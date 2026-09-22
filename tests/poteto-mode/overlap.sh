#!/usr/bin/env bash
# Runs template/.agents/skills/poteto-mode/scripts/overlap.sh against a temp clone with a bare
# origin and three open PRs (a fake gh on PATH answers `pr list` from FAKE_PRS, each PR carrying the
# ticket it closes, `issue view` from FAKE_BODY, and fails the call FAKE_GH_FAIL names), and asserts
# the exit code and the output of each call in the order of the scenario table in the ticket's
# design: usage, no origin remote, a failing gh, a head with no merge base, tokens that name no path
# or lie outside the repository, one PR shared, a deleted and a stale remote ref both fetched, a file
# a PR creates, a stacked PR reporting only its own commits, a glob and both directory forms,
# `## Diff` skipped, two PRs in ascending number, gos that cover and gos that do not, the base as the
# head that contains the others, a one-off go appended under a program's line, a dead program's
# line, a linked worktree reading the main checkout's file, --diff skipping the own PR and counting
# only the branch's own commits, a literal token under --diff, and the mode bit. The fixture root
# has a space, and from the third call on the script runs by the relative path the playbooks name.
# Exits 1 on the first miss. The backticks in the bodies below are the ticket's token delimiters,
# not command substitutions.
# shellcheck disable=SC2016
set -euo pipefail
here="$(cd "$(dirname "$0")/../.." && pwd -P)"
script="$here/template/.agents/skills/poteto-mode/scripts/overlap.sh"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
fx="$tmp/with space"
mkdir -p "$fx/bin"
cat > "$fx/bin/gh" <<'GH'
#!/bin/sh
prs='[{"number":2,"headRefName":"feat-b","closingIssuesReferences":[{"number":8}]},{"number":1,"headRefName":"feat-a","closingIssuesReferences":[{"number":7}]},{"number":4,"headRefName":"feat-b2","closingIssuesReferences":[{"number":10}]}]'
case "$*" in
  "${FAKE_GH_FAIL:-none}"*) echo "gh: $FAKE_GH_FAIL failed" >&2; exit 2 ;;
  "pr list"*) while [ "$1" != -q ]; do shift; done; printf '%s' "${FAKE_PRS:-$prs}" | exec jq -r "$2" ;;
  "issue view"*) printf '%s\n' "$FAKE_BODY" ;;
  *) echo "fake gh: unexpected args: $*" >&2; exit 2 ;;
esac
GH
chmod +x "$fx/bin/gh"
export PATH="$fx/bin:$PATH"
git init -q -b main "$fx/clone"
cd "$fx/clone"
# The path the playbooks name, through the symlink every project and the factory carry; it is in
# the fixture commit, so a worktree has it too.
mkdir .claude && ln -s "$here/template/.agents/skills" .claude/skills
git config user.email test@factory918.invalid
git config user.name test
mkdir -p docs src/x
echo readme > README.md; echo a > docs/a.md; echo y > src/x/y.txt; echo z > src/z.txt
git add -A && git commit -qm fixture
git clone -q --bare "$fx/clone" "$fx/origin"
git remote add origin "$fx/origin"
git fetch -q origin
git switch -qc feat-a && echo a2 >> docs/a.md && git commit -qam "feat-a" && git push -q -u origin feat-a
git switch -q main && git switch -qc feat-b && echo y2 >> src/x/y.txt && git commit -qam "feat-b" && git push -q -u origin feat-b
feat_b1="$(git rev-parse HEAD)"
echo z2 >> src/z.txt && echo new > src/new.txt && git add src/new.txt && git commit -qam "feat-b 2" && git push -q origin feat-b
git switch -qc feat-b2 && echo z3 >> src/z.txt && git commit -qam "feat-b2" && git push -q -u origin feat-b2
git switch -q main && git switch -qc feat-e && echo i > docs/i.md && git add docs/i.md && git commit -qm "feat-e" && git push -q -u origin feat-e
git switch -q --orphan feat-x && echo orphan > orphan.txt && git add orphan.txt && git commit -qm "feat-x" && git push -q -u origin feat-x
git switch -q main
# feat-a's remote ref goes away and feat-b's is stale at its first commit, as another worktree's
# fetch leaves them, so the script has to fetch both.
git update-ref -d refs/remotes/origin/feat-a
git update-ref refs/remotes/origin/feat-b "$feat_b1"
# A repository with no remote at all.
git init -q -b main "$fx/lone"
mkdir "$fx/lone/.claude" && ln -s "$here/template/.agents/skills" "$fx/lone/.claude/skills"

