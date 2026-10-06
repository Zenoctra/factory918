#!/usr/bin/env python3
"""Re-run an old subagent: its brief (the first message of its transcript),
rewritten under a change, run against the repository as it was, then compared
with the original output and with what happened after (#153 decision 3).

    rerun-subagent.py show    AGENT
    rerun-subagent.py prepare AGENT --at COMMIT [--branch NAME] [--out DIR]
    rerun-subagent.py run     DIR --label NAME [--brief FILE] [--runs 3] [--model M] [--effort E]
    rerun-subagent.py compare DIR [--key FILE] [--rubric FILE] [--note FILE]

AGENT is an agent id (a1b2c3...), an agent-<id>.jsonl name or a path to a
subagent transcript under ~/.claude/projects/<this repo>/<session>/subagents/.
The transcript is copied, never changed.

prepare builds DIR/seed, a box holding the repository at --at (a fresh repo
with that one commit's history, no remote) and a scratchpad, and restores into
it the inputs the original read that are not in git: files still on disk from
before the original started, else the text of the original's own Read results.
It writes DIR/brief.md, the original brief with every old path rewritten to
{BOX}/..., which `run` fills in per run. Copy it, edit the copy under the
change, and run that copy under its own label.

run copies the seed for each run, starts a fresh Claude Code session in it
under the original's system prompt and model, sandboxed (no network, writes
only inside the box), and records the stream, the final message and every file
the run created or changed.

compare writes DIR/compare/report.md: the original and every run side by
side, what the launching agent did after the original returned, and, given a
--key (items the original found or missed) or a --rubric, one blind judge
pass over the original and all runs.
"""

from __future__ import annotations

import argparse
import json
import os
import random
import re
import shutil
import subprocess
import sys
from collections import defaultdict
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent / "lib"))
import qtlib as q  # noqa: E402

BOX_TOKEN = "{BOX}"


# --------------------------------------------------------------------------
# show
# --------------------------------------------------------------------------


def cmd_show(a):
    t = q.find_agent_transcript(a.agent)
    rows = q.load_rows(t)
    meta = q.agent_meta(t)
    calls = q.tool_calls(rows)
    brief = q.first_user_text(rows)
    ts = [r.get("timestamp") for r in rows if r.get("timestamp")]
    print(f"transcript: {t}")
    print(f"agent: {meta.get('agentType')} '{meta.get('description')}' depth {meta.get('spawnDepth')}")
    print(f"ran: {ts[0] if ts else '?'} to {ts[-1] if ts else '?'}; version {rows[0].get('version')}; "
          f"cwd {rows[0].get('cwd')} on {rows[0].get('gitBranch')}")
    print(f"models: {', '.join(q.models_used(rows))}; tool calls: {len(calls)}")
    print("\ncommits named in the brief that exist in the main checkout:")
    for sha in commits_named(brief):
        print(f"  {sha}  {git_main('log', '-1', '--format=%cI %s', sha)}")
    if ts:
        print(f"main as it was when the original started: {main_then(ts[0]) or '?'}")
    print("\nfiles read and written (first 40):")
    written = q.paths_written(calls)
    for c in calls[:200]:
        if c["name"] == "Read":
            p = c["input"].get("file_path")
            print(f"  read  {p}{'  (also written)' if p in written else ''}")
    for p in sorted(written)[:40]:
        print(f"  wrote {p}")
    print("\nbrief (first 1500 characters):\n" + brief[:1500])


def commits_named(text: str) -> list[str]:
    out = []
    for sha in dict.fromkeys(re.findall(r"\b[0-9a-f]{7,40}\b", text)):
        if git_main("rev-parse", "--verify", "-q", f"{sha}^{{commit}}"):
            out.append(sha)
    return out


def git_main(*args) -> str:
    return subprocess.run(["git", "-C", str(q.main_checkout()), *args], capture_output=True, text=True).stdout.strip()


