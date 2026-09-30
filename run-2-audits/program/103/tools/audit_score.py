"""Score the blinded audit: audited recall per model and axis, and agreement with the anchor scorer.

usage: audit_score.py <audit-dir-with-key.json> <verdicts.tsv>
"""
import collections
import json
import os
import sys
from pathlib import Path

os.chdir("/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.claude/worktrees/agent-a91d9f1cee64cb2f2")
sys.path.insert(0, "tests/eval/reviewer")
import reviewer as r  # noqa: E402

key = json.loads((Path(sys.argv[1]) / "key.json").read_text())
fx = r.load_fixtures(Path("tests/eval/reviewer"))
runs_root = Path("/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.scratch/eval/reviewer/runs")
verdict = {}
extra = collections.defaultdict(list)
for line in Path(sys.argv[2]).read_text().splitlines():
    if not line.strip():
        continue
    rid, lid, v = line.split("\t")
    if lid == "-":
        extra[rid].append(v.split()[-1])
    else:
        verdict[(rid, lid)] = v.split()[0]

hits = collections.Counter()
offered = collections.Counter()
per_k = collections.defaultdict(lambda: collections.Counter())
agree = collections.Counter()
extras = collections.Counter()
reports = collections.Counter()
for rid, info in key.items():
    d, b = info["descriptor"], info["brief"]
    rnd, axis = b.split("/")
    bid = next(x for x in fx.briefs if str(x) == b)
    labels = fx.labels.get(bid, ())
    slug = d.replace(":", "-")
    report = runs_root / slug / rnd / axis / str(info["k"]) / "report.md"
    parsed = r.parse_report(report.read_text())
    anchor_hits = r.score(r.RunId(d, bid, info["k"]), parsed, labels).hits
    reports[(d, axis)] += 1
    extras[(d, axis, "yes")] += extra[rid].count("yes")
    extras[(d, axis, "no")] += extra[rid].count("no")
    for label in labels:
        v = verdict.get((rid, label.id), "missing")
        hit = v == "hard"
        offered[(d, axis)] += 1
        hits[(d, axis)] += hit
        per_k[(d, axis)][(info["k"], "h")] += hit
        per_k[(d, axis)][(info["k"], "o")] += 1
        agree[(hit, label.id in anchor_hits)] += 1

print("model\taxis\taudited recall\tmin_k\tmax_k\treal extra/report\tfalse extra/report")
for (d, axis) in sorted(offered):
    ks = sorted({k for k, _ in per_k[(d, axis)]})
    rec = [per_k[(d, axis)][(k, "h")] / per_k[(d, axis)][(k, "o")] for k in ks if per_k[(d, axis)][(k, "o")]]
    n = reports[(d, axis)]
    print(f"{d}\t{axis}\t{hits[(d, axis)]}/{offered[(d, axis)]} ({hits[(d, axis)] / offered[(d, axis)]:.2f})\t"
          f"{min(rec):.2f}\t{max(rec):.2f}\t{extras[(d, axis, 'yes')] / n:.2f}\t{extras[(d, axis, 'no')] / n:.2f}")
print("agreement (audit hit, anchor hit):", dict(agree))
