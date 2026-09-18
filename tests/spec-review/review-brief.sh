#!/usr/bin/env bash
# Runs template/.agents/skills/spec-review/scripts/review-brief.sh in a temp repo and asserts that
# each brief carries the report shape review-comment.sh enforces: the definition sentence, every
# heading name, the item format and the count rule. A fake gh on PATH supplies the ticket body and
# the ticket's comments, and the PR's earlier review comments when a fixture file names them (no
# PR otherwise), so the Spec brief is written and the round is 1 unless the comments or --round say
# otherwise. Only the judgment items that cite a decision carry into both briefs, from every earlier
# comment, each line once; the round is one more than the highest `round: N of 3` among the comments,
# so a rebuilt comment does not advance it; a fourth round is refused before any state is written;
# a gh failure other than "no pull requests found" is printed and the run goes on. A diff touching
# a cross-cutting path is briefed with its blast-radius grounding (--blast-radius FILE, else the PR
# body's section) before the diff, and refused without one. SKILL.md step 4 must carry the
# definition, the settled paragraph and the blast-radius paragraph word for word, so the skill and
# the script cannot drift apart. Exits 1 on the first miss.
set -euo pipefail
here="$(cd "$(dirname "$0")/../.." && pwd -P)"
skill="$here/template/.agents/skills/spec-review"
fx="$(mktemp -d)"
trap 'rm -rf "$fx"' EXIT
cd "$fx"
git init -q
git config user.email test@factory918.invalid
git config user.name test
echo one > a.txt
git add a.txt
git commit -qm "first"
echo two > a.txt
git commit -qam "second, no ticket named"
mkdir bin
# gh pr view --json body: the PR body is the file FAKE_PR_BODY names when set, else there is no PR.
# gh pr view for the comments: pr.json, when it exists, is the PR (its author and comments) and
# the script's own jq expression runs against it through jq, so the author filter is what is
# tested; pr-error, when it exists, goes to stderr with exit 1; with neither there is no PR for
# this branch. gh issue view: the body, or the author's comments already formatted the way the
# script's jq expression formats them (one is by someone else and is left out).
command -v jq >/dev/null || { echo "FAIL: jq is needed to play gh pr view"; exit 1; }
{
  echo '#!/bin/sh'
  echo "fx='$fx'"
  cat <<'EOF'
case "$*" in
  "pr view --json body"*) [ -f "${FAKE_PR_BODY:-}" ] && cat "$FAKE_PR_BODY" || { echo 'no pull requests found for branch "x"' >&2; exit 1; } ;;
  "pr view"*)
    if [ -f "$fx/pr-error" ]; then cat "$fx/pr-error" >&2; exit 1; fi
    if [ -f "$fx/pr.json" ]; then
      while [ "$1" != -q ]; do shift; done
      exec jq -r "$2" "$fx/pr.json"
    fi
    echo 'no pull requests found for branch "x"' >&2; exit 1 ;;
  *"--json body"*) echo "What to build: the ticket body" ;;
  *"--json author,comments"*) printf '### 2026-09-17\n\nuser: the hook stays in bash.\n\n### 2026-09-18\n\nuser: the count is Act on plus Ask.\n\n' ;;
  *) echo "fake gh: unexpected args: $*" >&2; exit 2 ;;
esac
EOF
} > bin/gh
chmod +x bin/gh
PATH="$fx/bin:$PATH"
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

bash "$skill/scripts/review-brief.sh" HEAD~1 --ticket 7 > out.txt 2> err.txt
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

# Any other gh failure is printed, and the run goes on as round 1 with nothing carried.
echo "HTTP 401: Bad credentials (https://api.github.com/graphql)" > pr-error
bash "$skill/scripts/review-brief.sh" HEAD~1 --ticket 7 > out.txt 2> err.txt
rm pr-error
has err.txt "review-brief: gh could not read the PR's review comments (HTTP 401: Bad credentials (https://api.github.com/graphql))" "a gh failure other than no PR is printed"
has out.txt "round: 1 of 3" "a gh failure other than no PR still runs round 1"
lacks "$std" "## Settled in earlier rounds" "a gh failure other than no PR carries nothing"

