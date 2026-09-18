#!/usr/bin/env bash
# spec-review step 6. Prints the review comment: the two reports and the orchestrator's judgment,
# verbatim under their headings, the round, then act-on items counted from the judgment's Act on
# items not filed as a ticket (`ticket: #N`) plus its Ask items, and clears the review state so
# the delegation hook stops blocking the reviewed files.
# No arguments: it reads .claude/state/review/dir. One argument, the review dir
# (.scratch/review/<id>): it reads that dir instead, so a judgment re-sorted after the human
# answers an Ask item, or a report sent back for its shape, reruns on the same reports once the
# state is gone, in the same round; the state is cleared only when it exists and names this dir,
# however the dir is spelled. Exits 1, clearing nothing, when a file is missing or off its shape:
# a count line above the Would-break items, a heading outside the shape, report or judgment items
# not numbered 1..N in document order, a round file that holds no number, or a judgment that does
# not name every report item exactly once.
set -euo pipefail
root="$(git rev-parse --show-toplevel)"
cd "$root"
state=.claude/state/review
fail() { echo "review-comment: $*" >&2; exit 1; }
if [ $# -gt 0 ]; then
  # Root-relative, so ./.scratch/review/x, .scratch/review/x/ and the absolute path name one dir.
  dir="$1"
  while [ "${dir%/}" != "$dir" ]; do dir="${dir%/}"; done
  case "$dir" in "$root"/*) dir="${dir#"$root"/}" ;; esac
  dir="${dir#./}"
  [ -d "$dir" ] || fail "$dir is not a directory; pass the .scratch/review/<id> review-brief.sh wrote"
else
  [ -f "$state/dir" ] || fail "no review in progress ($state/dir is missing); run scripts/review-brief.sh first, or pass the review dir to rerun a finished review"
  dir="$(cat "$state/dir")"
fi

# The shape is `## ` headings holding numbered items. Fenced text (the quoted hunks) is skipped:
# a fence opens on a line of three or more backticks or tildes and closes only on a line of the
# same character at least as long (CommonMark), so a hunk that quotes a fence stays inside its
# block. A heading's name is the text after `## ` less trailing whitespace. review-brief.sh
# carries this fragment word for word (tests/spec-review/review-brief.sh holds the copies together).
fenced='
  /^(```|~~~)/ { match($0, /^(`+|~+)/); m = substr($0, 1, RLENGTH)
    if (fence == "") { fence = m; next }
    if (substr(m, 1, 1) == substr(fence, 1, 1) && length(m) >= length(fence)) { fence = ""; next } }
  fence != "" { next }
  /^## / { h = substr($0, 4); sub(/[ \t\r]+$/, "", h) }
'
headings() { awk "$fenced"'/^## / { print h }' "$1"; }
# items <file> [heading]: the numbered items under one heading, or under every heading in document order.
items() { awk -v want="${2:-}" "$fenced"'/^## / { next } h != "" && /^[0-9]+\. / && (want == "" || h == want)' "$1"; }
count() { items "$@" | wc -l | tr -d ' '; }
# numbered <file>: the written item numbers run 1..N in document order across the headings, so a
# [S<n>] reference names the item its reviewer wrote as n.
numbered() {
  local f="$1" i=0 line
  while IFS= read -r line; do
    i=$((i + 1))
    [ "${line%%.*}" = "$i" ] || fail "$f item '$line' is numbered ${line%%.*} where $i was expected; number the items 1..N continuously across the headings, in document order"
  done < <(items "$f")
}
# shape <file> <heading>...: the file's headings are exactly these, in this order.
shape() {
  local f="$1" want got; shift
  want="$(printf '%s\n' "$@")"
  got="$(headings "$f")"
  [ "$got" = "$want" ] || fail "$f has the headings [$(printf '%s' "$got" | paste -sd '|' -)]; the shape is [$(printf '%s' "$want" | paste -sd '|' -)], in that order, each holding numbered items or nothing"
}
# report <file> <heading>...: the shape, the numbering, then the count line, which may not exceed the Would-break items.
report() {
  local f="$1" line n wb
  shape "$@"
  numbered "$f"
  line="$(grep -E '^hard findings: [0-9]+$' "$f" | tail -1)" || fail "$f has no 'hard findings: N' line; ask the reviewer for it"
  n="${line#hard findings: }"
  wb="$(count "$f" "Would break")"
  [ "$n" -le "$wb" ] || fail "$f says 'hard findings: $n' but has $wb items under '## Would break'; only those count. Ask the reviewer to put each finding under the heading it belongs to and recount"
}

[ -f "$dir/standards-report.md" ] || fail "$dir/standards-report.md is missing; wait for the Standards reviewer"
report "$dir/standards-report.md" "Would break" "Standards breaches" "Fix alongside"
s_total="$(count "$dir/standards-report.md")"
s_wb="$(count "$dir/standards-report.md" "Would break")"
has_spec="" p_total=0 p_wb=0
if [ -f "$dir/spec-brief.md" ]; then
  [ -f "$dir/spec-report.md" ] || fail "$dir/spec-report.md is missing; wait for the Spec reviewer"
  report "$dir/spec-report.md" "Would break" "Latent" "Not asked for"
  p_total="$(count "$dir/spec-report.md")"
  p_wb="$(count "$dir/spec-report.md" "Would break")"
  has_spec=yes
fi

[ -f "$dir/judgment.md" ] || fail "$dir/judgment.md is missing; sort every report item into Act on, Ask, Consider, Noted or Dismissed with a one-line reason (SKILL.md step 5), then rerun"
shape "$dir/judgment.md" "Act on" "Ask" "Consider" "Noted" "Dismissed"
numbered "$dir/judgment.md"
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
round=1
if [ -f "$dir/round" ]; then
  round="$(cat "$dir/round")"
  [ "$round" -gt 0 ] 2>/dev/null || fail "$dir/round holds '$round', not a round number; rerun scripts/review-brief.sh"
fi

echo "## Standards"
echo
cat "$dir/standards-report.md"
echo
echo "## Spec"
echo
if [ -n "$has_spec" ]; then cat "$dir/spec-report.md"; else echo "no spec: Standards axis only"; fi
echo
echo "## Judgment"
echo
cat "$dir/judgment.md"
echo
act="$(count "$dir/judgment.md" "Act on")"
# An Act on item filed as its own ticket (a trailing `ticket: #N`) is not counted.
ticketed="$(items "$dir/judgment.md" "Act on" | grep -cE 'ticket: #[0-9]+$' || true)"
ask="$(count "$dir/judgment.md" "Ask")"
if [ -n "$has_spec" ]; then spec="$p_wb would break of $p_total"; else spec="no spec"; fi
if [ -f "$dir/fixed-point" ]; then fixed="fixed point $(cat "$dir/fixed-point")"
elif [ -f "$state/fixed-point" ]; then fixed="fixed point $(cat "$state/fixed-point")"
else fixed="fixed point unknown"; fi
echo "Standards: $s_wb would break of $s_total; Spec: $spec; judged: act on $act ($ticketed with a ticket), ask $ask, consider $(count "$dir/judgment.md" Consider), noted $(count "$dir/judgment.md" Noted), dismissed $(count "$dir/judgment.md" Dismissed); $fixed."
echo "round: $round of 3"
echo "act-on items: $((act - ticketed + ask))"
if [ -f "$state/dir" ] && [ "$(cat "$state/dir")" = "$dir" ]; then rm -rf "$state"; fi
