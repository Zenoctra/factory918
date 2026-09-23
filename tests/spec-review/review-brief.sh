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
# skill and the script cannot drift apart. Both briefs carry the same `## Reading pack` section
# after the diff (ticket #107's table, one assertion per cell): the changed files' text at HEAD,
# whole or by function, comment-led block, section or window, within the byte cutoffs, the rest
# named on one line; a failing git inside the pack refuses before any state is written. Every
# line under a Risks heading of a cross-cutting diff's grounding, and every line under a
# `### Writer flags <YYYY-MM-DD>` heading of the ticket body (the fake gh reads it from the file
# FAKE_ISSUE_BODY names, and fails when an `issue-error` file exists), ends with `fixed: <sha>`, a
# commit in HEAD's history, or `accepted: <reason>`; a line without one, a heading that looks like
# either opener and is not, and a fence opened in a list and never closed are refused before any
# state is written, each line named (ticket #108's tables A, B and C, one assertion per cell, and
# the risk sentence now asks whether the diff honors each disposition). The Opening a PR playbook
# and the blast-radius skill must show the disposition line word for word. Ticket #139, table D: a
# body holding a writer flags heading line anywhere, from which no flag is read, is refused. Ticket
# #137: both briefs carry the edge line two after Manuel's fifth sentence, the reading-pack sentence
# two after it and the reading sentence, and neither brief nor SKILL.md sets a count of findings, a
# length cap or a limit on reading; a round-two and a fix-only brief carry exactly the `## `
# headings they carried before it.
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
# section <brief>: the brief's `## Reading pack` section, to the next `## ` line outside the pack's fences.
# A reader of section's output reads it to the end: a reader that exits early kills section with
# SIGPIPE on its next write, and under pipefail the pipeline then fails.
section() {
  awk '$0 == "## Reading pack" { on = 1; print; next }
    on && fence == "" && /^## / { exit }
    on { print }
    on && /^```+$/ { if (fence == "") fence = $0; else if ($0 == fence) fence = "" }' "$1"
}
# entry <brief> <header> <first> <last> <label>: the section holds the header line, a blank line, a
# fence line, text from the line <first> to the line <last>, and the same fence line.
entry() {
  if ! section "$1" | H="$2" F="$3" L="$4" awk '
      st == 0 && $0 == ENVIRON["H"] { st = 1; next }
      st == 1 { st = ($0 == "") ? 2 : -1; next }
      st == 2 { if ($0 ~ /^```+$/) { fence = $0; st = 3 } else st = -1; next }
      st == 3 { if ($0 == ENVIRON["F"]) { last = $0; st = 4 } else st = -1; next }
      st == 4 { if ($0 == fence) { ok = (last == ENVIRON["L"]); st = 5 } else last = $0; next }
      END { exit !ok }'; then
    echo "FAIL $5: $1 has no entry"; echo "  $2"; echo "  from: $3"; echo "  to: $4"; exit 1
  fi
  n=$((n + 1))
}
# fence <brief> <header> <fence> <label>: the entry under the header opens with exactly that fence line.
fence() {
  if ! section "$1" | H="$2" F="$3" awk '
      st == 0 && $0 == ENVIRON["H"] { st = 1; next }
      st == 1 { st = ($0 == "") ? 2 : -1; next }
      st == 2 { ok = ($0 == ENVIRON["F"]); st = -1 }
      END { exit !ok }'; then
    echo "FAIL $4: $1: the entry $2 does not open with $3"; exit 1
  fi
  n=$((n + 1))
}
# none <brief> <path> <label>: no line of the section starts with `### <path>,`.
none() {
  if section "$1" | P="### $2," awk 'index($0, ENVIRON["P"]) == 1 { found = 1 } END { exit !found }'; then
    echo "FAIL $3: $1 carries an entry for $2"; exit 1
  fi
  n=$((n + 1))
}
# notext <brief> <line> <label>: the section holds the line, then a blank line.
notext() {
  if ! section "$1" | L="$2" awk 'st == 0 && $0 == ENVIRON["L"] { st = 1; next } st == 1 { ok = ($0 == ""); st = 2 } END { exit !ok }'; then
    echo "FAIL $3: $1 lacks the line, then a blank line: $2"; exit 1
  fi
  n=$((n + 1))
}
# rows <prefix> <count>: lines `<prefix><i>` padded with dots to 64 bytes each, the newline included.
rows() { awk -v p="$1" -v c="$2" 'BEGIN { for (i = 1; i <= c; i++) { s = p i; while (length(s) < 63) s = s "."; print s } }'; }
# funcs <prefix> <count>: shell functions `<prefix><i>() {` of four lines each, a blank line after each.
funcs() {
  awk -v p="$1" -v c="$2" 'BEGIN { for (i = 1; i <= c; i++) {
    print p i "() {"; for (j = 1; j <= 4; j++) print "  echo \"" p i " line " j " of the function body, padded\""; print "}"; print "" } }'
}
# sections <name> <count>: Markdown sections `## <name> <i>` of four lines each, a blank line after each.
sections() {
  awk -v p="$1" -v c="$2" 'BEGIN { for (i = 1; i <= c; i++) {
    print "## " p " " i; print ""; for (j = 1; j <= 4; j++) print "Line " j " of " p " " i ", with filler text so the section has some weight."; print "" } }'
}
# at <file> <line>: the number of the first line that is exactly <line>.
at() { grep -m 1 -nxF -- "$2" "$1" | cut -d: -f1; }
# close_of <file> <n>: the number of the first line after line n that starts with `}`.
close_of() { awk -v s="$2" 'NR > s && /^}/ { print NR; exit }' "$1"; }
# line_of <file> <n>: line n of the file.
line_of() { sed -n "$2p" "$1"; }
# edit <file> <sed program>: the file rewritten by the program.
edit() { sed "$2" "$1" > "$1.new"; mv "$1.new" "$1"; }

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

definition="A hard finding is one of two things: the documented path gives a wrong or silent result, or an input outside it proceeds silently (fails open). An input outside the documented path that is refused with a message saying how to correct it is not a finding; it is the design."
quotes=(
  '- Manuel: "there are an infinite amount of unhappy paths and only 1 happy one"'
  '- Manuel: "AT MOST hardening to fail fast and loud if we move outside of that"'
  '- Manuel: "we notice the variable is unexpected and flag that without having to diagnose every reason the variable might be wrong for the user"'
  '- Manuel: "An edge case outside the intended path being unsupported is not a flag."'
  '- Manuel: "Primary focus must be the happy path, then unhappy paths that error in a way the user can correct."'
)
edge_rule='An edge case that proceeds silently fails open: file it under `## Fails open`.'
read_rule='You may open any file in the repository and run read-only commands, such as grep or the test suite.'
step_rule='Every item under `## Would break` or `## Fails open` carries a line `Documented step:` quoting the ticket line or the `file:line` of the documentation the user follows, and a line `Result:` saying what happens instead; an item without its `Documented step:` line is sent back.'
spec_rule='The same item carries a line `spec:` naming the artifact it rests on: `table <row>/<column>` for a cell of the ticket'"'"'s scenario table, `design <signature>` for a signature or usage in its `## Design` sketch, or `criterion <k>` for its k-th acceptance checkbox; an item without a `spec:` line in one of those three forms is sent back.'
count_rule='End the report with exactly one line `hard findings: N`, where N is the number of items under `## Would break` and `## Fails open` and nothing else.'
settled_rule="These findings were raised in an earlier round and settled by the decision each one cites. Do not raise them again. Nothing in this section says what you should find or confirm."
fix_rule="The round before this one fixed these Act on items on this PR after the commit it reviewed; this round's diff is those fix commits and nothing else. Read each fix against its item, walk only the steps these commits touch, and report only what these commits get wrong. Nothing in this section says what you should find or confirm."
blast_rule="The sessions and skills this change reaches, as the author grounded them before the review. Check the diff against each one; the grounding is the author's claim, not evidence."
risk_rule='The diff is cross-cutting: after the lines per documented step, one numbered line per risk under the Risks heading of the `## Blast radius` section above, in its order and numbered on from the last step, each naming the risk, saying what the diff does at that risk, and saying whether the diff honors the disposition the risk'"'"'s line ends with (for `fixed: <sha>`, whether that commit fixes the risk; for `accepted: <reason>`, whether the reason holds for this diff); a risk line is a walk line and counts nothing.'
# blind_rules <brief> <label suffix>: the edge line two after Manuel's fifth sentence, the reading
# sentence, and no count, cap or reading limit.
blind_rules() {
  has "$1" "$edge_rule" "$1 carries the edge line$2"
  [ "$(grep -nxF -- "$edge_rule" "$1" | cut -d: -f1)" -eq "$(($(grep -nF -- "${quotes[4]}" "$1" | cut -d: -f1) + 2))" ] || { echo "FAIL $1: the edge line is not two after the fifth quote$2"; exit 1; }
  n=$((n + 1))
  has "$1" "$read_rule" "$1 carries the reading sentence$2"
  for w in "Under 400 words" "Read nothing beyond this brief" "Run nothing" "Zero items" "not the file"; do
    lacks "$1" "$w" "$1 sets no count, cap or reading limit$2"
  done
}
has "$source_skill/SKILL.md" "$definition" "SKILL.md step 4 carries the definition"
has "$source_skill/SKILL.md" "$step_rule" "SKILL.md step 4 carries the step rule"
has "$source_skill/SKILL.md" "$spec_rule" "SKILL.md step 4 carries the spec rule"
has "$source_skill/SKILL.md" "$count_rule" "SKILL.md step 4 carries the count rule"
has "$source_skill/SKILL.md" "$settled_rule" "SKILL.md step 4 carries the settled paragraph"
has "$source_skill/SKILL.md" "$fix_rule" "SKILL.md step 4 carries the fix paragraph"
has "$source_skill/SKILL.md" "$blast_rule" "SKILL.md step 4 carries the blast-radius paragraph"
has "$source_skill/SKILL.md" "$risk_rule" "SKILL.md step 4 carries the risk sentence"
lacks "$source_skill/SKILL.md" "## Latent" "SKILL.md has no Latent heading"
has "$source_skill/SKILL.md" "$edge_rule" "SKILL.md step 4 carries the edge line"
has "$source_skill/SKILL.md" "$read_rule" "SKILL.md step 4 carries the reading sentence"
has "$source_skill/SKILL.md" 'A ticket body that holds a line of two or more `#` whose text holds `writer` and, after it, `flag` (in any case, fenced, quoted or after a list marker) and from which no flag is read is refused the same way, naming each such line' "SKILL.md step 1 says which heading lines #139's guard counts"
for w in "all nits" "more than five Act on items" "under 400 words" "runs nothing"; do
  lacks "$source_skill/SKILL.md" "$w" "SKILL.md sets no count, cap or reading limit"
