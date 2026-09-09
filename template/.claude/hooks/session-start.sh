#!/usr/bin/env bash
# Prints the session mandate; on SessionStart, stdout becomes context Claude can see.
set -euo pipefail
cat "${CLAUDE_PROJECT_DIR:-.}/.claude/hooks/session-mandate.md"