def main_then(ts: str) -> str:
    return git_main("rev-list", "-1", "--first-parent", f"--before={ts}", "origin/main")


# --------------------------------------------------------------------------
# prepare
# --------------------------------------------------------------------------


def cmd_prepare(a):
    t = q.find_agent_transcript(a.agent)
    rows = q.load_rows(t)
    meta = q.agent_meta(t)
    calls = q.tool_calls(rows)
    out = Path(a.out) if a.out else q.KIT / "trials" / f"rerun-{t.stem.removeprefix('agent-')[:8]}-{q.now_stamp()}"
    if (out / "prepare.json").exists():
        sys.exit(f"{out} is already prepared; prepare into a new directory")
    (out / "original").mkdir(parents=True, exist_ok=True)
    shutil.copy2(t, out / "original" / "transcript.jsonl")
    mt = t.with_name(t.stem + ".meta.json")
    if mt.exists():
        shutil.copy2(mt, out / "original" / "meta.json")

    start = next((r["timestamp"] for r in rows if r.get("timestamp")), None)
    brief = q.first_user_text(rows)
    # The seed lives outside the kit (it holds a git repo) and outside every protected tree.
    seed = q.make_box(q.new_box_path("seed"), a.at, a.branch)
    extra_refs = {}
    if start and not a.no_main:
        m = main_then(start)
        if m and not a.branch == "main":
            subprocess.run(["git", "-C", str(seed.repo), "fetch", "-q", "--no-tags", str(q.main_checkout()), m],
                           check=True, env=q.git_env(seed))
            subprocess.run(["git", "-C", str(seed.repo), "branch", "-f", "main", m], check=True, env=q.git_env(seed))
            extra_refs["main"] = m

    # Old roots -> the box. The seed path itself is replaced by {BOX} so each
    # run can live at its own path.
    all_text = brief + "\n" + "\n".join(json.dumps(c["input"]) for c in calls) + "\n" + json.dumps(rows[:20])
    mapping = q.default_mapping(seed, [rows[0].get("cwd")] if rows[0].get("cwd") else [])
    mapping += q.scratchpad_mapping(all_text, seed)
    mapping += [(old, new) for old, new in (m.split("=", 1) for m in a.map)]

    def to_token(s: str) -> str:
        return q.remap(s, mapping).replace(str(seed.root), BOX_TOKEN)

    # Restore inputs: paths the brief names and paths the original read, minus what it wrote.
    written = q.paths_written(calls)
    reads = q.reconstruct_reads(calls)
    candidates = set(q.abs_paths_in(brief)) | set(reads)
    for c in calls:
        if c["name"] == "Bash":
            candidates |= q.abs_paths_in(q.expand_vars(c["input"].get("command", "")))
    candidates |= set(a.input)
    inputs = []
    start_epoch = iso_epoch(start) if start else None
    others = q.session_writes(t, {c for c in candidates if c not in written and not Path(c).exists()}, start or "")
    for old in sorted(candidates):
        new = q.remap(old, mapping)
        rec = {"original_path": old, "box_path": new.replace(str(seed.root), BOX_TOKEN)}
        if old in written:
            rec["status"] = "written by the original; not restored"
        elif not new.startswith(str(seed.root)):
            rec["status"] = "outside the box; not restored"
        elif Path(old).is_dir() or Path(new).is_dir():
            rec["status"] = "directory; its files are listed on their own"
        elif Path(new).exists():
            rec["status"] = "present (in git at the commit)" if Path(new).is_file() else "present (directory)"
        elif Path(old).is_file() and start_epoch and Path(old).stat().st_mtime <= start_epoch + 5:
            Path(new).parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(old, new)
            rec["status"] = "restored from disk (unchanged since before the original started)"
        elif old in others:
            Path(new).parent.mkdir(parents=True, exist_ok=True)
            Path(new).write_text(others[old])
            rec["status"] = "restored from what other agents of the session wrote before the original started"
        elif old in reads:
            Path(new).parent.mkdir(parents=True, exist_ok=True)
            Path(new).write_text(reads[old])
            rec["status"] = "restored from the original's Read results"
        elif Path(old).exists():
            rec["status"] = "MISSING: on disk but changed after the original started"
        else:
            rec["status"] = "MISSING: gone from disk and not fully read by the original"
        inputs.append(rec)

    # The original's output: its final message and the files it wrote (Write/Edit replayed).
    final = q.final_text(rows)
    writes = q.reconstruct_writes(calls)
    end = next((r["timestamp"] for r in reversed(rows) if r.get("timestamp")), None)
    for p in sorted(written - set(writes)):
        # A file the original wrote by shell: take it from disk if nothing touched it after
        # the original ended, else from a heredoc in the original's command.
        f = Path(p)
        if f.is_file() and start and end and iso_epoch(start) - 5 <= f.stat().st_mtime <= iso_epoch(end) + 60:
            writes[p] = f.read_text(errors="replace")
    for p, text in q.heredoc_writes(calls).items():
        writes.setdefault(p, text)
    (out / "original" / "final.md").write_text(final)
    parts = ["## Final message\n", final.strip() or "(empty)", ""]
    for p, text in writes.items():
        parts += [f"## File written: {p}\n", "```", text.rstrip(), "```", ""]
    bash_written = sorted(p for p in written if p not in writes)
    if bash_written:
        parts += ["## Written by shell commands (content not recoverable from the transcript)\n",
                  "\n".join(bash_written), ""]
    (out / "original" / "output.md").write_text("\n".join(parts))
    (out / "original" / "trace.md").write_text(trace(calls))
    parent, after = q.parent_after(t, meta)
    (out / "original" / "after.md").write_text(
        f"# What the launching agent did next\n\nParent transcript: {parent}\n\n{after or '(not found)'}\n")

    (out / "brief.md").write_text(to_token(brief))
    system_prompt = q.snapshot_system_prompt(rows)
    env_note = env_block(rows, mapping, seed)
    (out / "system-prompt.txt").write_text(to_token((system_prompt or "") + ("\n\n" + env_note if env_note else "")))
    models = q.models_used(rows)
    m = re.search(r"Requested effort: (low|medium|high|xhigh|max)", brief)
    q.write_json(out / "prepare.json", {
        "effort": m.group(1) if m else None,
        "transcript": str(t), "seed": str(seed.root), "meta": meta, "started": start, "commit": a.at,
        "commit_full": q.repo_head(seed), "branch": a.branch, "extra_refs": extra_refs,
        "models": models, "mapping": [[o, n.replace(str(seed.root), BOX_TOKEN)] for o, n in mapping],
        "inputs": inputs, "original_skill_listing": q.skill_listing(rows)[:6000],
    })
    q.write_json(out / "seed-hashes.json", q.tree_hashes(seed.root))
    missing = [i for i in inputs if i["status"].startswith("MISSING")]
    print(f"prepared {out}")
    print(f"  repo at {a.at} ({q.repo_head(seed)[:9]}), main at {extra_refs.get('main', '-')[:9]}; models {models}")
    for i in inputs:
        print(f"  {i['status']}: {i['original_path']}")
    if missing:
        print(f"  {len(missing)} input(s) missing: put them in the seed by hand or accept the gap")


