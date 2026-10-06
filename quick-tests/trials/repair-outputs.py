"""One-off repair, run once on 2026-10-05 for the first trials.

Their runs were recorded by the first collect_outputs, which kept and showed
every file a run left in its box (temp trees included), so output.md reached
5 MB and the judge prompts failed. This rewrites each run's written/,
changed-files.json and output.md under the current rules (lib/qtlib.py:
collect_outputs). Commits made in the box repo are not recoverable here; none
of these runs made one.

    python3 quick-tests/trials/repair-outputs.py RUNS_DIR
"""
import json, sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "lib"))
import qtlib as q

runs = Path(sys.argv[1])
seed_file = runs.parent / "seed-hashes.json"
seed_hashes = json.loads(seed_file.read_text()) if seed_file.exists() else {}
seed_values = set(seed_hashes.values())
for r in sorted(runs.iterdir()):
    f = r / "changed-files.json"
    if not f.exists():
        continue
    info = json.loads(f.read_text())
    if "changed" not in info:
        info["changed"] = info["kept"] + info["not_kept"]
        info["not_kept"] = []
    kept, skipped = [], []
    for rel in info["changed"]:
        p = r / "written" / rel
        if not p.exists():
            skipped.append(rel)
            continue
        copy = rel not in seed_hashes and q.hashlib.sha256(p.read_bytes()).hexdigest() in seed_values
        if q._scratch_noise(rel) or p.stat().st_size > q.KEEP_MAX or copy:
            skipped.append(rel)
            p.unlink()
        else:
            kept.append(rel)
    for d in sorted((r / "written").rglob("*"), reverse=True):
        if d.is_dir() and not any(d.iterdir()):
            d.rmdir()
    q.write_json(f, {"kept": kept, "not_kept": skipped, "removed": info["removed"]})
    print(r.name, "kept", len(kept), "not kept", len(skipped), "output.md", len(q.render_output(r, (r / "final.md").read_text())))
