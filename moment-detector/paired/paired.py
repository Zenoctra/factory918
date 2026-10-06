#!/usr/bin/env python3
"""Paired replays of real moments: the moment detector's hook live in both arms,
delivering its suggestion in one and running in shadow in the other.

  paired.py kits                                  Build the two arms' hook kits.
  paired.py run NAME ARM [-n N] [--parallel P]    Replay one moment in one arm.
  paired.py collect                               One row per run: the check, delivery, uptake, cost.
  paired.py judge NAME [--model M]                One blind judge pass over every run of a moment.
  paired.py report                                Aggregate tables (no transcript text).

The moments are listed in $PAIRED_DATA/moments.json (default: the main
checkout's .scratch/moment-detector/paired/), with the criteria files the judge
reads. Everything that holds Manuel's words stays there or in the replay
folders under $PAIRED_ROOT; README.md beside this file has the method.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import os
import random
import re
import shutil
import subprocess
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
KIT = HERE.parent.parent
sys.path.insert(0, str(KIT / "moment-detector" / "hook"))
sys.path.insert(0, str(KIT / "quick-tests" / "lib"))
import md  # noqa: E402
import qtlib  # noqa: E402

REPLAY = KIT / "quick-tests" / "replay" / "replay.py"
# Run folders are seen by the replayed model (its working directory sits inside
# one), so their names say nothing about the arms or the experiment.
ROOT = Path(os.environ.get("PAIRED_ROOT", "/private/tmp/wsr"))
DATA = Path(os.environ.get("PAIRED_DATA", qtlib.main_checkout() / ".scratch" / "moment-detector" / "paired"))
LIBRARY = qtlib.main_checkout() / ".scratch" / "moment-detector" / "moments" / "library.jsonl"
MODEL = "claude-opus-5-5"
# Neutral folder letters for the arms.
ARMS = {"deliver": "p", "shadow": "q"}


def moments() -> dict:
    return {m["name"]: m for m in json.loads((DATA / "moments.json").read_text())}


def library_row(lib_id: str) -> dict:
    for line in open(LIBRARY):
        r = json.loads(line)
        if r["id"] == lib_id:
            return r
    sys.exit(f"{lib_id} is not in {LIBRARY}")


def out_dir(name: str, arm: str) -> Path:
    return ROOT / f"{name}-{ARMS[arm]}"


# ---------------------------------------------------------------- the arms

def cmd_kits(a) -> None:
    """Each arm gets a copy of the hook and the shipped correction moment; they
    differ in one key, `deliver`. The hook runs unsandboxed as a user's hook
    would, outside the replay's API proxy, and logs into the run's folder. It
    reads the transcript the replay resumed from (MD_TRANSCRIPT): the forked
    session's own file does not exist yet when the hook fires."""
    for arm, letter in ARMS.items():
        kit = ROOT / "kits" / letter
        if kit.exists():
            shutil.rmtree(kit)
        (kit / "moments").mkdir(parents=True)
        shutil.copy(KIT / "moment-detector" / "hook" / "md.py", kit / "md.py")
        shutil.copytree(KIT / "moment-detector" / "hook" / "moments" / "correction", kit / "moments" / "correction")
        mj = kit / "moments" / "correction" / "moment.json"
        m = json.loads(mj.read_text())
        m["deliver"] = arm == "deliver"
        mj.write_text(json.dumps(m, indent=2) + "\n")
        # MD_KIT names the kit's contents, so replay's folder check refuses a rebuilt kit
        # that differs from the one a folder's earlier runs used.
        digest = hashlib.sha256()
        for f in sorted(kit.rglob("*")):
            if f.is_file():
                digest.update(f.relative_to(kit).as_posix().encode() + f.read_bytes())
        command = (f'env -u ANTHROPIC_BASE_URL MD_KIT={digest.hexdigest()[:12]} '
                   f'MD_LOG="$REPLAY_RUN_DIR/md-checks.jsonl" MD_TRANSCRIPT="$REPLAY_RUN_DIR/source.jsonl" '
                   f'MD_MOMENTS="{kit}/moments" MD_CLAUDE="{md.find_cli()}" python3 "{kit}/md.py" hook')
        hooks = {"UserPromptSubmit": [{"hooks": [{"type": "command", "command": command, "timeout": 60}]}]}
        (kit / "hooks.json").write_text(json.dumps(hooks, indent=1) + "\n")
        print(f"{arm}: {kit}")


