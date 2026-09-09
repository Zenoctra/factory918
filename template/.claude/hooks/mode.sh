#!/usr/bin/env bash
# Phase guard. Runs on every UserPromptSubmit; its stdout is added to Claude's context each prompt.
# Planning commands flip the phase to "planning"; execution commands or an issue reference flip it to "execute".
set -euo pipefail
input="$(cat)"
prompt="$(printf '%s' "$input" | jq -r '.prompt // ""')"
state_dir="${CLAUDE_PROJECT_DIR:-.}/.claude/state"
mkdir -p "$state_dir"
f="$state_dir/mode"
case "$prompt" in
  /grill-with-docs*|/grill-me*|/wayfinder*|/to-spec*|/to-tickets*|/mode-plan*) echo planning > "$f" ;;
  /poteto-mode*|/how*|/why*|/architect*|/tdd*|/mode-build*|*"#"[0-9]*)         echo execute  > "$f" ;;
esac
mode="$(cat "$f" 2>/dev/null || echo execute)"
if [ "$mode" = planning ]; then
  echo "PHASE: planning. Matt's planning skills are in control (interview, spec, tickets). Do not invoke poteto-mode, do not write production code, decisions go to the human. Switch with /mode-build or by starting a ticket."
else
  echo "PHASE: execute. New task? Playbook match or rigor needed -> invoke /poteto-mode. An issue reference (#N) -> the Ticket playbook. Casual turn or the user opts out -> don't."
fi
