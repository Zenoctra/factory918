#!/usr/bin/env bash
# Runs review-brief.sh twice, in a temp repo laid out as a project and in one laid out as the
# factory (tests/spec-review/layout.sh), each time the copy of the skill that repo holds, and
# asserts that each brief carries the report shape review-comment.sh enforces: the definition
# sentence, Manuel's five sentences, every heading name, the item format, the step rule, the spec
# rule (only in a review with a spec: a run with no ticket writes a Standards brief without it) and
# the count rule. The fake gh (tests/spec-review/fake-gh.sh) on PATH supplies the ticket body and the
# ticket's comments, and the PR's earlier review comments when a fixture file names them (no PR
# otherwise), so the Spec brief is written and the round is 1 unless the comments or --round say
# otherwise. Only the judgment items that cite a decision carry into both briefs, from every earlier
# comment, each line once; the round is one more than the highest `round: N of 3` among the comments,
# so a rebuilt comment does not advance it; a fourth round is refused before any state is written;
# a gh failure other than "no pull requests found" is printed and the run goes on. A comment holding
# a line that is exactly `restart` outside fenced text ends the history: the round and the settled
# items come from the comments after the last such comment, the script prints a `restart:` line,
# and a cite of a cell, a signature or a criterion (`cites: #N table <row>/<column>`, `design
# <signature>`, `criterion <k>`) carries like the three older forms. A diff touching
# a cross-cutting path is briefed with its blast-radius grounding (--blast-radius FILE, else the PR
# body's section) before the diff, and refused without one. For such a diff the Spec brief's
# `## Walk` bullet continues, on its line, with the risk sentence, and a grounding with no line
# outside fenced text that is exactly `## Risks` or `### Risks` is refused before any state is
# written; the assertions come from ticket #91's scenario table, one per cell, each named by its
# row and column. A round past three (ticket #93's table A, one assertion per cell) is allowed
# only when the last comment carries `would-break fixed after <sha>` and the fixed point is that
# commit: the brief then reads `round: N of 5`, both briefs carry the fixed items under `## The
# fix under review` before the diff, and a sixth round, a hand-written line, a fixed point that is
# not the commit, one that does not resolve, and a fix-only round with no ticket after a round
# with a spec are each refused before any state is written; every run records HEAD in
# `<dir>/reviewed`. Round three is fix-only the same way when round two's comment carries
# `fix only after <sha>` (ticket #106's table A, one assertion per cell); rounds one and two print
# byte for byte what they print with the `reviewed:`, `fix only after` and `next round owed:`
# lines deleted, and round two after a `reviewed: <sha>` line writes the fix lines to
# `<dir>/fix-lines`. The source SKILL.md, step 4, must carry the definition, the five sentences,
# the heading bullets, the step rule, the spec rule, the count rule, the settled paragraph, the
# blast-radius paragraph, the risk sentence and the fix paragraph word for word, step 1 the
# fix-only round three, and the two babysit copies the same merge-ready and owed sentences, so the
# skill and the script cannot drift apart.
# Exits 1 on the first miss.
# shellcheck disable=SC2016 # the expected strings below are the Markdown the script emits; the backticks and $ are literal
set -euo pipefail
here="$(cd "$(dirname "$0")/../.." && pwd -P)"
# shellcheck source-path=SCRIPTDIR source=layout.sh
. "$here/tests/spec-review/layout.sh"
command -v jq >/dev/null || { echo "FAIL: jq is needed to play gh pr view"; exit 1; }
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
mkdir "$tmp/bin"
cp "$here/tests/spec-review/fake-gh.sh" "$tmp/bin/gh"
PATH="$tmp/bin:$PATH"
# pr <author> [login:file ...]: pr.json, the PR opened by <author> with one comment per pair, in order.
pr() {
  local a="$1" c; shift
  for c in "$@"; do jq -n --arg l "${c%%:*}" --rawfile b "${c#*:}" '{author: {login: $l}, body: $b}'; done |
    jq -s --arg a "$a" '{author: {login: $a}, comments: .}' > pr.json
}

n=0
# has <file> <text> <label>: the file contains the text as a fixed string.
has() {
  if ! grep -qF -- "$2" "$1"; then
    echo "FAIL $3: $1 lacks: $2"
    exit 1
  fi
  n=$((n + 1))
}
# lacks <file> <text> <label>: the file does not contain the text.
lacks() {
  if grep -qF -- "$2" "$1"; then
    echo "FAIL $3: $1 carries: $2"
    exit 1
  fi
  n=$((n + 1))
}
# printed <file> <expected> <label>: the script's stdout, exactly.
printed() {
  if [ "$(cat "$1")" != "$2" ]; then
    echo "FAIL $3: review-brief.sh printed"; cat "$1"; echo "wanted"; printf '%s\n' "$2"; exit 1
  fi
  n=$((n + 1))
}