done
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
  blind_rules "$f" ""
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
# headings <brief> <list> <label>: the brief's `## ` lines are exactly the list.
headings() {
  [ "$(grep '^## ' "$1")" = "$2" ] || { echo "FAIL $3: $1's headings are"; grep '^## ' "$1"; exit 1; }
  n=$((n + 1))
}
r2_headings="## Commits
## Changed files
## Diff
## Reading pack
## Settled in earlier rounds"
fix_headings="## Commits
## Changed files
## The fix under review
## Diff
## Reading pack
## Settled in earlier rounds"
std_tail="## Standards
## Smell baseline
## Report"
spec_tail="## The ticket (#7)
## What to build
## Acceptance criteria
## Comments by the ticket's author (#7)
## Report"
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
# #137, criterion 3: a fix-only brief's headings are the ones it carried before #137, nothing more.
headings ".scratch/review/$s4/standards-brief.md" "$fix_headings
$std_tail" "Standards: fix-only headings (#137)"
headings ".scratch/review/$s4/spec-brief.md" "$fix_headings
$spec_tail" "Spec: fix-only headings (#137)"
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
# #137, criterion 3: a round-two brief's headings are the ones it carried before #137, nothing more.
headings "$std" "$r2_headings
$std_tail" "Standards: round-two headings (#137)"
headings "$spec" "$r2_headings
$spec_tail" "Spec: round-two headings (#137)"
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
# unmarked Act on item and one ticketed, and `fix only after r2`. The second fix commit adds
# `walk fixed` a second time, so that text says nowhere which line a quote came from. Each
# assertion names its cell.
r1="$(git rev-parse HEAD)"
printf 'four\n  walk fixed\nok\n' > a.txt
git commit -qam "fix the walk, #7"
r2="$(git rev-parse HEAD)"
printf '  hook fixed\n  walk fixed\nok\n  walk fixed\n' > a.txt
git commit -qam "fix the hook, #7"
od=.scratch/review/HEAD_2
r2d=".scratch/review/$r2"
# The lines r1..HEAD adds, four characters or more, less markers and surrounding blanks, whose text
# occurs once in a.txt at HEAD; and the one hunk's new side, a.txt being the single line `four` at r1.
fix_lines='hook fixed'
fix_ranges="$(printf '1\t4\ta.txt')"
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
# ff <dir> <label>, no_ff <dir> <label>: the fix lines and ranges written exactly, or neither written.
ff() {
  [ "$(cat "$1/fix-lines" 2>/dev/null)" = "$fix_lines" ] || { echo "FAIL $2: $1/fix-lines is not the unique lines r1..HEAD added"; cat "$1/fix-lines" 2>/dev/null; exit 1; }
  [ "$(cat "$1/fix-ranges" 2>/dev/null)" = "$fix_ranges" ] || { echo "FAIL $2: $1/fix-ranges is not the new side of r1..HEAD"; cat "$1/fix-ranges" 2>/dev/null; exit 1; }
  n=$((n + 1))
}
no_ff() {
  [ ! -e "$1/fix-lines" ] && [ ! -e "$1/fix-ranges" ] || { echo "FAIL $2: $1/fix-lines or $1/fix-ranges was written"; exit 1; }
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
# Row 6: round two with no hard item carries the same line, so the brief is row 5's. 6B and 6C
# are 5B and 5C: the brief never reads a hard item, so their history is byte for byte row 5's.
bash "$skill/scripts/review-brief.sh" "$r2" --ticket 7 > out.txt
printed out.txt "$r3_fix" "(2F) with no hard item is row 5 to the brief (6A)"
# Row 7: a fixed point that is not r2.
refused "(2F), the original fixed point (7A)" "$(fp3 "$r2" HEAD~2)" HEAD~2 --ticket 7
refused "(2F), HEAD as the fixed point (7A)" "$(fp3 "$r2" HEAD)" HEAD --ticket 7
refused "(2F), --round 3 from the original fixed point (7B)" "$(fp3 "$r2" HEAD~2)" HEAD~2 --ticket 7 --round 3
refused "(2F) from --previous, the original fixed point (7C)" "$(fp3 "$r2" HEAD~2)" HEAD~2 --ticket 7 --previous previous-2f.md
# Row 8: r2 does not resolve.
sed "s/$r2/0000000000000000000000000000000000000000/" previous-2f.md > previous-2f-gone.md
pr me me:previous-1r.md me:previous-2f-gone.md
fr3="review-brief: round 3 reviews only the fix from 0000000000000000000000000000000000000000, the commit round 2 reviewed, and that commit does not resolve here; fetch the PR's branch"
refused "(2F) naming a commit this clone lacks (8A)" "$fr3" "$r2" --ticket 7
refused "(2F) naming a commit this clone lacks, --round 3 (8B)" "$fr3" "$r2" --ticket 7 --round 3
refused "(2F) naming a commit this clone lacks, from --previous (8C)" "$fr3" "$r2" --ticket 7 --previous previous-2f-gone.md
# Row 9: a fix commit naming no ticket, on a branch of its own.
git switch -q -c no-ticket "$r2"
echo 'hook fixed, no ticket' > a.txt
git commit -qam "fix the hook"
pr me me:previous-1r.md me:previous-2f.md
ft3="review-brief: round 3 reviews only the fix and its commits name no ticket, while round 2 had a spec; pass --ticket N so the Spec axis reads the same spec"
refused "(2F) with a spec, no --ticket and a fix naming none (9A)" "$ft3" "$r2"
refused "(2F) with a spec, no --ticket and a fix naming none, --round 3 (9B)" "$ft3" "$r2" --round 3
refused "(2F) with a spec, no --ticket and a fix naming none, from --previous (9C)" "$ft3" "$r2" --previous previous-2f.md
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
for cell in "10A:" "10B:--round 3" "10C:--previous previous-2f-head.md"; do
  rm -rf .scratch .claude/state
  set +e
  # shellcheck disable=SC2086 # the cell's flags are words
  out="$(bash "$skill/scripts/review-brief.sh" "$h" --ticket 7 ${cell#*:} 2>&1)"
  code=$?
  set -e
  if [ "$code" != 1 ] || [ "${out##*$'\n'}" != "review-brief: the diff is empty; nothing to review since $h" ] || [ -e .claude/state/review ] || [ -e ".scratch/review/$h" ]; then
    echo "FAIL round three with no fix commit (${cell%%:*}): exit $code, wanted 1, the empty-diff refusal and no state"
    echo "  got: $out"
    exit 1
  fi
  n=$((n + 1))
done
# Row 11: the sweep form has no fix-only round.
pr me me:previous-1r.md me:previous-2f.md
refused "the sweep form after (2F) (11A)" "$(fp3 "$r2" paths)" --paths a.txt --commits HEAD
refused "the sweep form after (2F), --round 3 (11B)" "$(fp3 "$r2" paths)" --paths a.txt --commits HEAD --round 3
refused "the sweep form after (2F) from --previous (11C)" "$(fp3 "$r2" paths)" --paths a.txt --commits HEAD --previous previous-2f.md
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
  bash "$skill/scripts/review-brief.sh" HEAD~2 --ticket 7 --round 3 > out.txt
  has out.txt "round: 3 of 3" "$hist is not the line, --round 3 (12B)"
  lacks "$od/standards-brief.md" "## The fix under review" "$hist is not the line, --round 3: the whole diff (12B)"
  # A stranger's comment or a rebuilt (2) has no --previous form: a file is the author's (#93).
  case "$hist" in *" "*) continue ;; esac
  bash "$skill/scripts/review-brief.sh" HEAD~2 --ticket 7 --previous "${hist#me:}" > out.txt
  has out.txt "round: 3 of 3" "$hist is not the line, from --previous (12C)"
  lacks "$od/standards-brief.md" "## The fix under review" "$hist is not the line, from --previous: the whole diff (12C)"
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
{ cat previous-1r.md; printf '\036\n'; cat previous-2rv.md; } > hist-13.md
bash "$skill/scripts/review-brief.sh" HEAD~2 --ticket 7 --previous hist-13.md > out.txt
printed out.txt "$r3_whole" "(1R), (2 with a reviewed line) from --previous: round three, the whole diff (13C)"
lacks "$od/standards-brief.md" "## The fix under review" "(1R), (2 with a reviewed line) from --previous: no fix section (13C)"
no_ff "$od" "(1R), (2 with a reviewed line) from --previous (13C)"
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
{ cat previous-1r.md; printf '\036\n'; cat previous-2f.md; printf '\036\n'; cat previous-3w-fo.md; } > hist-15.md
bash "$skill/scripts/review-brief.sh" "$s3" --ticket 7 --previous hist-15.md > out.txt
has out.txt "round: 4 of 5" "(3W s) after (2F) from --previous: round four (15C)"
fixed_section ".scratch/review/$s3/standards-brief.md" "1. [S1] **Hook in Python.** Guarded. fixed: $short3" "(3W s) after (2F) from --previous (15C)"
lacks ".scratch/review/$s3/standards-brief.md" "1. [S1] **Hook in Python.** Ported." "(3W s) after (2F) from --previous: round two's item is not in the section (15C)"
refused "(3W s) after (2F), from r2 (16A)" "$(fp 4 "$s3" "$r2")" "$r2" --ticket 7
refused "(3W s) after (2F), from r2, --round 4 (16B)" "$(fp 4 "$s3" "$r2")" "$r2" --ticket 7 --round 4
refused "(3W s) after (2F), from r2, from --previous (16C)" "$(fp 4 "$s3" "$r2")" "$r2" --ticket 7 --previous hist-15.md
pr me me:previous-1r.md me:previous-2f.md me:previous-3.md
refused "a plain round three after (2F) (17A)" "$f4" "$s3" --ticket 7
refused "a plain round three after (2F), --round 5 (17B)" "$(f5 5 3)" "$s3" --ticket 7 --round 5
{ cat previous-1r.md; printf '\036\n'; cat previous-2f.md; printf '\036\n'; cat previous-3.md; } > hist-17.md
refused "a plain round three after (2F) from --previous (17C)" "$f4" "$s3" --ticket 7 --previous hist-17.md
t="$(git rev-parse HEAD)"
echo "guarded again" >> a.txt
git commit -qam "guard the hook again, #7"
shortt="$(git rev-parse --short HEAD)"
wb_comment previous-3-spec.md "$t" "Guarded again." "$shortt" | sed 's/^round: 3 of 3$/round: 4 of 5/' > previous-4w-fo.md
pr me me:previous-1r.md me:previous-2f.md me:previous-3w-fo.md me:previous-4w-fo.md
bash "$skill/scripts/review-brief.sh" "$t" --ticket 7 > out.txt
has out.txt "round: 5 of 5" "(4W t) after (2F), (3W s): round five (18A)"
fixed_section ".scratch/review/$t/standards-brief.md" "1. [S1] **Hook in Python.** Guarded again. fixed: $shortt" "round five (18A)"
bash "$skill/scripts/review-brief.sh" "$t" --ticket 7 --round 5 > out.txt
has out.txt "round: 5 of 5" "(4W t) after (2F), (3W s), --round 5 (18B)"
{ cat hist-15.md; printf '\036\n'; cat previous-4w-fo.md; } > hist-18.md
bash "$skill/scripts/review-brief.sh" "$t" --ticket 7 --previous hist-18.md > out.txt
has out.txt "round: 5 of 5" "(4W t) after (2F), (3W s) from --previous: round five (18C)"
{ cat hist-18.md; printf '\036\n'; cat previous-5.md; } > hist-18-5.md
refused "a fifth comment after (2F) from --previous: the sixth round (18C)" "$f6" "$t" --ticket 7 --previous hist-18-5.md
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
bash "$skill/scripts/review-brief.sh" HEAD~2 --ticket 7 --round 3 > out.txt
printed out.txt "$r3_whole" "(1), (2), --round 3 (19B)"
lacks "$od/standards-brief.md" "## The fix under review" "(1), (2), --round 3: no fix section (19B)"
no_ff "$od" "(1), (2), --round 3 (19B)"
{ cat previous.md; printf '\036\n'; cat previous-2.md; } > hist-19.md
bash "$skill/scripts/review-brief.sh" HEAD~2 --ticket 7 --previous hist-19.md > out.txt
printed out.txt "$r3_whole" "(1), (2) from --previous (19C)"
lacks "$od/standards-brief.md" "## The fix under review" "(1), (2) from --previous: no fix section (19C)"
no_ff "$od" "(1), (2) from --previous (19C)"
# 20B and 20C: round three after a round-two comment reads no line of the round-one comment, and
# (1) differs from (1R) by the reviewed line alone, which 5B and 5C carry.
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
pr me me:previous-1r.md me:previous-2f-crlf.md
bash "$skill/scripts/review-brief.sh" "$r2" --ticket 7 > out.txt
printed out.txt "$r3_fix" "a CRLF (2F) from gh: as the LF history of 5A (21A)"
fixed_section "$r2d/standards-brief.md" "1. [S1] **Hook in Python.** Ported." "a CRLF (2F) from gh (21A)"
# 21B: --round 3 over the CRLF history from gh is 21A's input path with the flag 5B covers.
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
{ cat blast.md; printf '\n## Risks\n\n1. A subagent inherits it: `.claude/hooks/x.sh:1`. accepted: fixture\n'; } > blast-risks.md
sed 's/^## Risks$/### Risks/' blast-risks.md > blast-risks-demoted.md
{ cat blast-risks.md; printf '\n### Risks\n\n2. The same risk, demoted. accepted: fixture\n'; } > blast-both.md
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
printf '## Why\r\n\r\nA hook.\r\n\r\n## Blast Radius\r\n\r\n- **Risks.** a subagent inherits it: `.claude/hooks/x.sh:1`.\r\n\r\n### Risks\r\n\r\n1. a subagent inherits it: `.claude/hooks/x.sh:1`. accepted: fixture\r\n\r\n```sh\r\n## not a heading, part of the proof\r\n```\r\n\r\n## Verification\r\n\r\nran it\r\n' > pr-body.md
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

# Ticket #107, the reading pack's scenario table, one assertion per cell, each named by its row and
# column. K0 holds every file under pk/, P changes each as its row says, F1 changes only pk/t.sh,
# f50 of pk/big.sh and section 20 of pk/big.md; W is round one from K0, F a fix-only round three
# from P (#106's `fix only after` comment naming P). Both runs are at F1. Windows are 63 lines of
# 64 bytes, the widest odd run within 4096 bytes.
mkdir pk
printf 'pk/gen.txt linguist-generated\n' > .gitattributes
echo 'echo s' > pk/s.sh
echo 'echo t' > pk/t.sh
{ echo '#!/usr/bin/env bash'; echo; funcs f 70; } > pk/big.sh
{ echo '#!/usr/bin/env bash'; echo; funcs a 35; echo '# top block'; echo 'top_a=1'; echo 'top_b=2'; echo '# next block'; funcs b 35; } > pk/top.sh
{ echo '#!/usr/bin/env bash'; echo 'long() {'; for i in 1 2 3 4 5 6 7 8; do echo "# part $i"; rows "  part${i}_" 10; done; echo '}'; echo; funcs l 30; } > pk/long.sh
{ echo '#!/usr/bin/env bash'; echo 'g() {'; echo "  cat <<'EOF'"; echo 'heredoc one'; echo 'heredoc two'; echo '}'; echo 'EOF'; echo '}'; echo; funcs h 70; } > pk/heredoc.sh
{ echo '#!/usr/bin/env bash'; echo; funcs v 3; echo '# wide block'; rows w_ 200; } > pk/wide.sh
{ echo '#!/usr/bin/env bash'; echo; funcs da 35; echo 'del_a() {'; echo '  echo del a'; echo '}'; echo ':'; echo 'del_b() {'; echo '  echo del b'; echo '}'; echo; funcs db 35; } > pk/del.sh
sections Section 40 > pk/big.md
{ sections Pad 40; echo '## Fenced'; echo; echo 'before the fence'; echo '````md'; echo '## not a heading'; echo '```'; echo '````'; echo 'after the fence'; echo '## After'; echo; sections Tail 5; } > pk/fenced.md
{ sections Pad 10; echo '## Long'; echo; rows long_ 200; echo; sections Tail 10; } > pk/longsec.md
rows code_ 200 > pk/code.py
{ echo '#!/usr/bin/env bash'; echo; funcs x 35; echo 'm1() {'; echo '  echo m one'; echo '}'; echo 'm2() {'; echo '  echo m two'; echo '}'; echo; funcs y 35; } > pk/touch.sh
printf 'ticks\n```\n````\na ````` b\n' > pk/ticks.md
printf 'one\ntwo' > pk/nonl.txt
printf 'a\r\nb\r\n' > pk/crlf.txt
{ echo '#!/usr/bin/env bash'; echo; funcs r 70; } > "pk/old name.sh"
rows mode_ 200 > pk/mode.txt
rows moved_ 200 > pk/moved-from.txt
echo gone > pk/gone.txt
printf 'a\000b' > pk/bin.dat
echo 'gen one' > pk/gen.txt
ln -s target-a pk/link
mkdir pk/sub
echo full > pk/emptied.txt
nl_path="$(printf 'pk/nl\nname.txt')"
echo nl > "$nl_path"
git add .gitattributes pk
git update-index --add --cacheinfo "160000,1111111111111111111111111111111111111111,pk/sub"
git commit -qm "the pack's files, #7"
k0="$(git rev-parse HEAD)"
echo 'echo s changed' > pk/s.sh
echo 'echo t changed' > pk/t.sh
edit pk/big.sh 's/f10 line 2 of/f10 line 2, changed, of/'
edit pk/top.sh 's/^top_b=2$/top_b=3/'
edit pk/long.sh 's/^  part3_5\./  part3_5X/'
edit pk/heredoc.sh 's/^heredoc two$/heredoc two changed/'
edit pk/wide.sh 's/^w_100\./w_100X/'
edit pk/del.sh '/^:$/d'
edit pk/big.md 's/^Line 2 of Section 7,/Line 2 of Section 7, changed,/'
edit pk/fenced.md 's/^after the fence$/after the fence, changed/'
edit pk/longsec.md 's/^long_100\./long_100X/'
edit pk/code.py 's/^code_100\./code_100X/'
edit pk/touch.sh 's/^  echo m one$/  echo m one changed/; s/^  echo m two$/  echo m two changed/'
echo end >> pk/ticks.md
printf 'one\nthree' > pk/nonl.txt
printf 'a\r\nc\r\n' > pk/crlf.txt
git mv "pk/old name.sh" "pk/new name.sh"
edit "pk/new name.sh" 's/r5 line 2 of/r5 line 2, changed, of/'
chmod +x pk/mode.txt
git update-index --chmod=+x pk/mode.txt
git mv pk/moved-from.txt pk/moved-to.txt
echo 'added small' > pk/added-small.txt
rows added_ 200 > pk/added-big.txt
git rm -q pk/gone.txt
printf 'a\000c' > pk/bin.dat
echo 'gen two' > pk/gen.txt
rm pk/link
ln -s target-b pk/link
: > pk/emptied.txt
echo 'nl changed' > "$nl_path"
git add pk
git update-index --cacheinfo "160000,2222222222222222222222222222222222222222,pk/sub"
git commit -qm "the pack's changes, #7"
p="$(git rev-parse HEAD)"
echo 'echo t fixed' > pk/t.sh
edit pk/big.sh 's/f50 line 2 of/f50 line 2, changed, of/'
edit pk/big.md 's/^Line 2 of Section 20,/Line 2 of Section 20, changed,/'
git commit -qam "the pack's fix, #7"
f1="$(git rev-parse HEAD)"
[ -z "$(git status --porcelain -- pk .gitattributes)" ] || { echo "FAIL: the pack's fixtures left the tree dirty:"; git status --porcelain -- pk .gitattributes; exit 1; }
wd=".scratch/review/$k0"
fd=".scratch/review/$p"
bash "$skill/scripts/review-brief.sh" "$k0" --ticket 7 > pk-w.out
for f in standards-brief.md spec-brief.md round reviewed; do cp "$wd/$f" "pk-w.$f"; done
for f in fixed-point files dir; do cp ".claude/state/review/$f" "pk-w.state.$f"; done
ls "$wd" > pk-w.ls
fo_comment previous-3-spec.md "$p" > previous-2f-pk.md
pr me me:previous-1r.md me:previous-2f-pk.md
bash "$skill/scripts/review-brief.sh" "$p" --ticket 7 > pk-f.out
for f in standards-brief.md spec-brief.md round reviewed; do cp "$fd/$f" "pk-f.$f"; done
for f in fixed-point files dir; do cp ".claude/state/review/$f" "pk-f.state.$f"; done
ls "$fd" > pk-f.ls
rm pr.json
wb=pk-w.standards-brief.md
fb=pk-f.standards-brief.md
section "$fb" > pk-f.section
# Row 1: the small files.
entry "$wb" "### pk/s.sh, whole, 1 line" "echo s changed" "echo s changed" "(1W)"
entry "$wb" "### pk/t.sh, whole, 1 line" "echo t fixed" "echo t fixed" "(1W)"
entry "$fb" "### pk/t.sh, whole, 1 line" "echo t fixed" "echo t fixed" "(1F)"
none "$fb" pk/s.sh "(1F)"
# Row 2: the enclosing function.
nb="$(wc -l < pk/big.sh | tr -d ' ')"
a10="$(at pk/big.sh 'f10() {')"; a50="$(at pk/big.sh 'f50() {')"
entry "$wb" "### pk/big.sh, lines $a10-$(close_of pk/big.sh "$a10") of $nb" 'f10() {' '}' "(2W)"
entry "$wb" "### pk/big.sh, lines $a50-$(close_of pk/big.sh "$a50") of $nb" 'f50() {' '}' "(2W)"
entry "$fb" "### pk/big.sh, lines $a50-$(close_of pk/big.sh "$a50") of $nb" 'f50() {' '}' "(2F)"
lacks pk-f.section 'f10() {' "(2F)"
# Row 3: top-level code, the comment-led block.
a="$(at pk/top.sh '# top block')"
entry "$wb" "### pk/top.sh, lines $a-$(($(at pk/top.sh '# next block') - 1)) of $(wc -l < pk/top.sh | tr -d ' ')" '# top block' 'top_b=3' "(3W)"
none "$fb" pk/top.sh "(3F)"
# Row 4: a long function, the comment-led block inside it.
a="$(at pk/long.sh '# part 3')"; b="$(($(at pk/long.sh '# part 4') - 1))"
entry "$wb" "### pk/long.sh, lines $a-$b of $(wc -l < pk/long.sh | tr -d ' ')" '# part 3' "$(line_of pk/long.sh "$b")" "(4W)"
none "$fb" pk/long.sh "(4F)"
# Row 5: the function ends at the heredoc's column-0 `}`, the line before EOF.
entry "$wb" "### pk/heredoc.sh, lines $(at pk/heredoc.sh 'g() {')-$(($(at pk/heredoc.sh 'EOF') - 1)) of $(wc -l < pk/heredoc.sh | tr -d ' ')" 'g() {' '}' "(5W)"
none "$fb" pk/heredoc.sh "(5F)"
# Row 6: no rung fits, the window inside the block.
l="$(grep -n '^w_100X' pk/wide.sh | cut -d: -f1)"
entry "$wb" "### pk/wide.sh, lines $((l - 31))-$((l + 31)) of $(wc -l < pk/wide.sh | tr -d ' ')" "$(line_of pk/wide.sh $((l - 31)))" "$(line_of pk/wide.sh $((l + 31)))" "(6W)"
none "$fb" pk/wide.sh "(6F)"
# Row 7: the deletion's lines c (del_a's `}`) and c+1 (`del_b() {`), their functions merged.
a="$(at pk/del.sh 'del_a() {')"
entry "$wb" "### pk/del.sh, lines $a-$(close_of pk/del.sh "$(at pk/del.sh 'del_b() {')") of $(wc -l < pk/del.sh | tr -d ' ')" 'del_a() {' '}' "(7W)"
none "$fb" pk/del.sh "(7F)"
# Row 8: the Markdown section, less its trailing blank line.
nm="$(wc -l < pk/big.md | tr -d ' ')"
a7="$(at pk/big.md '## Section 7')"; a20="$(at pk/big.md '## Section 20')"
b7="$(($(at pk/big.md '## Section 8') - 2))"; b20="$(($(at pk/big.md '## Section 21') - 2))"
entry "$wb" "### pk/big.md, lines $a7-$b7 of $nm" '## Section 7' "$(line_of pk/big.md "$b7")" "(8W)"
entry "$wb" "### pk/big.md, lines $a20-$b20 of $nm" '## Section 20' "$(line_of pk/big.md "$b20")" "(8W)"
entry "$fb" "### pk/big.md, lines $a20-$b20 of $nm" '## Section 20' "$(line_of pk/big.md "$b20")" "(8F)"
lacks pk-f.section '## Section 7' "(8F)"
# Row 9: past the fenced heading, in a fence of five backticks.
h="### pk/fenced.md, lines $(at pk/fenced.md '## Fenced')-$(($(at pk/fenced.md '## After') - 1)) of $(wc -l < pk/fenced.md | tr -d ' ')"
entry "$wb" "$h" '## Fenced' 'after the fence, changed' "(9W)"
fence "$wb" "$h" '`````' "(9W)"
none "$fb" pk/fenced.md "(9F)"
# Row 10: a section over 4096 bytes, the window inside it.
l="$(grep -n '^long_100X' pk/longsec.md | cut -d: -f1)"
entry "$wb" "### pk/longsec.md, lines $((l - 31))-$((l + 31)) of $(wc -l < pk/longsec.md | tr -d ' ')" "$(line_of pk/longsec.md $((l - 31)))" "$(line_of pk/longsec.md $((l + 31)))" "(10W)"
none "$fb" pk/longsec.md "(10F)"
# Row 11: another kind, the window.
l="$(grep -n '^code_100X' pk/code.py | cut -d: -f1)"
entry "$wb" "### pk/code.py, lines $((l - 31))-$((l + 31)) of 200" "$(line_of pk/code.py $((l - 31)))" "$(line_of pk/code.py $((l + 31)))" "(11W)"
none "$fb" pk/code.py "(11F)"
# Row 12: m1 and m2 touch, one entry.
entry "$wb" "### pk/touch.sh, lines $(at pk/touch.sh 'm1() {')-$(close_of pk/touch.sh "$(at pk/touch.sh 'm2() {')") of $(wc -l < pk/touch.sh | tr -d ' ')" 'm1() {' '}' "(12W)"
none "$fb" pk/touch.sh "(12F)"
# Row 13: a fence of six backticks.
entry "$wb" "### pk/ticks.md, whole, 5 lines" 'ticks' 'end' "(13W)"
fence "$wb" "### pk/ticks.md, whole, 5 lines" '``````' "(13W)"
none "$fb" pk/ticks.md "(13F)"
# Row 14: no final newline, and CRLF.
entry "$wb" "### pk/nonl.txt, whole, 2 lines" 'one' 'three' "(14W)"
entry "$wb" "### pk/crlf.txt, whole, 2 lines" $'a\r' $'c\r' "(14W)"
none "$fb" pk/nonl.txt "(14F)"
none "$fb" pk/crlf.txt "(14F)"
# Row 15: renamed with an edit, a space in the path.
a="$(at "pk/new name.sh" 'r5() {')"
entry "$wb" "### pk/new name.sh, renamed from pk/old name.sh, lines $a-$(close_of "pk/new name.sh" "$a") of $(wc -l < "pk/new name.sh" | tr -d ' ')" 'r5() {' '}' "(15W)"
none "$fb" "pk/new name.sh" "(15F)"
# Row 16: no changed line.
notext "$wb" "### pk/mode.txt, 200 lines, no line changed: no text" "(16W)"
notext "$wb" "### pk/moved-to.txt, renamed from pk/moved-from.txt, 200 lines, no line changed: no text" "(16W)"
none "$fb" pk/mode.txt "(16F)"
none "$fb" pk/moved-to.txt "(16F)"
# Row 17: added.
entry "$wb" "### pk/added-small.txt, whole, 1 line" 'added small' 'added small' "(17W)"
notext "$wb" "### pk/added-big.txt, added, 200 lines; the diff carries it whole: no text" "(17W)"
none "$fb" pk/added-small.txt "(17F)"
none "$fb" pk/added-big.txt "(17F)"
# Row 18: deleted.
notext "$wb" "### pk/gone.txt, deleted at HEAD: no text" "(18W)"
none "$fb" pk/gone.txt "(18F)"
# Row 19: binary and generated.
notext "$wb" "### pk/bin.dat, binary: no text" "(19W)"
notext "$wb" "### pk/gen.txt, generated (linguist-generated): no text" "(19W)"
none "$fb" pk/bin.dat "(19F)"
none "$fb" pk/gen.txt "(19F)"
# Row 20: a symbolic link and a submodule.
notext "$wb" "### pk/link, a symbolic link to target-b: no text" "(20W)"
notext "$wb" "### pk/sub, a submodule: no text" "(20W)"
none "$fb" pk/link "(20F)"
none "$fb" pk/sub "(20F)"
# Row 21: emptied, and a path holding a newline.
notext "$wb" "### pk/emptied.txt, empty at HEAD: no text" "(21W)"
notext "$wb" "### $(printf %q "$nl_path"), a path holding a newline: no text" "(21W)"
none "$fb" pk/emptied.txt "(21F)"
none "$fb" "$(printf %q "$nl_path")" "(21F)"
# Rows 22 to 24: the total. K2 holds pk2/z.txt; eight files of 8192 bytes, then one of 2 bytes, then
# z.txt as one line of 70000 bytes.
mkdir pk2
awk 'BEGIN { s = "a"; while (length(s) < 70000) s = s s; print substr(s, 1, 70000) }' > pk2/z.txt
git add pk2
git commit -qm "the total's base, #7"
k2="$(git rev-parse HEAD)"
w2=".scratch/review/$k2/standards-brief.md"
for i in 1 2 3 4 5 6 7 8; do rows "f${i}_" 128 > "pk2/f$i.txt"; done
git add pk2
git commit -qm "eight files, #7"
bash "$skill/scripts/review-brief.sh" "$k2" --ticket 7 > out.txt
for i in 1 2 3 4 5 6 7 8; do
  entry "$w2" "### pk2/f$i.txt, whole, 128 lines" "$(line_of "pk2/f$i.txt" 1)" "$(line_of "pk2/f$i.txt" 128)" "(22W)"
done
section "$w2" > pk2.section
lacks pk2.section "Not carried" "(22W)"
printf 'a\n' > pk2/a.txt
git add pk2
git commit -qm "a 2-byte file, #7"
bash "$skill/scripts/review-brief.sh" "$k2" --ticket 7 > out.txt
over23="Not carried, over the pack's 65536 bytes: pk2/f8.txt whole. Read these at HEAD from the repository."
carried23="### pk2/a.txt, whole, 1 line
### pk2/f1.txt, whole, 128 lines
### pk2/f2.txt, whole, 128 lines
### pk2/f3.txt, whole, 128 lines
### pk2/f4.txt, whole, 128 lines
### pk2/f5.txt, whole, 128 lines
### pk2/f6.txt, whole, 128 lines
### pk2/f7.txt, whole, 128 lines"
[ "$(section "$w2" | grep '^### ')" = "$carried23" ] && [ "$(section "$w2" | grep -v '^$' | tail -1)" = "$over23" ] || { echo "FAIL (23W): the carried entries in path order, then the eighth on the over line:"; section "$w2" | grep -e '^### ' -e '^Not carried'; exit 1; }
n=$((n + 1))
awk 'BEGIN { s = "b"; while (length(s) < 70000) s = s s; print substr(s, 1, 70000) }' > pk2/z.txt
git commit -qam "one line of 70000 bytes, #7"
bash "$skill/scripts/review-brief.sh" "$k2" --ticket 7 > out.txt
[ "$(section "$w2" | grep '^### ')" = "$carried23" ] && [ "$(section "$w2" | grep -v '^$' | tail -1)" = "Not carried, over the pack's 65536 bytes: pk2/f8.txt whole; pk2/z.txt lines 1-1. Read these at HEAD from the repository." ] || { echo "FAIL (24W): row 23's entries carried, z.txt named on the over line after f8.txt:"; section "$w2" | grep -e '^### ' -e '^Not carried'; exit 1; }
n=$((n + 1))
# Row 25: the sweep form.
bash "$skill/scripts/review-brief.sh" --paths pk/s.sh pk/big.sh --commits "$p" --ticket 7 > out.txt
[ "$(section ".scratch/review/sweep-$(git rev-parse --short "$p")/standards-brief.md")" = "## Reading pack

The sweep form carries no reading pack: its diff numbers lines as the swept commits did, so the files at HEAD are not the code it shows." ] || { echo "FAIL (25W): the sweep's section is not the one line"; exit 1; }
n=$((n + 1))
# Row 26: after the diff, before the next section; the two briefs' sections equal.
# around <brief>: the `## ` line before the section and the one after it, outside the pack's fences.
around() {
  awk '/^## / && !on && $0 != "## Reading pack" { before = $0 }
    $0 == "## Reading pack" { on = 1; next }
    on && fence == "" && /^## / { print before; print; exit }
    on && /^```+$/ { if (fence == "") fence = $0; else if ($0 == fence) fence = "" }' "$1"
}
[ "$(around pk-w.standards-brief.md)" = "## Diff
## Standards" ] && [ "$(around pk-w.spec-brief.md)" = "## Diff
## The ticket (#7)" ] || { echo "FAIL (26W): the section is not between the diff and the next section"; exit 1; }
n=$((n + 1))
[ "$(section pk-w.standards-brief.md)" = "$(section pk-w.spec-brief.md)" ] || { echo "FAIL (26W): the two briefs' sections differ"; exit 1; }
n=$((n + 1))
[ "$(around pk-f.standards-brief.md)" = "## Diff
## Settled in earlier rounds" ] && [ "$(around pk-f.spec-brief.md)" = "## Diff
## Settled in earlier rounds" ] || { echo "FAIL (26F): the section is not between the diff and the settled items"; exit 1; }
n=$((n + 1))
[ "$(section pk-f.standards-brief.md)" = "$(section pk-f.spec-brief.md)" ] || { echo "FAIL (26F): the two briefs' sections differ"; exit 1; }
n=$((n + 1))
# Row 27: the Report sentence after the edge line, before the shape sentence.
pack_rule='The `## Reading pack` section above is the code to read, as it stands at the reviewed commit; open the repository for what the pack does not carry.'
for f in pk-w.standards-brief.md pk-w.spec-brief.md pk-f.standards-brief.md pk-f.spec-brief.md; do
  c="W"; case "$f" in pk-f.*) c="F" ;; esac
  has "$f" "$pack_rule" "$f carries the Report sentence (27$c)"
  s="$(grep -nxF -- "$pack_rule" "$f" | cut -d: -f1)"
  [ "$s" -eq "$(($(grep -nxF -- "$edge_rule" "$f" | cut -d: -f1) + 2))" ] && [ "$(sed -n "$((s + 2))p" "$f")" = 'Write the report as Markdown with exactly these `## ` headings, in this order, each holding numbered items or nothing:' ] || { echo "FAIL (27$c): $f: the sentence is not between the edge line and the shape sentence"; exit 1; }
  n=$((n + 1))
  blind_rules "$f" " (27$c)"
done
# Row 28: stdout and state as without the pack.
printed pk-w.out "ticket: #7
round: 1 of 3
$wd/standards-brief.md
$wd/spec-brief.md" "(28W)"
[ "$(cat pk-w.round)" = 1 ] && [ "$(cat pk-w.reviewed)" = "$f1" ] && [ "$(cat pk-w.state.fixed-point)" = "$k0" ] && [ "$(cat pk-w.state.dir)" = "$wd" ] && [ "$(cat pk-w.state.files)" = "$(git diff "$k0...$f1" --name-only)" ] && [ "$(tr '\n' ' ' < pk-w.ls)" = "diff files fixed-point log pack.md reviewed round spec-brief.md standards-brief.md stat ticket.md " ] || { echo "FAIL (28W): the state is not what the run writes without the pack"; exit 1; }
n=$((n + 1))
printed pk-f.out "ticket: #7
round: 3 of 3
settled: carried 3, dropped 1 without a citation
$fd/standards-brief.md
$fd/spec-brief.md" "(28F)"
[ "$(cat pk-f.round)" = 3 ] && [ "$(cat pk-f.reviewed)" = "$f1" ] && [ "$(cat pk-f.state.fixed-point)" = "$p" ] && [ "$(cat pk-f.state.dir)" = "$fd" ] && [ "$(cat pk-f.state.files)" = "$(git diff "$p...$f1" --name-only)" ] && [ "$(tr '\n' ' ' < pk-f.ls)" = "diff files fixed-point log pack.md reviewed round spec-brief.md standards-brief.md stat ticket.md " ] || { echo "FAIL (28F): the state is not what the run writes without the pack"; exit 1; }
n=$((n + 1))
# Row 29: a git that fails on check-attr.
mkdir -p "$tmp/failgit"
printf '#!/bin/sh\nif [ "$1" = check-attr ]; then echo "fatal: check-attr refused by the test" >&2; exit 128; fi\nexec '"'"'%s'"'"' "$@"\n' "$(command -v git)" > "$tmp/failgit/git"
chmod +x "$tmp/failgit/git"
git switch -q --detach "$f1"
for c in W F; do
  if [ "$c" = F ]; then pr me me:previous-1r.md me:previous-2f-pk.md; from="$p" d="$fd"; else from="$k0" d="$wd"; fi
  rm -rf .scratch .claude/state
  set +e
  PATH="$tmp/failgit:$PATH" bash "$skill/scripts/review-brief.sh" "$from" --ticket 7 > out.txt 2> err.txt
  code=$?
  set -e
  if [ "$code" != 1 ] || [ "$(tail -1 err.txt)" != "review-brief: the reading pack failed (above); nothing written" ] || ! grep -qF "fatal: check-attr refused by the test" err.txt || [ -e .claude/state/review ] || [ -e "$d" ]; then
    echo "FAIL (29$c): exit $code, wanted 1, git's message, the refusal, no state and no $d"; cat err.txt; exit 1
  fi
  n=$((n + 1))
done
rm pr.json
git switch -q -
# The drift guard: the cutoffs line, and SKILL.md step 4's bullet and Report sentence.
grep -qx 'pack_whole=8192 pack_unit=4096 pack_total=65536' "$skill/scripts/reading-pack.sh" || { echo "FAIL: reading-pack.sh has no cutoffs line"; exit 1; }
n=$((n + 1))
has "$source_skill/SKILL.md" '- `## Reading pack`, right after the diff, from `scripts/reading-pack.sh`: the code the diff touches as it stands at the reviewed commit. A changed file of 8192 bytes or less is carried whole; in a larger one, each changed line brings the shell function, the comment-led block or the Markdown section around it when that is 4096 bytes or less, else the widest window around the line within 4096 bytes. The pack carries 65536 bytes at most, smallest entries first, and names what it leaves out on one closing line; a file with no text to carry (deleted, binary, generated, a link) is named with the reason. The sweep form carries no pack.' "SKILL.md step 4 names the pack and its cutoffs"
has "$source_skill/SKILL.md" "$pack_rule" "SKILL.md step 4 carries the Report sentence"

# Ticket #108, tables A, B and C, one assertion per cell, each named by its row and column: every
# line under a Risks heading of a cross-cutting diff's grounding, and every line under a
# `### Writer flags <YYYY-MM-DD>` heading of the ticket body, ends with `fixed: <sha>` (a commit in
# HEAD's history) or `accepted: <reason>`, or the brief is refused before any state is written,
# naming each offending line. o8 is the commit so far, t8 a text commit on it and k8 a hook commit
# on t8, so a run at k8 from t8 is cross-cutting (cc) and a run at t8 from o8 is not (nc); x8 is on
# a side branch, outside HEAD's history. The commits name no ticket, so a run passes --ticket 7
# unless the cell has no ticket. The templates under f8/ write <H> for HEAD's short sha and <X> for x8.
br8="$(git symbolic-ref --short HEAD)"
o8="$(git rev-parse HEAD)"
git switch -q -c side108
echo side > side.txt
git add side.txt
git commit -qm "a side commit"
x8="$(git rev-parse --short HEAD)"
git switch -q "$br8"
echo text > t8.txt
git add t8.txt
git commit -qm "a text file"
t8="$(git rev-parse HEAD)"
echo 'exit 0 # 108' > "$hooks/x.sh"
git add "$hooks/x.sh"
git commit -qm "the hook, again"
k8="$(git rev-parse HEAD)"
hk="$(git rev-parse --short "$k8")"
fo_comment previous-3-spec.md "$t8" > prev8.md
mkdir -p f8
# risks8 <name> <line>...: a grounding, the hand-back's first bullet, then `## Risks` and the lines.
risks8() { local f="f8/$1"; shift; { printf -- '- **What it does.** Adds a hook that exits 0.\n\n## Risks\n\n'; [ $# -eq 0 ] || printf '%s\n' "$@"; } > "$f"; }
# ground8 <name> <line>...: a grounding holding the lines, then `## Risks` with one settled risk.
ground8() { local f="f8/$1"; shift; { printf -- '- **What it does.** Adds a hook that exits 0.\n\n'; printf '%s\n' "$@"; printf '\n## Risks\n\n1. A subagent inherits it accepted: ok\n'; } > "$f"; }
# flags8 <name> <line>...: a ticket body, `### Writer flags 2026-09-23` inside `## Testing decisions`, then the lines.
flags8() { local f="f8/$1"; shift; { printf '## What to build\n\nThe ticket body.\n\n## Testing decisions\n\n### Writer flags 2026-09-23\n\n'; [ $# -eq 0 ] || printf '%s\n' "$@"; } > "$f"; }
# body8 <name> <line>...: a ticket body holding the lines and no list.
body8() { local f="f8/$1"; shift; { printf '## What to build\n\nThe ticket body.\n\n'; printf '%s\n' "$@"; } > "$f"; }
# go8 <cc|nc> <F|P|R|S> <grounding|-> <ticket|-|none> [arg ...]: review-brief.sh in the column's
# form, the grounding as blast8.md (`-`: none) and the ticket body as ticket8.md (`-`: the fake's
# fixed body, which has no list; `none`: no ticket). Leaves the stdout in out8, the stderr in err8,
# the exit in code and the review directory in d8.
go8() {
  local kind="$1" form="$2" g="$3" tk="$4" fp="$t8" h a=(); shift 4
  if [ "$kind" = nc ]; then git switch -q --detach "$t8"; fp="$o8"; fi
  h="$(git rev-parse --short HEAD)"
  d8=".scratch/review/$fp"
  if [ "$g" = - ]; then : > blast8.md; else sed "s/<H>/$h/g; s/<X>/$x8/g" "f8/$g" > blast8.md; fi
  case "$tk" in
    none) ;;
    -) a=(--ticket 7) ;;
    *) sed "s/<H>/$h/g; s/<X>/$x8/g" "f8/$tk" > ticket8.md; export FAKE_ISSUE_BODY="$fx/ticket8.md"; a=(--ticket 7) ;;
  esac
  rm -rf .scratch .claude/state pr8.md
  [ "$g" = - ] || { printf '## Why\n\nA hook.\n\n## Blast Radius\n\n'; sed 's/^\(#\{1,\}\) /#\1 /' blast8.md; printf '\n## Verification\n\nran it\n'; } > pr8.md
  set +e
  case "$form" in
    F) bash "$skill/scripts/review-brief.sh" "$fp" --blast-radius blast8.md ${a[@]+"${a[@]}"} "$@" ;;
    P) FAKE_PR_BODY="$fx/pr8.md" bash "$skill/scripts/review-brief.sh" "$fp" ${a[@]+"${a[@]}"} "$@" ;;
    R) bash "$skill/scripts/review-brief.sh" "$fp" --previous prev8.md --blast-radius blast8.md ${a[@]+"${a[@]}"} "$@" ;;
    S) d8=".scratch/review/sweep-$h"; bash "$skill/scripts/review-brief.sh" --paths "$hooks/x.sh" --commits HEAD --blast-radius blast8.md ${a[@]+"${a[@]}"} "$@" ;;
  esac > out8 2> err8
  code=$?
  set -e
  unset FAKE_ISSUE_BODY
  [ "$kind" = cc ] || git switch -q "$br8"
}
# where8 <column>: the grounding's source as the risk refusal names it.
where8() { if [ "$1" = P ]; then echo "the PR body's Blast Radius section"; else echo blast8.md; fi; }
# rr8 <where> <line>..., rf8 <line>...: the two refusals, each offending line after the header;
# rz8 <heading>...: #139's refusal, each heading line after the header.
rr8() { local w="$1"; shift; printf 'review-brief: the blast-radius grounding (%s) has risk lines without a disposition; every line under a `## Risks` or `### Risks` heading that is not indented deeper or fenced is a risk and ends with `fixed: <sha>` (a commit in HEAD'"'"'s history) or `accepted: <reason>` as plain text; indent a continuation, fence a proof, and write the heading exactly that way:' "$w"; printf '\n  %s' "$@"; }
rf8() { printf 'review-brief: ticket #7 has Writer flags without a disposition; every line under a `### Writer flags <YYYY-MM-DD>` heading that is not indented deeper or fenced is a flag and ends with `fixed: <sha>` (a commit in HEAD'"'"'s history) or `accepted: <reason>` as plain text; indent a continuation, fence a proof, and write the heading exactly that way:'; printf '\n  %s' "$@"; }
rz8() { printf 'review-brief: ticket #7 has a writer flags heading and no flag could be read from its body; flags are read only under an unfenced, unquoted line that is exactly `### Writer flags <YYYY-MM-DD>`, one flag per line with its disposition; the headings found:'; printf '\n  %s' "$@"; }
nd='no disposition'
na='`accepted:` has no reason'
fo='a fence opened here never closes'
nmr='not the heading `## Risks` or `### Risks`'
nmf='not the heading `### Writer flags <YYYY-MM-DD>`'
nc8() { printf '`fixed: %s` is not a commit id (7 to 40 lowercase hex characters)' "$1"; }
nr8() { printf '`fixed: %s` does not resolve to a commit here' "$1"; }
nh8() { printf '`fixed: %s` is not in HEAD'"'"'s history' "$1"; }
np8="review-brief: the diff is not cross-cutting; blast8.md is not pasted"
# refused8 <label> <stderr>: exit 1, exactly that stderr, and neither the review state nor the review directory.
refused8() {
  if [ "$code" != 1 ] || [ "$(cat err8)" != "$2" ] || [ -e .claude/state/review ] || [ -e "$d8" ]; then
    echo "FAIL $1: exit $code, wanted 1, the refusal and no state"; echo "  got:"; cat err8; echo "  wanted:"; printf '%s\n' "$2"; exit 1
  fi
  n=$((n + 1))
}
# briefed8 <label> <stderr>: exit 0, exactly that stderr (empty: none), both briefs and the review state.
briefed8() {
  if [ "$code" != 0 ] || [ "$(cat err8)" != "$2" ] || [ ! -s "$d8/standards-brief.md" ] || [ ! -s "$d8/spec-brief.md" ] || [ "$(cat .claude/state/review/dir 2>/dev/null)" != "$d8" ]; then
    echo "FAIL $1: exit $code, wanted 0, both briefs in $d8 and the state, stderr: $2"; echo "  got:"; cat err8; exit 1
  fi
  n=$((n + 1))
}
# plus8 <label>: briefed8 with nothing on stderr; both briefs carry `## Blast radius` and every
# line of the grounding that is not blank or a heading, dispositions included, and the Spec brief's
# Walk bullet ends with the risk sentence.
plus8() {
  local f l
  briefed8 "$1" ""
  for f in "$d8/standards-brief.md" "$d8/spec-brief.md"; do
    has "$f" "## Blast radius" "$1: $f has the blast-radius section"
    while IFS= read -r l; do
      l="${l%$'\r'}"
      case "$l" in ''|'#'*) ;; *) has "$f" "$l" "$1: $f carries the grounding line" ;; esac
    done < blast8.md
  done
  has "$d8/spec-brief.md" "${spec_bullets[0]} $risk_rule" "$1: the Walk bullet ends with the risk sentence"
}
# nospec8 <label> <stderr>: exit 0, exactly that stderr, the Standards brief alone and the no-spec line last.
nospec8() {
  if [ "$code" != 0 ] || [ "$(cat err8)" != "$2" ] || [ "$(tail -1 out8)" != "no spec: Standards axis only" ] || [ ! -s "$d8/standards-brief.md" ] || [ -e "$d8/spec-brief.md" ]; then
    echo "FAIL $1: exit $code, wanted 0, the Standards brief alone and the no-spec line, stderr: $2"; echo "  got:"; cat out8 err8; exit 1
  fi
  n=$((n + 1))
}
# Table A. Risks OK: risk 1 fixed at HEAD, risk 2 accepted; one risk bare: risk 2 has none.
risks8 ok '1. A subagent inherits it: `.claude/hooks/x.sh:1`. fixed: <H>' '2. factory-start at day zero runs it accepted: the hook exits 0 before any skill'
risks8 bare '1. A subagent inherits it: `.claude/hooks/x.sh:1`. fixed: <H>' '2. factory-start at day zero runs it'
flags8 fok '1. flag one fixed: <H>' '2. flag nine: the table misses a row accepted: filed #130'
flags8 fbare '1. flag one fixed: <H>' '2. flag nine: the table misses a row'
go8 nc F bare -; briefed8 "(A1/F)" "$np8"
go8 nc P bare -; briefed8 "(A1/P)" ""
rg8="review-brief: cross-cutting diff ($hooks/x.sh) without a blast-radius grounding; run the blast-radius skill, put the result in the PR body's Blast Radius section or pass --blast-radius FILE"
go8 cc F - -; refused8 "(A2/F)" "$rg8"
go8 cc P - -; refused8 "(A2/P)" "$rg8"
for c in F P R S; do go8 cc "$c" ok -; plus8 "(A3/$c)"; done
for c in F P R S; do go8 cc "$c" bare -; refused8 "(A4/$c)" "$(rr8 "$(where8 "$c")" "$nd: 2. factory-start at day zero runs it")"; done
for c in F P R S; do go8 cc "$c" ok fbare; refused8 "(A5/$c)" "$(rf8 "$nd: 2. flag nine: the table misses a row")"; done
go8 nc F ok fbare; refused8 "(A6/F)" "$np8
$(rf8 "$nd: 2. flag nine: the table misses a row")"
go8 nc P ok fbare; refused8 "(A6/P)" "$(rf8 "$nd: 2. flag nine: the table misses a row")"
for c in F P; do go8 cc "$c" bare fbare; refused8 "(A7/$c)" "$(rr8 "$(where8 "$c")" "$nd: 2. factory-start at day zero runs it")"; done
for c in F P; do
  go8 cc "$c" ok fok
  plus8 "(A8/$c)"
  has "$d8/spec-brief.md" "### Writer flags 2026-09-23" "(A8/$c): the Spec brief carries the list"
  has "$d8/spec-brief.md" "1. flag one fixed: $hk" "(A8/$c): the Spec brief carries flag 1"
  has "$d8/spec-brief.md" "2. flag nine: the table misses a row accepted: filed #130" "(A8/$c): the Spec brief carries flag 2"
done
for c in F P; do go8 cc "$c" ok none; nospec8 "(A9/$c)" ""; done
printf 'could not resolve to an issue\n' > issue-error
for c in F P; do go8 cc "$c" ok -; nospec8 "(A10/$c)" "review-brief: gh could not fetch #7 (could not resolve to an issue); no spec"; done
rm issue-error
# Table B: column r under `## Risks` in the grounding, cross-cutting, form F, the fixed body; column
# f under `### Writer flags 2026-09-23` in the ticket body, not cross-cutting, no grounding.
risks8 b1 '1. text fixed: <H>'; go8 cc F b1 -; plus8 "(B1/r)"
flags8 fb1 '1. text fixed: <H>'; go8 nc P - fb1; briefed8 "(B1/f)" ""
risks8 b2 '1. text accepted: out of scope, #130'; go8 cc F b2 -; plus8 "(B2/r)"
risks8 b3 '1. text'; go8 cc F b3 -; refused8 "(B3/r)" "$(rr8 blast8.md "$nd: 1. text")"
flags8 fb3 '1. text'; go8 nc P - fb3; refused8 "(B3/f)" "$(rf8 "$nd: 1. text")"
risks8 b4 '- a bullet item'; go8 cc F b4 -; refused8 "(B4/r)" "$(rr8 blast8.md "$nd: - a bullet item")"
risks8 b5 '1. first half' 'second half accepted: ok'; go8 cc F b5 -; refused8 "(B5/r)" "$(rr8 blast8.md "$nd: 1. first half")"
b6=('1. a accepted: ok' '   an indented continuation with no disposition' '```' '## x' '1. y' '```' '2. b fixed: <H>')
risks8 b6 "${b6[@]}"; go8 cc F b6 -; plus8 "(B6/r)"
flags8 fb6 "${b6[@]}"; go8 nc P - fb6; briefed8 "(B6/f)" ""
risks8 b7 '1. the binary is not fixed: it stays stale'; go8 cc F b7 -; refused8 "(B7/r)" "$(rr8 blast8.md "$(nc8 'it stays stale'): 1. the binary is not fixed: it stays stale")"
risks8 b8 '1. text fixed: 1234abc'; go8 cc F b8 -; refused8 "(B8/r)" "$(rr8 blast8.md "$(nr8 1234abc): 1. text fixed: 1234abc")"
risks8 b9 '1. text fixed: <X>'; go8 cc F b9 -; refused8 "(B9/r)" "$(rr8 blast8.md "$(nh8 "$x8"): 1. text fixed: $x8")"
risks8 b10 '1. text accepted:'; go8 cc F b10 -; refused8 "(B10/r)" "$(rr8 blast8.md "$na: 1. text accepted:")"
risks8 b11 '1. text accepted: partly, then fixed: <H>'; go8 cc F b11 -; plus8 "(B11/r)"
risks8 b12 '1. text fixed: <H> (the second commit)'; go8 cc F b12 -; refused8 "(B12/r)" "$(rr8 blast8.md "$(nc8 "$hk (the second commit)"): 1. text fixed: $hk (the second commit)")"
risks8 b13 '1. text `fixed: <H>`'; go8 cc F b13 -; refused8 "(B13/r)" "$(rr8 blast8.md "$nd: 1. text \`fixed: $hk\`")"
risks8 b14 '1. text fixed: ABCDEF1'; go8 cc F b14 -; refused8 "(B14/r)" "$(rr8 blast8.md "$(nc8 ABCDEF1): 1. text fixed: ABCDEF1")"
risks8 b15 '1. a accepted: ok' '```sh' '2. hidden'; go8 cc F b15 -; refused8 "(B15/r)" "$(rr8 blast8.md "$fo: \`\`\`sh")"
flags8 fb15 '1. a accepted: ok' '```sh' '2. hidden'; go8 nc P - fb15; refused8 "(B15/f)" "$(rf8 "$fo: \`\`\`sh")"
risks8 b16 '1. a accepted: ok' '#### Risks' '2. b'; go8 cc F b16 -; refused8 "(B16/r)" "$(rr8 blast8.md "$nmr: #### Risks" "$nd: 2. b")"
flags8 fb16 '1. a accepted: ok' '#### Writer flags 2026-09-23' '2. b'; go8 nc P - fb16; refused8 "(B16/f)" "$(rf8 "$nmf: #### Writer flags 2026-09-23" "$nd: 2. b")"
risks8 b17 '1. a accepted: ok' '#### Proof'; go8 cc F b17 -; refused8 "(B17/r)" "$(rr8 blast8.md "$nd: #### Proof")"
risks8 b18; go8 cc F b18 -; plus8 "(B18/r)"
risks8 b19 '  1. a accepted: ok' '  2. b'; go8 cc F b19 -; refused8 "(B19/r)" "$(rr8 blast8.md "$nd:   2. b")"
risks8 b20 '1. a accepted: ok' '## Risks' '2. b'; go8 cc F b20 -; refused8 "(B20/r)" "$(rr8 blast8.md "$nd: 2. b")"
risks8 b21 '1. a accepted: ok' '## Cleared' 'prose with no disposition'; go8 cc F b21 -; plus8 "(B21/r)"
risks8 b22 '1. text fixed: <H>   '
awk '{ printf "%s\r\n", $0 }' f8/b22 > f8/b22.crlf
mv f8/b22.crlf f8/b22
go8 cc F b22 -; plus8 "(B22/r)"
# Table C: column r a line in the grounding before an exact `## Risks` whose one risk is settled,
# cross-cutting; column f a line in a ticket body with no list, not cross-cutting.
ground8 c1 'Risks:'; go8 cc F c1 -; refused8 "(C1/r)" "$(rr8 blast8.md "$nmr: Risks:")"
body8 fc1 'Writer flags:'; go8 nc P - fc1; refused8 "(C1/f)" "$(rf8 "$nmf: Writer flags:")"
ground8 c2 '## Cleared' '' '#### Risks'; go8 cc F c2 -; refused8 "(C2/r)" "$(rr8 blast8.md "$nmr: #### Risks")"
body8 fc2 '## Writer flags 2026-09-23'; go8 nc P - fc2; refused8 "(C2/f)" "$(rf8 "$nmf: ## Writer flags 2026-09-23")"
ground8 c3 '### Risks (two)'; go8 cc F c3 -; refused8 "(C3/r)" "$(rr8 blast8.md "$nmr: ### Risks (two)")"
body8 fc3 '### Writer flags 2026-09-23 (PR #99)'; go8 nc P - fc3; refused8 "(C3/f)" "$(rf8 "$nmf: ### Writer flags 2026-09-23 (PR #99)")"
ground8 c4 '## risks'; go8 cc F c4 -; refused8 "(C4/r)" "$(rr8 blast8.md "$nmr: ## risks")"
body8 fc4 '### writer flags 2026-09-23'; go8 nc P - fc4; refused8 "(C4/f, lowercase)" "$(rf8 "$nmf: ### writer flags 2026-09-23")"
body8 fc4d '### Writer flags'; go8 nc P - fc4d; refused8 "(C4/f, no date)" "$(rf8 "$nmf: ### Writer flags")"
ground8 c5 '**Risks**'; go8 cc F c5 -; refused8 "(C5/r)" "$(rr8 blast8.md "$nmr: **Risks**")"
body8 fc5 '**Writer flags 2026-09-23**'; go8 nc P - fc5; refused8 "(C5/f)" "$(rf8 "$nmf: **Writer flags 2026-09-23**")"
ground8 c6 '```md' '## Risks' '' '1. bare' '```'; go8 cc F c6 -; plus8 "(C6/r)"
body8 fc6 '```md' '### Writer flags 2026-09-23' '' '1. bare' '```'; go8 nc P - fc6; refused8 "(C6/f, #139)" "$(rz8 '### Writer flags 2026-09-23')"
ground8 c7 'Risks here are low.' '- **Risks.** day zero: x.sh:1'; go8 cc F c7 -; plus8 "(C7/r)"
body8 fc7 "- [ ] A writer's flags reach the ticket under \`## Testing decisions\` (or \`## Design\`) as a dated \`Writer flags\` list with a disposition per flag, and the brief refuses when the ticket body carries a \`Writer flags\` list with a flag that has none; a ticket with no such list is unaffected." 'Writer flags are recorded by the orchestrator.' '| C1 | a plain marker: `Risks:` (r), `Writer flags:` (f) | RR[`nm`] | RF[`nm`] |'
go8 nc P - fc7; briefed8 "(C7/f)" ""
# Ticket #139, table D, not cross-cutting, form P: a body with a writer flags heading line anywhere
# (after any list marker too) and no flag read from it is refused; D10 is the accepted hole, one read list lets a second pass.
go8 nc P - fok; briefed8 "(D1)" ""
flags8 fd2; go8 nc P - fd2; refused8 "(D2)" "$(rz8 '### Writer flags 2026-09-23')"
go8 nc P - fc6; refused8 "(D3)" "$(rz8 '### Writer flags 2026-09-23')"
body8 fd4 '```sh' 'echo open' '' '### Writer flags 2026-09-23' '' '1. a accepted: ok'; go8 nc P - fd4; refused8 "(D4)" "$(rz8 '### Writer flags 2026-09-23')"
body8 fd5 '> ### Writer flags 2026-09-23' '>' '> 1. a accepted: ok'; go8 nc P - fd5; refused8 "(D5)" "$(rz8 '> ### Writer flags 2026-09-23')"
body8 fd6 '### Writer-flags 2026-09-23' '' '1. a accepted: ok'; go8 nc P - fd6; refused8 "(D6)" "$(rz8 '### Writer-flags 2026-09-23')"
body8 fd7 '### Writer flag 2026-09-23' '' '1. a accepted: ok'; go8 nc P - fd7; refused8 "(D7)" "$(rz8 '### Writer flag 2026-09-23')"
go8 nc P - fc4; refused8 "(D8)" "$(rf8 "$nmf: ### writer flags 2026-09-23")"
go8 nc P - fc7; briefed8 "(D9)" ""
flags8 fd10 '1. flag one fixed: <H>' '2. flag nine: the table misses a row accepted: filed #130' '' '### Writer-flags 2026-09-24' '' '1. bare'; go8 nc P - fd10; briefed8 "(D10)" ""
body8 fd11 '- ### Writer flags 2026-09-23' '' '   1. bare'; go8 nc P - fd11; refused8 "(D11)" "$(rz8 '- ### Writer flags 2026-09-23')"
body8 fd11b '1. ### Writer flags 2026-09-23' '' '   1. bare'; go8 nc P - fd11b; refused8 "(D11b)" "$(rz8 '1. ### Writer flags 2026-09-23')"
body8 fd12 '```sh' '# writer flags are parsed here' '```'; go8 nc P - fd12; briefed8 "(D12)" ""
body8 fd13 '### **Writer flags** 2026-09-23' '' '1. a accepted: ok'; go8 nc P - fd13; refused8 "(D13)" "$(rz8 '### **Writer flags** 2026-09-23')"
body8 fd14 '### Writer  flags 2026-09-23' '' '1. a accepted: ok'; go8 nc P - fd14; refused8 "(D14)" "$(rz8 '### Writer  flags 2026-09-23')"
body8 fd15 "### Writer's flags 2026-09-23" '' '1. bare'; go8 nc P - fd15; refused8 "(D15)" "$(rz8 "### Writer's flags 2026-09-23")"
body8 fd16 '### Writers flags 2026-09-23' '' '1. a accepted: ok'; go8 nc P - fd16; refused8 "(D16)" "$(rz8 '### Writers flags 2026-09-23')"
# Criterion 5: the Opening a PR playbook's Blast Radius bullet and the blast-radius skill's hand-back show the disposition line.
has "$here/template/.agents/skills/poteto-mode/playbooks/opening-a-pr.md" 'Each line under `### Risks` is one risk and ends with its disposition as plain text, `fixed: <sha>` (the commit on this branch that fixes it) or `accepted: <reason>`, for example `` 1. A subagent inherits the hook before its skill is installed: `.claude/hooks/x.sh:12`. fixed: 3f2a9c1 ``' "opening-a-pr.md shows the disposition line (#108)"
has "$here/template/.agents/skills/blast-radius/SKILL.md" 'Once the author has acted on a risk, its line ends with the disposition, `fixed: <sha>` or `accepted: <reason>`, as in `` 1. A subagent inherits the hook: `.claude/hooks/x.sh:12`, likely, blocks every read. fixed: 3f2a9c1 ``.' "the blast-radius hand-back shows the disposition line (#108)"
}

suite project
suite factory
echo "ok $n assertions"
