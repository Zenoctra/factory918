#!/usr/bin/env python3
"""Copy what a reader needs to check the trial's counts out of the run folders.

    collect.py <runs-root> <results-dir> <arm>... -- <judge-folder>...

Per arm: config, drift, seal check, the original moment, the sent message, and
per run the text, tool calls and outcome. Not copied: the clone, the transcript
copy, the full API logs (they hold the whole session). In their place,
request-facts.json records what the first run's first request carried.
"""
import json
import re
import shutil
import sys
from pathlib import Path

root, results = Path(sys.argv[1]), Path(sys.argv[2])
split = sys.argv.index("--")
arms, judges = sys.argv[3:split], sys.argv[split + 1:]
CHANGE = "Before you tell Manuel that two rules"


def facts(req):
    body = json.load(open(req))
    b = body["body"]
    msgs = b["messages"]
    text = json.dumps(msgs)
    thinking = [x for m in msgs if isinstance(m["content"], list) for x in m["content"]
                if x.get("type") in ("thinking", "redacted_thinking")]
    last = msgs[-1]
    tail = last["content"] if isinstance(last["content"], str) else "\n".join(
        x.get("text", "") for x in last["content"] if x.get("type") == "text")
    return {
        "messages": len(msgs),
        "thinking_blocks": len(thinking),
        "thinking_blocks_with_text": sum(1 for x in thinking if x.get("thinking")),
        "thinking_blocks_with_signature": sum(1 for x in thinking if x.get("signature")),
        "thinking_config": b.get("thinking"),
        "context_management": b.get("context_management"),
        "model": b.get("model"),
        "blocks_removed_by_proxy": body.get("sandbox_note_blocks_removed"),
        "instruction_reread_reminder": "Instruction files were re-read" in text,
        "session_mandate_copies": text.count("<FACTORY918>"),
        "budget_line": "USD budget" in text,
        "lost_background_agent_notification": "before the previous session ended" in text,
        "change_text_in_message_index": [i for i, m in enumerate(msgs) if CHANGE in json.dumps(m)],
        "last_message_role": last["role"],
        "last_message_headings": re.findall(r"(?m)^#+ .*$", tail),
    }


for arm in arms:
    src, dst = root / arm, results / arm
    dst.mkdir(parents=True, exist_ok=True)
    for name in ("config.json", "drift.txt", "seal-check.txt", "original.md", "sent.txt"):
        if (src / name).exists():
            shutil.copyfile(src / name, dst / name)
    for run in sorted(src.glob("runs/[0-9]*")):
        out = dst / "runs" / run.name
        out.mkdir(parents=True, exist_ok=True)
        for name in ("all-text.md", "tools.txt", "meta.json", "repo-changes.txt"):
            if (run / name).exists():
                shutil.copyfile(run / name, out / name)
    first = sorted(src.glob("runs/*/api/0001-req.json"))
    if first:
        (dst / "request-facts.json").write_text(json.dumps(facts(first[0]), indent=1) + "\n")

for j in judges:
    src = Path(j)
    dst = results / "judge" / src.name
    dst.mkdir(parents=True, exist_ok=True)
    for name in ("tally.txt", "verdicts.json", "key.json"):
        shutil.copyfile(src / name, dst / name)
    # Make the paths in the verdicts relative to the results folder.
    for name in ("verdicts.json", "key.json"):
        p = dst / name
        p.write_text(p.read_text().replace(str(root) + "/", ""))
