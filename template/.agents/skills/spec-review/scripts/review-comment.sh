#!/usr/bin/env bash
# spec-review step 6. Prints the review comment: the two reports and the orchestrator's judgment,
# verbatim under their headings, the line `restart` when an Act on item is marked a design hole
# (`hole: <reference>`), the round, then act-on items counted from the judgment's Act on items
# neither fixed on this PR (`fixed: <sha>`), filed as a ticket (`ticket: #N`) nor marked a hole,
# plus its Ask items, and clears the review state so the delegation hook stops blocking the
# reviewed files. No arguments: it reads .claude/state/review/dir. One argument, the review dir
# (.scratch/review/<id>): it reads that dir instead, so a judgment re-sorted after the human
# answers an Ask item, or a report sent back for its shape, reruns on the same reports once the
# state is gone, in the same round; the state is cleared only when it exists and names this dir,
# however the dir is spelled. Exits 1, clearing nothing, when a file is missing or off its shape:
# a count line above the Would-break and Fails-open items, a Would-break or Fails-open item with no
# `Documented step:` line or, in a review with a spec (<dir>/spec-brief.md present), no `spec:`
# line naming the cell, signature or criterion it rests on, a heading outside the shape, report or
# judgment items not numbered 1..N in document order, a judgment that does not name every report
# item exactly once, a `hole:` field in a review with no spec (nothing exists for a hole to amend),
# outside Act on, in no form, or not word for word the `spec:` of the item it judges, or a round
# file that holds no number. The Spec report's `## Walk` lines are steps, not items: they are not
# counted, not numbered with the findings and not judged.
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

# The shape is `## ` headings holding numbered items. Fenced text (the quoted hunks) is skipped.
# A fence opens on a line starting with three or more backticks or tildes, whatever follows them;
# it closes only on a line of the same character, at least as long as the opening run, followed
# by nothing but spaces or tabs (no info string). So ```sh inside a ``` block does not close it,
# nor does ``` inside a ```` block or a ~~~ block, and the quoted hunk stays fenced. A heading's
# name is the text after `## ` less trailing whitespace. review-brief.sh carries this fragment
# word for word (tests/spec-review/review-brief.sh holds the copies together).
# shellcheck disable=SC2016 # the fenced block is Markdown emitted verbatim; the backticks are literal
fenced='
  /^(```|~~~)/ { match($0, /^(`+|~+)/); m = substr($0, 1, RLENGTH); rest = substr($0, RLENGTH + 1)
    if (fence == "") { fence = m; next }
    if (substr(m, 1, 1) == substr(fence, 1, 1) && length(m) >= length(fence) && rest ~ /^[ \t\r]*$/) { fence = ""; next } }
  fence != "" { next }
  /^## / { h = substr($0, 4); sub(/[ \t\r]+$/, "", h) }
