#!/usr/bin/env bash
# Runs review-comment.sh twice, in a temp repo laid out as a project and in one laid out as the
# factory (tests/spec-review/layout.sh), each time the copy of the skill that repo holds, against
# fixture reports and judgments, and asserts the exact stdout of each accepted shape and the exact
# refusal line of each rejected one. Report and judgment items are numbered 1..N across the
# headings; the Spec report's `## Walk` lines are steps, not items, and count nothing. Every item
# under `## Would break` or `## Fails open` carries a `Documented step:` line. A refusal leaves the
# review state in place; an accepted run clears it. Exits 1 on the first miss.
set -euo pipefail
here="$(cd "$(dirname "$0")/../.." && pwd -P)"
# shellcheck source-path=SCRIPTDIR source=layout.sh
. "$here/tests/spec-review/layout.sh"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
dir=.scratch/review/x
state=.claude/state/review

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

printf '## Would break\n\n1. **One.** a\nDocumented step: t\n\n## Fails open\n\n## Standards breaches\n\n2. **Two.** b\n\n## Fix alongside\n\nhard findings: 1\n' > "$dir/standards-report.md"
printf '## Walk\n\n1. step one\n2. step two\n\n## Would break\n\n## Fails open\n\n1. **Edge.** c\nDocumented step: t\n\n## Not asked for\n\nhard findings: 1\n' > "$dir/spec-report.md"
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
round: 1 of 3
act-on items: 0" "nothing found, no spec, no round file"

reset
cat > "$dir/standards-report.md" <<'EOF'
## Would break

1. **Hook exits 0 on a miss.** The guard returns before blocking.
Documented step: `docs/agents/review-ladder.md:6`, "the delegation hook blocks your reads of the changed files"
Result: the read goes through.

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

## Fails open

2. **Token in the log.** A malformed state file is read as a fixed point and the run goes on.
Documented step: "It also writes the review state under `.claude/state/review/`"
Result: a hook reads garbage and blocks nothing.

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
act-on items: 3" "two Act on and one Ask, round 2; the walk's three lines are not items"

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
# is not counted either. The state is gone, so the rerun names the dir.
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
  printf '## Would break\n\n1. **One.** a\nDocumented step: t\n\n%s\n\n## Fails open\n\n## Standards breaches\n\n2. **Two.** b\n\n## Fix alongside\n\n3. **Three.** c\n\nhard findings: 1\n' "$2" > "$dir/standards-report.md"
  printf '## Act on\n\n1. [S1] **One.** yes\n\n## Ask\n\n## Consider\n\n## Noted\n\n2. [S3] **Three.** later\n\n## Dismissed\n\n3. [S2] **Two.** no\n' > "$dir/judgment.md"
  accept "## Standards

$(cat "$dir/standards-report.md")

## Spec

no spec: Standards axis only

## Judgment

$(cat "$dir/judgment.md")

Standards: 1 would break, 0 fail open, of 3; Spec: no spec; judged: act on 1 (0 fixed, 0 with a ticket), ask 0, consider 0, noted 1, dismissed 1; fixed point main.
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
round: 1 of 3
act-on items: 0" "headings with trailing whitespace"
}

suite project
suite factory
echo "ok $n assertions"