def cmd_run(a) -> None:
    m = moments()[a.name]
    row = library_row(m["id"])
    session = Path.home() / ".claude" / "projects" / row["project"] / f"{row['session_id']}.jsonl"
    cmd = [sys.executable, str(REPLAY), "run", str(session), "--at", row["uuid"], "--out", str(out_dir(a.name, a.arm)),
           "-n", str(a.n), "--parallel", str(a.parallel), "--model", MODEL, "--cli", md.find_cli(), "--persist",
           "--hooks", str(ROOT / "kits" / ARMS[a.arm] / "hooks.json"), "--max-turns", str(a.max_turns)]
    if m.get("repo"):
        cmd += ["--repo", m["repo"]]
    if a.effort:
        cmd += ["--effort", a.effort]
    # Two batches on one folder overwrite each other's runs: one at a time.
    lock = out_dir(a.name, a.arm).with_suffix(".lock")
    try:
        fd = os.open(lock, os.O_CREAT | os.O_EXCL)
    except FileExistsError:
        sys.exit(f"{lock} exists: a batch is running on this folder (or crashed; remove the lock)")
    try:
        rc = subprocess.run(cmd).returncode
    finally:
        os.close(fd)
        lock.unlink()
    sys.exit(rc)


# ---------------------------------------------------------------- what each run did

def run_transcript(run_dir: Path) -> Path | None:
    """The forked session's transcript, which replay --persist moved into the folder.
    Its folder is named after the run's path when it ran, so match the path's tail:
    the replays may have been moved since."""
    tail = qtlib.slug(Path(run_dir.name) / "w" / "repo")
    found = sorted((run_dir.parent.parent / "claude-home-leftovers" / "projects").glob(f"*-runs-{tail}/*.jsonl"))
    return found[0] if found else None


def run_cost(run_dir: Path, meta: dict) -> float | None:
    """The run's own cost. A resumed session's `total_cost_usd` can carry the cost the
    original session had run up (about $1,556 on one session). replay.py records
    `run_cost_usd`; for runs made before it did, the baseline is the stream's first
    result, reported before any turn."""
    if "run_cost_usd" in meta:
        return meta["run_cost_usd"]
    baseline = 0.0
    for line in open(run_dir / "stream.jsonl"):
        if '"total_cost_usd"' in line:
            ev = json.loads(line)
            if ev.get("type") == "result" and ev.get("num_turns") == 0:
                baseline = ev["total_cost_usd"]
                break
    total = meta.get("total_cost_usd")
    return None if total is None else total - baseline


ARM_IN_PATH = re.compile(r"(?<![A-Za-z0-9])(m\d+)-[" + "".join(ARMS.values()) + r"](?=[/-])")
MARKER = re.compile(r"\(md-[0-9a-f]{6}(?:\s+declined:[^)]*)?\)\s*")


def run_rows(name: str, arm: str) -> list[dict]:
    rows = []
    out = out_dir(name, arm)
    for run_dir in sorted(out.glob("runs/[0-9]*")):
        if not (run_dir / "meta.json").exists():
            continue
        meta = json.loads((run_dir / "meta.json").read_text())
        checks_path = run_dir / "md-checks.jsonl"
        checks = [json.loads(x) for x in open(checks_path)] if checks_path.exists() else []
        c = checks[0] if checks else {}
        transcript = run_transcript(run_dir)
        up = md.uptake(str(transcript), str(checks_path)) if transcript else []
        text = (run_dir / "all-text.md").read_text() if (run_dir / "all-text.md").exists() else ""
        u = next((x for x in up if x["id"] == c.get("id")), None)
        rows.append({
            "moment": name, "arm": arm, "run": run_dir.name,
            "outcome": meta.get("subtype"), "turns": meta.get("num_turns"),
            "main_cost_usd": run_cost(run_dir, meta), "wall_s": meta.get("wall_s"),
            "checks": len(checks), "check_id": c.get("id"), "skipped": c.get("skipped"), "error": c.get("error"),
            "score": (c.get("verdict") or {}).get("score"), "fired": bool((c.get("verdict") or {}).get("moment")),
            "delivered": bool(c.get("delivered")),
            "detector_cost_usd": c.get("cost_usd"), "hook_ms": (c.get("latency_ms") or {}).get("hook"),
            "transcript": bool(transcript),
            # Delivery as the session recorded it: the suggestion's attachment in the transcript.
            "reached_transcript": u is not None,
            "uptake": u["outcome"] if u else ("not_delivered" if not c.get("delivered") else "attachment_missing"),
            "decline_reason": u["reason"] if u else None,
            "marker_in_text": bool(MARKER.search(text)),
        })
    return rows


def cmd_collect(a) -> None:
    rows = [r for name in moments() for arm in ARMS for r in run_rows(name, arm)]
    (DATA / "runs.jsonl").write_text("".join(json.dumps(r) + "\n" for r in rows))
    print(f"{len(rows)} runs -> {DATA / 'runs.jsonl'}")


# ---------------------------------------------------------------- the blind judge

