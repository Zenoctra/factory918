#!/usr/bin/env bash
# Runs reviewer.py's content check over the #103 runs labelled in contamination-cases and fails on any
# verdict that differs from its label. The #103 output lives only on the machine that ran it, under
# <main checkout>/.scratch/eval/reviewer (REVIEWER_CORPUS overrides); without it the test prints one
# `skip:` line and exits 0, which is CI's case. Each run's head and given brief and diff are read from
# e710e99's rounds. REVIEWER_CACHE keeps the line sets between runs (a temporary directory otherwise).
set -euo pipefail
here="$(cd "$(dirname "$0")/../../.." && pwd -P)"
main="$(dirname "$(git -C "$here" rev-parse --path-format=absolute --git-common-dir)")"
corpus="${REVIEWER_CORPUS:-$main/.scratch/eval/reviewer}"
if [ ! -d "$corpus/runs" ]; then
  echo "skip: no #103 corpus at $corpus"
  exit 0
fi
cache="${REVIEWER_CACHE:-}"
if [ -z "$cache" ]; then
  cache="$(mktemp -d)"
  trap 'rm -rf "$cache"' EXIT
fi
python3 - "$here/tests/eval/reviewer/reviewer.py" "$here/tests/eval/reviewer/contamination-cases" "$corpus" "$here" "$cache" <<'EOF'
import importlib.util, json, subprocess, sys
from pathlib import Path

script, cases, corpus, repo, cache = sys.argv[1:]
spec = importlib.util.spec_from_file_location("reviewer", script)
r = importlib.util.module_from_spec(spec)
sys.modules["reviewer"] = r
spec.loader.exec_module(r)
repo, cache = Path(repo), Path(cache)


def at_e710e99(path):
    return subprocess.run(["git", "-C", str(repo), "show", f"e710e99:tests/eval/reviewer/{path}"],
                          capture_output=True, text=True, check=True).stdout


rows, bad = [], 0
for raw in Path(cases).read_text().splitlines():
    if not raw.strip() or raw.startswith("#"):
        continue
    case, label, _evidence = raw.split("\t")
    receipt = json.loads((Path(corpus) / case).read_text())
    rnd, axis = receipt["run"]["round"], receipt["run"]["axis"]
    head = next(l.split("=", 1)[1] for l in at_e710e99(f"rounds/{rnd}/round").splitlines() if l.startswith("head="))
    given = set(r.tree_lines(repo, head, cache))
    given |= r.text_lines(at_e710e99(f"rounds/{rnd}/review/{name}") for name in (f"{axis}-brief.md", "diff"))
    found = r.leaks(r.read_jsonl(Path(receipt["source"])), r.future_lines(repo, head, cache), given)
    verdict = "future" if found else "clean"
    bad += verdict != label
    first = f"{found[0].line[:60]} [{found[0].commit[:7]} {found[0].tool}]" if found else "-"
    rows.append((case.removeprefix("runs/").removesuffix("/receipt.json"), label, verdict, first))
width = max(len(c) for c, *_ in rows)
for case, label, verdict, first in rows:
    print(f"{'ok  ' if label == verdict else 'FAIL'} {case:<{width}}  {label:<6}  {verdict:<6}  {first}")
print(f"{len(rows) - bad} of {len(rows)} cases match their label")
sys.exit(1 if bad else 0)
EOF
