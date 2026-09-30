#!/usr/bin/env bash
# Runs the unmodified delegation hook on the calls an eco ticket makes, with the tier file absent,
# eco and junk, in execute with a review state live. Prints exit code and stderr for each; the
# claim is that every row is identical across the three tiers.
# Usage: bash hook-proof.sh <repo root> <empty scratch dir>
set -u
hook="$1/template/.claude/hooks/delegation.sh"; fx="$2"
mkdir -p "$fx"; cd "$fx" || exit 1
git init -q; git config user.email t@t.invalid; git config user.name t
seq 1 250 | sed 's/^/echo /' > big.sh; seq 1 10 > small.md
mkdir -p docs/agents .claude/state/review .scratch/review/main
echo ledger > docs/agents/ledger.md; echo x > SOURCES.md; echo x > patches.series
git add -A; git commit -qm f
echo execute > .claude/state/mode
echo main > .claude/state/review/fixed-point; echo big.sh > .claude/state/review/files
echo .scratch/review/main > .claude/state/review/dir; echo d > .scratch/review/main/diff
export CLAUDE_PROJECT_DIR="$fx"
run() { # who tool input label
  local extra='{}'; [ "$1" = agent ] && extra='{"agent_id":"a1","agent_type":"general-purpose"}'
  local err code
  err="$(jq -cn --arg t "$2" --argjson i "$3" --arg c "$fx" --argjson e "$extra" \
    '{session_id:"s",hook_event_name:"PreToolUse",cwd:$c,tool_name:$t,tool_input:$i} + $e' \
    | bash "$hook" 2>&1 >/dev/null)"; code=$?
  printf '%s|%s|%s\n' "$4" "$code" "$(printf '%s' "$err" | cut -c1-60)"
}
edit() { jq -cn --arg p "$fx/$1" --arg o "$2" --arg n "$3" '{file_path:$p,old_string:$o,new_string:$n}'; }
path() { jq -cn --arg p "$fx/$1" '{file_path:$p}'; }
cmd() { jq -cn --arg c "$1" '{command:$c}'; }
rows() {
  run orchestrator Edit "$(edit small.md 1 one)" "B1 orch Edit small.md"
  run orchestrator Edit "$(edit big.sh 'echo 1' 'echo 0')" "B2 orch Edit big.sh"
  run orchestrator Bash "$(cmd 'echo x >> small.md')" "B3 orch echo >> small.md"
  run orchestrator Write "$(path docs/agents/ledger.md)" "B4 orch Write ledger"
  run orchestrator Write "$(path .claude/state/tier)" "B5 orch Write tier"
  run orchestrator Bash "$(cmd 'bash .claude/skills/spec-review/scripts/review-brief.sh main')" "B6 orch review-brief"
  run agent Edit "$(edit small.md 1 one)" "B7 agent Edit small.md"
  run orchestrator Bash "$(cmd '[ "$(cat "$(git rev-parse --git-common-dir)/../.claude/state/tier" 2>/dev/null)" = eco ]')" "X1 orch reads tier under review"
  run orchestrator Write "$(path SOURCES.md)" "X2 orch Write SOURCES.md (records commit)"
}
rm -f .claude/state/tier; rows > "$fx/none.txt"
echo eco > .claude/state/tier; rows > "$fx/eco.txt"
printf 'ECO\nfast\n' > .claude/state/tier; rows > "$fx/junk.txt"
cat "$fx/none.txt"
echo "--- diff none vs eco:"; diff "$fx/none.txt" "$fx/eco.txt" && echo identical
echo "--- diff none vs junk:"; diff "$fx/none.txt" "$fx/junk.txt" && echo identical
echo "--- tier is read nowhere in the hook:"; grep -c tier "$hook"