n=0
prog=.claude/state/program
fail() { echo "FAIL $1"; echo "  got:    $2"; echo "  wanted: $3"; exit 1; }
# run <args...>: the script from the current directory, its exit in code and stdout plus stderr in got.
run() { set +e; got="$("$script" "$@" 2>&1)"; code=$?; set -e; }
# check <name> <exit> <output> <args...>: both exact.
check() {
  local name="$1" want="$2" out="$3"; shift 3
  run "$@"
  if [ "$code" != "$want" ] || [ "$got" != "$out" ]; then fail "$name" "exit $code: $got" "exit $want: $out"; fi
  n=$((n + 1))
}
# check_err <name> <exit> <pattern> <args...>: the exit exact, the output holding the pattern.
check_err() {
  local name="$1" want="$2" pat="$3"; shift 3
  run "$@"
  if [ "$code" != "$want" ] || ! grep -q -- "$pat" <<< "$got"; then fail "$name" "exit $code: $got" "exit $want with $pat"; fi
  n=$((n + 1))
}
# same <name> <wanted> <got>
same() { [ "$2" = "$3" ] || fail "$1" "$3" "$2"; n=$((n + 1)); }

usage='usage: overlap.sh N [--diff] | overlap.sh go "<label>" N...'
check "1 no argument" 64 "$usage"
check "2 a third argument" 64 "$usage" 9 --diff x
check "2 a flag other than --diff" 64 "$usage" 9 --record
script=.claude/skills/poteto-mode/scripts/overlap.sh
check "3 go with no ticket" 64 "$usage" go sweep
export FAKE_BODY='Touches `docs/a.md`.'
cd "$fx/lone"
check "4 no origin remote" 0 $'no origin remote; nothing in flight\ngo: none\nbase: main' 9
cd "$fx/clone"
export FAKE_GH_FAIL="issue view"
check "5 gh issue view fails" 2 "gh: issue view failed" 9
export FAKE_GH_FAIL="pr list"
git switch -q feat-a
check "6 gh pr list fails under --diff" 2 "gh: pr list failed" 9 --diff
git switch -q main
unset FAKE_GH_FAIL
export FAKE_PRS='[{"number":3,"headRefName":"feat-x","closingIssuesReferences":[]}]'
check_err "7 a head with no merge base" 2 "no merge base" 9
unset FAKE_PRS
export FAKE_BODY='## What to build

Edit `README.md`, then `gh issue view` on `#9`.'
check "8 tokens no PR touches" 0 $'go: none\nbase: origin/main' 9
export FAKE_BODY='Edits nothing in particular.'
check "9 a body with no token" 0 $'go: none\npaths: none\nbase: origin/main' 9
export FAKE_BODY='Edits `nothing/here.md` with `set -e` under `{docs,src}`.'
check "10 tokens that are no path" 0 $'go: none\nbase: origin/main' 9
export FAKE_BODY='Reads `../x`.'
check_err "11 a token outside the repository" 2 "outside repository" 9
export FAKE_BODY='Touches `docs/a.md`.'
check "12 one PR shared, no go" 1 $'go: none\n#1 feat-a: docs/a.md' 9
same "12 the deleted origin/feat-a was fetched" "$(git rev-parse feat-a)" "$(git rev-parse origin/feat-a)"
export FAKE_BODY='Touches `src/z.txt`.'
check "13 a path past the stale origin/feat-b, siblings" 1 $'go: none\n#2 feat-b: src/z.txt\n#4 feat-b2: src/z.txt' 9
export FAKE_BODY='Adds `src/new.txt`, which feat-b creates.'
check "14 a file a PR creates" 1 $'go: none\n#2 feat-b: src/new.txt' 9
export FAKE_BODY='Everything under `src/*`.'
check "15 a glob token" 1 $'go: none\n#2 feat-b: src/new.txt src/x/y.txt src/z.txt\n#4 feat-b2: src/z.txt' 9
export FAKE_BODY='Everything under `src`, that is `src/`.'
check "16 both directory forms" 1 $'go: none\n#2 feat-b: src/new.txt src/x/y.txt src/z.txt\n#4 feat-b2: src/z.txt' 9
export FAKE_BODY='## Diff

`docs/a.md`

## Notes

