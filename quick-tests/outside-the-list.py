#!/usr/bin/env python3
"""Outside the list: the same open task with and without an example list,
counting what each run finds that the list did not name. No answer key is
needed (#153 decision 3).

    outside-the-list.py --with with.md --without without.md --list list.txt
                        [--runs 3] (--at COMMIT | --seed-from PREPARED_DIR) [--out DIR]

--with and --without are the two briefs. --list holds the list's items, one
per line; without it, the lines of --with that --without lacks are taken.
Each run is a fresh Claude Code session in its own copy of a box: the
repository at --at, or a seed `rerun-subagent.py prepare` built (its restored
inputs and the original's system prompt come with it, and {BOX} in a brief is
filled in). Then one blind judge pass over every run of both briefs names the
distinct findings, says which list item each one is, if any, and which runs
found it.
"""

from __future__ import annotations

import argparse
import difflib
import json
import random
import shutil
import sys
from collections import defaultdict
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent / "lib"))
import qtlib as q  # noqa: E402

BOX_TOKEN = "{BOX}"

JUDGE_SCHEMA = {
    "type": "object",
    "properties": {
        "findings": {"type": "array", "items": {
            "type": "object",
            "properties": {
                "key": {"type": "string"},
                "statement": {"type": "string"},
                "list_item": {"type": "string"},
                "found_by": {"type": "array", "items": {"type": "string"}},
            },
            "required": ["key", "statement", "list_item", "found_by"]}},
    },
    "required": ["findings"],
}

JUDGE_PROMPT = """\
Below are the outputs of several runs of the same kind of open-ended task (finding risks, problems or cases in a piece of work), each under an id, in random order. Some runs were given a list of things to examine and some were not; you are not told which.

Build one combined list of the distinct findings across all outputs. A finding is one specific claim about the work: a risk, a defect, a case that breaks or a fact that was checked. Two outputs share a finding when they describe the same underlying issue, even in different words or with different evidence; they do not share it when they only touch the same file or area. A finding an output raises and then clears as fine still counts as a finding of that output (it examined it).

For each finding give:
- key: F1, F2, ... in any order;
- statement: one sentence naming the issue;
- list_item: the id of the item in the LIST below that names this same issue (L1, L2, ...), or "none" if no list item names it. An item names an issue when it points at that same case, not merely the same area;
- found_by: the ids of every output that contains it.

LIST
{items}

OUTPUTS

{outputs}
"""


def parse_args():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--with", dest="with_", required=True, help="the brief with the example list")
    ap.add_argument("--without", required=True, help="the same brief without it")
    ap.add_argument("--list", help="the list's items, one per line")
    ap.add_argument("--runs", type=int, default=3, help="runs per brief (default 3)")
    src = ap.add_mutually_exclusive_group()
    src.add_argument("--at", help="commit the box repository is at (default origin/main)")
    src.add_argument("--seed-from", help="a directory `rerun-subagent.py prepare` made: use its seed and system prompt")
    ap.add_argument("--mode", choices=["work", "read"], default="work",
                    help="work: a lane's tools, Bash sandboxed (default); read: Read, Grep, Glob only")
    ap.add_argument("--model", help="default: the prepared original's model, else claude-opus-5-5")
    ap.add_argument("--effort", default="high")
    ap.add_argument("--system-prompt-file", help="default: the prepared original's, else a general-purpose lane's")
    ap.add_argument("--judge-model", default="claude-opus-5-5")
    ap.add_argument("--judge-effort", default="high")
    ap.add_argument("--parallel", type=int, default=6)
    ap.add_argument("--timeout", type=int, default=60, help="minutes per run")
    ap.add_argument("--seed", type=int)
    ap.add_argument("--judge-only", action="store_true",
                    help="skip the runs; judge the runs already under --out again")
    ap.add_argument("--out")
    return ap.parse_args()


def derive_list(with_text: str, without_text: str) -> list[str]:
    a, b = with_text.splitlines(), without_text.splitlines()
    items = []
    for op, i1, i2, j1, j2 in difflib.SequenceMatcher(None, a, b).get_opcodes():
        if op in ("delete", "replace"):
            items += [x.strip().lstrip("-*0123456789. ").strip() for x in a[i1:i2] if x.strip()]
    return items


