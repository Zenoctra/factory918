#!/usr/bin/env bash
# Runs tools/check_knowledge.py on a copy of docs/knowledge/ whose DECISIONS.md holds the Provisional
# ids of ticket #110's test list, one case per item, in its order, and asserts the check's id lines
# and exit code: an id is P<ticket> with an optional b-z sibling letter, used once, and a Provisional
# section from which no row is read is refused. Item 16 holds the check's id form and the
# `DECISIONS.md` alternative of review-brief.sh's `cites:` grammar together. The script resolves the
# knowledge base from its own path, so each case runs a copy of it in a temp tree. Exits 1 on the
# first miss.
set -euo pipefail
here="$(cd "$(dirname "$0")/../.." && pwd -P)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
kb="$tmp/docs/knowledge"
dec="$kb/core/DECISIONS.md"

bad_tail="is not P<ticket> with an optional b-z sibling letter"
dup_tail="; an id comes from its ticket (P<ticket>, then b, c, ... for a second row of the same ticket), so rename this row and its mentions"
gone="DECISIONS.md: no Provisional row was read; the '## Provisional' section is missing or its table changed shape"

# fresh: the temp tree holds the repository's check and knowledge base, less every real row whose id
# a case writes, so a P110 or P111 row landing in the real file cannot collide with a case.
fresh() {
  rm -rf "$tmp/tools" "$tmp/docs"
  mkdir -p "$tmp/tools" "$tmp/docs"
  cp "$here/tools/check_knowledge.py" "$tmp/tools/"
  cp -R "$here/docs/knowledge" "$tmp/docs/"
  grep -vE '^\| (P110|P110b|P111|P112|P31|P17b) \|' "$here/docs/knowledge/core/DECISIONS.md" > "$dec"
  recount
  base="$(wc -l < "$dec" | tr -d ' ')"
}
# at <id>: the line number of the first row whose id cell is <id>.
at() { grep -nF -- "| $1 |" "$dec" | head -1 | cut -d: -f1; }
# rewrite <old> <new>: the id cell of row <old> becomes <new>, in place; the line count is kept.
rewrite() {
  awk -v o="| $1 |" -v r="| $2 |" 'index($0, o) == 1 && !done { $0 = r substr($0, length(o) + 1); done = 1 } { print }' "$dec" > "$dec.new"
  mv "$dec.new" "$dec"
}
# recount: INDEX.md's line count for DECISIONS.md is the file's, so only the id check can fail.
recount() {
  sed "s/^\(| \`core\/DECISIONS.md\` | [^|]* | \)[0-9]*/\1$(wc -l < "$dec" | tr -d ' ')/" "$kb/INDEX.md" > "$kb/INDEX.new"
  mv "$kb/INDEX.new" "$kb/INDEX.md"
}
row() { printf '| %s | Decision of %s | A choice | A reason |\n' "$1" "$1"; }
# add <id>...: one row per id, appended to the Provisional table in order.
add() {
  local id
  for id in "$@"; do row "$id" >> "$dec"; done
  recount
}
# above <anchor> <id>: a row <id> inserted directly above the row <anchor>.
above() {
  awk -v o="| $1 |" -v r="$(row "$2")" 'index($0, o) == 1 { print r } { print }' "$dec" > "$dec.new"
  mv "$dec.new" "$dec"
  recount
}