# suite <project|factory>: every assertion, against the copy of the skill a repo of that layout holds.
suite() {
fx="$tmp/$1"
layout "$1" "$fx"
cd "$fx"
echo one > a.txt
git add a.txt
git commit -qm "first"
echo two > a.txt
git commit -qam "second, no ticket named"

# No PR: gh's "no pull requests found" is swallowed and the round is 1.
echo 'no pull requests found for branch "x"' > pr-error
bash "$skill/scripts/review-brief.sh" HEAD~1 --ticket 7 > out.txt 2> err.txt
rm pr-error
printed out.txt "ticket: #7
round: 1 of 3
.scratch/review/HEAD_1/standards-brief.md
.scratch/review/HEAD_1/spec-brief.md" "first round, no PR"
std=.scratch/review/HEAD_1/standards-brief.md
spec=.scratch/review/HEAD_1/spec-brief.md
[ "$(cat .scratch/review/HEAD_1/round)" = 1 ] || { echo "FAIL: the round file does not say 1"; exit 1; }
n=$((n + 1))
# #93, table A, row 20: every run that writes state records the commit it reviews beside the round.
[ "$(cat .scratch/review/HEAD_1/reviewed)" = "$(git rev-parse HEAD)" ] || { echo "FAIL: the reviewed file does not hold HEAD (20)"; exit 1; }
n=$((n + 1))
[ ! -s err.txt ] || { echo "FAIL no PR: gh's 'no pull requests found' is printed:"; cat err.txt; exit 1; }
n=$((n + 1))
# A PR with no comments is round 1 too.
bash "$skill/scripts/review-brief.sh" HEAD~1 --ticket 7 > out.txt 2> err.txt
has out.txt "round: 1 of 3" "a PR without comments is round 1"
[ ! -s err.txt ] || { echo "FAIL PR without comments: stderr is not empty:"; cat err.txt; exit 1; }
n=$((n + 1))

# Any other gh failure is printed, and the run goes on as round 1 with nothing carried.
echo "HTTP 401: Bad credentials (https://api.github.com/graphql)" > pr-error
bash "$skill/scripts/review-brief.sh" HEAD~1 --ticket 7 > out.txt 2> err.txt
rm pr-error
has err.txt "review-brief: gh could not read the PR's review comments (HTTP 401: Bad credentials (https://api.github.com/graphql))" "a gh failure other than no PR is printed"
has out.txt "round: 1 of 3" "a gh failure other than no PR still runs round 1"
lacks "$std" "## Settled in earlier rounds" "a gh failure other than no PR carries nothing"

definition="A hard finding is one of two things: the documented path gives a wrong or silent result, or an input outside it proceeds silently (fails open). An input outside the documented path that is refused with a message saying how to correct it is not a finding; it is the design. Zero items is the expected result for a clean change."
quotes=(
  '- Manuel: "there are an infinite amount of unhappy paths and only 1 happy one"'
  '- Manuel: "AT MOST hardening to fail fast and loud if we move outside of that"'
  '- Manuel: "we notice the variable is unexpected and flag that without having to diagnose every reason the variable might be wrong for the user"'
  '- Manuel: "An edge case outside the intended path being unsupported is not a flag."'
  '- Manuel: "Primary focus must be the happy path, then unhappy paths that error in a way the user can correct."'
)
step_rule='Every item under `## Would break` or `## Fails open` carries a line `Documented step:` quoting the ticket line or the `file:line` of the documentation the user follows, and a line `Result:` saying what happens instead; an item without its `Documented step:` line is sent back.'
spec_rule='The same item carries a line `spec:` naming the artifact it rests on: `table <row>/<column>` for a cell of the ticket'"'"'s scenario table, `design <signature>` for a signature or usage in its `## Design` sketch, or `criterion <k>` for its k-th acceptance checkbox; an item without a `spec:` line in one of those three forms is sent back.'
count_rule='End the report with exactly one line `hard findings: N`, where N is the number of items under `## Would break` and `## Fails open` and nothing else.'
settled_rule="These findings were raised in an earlier round and settled by the decision each one cites. Do not raise them again. Nothing in this section says what you should find or confirm."
fix_rule="The round before this one fixed these Act on items on this PR after the commit it reviewed; this round's diff is those fix commits and nothing else. Read each fix against its item, walk only the steps these commits touch, and report only what these commits get wrong. Nothing in this section says what you should find or confirm."
blast_rule="The sessions and skills this change reaches, as the author grounded them before the review. Check the diff against each one; the grounding is the author's claim, not evidence."
risk_rule='The diff is cross-cutting: after the lines per documented step, one numbered line per risk under the Risks heading of the `## Blast radius` section above, in its order and numbered on from the last step, each naming the risk and saying what the diff does at that risk; a risk line is a walk line and counts nothing.'
has "$source_skill/SKILL.md" "$definition" "SKILL.md step 4 carries the definition"
has "$source_skill/SKILL.md" "$step_rule" "SKILL.md step 4 carries the step rule"
has "$source_skill/SKILL.md" "$spec_rule" "SKILL.md step 4 carries the spec rule"
has "$source_skill/SKILL.md" "$count_rule" "SKILL.md step 4 carries the count rule"
has "$source_skill/SKILL.md" "$settled_rule" "SKILL.md step 4 carries the settled paragraph"
has "$source_skill/SKILL.md" "$fix_rule" "SKILL.md step 4 carries the fix paragraph"
has "$source_skill/SKILL.md" "$blast_rule" "SKILL.md step 4 carries the blast-radius paragraph"
has "$source_skill/SKILL.md" "$risk_rule" "SKILL.md step 4 carries the risk sentence"
lacks "$source_skill/SKILL.md" "## Latent" "SKILL.md has no Latent heading"
for q in "${quotes[@]}"; do
  has "$source_skill/SKILL.md" "$q" "SKILL.md step 4 carries the quote"
done
for f in "$std" "$spec"; do
  has "$f" "$definition" "$f carries the definition"
  for q in "${quotes[@]}"; do
    has "$f" "$q" "$f carries the quote"
  done
  if [ "$(grep -nF -- "$definition" "$f" | cut -d: -f1)" -ne "$(($(grep -nF -- "${quotes[0]}" "$f" | cut -d: -f1) - 2))" ]; then
    echo "FAIL $f: the quotes do not follow the definition"; exit 1
  fi
  n=$((n + 1))
  has "$f" 'Write the report as Markdown with exactly these `## ` headings, in this order, each holding numbered items or nothing:' "$f names the shape"
  has "$f" '`1. **Title.** body`' "$f carries the item format"
  has "$f" "number the items continuously across the headings" "$f says how to number"
  has "$f" "$step_rule" "$f carries the step rule"
  has "$f" "$spec_rule" "$f carries the spec rule"
  has "$f" "$count_rule" "$f carries the count rule"
  # The spec rule one blank line after the step rule; the report path and the count rule follow it.
  if [ "$(grep -nF -- "$spec_rule" "$f" | cut -d: -f1)" -ne "$(($(grep -nF -- "$step_rule" "$f" | cut -d: -f1) + 2))" ]; then
    echo "FAIL $f: the spec rule does not follow the step rule"; exit 1
  fi
  n=$((n + 1))
  if [ "$(grep -nF -- "$count_rule" "$f" | cut -d: -f1)" -ne "$(($(grep -nF -- "$spec_rule" "$f" | cut -d: -f1) + 3))" ]; then
    echo "FAIL $f: the report path and the count rule do not follow the spec rule"; exit 1
  fi
  n=$((n + 1))
  has "$f" '- `## Fails open`' "$f has the Fails open heading"
  lacks "$f" "## Latent" "$f has no Latent heading"
  lacks "$f" "## Settled in earlier rounds" "$f has no settled section without a previous comment"
  lacks "$f" "## Blast radius" "$f has no blast-radius section for a diff that is not cross-cutting"
  # 9B: no grounding and not cross-cutting, the bullet as before.
  lacks "$f" "$risk_rule" "$f has no risk sentence for a diff that is not cross-cutting (9B)"
done
# The heading bullets of each Report paragraph, word for word in SKILL.md step 4 and in the brief.
standards_bullets=(
  '- `## Would break`: a breach of a documented standard that makes the documented path give a wrong or silent result. Cite the standard (file + the rule) and quote the hunk.'
  '- `## Fails open`: a breach of a documented standard that lets an input outside the documented path proceed silently. Cite the standard (file + the rule) and quote the hunk.'
  '- `## Standards breaches`: documented-standard breaches that do not change behavior. Cite the standard and quote the hunk.'
  '- `## Fix alongside`: baseline smells and other judgement calls. Name the smell and quote the hunk. They are fixed only when a would-break fix already touches that code; they never count.'
)
spec_bullets=(
  "- \`## Walk\`: one numbered line per documented step of the path the change touches (the ticket's criteria and the documentation the diff changes), each saying what the code does at that step. A walk, not findings: its lines are numbered 1..K on their own and count nothing."
  '- `## Would break`: a requirement missing, partial, or implemented so that the documented path gives a wrong or silent result.'
  '- `## Fails open`: an input outside the documented path that proceeds silently instead of being refused with a message saying how to correct it.'
  '- `## Not asked for`: behaviour in the diff the ticket did not ask for.'
)
for b in "${standards_bullets[@]}"; do
  has "$source_skill/SKILL.md" "$b" "SKILL.md step 4 carries the Standards bullet"
  has "$std" "$b" "Standards: the heading bullet"
done
for b in "${spec_bullets[@]}"; do
  has "$source_skill/SKILL.md" "$b" "SKILL.md step 4 carries the Spec bullet"
  has "$spec" "$b" "Spec: the heading bullet"
done
lacks "$std" '`## Walk`' "Standards: no walk"
[ "$(grep -o '^- `## [A-Za-z ]*`' "$spec" | head -1)" = '- `## Walk`' ] || { echo "FAIL Spec: the first heading bullet is not the walk"; exit 1; }
n=$((n + 1))
[ "$(grep -o '^- `## [A-Za-z ]*`' "$std" | head -2 | tail -1)" = '- `## Fails open`' ] || { echo "FAIL Standards: Fails open is not after Would break"; exit 1; }
n=$((n + 1))
has "$std" "Write your report to \`$(dirname "$std")/standards-report.md\` and reply with only that path." "Standards: the report path"
has "$spec" 'quotes the spec line it rests on in a fenced block (a criterion can carry `## ` or `1. ` lines, and only fenced text is exempt from the report shape)' "Spec: the quote is fenced"
has "$spec" "What to build: the ticket body" "Spec: the ticket body from gh"
has "$spec" "## Comments by the ticket's author (#7)" "Spec: the author's comments heading"
has "$spec" "### 2026-09-18" "Spec: a comment under its date"
has "$spec" "user: the count is Act on plus Ask." "Spec: the author's comment body"
lacks "$std" "## Comments by the ticket's author" "Standards: no ticket comments"
has "$spec" "Write your report to \`$(dirname "$spec")/spec-report.md\` and reply with only that path." "Spec: the report path"

# Ticket #90, criterion 2: a review with no spec (no ticket named, none in the commits) has no
# artifact a finding could rest on, so the Standards brief carries the step rule and not the spec
# rule, and the report path and the count rule follow the step rule directly.
bash "$skill/scripts/review-brief.sh" HEAD~1 > out.txt
printed out.txt "round: 1 of 3
.scratch/review/HEAD_1/standards-brief.md
no spec: Standards axis only" "no ticket: no spec"
has "$std" "$step_rule" "no spec: the Standards brief carries the step rule"
lacks "$std" "$spec_rule" "no spec: the Standards brief carries no spec rule"
if [ "$(grep -nF -- "$count_rule" "$std" | cut -d: -f1)" -ne "$(($(grep -nF -- "$step_rule" "$std" | cut -d: -f1) + 3))" ]; then
  echo "FAIL $std: with no spec, the report path and the count rule do not follow the step rule"; exit 1
fi
n=$((n + 1))

# A previous review comment: one cited Dismissed item, one uncited Dismissed item, one cited Noted item.
# The report above the judgment carries a quoted hunk whose lines are not items.
cat > previous.md <<'EOF'
The review found two things and I dismissed one of them. The hook stays in bash by decision.

## Standards

## Would break

1. **Hook in Python.** The hook is bash.

```sh
## Dismissed
1. **Not an item.** inside a fence. cites: DECISIONS.md P1
```

## Standards breaches

## Fix alongside

hard findings: 1

## Spec

no spec: Standards axis only

## Judgment

## Act on

## Ask

## Consider

## Noted

1. [S1] **Hook in Python.** A port is a later ticket. cites: #74 comment 2026-09-17

## Dismissed

2. [S2] **Whole DECISIONS.md is writable.** Provisional rows are the agent's to add. cites: DECISIONS.md P17
3. [S3] **Bare number.** The constant is named two lines up.

Standards: 1 would break of 3; Spec: no spec; judged: act on 0 (0 with a ticket), ask 0, consider 0, noted 1, dismissed 2; fixed point main.
round: 1 of 3
act-on items: 0
EOF
bash "$skill/scripts/review-brief.sh" HEAD~1 --ticket 7 --previous previous.md --round 2 > out.txt
printed out.txt "ticket: #7
round: 2 of 3
settled: carried 2, dropped 1 without a citation
.scratch/review/HEAD_1/standards-brief.md
.scratch/review/HEAD_1/spec-brief.md" "second round from --previous and --round"
[ "$(cat .scratch/review/HEAD_1/round)" = 2 ] || { echo "FAIL: the round file does not say 2"; exit 1; }
n=$((n + 1))
for f in "$std" "$spec"; do
  has "$f" "## Settled in earlier rounds" "$f has the settled section"
  has "$f" "$settled_rule" "$f carries the settled paragraph"
  has "$f" "1. [S1] **Hook in Python.** A port is a later ticket. cites: #74 comment 2026-09-17" "$f carries the cited Noted item"
  has "$f" "2. [S2] **Whole DECISIONS.md is writable.** Provisional rows are the agent's to add. cites: DECISIONS.md P17" "$f carries the cited Dismissed item"
  lacks "$f" "Bare number" "$f drops the uncited item"
  lacks "$f" "Not an item" "$f skips the fenced hunk"
done

# A comment posted from the GitHub web UI has CRLF line ends; the same items carry.
awk '{ printf "%s\r\n", $0 }' previous.md > previous-crlf.md
bash "$skill/scripts/review-brief.sh" HEAD~1 --ticket 7 --previous previous-crlf.md --round 3 > out.txt
has out.txt "settled: carried 2, dropped 1 without a citation" "CRLF previous comment carries the same items"
has "$std" "cites: DECISIONS.md P17" "CRLF previous comment: the cited item is in the brief"

# A cited item with a trailing space or tab still cites; the brief carries it without the whitespace.
awk '/cites: DECISIONS.md P17$/ { $0 = $0 " " } /cites: #74 comment 2026-09-17$/ { $0 = $0 "\t" } { print }' previous.md > previous-trailing.md
bash "$skill/scripts/review-brief.sh" HEAD~1 --ticket 7 --previous previous-trailing.md --round 2 > out.txt
has out.txt "settled: carried 2, dropped 1 without a citation" "trailing whitespace after the citation carries the same items"
has "$std" "2. [S2] **Whole DECISIONS.md is writable.** Provisional rows are the agent's to add. cites: DECISIONS.md P17" "trailing space: the item is in the brief without it"
has "$std" "1. [S1] **Hook in Python.** A port is a later ticket. cites: #74 comment 2026-09-17" "trailing tab: the item is in the brief without it"

# Ticket #110, row 5: a Provisional id is P<ticket> with an optional b-z sibling letter, and a cite of
# either carries; an off-form id is dropped.
for id in P110 P110b; do
  sed "s/DECISIONS.md P17\$/DECISIONS.md $id/" previous.md > "previous-$id.md"
  bash "$skill/scripts/review-brief.sh" HEAD~1 --ticket 7 --previous "previous-$id.md" --round 2 > out.txt
  has out.txt "settled: carried 2, dropped 1 without a citation" "cites: DECISIONS.md $id is counted as carried (5A, 5B)"
  has "$std" "2. [S2] **Whole DECISIONS.md is writable.** Provisional rows are the agent's to add. cites: DECISIONS.md $id" "cites: DECISIONS.md $id carries (5A, 5B)"
done
sed 's/DECISIONS.md P17$/DECISIONS.md P-110/' previous.md > previous-P-110.md
bash "$skill/scripts/review-brief.sh" HEAD~1 --ticket 7 --previous previous-P-110.md --round 2 > out.txt
has out.txt "settled: carried 1, dropped 2 without a citation" "cites: DECISIONS.md P-110 is counted as dropped (5C)"
lacks "$std" "cites: DECISIONS.md P-110" "cites: DECISIONS.md P-110 does not carry (5C)"

# The PR's earlier review comments, from gh: those by the PR's author that carry the count line.
# The round is one more than the highest `round: N of 3` among them; a comment from before the
# line existed is round 1. A comment rebuilt in the same round repeats its number and advances
# nothing; every comment's cited items carry, each line once.
grep -v '^round: ' previous.md > previous-unnumbered.md
pr me me:previous-unnumbered.md
bash "$skill/scripts/review-brief.sh" HEAD~1 --ticket 7 > out.txt
has out.txt "round: 2 of 3" "a comment without a round line is round 1, so the next is 2"
has out.txt "settled: carried 2, dropped 1 without a citation" "the comment without a round line carries its items"
# The rebuilt comment repeats round 1 and no longer holds the Noted item (settled, so not re-raised).
grep -v '^1\. \[S1\]' previous.md > previous-rebuilt.md
pr me me:previous.md me:previous-rebuilt.md
bash "$skill/scripts/review-brief.sh" HEAD~1 --ticket 7 > out.txt
printed out.txt "ticket: #7
round: 2 of 3
settled: carried 2, dropped 1 without a citation
.scratch/review/HEAD_1/standards-brief.md
.scratch/review/HEAD_1/spec-brief.md" "two comments both reading round 1 are round 1, so the next is 2, and their items carry once each"
[ "$(cat .scratch/review/HEAD_1/round)" = 2 ] || { echo "FAIL: the round file does not say 2 after a rebuilt comment"; exit 1; }
n=$((n + 1))
for f in "$std" "$spec"; do
  has "$f" "1. [S1] **Hook in Python.** A port is a later ticket. cites: #74 comment 2026-09-17" "$f carries the item only the first comment holds"
  has "$f" "2. [S2] **Whole DECISIONS.md is writable.** Provisional rows are the agent's to add. cites: DECISIONS.md P17" "$f carries the item both comments hold"
  [ "$(grep -cF 'cites: DECISIONS.md P17' "$f")" = 1 ] || { echo "FAIL: $f carries the item both comments hold twice"; exit 1; }
  n=$((n + 1))
done
# A comment by anyone but the PR's author is a stranger's text: it neither counts a round nor
# carries, whatever it holds.
sed 's/^round: 1 of 3$/round: 2 of 3/' previous.md > previous-2.md
sed 's/^round: 1 of 3$/round: 3 of 3/' previous.md > previous-3.md
awk '/^3\. \[S3\]/ { print "3. [S3] **Stranger'"'"'s item.** looks settled. cites: DECISIONS.md P1"; next } { print }' previous-2.md > stranger.md
pr me me:previous.md stranger:stranger.md
bash "$skill/scripts/review-brief.sh" HEAD~1 --ticket 7 > out.txt
has out.txt "round: 2 of 3" "a stranger's comment reading round 2 does not advance the round"
has out.txt "settled: carried 2, dropped 1 without a citation" "a stranger's cited item is not counted"
lacks "$std" "Stranger's item" "a stranger's cited item is not carried"
# Rounds 1, 2 and 3 were run: the fourth is refused before any state is written.
pr me me:previous.md me:previous-2.md me:previous-3.md
rm -rf .scratch .claude/state
set +e
out="$(bash "$skill/scripts/review-brief.sh" HEAD~1 --ticket 7 2>&1)"
code=$?
set -e
if [ "$code" != 1 ] || [ "$out" != 'review-brief: three rounds were run on this PR; the remaining Act on items are fixed here and marked `fixed: <sha>`, not reviewed in a fourth round' ] || [ -e .claude/state/review ] || [ -e .scratch/review ]; then
  echo "FAIL fourth round from the PR's comments: exit $code, wanted 1, the message and no state"
  echo "  got: $out"
  exit 1
fi
n=$((n + 1))
# --round overrides what the comments say.
bash "$skill/scripts/review-brief.sh" HEAD~1 --ticket 7 --round 3 > out.txt
has out.txt "round: 3 of 3" "--round overrides the round the comments give"
has out.txt "settled: carried 2, dropped 1 without a citation" "--round still carries the comments' items"

# Ticket #90, table A. A restart comment, one holding a line that is exactly `restart` outside
# fenced text, ends the history: the round and the settled items come from the comments after the
# last such comment, the script says so with a `restart:` line, and nothing before it carries, the
# restart comment's own cited items included. The old series cites P16 and a Ruby hook; the new
# series is previous.md and its rounds two and three.
restart_line="restart: the round and the settled items count from the last restart comment"
awk '/^round: 2 of 3$/ { print "restart" } { print }' previous-2.md > restart-2.md
sed 's/^round: 2 of 3$/round: 3 of 3/' restart-2.md > restart-3.md
sed 's/DECISIONS.md P17/DECISIONS.md P16/; s/Hook in Python/Hook in Ruby/' previous.md > old.md
awk '/^round: 1 of 3$/ { print "restart" } { print }' old.md > old-restart.md
sed 's/^round: 1 of 3$/round: 2 of 3/' old-restart.md > old-restart-2.md
# Rows 5 and 13: (1), (2 restart) is round one of the redesign, and the cited items of both
# comments are dropped.
pr me me:previous.md me:restart-2.md
bash "$skill/scripts/review-brief.sh" HEAD~1 --ticket 7 > out.txt
printed out.txt "ticket: #7
$restart_line
round: 1 of 3
.scratch/review/HEAD_1/standards-brief.md
.scratch/review/HEAD_1/spec-brief.md" "a restart comment in round 2: round 1, nothing carried (5A)"
[ "$(cat .scratch/review/HEAD_1/round)" = 1 ] || { echo "FAIL: the round file does not say 1 after a restart"; exit 1; }
n=$((n + 1))
for f in "$std" "$spec"; do
  lacks "$f" "## Settled in earlier rounds" "$f has no settled section after a restart"
  lacks "$f" "cites: DECISIONS.md P17" "$f drops the cited items of the restart comment and the one before it (row 13)"
done
bash "$skill/scripts/review-brief.sh" HEAD~1 --ticket 7 --round 2 > out.txt
printed out.txt "ticket: #7
$restart_line
round: 2 of 3
.scratch/review/HEAD_1/standards-brief.md
.scratch/review/HEAD_1/spec-brief.md" "a restart comment with --round 2 (5B)"
lacks "$std" "## Settled in earlier rounds" "--round after a restart carries nothing"
{ cat previous.md; printf '\036\n'; cat restart-2.md; } > both.md
bash "$skill/scripts/review-brief.sh" HEAD~1 --ticket 7 --previous both.md > out.txt
printed out.txt "ticket: #7
$restart_line
round: 1 of 3
.scratch/review/HEAD_1/standards-brief.md
.scratch/review/HEAD_1/spec-brief.md" "a restart comment from a --previous file holding both comments (5C)"
# Row 6: a restart in round three is round one, not the fourth-round refusal.
pr me me:previous.md me:previous-2.md me:restart-3.md
bash "$skill/scripts/review-brief.sh" HEAD~1 --ticket 7 > out.txt
printed out.txt "ticket: #7
$restart_line
round: 1 of 3
.scratch/review/HEAD_1/standards-brief.md
.scratch/review/HEAD_1/spec-brief.md" "a restart comment in round 3 is round 1, not refused (6A)"
lacks "$std" "## Settled in earlier rounds" "a restart in round 3 carries nothing"
# Row 7: three comments after the restart, and the new series' fourth round is refused before
# any state is written; --round 3 rebuilds round three from the new series alone.
pr me me:old.md me:old-restart-2.md me:previous.md me:previous-2.md me:previous-3.md
rm -rf .scratch .claude/state
set +e
out="$(bash "$skill/scripts/review-brief.sh" HEAD~1 --ticket 7 2>&1)"
code=$?
set -e
if [ "$code" != 1 ] || [ "$out" != 'review-brief: three rounds were run on this PR; the remaining Act on items are fixed here and marked `fixed: <sha>`, not reviewed in a fourth round' ] || [ -e .claude/state/review ] || [ -e .scratch/review ]; then
  echo "FAIL fourth round after a restart: exit $code, wanted 1, the message and no state (7A)"
  echo "  got: $out"
  exit 1
fi
n=$((n + 1))
bash "$skill/scripts/review-brief.sh" HEAD~1 --ticket 7 --round 3 > out.txt
printed out.txt "ticket: #7
$restart_line
round: 3 of 3
settled: carried 2, dropped 1 without a citation
.scratch/review/HEAD_1/standards-brief.md
.scratch/review/HEAD_1/spec-brief.md" "--round 3 after a restart carries the new series only (7B)"
has "$std" "cites: DECISIONS.md P17" "the new series' cited item carries after a restart"
lacks "$std" "DECISIONS.md P16" "the old series' cited item does not carry after a restart"
lacks "$std" "Hook in Ruby" "the old series' Noted item does not carry after a restart"
# Row 8: two restarts; the round and the settled items come from the comment after the last.
pr me me:old-restart.md me:old.md me:old-restart-2.md me:previous.md
bash "$skill/scripts/review-brief.sh" HEAD~1 --ticket 7 > out.txt
printed out.txt "ticket: #7
$restart_line
round: 2 of 3
settled: carried 2, dropped 1 without a citation
.scratch/review/HEAD_1/standards-brief.md
.scratch/review/HEAD_1/spec-brief.md" "two restarts: round two of the third series, its one comment carried (8A)"
lacks "$std" "DECISIONS.md P16" "two restarts: nothing before the last carries"
# Row 11: `restart` in prose, inside a fenced hunk or with trailing text is not a restart line.
awk '/^round: 2 of 3$/ { print "the writer asked for a restart"; print "```"; print "restart"; print "```"; print "restart: table 2/D" } { print }' previous-2.md > not-restart.md
pr me me:previous.md me:not-restart.md
bash "$skill/scripts/review-brief.sh" HEAD~1 --ticket 7 > out.txt
printed out.txt "ticket: #7
round: 3 of 3
settled: carried 2, dropped 1 without a citation
.scratch/review/HEAD_1/standards-brief.md
.scratch/review/HEAD_1/spec-brief.md" "restart in prose, in a fence or with trailing text is not a restart line (11A)"
# Row 12: a body with a `restart` line and no `act-on items:` line is not fetched, so the round
# does not reset; from --previous the file is trusted, so it is a restart comment.
grep -v '^act-on items:' restart-2.md > restart-uncounted.md
pr me me:previous.md me:previous-2.md me:restart-uncounted.md
bash "$skill/scripts/review-brief.sh" HEAD~1 --ticket 7 > out.txt
printed out.txt "ticket: #7
round: 3 of 3
settled: carried 2, dropped 1 without a citation
.scratch/review/HEAD_1/standards-brief.md
.scratch/review/HEAD_1/spec-brief.md" "a restart line without an act-on items line is not fetched (12A)"
bash "$skill/scripts/review-brief.sh" HEAD~1 --ticket 7 --previous restart-uncounted.md > out.txt
printed out.txt "ticket: #7
$restart_line
round: 1 of 3
.scratch/review/HEAD_1/standards-brief.md
.scratch/review/HEAD_1/spec-brief.md" "a restart line from a --previous file is trusted (12C)"
rm pr.json
# Rows 14 to 16: a Noted or Dismissed item citing a cell, a signature or a criterion of the ticket
# carries as settled, the line pasted verbatim in both briefs.
for cite in '#42 table 12/A' '#42 design overlap.sh N --diff' '#42 criterion 3'; do
  sed "s|^3\. \[S3\] \*\*Bare number\.\*\* The constant is named two lines up\.$|3. [S3] **Bare number.** The cell settles it. cites: $cite|" previous.md > cited.md
  bash "$skill/scripts/review-brief.sh" HEAD~1 --ticket 7 --previous cited.md --round 2 > out.txt
  has out.txt "settled: carried 3, dropped 0 without a citation" "cites: $cite carries"
  for f in "$std" "$spec"; do
    has "$f" "3. [S3] **Bare number.** The cell settles it. cites: $cite" "$f carries the item citing $cite"
  done
done
# Row 17: a malformed cite is dropped and counted as uncited.
awk '/^3\. \[S3\]/ { print "3. [S3] **Bare number.** cites: #42 cell 12A"; print "4. [S3] **Bare number.** cites: table 12/A"; print "5. [S3] **Bare number.** cites: #42 criterion 0"; print "6. [S3] **Bare number.** cites: #42 table 12/A trailing"; print "7. [S3] **Bare number.** cites: #42 table 12/A. The cell."; next } { print }' previous.md > malformed.md
bash "$skill/scripts/review-brief.sh" HEAD~1 --ticket 7 --previous malformed.md --round 2 > out.txt
has out.txt "settled: carried 2, dropped 5 without a citation" "five malformed cites are dropped and counted (17)"
lacks "$std" "cell 12A" "a malformed cite does not carry"

# The cited Dismissed item quotes a hunk whose lines look like cited items: a ``` line inside a
# ```` block, and a ~~~ block quoting a ``` line. A fence closes only on its own character at
# least as long (CommonMark), so the hunk stays fenced and the same items carry.
# quoting <label> <hunk>: previous.md with the hunk under the cited Dismissed item, round 2.
quoting() {
  { echo; printf '%s\n' "$2"; } > hunk.md
  sed '/cites: DECISIONS.md P17$/r hunk.md' previous.md > previous-quoting.md
  bash "$skill/scripts/review-brief.sh" HEAD~1 --ticket 7 --previous previous-quoting.md --round 2 > out.txt
  has out.txt "settled: carried 2, dropped 1 without a citation" "$1: the same items carry"
  for f in "$std" "$spec"; do
    has "$f" "1. [S1] **Hook in Python.** A port is a later ticket. cites: #74 comment 2026-09-17" "$1: $f carries the cited Noted item"
    has "$f" "2. [S2] **Whole DECISIONS.md is writable.** Provisional rows are the agent's to add. cites: DECISIONS.md P17" "$1: $f carries the cited Dismissed item"
    lacks "$f" "Still the hunk" "$1: $f skips the hunk's cited line"
    lacks "$f" "Bare number" "$1: $f drops the uncited item"
  done
}
quoting 'a ``` line inside a ```` block' '````md
## Noted
1. **Not an item.** the hunk is a judgment. cites: DECISIONS.md P1
```
2. **Still the hunk.** cites: DECISIONS.md P2
```
````'
quoting 'a ~~~ block quoting a ``` line' '~~~sh
## Noted
```
1. **Still the hunk.** cites: DECISIONS.md P2
~~~'
quoting 'a ```sh line inside a ``` block' '```
## Noted
```sh
1. **Still the hunk.** cites: DECISIONS.md P2
```'

# The fence rule is one awk fragment, the reference grammar one `ref=` line and the round cap one
# `cap=3;` line, each copied between the two scripts; the copies stay identical.
fragment() { sed -n "/^fenced='\$/,/^'\$/p; /^ref='/p; /^cap=3; /p" "$1"; }
[ -n "$(fragment "$skill/scripts/review-brief.sh")" ] || { echo "FAIL: review-brief.sh has no fenced='...' fragment"; exit 1; }
if [ "$(fragment "$skill/scripts/review-brief.sh")" != "$(fragment "$skill/scripts/review-comment.sh")" ]; then
  echo "FAIL: the fenced awk fragment or the ref line differs between review-brief.sh and review-comment.sh"; exit 1
fi
n=$((n + 1))
grep -q "^ref='" "$skill/scripts/review-brief.sh" || { echo "FAIL: review-brief.sh has no ref='...' line"; exit 1; }
n=$((n + 1))
grep -q "^cap=3; " "$skill/scripts/review-brief.sh" || { echo "FAIL: review-brief.sh has no cap=3; line"; exit 1; }
n=$((n + 1))

# A fourth round is refused before any state is written.
rm -rf .scratch .claude/state
set +e
out="$(bash "$skill/scripts/review-brief.sh" HEAD~1 --ticket 7 --round 4 2>&1)"
code=$?
set -e
if [ "$code" != 1 ] || [ "$out" != 'review-brief: three rounds were run on this PR; the remaining Act on items are fixed here and marked `fixed: <sha>`, not reviewed in a fourth round' ] || [ -e .claude/state/review ] || [ -e .scratch/review ]; then
  echo "FAIL fourth round: exit $code, wanted 1, the message and no state"
  echo "  got: $out"
  exit 1
fi
n=$((n + 1))

# Ticket #93, table A: a round past three. The history is written oldest first; (3W s) is a
# round-three comment carrying `would-break fixed after s`, s the commit round three reviewed, and
# the round after it reviews only the fix commits from s. Here s is the commit under review so
# far, and one fix commit follows it, so s..HEAD is that commit and HEAD~1 is s; a second fix
# commit lands before row 9, where s4 is the first. previous-3w.md is previous-3.md with a Spec
# report in place of the no-spec line, the Would-break item S1 moved from Noted to Act on as
# fixed, and the line; each assertion names its cell, row then column. The refusal strings are the
# contract's.
f4='review-brief: three rounds were run on this PR; the remaining Act on items are fixed here and marked `fixed: <sha>`, not reviewed in a fourth round'
f6="review-brief: five rounds were run on this PR; round five's Would-break fixes are the human's to review (spec-review step 5), not reviewed in a sixth round"
# f5 <round> <top>, fp <round> <sha> <fixed>, fm <rest>: the other refusals, filled in.
f5() { printf 'review-brief: round %s does not follow a review comment carrying `would-break fixed after <sha>` (the last review comment is round %s); a round past three reviews only such a fix, and the remaining Act on items are fixed here and marked `fixed: <sha>`' "$1" "$2"; }
fp() { printf 'review-brief: round %s reviews only the fix from %s, the commit round %s reviewed (the `would-break fixed after` line of the last review comment); %s is not that commit' "$1" "$2" "$(($1 - 1))" "$3"; }
fm() { printf 'review-brief: the last review comment carries `would-break fixed after %s`, which is not the line review-comment.sh writes (a 40-character commit id follows the words); post the comment the script printed' "$1"; }
# refused <label> <message> [arg ...]: the script with the args exits 1 with exactly that line and writes no state.
refused() {
  local label="$1" want="$2"; shift 2
  rm -rf .scratch .claude/state
  set +e
  out="$(bash "$skill/scripts/review-brief.sh" "$@" 2>&1)"
  code=$?
  set -e
  if [ "$code" != 1 ] || [ "$out" != "$want" ] || [ -e .claude/state/review ] || [ -e .scratch/review ]; then
    echo "FAIL $label: exit $code, wanted 1, the message and no state"
    echo "  got: $out"
    exit 1
  fi
  n=$((n + 1))
}
# fixed_section <file> <item> <label>: the brief carries the section, its paragraph and the item, before the diff.
fixed_section() {
  has "$1" "## The fix under review" "$3: the fix section"
  has "$1" "$fix_rule" "$3: the fix paragraph"
  has "$1" "$2" "$3: the fixed item"
  if [ "$(grep -n '^## The fix under review$' "$1" | cut -d: -f1)" -ge "$(grep -n '^## Diff$' "$1" | cut -d: -f1)" ]; then
    echo "FAIL $3: the fix section is not before the diff"; exit 1
  fi
  n=$((n + 1))
}
# only_commit <file> <subject> <label>: the brief's commit list is that one commit.
only_commit() {
  has "$1" "$2" "$3: the fix commit is listed"
  [ "$(sed -n '/^## Commits$/,/^## Changed files$/p' "$1" | grep -c '^[0-9a-f]\{7,\} ')" = 1 ] || { echo "FAIL $3: the commit list is not the one fix commit"; exit 1; }
  n=$((n + 1))
}
s="$(git rev-parse HEAD)"
echo three > a.txt
git commit -qam "fix the hook"
short="$(git rev-parse --short HEAD)"
# wb_comment <base> <sha> <reason> <fixed sha>: the base comment with S1 fixed under Act on and the line before its round line.
wb_comment() {
  awk -v s="$2" -v reason="$3" -v fixed="$4" '
    /^## Act on$/ { print; print ""; print "1. [S1] **Hook in Python.** " reason " fixed: " fixed; next }
    /^1\. \[S1\]/ { next }
    /^Standards: / { print "Standards: 1 would break of 3; Spec: 0 would break, 0 fail open, of 0; judged: act on 1 (1 fixed, 0 with a ticket), ask 0, consider 0, noted 0, dismissed 2; fixed point main."; next }
    /^round: / { print "would-break fixed after " s }
    { print }
  ' "$1"
}
awk '/^no spec: Standards axis only$/ { print "## Walk"; print ""; print "1. The hook runs at every prompt."; print ""; print "## Would break"; print ""; print "## Fails open"; print ""; print "## Not asked for"; print ""; print "hard findings: 0"; next } { print }' previous-3.md > previous-3-spec.md
wb_comment previous-3-spec.md "$s" "Ported." "$short" > previous-3w.md
wb_comment previous-3.md "$s" "Ported." "$short" > previous-3w-nospec.md
awk '/^round: 1 of 3$/ { print "would-break fixed after '"$s"'" } { print }' previous.md > previous-1w.md
sed 's/^round: 3 of 3$/round: 4 of 5/' previous-3.md > previous-4.md
sed 's/^round: 3 of 3$/round: 5 of 5/' previous-3.md > previous-5.md
sed 's/^round: 2 of 3$/round: 4 of 5/' restart-2.md > restart-4.md
std4=.scratch/review/$s/standards-brief.md
spec4=.scratch/review/$s/spec-brief.md
# Row 1: no comment; --round past three is refused, round five for want of the line, six as the cap.
refused "no comment, --round 5 (1B)" "$(f5 5 0)" HEAD~1 --ticket 7 --round 5
refused "no comment, --round 6 (1B)" "$f6" HEAD~1 --ticket 7 --round 6
# Row 2: three plain comments; --round 5 is refused for want of the line.
pr me me:previous.md me:previous-2.md me:previous-3.md
refused "three plain comments, --round 5 (2B)" "$(f5 5 3)" HEAD~1 --ticket 7 --round 5
# Row 3: (3W s) with the fixed point s is round four of five: the settled items of all three, the
# fix section in both briefs before the diff, the commit list the fix commit alone.
pr me me:previous.md me:previous-2.md me:previous-3w.md
bash "$skill/scripts/review-brief.sh" "$s" --ticket 7 > out.txt
printed out.txt "ticket: #7
round: 4 of 5
settled: carried 2, dropped 1 without a citation
.scratch/review/$s/standards-brief.md
.scratch/review/$s/spec-brief.md" "round four from the reviewed commit (3A)"
[ "$(cat ".scratch/review/$s/round")" = 4 ] || { echo "FAIL: the round file does not say 4 (3A)"; exit 1; }
n=$((n + 1))
for f in "$std4" "$spec4"; do
  fixed_section "$f" "1. [S1] **Hook in Python.** Ported. fixed: $short" "$f (3A)"
  has "$f" "cites: DECISIONS.md P17" "$f carries the settled items at round four (3A)"
done
only_commit "$std4" "fix the hook" "Standards (3A)"
lacks "$std4" "second, no ticket named" "Standards: the commit before s is not listed (3A)"
bash "$skill/scripts/review-brief.sh" "$s" --ticket 7 --round 4 > out.txt
has out.txt "round: 4 of 5" "--round 4 after (3W) is round four (3B)"
bash "$skill/scripts/review-brief.sh" "$s" --ticket 7 --round 3 > out.txt
printed out.txt "ticket: #7
round: 3 of 3
settled: carried 2, dropped 1 without a citation
.scratch/review/$s/standards-brief.md
.scratch/review/$s/spec-brief.md" "--round 3 after (3W) rebuilds round three (3B)"
lacks "$std4" "## The fix under review" "--round 3: no fix section (3B)"
refused "--round 5 after (3W) (3B)" "$(f5 5 3)" "$s" --ticket 7 --round 5
bash "$skill/scripts/review-brief.sh" "$s" --ticket 7 --previous previous-3w.md > out.txt
printed out.txt "ticket: #7
round: 4 of 5
settled: carried 1, dropped 1 without a citation
.scratch/review/$s/standards-brief.md
.scratch/review/$s/spec-brief.md" "round four from a --previous file holding (3W) (3C)"
fixed_section "$std4" "1. [S1] **Hook in Python.** Ported. fixed: $short" "Standards from --previous (3C)"
# Row 4: a fixed point that is not the reviewed commit is refused, whichever ref it is.
refused "the original fixed point at round four (4A)" "$(fp 4 "$s" HEAD~2)" HEAD~2 --ticket 7
refused "HEAD as the fixed point at round four (4A)" "$(fp 4 "$s" HEAD)" HEAD --ticket 7
# Row 5: the line names a commit this clone does not have.
sed "s/$s/0000000000000000000000000000000000000000/" previous-3w.md > previous-3w-gone.md
pr me me:previous.md me:previous-2.md me:previous-3w-gone.md
refused "the reviewed commit does not resolve (5A)" "review-brief: round 4 reviews only the fix from 0000000000000000000000000000000000000000, the commit round 3 reviewed, and that commit does not resolve here; fetch the PR's branch" "$s" --ticket 7
# Row 6: the fix commit names no ticket and round three had a spec: refused for --ticket.
pr me me:previous.md me:previous-2.md me:previous-3w.md
refused "a fix commit naming no ticket after a round with a spec (6A)" "review-brief: round 4 reviews only the fix and its commits name no ticket, while round 3 had a spec; pass --ticket N so the Spec axis reads the same spec" "$s"
# Row 7: the same with no spec at round three: the Standards axis alone, as today.
pr me me:previous.md me:previous-2.md me:previous-3w-nospec.md
bash "$skill/scripts/review-brief.sh" "$s" > out.txt
printed out.txt "round: 4 of 5
settled: carried 2, dropped 1 without a citation
.scratch/review/$s/standards-brief.md
no spec: Standards axis only" "round four with no spec (7A)"
fixed_section "$std4" "1. [S1] **Hook in Python.** Ported. fixed: $short" "Standards with no spec (7A)"
# Row 8: a round four without the line ends the review; nothing follows it.
pr me me:previous.md me:previous-2.md me:previous-3w.md me:previous-4.md
refused "a plain round four, the fifth (8A)" "$(f5 5 4)" "$s" --ticket 7
refused "a plain round four, --round 4 (8B)" "$(f5 4 4)" "$s" --ticket 7 --round 4
# Row 9: (4W t) with the fixed point t is round five, the fix section holding round four's item.
s4="$(git rev-parse HEAD)"
echo four > a.txt
git commit -qam "fix the hook again"
short4="$(git rev-parse --short HEAD)"
wb_comment previous-3-spec.md "$s4" "Ported again." "$short4" | sed 's/^round: 3 of 3$/round: 4 of 5/' > previous-4w.md
sed 's/^round: 4 of 5$/round: 5 of 5/' previous-4w.md > previous-5w.md
pr me me:previous.md me:previous-2.md me:previous-3w.md me:previous-4w.md
bash "$skill/scripts/review-brief.sh" "$s4" --ticket 7 > out.txt
printed out.txt "ticket: #7
round: 5 of 5
settled: carried 2, dropped 1 without a citation
.scratch/review/$s4/standards-brief.md
.scratch/review/$s4/spec-brief.md" "round five from the commit round four reviewed (9A)"
for f in ".scratch/review/$s4/standards-brief.md" ".scratch/review/$s4/spec-brief.md"; do
  fixed_section "$f" "1. [S1] **Hook in Python.** Ported again. fixed: $short4" "$f (9A)"
  lacks "$f" "Ported. fixed:" "$f: round three's fixed item is not in round five's section (9A)"
done
only_commit ".scratch/review/$s4/standards-brief.md" "fix the hook again" "Standards (9A)"
# Row 10: round five from any commit but the one round four reviewed is refused.
refused "round five from round three's commit (10A)" "$(fp 5 "$s4" "$s")" "$s" --ticket 7
# Row 11: a fifth comment, with or without the line, and --round 6: a sixth round is refused.
pr me me:previous.md me:previous-2.md me:previous-3w.md me:previous-4w.md me:previous-5.md
refused "a plain round five, the sixth (11A)" "$f6" "$s4" --ticket 7
pr me me:previous.md me:previous-2.md me:previous-3w.md me:previous-4w.md me:previous-5w.md
refused "a round five with the line, the sixth (11A)" "$f6" HEAD --ticket 7
refused "--round 6 (11B)" "$f6" "$s4" --ticket 7 --round 6
# Row 12: the line in a round-one comment changes nothing before round four.
pr me me:previous-1w.md
bash "$skill/scripts/review-brief.sh" HEAD~1 --ticket 7 > out.txt
printed out.txt "ticket: #7
round: 2 of 3
settled: carried 2, dropped 1 without a citation
.scratch/review/HEAD_1/standards-brief.md
.scratch/review/HEAD_1/spec-brief.md" "a Would-break fix at round one: round two from the original fixed point (12A)"
lacks "$std" "## The fix under review" "round two: no fix section (12A)"
# Row 13: a restart after (3W) wins; so does a --previous comment carrying both lines.
pr me me:previous.md me:previous-2.md me:previous-3w.md me:restart-4.md
bash "$skill/scripts/review-brief.sh" HEAD~1 --ticket 7 > out.txt
printed out.txt "ticket: #7
$restart_line
round: 1 of 3
.scratch/review/HEAD_1/standards-brief.md
.scratch/review/HEAD_1/spec-brief.md" "a restart comment after (3W) is round one (13A)"
lacks "$std" "## The fix under review" "round one after a restart: no fix section (13A)"
awk '/^would-break fixed after / { print "restart" } { print }' previous-3w.md > both-3w.md
bash "$skill/scripts/review-brief.sh" HEAD~1 --ticket 7 --previous both-3w.md > out.txt
printed out.txt "ticket: #7
$restart_line
round: 1 of 3
.scratch/review/HEAD_1/standards-brief.md
.scratch/review/HEAD_1/spec-brief.md" "a --previous comment carrying restart and the line is a restart (13C)"
# 13B: --round 2 after the restart, from the PR and from the --previous file: round two of the
# redesign, the whole diff.
pr me me:previous.md me:previous-2.md me:previous-3w.md me:restart-4.md
for src in pr both-3w.md; do
  if [ "$src" = pr ]; then prev=(); else prev=(--previous "$src"); fi
  bash "$skill/scripts/review-brief.sh" HEAD~1 --ticket 7 ${prev[@]+"${prev[@]}"} --round 2 > out.txt
  printed out.txt "ticket: #7
$restart_line
round: 2 of 3
.scratch/review/HEAD_1/standards-brief.md
.scratch/review/HEAD_1/spec-brief.md" "--round 2 after a restart that followed (3W), from $src (13B)"
  lacks "$std" "## The fix under review" "--round 2 after a restart, from $src: no fix section (13B)"
done
# Row 14: the words followed by anything but a full lowercase commit id: refused, shown as written.
for rest in "$(git rev-parse --short "$s")" "$(printf '%s' "$s" | tr a-f A-F)" "$s trailing" ""; do
  sed "s/^would-break fixed after .*/would-break fixed after $rest/" previous-3w.md > hand-3w.md
  pr me me:previous.md me:previous-2.md me:hand-3w.md
  refused "a hand-written line reading '$rest' (14A)" "$(fm "$rest")" "$s" --ticket 7
done
# Row 15: the line inside a fence, in a stranger's comment or in a comment before the deciding one is not the line.
awk '/^round: 3 of 3$/ { print "```"; print "would-break fixed after '"$s"'"; print "```" } { print }' previous-3.md > fenced-3.md
pr me me:previous.md me:previous-2.md me:fenced-3.md
refused "the line inside a fenced hunk (15A)" "$f4" "$s" --ticket 7
pr me me:previous.md me:previous-2.md me:previous-3.md stranger:previous-3w.md
refused "the line in a stranger's comment (15A)" "$f4" "$s" --ticket 7
wb_comment previous-2.md "$s" "Ported." "$short" > previous-2w.md
pr me me:previous.md me:previous-2w.md me:previous-3.md
refused "the line in round two with a plain round three after it (15A)" "$f4" "$s" --ticket 7
# Row 16: a CRLF copy of (3W) parses like the LF one.
awk '{ printf "%s\r\n", $0 }' previous-3w.md > previous-3w-crlf.md
bash "$skill/scripts/review-brief.sh" "$s" --ticket 7 --previous previous-3w-crlf.md > out.txt
printed out.txt "ticket: #7
round: 4 of 5
settled: carried 1, dropped 1 without a citation
.scratch/review/$s/standards-brief.md
.scratch/review/$s/spec-brief.md" "round four from a CRLF --previous file (16C)"
fixed_section "$std4" "1. [S1] **Hook in Python.** Ported. fixed: $short" "Standards from a CRLF file (16C)"
# Row 17: the sweep form has no fix-only round; its fixed point is the word paths.
pr me me:previous.md me:previous-2.md me:previous-3w.md
refused "the sweep form after (3W) (17A)" "$(fp 4 "$s" paths)" --paths a.txt --commits HEAD
# Row 18: the fix lane committed nothing: the empty-diff refusal, as today.
h="$(git rev-parse HEAD)"
sed "s/$s/$h/" previous-3w.md > previous-3w-head.md
pr me me:previous.md me:previous-2.md me:previous-3w-head.md
rm -rf .scratch .claude/state
set +e
out="$(bash "$skill/scripts/review-brief.sh" "$h" --ticket 7 2>&1)"
code=$?
set -e
if [ "$code" != 1 ] || [ "${out##*$'\n'}" != "review-brief: the diff is empty; nothing to review since $h" ] || [ -e .claude/state/review ] || [ -e ".scratch/review/$h" ]; then
  echo "FAIL round four with no fix commit (18A): exit $code, wanted 1, the empty-diff refusal and no state"
  echo "  got: $out"
  exit 1
fi
n=$((n + 1))
# Row 19: round three rebuilt; the last comment decides.
pr me me:previous.md me:previous-2.md me:previous-3.md me:previous-3w.md
bash "$skill/scripts/review-brief.sh" "$s" --ticket 7 > out.txt
printed out.txt "ticket: #7
round: 4 of 5
settled: carried 2, dropped 1 without a citation
.scratch/review/$s/standards-brief.md
.scratch/review/$s/spec-brief.md" "(3) then (3W): round four (19A)"
fixed_section "$std4" "1. [S1] **Hook in Python.** Ported. fixed: $short" "Standards after a rebuilt round three (19A)"
pr me me:previous.md me:previous-2.md me:previous-3w.md me:previous-3.md
refused "(3W) then (3): the fourth round refused (19A)" "$f4" "$s" --ticket 7
# Row 20: the sweep form records HEAD too.
rm pr.json
bash "$skill/scripts/review-brief.sh" --paths a.txt --commits HEAD --ticket 7 > out.txt
[ "$(cat ".scratch/review/sweep-$(git rev-parse --short HEAD)/reviewed")" = "$(git rev-parse HEAD)" ] || { echo "FAIL: the sweep form does not record HEAD in the reviewed file (20)"; exit 1; }
n=$((n + 1))
# Ticket #106, table A: round three reviews only round two's fix when round two's comment carries
# `fix only after <sha>`; rounds one and two print what they printed before the three new lines
# existed, and round two's brief writes the fix lines. r1 and r2 are the commits rounds one and two
# reviewed, one fix commit after each, so HEAD~2 is r1 (the fixed point o below), r1..HEAD the two
# fix commits and r2..HEAD the second alone. (1R) is previous.md with `reviewed: r1`, (1R+) the same
# with S1 fixed and the owed line, (2) previous-2.md, (2F) a round-two comment with a spec, one
# unmarked Act on item and one ticketed, and `fix only after r2`. Each assertion names its cell.
r1="$(git rev-parse HEAD)"
printf 'four\n  walk fixed\nok\n' > a.txt
git commit -qam "fix the walk, #7"
r2="$(git rev-parse HEAD)"
printf '  hook fixed\n  walk fixed\nok\n' > a.txt
git commit -qam "fix the hook, #7"
od=.scratch/review/HEAD_2
r2d=".scratch/review/$r2"
# The lines r1..HEAD adds or removes, four characters or more, less markers and surrounding blanks.
fix_lines='four
hook fixed
walk fixed'
awk -v r="reviewed: $r1" '/^round: 1 of 3$/ { print r } { print }' previous.md > previous-1r.md
awk -v f="$(git rev-parse --short "$r2")" '
  /^## Act on$/ { print; print ""; print "1. [S1] **Hook in Python.** Ported. fixed: " f; next }
  /^1\. \[S1\]/ { next }
  /^reviewed: / { print "next round owed: round 2 reviews the fixes marked here" }
  { print }' previous-1r.md > previous-1rp.md
cp previous-2.md previous-2r.md
# fo_comment <base> <sha>: the base as a round-two comment with S1 and S3 under Act on, S3 ticketed, and the FO line.
fo_comment() {
  sed 's/^round: 3 of 3$/round: 2 of 3/' "$1" | awk -v fo="fix only after $2" '
    /^## Act on$/ { print; print ""; print "1. [S1] **Hook in Python.** Ported."; print "2. [S3] **Bare number.** Out of scope. ticket: #12"; next }
    /^1\. \[S1\]/ || /^3\. \[S3\]/ { next }
    /^2\. \[S2\]/ { sub(/^2\./, "3.") }
    /^round: / { print fo }
    { print }'
}
fo_comment previous-3-spec.md "$r2" > previous-2f.md
fo_comment previous-2.md "$r2" > previous-2f-nospec.md
# ff <dir> <label>, no_ff <dir> <label>: the fix lines written exactly, or not written.
ff() {
  [ "$(cat "$1/fix-lines" 2>/dev/null)" = "$fix_lines" ] || { echo "FAIL $2: $1/fix-lines is not the lines r1..HEAD changed"; cat "$1/fix-lines" 2>/dev/null; exit 1; }
  n=$((n + 1))
}
no_ff() {
  [ ! -e "$1/fix-lines" ] || { echo "FAIL $2: $1/fix-lines was written"; exit 1; }
  n=$((n + 1))
}
# fp3 <sha> <fixed>: #93's FP naming the line round three reads.
fp3() { printf 'review-brief: round 3 reviews only the fix from %s, the commit round 2 reviewed (the `fix only after` line of the last review comment); %s is not that commit' "$1" "$2"; }
# same <label> <fixed-point> <login:file>...: the brief over the history with every RV, owed and FO
# line deleted, then over the history as written, prints the same stdout, diff, briefs and round
# (criterion 1). The state left is the run over the history as written.
same() {
  local label="$1" fp="$2" c d k f bare=(); shift 2
  for c in "$@"; do
    sed '/^reviewed: /d; /^fix only after /d; /^next round owed: /d' "${c#*:}" > "bare-${c#*:}"
    bare+=("${c%%:*}:bare-${c#*:}")
  done
  d=".scratch/review/$(printf '%s' "$fp" | tr -c 'A-Za-z0-9._-' '_')"
  for k in bare with; do
    if [ "$k" = bare ]; then pr me "${bare[@]}"; else pr me "$@"; fi
    bash "$skill/scripts/review-brief.sh" "$fp" --ticket 7 > "same-$k.out"
    for f in diff standards-brief.md spec-brief.md round; do cp "$d/$f" "same-$k.$f"; done
  done
  for f in out diff standards-brief.md spec-brief.md round; do
    cmp -s "same-bare.$f" "same-with.$f" || { echo "FAIL $label: $f differs from the run without the new lines"; diff "same-bare.$f" "same-with.$f"; exit 1; }
  done
  n=$((n + 1))
}
r1_out="ticket: #7
round: 1 of 3
$od/standards-brief.md
$od/spec-brief.md"
r2_out="ticket: #7
round: 2 of 3
settled: carried 2, dropped 1 without a citation
$od/standards-brief.md
$od/spec-brief.md"
r3_whole="ticket: #7
round: 3 of 3
settled: carried 2, dropped 1 without a citation
$od/standards-brief.md
$od/spec-brief.md"
r3_fix="ticket: #7
round: 3 of 3
settled: carried 3, dropped 1 without a citation
$r2d/standards-brief.md
$r2d/spec-brief.md"
# Row 1: no comment.
pr me
bash "$skill/scripts/review-brief.sh" HEAD~2 --ticket 7 > out.txt
printed out.txt "$r1_out" "no comment: round one (1A)"
no_ff "$od" "no comment (1A)"
bash "$skill/scripts/review-brief.sh" HEAD~2 --ticket 7 --round 2 > out.txt
printed out.txt "ticket: #7
round: 2 of 3
$od/standards-brief.md
$od/spec-brief.md" "no comment, --round 2 (1B)"
no_ff "$od" "no comment, --round 2 (1B)"
bash "$skill/scripts/review-brief.sh" HEAD~2 --ticket 7 --round 3 > out.txt
printed out.txt "ticket: #7
round: 3 of 3
$od/standards-brief.md
$od/spec-brief.md" "no comment, --round 3 (1B)"
lacks "$od/standards-brief.md" "## The fix under review" "no comment, --round 3: the whole diff (1B)"
: > empty.md
bash "$skill/scripts/review-brief.sh" HEAD~2 --ticket 7 --previous empty.md > out.txt
printed out.txt "$r1_out" "an empty --previous file (1C)"
no_ff "$od" "an empty --previous file (1C)"
# Row 2: (1R): round two, the whole diff, byte for byte what it was, and the fix lines from r1.
pr me me:previous-1r.md
bash "$skill/scripts/review-brief.sh" HEAD~2 --ticket 7 > out.txt
printed out.txt "$r2_out" "(1R): round two (2A)"
lacks "$od/standards-brief.md" "## The fix under review" "(1R): no fix section (2A)"
same "(1R) with and without the reviewed line (2A)" HEAD~2 me:previous-1r.md
ff "$od" "(1R) (2A)"
bash "$skill/scripts/review-brief.sh" HEAD~2 --ticket 7 --round 2 > out.txt
printed out.txt "$r2_out" "(1R), --round 2 (2B)"
ff "$od" "(1R), --round 2 (2B)"
bash "$skill/scripts/review-brief.sh" HEAD~2 --ticket 7 --round 3 > out.txt
printed out.txt "$r3_whole" "(1R), --round 3 (2B)"
no_ff "$od" "(1R), --round 3 (2B)"
bash "$skill/scripts/review-brief.sh" HEAD~2 --ticket 7 --previous previous-1r.md > out.txt
printed out.txt "$r2_out" "(1R) from --previous (2C)"
ff "$od" "(1R) from --previous (2C)"
# Row 3: (1R+): the owed line changes nothing in the brief.
r2p_out="ticket: #7
round: 2 of 3
settled: carried 1, dropped 1 without a citation
$od/standards-brief.md
$od/spec-brief.md"
pr me me:previous-1rp.md
bash "$skill/scripts/review-brief.sh" HEAD~2 --ticket 7 > out.txt
printed out.txt "$r2p_out" "(1R+): round two (3A)"
same "(1R+) with and without the owed and reviewed lines (3A)" HEAD~2 me:previous-1rp.md
ff "$od" "(1R+) (3A)"
bash "$skill/scripts/review-brief.sh" HEAD~2 --ticket 7 --round 2 > out.txt
ff "$od" "(1R+), --round 2 (3B)"
bash "$skill/scripts/review-brief.sh" HEAD~2 --ticket 7 --round 3 > out.txt
no_ff "$od" "(1R+), --round 3 (3B)"
bash "$skill/scripts/review-brief.sh" HEAD~2 --ticket 7 --previous previous-1rp.md > out.txt
printed out.txt "$r2p_out" "(1R+) from --previous (3C)"
ff "$od" "(1R+) from --previous (3C)"
# Row 4: (1R), (2): round three reviews the whole diff from o, as before.
pr me me:previous-1r.md me:previous-2r.md
bash "$skill/scripts/review-brief.sh" HEAD~2 --ticket 7 > out.txt
printed out.txt "$r3_whole" "(1R), (2): round three, the whole diff (4A)"
same "(1R), (2) with and without the reviewed line (4A)" HEAD~2 me:previous-1r.md me:previous-2r.md
lacks "$od/standards-brief.md" "## The fix under review" "(1R), (2): no fix section (4A)"
has "$od/standards-brief.md" "fix the walk, #7" "(1R), (2): round one's fix commit is listed (4A)"
has "$od/standards-brief.md" "fix the hook, #7" "(1R), (2): round two's fix commit is listed (4A)"
no_ff "$od" "(1R), (2) (4A)"
bash "$skill/scripts/review-brief.sh" HEAD~2 --ticket 7 --round 3 > out.txt
printed out.txt "$r3_whole" "(1R), (2), --round 3 (4B)"
{ cat previous-1r.md; printf '\036\n'; cat previous-2r.md; } > hist-4.md
bash "$skill/scripts/review-brief.sh" HEAD~2 --ticket 7 --previous hist-4.md > out.txt
printed out.txt "$r3_whole" "(1R), (2) from --previous (4C)"
# Row 5: (1R), (2F r2): round three reviews r2..HEAD alone, the unmarked Act on item in the fix section.
pr me me:previous-1r.md me:previous-2f.md
bash "$skill/scripts/review-brief.sh" "$r2" --ticket 7 > out.txt
printed out.txt "$r3_fix" "(1R), (2F): round three reviews the fix (5A)"
[ "$(cat "$r2d/round")" = 3 ] || { echo "FAIL: the round file does not say 3 (5A)"; exit 1; }
n=$((n + 1))
for f in "$r2d/standards-brief.md" "$r2d/spec-brief.md"; do
  fixed_section "$f" "1. [S1] **Hook in Python.** Ported." "$f (5A)"
  lacks "$f" "Out of scope. ticket: #12" "$f: the ticketed item is not in the fix section (5A)"
done
only_commit "$r2d/standards-brief.md" "fix the hook, #7" "Standards (5A)"
lacks "$r2d/standards-brief.md" "fix the walk" "Standards: round one's fix is not listed (5A)"
no_ff "$r2d" "(2F) (5A)"
bash "$skill/scripts/review-brief.sh" "$r2" --ticket 7 --round 3 > out.txt
printed out.txt "$r3_fix" "(1R), (2F), --round 3 (5B)"
fixed_section "$r2d/standards-brief.md" "1. [S1] **Hook in Python.** Ported." "--round 3 (5B)"
bash "$skill/scripts/review-brief.sh" "$r2" --ticket 7 --round 2 > out.txt
printed out.txt "ticket: #7
round: 2 of 3
settled: carried 3, dropped 1 without a citation
$r2d/standards-brief.md
$r2d/spec-brief.md" "(1R), (2F), --round 2 (5B)"
lacks "$r2d/standards-brief.md" "## The fix under review" "(1R), (2F), --round 2: no fix section (5B)"
no_ff "$r2d" "(1R), (2F), --round 2 (5B)"
refused "(1R), (2F), --round 4 (5B)" "$f4" "$r2" --ticket 7 --round 4
bash "$skill/scripts/review-brief.sh" "$r2" --ticket 7 --previous previous-2f.md > out.txt
printed out.txt "ticket: #7
round: 3 of 3
settled: carried 1, dropped 0 without a citation
$r2d/standards-brief.md
$r2d/spec-brief.md" "(2F) from --previous (5C)"
fixed_section "$r2d/standards-brief.md" "1. [S1] **Hook in Python.** Ported." "(2F) from --previous (5C)"
# Row 6: round two with no hard item carries the same line, so the brief is row 5's.
bash "$skill/scripts/review-brief.sh" "$r2" --ticket 7 > out.txt
printed out.txt "$r3_fix" "(2F) with no hard item is row 5 to the brief (6A)"
# Row 7: a fixed point that is not r2.
refused "(2F), the original fixed point (7A)" "$(fp3 "$r2" HEAD~2)" HEAD~2 --ticket 7
refused "(2F), HEAD as the fixed point (7A)" "$(fp3 "$r2" HEAD)" HEAD --ticket 7
refused "(2F), --round 3 from the original fixed point (7B)" "$(fp3 "$r2" HEAD~2)" HEAD~2 --ticket 7 --round 3
# Row 8: r2 does not resolve.
sed "s/$r2/0000000000000000000000000000000000000000/" previous-2f.md > previous-2f-gone.md
pr me me:previous-1r.md me:previous-2f-gone.md
refused "(2F) naming a commit this clone lacks (8A)" "review-brief: round 3 reviews only the fix from 0000000000000000000000000000000000000000, the commit round 2 reviewed, and that commit does not resolve here; fetch the PR's branch" "$r2" --ticket 7
# Row 9: a fix commit naming no ticket, on a branch of its own.
git switch -q -c no-ticket "$r2"
echo 'hook fixed, no ticket' > a.txt
git commit -qam "fix the hook"
pr me me:previous-1r.md me:previous-2f.md
refused "(2F) with a spec, no --ticket and a fix naming none (9A)" "review-brief: round 3 reviews only the fix and its commits name no ticket, while round 2 had a spec; pass --ticket N so the Spec axis reads the same spec" "$r2"
pr me me:previous-1r.md me:previous-2f-nospec.md
bash "$skill/scripts/review-brief.sh" "$r2" > out.txt
printed out.txt "round: 3 of 3
settled: carried 3, dropped 1 without a citation
$r2d/standards-brief.md
no spec: Standards axis only" "(2F) with no spec: the Standards axis alone (9A)"
fixed_section "$r2d/standards-brief.md" "1. [S1] **Hook in Python.** Ported." "(2F) with no spec (9A)"
git switch -q -
git branch -qD no-ticket
# Row 10: no commit after r2.
h="$(git rev-parse HEAD)"
sed "s/$r2/$h/" previous-2f.md > previous-2f-head.md
pr me me:previous-1r.md me:previous-2f-head.md
rm -rf .scratch .claude/state
set +e
out="$(bash "$skill/scripts/review-brief.sh" "$h" --ticket 7 2>&1)"
code=$?
set -e
if [ "$code" != 1 ] || [ "${out##*$'\n'}" != "review-brief: the diff is empty; nothing to review since $h" ] || [ -e .claude/state/review ] || [ -e ".scratch/review/$h" ]; then
  echo "FAIL round three with no fix commit (10A): exit $code, wanted 1, the empty-diff refusal and no state"
  echo "  got: $out"
  exit 1
fi
n=$((n + 1))
# Row 11: the sweep form has no fix-only round.
pr me me:previous-1r.md me:previous-2f.md
refused "the sweep form after (2F) (11A)" "$(fp3 "$r2" paths)" --paths a.txt --commits HEAD
# Row 12: the words not as the line: in a fence, from a stranger, before a rebuilt (2), with a
# short, uppercase or trailing-text sha, and bare.
awk '/^fix only after / { print "```"; print; print "```"; next } { print }' previous-2f.md > previous-2f-fenced.md
fo_comment previous-3-spec.md "$(git rev-parse --short "$r2")" > previous-2f-short.md
fo_comment previous-3-spec.md "$(printf '%s' "$r2" | tr a-f A-F)" > previous-2f-upper.md
fo_comment previous-3-spec.md "$r2 trailing" > previous-2f-trailing.md
fo_comment previous-3-spec.md "" > previous-2f-bare.md
for hist in "me:previous-2f-fenced.md" "me:previous-2r.md stranger:previous-2f.md" "me:previous-2f.md me:previous-2r.md" "me:previous-2f-short.md" "me:previous-2f-upper.md" "me:previous-2f-trailing.md" "me:previous-2f-bare.md"; do
  # shellcheck disable=SC2086 # the history is a list of login:file words
  pr me me:previous-1r.md $hist
  bash "$skill/scripts/review-brief.sh" HEAD~2 --ticket 7 > out.txt
  has out.txt "round: 3 of 3" "$hist is not the line: round three (12A)"
  lacks "$od/standards-brief.md" "## The fix under review" "$hist is not the line: the whole diff (12A)"
  # shellcheck disable=SC2086 # the history is a list of login:file words
  same "$hist is not the line: as today (12A)" HEAD~2 me:previous-1r.md $hist
done
# Row 13: the FO line on a round-one comment, and the RV line on a round-two one, are not read there.
awk -v fo="fix only after $r2" '/^round: 1 of 3$/ { print fo } { print }' previous.md > previous-1f.md
bash "$skill/scripts/review-brief.sh" HEAD~2 --ticket 7 --previous previous-1f.md > out.txt
printed out.txt "$r2_out" "(1F): round two (13A)"
no_ff "$od" "(1F) (13A)"
awk -v r="reviewed: $r1" '/^round: 2 of 3$/ { print r } { print }' previous-2.md > previous-2rv.md
pr me me:previous-1r.md me:previous-2rv.md
bash "$skill/scripts/review-brief.sh" HEAD~2 --ticket 7 > out.txt
printed out.txt "$r3_whole" "(1R), (2 with a reviewed line): round three, the whole diff (13A)"
lacks "$od/standards-brief.md" "## The fix under review" "(1R), (2 with a reviewed line): no fix section (13A)"
no_ff "$od" "(1R), (2 with a reviewed line) (13A)"
bash "$skill/scripts/review-brief.sh" HEAD~2 --ticket 7 --previous previous-1f.md --round 3 > out.txt
has out.txt "round: 3 of 3" "(1F), --round 3 (13B)"
lacks "$od/standards-brief.md" "## The fix under review" "(1F), --round 3: the whole diff (13B)"
# Row 14: a restart after (1R), and after (1R), (2F).
for hist in "me:restart-2.md" "me:previous-2f.md me:restart-3.md"; do
  # shellcheck disable=SC2086 # the history is a list of login:file words
  pr me me:previous-1r.md $hist
  bash "$skill/scripts/review-brief.sh" HEAD~2 --ticket 7 > out.txt
  printed out.txt "ticket: #7
$restart_line
round: 1 of 3
$od/standards-brief.md
$od/spec-brief.md" "(1R), $hist: round one of the redesign (14A)"
  no_ff "$od" "(1R), $hist (14A)"
  bash "$skill/scripts/review-brief.sh" HEAD~2 --ticket 7 --round 2 > out.txt
  printed out.txt "ticket: #7
$restart_line
round: 2 of 3
$od/standards-brief.md
$od/spec-brief.md" "(1R), $hist, --round 2 (14B)"
  no_ff "$od" "(1R), $hist, --round 2 (14B)"
done
# Rows 15 to 18: past a fix-only round three, #93's rounds, on a branch of their own. s3 is the
# commit round three reviewed and t the one round four reviewed.
git switch -q -c past-three
s3="$(git rev-parse HEAD)"
echo guarded >> a.txt
git commit -qam "guard the hook, #7"
short3="$(git rev-parse --short HEAD)"
wb_comment previous-3-spec.md "$s3" "Guarded." "$short3" > previous-3w-fo.md
pr me me:previous-1r.md me:previous-2f.md me:previous-3w-fo.md
bash "$skill/scripts/review-brief.sh" "$s3" --ticket 7 > out.txt
has out.txt "round: 4 of 5" "(3W s) after (2F): round four (15A)"
for f in ".scratch/review/$s3/standards-brief.md" ".scratch/review/$s3/spec-brief.md"; do
  fixed_section "$f" "1. [S1] **Hook in Python.** Guarded. fixed: $short3" "$f (15A)"
  lacks "$f" "1. [S1] **Hook in Python.** Ported." "$f: round two's unmarked item is not in round four's section (15A)"
done
only_commit ".scratch/review/$s3/standards-brief.md" "guard the hook, #7" "Standards (15A)"
bash "$skill/scripts/review-brief.sh" "$s3" --ticket 7 --round 3 > out.txt
has out.txt "round: 3 of 3" "(3W s) after (2F), --round 3 (15B)"
lacks ".scratch/review/$s3/standards-brief.md" "## The fix under review" "(3W s) after (2F), --round 3: no fix section (15B)"
refused "(3W s) after (2F), from r2 (16A)" "$(fp 4 "$s3" "$r2")" "$r2" --ticket 7
pr me me:previous-1r.md me:previous-2f.md me:previous-3.md
refused "a plain round three after (2F) (17A)" "$f4" "$s3" --ticket 7
refused "a plain round three after (2F), --round 5 (17B)" "$(f5 5 3)" "$s3" --ticket 7 --round 5
t="$(git rev-parse HEAD)"
echo "guarded again" >> a.txt
git commit -qam "guard the hook again, #7"
shortt="$(git rev-parse --short HEAD)"
wb_comment previous-3-spec.md "$t" "Guarded again." "$shortt" | sed 's/^round: 3 of 3$/round: 4 of 5/' > previous-4w-fo.md
pr me me:previous-1r.md me:previous-2f.md me:previous-3w-fo.md me:previous-4w-fo.md
bash "$skill/scripts/review-brief.sh" "$t" --ticket 7 > out.txt
has out.txt "round: 5 of 5" "(4W t) after (2F), (3W s): round five (18A)"
fixed_section ".scratch/review/$t/standards-brief.md" "1. [S1] **Hook in Python.** Guarded again. fixed: $shortt" "round five (18A)"
pr me me:previous-1r.md me:previous-2f.md me:previous-3w-fo.md me:previous-4w-fo.md me:previous-5.md
refused "a fifth comment after (2F): the sixth round (18A)" "$f6" "$t" --ticket 7
git switch -q -
git branch -qD past-three
# Row 19: histories from before this ticket.
pr me me:previous.md me:previous-2.md
bash "$skill/scripts/review-brief.sh" HEAD~2 --ticket 7 > out.txt
printed out.txt "$r3_whole" "(1), (2) from before the lines: round three, the whole diff (19A)"
lacks "$od/standards-brief.md" "## The fix under review" "(1), (2): no fix section (19A)"
no_ff "$od" "(1), (2) (19A)"
# Row 20: an old round-one comment, then (2F).
pr me me:previous.md me:previous-2f.md
bash "$skill/scripts/review-brief.sh" "$r2" --ticket 7 > out.txt
printed out.txt "$r3_fix" "(1), (2F): as row 5 (20A)"
fixed_section "$r2d/standards-brief.md" "1. [S1] **Hook in Python.** Ported." "(1), (2F) (20A)"
only_commit "$r2d/standards-brief.md" "fix the hook, #7" "(1), (2F) (20A)"
# Row 21: a CRLF copy of (2F).
awk '{ printf "%s\r\n", $0 }' previous-2f.md > previous-2f-crlf.md
bash "$skill/scripts/review-brief.sh" "$r2" --ticket 7 --previous previous-2f-crlf.md > out.txt
printed out.txt "ticket: #7
round: 3 of 3
settled: carried 1, dropped 0 without a citation
$r2d/standards-brief.md
$r2d/spec-brief.md" "a CRLF (2F) from --previous (21C)"
fixed_section "$r2d/standards-brief.md" "1. [S1] **Hook in Python.** Ported." "a CRLF (2F) (21C)"
# Row 22: the state each run writes.
pr me me:previous-1r.md
bash "$skill/scripts/review-brief.sh" HEAD~2 --ticket 7 > out.txt
ff "$od" "the fix lines after (1R) (22)"
[ "$(cat "$od/reviewed")" = "$(git rev-parse HEAD)" ] || { echo "FAIL: the reviewed file does not hold HEAD after (1R) (22)"; exit 1; }
n=$((n + 1))
awk -v r="reviewed: $(git commit-tree "HEAD^{tree}" -m elsewhere)" '/^round: 1 of 3$/ { print r } { print }' previous.md > previous-1r-elsewhere.md
pr me me:previous-1r-elsewhere.md
bash "$skill/scripts/review-brief.sh" HEAD~2 --ticket 7 > out.txt
no_ff "$od" "a reviewed commit that is not an ancestor of HEAD (22)"
sed "s/$r1/0000000000000000000000000000000000000000/" previous-1r.md > previous-1r-gone.md
pr me me:previous-1r-gone.md
bash "$skill/scripts/review-brief.sh" HEAD~2 --ticket 7 > out.txt
no_ff "$od" "a reviewed commit that does not resolve (22)"
pr me me:previous-1r.md me:previous-2f.md
refused "a refusal writes neither file (22)" "$(fp3 "$r2" HEAD~2)" HEAD~2 --ticket 7
rm pr.json
# The merge-ready sentence babysit reads, byte-identical in the playbook and the standalone skill.
babysit_rule='The review runs three rounds on one PR, five when round three or four fixed a Would-break item; a comment reading `round: 3 of 3`, `round: 4 of 5` or `round: 5 of 5` with `act-on items: 0` and no `would-break fixed after <sha>` line makes the PR review-ready even when the fix commits it names come after the reviewed commit. A comment carrying the line `would-break fixed after <sha>` is not review-ready whatever its count: below round five another round is owed and the orchestrator runs it (`spec-review` step 1 says its fixed point); at `round: 5 of 5` it is the human'"'"'s line, a wait like an `## Ask` item and not a blocker to fix here, until the human answers the report the orchestrator posted on the PR.'
has "$here/template/.agents/skills/poteto-mode/playbooks/babysit.md" "$babysit_rule" "the babysit playbook carries the merge-ready sentence"
has "$here/template/.agents/skills/babysit/SKILL.md" "$babysit_rule" "the babysit skill carries the merge-ready sentence"
# #106: the owed line's sentence, byte-identical in both babysit copies, and step 1's fix-only round three.
babysit_owed='A round-one or round-two comment carrying the line `next round owed: round <N> reviews the fixes marked here` is not review-ready whatever its count: the orchestrator runs that round (`spec-review` step 1); the lines `reviewed: <sha>` and `fix only after <sha>` only record where the next round starts and change nothing here.'
has "$here/template/.agents/skills/poteto-mode/playbooks/babysit.md" "$babysit_owed" "the babysit playbook carries the owed sentence (#106)"
has "$here/template/.agents/skills/babysit/SKILL.md" "$babysit_owed" "the babysit skill carries the owed sentence (#106)"
has "$source_skill/SKILL.md" 'Round three is fix-only too when round two'"'"'s comment carries `fix only after <sha>`' "SKILL.md step 1 says round three is fix-only after the line (#106)"

# Ticket #91, the scenario table: a cross-cutting diff's Spec brief continues its `## Walk` bullet,
# on the same line, with the risk sentence, and a grounding with no line outside fenced text that
# is exactly `## Risks` or `### Risks` is refused before any state is written. Each assertion below
# names its cell, row then column. The cross-cutting commit touches the hooks directory of this
# layout; blast.md is the blast-radius skill's bullet hand-back, with a leading blank line.
echo 'exit 0' > "$hooks/x.sh"
git add "$hooks/x.sh"
git commit -qm "a hook, #7"
cat > blast.md <<'EOF'

- **What it does.** Adds a hook that exits 0.
- **Risks.** `factory-start` at day zero runs it before any skill is installed: `.claude/hooks/x.sh:1`.
EOF
{ cat blast.md; printf '\n## Risks\n\n1. A subagent inherits it: `.claude/hooks/x.sh:1`.\n'; } > blast-risks.md
sed 's/^## Risks$/### Risks/' blast-risks.md > blast-risks-demoted.md
{ cat blast-risks.md; printf '\n### Risks\n\n2. The same risk, demoted.\n'; } > blast-both.md
{ cat blast.md; printf '\n## Risks\n'; } > blast-empty-risks.md
{ cat blast.md; printf '\n```md\n## Risks\n\n1. inside a fence\n```\n'; } > blast-fenced.md
# refused_risks <label> <where> [arg ...]: HEAD~1 with the args exits 1 with the ticket and round
# lines, then the refusal naming <where>, and writes no state and no briefs.
refused_risks() {
  local label="$1" where="$2"; shift 2
  rm -rf .scratch .claude/state
  set +e
  out="$(bash "$skill/scripts/review-brief.sh" HEAD~1 "$@" 2>&1)"
  code=$?
  set -e
  if [ "$code" != 1 ] || [ "$out" != "ticket: #7
round: 1 of 3
review-brief: the blast-radius grounding ($where) has no Risks heading outside fenced text; put the risks under a line that is exactly \`## Risks\` in the file, \`### Risks\` in the PR body, where the grounding's headings are demoted one level so the section stays intact" ] || [ -e .claude/state/review ] || [ -e .scratch/review/HEAD_1 ]; then
    echo "FAIL $label: exit $code, wanted 1, the refusal naming $where, no state and no briefs"
    echo "  got: $out"
    exit 1
  fi
  n=$((n + 1))
}
# 1A: --blast-radius FILE with `## Risks` and a numbered risk. Both briefs carry the grounding under
# `## Blast radius` before `## Diff`; the Spec brief's Walk bullet continues with the risk sentence
# on its own line; the Standards brief does not carry the sentence.
bash "$skill/scripts/review-brief.sh" HEAD~1 --blast-radius blast-risks.md > out.txt 2> err.txt
printed out.txt "ticket: #7
round: 1 of 3
.scratch/review/HEAD_1/standards-brief.md
.scratch/review/HEAD_1/spec-brief.md" "cross-cutting diff with --blast-radius (1A)"
[ ! -s err.txt ] || { echo "FAIL cross-cutting diff with --blast-radius (1A): stderr is not empty:"; cat err.txt; exit 1; }
n=$((n + 1))
for f in "$std" "$spec"; do
  has "$f" "## Blast radius" "$f has the blast-radius section (1A)"
  has "$f" "$blast_rule" "$f carries the blast-radius paragraph (1A)"
  has "$f" '- **Risks.** `factory-start` at day zero runs it before any skill is installed: `.claude/hooks/x.sh:1`.' "$f carries the grounding text (1A)"
  has "$f" '1. A subagent inherits it: `.claude/hooks/x.sh:1`.' "$f carries the numbered risk (1A)"
  if [ "$(grep -n '^## Blast radius$' "$f" | cut -d: -f1)" -ge "$(grep -n '^## Diff$' "$f" | cut -d: -f1)" ]; then
    echo "FAIL $f: the blast-radius section is not before the diff (1A)"; exit 1
  fi
  n=$((n + 1))
done
has "$spec" "${spec_bullets[0]} $risk_rule" "Spec: the Walk bullet continues with the risk sentence (1A)"
lacks "$std" "$risk_rule" "Standards: no risk sentence (1A)"
# 2A: `### Risks` in the file gives the same bullet; the source restricts no level.
bash "$skill/scripts/review-brief.sh" HEAD~1 --blast-radius blast-risks-demoted.md > out.txt
has "$spec" "${spec_bullets[0]} $risk_rule" "Spec: a file with ### Risks continues the Walk bullet (2A)"
# 7A: both levels; the first unfenced one satisfies the check.
bash "$skill/scripts/review-brief.sh" HEAD~1 --blast-radius blast-both.md > out.txt
has "$spec" "${spec_bullets[0]} $risk_rule" "Spec: a file with ## Risks then ### Risks continues the Walk bullet (7A)"
# 8A: a Risks heading with no numbered line under it gives the same bullet.
bash "$skill/scripts/review-brief.sh" HEAD~1 --blast-radius blast-empty-risks.md > out.txt
has "$spec" "${spec_bullets[0]} $risk_rule" "Spec: a Risks heading with nothing under it continues the Walk bullet (8A)"
# 5A: the bullet hand-back, no Risks heading: refused naming the file.
refused_risks "no Risks heading in the file (5A)" blast.md --blast-radius blast.md
# 6A: the only Risks heading inside a fenced block: refused the same way.
refused_risks "the only Risks heading inside a fence (6A)" blast-fenced.md --blast-radius blast-fenced.md

# 9A: no --blast-radius and no PR is refused as before, naming the path, before any state is written.
rm -rf .scratch .claude/state
set +e
out="$(bash "$skill/scripts/review-brief.sh" HEAD~1 2>&1)"
code=$?
set -e
if [ "$code" != 1 ] || [ "$out" != "ticket: #7
round: 1 of 3
review-brief: cross-cutting diff ($hooks/x.sh) without a blast-radius grounding; run the blast-radius skill, put the result in the PR body's Blast Radius section or pass --blast-radius FILE" ] || [ -e .claude/state/review ] || [ -e .scratch/review/HEAD_1 ]; then
  echo "FAIL cross-cutting diff without a grounding (9A): exit $code, wanted 1, the message, no state and no briefs"
  echo "  got: $out"
  exit 1
fi
n=$((n + 1))

# 3A: with a PR, the grounding is the body's `## Blast Radius` section with its headings demoted:
# CRLF line ends, a fenced `## ` line kept inside it, `### Risks` inside it, and the next heading
# ending it. The Spec brief's Walk bullet continues with the risk sentence; the Standards brief's does not.
printf '## Why\r\n\r\nA hook.\r\n\r\n## Blast Radius\r\n\r\n- **Risks.** a subagent inherits it: `.claude/hooks/x.sh:1`.\r\n\r\n### Risks\r\n\r\n1. a subagent inherits it: `.claude/hooks/x.sh:1`.\r\n\r\n```sh\r\n## not a heading, part of the proof\r\n```\r\n\r\n## Verification\r\n\r\nran it\r\n' > pr-body.md
FAKE_PR_BODY="$fx/pr-body.md" bash "$skill/scripts/review-brief.sh" HEAD~1 > out.txt
for f in "$std" "$spec"; do
  has "$f" '- **Risks.** a subagent inherits it: `.claude/hooks/x.sh:1`.' "$f carries the PR body's section (3A)"
  has "$f" "### Risks" "$f carries the section's demoted Risks heading (3A)"
  has "$f" "## not a heading, part of the proof" "$f keeps the fenced line of the section (3A)"
  lacks "$f" "ran it" "$f stops the section at the next heading (3A)"
  lacks "$f" "A hook." "$f starts the section at its heading (3A)"
done
has "$spec" "${spec_bullets[0]} $risk_rule" "Spec: the PR body's ### Risks continues the Walk bullet (3A)"
lacks "$std" "$risk_rule" "Standards: no risk sentence from a PR body (3A)"
# 4A: a body whose headings were not demoted ends its section at the first inner `## ` line. Nothing
# before that line is the empty section, refused like a missing grounding; prose before it is
# refused naming the body.
printf '## Why\n\nA hook.\n\n## Blast Radius\n\n## Verification\n\nran it\n' > pr-body-empty.md
rm -rf .scratch .claude/state
set +e
out="$(FAKE_PR_BODY="$fx/pr-body-empty.md" bash "$skill/scripts/review-brief.sh" HEAD~1 2>&1)"
code=$?
set -e
if [ "$code" != 1 ] || ! printf '%s' "$out" | grep -qF "cross-cutting diff ($hooks/x.sh) without a blast-radius grounding" || [ -e .claude/state/review ]; then
  echo "FAIL empty Blast Radius section (4A, nothing before the inner heading): exit $code, wanted 1 with the refusal and no state"
  echo "  got: $out"
  exit 1
fi
n=$((n + 1))
printf '## Why\n\nA hook.\n\n## Blast Radius\n\n- **What it does.** Adds a hook that exits 0.\n\n## Risks\n\n1. a subagent inherits it: `.claude/hooks/x.sh:1`.\n\n## Verification\n\nran it\n' > pr-body-undemoted.md
export FAKE_PR_BODY="$fx/pr-body-undemoted.md"
refused_risks "undemoted headings in the PR body (4A, prose before the inner heading)" "the PR body's Blast Radius section"
unset FAKE_PR_BODY
# 10: --blast-radius naming no file is the usage block, before anything runs.
rm -rf .scratch .claude/state
set +e
out="$(bash "$skill/scripts/review-brief.sh" HEAD~1 --blast-radius missing.md 2>&1)"
code=$?
set -e
if [ "$code" != 1 ] || [ "$out" != "usage: review-brief.sh <fixed-point> [--ticket N] [--standards FILE ...] [--previous FILE] [--round N] [--blast-radius FILE]
       review-brief.sh --paths P... --commits SHA... [--ticket N] [--standards FILE ...] [--blast-radius FILE]" ] || [ -e .claude/state/review ] || [ -e .scratch/review ]; then
  echo "FAIL --blast-radius naming no file (10): exit $code, wanted 1, the usage block and no state"
  echo "  got: $out"
  exit 1
fi
n=$((n + 1))

# 1B: a diff that is not cross-cutting ignores --blast-radius, says so on stderr, and neither brief
# carries the grounding or the risk sentence.
echo readme > README.md
git add README.md
git commit -qm "a readme, #7"
bash "$skill/scripts/review-brief.sh" HEAD~1 --blast-radius blast-risks.md > out.txt 2> err.txt
printed err.txt "review-brief: the diff is not cross-cutting; blast-risks.md is not pasted" "README-only diff with --blast-radius (1B)"
for f in "$std" "$spec"; do
  lacks "$f" "## Blast radius" "$f has no blast-radius section for a README-only diff (1B)"
  lacks "$f" "Adds a hook that exits 0" "$f does not carry the ignored file (1B)"
  lacks "$f" "$risk_rule" "$f has no risk sentence for a README-only diff (1B)"
done
# 3B: the same diff with a PR whose body holds the section: the body is never fetched.
FAKE_PR_BODY="$fx/pr-body.md" bash "$skill/scripts/review-brief.sh" HEAD~1 > out.txt 2> err.txt
[ ! -s err.txt ] || { echo "FAIL README-only diff with a PR body (3B): stderr is not empty:"; cat err.txt; exit 1; }
n=$((n + 1))
for f in "$std" "$spec"; do
  lacks "$f" "## Blast radius" "$f has no blast-radius section for a README-only diff with a PR (3B)"
  lacks "$f" "a subagent inherits it" "$f does not carry the PR body's section (3B)"
  lacks "$f" "$risk_rule" "$f has no risk sentence for a README-only diff with a PR (3B)"
done
}

suite project
suite factory
echo "ok $n assertions"