'
# The reference a counted report item's `spec:` line and a judgment item's `hole:` field carry, one
# grammar: `table <row>/<column>` a cell of the ticket's scenario table by its own labels, no
# spaces or slashes; `design <signature>` the rest of the line, a signature or usage as the
# `## Design` sketch writes it; `criterion <k>` the k-th acceptance checkbox, from 1. review-brief.sh
# holds the same line for its `cites:` forms (the same test holds the copies together).
ref='(table [^[:space:]/]+/[^[:space:]/]+|design [^[:space:]].*|criterion [1-9][0-9]*)'
headings() { awk "$fenced"'/^## / { print h }' "$1"; }
# items <file> [heading]: the numbered items under one heading, or under every heading but Walk in document order.
items() { awk -v want="${2:-}" "$fenced"'/^## / { next } h != "" && h != "Walk" && /^[0-9]+\. / && (want == "" || h == want)' "$1"; }
count() { items "$@" | wc -l | tr -d ' '; }
# title <item line>: its opening, `1. **Title.**` or `1. [S2] **Title.**`, for a refusal.
title() { printf '%s' "$1" | sed -E 's/^([0-9]+\. (\[[SP][0-9]+\] )?\*\*[^*]+\*\*).*/\1/'; }
# stepless <file> <regex>: the heading and opening line of the first Would-break or Fails-open item
# with no line matching the regex before the next item or heading; fenced text does not count.
stepless() {
  awk -v want="$2" "$fenced"'
    function flush() { if (item != "" && !ok) { print at ": " item; item = ""; exit } item = ""; ok = 0 }
    /^## / { flush(); next }
    /^[0-9]+\. / { flush(); if (h == "Would break" || h == "Fails open") { at = h; item = $0 } next }
    $0 ~ want { ok = 1 }
    END { flush() }
  ' "$1"
}
# specs <file>: one line per item in document order, `<heading>\t<reference>`, the reference the
# item's `spec:` value when it is counted and carries one, else empty; fenced text does not count.
specs() {
  awk -v want="^spec: $ref\$" "$fenced"'
    function flush() { if (item) print at "\t" v; item = 0; v = "" }
    /^## / { flush(); next }
    /^[0-9]+\. / { flush(); if (h != "" && h != "Walk") { item = 1; at = h } next }
    item && (at == "Would break" || at == "Fails open") && v == "" && $0 ~ want { v = substr($0, 7) }
    END { flush() }
  ' "$1"
}
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
# report <file> <heading>...: the shape, the numbering, the count line, which may not exceed the
# Would-break and Fails-open items, then the step line every one of those items carries and, in a
# review with a spec, its spec line; a review with no spec has no artifact for a `spec:` to name.
report() {
  local f="$1" line n wb fo
  shape "$@"
  numbered "$f"
  line="$(grep -E '^hard findings: [0-9]+$' "$f" | tail -1)" || fail "$f has no 'hard findings: N' line; ask the reviewer for it"
  n="${line#hard findings: }"
  wb="$(count "$f" "Would break")"
  fo="$(count "$f" "Fails open")"
  [ "$n" -le $((wb + fo)) ] || fail "$f says 'hard findings: $n' but has $wb items under '## Would break' and $fo under '## Fails open'; only those count. Ask the reviewer to put each finding under the heading it belongs to and recount"
  line="$(stepless "$f" '^Documented step:')"
  [ -z "$line" ] || fail "$f item '$(title "${line#*: }")' under '## ${line%%: *}' has no 'Documented step:' line; a counted item quotes the ticket line or the file:line of the documentation the user follows, then 'Result:' what happens instead. Ask the reviewer for both"
  [ -n "$has_spec" ] || return 0
  line="$(stepless "$f" "^spec: $ref\$")"
  [ -z "$line" ] || fail "$f item '$(title "${line#*: }")' under '## ${line%%: *}' has no 'spec:' line; a counted item names what it rests on, one of 'spec: table <row>/<column>', 'spec: design <signature>' or 'spec: criterion <k>', on its own line. Ask the reviewer for it"
}

# The review has a spec exactly when review-brief.sh wrote the Spec brief (a ticket named and fetched).
has_spec=""
[ ! -f "$dir/spec-brief.md" ] || has_spec=yes
[ -f "$dir/standards-report.md" ] || fail "$dir/standards-report.md is missing; wait for the Standards reviewer"
report "$dir/standards-report.md" "Would break" "Fails open" "Standards breaches" "Fix alongside"
s_total="$(count "$dir/standards-report.md")"
s_wb="$(count "$dir/standards-report.md" "Would break")"
s_fo="$(count "$dir/standards-report.md" "Fails open")"
p_total=0 p_wb=0 p_fo=0
if [ -n "$has_spec" ]; then
  [ -f "$dir/spec-report.md" ] || fail "$dir/spec-report.md is missing; wait for the Spec reviewer"
  report "$dir/spec-report.md" "Walk" "Would break" "Fails open" "Not asked for"
  p_total="$(count "$dir/spec-report.md")"
  p_wb="$(count "$dir/spec-report.md" "Would break")"
  p_fo="$(count "$dir/spec-report.md" "Fails open")"
fi

[ -f "$dir/judgment.md" ] || fail "$dir/judgment.md is missing; sort every report item into Act on, Ask, Consider, Noted or Dismissed with a one-line reason (SKILL.md step 5), then rerun"
shape "$dir/judgment.md" "Act on" "Ask" "Consider" "Noted" "Dismissed"
numbered "$dir/judgment.md"
j_total="$(count "$dir/judgment.md")"
[ "$j_total" -eq $((s_total + p_total)) ] || fail "$dir/judgment.md has $j_total items; the reports have $((s_total + p_total)) (Standards $s_total, Spec $p_total). Every report item appears exactly once in the judgment"
# Each judgment item opens with [S<n>] or [P<n>]; the set of references is exactly the set of report items.
refs=""
while IFS= read -r line; do
  ref_id="$(printf '%s' "$line" | sed -nE 's/^[0-9]+\. \[([SP][0-9]+)\].*/\1/p')"
  [ -n "$ref_id" ] || fail "$dir/judgment.md item '$line' does not open with [S<n>] or [P<n>], the report item it judges"
  refs="$refs$ref_id"$'\n'
done < <(items "$dir/judgment.md")
want="$(awk -v s="$s_total" -v p="$p_total" 'BEGIN { for (i = 1; i <= s; i++) print "S" i; for (i = 1; i <= p; i++) print "P" i }' | sort)"
got="$(printf '%s' "$refs" | sort)"
if [ "$got" != "$want" ]; then
  missing="$(comm -23 <(printf '%s\n' "$want") <(printf '%s\n' "$got") | sed '/^$/d' | paste -sd ' ' -)"
  extra="$(comm -13 <(printf '%s\n' "$want") <(printf '%s\n' "$got") | sed '/^$/d' | paste -sd ' ' -)"
  fail "$dir/judgment.md does not name every report item exactly once: missing [${missing:-none}], unknown or repeated [${extra:-none}]; the reports have $s_total Standards items and $p_total Spec items"
fi
# A `hole:` field on an Act on item says the finding's fix changes the artifact the work was built
# against: it repeats, word for word, the `spec:` reference of the report item the judgment item
# names. The field is the text from the last `hole:` on a judgment line to its end, when the line
# does not end in a `fixed:` or `ticket:` field (the field that ends the line is the field, so a
# `hole:` before a trailing `fixed:` or `ticket:` is text). The `$` anchor is on the value
# (`hole: $ref$`), not on detection, which is `holed()`'s exclusion below: a `fixed:` or `ticket:`
# that fits no form leaves its item counted, toward more work for the human, while a `hole:` that
# fell through as text would send a design hole down the fix-on-the-PR path, so every `hole:` text
# in no form is refused with the value shown and a reason that says `hole:` is reworded.
ending='(fixed: [0-9a-f]{7,40}|ticket: #[0-9]+)$'
# holed [heading]: the judgment items under the heading, or under every heading, whose line carries a `hole:` field.
holed() { items "$dir/judgment.md" "${1:-}" | grep -vE "$ending" | grep 'hole:' || true; }
# value <item line>: the field's text after `hole:`, the space after it stripped, for a refusal.
value() { local v="${1##*hole:}"; printf '%s' "${v# }"; }
# A review with no spec has no artifact a hole could amend, so any `hole:` field is refused first.
if [ -z "$has_spec" ]; then
  line="$(holed | head -1)"
  [ -z "$line" ] || fail "$dir/judgment.md item '$(title "$line")' carries a 'hole:' field, but this review has no spec ($dir/spec-brief.md is missing): a hole names an artifact on the ticket the work was built against, and this review has none. Fix the finding on this PR, or rerun scripts/review-brief.sh <fixed-point> --ticket N and judge again"
fi
for h in Ask Consider Noted Dismissed; do
  line="$(holed "$h" | head -1)"
  [ -z "$line" ] || fail "$dir/judgment.md item '$(title "$line")' carries a 'hole:' field under '## $h', 'hole: $(value "$line")'; 'hole:' marks an Act on item, as 'fixed:' and 'ticket:' do: move the item, or reword a reason that says 'hole:'"
done
line="$(holed "Act on" | grep -vE "hole: $ref\$" | head -1 || true)"
[ -z "$line" ] || fail "$dir/judgment.md item '$(title "$line")' has a 'hole:' field that fits no form, 'hole: $(value "$line")' (the text from 'hole:' to the end of the line is the field); a mark ends the line as 'hole: table <row>/<column>', 'hole: design <signature>' or 'hole: criterion <k>', and a reason that says 'hole:' is reworded"
while IFS= read -r line; do
  [ -n "$line" ] || continue
  mark="$(printf '%s' "$line" | sed -E "s#.*hole: ($ref)\$#\1#")"
  ref_id="$(printf '%s' "$line" | sed -nE 's/^[0-9]+\. \[([SP][0-9]+)\].*/\1/p')"
  case "$ref_id" in S*) f="$dir/standards-report.md" ;; *) f="$dir/spec-report.md" ;; esac
  rests="$(specs "$f" | sed -n "${ref_id#[SP]}p")"
  at="${rests%%$'\t'*}"; want="${rests#*$'\t'}"
  [ -n "$want" ] || fail "$dir/judgment.md item '$(title "$line")' is marked 'hole: $mark' but [$ref_id] carries no 'spec:' line: it is under '## $at' in $f, not a counted item"
  [ "$mark" = "$want" ] || fail "$dir/judgment.md item '$(title "$line")' is marked 'hole: $mark' but [$ref_id] rests on '$want'; the mark repeats the report item's 'spec:' line word for word"
done < <(holed "Act on")
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
# An Act on item fixed on this PR (a trailing `fixed: <sha>`, the round-three path), filed as its
# own ticket (a trailing `ticket: #N`) or marked a design hole (a trailing `hole: <reference>`,
# returned to architect) is not counted; a hole prints the line `restart` before the round.
fixed_here="$(items "$dir/judgment.md" "Act on" | grep -cE 'fixed: [0-9a-f]{7,40}$' || true)"
ticketed="$(items "$dir/judgment.md" "Act on" | grep -cE 'ticket: #[0-9]+$' || true)"
holes="$(holed "Act on" | grep -c . || true)"
ask="$(count "$dir/judgment.md" "Ask")"
if [ -n "$has_spec" ]; then spec="$p_wb would break, $p_fo fail open, of $p_total"; else spec="no spec"; fi
if [ -f "$dir/fixed-point" ]; then fixed="fixed point $(cat "$dir/fixed-point")"
elif [ -f "$state/fixed-point" ]; then fixed="fixed point $(cat "$state/fixed-point")"
else fixed="fixed point unknown"; fi
echo "Standards: $s_wb would break, $s_fo fail open, of $s_total; Spec: $spec; judged: act on $act ($fixed_here fixed, $ticketed with a ticket), ask $ask, consider $(count "$dir/judgment.md" Consider), noted $(count "$dir/judgment.md" Noted), dismissed $(count "$dir/judgment.md" Dismissed); $fixed."
[ "$holes" -eq 0 ] || echo restart
echo "round: $round of 3"
echo "act-on items: $((act - fixed_here - ticketed - holes + ask))"
if [ -f "$state/dir" ] && [ "$(cat "$state/dir")" = "$dir" ]; then rm -rf "$state"; fi