def iso_epoch(ts: str) -> float:
    import datetime as dt
    return dt.datetime.fromisoformat(ts.replace("Z", "+00:00")).timestamp()


def env_block(rows, mapping, seed) -> str:
    """The original's environment attachment, remapped: the default system prompt
    carries this, a replaced one does not, so it is appended."""
    for r in rows:
        a = r.get("attachment") or {}
        if a.get("type") == "environment":
            text = q.flatten(r.get("rendered")) if r.get("rendered") else ""
            if not text:
                snap = a.get("snapshot") or {}
                text = "\n".join(f"{k}: {v}" for k, v in snap.items())
            text = re.sub(r"</?system-reminder>", "", text).strip()
            text = q.remap(text, mapping)
            return text
    return ""


def trace(calls) -> str:
    L = ["# The original's tool calls, in order", ""]
    for i, c in enumerate(calls, 1):
        inp = c["input"]
        head = inp.get("command") or inp.get("file_path") or inp.get("pattern") or inp.get("description") or json.dumps(inp)[:200]
        L.append(f"{i}. [{(c.get('ts') or '')[11:19]}] {c['name']}: {str(head)[:300]}" + ("  (error)" if c["is_error"] else ""))
    return "\n".join(L) + "\n"


# --------------------------------------------------------------------------
# run
# --------------------------------------------------------------------------


