#!/usr/bin/env bash
# spec-review step 6. Prints the review comment: the two reports and the orchestrator's judgment,
# verbatim under their headings, then act-on items counted from the judgment's Act on and Ask
# lists, and clears the review state so the delegation hook stops blocking the reviewed files.
# No arguments: it reads .claude/state/review/dir. Exits 1, clearing nothing, when a file is
# missing or off its shape: a count line above the Would-break items, a heading outside the
# shape, or a judgment that does not name every report item exactly once.
set -euo pipefail
root="$(git rev-parse --show-toplevel)"
cd "$root"
state=.claude/state/review
[ -f "$state/dir" ] || { echo "review-comment: no review in progress ($state/dir is missing); run scripts/review-brief.sh first" >&2; exit 1; }
dir="$(cat "$state/dir")"
fail() { echo "review-comment: $*" >&2; exit 1; }

# The shape is `## ` headings holding numbered items; fenced code (the quoted hunks) is skipped.
headings() { awk '/^```/ { fence = !fence; next } fence { next } /^## / { print substr($0, 4) }' "$1"; }
# items <file> [heading]: the numbered items under one heading, or under every heading in document order.
items() {
  awk -v want="${2:-}" '
    /^```/ { fence = !fence; next }
    fence { next }
    /^## / { h = substr($0, 4); next }
    h != "" && /^[0-9]+\. / && (want == "" || h == want)
  ' "$1"
}
count() { items "$@" | wc -l | tr -d ' '; }
# shape <file> <heading>...: the file's headings are exactly these, in this order.
shape() {
  local f="$1" want got; shift
  want="$(printf '%s\n' "$@")"
  got="$(headings "$f")"
  [ "$got" = "$want" ] || fail "$f has the headings [$(printf '%s' "$got" | paste -sd '|' -)]; the shape is [$(printf '%s' "$want" | paste -sd '|' -)], in that order, each holding numbered items or nothing"
}
# report <file> <heading>...: the shape, then the count line, which may not exceed the Would-break items.
report() {
  local f="$1" line n wb
  shape "$@"
  line="$(grep -E '^hard findings: [0-9]+$' "$f" | tail -1)" || fail "$f has no 'hard findings: N' line; ask the reviewer for it"
  n="${line#hard findings: }"
  wb="$(count "$f" "Would break")"
  [ "$n" -le "$wb" ] || fail "$f says 'hard findings: $n' but has $wb items under '## Would break'; only those count. Ask the reviewer to put each finding under the heading it belongs to and recount"
}

[ -f "$dir/standards-report.md" ] || fail "$dir/standards-report.md is missing; wait for the Standards reviewer"
report "$dir/standards-report.md" "Would break" "Standards breaches" "Fix alongside"
s_total="$(count "$dir/standards-report.md")"
s_wb="$(count "$dir/standards-report.md" "Would break")"
spec="" p_total=0 p_wb=0
if [ -f "$dir/spec-brief.md" ]; then
  [ -f "$dir/spec-report.md" ] || fail "$dir/spec-report.md is missing; wait for the Spec reviewer"
  report "$dir/spec-report.md" "Would break" "Latent" "Not asked for"
  p_total="$(count "$dir/spec-report.md")"
  p_wb="$(count "$dir/spec-report.md" "Would break")"
  spec="$p_wb would break of $p_total"
fi

[ -f "$dir/judgment.md" ] || fail "$dir/judgment.md is missing; sort every report item into Act on, Ask, Consider, Noted or Dismissed with a one-line reason (SKILL.md step 5), then rerun"
shape "$dir/judgment.md" "Act on" "Ask" "Consider" "Noted" "Dismissed"
j_total="$(count "$dir/judgment.md")"
[ "$j_total" -eq $((s_total + p_total)) ] || fail "$dir/judgment.md has $j_total items; the reports have $((s_total + p_total)) (Standards $s_total, Spec $p_total). Every report item appears exactly once in the judgment"
# Each judgment item opens with [S<n>] or [P<n>]; the set of references is exactly the set of report items.
refs=""
while IFS= read -r line; do
  ref="$(printf '%s' "$line" | sed -nE 's/^[0-9]+\. \[([SP][0-9]+)\].*/\1/p')"
  [ -n "$ref" ] || fail "$dir/judgment.md item '$line' does not open with [S<n>] or [P<n>], the report item it judges"
  refs="$refs$ref"$'\n'
done < <(items "$dir/judgment.md")
want="$(awk -v s="$s_total" -v p="$p_total" 'BEGIN { for (i = 1; i <= s; i++) print "S" i; for (i = 1; i <= p; i++) print "P" i }' | sort)"
got="$(printf '%s' "$refs" | sort)"
if [ "$got" != "$want" ]; then
  missing="$(comm -23 <(printf '%s\n' "$want") <(printf '%s\n' "$got") | sed '/^$/d' | paste -sd ' ' -)"
  extra="$(comm -13 <(printf '%s\n' "$want") <(printf '%s\n' "$got") | sed '/^$/d' | paste -sd ' ' -)"
  fail "$dir/judgment.md does not name every report item exactly once: missing [${missing:-none}], unknown or repeated [${extra:-none}]; the reports have $s_total Standards items and $p_total Spec items"
fi

echo "## Standards"
echo
cat "$dir/standards-report.md"
echo
echo "## Spec"
echo
if [ -n "$spec" ]; then cat "$dir/spec-report.md"; else echo "no spec: Standards axis only"; fi
echo
echo "## Judgment"
echo
cat "$dir/judgment.md"
echo
act="$(count "$dir/judgment.md" "Act on")"
ask="$(count "$dir/judgment.md" "Ask")"
echo "Standards: $s_wb would break of $s_total; Spec: ${spec:-no spec}; judged: act on $act, ask $ask, consider $(count "$dir/judgment.md" Consider), noted $(count "$dir/judgment.md" Noted), dismissed $(count "$dir/judgment.md" Dismissed); fixed point $(cat "$state/fixed-point")."
echo "act-on items: $((act + ask))"
rm -rf "$state"
