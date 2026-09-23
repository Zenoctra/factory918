#!/usr/bin/env bash
# Runs review-comment.sh twice, in a temp repo laid out as a project and in one laid out as the
# factory (tests/spec-review/layout.sh), each time the copy of the skill that repo holds, against
# fixture reports and judgments, and asserts the exact stdout of each accepted shape and the exact
# refusal line of each rejected one. Report and judgment items are numbered 1..N across the
# headings; the Spec report's `## Walk` lines are steps, not items, and count nothing. Every item
# under `## Would break` or `## Fails open` carries a `Documented step:` line and, in a review with
# a spec (`<dir>/spec-brief.md` present), a `spec:` line naming the cell, signature or criterion it
# rests on; with no spec the line is not asked for. A judgment may mark an Act on item
# `hole: <reference>`, the item's `spec:` word for word: the comment then carries the line
# `restart` before `round:` and the hole is left out of the count. The text from the last `hole:`
# on a judgment line not ending in a `fixed:` or `ticket:` field is the field: one in a review with
# no spec, outside Act on, in no form (a reason that says `hole:` included), or differing from the
# item's `spec:` is refused with the value shown. An Act on item marked `fixed:` whose report item
# sits under `## Would break` puts the line `would-break fixed after <sha>` between the summary
# line and `round:`, `<sha>` from `<dir>/reviewed`, unless a hole is marked; from round four the
# round line reads `of 5`; the line needed with `<dir>/reviewed` missing or not a full commit id
# is refused (ticket #93, table B, one assertion per cell). At rounds one and two with no hole
# marked, three lines may follow, in this order, before `round:` (ticket #106, table B, one
# assertion per cell): `next round owed: round <N+1> reviews the fixes marked here` when an Act on
# item is marked `fixed:`, at round one `reviewed: <sha>` from `<dir>/reviewed`, and at round two
# `fix only after <sha>` when no Would-break or Fails-open item of either report is outside the
# fix lines in `<dir>/fix-lines`. A refusal leaves the review state in place; an accepted run
# clears it. Exits 1 on the first miss.
set -euo pipefail
here="$(cd "$(dirname "$0")/../.." && pwd -P)"
# shellcheck source-path=SCRIPTDIR source=layout.sh
. "$here/tests/spec-review/layout.sh"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
dir=.scratch/review/x
state=.claude/state/review
wb="would-break fixed after 0123456789abcdef0123456789abcdef01234567"
rv="reviewed: 0123456789abcdef0123456789abcdef01234567"

n=0
code=0
out=""
# rearm: the review state an accepted run cleared, with the fixture files kept.
rearm() {
  mkdir -p "$dir" "$state"
  echo main > "$state/fixed-point"
  echo main > "$dir/fixed-point"
  echo a.sh > "$state/files"
  echo "$dir" > "$state/dir"
  echo 0123456789abcdef0123456789abcdef01234567 > "$dir/reviewed"
}
# reset: a fresh review with no reports and no spec brief.
reset() {
  rm -rf "$dir" "$state"
  rearm
}
# run [dir]: the script, with the review dir as its argument when given.
run() {
  set +e
  out="$(bash "$script" "$@" 2>&1)"
  code=$?
  set -e
}
# refuse <message> <label> [dir]: exit 1, that one line on stderr, the state as it was (kept, or absent).
refuse() {
  local had=no
  [ -f "$state/dir" ] && had=yes
  run "${@:3}"
  if [ "$code" != 1 ] || [ "$out" != "review-comment: $1" ] || [ "$([ -f "$state/dir" ] && echo yes || echo no)" != "$had" ]; then
    echo "FAIL $2: exit $code, wanted 1 and the state as it was"
    echo "  got:    $out"
    echo "  wanted: review-comment: $1"
    exit 1
  fi
  n=$((n + 1))
}
# accept <stdout> <label> [dir]: exit 0, exactly that output, the state cleared.
accept() {
  run "${@:3}"
  if [ "$code" != 0 ] || [ "$out" != "$1" ] || [ -e "$state" ]; then
    echo "FAIL $2: exit $code, wanted 0 and the state cleared"
    echo "  got:"; printf '%s\n' "$out"
    echo "  wanted:"; printf '%s\n' "$1"
    exit 1
  fi
  n=$((n + 1))
}
empty_standards() { printf '## Would break\n\n## Fails open\n\n## Standards breaches\n\n## Fix alongside\n\nhard findings: 0\n'; }
empty_spec() { printf '## Walk\n\n## Would break\n\n## Fails open\n\n## Not asked for\n\nhard findings: 0\n'; }
empty_judgment() { printf '## Act on\n\n## Ask\n\n## Consider\n\n## Noted\n\n## Dismissed\n'; }