def cmd_run(a):
    d = Path(a.dir)
    prep = json.loads((d / "prepare.json").read_text())
    seed = q.Box(Path(prep["seed"]))
    if not seed.repo.exists():
        sys.exit(f"the seed {seed.root} is gone (boxes live in /private/tmp); run prepare again into a new directory")
    seed_hashes = json.loads((d / "seed-hashes.json").read_text())

    brief_t = Path(a.brief).read_text() if a.brief else (d / "brief.md").read_text()
    sp_t = (d / "system-prompt.txt").read_text()
    model = a.model or (prep["models"][0] if prep["models"] else "claude-opus-5-5")
    a.effort = a.effort or prep.get("effort") or "high"
    seed_head = q.repo_head(seed)
    before = q.safety_preamble()
    jobs, labels = [], []
    for i in range(1, a.runs + 1):
        rdir = d / "runs" / f"{a.label}-{i}"
        if rdir.exists():
            sys.exit(f"{rdir} exists; pick another label")
        labels.append(rdir)

        def job(rdir=rdir):
            box = q.copy_box(seed, q.new_box_path("w"))
            fill = lambda s: s.replace(BOX_TOKEN, str(box.root))
            run_hashes = dict(seed_hashes)
            if a.overlay:
                # Files the change rewrites inside the box (a brief file a script wrote, a
                # skill): laid over the seed, paths relative to the box root. Overlaid files
                # count as the seed, not as output.
                for f in Path(a.overlay).rglob("*"):
                    if f.is_file():
                        dst = box.root / f.relative_to(a.overlay)
                        dst.parent.mkdir(parents=True, exist_ok=True)
                        dst.write_text(fill(f.read_text()))
                        run_hashes[str(dst.relative_to(box.root))] = q.hashlib.sha256(dst.read_bytes()).hexdigest()
            res = q.run_claude(box, fill(brief_t), rdir, mode="work", system_prompt=fill(sp_t) or None,
                               model=model, effort=a.effort, timeout_s=a.timeout * 60, hooks=a.hooks)
            q.collect_outputs(box, run_hashes, seed_head, rdir, res.final)
            (rdir / "box-path.txt").write_text(str(box.root) + "\n")
            if not a.keep_boxes:
                shutil.rmtree(box.root, ignore_errors=True)
            return res
        jobs.append(job)
    print(f"{a.runs} run(s) of '{a.label}' with {model} at {a.effort}", flush=True)
    results = q.run_many(jobs, a.parallel)
    problems = q.safety_verdict(before, d / "runs", f"safety-{a.label}.json")
    for rdir, r in zip(labels, results):
        print(f"  {rdir.name}: ok={r.ok} {r.duration_s}s turns={r.num_turns} tools={len(r.tool_calls)} "
              f"${r.cost_usd:.2f} denied={len(r.denied)} {r.error[:120]}")
    if problems:
        print("SAFETY PROBLEMS:\n" + "\n".join(problems))
        sys.exit(1)


# --------------------------------------------------------------------------
# compare
# --------------------------------------------------------------------------

