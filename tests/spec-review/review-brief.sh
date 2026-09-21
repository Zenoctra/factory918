#!/usr/bin/env bash
# Runs template/.agents/skills/spec-review/scripts/review-brief.sh in a temp repo and asserts that
# each brief carries the report shape review-comment.sh enforces: the definition sentence, every
# heading name, the item format and the count rule. A fake gh on PATH supplies the ticket body so
# the Spec brief is written too. SKILL.md step 4 must carry the definition word for word, so the
# skill and the script cannot drift apart. Exits 1 on the first miss.
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
printf '#!/bin/sh\necho "What to build: the ticket body"\n' > bin/gh
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

bash "$skill/scripts/review-brief.sh" HEAD~1 --ticket 7 > out.txt
[ "$(cat out.txt)" = "ticket: #7
.scratch/review/HEAD_1/standards-brief.md
.scratch/review/HEAD_1/spec-brief.md" ] || { echo "FAIL: review-brief.sh printed"; cat out.txt; exit 1; }
n=$((n + 1))
std=.scratch/review/HEAD_1/standards-brief.md
spec=.scratch/review/HEAD_1/spec-brief.md

definition="A hard finding is wrong behavior in normal use: a command, hook, script or documented flow does something other than what the ticket or its own documentation says it does, on the path a user takes."
count_rule='End the report with exactly one line `hard findings: N`, where N is the number of items under `## Would break` and nothing else.'
has "$skill/SKILL.md" "$definition" "SKILL.md step 4 carries the definition"
for f in "$std" "$spec"; do
  has "$f" "$definition" "$f carries the definition"
  has "$f" 'Write the report as Markdown with exactly these `## ` headings, in this order, each holding numbered items or nothing:' "$f names the shape"
  has "$f" '`1. **Title.** body`' "$f carries the item format"
  has "$f" "number the items continuously across the headings" "$f says how to number"
  has "$f" "$count_rule" "$f carries the count rule"
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
has "$spec" "Write your report to \`$(dirname "$spec")/spec-report.md\` and reply with only that path." "Spec: the report path"

echo "ok $n assertions"