# suite <project|factory>: every assertion, against the copy of the skill a repo of that layout holds.
suite() {
fx="$tmp/$1"
layout "$1" "$fx"
script="$skill/scripts/review-comment.sh"
cd "$fx"

refuse "no review in progress ($state/dir is missing); run scripts/review-brief.sh first, or pass the review dir to rerun a finished review" "no state"

reset
refuse "$dir/standards-report.md is missing; wait for the Standards reviewer" "no Standards report"

printf '## Would break\n\n## Fails open\n\n## Standards breaches\n\n## Fix alongside\n' > "$dir/standards-report.md"
refuse "$dir/standards-report.md has no 'hard findings: N' line; ask the reviewer for it" "Standards report without the count line"

printf '## Would break\n\n1. **One.** a\n\n## Fails open\n\n2. **Open.** o\n\n## Standards breaches\n\n## Fix alongside\n\n3. **Smell.** b\n\nhard findings: 3\n' > "$dir/standards-report.md"
refuse "$dir/standards-report.md says 'hard findings: 3' but has 1 items under '## Would break' and 1 under '## Fails open'; only those count. Ask the reviewer to put each finding under the heading it belongs to and recount" "count line above the Would-break and Fails-open items"

printf '## Would break\n\n1. **One.** a\n\n## Fails open\n\n## Standards breaches\n\n1. **Two.** b\n2. **Three.** c\n\n## Fix alongside\n\nhard findings: 1\n' > "$dir/standards-report.md"
refuse "$dir/standards-report.md item '1. **Two.** b' is numbered 1 where 2 was expected; number the items 1..N continuously across the headings, in document order" "numbering restarts under the second heading"

printf '## Would Break\n\n## Standards breaches\n\nhard findings: 0\n' > "$dir/standards-report.md"
refuse "$dir/standards-report.md has the headings [Would Break|Standards breaches]; the shape is [Would break|Fails open|Standards breaches|Fix alongside], in that order, each holding numbered items or nothing" "Standards report off its shape"

# A Would-break or Fails-open item without a `Documented step:` line is refused by name; a line
# inside a quoted hunk does not count; a body sentence is not the item's title.
# shellcheck disable=SC2016 # the expected Markdown is literal; the backticks are not command substitution
printf '## Would break\n\n1. **One.** a\nDocumented step: ticket line\nResult: r\n\n## Fails open\n\n2. **Open, silently.** the guard returns. More.\n\n```sh\nDocumented step: inside the hunk\n```\n\n## Standards breaches\n\n## Fix alongside\n\nhard findings: 2\n' > "$dir/standards-report.md"
refuse "$dir/standards-report.md item '2. **Open, silently.**' under '## Fails open' has no 'Documented step:' line; a counted item quotes the ticket line or the file:line of the documentation the user follows, then 'Result:' what happens instead. Ask the reviewer for both" "Fails-open item without a Documented step line, the fenced one not counting"
printf '## Would break\n\n1. **One.** a\n\n## Fails open\n\n2. **Open.** o\nDocumented step: ticket line\n\n## Standards breaches\n\n3. **Breach.** b\n\n## Fix alongside\n\nhard findings: 2\n' > "$dir/standards-report.md"
refuse "$dir/standards-report.md item '1. **One.**' under '## Would break' has no 'Documented step:' line; a counted item quotes the ticket line or the file:line of the documentation the user follows, then 'Result:' what happens instead. Ask the reviewer for both" "Would-break item without a Documented step line"

empty_standards > "$dir/standards-report.md"
echo brief > "$dir/spec-brief.md"
refuse "$dir/spec-report.md is missing; wait for the Spec reviewer" "Spec brief without a Spec report"

printf '## Would break\n\n## Fails open\n\n## Not asked for\n\n## Walk\n\nhard findings: 0\n' > "$dir/spec-report.md"
refuse "$dir/spec-report.md has the headings [Would break|Fails open|Not asked for|Walk]; the shape is [Walk|Would break|Fails open|Not asked for], in that order, each holding numbered items or nothing" "Spec report headings out of order"

empty_spec > "$dir/spec-report.md"
refuse "$dir/judgment.md is missing; sort every report item into Act on, Ask, Consider, Noted or Dismissed with a one-line reason (SKILL.md step 5), then rerun" "no judgment"

printf '## Act on\n\n## Consider\n\n## Noted\n\n## Dismissed\n' > "$dir/judgment.md"
refuse "$dir/judgment.md has the headings [Act on|Consider|Noted|Dismissed]; the shape is [Act on|Ask|Consider|Noted|Dismissed], in that order, each holding numbered items or nothing" "judgment without Ask"

printf '## Would break\n\n1. **One.** a\nDocumented step: t\nspec: criterion 1\n\n## Fails open\n\n## Standards breaches\n\n2. **Two.** b\n\n## Fix alongside\n\nhard findings: 1\n' > "$dir/standards-report.md"
printf '## Walk\n\n1. step one\n2. step two\n\n## Would break\n\n## Fails open\n\n1. **Edge.** c\nDocumented step: t\nspec: criterion 1\n\n## Not asked for\n\nhard findings: 1\n' > "$dir/spec-report.md"
printf '## Act on\n\n1. [S1] **One.** yes\n\n## Ask\n\n## Consider\n\n## Noted\n\n## Dismissed\n' > "$dir/judgment.md"
refuse "$dir/judgment.md has 1 items; the reports have 3 (Standards 2, Spec 1). Every report item appears exactly once in the judgment" "judgment short of the reports"

printf '## Act on\n\n1. [S1] **One.** yes\n\n## Ask\n\n## Consider\n\n## Noted\n\n2. [S4] **Two.** later\n\n## Dismissed\n\n3. [P1] **Edge.** no\n' > "$dir/judgment.md"
refuse "$dir/judgment.md does not name every report item exactly once: missing [S2], unknown or repeated [S4]; the reports have 2 Standards items and 1 Spec items" "reference to an item that does not exist"

printf '## Act on\n\n1. [S1] **One.** yes\n\n## Ask\n\n## Consider\n\n## Noted\n\n2. [S1] **One again.** twice\n\n## Dismissed\n\n3. [P1] **Edge.** no\n' > "$dir/judgment.md"
refuse "$dir/judgment.md does not name every report item exactly once: missing [S2], unknown or repeated [S1]; the reports have 2 Standards items and 1 Spec items" "repeated reference"

printf '## Act on\n\n1. [S1] **One.** yes\n\n## Ask\n\n## Consider\n\n## Noted\n\n2. **Two.** no reference\n\n## Dismissed\n\n3. [P1] **Edge.** no\n' > "$dir/judgment.md"
refuse "$dir/judgment.md item '2. **Two.** no reference' does not open with [S<n>] or [P<n>], the report item it judges" "item without a reference"

printf '## Act on\n\n1. [S1] **One.** yes\n\n## Ask\n\n## Consider\n\n1. [S2] **Two.** maybe\n\n## Noted\n\n## Dismissed\n\n3. [P1] **Edge.** no\n' > "$dir/judgment.md"
refuse "$dir/judgment.md item '1. [S2] **Two.** maybe' is numbered 1 where 2 was expected; number the items 1..N continuously across the headings, in document order" "judgment numbering restarts under Consider"

rm "$dir/spec-brief.md" "$dir/spec-report.md"
printf '## Act on\n\n1. [S1] **One.** yes\n\n## Ask\n\n## Consider\n\n## Noted\n\n2. [P1] **Edge.** no\n\n## Dismissed\n' > "$dir/judgment.md"
refuse "$dir/judgment.md does not name every report item exactly once: missing [S2], unknown or repeated [P1]; the reports have 2 Standards items and 0 Spec items" "Spec reference without a Spec axis"

reset
empty_standards > "$dir/standards-report.md"
empty_judgment > "$dir/judgment.md"
accept "## Standards

## Would break

## Fails open

## Standards breaches

## Fix alongside

hard findings: 0

## Spec

no spec: Standards axis only

## Judgment

## Act on

## Ask

## Consider

## Noted

## Dismissed

Standards: 0 would break, 0 fail open, of 0; Spec: no spec; judged: act on 0 (0 fixed, 0 with a ticket), ask 0, consider 0, noted 0, dismissed 0; fixed point main.
$rv
round: 1 of 3
act-on items: 0" "nothing found, no spec, no round file"

reset
cat > "$dir/standards-report.md" <<'EOF'
## Would break

1. **Hook exits 0 on a miss.** The guard returns before blocking.
Documented step: `docs/agents/review-ladder.md:6`, "the delegation hook blocks your reads of the changed files"
Result: the read goes through.
spec: criterion 1

```sh
## Would break
1. a numbered line inside a quoted hunk is not an item
```

## Fails open

## Standards breaches

2. **Bare number.** P3 wants the constant named.

## Fix alongside

3. **Duplicated Code.** The two loops share a shape.

hard findings: 1
EOF
echo brief > "$dir/spec-brief.md"
cat > "$dir/spec-report.md" <<'EOF'
## Walk

1. `review-brief.sh <fixed-point>` resolves the fixed point and writes the diff.
2. `--ticket N` names the spec; the sweep form drops it.
3. The state file is written under `.claude/state/review/`.

## Would break

1. **Sweep form ignores --ticket.** "add `--ticket N` when the commits do not name the ticket".
Documented step: "add `--ticket N` when the commits do not name the ticket"
Result: the sweep form writes no Spec brief.
spec: design review-brief.sh --paths P... --commits SHA...

## Fails open

2. **Token in the log.** A malformed state file is read as a fixed point and the run goes on.
Documented step: "It also writes the review state under `.claude/state/review/`"
Result: a hook reads garbage and blocks nothing.
spec: table 3/B

## Not asked for

hard findings: 2
EOF
cat > "$dir/judgment.md" <<'EOF'
## Act on

1. [S1] **Hook exits 0 on a miss.** The test proves it.
2. [P1] **Sweep form ignores --ticket.** The commit list is empty there.

## Ask

3. [P2] **Token in the log.** Data retention is the human's call.

## Consider

## Noted

4. [S3] **Duplicated Code.** Fixed alongside S1 if the loops are touched.

## Dismissed

5. [S2] **Bare number.** The constant is named two lines up.
EOF
echo 2 > "$dir/round"
accept "## Standards

$(cat "$dir/standards-report.md")

## Spec

$(cat "$dir/spec-report.md")

## Judgment

$(cat "$dir/judgment.md")

Standards: 1 would break, 0 fail open, of 3; Spec: 1 would break, 1 fail open, of 2; judged: act on 2 (0 fixed, 0 with a ticket), ask 1, consider 0, noted 1, dismissed 1; fixed point main.
round: 2 of 3
act-on items: 3" "two Act on and one Ask, round 2; the walk's three lines are not items (#106 3C: hard items, no fix lines)"
# Ticket #91, criterion 3: a walk that continues with one line per blast-radius risk, numbered on
# from the last step, is still all steps: the same counts and the same comment.
rearm
awk '{ print } /^3\. The state file/ { print "4. Risk: a subagent inherits the hook; the diff exits 0 there."; print "5. Risk: `factory-start` at day zero; the diff runs before any skill is installed." }' "$dir/spec-report.md" > "$dir/spec-report.risks"
mv "$dir/spec-report.risks" "$dir/spec-report.md"
accept "## Standards

$(cat "$dir/standards-report.md")

## Spec

$(cat "$dir/spec-report.md")

## Judgment

$(cat "$dir/judgment.md")

Standards: 1 would break, 0 fail open, of 3; Spec: 1 would break, 1 fail open, of 2; judged: act on 2 (0 fixed, 0 with a ticket), ask 1, consider 0, noted 1, dismissed 1; fixed point main.
round: 2 of 3
act-on items: 3" "the walk continued with two risk lines: the same counts (#91, criterion 3; #106 3C)"

rearm
echo 3 > "$dir/round"
cat > "$dir/judgment.md" <<'EOF'
## Act on

1. [S1] **Hook exits 0 on a miss.** The test proves it.
2. [P1] **Sweep form ignores --ticket.** The commit list is empty there. ticket: #12

## Ask

3. [P2] **Token in the log.** Data retention is the human's call.

## Consider

## Noted

4. [S3] **Duplicated Code.** Fixed alongside S1 if the loops are touched.

## Dismissed

5. [S2] **Bare number.** The constant is named two lines up.
EOF
accept "## Standards

$(cat "$dir/standards-report.md")

## Spec

$(cat "$dir/spec-report.md")

## Judgment

$(cat "$dir/judgment.md")

Standards: 1 would break, 0 fail open, of 3; Spec: 1 would break, 1 fail open, of 2; judged: act on 2 (0 fixed, 1 with a ticket), ask 1, consider 0, noted 1, dismissed 1; fixed point main.
round: 3 of 3
act-on items: 2" "an Act on item filed as a ticket is not counted, round 3"

# The state is cleared; naming the directory rebuilds the same comment, which is how a re-sorted Ask item gets its comment.
accept "## Standards

$(cat "$dir/standards-report.md")

## Spec

$(cat "$dir/spec-report.md")

## Judgment

$(cat "$dir/judgment.md")

Standards: 1 would break, 0 fail open, of 3; Spec: 1 would break, 1 fail open, of 2; judged: act on 2 (0 fixed, 1 with a ticket), ask 1, consider 0, noted 1, dismissed 1; fixed point main.
round: 3 of 3
act-on items: 2" "rebuilt from the directory after the state was cleared" "$dir"
refuse "nowhere is not a directory; pass the .scratch/review/<id> review-brief.sh wrote" "a directory that does not exist" nowhere
touch nowhere
refuse "nowhere is not a directory; pass the .scratch/review/<id> review-brief.sh wrote" "a file where the review dir should be" nowhere
rm nowhere

# At round three the Act on items are fixed on this PR and marked with the commit; a marked item
# is not counted either. S1 sits under `## Would break`, so the comment carries the line that owes
# a fourth round (#93, table B, 3B). The state is gone, so the rerun names the dir.
cat > "$dir/judgment.md" <<'EOF'
## Act on

1. [S1] **Hook exits 0 on a miss.** The test proves it. fixed: abc1234
2. [P1] **Sweep form ignores --ticket.** The commit list is empty there. ticket: #12

## Ask

3. [P2] **Token in the log.** Data retention is the human's call.

## Consider

## Noted

4. [S3] **Duplicated Code.** Fixed alongside S1 if the loops are touched.

## Dismissed

5. [S2] **Bare number.** The constant is named two lines up.
EOF
accept "## Standards

$(cat "$dir/standards-report.md")

## Spec

$(cat "$dir/spec-report.md")

## Judgment

$(cat "$dir/judgment.md")

Standards: 1 would break, 0 fail open, of 3; Spec: 1 would break, 1 fail open, of 2; judged: act on 2 (1 fixed, 1 with a ticket), ask 1, consider 0, noted 1, dismissed 1; fixed point main.
would-break fixed after 0123456789abcdef0123456789abcdef01234567
round: 3 of 3
act-on items: 1" "an Act on item fixed on this PR is not counted, round 3" "$dir"

# A newer review's state is live and names another dir: rerunning the old dir prints its comment
# and leaves that state alone, so the delegation hook keeps blocking the newer review's files.
rearm
echo .scratch/review/y > "$state/dir"
echo other > "$state/fixed-point"
run "$dir"
if [ "$code" != 0 ] || [ "$(cat "$state/dir")" != .scratch/review/y ] || [ "${out%%; fixed point main.*}" = "$out" ]; then
  echo "FAIL rerun of an old dir under a newer review's state: exit $code, wanted 0, the state kept and the old dir's fixed point"
  echo "  got:"; printf '%s\n' "$out"
  exit 1
fi
n=$((n + 1))
rm -rf "$state"

rearm
echo three > "$dir/round"
refuse "$dir/round holds 'three', not a round number; rerun scripts/review-brief.sh" "round file off its shape"

reset
printf '## Would break\n\n## Fails open\n\n## Standards breaches\n\n## Fix alongside\n\n1. **Mysterious Name.** x\n2. **Middle Man.** y\n\nhard findings: 0\n' > "$dir/standards-report.md"
printf '## Act on\n\n## Ask\n\n## Consider\n\n## Noted\n\n## Dismissed\n\n1. [S1] **Mysterious Name.** the name is the domain term\n2. [S2] **Middle Man.** one caller, kept inline\n' > "$dir/judgment.md"
accept "## Standards

$(cat "$dir/standards-report.md")

## Spec

no spec: Standards axis only

## Judgment

$(cat "$dir/judgment.md")

Standards: 0 would break, 0 fail open, of 2; Spec: no spec; judged: act on 0 (0 fixed, 0 with a ticket), ask 0, consider 0, noted 0, dismissed 2; fixed point main.
$rv
round: 1 of 3
act-on items: 0" "Dismissed only"

# The state is gone now. The judgment is re-sorted (an Ask item answered, say) and the script
# reruns on the same reports with the dir as its argument, reading the fixed point from the dir.
printf '## Act on\n\n1. [S1] **Mysterious Name.** the human wants it renamed\n\n## Ask\n\n## Consider\n\n## Noted\n\n## Dismissed\n\n2. [S2] **Middle Man.** one caller, kept inline\n' > "$dir/judgment.md"
accept "## Standards

$(cat "$dir/standards-report.md")

## Spec

no spec: Standards axis only

## Judgment

$(cat "$dir/judgment.md")

Standards: 0 would break, 0 fail open, of 2; Spec: no spec; judged: act on 1 (0 fixed, 0 with a ticket), ask 0, consider 0, noted 0, dismissed 1; fixed point main.
$rv
round: 1 of 3
act-on items: 1" "rerun with the dir argument after the state was cleared" "$dir"
accept "$out" "the same with a trailing slash on the dir" "$dir/"

# An Ask item the human answered moves to the bucket the answer settles. Moved as it stands, the
# numbers no longer run 1..N in document order and the rerun is refused; renumbered, the rerun
# prints the new count.
printf '## Act on\n\n## Ask\n\n1. [S1] **Mysterious Name.** whether the name is a data term is the human'"'"'s call\n\n## Consider\n\n## Noted\n\n## Dismissed\n\n2. [S2] **Middle Man.** one caller, kept inline\n' > "$dir/judgment.md"
accept "## Standards

$(cat "$dir/standards-report.md")

## Spec

no spec: Standards axis only

## Judgment

$(cat "$dir/judgment.md")

Standards: 0 would break, 0 fail open, of 2; Spec: no spec; judged: act on 0 (0 fixed, 0 with a ticket), ask 1, consider 0, noted 0, dismissed 1; fixed point main.
$rv
round: 1 of 3
act-on items: 1" "an Ask item, counted" "$dir"
printf '## Act on\n\n## Ask\n\n## Consider\n\n## Noted\n\n## Dismissed\n\n2. [S2] **Middle Man.** one caller, kept inline\n1. [S1] **Mysterious Name.** the human says the name is the domain term. cites: #7 comment 2026-09-18\n' > "$dir/judgment.md"
refuse "$dir/judgment.md item '2. [S2] **Middle Man.** one caller, kept inline' is numbered 2 where 1 was expected; number the items 1..N continuously across the headings, in document order" "an Ask item moved without renumbering" "$dir"
printf '## Act on\n\n## Ask\n\n## Consider\n\n## Noted\n\n## Dismissed\n\n1. [S2] **Middle Man.** one caller, kept inline\n2. [S1] **Mysterious Name.** the human says the name is the domain term. cites: #7 comment 2026-09-18\n' > "$dir/judgment.md"
accept "## Standards

$(cat "$dir/standards-report.md")

## Spec

no spec: Standards axis only

## Judgment

$(cat "$dir/judgment.md")

Standards: 0 would break, 0 fail open, of 2; Spec: no spec; judged: act on 0 (0 fixed, 0 with a ticket), ask 0, consider 0, noted 0, dismissed 2; fixed point main.
$rv
round: 1 of 3
act-on items: 0" "an Ask item moved and renumbered, the same round" "$dir"

# The same rerun with the dir spelled ./<dir>/ and as its absolute path, the state present and
# naming the dir: each spelling is the dir the state names, so the state is cleared.
for spelling in "./$dir/" "$(git rev-parse --show-toplevel)/$dir"; do
  reset
  printf '## Would break\n\n## Fails open\n\n## Standards breaches\n\n## Fix alongside\n\n1. **Mysterious Name.** x\n2. **Middle Man.** y\n\nhard findings: 0\n' > "$dir/standards-report.md"
  printf '## Act on\n\n1. [S1] **Mysterious Name.** the human wants it renamed\n\n## Ask\n\n## Consider\n\n## Noted\n\n## Dismissed\n\n2. [S2] **Middle Man.** one caller, kept inline\n' > "$dir/judgment.md"
  accept "## Standards

$(cat "$dir/standards-report.md")

## Spec

no spec: Standards axis only

## Judgment

$(cat "$dir/judgment.md")

Standards: 0 would break, 0 fail open, of 2; Spec: no spec; judged: act on 1 (0 fixed, 0 with a ticket), ask 0, consider 0, noted 0, dismissed 1; fixed point main.
$rv
round: 1 of 3
act-on items: 1" "rerun with the dir spelled $spelling" "$spelling"
done

# Fenced text is exempt from the shape. Four reports, each the unfenced twin below with a quoted
# hunk under its first item, parse to the twin's headings and items: a hunk quoting a ``` line
# inside a ```` block, a hunk in ~~~ fences that quotes a ``` line, a hunk quoting a ```sh line
# inside a ``` block (an info string never closes a fence), and a fenced hunk carrying `## ` and
# `1. ` lines. A heading with trailing whitespace is the same heading.
# fenced_twin <label> <hunk>: the twin with the hunk under item 1 is accepted with the twin's summary.
fenced_twin() {
  reset
  printf '## Would break\n\n1. **One.** a\nDocumented step: t\nspec: criterion 1\n\n%s\n\n## Fails open\n\n## Standards breaches\n\n2. **Two.** b\n\n## Fix alongside\n\n3. **Three.** c\n\nhard findings: 1\n' "$2" > "$dir/standards-report.md"
  printf '## Act on\n\n1. [S1] **One.** yes\n\n## Ask\n\n## Consider\n\n## Noted\n\n2. [S3] **Three.** later\n\n## Dismissed\n\n3. [S2] **Two.** no\n' > "$dir/judgment.md"
  accept "## Standards

$(cat "$dir/standards-report.md")

## Spec

no spec: Standards axis only

## Judgment

$(cat "$dir/judgment.md")

Standards: 1 would break, 0 fail open, of 3; Spec: no spec; judged: act on 1 (0 fixed, 0 with a ticket), ask 0, consider 0, noted 1, dismissed 1; fixed point main.
$rv
round: 1 of 3
act-on items: 1" "$1"
}
fenced_twin "the unfenced twin" ""
fenced_twin "a fence quoted inside a longer fence" '````md
## Would break
1. **Quoted.** the hunk is a report
```
2. still the hunk
```
## Fails open
````'
fenced_twin 'a ~~~ fence quoting a ``` line' '~~~sh
## Would break
```
1. still the hunk
~~~'
# shellcheck disable=SC2016 # the expected Markdown is literal; the backticks are not command substitution
fenced_twin 'a ```sh fence quoted inside a ``` block' '```
## Would break
```sh
1. still the hunk
## Fails open
```'
fenced_twin "a fenced hunk carrying heading and item lines" '```
## Fix alongside
1. not an item
## Would break
```'

reset
printf '## Would break \n\n## Fails open\t\n\n## Standards breaches\t\n\n## Fix alongside \n\nhard findings: 0\n' > "$dir/standards-report.md"
empty_judgment > "$dir/judgment.md"
accept "## Standards

$(cat "$dir/standards-report.md")

## Spec

no spec: Standards axis only

## Judgment

$(cat "$dir/judgment.md")

Standards: 0 would break, 0 fail open, of 0; Spec: no spec; judged: act on 0 (0 fixed, 0 with a ticket), ask 0, consider 0, noted 0, dismissed 0; fixed point main.
$rv
round: 1 of 3
act-on items: 0" "headings with trailing whitespace"

# Ticket #90, table B, rows 2 to 4: in a review with a spec, a counted item without a `spec:` line
# naming what it rests on is refused before the judgment is read, whatever the judgment holds; a
# `spec:` fitting no form, or inside a fenced hunk, is the same refusal; a missing
# `Documented step:` is refused first. The refusals fire inside the Standards report's check, so
# the Spec brief needs no Spec report.
reset
echo brief > "$dir/spec-brief.md"
printf '## Would break\n\n1. **One.** a\nDocumented step: t\nResult: r\nspec: criterion 1\n\n## Fails open\n\n2. **Open, silently.** the guard returns.\nDocumented step: t\nResult: r\n\n## Standards breaches\n\n## Fix alongside\n\nhard findings: 2\n' > "$dir/standards-report.md"
refuse "$dir/standards-report.md item '2. **Open, silently.**' under '## Fails open' has no 'spec:' line; a counted item names what it rests on, one of 'spec: table <row>/<column>', 'spec: design <signature>' or 'spec: criterion <k>', on its own line. Ask the reviewer for it" "Fails-open item without a spec line, no judgment yet"
for bad in 'spec: cell 12A' 'spec: table 12A' 'spec: criterion 0' 'spec: table 12/A trailing'; do
  printf '## Would break\n\n1. **One.** a\nDocumented step: t\nResult: r\nspec: criterion 1\n\n## Fails open\n\n2. **Open, silently.** the guard returns.\nDocumented step: t\nResult: r\n%s\n\n## Standards breaches\n\n## Fix alongside\n\nhard findings: 2\n' "$bad" > "$dir/standards-report.md"
  refuse "$dir/standards-report.md item '2. **Open, silently.**' under '## Fails open' has no 'spec:' line; a counted item names what it rests on, one of 'spec: table <row>/<column>', 'spec: design <signature>' or 'spec: criterion <k>', on its own line. Ask the reviewer for it" "Fails-open item whose spec line is '$bad'"
done
# shellcheck disable=SC2016 # the expected Markdown is literal; the backticks are not command substitution
printf '## Would break\n\n1. **One.** a\nDocumented step: t\nResult: r\nspec: criterion 1\n\n## Fails open\n\n2. **Open, silently.** the guard returns.\nDocumented step: t\nResult: r\n\n```sh\nspec: table 2/D\n```\n\n## Standards breaches\n\n## Fix alongside\n\nhard findings: 2\n' > "$dir/standards-report.md"
refuse "$dir/standards-report.md item '2. **Open, silently.**' under '## Fails open' has no 'spec:' line; a counted item names what it rests on, one of 'spec: table <row>/<column>', 'spec: design <signature>' or 'spec: criterion <k>', on its own line. Ask the reviewer for it" "Fails-open item whose spec line is inside a fenced hunk"
printf '## Would break\n\n1. **One.** a\nspec: criterion 1\n\n## Fails open\n\n## Standards breaches\n\n## Fix alongside\n\nhard findings: 1\n' > "$dir/standards-report.md"
refuse "$dir/standards-report.md item '1. **One.**' under '## Would break' has no 'Documented step:' line; a counted item quotes the ticket line or the file:line of the documentation the user follows, then 'Result:' what happens instead. Ask the reviewer for both" "Would-break item with a spec line and no Documented step line"

# Row 7: a review with no spec (no Spec brief) has no artifact a finding could rest on. A counted
# item with no `spec:` line is counted, not refused; a `hole:` field is refused with one message
# whatever its value, before the form check.
reset
printf '## Would break\n\n1. **One.** a\nDocumented step: t\nResult: r\n\n## Fails open\n\n## Standards breaches\n\n## Fix alongside\n\nhard findings: 1\n' > "$dir/standards-report.md"
printf '## Act on\n\n1. [S1] **One.** yes\n\n## Ask\n\n## Consider\n\n## Noted\n\n## Dismissed\n' > "$dir/judgment.md"
accept "## Standards

$(cat "$dir/standards-report.md")

## Spec

no spec: Standards axis only

## Judgment

$(cat "$dir/judgment.md")

Standards: 1 would break, 0 fail open, of 1; Spec: no spec; judged: act on 1 (0 fixed, 0 with a ticket), ask 0, consider 0, noted 0, dismissed 0; fixed point main.
$rv
round: 1 of 3
act-on items: 1" "a counted item with no spec line in a review with no spec, counted (7A)"
rearm
for mark in 'hole: table 2/D' 'hole: table 2'; do
  printf '## Act on\n\n1. [S1] **One.** yes %s\n\n## Ask\n\n## Consider\n\n## Noted\n\n## Dismissed\n' "$mark" > "$dir/judgment.md"
  refuse "$dir/judgment.md item '1. [S1] **One.**' carries a 'hole:' field, but this review has no spec ($dir/spec-brief.md is missing): a hole names an artifact on the ticket the work was built against, and this review has none. Fix the finding on this PR, or rerun scripts/review-brief.sh <fixed-point> --ticket N and judge again" "an Act on item marked '$mark' in a review with no spec (7D)"
done
# #93, table B, 3F: with no spec the heading is still read, so a fixed Would-break item puts the line in the comment.
printf '## Act on\n\n1. [S1] **One.** yes fixed: abc1234\n\n## Ask\n\n## Consider\n\n## Noted\n\n## Dismissed\n' > "$dir/judgment.md"
accept "## Standards

$(cat "$dir/standards-report.md")

## Spec

no spec: Standards axis only

## Judgment

$(cat "$dir/judgment.md")

Standards: 1 would break, 0 fail open, of 1; Spec: no spec; judged: act on 1 (1 fixed, 0 with a ticket), ask 0, consider 0, noted 0, dismissed 0; fixed point main.
would-break fixed after 0123456789abcdef0123456789abcdef01234567
next round owed: round 2 reviews the fixes marked here
$rv
round: 1 of 3
act-on items: 0" "a Would-break item fixed in a review with no spec carries the line (3F)"

# Rows 1, 5 and 6 and the notes under the table. Two counted items rest on a cell and a signature,
# a Fails-open item on a criterion, a Standards-breaches item carries an inert `spec:` line, and
# the walk's lines carry `spec:` and `hole:` text that is invisible.
reset
cat > "$dir/standards-report.md" <<'EOF'
## Would break

1. **Hook exits 0 on a miss.** The guard returns before blocking.
Documented step: `docs/agents/review-ladder.md:6`
Result: the read goes through.
spec: table 2/D

## Fails open

## Standards breaches

2. **Bare number.** P3 wants the constant named.
spec: table 9/Z

## Fix alongside

hard findings: 1
EOF
echo brief > "$dir/spec-brief.md"
cat > "$dir/spec-report.md" <<'EOF'
## Walk

1. `review-brief.sh <fixed-point>` resolves the fixed point and writes the diff.
spec: table 1/A
2. `--ticket N` names the spec; the sweep form drops it. hole: table 1/A

## Would break

1. **Sweep form ignores --ticket.** The sweep form writes no Spec brief.
Documented step: "add `--ticket N` when the commits do not name the ticket"
Result: the sweep form writes no Spec brief.
spec: design overlap.sh N --diff

## Fails open

2. **Token in the log.** A malformed state file is read as a fixed point and the run goes on.
Documented step: "It also writes the review state under `.claude/state/review/`"
Result: a hook reads garbage and blocks nothing.
spec: criterion 3

## Not asked for

hard findings: 2
EOF
# judged <S1 tail> <P1 tail> <S2 tail> <P2 tail>: the judgment with S1 and P1 under Act on, S2 and P2 under Noted.
judged() {
  printf '## Act on\n\n1. [S1] **Hook exits 0 on a miss.** The test proves it.%s\n2. [P1] **Sweep form ignores --ticket.** The commit list is empty there.%s\n\n## Ask\n\n## Consider\n\n## Noted\n\n3. [S2] **Bare number.** The constant is named two lines up.%s\n4. [P2] **Token in the log.** Data retention is settled.%s\n\n## Dismissed\n' "$1" "$2" "$3" "$4" > "$dir/judgment.md"
}
# breach <S2 tail>: the judgment with S1, P1 and S2 under Act on, P2 under Noted.
breach() {
  printf '## Act on\n\n1. [S1] **Hook exits 0 on a miss.** The test proves it.\n2. [P1] **Sweep form ignores --ticket.** The commit list is empty there.\n3. [S2] **Bare number.** The constant is named two lines up.%s\n\n## Ask\n\n## Consider\n\n## Noted\n\n4. [P2] **Token in the log.** Data retention is settled.\n\n## Dismissed\n' "$1" > "$dir/judgment.md"
}
# above: the comment above its summary line, from the fixture files.
above() { printf '## Standards\n\n%s\n\n## Spec\n\n%s\n\n## Judgment\n\n%s' "$(cat "$dir/standards-report.md")" "$(cat "$dir/spec-report.md")" "$(cat "$dir/judgment.md")"; }
judged "" "" "" ""
accept "$(above)

Standards: 1 would break, 0 fail open, of 2; Spec: 1 would break, 1 fail open, of 2; judged: act on 2 (0 fixed, 0 with a ticket), ask 0, consider 0, noted 2, dismissed 0; fixed point main.
$rv
round: 1 of 3
act-on items: 2" "counted items with spec lines and no mark, the walk's spec and hole text invisible (1A, row 6)"
rearm
judged " fixed: abc1234" "" "" ""
accept "$(above)

Standards: 1 would break, 0 fail open, of 2; Spec: 1 would break, 1 fail open, of 2; judged: act on 2 (1 fixed, 0 with a ticket), ask 0, consider 0, noted 2, dismissed 0; fixed point main.
would-break fixed after 0123456789abcdef0123456789abcdef01234567
next round owed: round 2 reviews the fixes marked here
$rv
round: 1 of 3
act-on items: 1" "a counted item with a spec line, fixed (1B; #93 3A: S1 is a Would-break item)"
rearm
judged "" " ticket: #12" "" ""
accept "$(above)

Standards: 1 would break, 0 fail open, of 2; Spec: 1 would break, 1 fail open, of 2; judged: act on 2 (0 fixed, 1 with a ticket), ask 0, consider 0, noted 2, dismissed 0; fixed point main.
$rv
round: 1 of 3
act-on items: 1" "a counted item with a spec line, ticketed (1C)"
# A hole: the summary line unchanged, then `restart`, then the round, then the count without the hole.
rearm
judged " hole: table 2/D" "" "" ""
accept "$(above)

Standards: 1 would break, 0 fail open, of 2; Spec: 1 would break, 1 fail open, of 2; judged: act on 2 (0 fixed, 0 with a ticket), ask 0, consider 0, noted 2, dismissed 0; fixed point main.
restart
round: 1 of 3
act-on items: 1" "an Act on item marked hole with its spec reference (1D)"
# The state is gone; rerunning with the dir prints the same comment, restart included.
accept "$out" "the same comment rebuilt from the dir while the hole is still marked" "$dir"
rearm
judged " hole: table 2/D" " hole: design overlap.sh N --diff" "" ""
accept "$(above)

Standards: 1 would break, 0 fail open, of 2; Spec: 1 would break, 1 fail open, of 2; judged: act on 2 (0 fixed, 0 with a ticket), ask 0, consider 0, noted 2, dismissed 0; fixed point main.
restart
round: 1 of 3
act-on items: 0" "two holes print one restart line and both are left out"
# Only the field that ends the line is a field: a `hole:` before a trailing `fixed:` is text, and
# the fixed Would-break item puts the line in the comment (#93, table B, 4A).
rearm
judged " hole: table 2/D fixed: abc1234" "" "" ""
accept "$(above)

Standards: 1 would break, 0 fail open, of 2; Spec: 1 would break, 1 fail open, of 2; judged: act on 2 (1 fixed, 0 with a ticket), ask 0, consider 0, noted 2, dismissed 0; fixed point main.
would-break fixed after 0123456789abcdef0123456789abcdef01234567
next round owed: round 2 reviews the fixes marked here
$rv
round: 1 of 3
act-on items: 1" "a hole before a trailing fixed field counts as fixed"
rearm
# The text from the last `hole:` to the end of the line is the field, a reason that says `hole:`
# included; a value in no form is refused with the value shown, and the word without a colon is text.
for bad in 'hole: table 2' 'hole: cell 12A' 'hole: criterion 0' 'hole: table 2/D trailing'; do
  judged " $bad" "" "" ""
  refuse "$dir/judgment.md item '1. [S1] **Hook exits 0 on a miss.**' has a 'hole:' field that fits no form, '$bad' (the text from 'hole:' to the end of the line is the field); a mark ends the line as 'hole: table <row>/<column>', 'hole: design <signature>' or 'hole: criterion <k>', and a reason that says 'hole:' is reworded" "an Act on hole reading '$bad' (1E)"
done
# The value is shown as written: a mark missing the space after `hole:` is refused with the space missing.
judged " hole:table 2/D" "" "" ""
refuse "$dir/judgment.md item '1. [S1] **Hook exits 0 on a miss.**' has a 'hole:' field that fits no form, 'hole:table 2/D' (the text from 'hole:' to the end of the line is the field); a mark ends the line as 'hole: table <row>/<column>', 'hole: design <signature>' or 'hole: criterion <k>', and a reason that says 'hole:' is reworded" "an Act on hole written without the space, shown as written (1E)"
judged " Not a design hole: the table stands." "" "" ""
refuse "$dir/judgment.md item '1. [S1] **Hook exits 0 on a miss.**' has a 'hole:' field that fits no form, 'hole: the table stands.' (the text from 'hole:' to the end of the line is the field); a mark ends the line as 'hole: table <row>/<column>', 'hole: design <signature>' or 'hole: criterion <k>', and a reason that says 'hole:' is reworded" "an Act on reason that says 'hole:' is refused with the value shown (1E)"
judged " Not a design hole; the table stands." "" "" ""
accept "$(above)

Standards: 1 would break, 0 fail open, of 2; Spec: 1 would break, 1 fail open, of 2; judged: act on 2 (0 fixed, 0 with a ticket), ask 0, consider 0, noted 2, dismissed 0; fixed point main.
$rv
round: 1 of 3
act-on items: 2" "an Act on reason saying the word without a colon carries no mark, counted (1A)"
rearm
judged " hole: criterion 4" "" "" ""
refuse "$dir/judgment.md item '1. [S1] **Hook exits 0 on a miss.**' is marked 'hole: criterion 4' but [S1] rests on 'table 2/D'; the mark repeats the report item's 'spec:' line word for word" "an Act on hole differing from the item's spec line (1F)"
judged "" "" "" " hole: criterion 3"
refuse "$dir/judgment.md item '4. [P2] **Token in the log.**' carries a 'hole:' field under '## Noted', 'hole: criterion 3'; 'hole:' marks an Act on item, as 'fixed:' and 'ticket:' do: move the item, or reword a reason that says 'hole:'" "a hole under Noted (1G)"
judged "" "" "" " Not a design hole: the table stands."
refuse "$dir/judgment.md item '4. [P2] **Token in the log.**' carries a 'hole:' field under '## Noted', 'hole: the table stands.'; 'hole:' marks an Act on item, as 'fixed:' and 'ticket:' do: move the item, or reword a reason that says 'hole:'" "a Noted reason that says 'hole:' is refused with the value shown (1G)"
judged " hole: table 2" "" "" " hole: criterion 3"
refuse "$dir/judgment.md item '4. [P2] **Token in the log.**' carries a 'hole:' field under '## Noted', 'hole: criterion 3'; 'hole:' marks an Act on item, as 'fixed:' and 'ticket:' do: move the item, or reword a reason that says 'hole:'" "a hole outside Act on is refused before one fitting no form"
breach ""
accept "$(above)

Standards: 1 would break, 0 fail open, of 2; Spec: 1 would break, 1 fail open, of 2; judged: act on 3 (0 fixed, 0 with a ticket), ask 0, consider 0, noted 1, dismissed 0; fixed point main.
$rv
round: 1 of 3
act-on items: 3" "a Standards-breaches item with an inert spec line, unmarked (5A)"
rearm
breach " hole: table 9/Z"
refuse "$dir/judgment.md item '3. [S2] **Bare number.**' is marked 'hole: table 9/Z' but [S2] carries no 'spec:' line: it is under '## Standards breaches' in $dir/standards-report.md, not a counted item" "a hole on a Standards-breaches item, its inert spec line not counting (5D)"
breach " hole: cell 12A"
refuse "$dir/judgment.md item '3. [S2] **Bare number.**' has a 'hole:' field that fits no form, 'hole: cell 12A' (the text from 'hole:' to the end of the line is the field); a mark ends the line as 'hole: table <row>/<column>', 'hole: design <signature>' or 'hole: criterion <k>', and a reason that says 'hole:' is reworded" "a hole fitting no form on a Standards-breaches item (5E)"
breach " hole: criterion 2"
refuse "$dir/judgment.md item '3. [S2] **Bare number.**' is marked 'hole: criterion 2' but [S2] carries no 'spec:' line: it is under '## Standards breaches' in $dir/standards-report.md, not a counted item" "a well-formed hole on a Standards-breaches item (5F)"
judged "" "" " hole: table 9/Z" ""
refuse "$dir/judgment.md item '3. [S2] **Bare number.**' carries a 'hole:' field under '## Noted', 'hole: table 9/Z'; 'hole:' marks an Act on item, as 'fixed:' and 'ticket:' do: move the item, or reword a reason that says 'hole:'" "a hole on a Standards-breaches item under Noted (5G)"

# Ticket #93, table B, over the same fixture: S1 and P1 are the Would-break items, S2 a Standards
# breach, P2 a Fails-open item. An Act on item marked `fixed:` whose report item sits under
# `## Would break` puts `would-break fixed after <sha>` between the summary line and `round:`,
# `<sha>` the content of `<dir>/reviewed`, once whatever the number of such items and never
# beside `restart`; from round four the round line reads `of 5`; the reviewed file is read only
# when the line is needed and refused then when missing or not a full commit id. Each assertion
# names its cell, row then column.
# fails <P2 tail>: the judgment with S1, P1 and P2 under Act on, S2 under Noted.
fails() {
  printf '## Act on\n\n1. [S1] **Hook exits 0 on a miss.** The test proves it.\n2. [P1] **Sweep form ignores --ticket.** The commit list is empty there.\n3. [P2] **Token in the log.** Data retention is settled.%s\n\n## Ask\n\n## Consider\n\n## Noted\n\n4. [S2] **Bare number.** The constant is named two lines up.\n\n## Dismissed\n' "$1" > "$dir/judgment.md"
}
# Row 1: no fixed item; the cap follows the round and the reviewed file is not read.
rearm
echo 4 > "$dir/round"
judged "" "" "" ""
accept "$(above)

Standards: 1 would break, 0 fail open, of 2; Spec: 1 would break, 1 fail open, of 2; judged: act on 2 (0 fixed, 0 with a ticket), ask 0, consider 0, noted 2, dismissed 0; fixed point main.
round: 4 of 5
act-on items: 2" "no fixed item at round 4 (1C)"
rearm
echo 5 > "$dir/round"
accept "$(above)

Standards: 1 would break, 0 fail open, of 2; Spec: 1 would break, 1 fail open, of 2; judged: act on 2 (0 fixed, 0 with a ticket), ask 0, consider 0, noted 2, dismissed 0; fixed point main.
round: 5 of 5
act-on items: 2" "no fixed item at round 5 (1D)"
# Row 2: every fixed item under a heading other than Would break: no line, the round may be the last.
rearm
echo 3 > "$dir/round"
fails " fixed: abc1234"
accept "$(above)

Standards: 1 would break, 0 fail open, of 2; Spec: 1 would break, 1 fail open, of 2; judged: act on 3 (1 fixed, 0 with a ticket), ask 0, consider 0, noted 1, dismissed 0; fixed point main.
round: 3 of 3
act-on items: 2" "a Fails-open item fixed at round 3: no line (2B)"
rearm
echo 4 > "$dir/round"
accept "$(above)

Standards: 1 would break, 0 fail open, of 2; Spec: 1 would break, 1 fail open, of 2; judged: act on 3 (1 fixed, 0 with a ticket), ask 0, consider 0, noted 1, dismissed 0; fixed point main.
round: 4 of 5
act-on items: 2" "a Fails-open item fixed at round 4: no line (2C)"
rearm
echo 3 > "$dir/round"
breach " fixed: abc1234"
accept "$(above)

Standards: 1 would break, 0 fail open, of 2; Spec: 1 would break, 1 fail open, of 2; judged: act on 3 (1 fixed, 0 with a ticket), ask 0, consider 0, noted 1, dismissed 0; fixed point main.
round: 3 of 3
act-on items: 2" "a Standards-breaches item fixed at round 3: no line (2B)"
# Row 3: a fixed item under Would break in either report carries the line; a rerun from the dir
# prints it again; at rounds four and five the cap is 5.
rearm
judged " fixed: abc1234" "" "" ""
accept "$(above)

Standards: 1 would break, 0 fail open, of 2; Spec: 1 would break, 1 fail open, of 2; judged: act on 2 (1 fixed, 0 with a ticket), ask 0, consider 0, noted 2, dismissed 0; fixed point main.
$wb
round: 3 of 3
act-on items: 1" "a Standards Would-break item fixed at round 3 (3B)"
accept "$out" "the same comment rebuilt from the dir, the line included (3B)" "$dir"
rearm
judged "" " fixed: abc1234" "" ""
accept "$(above)

Standards: 1 would break, 0 fail open, of 2; Spec: 1 would break, 1 fail open, of 2; judged: act on 2 (1 fixed, 0 with a ticket), ask 0, consider 0, noted 2, dismissed 0; fixed point main.
$wb
round: 3 of 3
act-on items: 1" "a Spec Would-break item fixed at round 3 (3B)"
rearm
echo 4 > "$dir/round"
judged " fixed: abc1234" "" "" ""
accept "$(above)

Standards: 1 would break, 0 fail open, of 2; Spec: 1 would break, 1 fail open, of 2; judged: act on 2 (1 fixed, 0 with a ticket), ask 0, consider 0, noted 2, dismissed 0; fixed point main.
$wb
round: 4 of 5
act-on items: 1" "a Would-break item fixed at round 4 (3C)"
rearm
echo 5 > "$dir/round"
accept "$(above)

Standards: 1 would break, 0 fail open, of 2; Spec: 1 would break, 1 fail open, of 2; judged: act on 2 (1 fixed, 0 with a ticket), ask 0, consider 0, noted 2, dismissed 0; fixed point main.
$wb
round: 5 of 5
act-on items: 1" "a Would-break item fixed at round 5 (3D)"
# 3E: the line is needed and the reviewed file is missing, short, not hex or empty: refused with
# the content as written, the state kept.
rearm
rm "$dir/reviewed"
refuse "$dir/reviewed is missing or holds no full commit id (''); '1. [S1] **Hook exits 0 on a miss.**' under '## Would break' is marked 'fixed:', and the next round reviews that fix from the commit this round reviewed: write its 40-character id to $dir/reviewed (git rev-parse of the first commit in $dir/log) and rerun" "a Would-break fix with no reviewed file (3E; #106 11D)"
for content in abc1234 three; do
  echo "$content" > "$dir/reviewed"
  refuse "$dir/reviewed is missing or holds no full commit id ('$content'); '1. [S1] **Hook exits 0 on a miss.**' under '## Would break' is marked 'fixed:', and the next round reviews that fix from the commit this round reviewed: write its 40-character id to $dir/reviewed (git rev-parse of the first commit in $dir/log) and rerun" "a Would-break fix with the reviewed file holding '$content' (3E)"
done
: > "$dir/reviewed"
refuse "$dir/reviewed is missing or holds no full commit id (''); '1. [S1] **Hook exits 0 on a miss.**' under '## Would break' is marked 'fixed:', and the next round reviews that fix from the commit this round reviewed: write its 40-character id to $dir/reviewed (git rev-parse of the first commit in $dir/log) and rerun" "a Would-break fix with an empty reviewed file (3E)"
# Row 5: a hole beside a Would-break fix: restart wins, no line, the reviewed file not read.
rearm
echo 3 > "$dir/round"
judged " hole: table 2/D" " fixed: abc1234" "" ""
accept "$(above)

Standards: 1 would break, 0 fail open, of 2; Spec: 1 would break, 1 fail open, of 2; judged: act on 2 (1 fixed, 0 with a ticket), ask 0, consider 0, noted 2, dismissed 0; fixed point main.
restart
round: 3 of 3
act-on items: 0" "a hole and a Would-break fix: restart, no line (5B)"
rearm
rm "$dir/reviewed"
accept "$(above)

Standards: 1 would break, 0 fail open, of 2; Spec: 1 would break, 1 fail open, of 2; judged: act on 2 (1 fixed, 0 with a ticket), ask 0, consider 0, noted 2, dismissed 0; fixed point main.
restart
round: 3 of 3
act-on items: 0" "a hole and a Would-break fix with no reviewed file: the file is not read (5E)"
for r in 4 5; do
  rearm
  echo "$r" > "$dir/round"
  accept "$(above)

Standards: 1 would break, 0 fail open, of 2; Spec: 1 would break, 1 fail open, of 2; judged: act on 2 (1 fixed, 0 with a ticket), ask 0, consider 0, noted 2, dismissed 0; fixed point main.
restart
round: $r of 5
act-on items: 0" "a hole and a Would-break fix at round $r: restart, no line (5$([ "$r" = 4 ] && echo C || echo D))"
done
rearm
echo 3 > "$dir/round"
# Row 6: a Would-break item filed as a ticket is not a fix.
rearm
judged "" " ticket: #12" "" ""
accept "$(above)

Standards: 1 would break, 0 fail open, of 2; Spec: 1 would break, 1 fail open, of 2; judged: act on 2 (0 fixed, 1 with a ticket), ask 0, consider 0, noted 2, dismissed 0; fixed point main.
round: 3 of 3
act-on items: 1" "a Would-break item ticketed at round 3: no line (6B)"
# Row 7: two Would-break fixes, one in each report: one line.
rearm
judged " fixed: abc1234" " fixed: def5678" "" ""
accept "$(above)

Standards: 1 would break, 0 fail open, of 2; Spec: 1 would break, 1 fail open, of 2; judged: act on 2 (2 fixed, 0 with a ticket), ask 0, consider 0, noted 2, dismissed 0; fixed point main.
$wb
round: 3 of 3
act-on items: 0" "two Would-break fixes print one line (7B)"
# Row 8: a `## Walk` line carrying `fixed:` is not an item: no line, the counts unchanged.
rearm
rm "$dir/round"
awk '{ print } /^2\. `--ticket N`/ { print "3. The fix lane commits. fixed: abc1234" }' "$dir/spec-report.md" > "$dir/spec-report.walk"
mv "$dir/spec-report.walk" "$dir/spec-report.md"
judged "" "" "" ""
accept "$(above)

Standards: 1 would break, 0 fail open, of 2; Spec: 1 would break, 1 fail open, of 2; judged: act on 2 (0 fixed, 0 with a ticket), ask 0, consider 0, noted 2, dismissed 0; fixed point main.
$rv
round: 1 of 3
act-on items: 2" "a walk line carrying fixed: is invisible (8)"
# Row 9: the sweep form carries the line too, the reviewed file holding the checked-out HEAD at brief time.
rearm
echo paths > "$dir/fixed-point"
judged " fixed: abc1234" "" "" ""
accept "$(above)

Standards: 1 would break, 0 fail open, of 2; Spec: 1 would break, 1 fail open, of 2; judged: act on 2 (1 fixed, 0 with a ticket), ask 0, consider 0, noted 2, dismissed 0; fixed point paths.
$wb
next round owed: round 2 reviews the fixes marked here
$rv
round: 1 of 3
act-on items: 1" "a Would-break fix in the sweep form (9)"

# Ticket #106, table B: at rounds one and two with no hole marked, the tail gains the owed line
# when an Act on item is marked `fixed:`, `reviewed: <sha>` at round one and `fix only after <sha>`
# at round two when no hard item of either report is outside the fix; from round three on, and
# beside `restart`, none of the three. The fix added `exit 1 # miss` and removed `exit 0`
# (<dir>/fix-lines, which round two's brief writes); r2 is the id rearm writes to <dir>/reviewed.
# Each assertion names its cell, row then column; the lines above the summary line are the
# fixture files, and the summary line is #93's, unchanged.
r2=0123456789abcdef0123456789abcdef01234567
fo="fix only after $r2"
owed2="next round owed: round 2 reviews the fixes marked here"
owed3="next round owed: round 3 reviews the fixes marked here"
# at <round>: a fresh review with a spec at that round (no round file at 1), empty reports and
# judgment, and the fix lines.
at() {
  reset
  echo brief > "$dir/spec-brief.md"
  empty_standards > "$dir/standards-report.md"
  empty_spec > "$dir/spec-report.md"
  empty_judgment > "$dir/judgment.md"
  [ "$1" = 1 ] || echo "$1" > "$dir/round"
  printf 'exit 1 # miss\nexit 0\n' > "$dir/fix-lines"
}
# ends <tail> <label> [dir]: exit 0, the fixture files above the summary line, exactly the tail
# after it, the state cleared.
ends() {
  run "${@:3}"
  local body="${out%%$'\n\n'Standards: *}" rest="${out#*$'\n'Standards: }"
  rest="${rest#*$'\n'}"
  if [ "$code" != 0 ] || [ "$body" != "$(above)" ] || [ "$rest" != "$1" ] || [ -e "$state" ]; then
    echo "FAIL $2: exit $code, wanted 0, the fixture files, the tail and the state cleared"
    echo "  got:"; printf '%s\n' "$out"
    echo "  wanted tail:"; printf '%s\n' "$1"
    exit 1
  fi
  n=$((n + 1))
}
# item <quote>: a Would-break item on the hook, with the quote fenced under it when one is given.
# shellcheck disable=SC2016 # the expected Markdown is literal; the backticks and $1 are not expanded
item() {
  printf '**Hook exits 0 on a miss.** The guard returns before blocking.\nDocumented step: `a.sh:2`, "a miss exits 1"\nResult: the read goes through.\nspec: table 2/D\n'
  [ -z "$1" ] || printf '\n```diff\n%s\n```\n' "$1"
}
# standards <item>...: the Standards report holding the items under Would break, then one breach.
standards() {
  local i=0 it
  {
    printf '## Would break\n\n'
    for it in "$@"; do i=$((i + 1)); printf '%s. %s\n\n' "$i" "$it"; done
    printf '## Fails open\n\n## Standards breaches\n\n%s. **Bare number.** P3 wants the constant named.\n\n## Fix alongside\n\nhard findings: %s\n' "$((i + 1))" "$#"
  } > "$dir/standards-report.md"
}
# judge <S1 tail> <S2 tail> [P1]: S1 (the Would-break item) and S2 (the breach) under Act on; P1,
# when its argument is given, under Noted.
judge() {
  local p1=""
  [ -z "${3:-}" ] || p1=$'3. [P1] **Ticket line.** Read.\n\n'
  printf '## Act on\n\n1. [S1] **Hook exits 0 on a miss.** The test proves it.%s\n2. [S2] **Bare number.** Named.%s\n\n## Ask\n\n## Consider\n\n## Noted\n\n%s## Dismissed\n' "$1" "$2" "$p1" > "$dir/judgment.md"
}
# shellcheck disable=SC2016 # the expected Markdown is literal; the backticks and $1 are not expanded
inside="$(item ' if [ -f "$1" ]; then
-  exit 0
+  exit 1 # miss')"
outside="$(item '+  exit 2 # elsewhere
+  exit 1 # miss')"
# shellcheck disable=SC2016 # the expected Markdown is literal; the backticks and $1 are not expanded
context="$(item ' if [ -f "$1" ]; then
 fi')"
bare="$(item '')"
elided="$(item '...
@@ -1 +1 @@')"
# Row 1: no hard item, nothing marked.
at 1
ends "$rv
round: 1 of 3
act-on items: 0" "no hard item at round 1: the reviewed line (1A)"
at 2
ends "$fo
round: 2 of 3
act-on items: 0" "no hard item at round 2: fix only after (1B)"
at 2
rm "$dir/fix-lines"
ends "$fo
round: 2 of 3
act-on items: 0" "no hard item at round 2 with no fix lines: none is outside (1C)"
for r in 3 4 5; do
  at "$r"
  cap=3; [ "$r" -le 3 ] || cap=5
  ends "round: $r of $cap
act-on items: 0" "no hard item at round $r: no new line (1D)"
done
# Row 2: every hard item inside the fix.
at 1
standards "$inside"
judge "" ""
ends "$rv
round: 1 of 3
act-on items: 2" "a hard item inside the fix at round 1 (2A)"
at 2
standards "$inside"
judge "" ""
ends "$fo
round: 2 of 3
act-on items: 2" "a hard item inside the fix at round 2 (2B)"
ends "$fo
round: 2 of 3
act-on items: 2" "the same comment rebuilt from the dir (13, after 2B)" "$dir"
at 2
standards "$inside"
judge "" ""
rm "$dir/fix-lines"
ends "round: 2 of 3
act-on items: 2" "a hard item with no fix lines at round 2 (2C)"
at 2
standards "$inside"
judge "" ""
: > "$dir/fix-lines"
ends "round: 2 of 3
act-on items: 2" "a hard item with empty fix lines at round 2 (2C)"
at 3
standards "$inside"
judge "" ""
ends "round: 3 of 3
act-on items: 2" "a hard item inside the fix at round 3: no new line (2D)"
# Row 3: a marked line the fix did not change, whatever the judgment does with the item.
at 2
standards "$outside"
judge "" ""
ends "round: 2 of 3
act-on items: 2" "a hard item quoting a line the rest of the PR added, Act on (3B)"
printf '## Act on\n\n## Ask\n\n## Consider\n\n## Noted\n\n## Dismissed\n\n1. [S1] **Hook exits 0 on a miss.** Not a bug.\n2. [S2] **Bare number.** Named.\n' > "$dir/judgment.md"
ends "round: 2 of 3
act-on items: 0" "the same item Dismissed: the verdict does not read the judgment (3B)" "$dir"
at 2
standards "$outside"
judge "" ""
rm "$dir/fix-lines"
ends "round: 2 of 3
act-on items: 2" "a hard item outside the fix with no fix lines (3C)"
at 2
standards "$context"
judge "" ""
ends "round: 2 of 3
act-on items: 2" "a hard item quoting only context lines the fix did not touch (3B)"
# Row 4: no quoted line at all.
for it in "$bare" "$elided"; do
  at 2
  standards "$it"
  judge "" ""
  ends "round: 2 of 3
act-on items: 2" "a hard item with no fenced block, or only elision and a hunk header in it (4B)"
done
# Row 5: a Spec item quoting its ticket line.
at 2
standards "$inside"
# shellcheck disable=SC2016 # the expected Markdown is literal; the backticks and $1 are not expanded
printf '## Walk\n\n## Would break\n\n1. **Ticket line.** The brief misses it.\nDocumented step: "The brief carries the ticket body."\nResult: it does not.\nspec: criterion 1\n\n```md\n- [ ] The brief carries the ticket body.\n```\n\n## Fails open\n\n## Not asked for\n\nhard findings: 1\n' > "$dir/spec-report.md"
judge "" "" P1
ends "round: 2 of 3
act-on items: 2" "a Spec hard item quoting its ticket line beside one inside the fix (5B)"
# Row 6: a removed line and an added line, each in its own item, context around them.
at 2
# shellcheck disable=SC2016 # the expected Markdown is literal; the backticks and $1 are not expanded
standards "$(item ' if [ -f "$1" ]; then
-  exit 0
 fi')" "$(item ' if [ -f "$1" ]; then
+  exit 1 # miss')"
printf '## Act on\n\n1. [S1] **Hook exits 0 on a miss.** Removed.\n2. [S2] **Hook exits 0 on a miss.** Added.\n\n## Ask\n\n## Consider\n\n## Noted\n\n3. [S3] **Bare number.** Named.\n\n## Dismissed\n' > "$dir/judgment.md"
ends "$fo
round: 2 of 3
act-on items: 2" "one item quoting a removed fix line, one an added one (6B)"
# Row 7: an Act on item marked fixed, here the breach.
at 1
standards "$inside"
judge "" " fixed: abc1234"
ends "$owed2
$rv
round: 1 of 3
act-on items: 1" "a fix marked at round 1: owed, then reviewed (7A)"
at 2
standards "$inside"
judge "" " fixed: abc1234"
ends "$owed3
$fo
round: 2 of 3
act-on items: 1" "a fix marked at round 2 with every hard item inside: owed, then fix only after (7B)"
ends "$owed3
$fo
round: 2 of 3
act-on items: 1" "the same comment rebuilt from the dir (13, after 7B)" "$dir"
at 2
standards "$outside"
judge "" " fixed: abc1234"
rm "$dir/fix-lines"
ends "$owed3
round: 2 of 3
act-on items: 1" "a fix marked at round 2 with a hard item outside: owed alone (7C)"
at 3
standards "$inside"
judge "" " fixed: abc1234"
ends "round: 3 of 3
act-on items: 1" "a fix marked at round 3: no owed line (7D)"
# Row 8: a Would-break fix.
at 1
standards "$inside"
judge " fixed: abc1234" ""
ends "$wb
$owed2
$rv
round: 1 of 3
act-on items: 1" "a Would-break fix at round 1: the line, owed, reviewed (8A)"
at 2
standards "$inside"
judge " fixed: abc1234" ""
ends "$wb
$owed3
$fo
round: 2 of 3
act-on items: 1" "a Would-break fix at round 2: the line, owed, fix only after (8B)"
# Row 9: a hole outranks every new line.
at 1
standards "$inside"
judge " hole: table 2/D" " fixed: abc1234"
ends "restart
round: 1 of 3
act-on items: 0" "a hole at round 1: restart alone (9A)"
at 2
standards "$inside"
judge " hole: table 2/D" " fixed: abc1234"
ends "restart
round: 2 of 3
act-on items: 0" "a hole at round 2 with every hard item inside: restart alone (9B)"
# Row 10: no usable reviewed file and no Would-break fix: the record is left out, nothing refused.
at 1
rm "$dir/reviewed"
ends "round: 1 of 3
act-on items: 0" "no reviewed file at round 1 (10A)"
at 1
echo abc1234 > "$dir/reviewed"
ends "round: 1 of 3
act-on items: 0" "a short reviewed file at round 1 (10A)"
at 2
rm "$dir/reviewed"
ends "round: 2 of 3
act-on items: 0" "no reviewed file at round 2 (10B)"
# Row 11: the same with a Would-break fix: #93's refusal.
at 1
standards "$inside"
judge " fixed: abc1234" ""
rm "$dir/reviewed"
refuse "$dir/reviewed is missing or holds no full commit id (''); '1. [S1] **Hook exits 0 on a miss.**' under '## Would break' is marked 'fixed:', and the next round reviews that fix from the commit this round reviewed: write its 40-character id to $dir/reviewed (git rev-parse of the first commit in $dir/log) and rerun" "a Would-break fix with no reviewed file at round 1 (11A)"
# Row 12: a walk quoting a line outside the fix and a walk line carrying fixed: are no items.
at 2
standards "$inside"
# shellcheck disable=SC2016 # the expected Markdown is literal; the backticks and $1 are not expanded
printf '## Walk\n\n1. The hook runs at every prompt.\n\n```diff\n-  exit 0\n+  exit 2 # elsewhere\n```\n\n2. The fix lane commits. fixed: abc1234\n\n## Would break\n\n## Fails open\n\n## Not asked for\n\nhard findings: 0\n' > "$dir/spec-report.md"
judge "" ""
ends "$fo
round: 2 of 3
act-on items: 2" "a walk quoting a line outside the fix and carrying fixed: (12)"
}

suite project
suite factory
echo "ok $n assertions"
