#!/usr/bin/env bash
# Proves the tier contract's path resolution from every place a ticket can run.
# Usage: bash tier-proof.sh <empty scratch dir>
set -u
S="$1"; git --version
tier() { [ "$(cat "$(git rev-parse --git-common-dir)/../.claude/state/tier" 2>/dev/null)" = eco ] && echo eco || echo safe; }
check() { printf '%-34s common-dir=%-58s tier=%s\n' "$1" "$(git rev-parse --git-common-dir 2>&1 | head -1)" "$(tier)"; }
m="$S/main repo with spaces"; mkdir -p "$m"; cd "$m" && git init -q -b main && git commit -q --allow-empty -m i
mkdir -p sub/deep .claude/state
git worktree add -q .claude/worktrees/owner -b owner
git worktree add -q "$S/outside wt" -b out
echo "--- A1 no file"; cd "$m"; check "main top"; cd "$m/.claude/worktrees/owner"; check "nested worktree"
echo eco > "$m/.claude/state/tier"
echo "--- A3 eco in main"
cd "$m"; check "main top"; cd "$m/sub/deep"; check "main subdir"
cd "$m/.claude/worktrees/owner"; check "nested worktree top"
mkdir -p x; cd x; check "nested worktree subdir"
cd "$S/outside wt"; check "worktree outside main"
echo "--- A4 other content, read from the nested worktree"
cd "$m/.claude/worktrees/owner"
for v in ECO 'eco ' '' safe; do printf '%s\n' "$v" > "$m/.claude/state/tier"; check "value [$v]"; done
printf 'ECO\nfast\n' > "$m/.claude/state/tier"; check "two lines ECO/fast"
printf 'eco\n\n\n' > "$m/.claude/state/tier"; check "eco + blank lines"
printf 'eco\r\n' > "$m/.claude/state/tier"; check "eco CRLF"
echo "--- file only in a worktree session's own .claude/state"
rm -f "$m/.claude/state/tier"; mkdir -p "$m/.claude/worktrees/owner/.claude/state"
echo eco > "$m/.claude/worktrees/owner/.claude/state/tier"
cd "$m/.claude/worktrees/owner"; check "eco set in worktree only"
rm -f "$m/.claude/worktrees/owner/.claude/state/tier"
echo "--- outside any repo"; cd "$S"; check "no repo"
echo "--- submodule of main"
echo eco > "$m/.claude/state/tier"
lib="$S/lib"; mkdir -p "$lib"; (cd "$lib" && git init -q -b main && git commit -q --allow-empty -m l)
cd "$m" && git -c protocol.file.allow=always submodule add -q "$lib" vendor/lib >/dev/null 2>&1
cd "$m/vendor/lib"; check "inside a submodule"
echo "--- day zero: echo eco > .claude/state/tier with no .claude/state"
d="$S/fresh"; mkdir -p "$d"; cd "$d" && git init -q -b main
echo eco > .claude/state/tier; echo "exit=$?"
rm .claude/state/tier; echo "rm exit=$?"
