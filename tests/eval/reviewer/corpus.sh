#!/usr/bin/env bash
# Runs reviewer.py's content check over the runs labelled in contamination-cases and fails on any verdict,
# or pinned first contaminated call, that differs from its label. The #103 output lives only on the machine
# that ran it, under <main checkout>/.scratch/eval/reviewer (REVIEWER_CORPUS overrides); without it the test
# prints one `skip:` line and exits 0, which is CI's case. A #103 run's head, brief, diff and frozen inputs
# are read from e710e99's rounds; a #138 run's from this tree's. The line sets and the live GitHub text are
# cached in REVIEWER_CACHE, by default <main checkout>/.scratch/eval/reviewer-corpus-cache; the first run
# fetches that text with gh.
set -euo pipefail
here="$(cd "$(dirname "$0")/../../.." && pwd -P)"
main="$(dirname "$(git -C "$here" rev-parse --path-format=absolute --git-common-dir)")"
corpus="${REVIEWER_CORPUS:-$main/.scratch/eval/reviewer}"
if [ ! -d "$corpus/runs" ]; then
  echo "skip: no #103 corpus at $corpus"
  exit 0
fi
cache="${REVIEWER_CACHE:-$main/.scratch/eval/reviewer-corpus-cache}"
python3 - "$here/tests/eval/reviewer/reviewer.py" "$here/tests/eval/reviewer/contamination-cases" "$corpus" "$here" "$cache" <<'EOF'
import importlib.util, json, re, subprocess, sys
from pathlib import Path

script, cases, corpus, repo, cache = sys.argv[1:]
spec = importlib.util.spec_from_file_location("reviewer", script)
r = importlib.util.module_from_spec(spec)
sys.modules["reviewer"] = r
spec.loader.exec_module(r)
repo, cache = Path(repo), Path(cache)
rounds = repo / "tests/eval/reviewer/rounds"


def at_e710e99(path):
    proc = subprocess.run(["git", "-C", str(repo), "show", f"e710e99:tests/eval/reviewer/{path}"], capture_output=True, text=True)
    return proc.stdout if proc.returncode == 0 else ""


def keys(text):
    return dict(line.split("=", 1) for line in text.splitlines() if "=" in line)


def briefing(case):
    """(transcript, head, ticket, pr, given texts, frozen texts) for a #103 or a #138 case."""
    if case.startswith("138 "):
        _, brief, transcript = case.split(" ", 2)
        rnd, axis = brief.split("/")
        read = lambda path: (rounds / rnd / path).read_text() if (rounds / rnd / path).is_file() else ""
        transcript = Path.home() / ".claude/projects" / transcript
    else:
        receipt = json.loads((Path(corpus) / case).read_text())
        rnd, axis = receipt["run"]["round"], receipt["run"]["axis"]
        read = lambda path: at_e710e99(f"rounds/{rnd}/{path}")
        transcript = Path(receipt["source"])
    k = {**keys(read("inputs/recipe")), **keys(read("round"))}
    given = [read(f"review/{axis}-brief.md"), read("review/diff")]
    frozen = [read(f"inputs/{n}") for n in ("ticket.md", "previous.txt", "blast-radius.md")]
    return transcript, k["head"], k.get("ticket"), k.get("pr"), given, frozen


rows, bad = [], 0
for raw in Path(cases).read_text().splitlines():
    if not raw.strip() or raw.startswith("#"):
        continue
    case, label, call, _evidence = raw.split("\t")
    transcript, head, ticket, pr, given_texts, frozen = briefing(case)
    future = {**r.live_lines(ticket, pr, frozen, cache), **r.future_lines(repo, head, cache)}
    given = set(r.tree_lines(repo, head, cache)) | r.text_lines(given_texts)
    lines = r.read_jsonl(transcript)
    export = Path(next(m.group(1) for line in lines if line.get("type") == "user"
                       for m in [re.search(r"You are working in `([^`]+)`", json.dumps(line))] if m))
    verdict = r.contamination(lines, future, given, export)
    found = r.leaks(lines, future, given)
    got = "future" if verdict.detail else "clean"
    first_call = str(verdict.first["call"]) if verdict.first else "-"
    ok = got == label and call in ("-", first_call)
    bad += not ok
    first = f"call {first_call}: {found[0].line[:50]} [{found[0].commit[:12]} {found[0].tool.split()[0]}]" if found else "-"
    name = case.removeprefix("runs/").removesuffix("/receipt.json")
    rows.append((ok, name if not case.startswith("138 ") else " ".join(case.split(" ")[:2]) + " " + transcript.stem, label, got, first))
width = max(len(row[1]) for row in rows)
for ok, name, label, got, first in rows:
    print(f"{'ok  ' if ok else 'FAIL'} {name:<{width}}  {label:<6}  {got:<6}  {first}")
print(f"{sum(ok for ok, *_ in rows)} of {len(rows)} cases match their label")
sys.exit(1 if bad else 0)
EOF
