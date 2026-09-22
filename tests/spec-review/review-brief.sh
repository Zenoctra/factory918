#!/usr/bin/env bash
# Runs review-brief.sh twice, in a temp repo laid out as a project and in one laid out as the
# factory (tests/spec-review/layout.sh), each time the copy of the skill that repo holds, and
# asserts that each brief carries the report shape review-comment.sh enforces: the definition
# sentence, Manuel's five sentences, every heading name, the item format, the step rule and the
# count rule. The fake gh (tests/spec-review/fake-gh.sh) on PATH supplies the ticket body and the
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
# row and column. The source SKILL.md, step 4, must carry the definition, the five sentences, the
# heading bullets, the step rule, the spec rule, the count rule, the settled paragraph, the
# blast-radius paragraph and the risk sentence word for word, so the skill and the script cannot
# drift apart. Exits 1 on the first miss.
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
blast_rule="The sessions and skills this change reaches, as the author grounded them before the review. Check the diff against each one; the grounding is the author's claim, not evidence."
risk_rule='The diff is cross-cutting: after the lines per documented step, one numbered line per risk under the Risks heading of the `## Blast radius` section above, in its order and numbered on from the last step, each naming the risk and saying what the diff does at that risk; a risk line is a walk line and counts nothing.'
has "$source_skill/SKILL.md" "$definition" "SKILL.md step 4 carries the definition"
has "$source_skill/SKILL.md" "$step_rule" "SKILL.md step 4 carries the step rule"
has "$source_skill/SKILL.md" "$spec_rule" "SKILL.md step 4 carries the spec rule"
has "$source_skill/SKILL.md" "$count_rule" "SKILL.md step 4 carries the count rule"
has "$source_skill/SKILL.md" "$settled_rule" "SKILL.md step 4 carries the settled paragraph"
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

# The fence rule is one awk fragment and the reference grammar one `ref=` line, each copied
# between the two scripts; the copies stay identical.
fragment() { sed -n "/^fenced='\$/,/^'\$/p; /^ref='/p" "$1"; }
[ -n "$(fragment "$skill/scripts/review-brief.sh")" ] || { echo "FAIL: review-brief.sh has no fenced='...' fragment"; exit 1; }
if [ "$(fragment "$skill/scripts/review-brief.sh")" != "$(fragment "$skill/scripts/review-comment.sh")" ]; then
  echo "FAIL: the fenced awk fragment or the ref line differs between review-brief.sh and review-comment.sh"; exit 1
fi
n=$((n + 1))
grep -q "^ref='" "$skill/scripts/review-brief.sh" || { echo "FAIL: review-brief.sh has no ref='...' line"; exit 1; }
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