KEY_SCHEMA = {
    "type": "object",
    "properties": {
        "outputs": {"type": "array", "items": {
            "type": "object",
            "properties": {
                "id": {"type": "string"},
                "key": {"type": "array", "items": {
                    "type": "object",
                    "properties": {"item": {"type": "string"}, "present": {"type": "string", "enum": ["yes", "partly", "no"]},
                                   "evidence": {"type": "string"}},
                    "required": ["item", "present", "evidence"]}},
                "rubric": {"type": "array", "items": {
                    "type": "object",
                    "properties": {"criterion": {"type": "string"}, "score": {"type": "integer", "minimum": 0, "maximum": 3},
                                   "evidence": {"type": "string"}},
                    "required": ["criterion", "score", "evidence"]}},
                "other_findings": {"type": "array", "items": {"type": "string"}},
            },
            "required": ["id", "key", "rubric", "other_findings"]}},
    },
    "required": ["outputs"],
}

JUDGE_PROMPT = """\
Below are several outputs of the same piece of delegated work, each under an id. They were produced by separate runs; you are not told which run produced which, and the order is random.

{key_block}{rubric_block}For each output, also list in "other_findings" any substantive finding or decision it contains that the items above do not cover, one short line each (empty if none).

Judge only from what each output says. Quote or point at the place in the output that supports each answer.

{outputs}
"""

KEY_BLOCK = """\
For each output and each numbered item in the KEY, say whether the output contains it: "yes" if it states it plainly, "partly" if it touches it without the substance, "no" if absent. Paraphrase counts; the item has to be the same issue, not a neighbour of it.

KEY
{key}

"""

RUBRIC_BLOCK = """\
Score each output on each RUBRIC criterion from 0 (not at all) to 3 (fully), on one scale for all outputs.

RUBRIC
{rubric}

"""


