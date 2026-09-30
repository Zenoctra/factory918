"""One-off: rebuild every stored receipt with the current reviewer.py rules (fix lane 2)."""
import collections
import json
import os
import sys
from pathlib import Path

os.chdir("/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.claude/worktrees/agent-a91d9f1cee64cb2f2")
os.environ["REVIEWER_OUT"] = "/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.scratch/eval/reviewer"
sys.path.insert(0, "tests/eval/reviewer")
import reviewer as r  # noqa: E402

env = r.load_env()
out = Path(os.environ["REVIEWER_OUT"])
changes = collections.Counter()
for rj in sorted(out.glob("runs/*/*/*/*/receipt.json")):
    d = rj.parent
    old = r.receipt_at(d)
    route = r.MODELS[old.run.descriptor]
    if isinstance(route, r.Native):
        p = r.prepared_at(d)
        lines = r.read_jsonl(old.source)
        new = r.receipt_from_transcript(old.run, lines, route.expect, p.checkout, env.transcripts, old.source)
    elif isinstance(route, r.External) and (d / "runner-receipt.json").is_file():
        new = r.receipt_from_runner(old.run, json.loads((d / "runner-receipt.json").read_text()), d / "runner-receipt.json")
    else:
        continue
    if r.receipt_json(new) != r.receipt_json(old):
        changes[(old.run.descriptor, old.status, old.detail.split(":")[0][:20], "->", new.status, new.detail.split(":")[0][:20])] += 1
        r.write_json(rj, r.receipt_json(new))
for k, v in changes.items():
    print(v, *k)