def main():
    a = parse_args()
    out = Path(a.out) if a.out else q.KIT / "trials" / f"outside-the-list-{q.now_stamp()}"
    out.mkdir(parents=True, exist_ok=True)
    texts = {"with": Path(a.with_).read_text(), "without": Path(a.without).read_text()}
    items = ([x.strip() for x in Path(a.list).read_text().splitlines() if x.strip()] if a.list
             else derive_list(texts["with"], texts["without"]))
    if not items:
        sys.exit("no list items: give --list")
    (out / "list.txt").write_text("\n".join(items) + "\n")
    for k, v in texts.items():
        (out / f"brief.{k}.md").write_text(v)

    if a.judge_only:
        model = a.model or "?"
        keys = [(v, i, out / "runs" / f"{v}-{i}") for v in texts for i in range(1, a.runs + 1)]
        results, problems = [], json.loads((out / "safety.json").read_text())["problems"]
        for _, _, rdir in keys:
            j = json.loads((rdir / "result.json").read_text())
            model = j.get("model", model)
            results.append(q.RunResult(out_dir=rdir, ok=j["ok"], final=j["final"], structured=None,
                                       cost_usd=j["cost_usd"], duration_s=j["duration_s"], num_turns=j["num_turns"]))
        a.effort = json.loads((keys[0][2] / "result.json").read_text()).get("effort", a.effort)
        judge_and_report(a, out, items, keys, results, model, problems)
        return
    if a.seed_from:
        prep = json.loads((Path(a.seed_from) / "prepare.json").read_text())
        seed = q.Box(Path(prep["seed"]))
        sp = a.system_prompt_file and Path(a.system_prompt_file).read_text() or (Path(a.seed_from) / "system-prompt.txt").read_text()
        model = a.model or (prep["models"][0] if prep["models"] else "claude-opus-5-5")
    else:
        seed = q.make_box(q.new_box_path("seed"), a.at or "origin/main")
        sp = Path(a.system_prompt_file or q.KIT / "lib" / "lane-system-prompt.txt").read_text()
        model = a.model or "claude-opus-5-5"
        mapping = q.default_mapping(seed)
        texts = {k: q.remap(v, mapping).replace(str(seed.root), BOX_TOKEN) for k, v in texts.items()}
    seed_hashes = q.tree_hashes(seed.root)
    seed_head = q.repo_head(seed)

    before = q.safety_preamble()
    jobs, keys = [], []
    for variant, text in texts.items():
        for i in range(1, a.runs + 1):
            rdir = out / "runs" / f"{variant}-{i}"
            keys.append((variant, i, rdir))

            def job(text=text, rdir=rdir):
                box = q.copy_box(seed, q.new_box_path("w"))
                fill = lambda s: s.replace(BOX_TOKEN, str(box.root))
                res = q.run_claude(box, fill(text), rdir, mode=a.mode, system_prompt=fill(sp), model=model,
                                   effort=a.effort, timeout_s=a.timeout * 60, hooks=False)
                q.collect_outputs(box, seed_hashes, seed_head, rdir, res.final)
                shutil.rmtree(box.root, ignore_errors=True)
                return res
            jobs.append(job)
    print(f"{len(jobs)} runs ({a.runs} per brief) with {model} at {a.effort}", flush=True)
    results = q.run_many(jobs, a.parallel)
    problems = q.safety_verdict(before, out)
    for (variant, i, rdir), r in zip(keys, results):
        print(f"  {variant}-{i}: ok={r.ok} {r.duration_s}s tools={len(r.tool_calls)} ${r.cost_usd:.2f} {r.error[:100]}", flush=True)

    judge_and_report(a, out, items, keys, results, model, problems)


def judge_and_report(a, out, items, keys, results, model, problems):
    """One blind judge pass over every output, then the report."""
    seed_n = a.seed if a.seed is not None else random.randrange(10**6)
    ids = q.blind_ids(len(keys), seed_n)
    blind = {bid: f"{v}-{i}" for bid, (v, i, _) in zip(ids, keys)}
    q.write_json(out / "blind-key.json", {"seed": seed_n, "ids": blind})
    blocks = []
    for bid in sorted(ids):
        v, i = blind[bid].rsplit("-", 1)
        text = (out / "runs" / blind[bid] / "output.md").read_text()
        text = q.re.sub(r"/private/tmp/wsbox/[^/\s`\"']+", BOX_TOKEN, text)
        blocks.append(f"===== OUTPUT {bid} =====\n{text}\n")
    prompt = JUDGE_PROMPT.format(items="\n".join(f"L{k}. {x}" for k, x in enumerate(items, 1)), outputs="\n".join(blocks))
    if len(prompt) > 600_000:
        sys.exit(f"the judge prompt is {len(prompt)} characters; trim the outputs (runs/*/output.md) first")
    verdict = q.judge(prompt, JUDGE_SCHEMA, out / "judge", model=a.judge_model, effort=a.judge_effort)
    q.write_json(out / "judge.json", verdict)
    write_report(out, a, items, keys, results, verdict, blind, model, problems)
    write_judged_items(out, items, verdict, blind)
    hits = q.privacy_check(out)
    print(f"report: {out / 'report.md'}")
    if problems or hits:
        print("SAFETY OR PRIVACY PROBLEMS:\n" + "\n".join(problems + hits))
        sys.exit(1)


