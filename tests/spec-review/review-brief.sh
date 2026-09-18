#!/usr/bin/env bash
# Runs template/.agents/skills/spec-review/scripts/review-brief.sh in a temp repo and asserts that
# each brief carries the report shape review-comment.sh enforces: the definition sentence, every
# heading name, the item format and the count rule. A fake gh on PATH supplies the ticket body and
# the ticket's comments, and reports no PR, so the Spec brief is written and the round is 1 unless
# --round says otherwise. With --previous, only the judgment items that cite a decision carry into
# both briefs; a fourth round is refused before any state is written. SKILL.md step 4 must carry
# the definition and the settled paragraph word for word, so the skill and the script cannot drift
# apart. Exits 1 on the first miss.
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
# gh pr view: no PR for this branch. gh issue view: the body, or the author's comments already
# formatted the way the script's jq expression formats them (one is by someone else and is left out).
cat > bin/gh <<'EOF'
#!/bin/sh
case "$*" in
  "pr view"*) echo "no pull requests found for branch" >&2; exit 1 ;;
  *"--json body"*) echo "What to build: the ticket body" ;;
  *"--json author,comments"*) printf '### 2026-09-17\n\nuser: the hook stays in bash.\n\n### 2026-09-18\n\nuser: the count is Act on plus Ask.\n\n' ;;
  *) echo "fake gh: unexpected args: $*" >&2; exit 2 ;;
esac
EOF
chmod +x bin/gh
PATH="$fx/bin:$PATH"

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

bash "$skill/scripts/review-brief.sh" HEAD~1 --ticket 7 > out.txt
printed out.txt "ticket: #7
round: 1 of 3
.scratch/review/HEAD_1/standards-brief.md
.scratch/review/HEAD_1/spec-brief.md" "first round, no PR"
std=.scratch/review/HEAD_1/standards-brief.md
spec=.scratch/review/HEAD_1/spec-brief.md
[ "$(cat .scratch/review/HEAD_1/round)" = 1 ] || { echo "FAIL: the round file does not say 1"; exit 1; }
n=$((n + 1))

definition="A hard finding is wrong behavior in normal use: a command, hook, script or documented flow does something other than what the ticket or its own documentation says it does, on the path a user takes."
count_rule='End the report with exactly one line `hard findings: N`, where N is the number of items under `## Would break` and nothing else.'
settled_rule="These findings were raised in an earlier round and settled by the decision each one cites. Do not raise them again. Nothing in this section says what you should find or confirm."
has "$skill/SKILL.md" "$definition" "SKILL.md step 4 carries the definition"
has "$skill/SKILL.md" "$settled_rule" "SKILL.md step 4 carries the settled paragraph"
for f in "$std" "$spec"; do
  has "$f" "$definition" "$f carries the definition"
  has "$f" 'Write the report as Markdown with exactly these `## ` headings, in this order, each holding numbered items or nothing:' "$f names the shape"
  has "$f" '`1. **Title.** body`' "$f carries the item format"
  has "$f" "number the items continuously across the headings" "$f says how to number"
  has "$f" "$count_rule" "$f carries the count rule"
  lacks "$f" "## Settled in earlier rounds" "$f has no settled section without a previous comment"
done
has "$std" '- `## Would break`: a breach of a documented standard that produces wrong behavior in normal use.' "Standards: Would break"
has "$std" '- `## Standards breaches`: documented-standard breaches that do not change behavior.' "Standards: Standards breaches"
has "$std" '- `## Fix alongside`: baseline smells and other judgement calls. Name the smell and quote the hunk. They are fixed only when a would-break fix already touches that code; they never count.' "Standards: Fix alongside and the smell rule"
has "$std" "Write your report to \`$(dirname "$std")/standards-report.md\` and reply with only that path." "Standards: the report path"
has "$spec" '- `## Would break`: a requirement missing, partial, or implemented so that normal use does something other than the ticket says.' "Spec: Would break"
has "$spec" '- `## Latent`: edge cases, visibility, policy, wording; anything a user would not hit in normal use.' "Spec: Latent"
has "$spec" '- `## Not asked for`: behaviour in the diff the ticket did not ask for.' "Spec: Not asked for"
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

1. [S2] **Whole DECISIONS.md is writable.** Provisional rows are the agent's to add. cites: DECISIONS.md P17
2. [S3] **Bare number.** The constant is named two lines up.

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
  has "$f" "1. [S2] **Whole DECISIONS.md is writable.** Provisional rows are the agent's to add. cites: DECISIONS.md P17" "$f carries the cited Dismissed item"
  lacks "$f" "Bare number" "$f drops the uncited item"
  lacks "$f" "Not an item" "$f skips the fenced hunk"
done

# A comment posted from the GitHub web UI has CRLF line ends; the same items carry.
sed 's/$/\r/' previous.md > previous-crlf.md
bash "$skill/scripts/review-brief.sh" HEAD~1 --ticket 7 --previous previous-crlf.md --round 3 > out.txt
has out.txt "settled: carried 2, dropped 1 without a citation" "CRLF previous comment carries the same items"
has "$std" "cites: DECISIONS.md P17" "CRLF previous comment: the cited item is in the brief"

# A fourth round is refused before any state is written.
rm -rf .scratch .claude
set +e
out="$(bash "$skill/scripts/review-brief.sh" HEAD~1 --ticket 7 --round 4 2>&1)"
code=$?
set -e
if [ "$code" != 1 ] || [ "$out" != 'review-brief: three rounds were run on this PR; the remaining Act on items become tickets (`ticket: #N`), not a fourth round' ] || [ -e .claude/state/review ] || [ -e .scratch/review ]; then
  echo "FAIL fourth round: exit $code, wanted 1, the message and no state"
  echo "  got: $out"
  exit 1
fi
n=$((n + 1))

echo "ok $n assertions"