def cmd_compare(a):
    d = Path(a.dir)
    prep = json.loads((d / "prepare.json").read_text())
    cdir = d / "compare"
    cdir.mkdir(exist_ok=True)
    entries = [("original", d / "original" / "output.md", None)]
    for rdir in sorted((d / "runs").glob("*-*")):
        if (rdir / "output.md").exists():
            entries.append((rdir.name, rdir / "output.md", json.loads((rdir / "result.json").read_text())))
    L = [f"# Re-run of '{prep['meta'].get('description', '?')}'", ""]
    L += [f"Original: `{prep['transcript']}`, started {prep['started']}, models {', '.join(prep['models'])}. "
          f"Repository at `{prep['commit']}` ({(prep['commit_full'] or '')[:9]}).", ""]
    missing = [i for i in prep["inputs"] if i["status"].startswith("MISSING")]
    if missing:
        L += ["Inputs the re-runs did not have:", ""] + [f"- `{i['original_path']}`: {i['status']}" for i in missing] + [""]
    L += ["## Runs", "", "| Run | ok | minutes | turns | tool calls | cost (API terms) | files changed |", "|---|---|---|---|---|---|---|"]
    orig_calls = len([x for x in (d / "original" / "trace.md").read_text().splitlines() if re.match(r"^\d+\. ", x)])
    L.append(f"| original | - | {original_minutes(d)} | - | {orig_calls} | - | see output |")
    for name, path, res in entries[1:]:
        ch = json.loads((path.parent / "changed-files.json").read_text())
        L.append(f"| {name} | {res['ok']} | {res['duration_s'] / 60:.1f} | {res['num_turns']} | {res['tool_calls']} | "
                 f"${res['cost_usd']:.2f} | {len(ch['changed'])} |")
    L.append("")

    verdict = None
    key = Path(a.key).read_text().strip() if a.key else ""
    rubric = Path(a.rubric).read_text().strip() if a.rubric else ""
    if key or rubric:
        seed = a.seed if a.seed is not None else random.randrange(10**6)
        ids = q.blind_ids(len(entries), seed)
        blind = dict(zip(ids, [e[0] for e in entries]))
        q.write_json(cdir / "blind-key.json", {"seed": seed, "ids": blind})
        blocks = []
        for bid in sorted(ids):
            name = blind[bid]
            path = next(p for n, p, _ in entries if n == name)
            text = neutralize(path.read_text(), prep)
            blocks.append(f"===== OUTPUT {bid} =====\n{text}\n")
        prompt = JUDGE_PROMPT.format(key_block=KEY_BLOCK.format(key=key) if key else "",
                                     rubric_block=RUBRIC_BLOCK.format(rubric=rubric) if rubric else "",
                                     outputs="\n".join(blocks))
        verdict = q.judge(prompt, KEY_SCHEMA, cdir / "judge", model=a.judge_model, effort=a.judge_effort)
        q.write_json(cdir / "judge.json", verdict)
        by = {o["id"]: o for o in verdict["outputs"]}
        if key:
            items = [o["item"] for o in verdict["outputs"][0]["key"]]
            L += ["## Key items found", "", "Each cell: yes / partly / no, from one blind judge pass over the original and every run.", ""]
            names = [e[0] for e in entries]
            L += ["| Item | " + " | ".join(names) + " |", "|---|" + "---|" * len(names)]
            inv = {v: k for k, v in blind.items()}
            for idx, it in enumerate(items):
                row = []
                for n in names:
                    o = by.get(inv[n])
                    row.append(o["key"][idx]["present"] if o and idx < len(o["key"]) else "?")
                L.append(f"| {it[:90]} | " + " | ".join(row) + " |")
            L.append("")
            # Per label: how often each key item came back.
            groups = defaultdict(list)
            for n in names[1:]:
                groups[n.rsplit("-", 1)[0]].append(n)
            if groups:
                L += ["How often each item came back, per label (yes or partly):", ""]
                for g, members in groups.items():
                    counts = []
                    for idx, it in enumerate(items):
                        k = sum(1 for n in members if by.get(inv[n]) and by[inv[n]]["key"][idx]["present"] in ("yes", "partly"))
                        counts.append(f"item {idx + 1}: {k}/{len(members)}")
                    L.append(f"- {g}: " + ", ".join(counts))
                L.append("")
        if rubric:
            names = [e[0] for e in entries]
            inv = {v: k for k, v in blind.items()}
            crits = [r["criterion"] for r in verdict["outputs"][0]["rubric"]]
            L += ["## Rubric scores (0 to 3)", "", "| Criterion | " + " | ".join(names) + " |", "|---|" + "---|" * len(names)]
            for idx, cr in enumerate(crits):
                L.append(f"| {cr[:80]} | " + " | ".join(str(by[inv[n]]["rubric"][idx]["score"]) if idx < len(by[inv[n]]["rubric"]) else "?" for n in names) + " |")
            L.append("")
        L += ["## Findings outside the key, per output", ""]
        inv = {v: k for k, v in blind.items()}
        for name, _, _ in entries:
            o = by.get(inv[name])
            if o and o["other_findings"]:
                L += [f"- {name}:"] + [f"  - {x}" for x in o["other_findings"]]
        L.append("")
        write_judged_items(cdir, verdict, blind, entries, key, rubric)

    L += ["## What happened after the original returned", ""]
    if a.note:
        L += [Path(a.note).read_text().strip(), ""]
    L += ["The launching agent's next steps, from its transcript: `original/after.md`.", ""]
    L += ["## Outputs", "", "Each output in full: `original/output.md` and `runs/<label>-<n>/output.md`. "
          "Each run's event stream: `runs/<label>-<n>/stream.jsonl`; files it wrote: `runs/<label>-<n>/written/`.", ""]
    (cdir / "report.md").write_text("\n".join(L))
    hits = q.privacy_check(d)
    print(f"report: {cdir / 'report.md'}")
    if hits:
        print("PRIVACY:\n" + "\n".join(hits))