def write_report(out, a, items, keys, results, verdict, blind, model, problems):
    F = verdict["findings"]
    runs = {"with": [f"with-{i}" for i in range(1, a.runs + 1)], "without": [f"without-{i}" for i in range(1, a.runs + 1)]}
    found = defaultdict(set)  # run name -> finding keys
    for f in F:
        for bid in f["found_by"]:
            if bid in blind:
                found[blind[bid]].add(f["key"])
    on = {f["key"] for f in F if f["list_item"] not in ("none", "", None)}
    L = ["# Outside the list", ""]
    L += [f"{a.runs} runs per brief with {model} at {a.effort}, mode {a.mode}; one blind judge pass ({a.judge_model} at {a.judge_effort}) "
          f"over all {2 * a.runs} outputs. Safety check: {'no problems' if not problems else '; '.join(problems)}.", ""]
    L += ["## Counts", "", "Per run: distinct findings, how many the list names, how many it does not.", "",
          "| Run | findings | on the list | outside the list | minutes | ok |", "|---|---|---|---|---|---|"]
    res_by = {f"{v}-{i}": r for (v, i, _), r in zip(keys, results)}
    for v in ("with", "without"):
        for name in runs[v]:
            ks = found[name]
            r = res_by[name]
            L.append(f"| {name} | {len(ks)} | {len(ks & on)} | {len(ks - on)} | {r.duration_s / 60:.1f} | {r.ok} |")
    L.append("")
    for v in ("with", "without"):
        union = set().union(*(found[n] for n in runs[v])) if runs[v] else set()
        L.append(f"- **{v}**: {len(union)} distinct findings across its runs; {len(union & on)} on the list, "
                 f"{len(union - on)} outside it.")
    only = {v: set().union(*(found[n] for n in runs[v])) for v in runs}
    L += [f"- Outside the list and found only by **without**: {len((only['without'] - only['with']) - on)}; "
          f"only by **with**: {len((only['with'] - only['without']) - on)}.", ""]

    L += ["## Each list item: how many runs found it", "", "| Item | with | without |", "|---|---|---|"]
    for k, it in enumerate(items, 1):
        keys_k = {f["key"] for f in F if f["list_item"] == f"L{k}"}
        c = {v: sum(1 for n in runs[v] if found[n] & keys_k) for v in runs}
        L.append(f"| L{k}. {it[:90]} | {c['with']}/{a.runs} | {c['without']}/{a.runs} |")
    L.append("")
    L += ["## Findings outside the list", "", "| Finding | with | without |", "|---|---|---|"]
    for f in F:
        if f["key"] in on:
            continue
        c = {v: sum(1 for n in runs[v] if f["key"] in found[n]) for v in runs}
        L.append(f"| {f['statement'][:160]} | {c['with']}/{a.runs} | {c['without']}/{a.runs} |")
    L.append("")
    L += ["## Files", "", "- `brief.with.md`, `brief.without.md`, `list.txt`: the inputs.",
          "- `runs/<brief>-<n>/output.md`: each run's final message and the files it wrote; `stream.jsonl` its events.",
          "- `judge.json`, `blind-key.json`: the judge's findings by blind id, and which id was which run.",
          "- `judged-items.jsonl`: the judge's list-item calls, for `judge-agreement.py`.", ""]
    (out / "report.md").write_text("\n".join(L))


def write_judged_items(out, items, verdict, blind):
    with open(out / "judged-items.jsonl", "w") as fh:
        for f in verdict["findings"]:
            fh.write(json.dumps({
                "item": f["key"],
                "question": "Which list item names this same issue (L1..Ln), or none?",
                "material": "LIST:\n" + "\n".join(f"L{k}. {x}" for k, x in enumerate(items, 1)) + f"\n\nFINDING: {f['statement']}",
                "choices": [f"L{k}" for k in range(1, len(items) + 1)] + ["none"],
                "judge": f["list_item"],
            }, ensure_ascii=False) + "\n")


if __name__ == "__main__":
    main()
