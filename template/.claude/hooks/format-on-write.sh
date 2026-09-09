#!/usr/bin/env bash
# Formats the file the agent just wrote. PostToolUse cannot block; always exit 0.
set -uo pipefail
input="$(cat)"
file="$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty')"
[ -n "$file" ] || exit 0
[ -f "$file" ] || exit 0
cd "${CLAUDE_PROJECT_DIR:-.}" && vp fmt --no-error-on-unmatched-pattern "$file" >/dev/null 2>&1 || true
exit 0
