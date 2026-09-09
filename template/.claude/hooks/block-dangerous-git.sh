#!/usr/bin/env bash
# Adapted from mattpocock/skills git-guardrails-claude-code (MIT). PreToolUse on Bash: exit 2 blocks the command.
# Agents may push feature branches; they may never push main, force-push, or destroy local state.
set -euo pipefail
input="$(cat)"
cmd="$(printf '%s' "$input" | jq -r '.tool_input.command // ""')"
patterns=(
  'git push[^|;&]* (origin[/ ])?(main|master)( |$)'
  'push[^|;&]* --force( |$)'
  'push[^|;&]* -f( |$)'
  'git reset --hard'
  'git clean -f'
  'git branch -D'
  'git checkout \.'
  'git restore \.'
)
for p in "${patterns[@]}"; do
  if printf '%s' "$cmd" | grep -Eq -- "$p"; then
    echo "BLOCKED: '$cmd' matches dangerous pattern '$p'. The user has prevented you from doing this. Use --force-with-lease on your own branch, or ask." >&2
    exit 2
  fi
done
exit 0
