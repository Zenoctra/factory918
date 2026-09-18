#!/usr/bin/env bash
# spec-review step 5. Prints the review comment from the two report files, verbatim under their
# axis headings, with act-on items summed from the reports' own count lines, then clears the review
# state so the delegation hook stops blocking the reviewed files. No arguments: it reads
# .claude/state/review/dir. Exits 1 when a report is missing or has no count line.
set -euo pipefail
root="$(git rev-parse --show-toplevel)"
cd "$root"
state=.claude/state/review
[ -f "$state/dir" ] || { echo "review-comment: no review in progress ($state/dir is missing); run scripts/review-brief.sh first" >&2; exit 1; }
dir="$(cat "$state/dir")"
count() {
  local line
  line="$(grep -E '^hard findings: [0-9]+$' "$1" | tail -1)" || { echo "review-comment: $1 has no 'hard findings: N' line; ask the reviewer for it" >&2; return 1; }
  echo "${line#hard findings: }"
}
[ -f "$dir/standards-report.md" ] || { echo "review-comment: $dir/standards-report.md is missing; wait for the Standards reviewer" >&2; exit 1; }
standards="$(count "$dir/standards-report.md")"
spec=""
if [ -f "$dir/spec-brief.md" ]; then
  [ -f "$dir/spec-report.md" ] || { echo "review-comment: $dir/spec-report.md is missing; wait for the Spec reviewer" >&2; exit 1; }
  spec="$(count "$dir/spec-report.md")"
fi
echo "## Standards"
echo
cat "$dir/standards-report.md"
echo
echo "## Spec"
echo
if [ -n "$spec" ]; then cat "$dir/spec-report.md"; else echo "no spec: Standards axis only"; fi
echo
echo "Standards: $standards, Spec: ${spec:-no spec}; hard findings, fixed point $(cat "$state/fixed-point")."
echo "act-on items: $((standards + ${spec:-0}))"
rm -rf "$state"
