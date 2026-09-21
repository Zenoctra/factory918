#!/usr/bin/env bash
# Runs template/.agents/skills/factory918/scripts/overlap.sh against a temp clone with a bare
# origin, two feature branches with open PRs (a fake gh on PATH answers `pr list` from a fixed
# JSON array and `issue view` from FAKE_BODY, and fails the call FAKE_GH_FAIL names), and asserts the exit code and the output of each
# call: 0 and nothing when the ticket names no in-flight path, 1 with `program: none` and the PR
# line on overlap, 2 when .claude/state/program names the ticket, a directory token, a token under
# `## Diff` ignored, --diff skipping the checked-out branch's own PR, a stale and a missing remote
# ref both fetched, a glob token naming nothing, and a failing gh or git diff aborting the run. Exits 1 on the first miss.
set -euo pipefail
here="$(cd "$(dirname "$0")/../.." && pwd -P)"
script="$here/template/.agents/skills/factory918/scripts/overlap.sh"
fx="$(mktemp -d)"
trap 'rm -rf "$fx"' EXIT
mkdir -p "$fx/bin"
cat > "$fx/bin/gh" <<'GH'
#!/bin/sh
two_prs='[{"number":1,"headRefName":"feat-a"},{"number":2,"headRefName":"feat-b"}]'
case "$*" in
  "$FAKE_GH_FAIL"*) echo "gh: $FAKE_GH_FAIL failed" >&2; exit 1 ;;
  "pr list"*) while [ "$1" != -q ]; do shift; done; printf '%s' "${FAKE_PRS:-$two_prs}" | exec jq -r "$2" ;;
  "issue view"*) printf '%s\n' "$FAKE_BODY" ;;
  *) echo "fake gh: unexpected args: $*" >&2; exit 2 ;;
esac
GH
chmod +x "$fx/bin/gh"
export PATH="$fx/bin:$PATH"
git init -q -b main "$fx/clone"
cd "$fx/clone"
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
echo z2 >> src/z.txt && git commit -qam "feat-b 2" && git push -q origin feat-b
git switch -q --orphan feat-x && echo orphan > orphan.txt && git add orphan.txt && git commit -qm "feat-x" && git push -q -u origin feat-x
git switch -q main
# feat-a's remote ref goes away and feat-b's is stale at its first commit, as another worktree's
# fetch leaves them, so the script has to fetch both.
git update-ref -d refs/remotes/origin/feat-a
git update-ref refs/remotes/origin/feat-b "$feat_b1"

n=0
# check <name> <expected exit> <expected output> <args...>: runs the script and compares both.
check() {
  local name="$1" want="$2" out="$3" got code; shift 3
  set +e; got="$("$script" "$@" 2>&1)"; code=$?; set -e
  if [ "$code" != "$want" ] || [ "$got" != "$out" ]; then
    echo "FAIL $name: exit $code, wanted $want"; echo "  got:    $got"; echo "  wanted: $out"; exit 1
  fi
  n=$((n + 1))
}

check "no argument" 64 "usage: overlap.sh N [--diff]"
export FAKE_GH_FAIL="issue view"
check "issue view fails" 1 "gh: issue view failed" 9
export FAKE_GH_FAIL="pr list"
check "pr list fails" 1 "gh: pr list failed" 9 --diff
export FAKE_GH_FAIL=none
export FAKE_PRS='[{"number":3,"headRefName":"feat-x"}]'
export FAKE_BODY='Touches `orphan.txt`.'
check "a PR head with no merge base" 128 "fatal: origin/main...origin/feat-x: no merge base" 9
unset FAKE_PRS
export FAKE_BODY='## What to build

Edit `README.md` and `gh issue view` and `#9`.'
check "README.md only" 0 "" 9
export FAKE_BODY='Touches `docs/a.md`.'
check "docs/a.md, no program" 1 "$(printf 'program: none\n#1 feat-a: docs/a.md')" 9
export FAKE_BODY='Touches `src/z.txt`, on feat-b after the stale remote ref.'
check "a path past the stale origin/feat-b" 1 "$(printf 'program: none\n#2 feat-b: src/z.txt')" 9
export FAKE_BODY='Everything under `src/*`.'
check "a glob token names nothing" 0 "" 9
export FAKE_BODY='Touches `docs/a.md`.'
mkdir -p .claude/state && echo 'sweep: #7 #9' > .claude/state/program
check "program names #9" 2 "$(printf 'program: sweep: #7 #9\n#1 feat-a: docs/a.md')" 9
check "program names #9, ticket is #42" 1 "$(printf 'program: sweep: #7 #9\n#1 feat-a: docs/a.md')" 42
check "a leading # on N" 2 "$(printf 'program: sweep: #7 #9\n#1 feat-a: docs/a.md')" '#9'
rm -rf .claude
export FAKE_BODY='Everything under `src/`, plus `docs/a.md`.'
check "directory token and a file" 1 "$(printf 'program: none\n#1 feat-a: docs/a.md\n#2 feat-b: src/x/y.txt src/z.txt')" 9
export FAKE_BODY='## Diff

`docs/a.md`

## Notes

`README.md`'
check "token under ## Diff ignored" 0 "" 9
git switch -q feat-a
check "--diff skips the own PR" 0 "" 9 --diff
git switch -qc feat-c && echo a3 >> docs/a.md && git commit -qam "feat-c"
check "--diff overlaps another PR" 1 "$(printf 'program: none\n#1 feat-a: docs/a.md')" 9 --diff
git switch -q main

echo "ok $n assertions"
