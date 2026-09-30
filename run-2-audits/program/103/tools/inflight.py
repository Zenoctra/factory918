"""List prepared Claude runs with no receipt and what their transcript's last assistant line says."""
import json
import os
import sys
from pathlib import Path

os.chdir("/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.claude/worktrees/agent-a91d9f1cee64cb2f2")
sys.path.insert(0, "tests/eval/reviewer")
import reviewer as r  # noqa: E402

out = Path("/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.scratch/eval/reviewer")
env = r.load_env()
prepared = {}
for rj in out.glob("runs/*/*/*/*/run.json"):
    d = rj.parent
    if (d / "receipt.json").exists():
        continue
    p = r.prepared_at(d)
    if isinstance(r.MODELS[p.run.descriptor], r.Native):
        prepared[p.run] = p
found = r.locate(prepared, env.transcripts, out)
for run, path in found.items():
    if not path:
        continue
    lines = r.read_jsonl(path)
    a = [x for x in lines if x.get("type") == "assistant"]
    last = a[-1] if a else {}
    print(run.descriptor, run.brief, run.k, path.name, len(lines), last.get("timestamp"), (last.get("message") or {}).get("stop_reason"))