definition="A hard finding is wrong behavior in normal use: a command, hook, script or documented flow does something other than what the ticket or its own documentation says it does, on the path a user takes."
count_rule='End the report with exactly one line `hard findings: N`, where N is the number of items under `## Would break` and nothing else.'
settled_rule="These findings were raised in an earlier round and settled by the decision each one cites. Do not raise them again. Nothing in this section says what you should find or confirm."
blast_rule="The sessions and skills this change reaches, as the author grounded them before the review. Check the diff against each one; the grounding is the author's claim, not evidence."
has "$skill/SKILL.md" "$definition" "SKILL.md step 4 carries the definition"
has "$skill/SKILL.md" "$settled_rule" "SKILL.md step 4 carries the settled paragraph"
has "$skill/SKILL.md" "$blast_rule" "SKILL.md step 4 carries the blast-radius paragraph"
for f in "$std" "$spec"; do
  has "$f" "$definition" "$f carries the definition"
  has "$f" 'Write the report as Markdown with exactly these `## ` headings, in this order, each holding numbered items or nothing:' "$f names the shape"
  has "$f" '`1. **Title.** body`' "$f carries the item format"
  has "$f" "number the items continuously across the headings" "$f says how to number"
  has "$f" "$count_rule" "$f carries the count rule"
  lacks "$f" "## Settled in earlier rounds" "$f has no settled section without a previous comment"
  lacks "$f" "## Blast radius" "$f has no blast-radius section for a diff that is not cross-cutting"
done
# The three heading bullets of each Report paragraph, word for word in SKILL.md step 4 and in the brief.
standards_bullets=(
  '- `## Would break`: a breach of a documented standard that produces wrong behavior in normal use. Cite the standard (file + the rule) and quote the hunk.'
  '- `## Standards breaches`: documented-standard breaches that do not change behavior. Cite the standard and quote the hunk.'
  '- `## Fix alongside`: baseline smells and other judgement calls. Name the smell and quote the hunk. They are fixed only when a would-break fix already touches that code; they never count.'
)
spec_bullets=(
  '- `## Would break`: a requirement missing, partial, or implemented so that normal use does something other than the ticket says.'
  '- `## Latent`: edge cases, visibility, policy, wording; anything a user would not hit in normal use.'
  '- `## Not asked for`: behaviour in the diff the ticket did not ask for.'
)
for b in "${standards_bullets[@]}"; do
  has "$skill/SKILL.md" "$b" "SKILL.md step 4 carries the Standards bullet"
  has "$std" "$b" "Standards: the heading bullet"
done
for b in "${spec_bullets[@]}"; do
  has "$skill/SKILL.md" "$b" "SKILL.md step 4 carries the Spec bullet"
  has "$spec" "$b" "Spec: the heading bullet"
done
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
rm -rf .scratch .claude
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
rm pr.json

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

# The fence rule is one awk fragment, copied between the two scripts; the copies stay identical.
fragment() { sed -n "/^fenced='\$/,/^'\$/p" "$1"; }
[ -n "$(fragment "$skill/scripts/review-brief.sh")" ] || { echo "FAIL: review-brief.sh has no fenced='...' fragment"; exit 1; }
if [ "$(fragment "$skill/scripts/review-brief.sh")" != "$(fragment "$skill/scripts/review-comment.sh")" ]; then
  echo "FAIL: the fenced awk fragment differs between review-brief.sh and review-comment.sh"; exit 1
fi
n=$((n + 1))

# A fourth round is refused before any state is written.
rm -rf .scratch .claude
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

# A cross-cutting diff: a commit touching .claude/hooks/x.sh. With --blast-radius FILE the file's text
# goes into both briefs under `## Blast radius`, before `## Diff`.
mkdir -p .claude/hooks
echo 'exit 0' > .claude/hooks/x.sh
git add .claude/hooks/x.sh
git commit -qm "a hook, #7"
cat > blast.md <<'EOF'