`README.md`'
check "17 a token under ## Diff ignored" 0 $'go: none\nbase: origin/main' 9
export FAKE_BODY='Touches `docs/a.md` and `src/x/y.txt`.'
# The fake lists PR 2 first; the output is sorted by PR number.
check "18 two PRs in ascending number" 1 $'go: none\n#1 feat-a: docs/a.md\n#2 feat-b: src/x/y.txt' 9
check "19 go writes the line" 0 "" go sweep 7 9
same "19 the line" 'sweep: #7 #9' "$(cat "$prog")"
rm "$prog"
# The documented form, typed at a shell: bare numbers, since `#4` would open a comment.
bash -c '.claude/skills/poteto-mode/scripts/overlap.sh go "autopilot-stack" 4 5 8'
same "19 the documented form typed at a shell" 'autopilot-stack: #4 #5 #8' "$(cat "$prog")"
rm "$prog"
check "19 go accepts #9" 0 "" go sweep 7 '#9'
same "19 the line from #9" 'sweep: #7 #9' "$(cat "$prog")"
export FAKE_BODY='Touches `docs/a.md`.'
check "20 a go covering one PR" 0 $'go: sweep\n#1 feat-a: docs/a.md\nbase: origin/feat-a' 9
check "21 a go not naming the ticket" 1 $'go: none\n#1 feat-a: docs/a.md' 42
rm "$prog"
check "22 go s2" 0 "" go s2 9
check "22 a go naming the ticket but not the PR's" 1 $'go: s2\n#1 feat-a: docs/a.md' 9
rm "$prog"
check "22 the one-off go names both tickets" 0 "" go "stack on #7" 9 7
check "22 the one-off go covers the stack" 0 $'go: stack on #7\n#1 feat-a: docs/a.md\nbase: origin/feat-a' 9
rm "$prog"
check "23 go sweep 7 8 9" 0 "" go sweep 7 8 9
export FAKE_BODY='Touches `docs/a.md` and `src/x/y.txt`.'
check "23 siblings covered, the lowest number's head" 0 $'go: sweep\n#1 feat-a: docs/a.md\n#2 feat-b: src/x/y.txt\nbase: origin/feat-a' 9
rm "$prog"
check "24 go sweep 7 9" 0 "" go sweep 7 9
check "24 siblings, one PR's ticket not on a line" 1 $'go: sweep\n#1 feat-a: docs/a.md\n#2 feat-b: src/x/y.txt' 9
rm "$prog"
check "25 go sweep 8 9 10" 0 "" go sweep 8 9 10
export FAKE_PRS='[{"number":4,"headRefName":"feat-b2","closingIssuesReferences":[{"number":10}]},{"number":2,"headRefName":"feat-b","closingIssuesReferences":[{"number":8}]}]'
export FAKE_BODY='Touches `src/z.txt`.'
check "25 one head contains the other" 0 $'go: sweep\n#2 feat-b: src/z.txt\n#4 feat-b2: src/z.txt\nbase: origin/feat-b2' 9
unset FAKE_PRS
rm "$prog"
check "26 go sweep 7 9" 0 "" go sweep 7 9
export FAKE_BODY='Touches `README.md`.'
check "26 a go and no overlap" 0 $'go: sweep\nbase: origin/main' 9
rm "$prog"
check "27 go autopilot-stack 7 8" 0 "" go autopilot-stack 7 8
check "27 a one-off go appended" 0 "" go "stack on #1" 9
export FAKE_BODY='Touches `docs/a.md`.'
check "27 the one-off go covers with the program's line" 0 $'go: stack on #1\n#1 feat-a: docs/a.md\nbase: origin/feat-a' 9
same "27 the file has two lines, the first unchanged" $'autopilot-stack: #7 #8\nstack on #1: #9' "$(cat "$prog")"
export FAKE_BODY='Touches `src/z.txt`.'
check "28 a dead program's line, one PR's ticket on no line" 1 $'go: stack on #1\n#2 feat-b: src/z.txt\n#4 feat-b2: src/z.txt' 9
export FAKE_PRS='[{"number":2,"headRefName":"feat-b","closingIssuesReferences":[{"number":8}]}]'
check "28 a dead program's line covers across lines" 0 $'go: stack on #1\n#2 feat-b: src/z.txt\nbase: origin/feat-b' 9
unset FAKE_PRS
rm "$prog"
check "29 go wt 9 from the main checkout" 0 "" go wt 9
git worktree add -q --detach "$fx/wt"
export FAKE_BODY='Touches `README.md`.'
cd "$fx/wt"
check "29 a linked worktree reads the main checkout's file" 0 $'go: wt\nbase: origin/main' 9
cd "$fx/clone"
rm -rf .claude/state
git switch -q feat-a
check "30 --diff skips the own PR" 0 "" 9 --diff
git switch -q --detach
check "30 --diff on a detached HEAD" 2 "detached HEAD; run from the ticket's branch" 9 --diff
git switch -q feat-a
git switch -q main && git switch -qc feat-c && echo a3 >> docs/a.md && git commit -qam "feat-c"
check "31 --diff overlaps another PR" 1 $'go: none\n#1 feat-a: docs/a.md' 9 --diff
check "32 go sweep 7 9" 0 "" go sweep 7 9
git switch -qc feat-c2 origin/feat-a && echo a3 >> docs/a.md && git commit -qam "feat-c2"
check "32 --diff on a stack, the shared path from the own commit" 0 $'go: sweep\n#1 feat-a: docs/a.md' 9 --diff
git switch -qc feat-c3 origin/feat-a && echo r2 >> README.md && git commit -qam "feat-c3"
check "33 --diff on a stack, the parent's change not counted" 0 "" 9 --diff
git switch -qc feat-d origin/main && echo id > 'docs/[id].md' && git add docs && git commit -qm "feat-d"
export FAKE_PRS='[{"number":5,"headRefName":"feat-e","closingIssuesReferences":[{"number":11}]},{"number":1,"headRefName":"feat-a","closingIssuesReferences":[{"number":7}]}]'
check "34 --diff takes the own paths literally" 0 "" 9 --diff
unset FAKE_PRS
git switch -q main
test -x "$here/template/.agents/skills/poteto-mode/scripts/overlap.sh" || fail "35 the mode bit" "not executable" "executable"
n=$((n + 1))

echo "ok $n assertions"