n=0
# expect <label> <exit> [line ...]: the check exits <exit> and prints exactly these Provisional lines.
expect() {
  local label="$1" want_code="$2" code got want=""
  shift 2
  set +e
  python3 "$tmp/tools/check_knowledge.py" > "$tmp/out"
  code=$?
  set -e
  got="$(grep -E 'Provisional (id|row)' "$tmp/out" || true)"
  [ $# -eq 0 ] || want="$(printf '%s\n' "$@")"
  if [ "$code" != "$want_code" ] || [ "$got" != "$want" ]; then
    echo "FAIL $label: exit $code, wanted $want_code; the check printed"; cat "$tmp/out"
    echo "wanted these Provisional lines"; printf '%s\n' "$want"; exit 1
  fi
  if [ "$want_code" = 0 ] && ! grep -q '^knowledge ok: ' "$tmp/out"; then
    echo "FAIL $label: no 'knowledge ok:' line"; cat "$tmp/out"; exit 1
  fi
  n=$((n + 1))
}
bad() { echo "DECISIONS.md line $1: Provisional id '$2' $bad_tail"; }
dup() { echo "DECISIONS.md line $1: Provisional id $2 is already on line $3$dup_tail"; }

fresh; rewrite P30 P110
expect "1. 1A, P30 rewritten to P110" 0

fresh; rewrite P29 P110; rewrite P30 P110b
expect "2. 1B, P29 and P30 rewritten to P110 and P110b" 0

for v in P-110 p110 P110a P110.2 110 ""; do
  fresh; l="$(at P30)"; rewrite P30 "$v"
  expect "3. 1C, P30 rewritten to '$v'" 1 "$(bad "$l" "$v")"
done

fresh; add P111 P110
expect "4. 2A, rows P111 then P110 appended" 0

fresh; add P111 P110 P110b
expect "5. 2B, rows P111, P110, P110b appended" 0

fresh; add P111 P-110
expect "6. 2C, rows P111, P-110 appended" 1 "$(bad $((base + 2)) P-110)"

fresh; add P110 P110
expect "7. 3A, two rows P110 appended" 1 "$(dup $((base + 2)) P110 $((base + 1)))"

fresh; add P110 P110b P110 P110b
expect "8. 3B, rows P110, P110b, P110, P110b appended" 1 \
  "$(dup $((base + 3)) P110 $((base + 1)))" "$(dup $((base + 4)) P110b $((base + 2)))"

fresh; add P110 P-110
expect "9. 3C, rows P110, P-110 appended" 1 "$(bad $((base + 2)) P-110)"

fresh; add P110
line110="$(grep -F -- "| P110 |" "$dec")"
above P110 P112
expect "10. 4A, row P110 appended, then P112 inserted above it" 0
grep -qxF -- "$line110" "$dec" || { echo "FAIL 10. 4A: the P110 line changed when P112 arrived above it"; exit 1; }
n=$((n + 1))

fresh; add P110 P110b P112
expect "11. 4B, rows P110, P110b, then P112 appended" 0

fresh; add P112 P110.2
expect "12. 4C, rows P112, P110.2 appended" 1 "$(bad $((base + 2)) P110.2)"

# The ids the check accepts in 1A, 1B and the unmodified copy (all green above and here).
ids() { awk '/^## / { s = /^## Provisional/ } s && /^\| P/ { split($0, c, "|"); gsub(/ /, "", c[2]); print c[2] }' "$dec"; }
fresh; accepted="$(ids)"
expect "16. 5D, the unmodified copy" 0
rewrite P30 P110; accepted="$accepted
$(ids)"
fresh; rewrite P29 P110; rewrite P30 P110b; accepted="$accepted
$(ids)"
alt="$(grep '^cites=' "$here/template/.agents/skills/spec-review/scripts/review-brief.sh" | grep -oE 'DECISIONS\\\.md [^|]+')"
[ -n "$alt" ] || { echo "FAIL 16. 5D: no DECISIONS.md alternative on review-brief.sh's cites= line"; exit 1; }
for id in P110 P110b P1 P17 P30; do
  printf '%s\n' "$accepted" | grep -qxF "$id" || { echo "FAIL 16. 5D: $id is not among the accepted ids"; exit 1; }
done
while IFS= read -r id; do
  echo "DECISIONS.md $id" | grep -qxE "$alt" || { echo "FAIL 16. 5D: the check accepts $id and the cites: grammar ($alt) drops it"; exit 1; }
done <<< "$accepted"
n=$((n + 1))

fresh; add P17
expect "17. 6A, a new row P17" 1 "$(dup $((base + 1)) P17 "$(at P17)")"

fresh; add P17 P17b
expect "18. 6B, new rows P17, P17b" 1 "$(dup $((base + 1)) P17 "$(at P17)")"

fresh; add P17.1
expect "19. 6C, a new row P17.1" 1 "$(bad $((base + 1)) P17.1)"

fresh; add P31 P31
expect "20. 7, two rows P31 appended" 1 "$(dup $((base + 2)) P31 $((base + 1)))"

fresh
sed 's/^## Provisional (/## Agent decisions (/' "$dec" > "$dec.new"
mv "$dec.new" "$dec"
expect "21. 8, the Provisional heading reworded" 1 "$gone"

fresh
awk 'index($0, "| P30 |") == 1 { sub(/ \|$/, " (see P25) |") } { print }' "$dec" > "$dec.new"
mv "$dec.new" "$dec"
grep -qF "(see P25) |" "$dec" || { echo "FAIL 22. 9: the Reason cell did not gain (see P25)"; exit 1; }
expect "22. 9, the unmodified copy with (see P25) in a Reason cell" 0

echo "provisional-ids: $n assertions passed"
