#!/usr/bin/env bash
# Runs template/.agents/skills/factory918/scripts/overlap.sh against a temp clone with a bare
# origin, two feature branches with open PRs (a fake gh on PATH answers `pr list` from a fixed
# JSON array and `issue view` from FAKE_BODY), and asserts the exit code and the output of each
# call: 0 and nothing when the ticket names no in-flight path, 1 with `program: none` and the PR
# line on overlap, 2 when .claude/state/program names the ticket, a directory token, a token under
# `## Diff` ignored, and --diff skipping the checked-out branch's own PR. Exits 1 on the first miss.
set -euo pipefail
here="$(cd "$(dirname "$0")/../.." && pwd -P)"
script="$here/template/.agents/skills/factory918/scripts/overlap.sh"
fx="$(mktemp -d)"
trap 'rm -rf "$fx"' EXIT
mkdir -p "$fx/bin"
cat > "$fx/bin/gh" <<'GH'
#!/bin/sh
case "$*" in
  "pr list"*) while [ "$1" != -q ]; do shift; done; echo '[{"number":1,"headRefName":"feat-a"},{"number":2,"headRefName":"feat-b"}]' | exec jq -r "$2" ;;
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
echo readme > README.md; echo a > docs/a.md; echo y > src/x/y.txt
git add -A && git commit -qm fixture
git clone -q --bare "$fx/clone" "$fx/origin"
git remote add origin "$fx/origin"
git fetch -q origin
git switch -qc feat-a && echo a2 >> docs/a.md && git commit -qam "feat-a" && git push -q -u origin feat-a
git switch -q main && git switch -qc feat-b && echo y2 >> src/x/y.txt && git commit -qam "feat-b" && git push -q -u origin feat-b
git switch -q main
# feat-b's remote ref goes away, so the script has to fetch it.
git update-ref -d refs/remotes/origin/feat-b

n=0
# check <name> <expected exit> <expected output> <args...>: runs the script and compares both.
check() {
  local name="$1" want="$2" out="$3" got code; shift 3
  set +e; got="$(bash "$script" "$@" 2>&1)"; code=$?; set -e
  if [ "$code" != "$want" ] || [ "$got" != "$out" ]; then
    echo "FAIL $name: exit $code, wanted $want"; echo "  got:    $got"; echo "  wanted: $out"; exit 1
  fi
  n=$((n + 1))
}

check "no argument" 64 "usage: overlap.sh N [--diff]"
export FAKE_BODY='## What to build

Edit `README.md` and `gh issue view` and `#9`.'
check "README.md only" 0 "" 9
export FAKE_BODY='Touches `docs/a.md`.'
check "docs/a.md, no program" 1 "$(printf 'program: none\n#1 feat-a: docs/a.md')" 9
mkdir -p .claude/state && echo 'sweep: #7 #9' > .claude/state/program
check "program names #9" 2 "$(printf 'program: sweep: #7 #9\n#1 feat-a: docs/a.md')" 9
check "program names #9, ticket is #42" 1 "$(printf 'program: sweep: #7 #9\n#1 feat-a: docs/a.md')" 42
check "a leading # on N" 2 "$(printf 'program: sweep: #7 #9\n#1 feat-a: docs/a.md')" '#9'
rm -rf .claude
export FAKE_BODY='Everything under `src/`, plus `docs/a.md`.'
check "directory token and a file" 1 "$(printf 'program: none\n#1 feat-a: docs/a.md\n#2 feat-b: src/x/y.txt')" 9
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