JUDGE_FRAME = """You are reading {n} independent re-runs of one turn in a past working session between an AI \
agent and Manuel, the person it works for. Each re-run starts from the same point: Manuel has just sent the \
message quoted below, and the agent responds. The re-runs are labelled with random ids, in random order. You see \
only what each re-run wrote and the tools it called.

{context}

# Questions

Answer every question for every re-run on its own, "yes", "no" or "unclear", and quote the words that decided it \
(or say what is missing). Do not reward or punish anything the questions do not ask about.

{criteria}

Then, in `groups`, say whether the re-runs fall into two or more distinct groups by how they respond to Manuel's \
message (not by style or length alone). If they do, name each group by the ids in it and say in one or two \
sentences what sets it apart. If they do not, return an empty list.

# Re-runs
"""


def judge_schema(keys: list[str]) -> dict:
    verdict = {"type": "object", "required": ["answer", "evidence"],
               "properties": {"answer": {"enum": ["yes", "no", "unclear"]}, "evidence": {"type": "string"}}}
    return {"type": "object", "required": ["runs", "groups"], "properties": {
        "runs": {"type": "array", "items": {"type": "object", "required": ["id", *keys],
                                             "properties": {"id": {"type": "string"},
                                                            **{k: verdict for k in keys}}}},
        "groups": {"type": "array", "items": {"type": "object", "required": ["ids", "what_sets_it_apart"],
                                               "properties": {"ids": {"type": "array", "items": {"type": "string"}},
                                                              "what_sets_it_apart": {"type": "string"}}}}}}


def blind_text(run_dir: Path) -> str:
    """What the judge reads of one run: its words with the suggestion's markers removed
    (only the delivering arm can write them), and its tool calls. Paths name the run's
    folder, `m01-p` or `m01-q`, as a path or a slug; the arm's letter becomes x."""
    text = ARM_IN_PATH.sub(r"\1-x", MARKER.sub("", (run_dir / "all-text.md").read_text())).strip()
    tools = ARM_IN_PATH.sub(r"\1-x", (run_dir / "tools.txt").read_text()).strip()
    return f"## Text it wrote\n\n{text or '(no text)'}\n\n## Tools it called\n\n{tools or '(none)'}\n"


def cmd_judge(a) -> None:
    """One pass over every run of both arms of one moment, shuffled under blind ids.
    The criteria file holds the context (`# Context` ... ) and the questions as
    `- **key**: question` lines."""
    crit = (DATA / "criteria" / f"{a.name}.md").read_text()
    context, _, questions = crit.partition("# Questions")
    keys = re.findall(r"^- \*\*([a-z_]+)\*\*", questions, re.M)
    runs = [(arm, p) for arm in ARMS for p in sorted(out_dir(a.name, arm).glob("runs/[0-9]*"))
            if (p / "meta.json").exists()]
    rng = random.Random(a.seed)
    ids = [f"r{k}" for k in rng.sample(range(100, 1000), len(runs))]
    items = list(zip(ids, runs))
    rng.shuffle(items)
    prompt = JUDGE_FRAME.format(n=len(items), context=context.strip(), criteria=questions.strip())
    prompt += "".join(f"\n\n# Re-run {rid}\n\n{blind_text(p)}" for rid, (_, p) in items)
    jdir = DATA / "judged" / a.model / a.name
    jdir.mkdir(parents=True, exist_ok=True)
    (jdir / "packet.md").write_text(prompt)
    (jdir / "key.json").write_text(json.dumps({rid: {"arm": arm, "run": p.name} for rid, (arm, p) in items}, indent=1))
    res = qtlib.judge(prompt, judge_schema(keys), jdir, model=a.model, effort=a.effort)
    (jdir / "verdicts.json").write_text(json.dumps(res, indent=1))
    print(f"{a.name}: judged {len(items)} runs on {keys}")


# ---------------------------------------------------------------- report

def cmd_report(a) -> None:
    import report
    report.main(DATA, list(moments().values()), ARMS, a.judge, a.second_judge)


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="cmd", required=True)
    sub.add_parser("kits")
    p = sub.add_parser("run")
    p.add_argument("name")
    p.add_argument("arm", choices=list(ARMS))
    p.add_argument("-n", type=int, default=1)
    p.add_argument("--parallel", type=int, default=3)
    p.add_argument("--effort", help="default: the effort the session had at the cut")
    p.add_argument("--max-turns", type=int, default=40)
    sub.add_parser("collect")
    p = sub.add_parser("judge")
    p.add_argument("name")
    p.add_argument("--model", default="claude-opus-5-5")
    p.add_argument("--effort", default="high")
    p.add_argument("--seed", type=int, default=0)
    p = sub.add_parser("report")
    p.add_argument("--judge", default="claude-opus-5-5")
    p.add_argument("--second-judge", default="claude-opus-5")
    a = ap.parse_args()
    {"kits": cmd_kits, "run": cmd_run, "collect": cmd_collect, "judge": cmd_judge, "report": cmd_report}[a.cmd](a)


if __name__ == "__main__":
    main()