def neutralize(text: str, prep: dict) -> str:
    """Make the original's paths look like a run's, so the judge cannot spot it by path."""
    for old, new in prep["mapping"]:
        text = text.replace(old, new)
    text = re.sub(r"/private/tmp/wsbox/[^/\s`\"']+", BOX_TOKEN, text)
    return text


def original_minutes(d: Path) -> str:
    rows = q.load_rows(d / "original" / "transcript.jsonl")
    ts = [r["timestamp"] for r in rows if r.get("timestamp")]
    if len(ts) < 2:
        return "?"
    return f"{(iso_epoch(ts[-1]) - iso_epoch(ts[0])) / 60:.1f}"


def write_judged_items(cdir, verdict, blind, entries, key, rubric):
    paths = {n: p for n, p, _ in entries}
    with open(cdir / "judged-items.jsonl", "w") as fh:
        for o in verdict["outputs"]:
            name = blind.get(o["id"])
            if not name:
                continue
            for k in o["key"]:
                fh.write(json.dumps({
                    "item": f"{o['id']}:key:{k['item'][:40]}",
                    "question": f"Does this output contain the item: {k['item']}? yes / partly / no",
                    "material": f"Read the output at {paths[name]} (blind id {o['id']}).",
                    "choices": ["yes", "partly", "no"],
                    "judge": k["present"],
                }, ensure_ascii=False) + "\n")


# --------------------------------------------------------------------------


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="cmd", required=True)
    s = sub.add_parser("show")
    s.add_argument("agent")
    p = sub.add_parser("prepare")
    p.add_argument("agent")
    p.add_argument("--at", required=True, help="the commit the original worked at")
    p.add_argument("--branch", help="check the commit out on this branch name (default: detached)")
    p.add_argument("--no-main", action="store_true", help="do not add a main branch at main-as-it-was")
    p.add_argument("--map", action="append", default=[], metavar="OLD=NEW",
                   help="an extra path rewrite; NEW may use {BOX}")
    p.add_argument("--input", action="append", default=[], metavar="PATH",
                   help="an extra original path to restore, when the brief abbreviates it")
    p.add_argument("--out")
    r = sub.add_parser("run")
    r.add_argument("dir")
    r.add_argument("--label", required=True)
    r.add_argument("--brief", help="the brief to run (default DIR/brief.md, the original)")
    r.add_argument("--overlay", help="a directory laid over each box before the run (paths relative to the box root, "
                                      "e.g. factory918/.scratch/x/brief.md); {BOX} in its files is filled in")
    r.add_argument("--runs", type=int, default=3)
    r.add_argument("--model", help="default: the original's model")
    r.add_argument("--effort", help="default: the effort the brief requested, else high")
    r.add_argument("--parallel", type=int, default=3)
    r.add_argument("--timeout", type=int, default=60, help="minutes per run")
    r.add_argument("--hooks", action="store_true",
                   help="run the box repo's hooks (default off: a re-run is a main session, so hooks a subagent never meets, "
                        "such as SessionStart, UserPromptSubmit and the delegation guard, would fire)")
    r.add_argument("--keep-boxes", action="store_true")
    c = sub.add_parser("compare")
    c.add_argument("dir")
    c.add_argument("--key", help="numbered items to look for in every output (what the original found or missed)")
    c.add_argument("--rubric", help="criteria to score 0-3")
    c.add_argument("--note", help="what happened after, from the record (a postmortem line, a PR comment)")
    c.add_argument("--judge-model", default="claude-opus-5-5")
    c.add_argument("--judge-effort", default="high")
    c.add_argument("--seed", type=int)
    a = ap.parse_args()
    {"show": cmd_show, "prepare": cmd_prepare, "run": cmd_run, "compare": cmd_compare}[a.cmd](a)


if __name__ == "__main__":
    main()
