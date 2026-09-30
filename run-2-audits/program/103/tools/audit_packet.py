"""Build a blinded audit packet: per labeled brief, the labels and every complete run's items under sanitized ids.

usage: audit_packet.py <out-dir> [descriptor-prefix ...]
Writes <out-dir>/packet.md (what the judge reads) and <out-dir>/key.json (sanitized id -> run), never shown to the judge.
"""
import hashlib
import json
import os
import sys
from pathlib import Path

os.chdir("/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.claude/worktrees/agent-a91d9f1cee64cb2f2")
sys.path.insert(0, "tests/eval/reviewer")
import reviewer as r  # noqa: E402

out_dir = Path(sys.argv[1])
prefixes = tuple(sys.argv[2:]) or ("",)
runs_root = Path("/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.scratch/eval/reviewer")
fx = r.load_fixtures(Path("tests/eval/reviewer"))
key = {}
parts = ["# Audit packet\n"]
def round_labels(rnd):
    rows = []
    for b, labels in fx.labels.items():
        if b.round != rnd:
            continue
        hist = fx.briefs[b].files / f"{b.axis}-report.historical.md"
        items = {i.n: i for i in r.parse_report(hist.read_text())} if hist.exists() else {}
        for label in labels:
            n = int(label.id[1:])
            rows.append((label.id, items[n].text if n in items else "(historical text unavailable)"))
    return sorted(rows)


for bid in sorted(fx.briefs, key=str):
    rows = round_labels(bid.round)
    if not rows:
        continue
    parts.append(f"\n## Brief {bid.round}/{bid.axis}\n\n### Labels of this round\n")
    for lid, text in rows:
        parts.append(f"- **{lid}**: {text}\n")
    parts.append("\n### Reports\n")
    for rj in sorted(runs_root.glob(f"runs/*/{bid.round}/{bid.axis}/*/receipt.json")):
        rec = r.receipt_at(rj.parent)
        if rec.status != "complete" or not rec.run.descriptor.startswith(prefixes):
            continue
        report = rj.parent / "report.md"
        parsed = r.parse_report(report.read_text() if report.exists() else None)
        if isinstance(parsed, str):
            continue
        sid = "R" + hashlib.sha256(str(rj.parent).encode()).hexdigest()[:8]
        key[sid] = {"descriptor": rec.run.descriptor, "brief": str(bid), "k": rec.run.k}
        parts.append(f"\n#### {sid}\n")
        for item in parsed:
            parts.append(f"- [{'hard' if item.hard else 'other'} {item.n}] {item.text}\n")
        if not parsed:
            parts.append("- (no findings)\n")
out_dir.mkdir(parents=True, exist_ok=True)
(out_dir / "packet.md").write_text("".join(parts))
(out_dir / "key.json").write_text(json.dumps(key, indent=1))
print(len(key), "reports;", sum(len(p) for p in parts), "chars")