- **What it does.** Adds a hook that exits 0.
- **Risks.** `factory-start` at day zero runs it before any skill is installed: `.claude/hooks/x.sh:1`.
EOF
bash "$skill/scripts/review-brief.sh" HEAD~1 --blast-radius blast.md > out.txt 2> err.txt
printed out.txt "ticket: #7
round: 1 of 3
.scratch/review/HEAD_1/standards-brief.md
.scratch/review/HEAD_1/spec-brief.md" "cross-cutting diff with --blast-radius"
[ ! -s err.txt ] || { echo "FAIL cross-cutting diff with --blast-radius: stderr is not empty:"; cat err.txt; exit 1; }
n=$((n + 1))
for f in "$std" "$spec"; do
  has "$f" "## Blast radius" "$f has the blast-radius section"
  has "$f" "$blast_rule" "$f carries the blast-radius paragraph"
  has "$f" '- **Risks.** `factory-start` at day zero runs it before any skill is installed: `.claude/hooks/x.sh:1`.' "$f carries the grounding text"
  if [ "$(grep -n '^## Blast radius$' "$f" | cut -d: -f1)" -ge "$(grep -n '^## Diff$' "$f" | cut -d: -f1)" ]; then
    echo "FAIL $f: the blast-radius section is not before the diff"; exit 1
  fi
  n=$((n + 1))
done

# The same diff with no --blast-radius and no PR is refused, naming the path, before any state is written.
rm -rf .scratch .claude/state
set +e
out="$(bash "$skill/scripts/review-brief.sh" HEAD~1 2>&1)"
code=$?
set -e
if [ "$code" != 1 ] || [ "$out" != "ticket: #7
round: 1 of 3
review-brief: cross-cutting diff (.claude/hooks/x.sh) without a blast-radius grounding; run the blast-radius skill, put the result in the PR body's Blast Radius section or pass --blast-radius FILE" ] || [ -e .claude/state/review ] || [ -e .scratch/review/HEAD_1 ]; then
  echo "FAIL cross-cutting diff without a grounding: exit $code, wanted 1, the message, no state and no briefs"
  echo "  got: $out"
  exit 1
fi
n=$((n + 1))

# With a PR, the grounding is the body's `## Blast Radius` section: CRLF line ends, a fenced `## ` line
# kept inside it, and the next heading ending it. An empty section is refused like a missing one.
printf '## Why\r\n\r\nA hook.\r\n\r\n## Blast Radius\r\n\r\n- **Risks.** a subagent inherits it: `.claude/hooks/x.sh:1`.\r\n\r\n```sh\r\n## not a heading, part of the proof\r\n```\r\n\r\n## Verification\r\n\r\nran it\r\n' > pr-body.md
FAKE_PR_BODY="$fx/pr-body.md" bash "$skill/scripts/review-brief.sh" HEAD~1 > out.txt
for f in "$std" "$spec"; do
  has "$f" '- **Risks.** a subagent inherits it: `.claude/hooks/x.sh:1`.' "$f carries the PR body's section"
  has "$f" "## not a heading, part of the proof" "$f keeps the fenced line of the section"
  lacks "$f" "ran it" "$f stops the section at the next heading"
  lacks "$f" "A hook." "$f starts the section at its heading"
done
printf '## Why\n\nA hook.\n\n## Blast Radius\n\n## Verification\n\nran it\n' > pr-body-empty.md
rm -rf .scratch .claude/state
set +e
out="$(FAKE_PR_BODY="$fx/pr-body-empty.md" bash "$skill/scripts/review-brief.sh" HEAD~1 2>&1)"
code=$?
set -e
if [ "$code" != 1 ] || ! printf '%s' "$out" | grep -qF "cross-cutting diff (.claude/hooks/x.sh) without a blast-radius grounding" || [ -e .claude/state/review ]; then
  echo "FAIL empty Blast Radius section: exit $code, wanted 1 with the refusal and no state"
  echo "  got: $out"
  exit 1
fi
n=$((n + 1))

# A diff that is not cross-cutting ignores --blast-radius and says so on stderr.
echo readme > README.md
git add README.md
git commit -qm "a readme, #7"
bash "$skill/scripts/review-brief.sh" HEAD~1 --blast-radius blast.md > out.txt 2> err.txt
printed err.txt "review-brief: the diff is not cross-cutting; blast.md is not pasted" "README-only diff with --blast-radius"
for f in "$std" "$spec"; do
  lacks "$f" "## Blast radius" "$f has no blast-radius section for a README-only diff"
  lacks "$f" "Adds a hook that exits 0" "$f does not carry the ignored file"
done

echo "ok $n assertions"
