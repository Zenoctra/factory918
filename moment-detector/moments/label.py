"""Label every moment as a correction or not with a strong model in a fresh pass.

    python3 moment-detector/moments/label.py --name opus55 [--model claude-opus-5-5] [--effort high]
        [--ids ID,ID | --sample N --seed S] [--parallel 8] [--dir DIR]

Reads DIR/moments.jsonl (from extract.py), writes one label per moment to
DIR/labels-NAME.jsonl. Each call is a judge session with no tools in an empty
box (qtlib.judge), so it sees only the prompt: definition.md plus the moment.
Moments already labelled under NAME are skipped, so a rerun finishes an
interrupted batch. `--show ID` prints the prompt a moment produces.
"""

from __future__ import annotations

import argparse
import json
import random
import shutil
import sys
import threading
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parents[1] / "quick-tests" / "lib"))
import qtlib  # noqa: E402

DEFAULT_DIR = qtlib.main_checkout() / ".scratch" / "moment-detector" / "moments"

KINDS_CORRECTION = ["misread_intent", "output", "action", "claim", "rule"]
KINDS_OTHER = ["new_request", "answer", "choice", "change_of_mind", "self_correction", "extension",
               "question", "approval", "information", "other_party", "other"]

HARD_CASES = ["proposal_pushback", "failure_report", "earlier_agent_work", "more_than_delivered", "cannot_follow",
              "authorized_then_objected", "suspicion_question", "none"]

SCHEMA = {
    "type": "object",
    "additionalProperties": False,
    "required": ["label", "kind", "surface", "near_miss", "target", "evidence", "reason", "confidence",
                 "hard_case", "agent_erred", "unclear", "other_reading"],
    "properties": {
        "label": {"enum": ["correction", "not_correction"]},
        "kind": {"enum": KINDS_CORRECTION + KINDS_OTHER},
        "surface": {"enum": ["overt", "quiet", "none"]},
        "near_miss": {"type": "boolean"},
        "target": {"type": "string"},
        "evidence": {"type": "string"},
        "reason": {"type": "string"},
        "confidence": {"enum": ["high", "medium", "low"]},
        "hard_case": {"enum": HARD_CASES},
        "agent_erred": {"enum": ["yes", "no", "unknown", "n/a"]},
        "unclear": {"type": "boolean"},
        "other_reading": {"type": "string"},
    },
}

DELIVERY = {
    "prompt": "typed as his next prompt",
    "queued": "typed while the agent was still working; it arrived mid-turn",
    "ask_answer": "his answer to a multiple-choice question the agent asked (the questions are quoted with his answers)",
    "command": "the arguments of a slash command he ran",
}


def render(m: dict) -> str:
    c, a = m["context"], m["after"]
    parts = [(HERE / "definition.md").read_text(), "\n---\n\n# The moment\n"]
    if c["starts_session"]:
        parts.append("This message opens the session; the agent had done nothing yet.\n")
    else:
        parts.append("## Before\n")
        parts.append("**Manuel's previous message:**\n\n" + (c["previous_message"] or "(none in this session)") + "\n")
        if c["since_previous"]:
            parts.append("**What the agent did since, in order:**\n\n" + "\n".join("- " + s for s in c["since_previous"]) + "\n")
        parts.append("**The agent's last words to Manuel before this message:**\n\n" + (c["last_reply"] or "(none)") + "\n")
        if c["interrupted"]:
            parts.append("**Manuel interrupted or stopped the agent just before writing this message.**\n")
    head = f"## The message to label ({DELIVERY[m['delivery']]}"
    head += f": `{m['command']}`)" if m.get("command") else ")"
    parts.append(head + "\n\n" + m["text"] + ("\n\n(He also attached an image.)" if m.get("images") else "") + "\n")
    for i, p in enumerate(m["pasted"], 1):
        parts.append(f"**Pasted content {i} (material he pasted, not his words):**\n\n{p}\n")
    parts.append("## After (evidence only; do not trust the agent's acceptance)\n")
    parts.append("**The agent's next reply:**\n\n" + (a["agent_reply"] or "(none)") + "\n")
    parts.append("**Manuel's next message:**\n\n" + (a["next_message"] or "(none)") + "\n")
    parts.append("\nLabel the message under \"The message to label\" by the definition above, in the requested structure.")
    return "\n".join(parts)


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    ap.add_argument("--name", required=True, help="labeller name; output is labels-NAME.jsonl")
    ap.add_argument("--model", default="claude-opus-5-5")
    ap.add_argument("--effort", default="high")
    ap.add_argument("--ids", default="")
    ap.add_argument("--sample", type=int, default=0)
    ap.add_argument("--seed", type=int, default=1)
    ap.add_argument("--parallel", type=int, default=8)
    ap.add_argument("--dir", type=Path, default=DEFAULT_DIR)
    ap.add_argument("--show", default="")
    args = ap.parse_args()

    moments = [json.loads(line) for line in open(args.dir / "moments.jsonl")]
    if args.show:
        print(render(next(m for m in moments if m["id"] == args.show)))
        return
    if args.ids:
        wanted = set(args.ids.split(","))
        moments = [m for m in moments if m["id"] in wanted]
    elif args.sample:
        moments = random.Random(args.seed).sample(moments, args.sample)

    out = args.dir / f"labels-{args.name}.jsonl"
    done = {json.loads(line)["id"] for line in open(out)} if out.exists() else set()
    todo = [m for m in moments if m["id"] not in done]
    print(f"{len(todo)} to label ({len(done)} already in {out.name})", flush=True)
    lock = threading.Lock()
    before = qtlib.safety_preamble()
    progress = {"n": 0, "failed": 0}

    def job(m: dict):
        def run():
            run_dir = args.dir / "runs" / args.name / m["id"]
            try:
                label = qtlib.judge(render(m), SCHEMA, run_dir, model=args.model, effort=args.effort)
            except Exception as e:  # one failed call must not stop the batch; a rerun retries it
                with lock:
                    progress["failed"] += 1
                    print(f"FAILED {m['id']}: {e}", flush=True)
                return
            row = {"id": m["id"], "labeller": args.name, "model": args.model, "effort": args.effort, **label}
            with lock:
                with open(out, "a") as fh:
                    fh.write(json.dumps(row, ensure_ascii=False) + "\n")
                progress["n"] += 1
                if progress["n"] % 25 == 0:
                    print(f"{progress['n']}/{len(todo)}", flush=True)
        return run

    qtlib.run_many([job(m) for m in todo], parallel=args.parallel)
    snap, status = before
    problems = qtlib.guard_check(snap) + qtlib.check_main_untouched(status)
    for p in qtlib.box_projects_dirs():
        shutil.rmtree(p, ignore_errors=True)
    qtlib.write_json(args.dir / "runs" / args.name / f"safety-{qtlib.now_stamp()}.json", {"problems": problems})
    print(f"labelled {progress['n']}, failed {progress['failed']}; safety problems: {problems or 'none'}")
    sys.exit(1 if problems or progress["failed"] else 0)


if __name__ == "__main__":
    main()
