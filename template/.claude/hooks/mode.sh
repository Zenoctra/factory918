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
# Ledger nudge: entries not yet promoted, and how long since the last retro (factory-retro stamps one).
ledger="${CLAUDE_PROJECT_DIR:-.}/docs/agents/ledger.md"
if [ -f "$ledger" ]; then
  n="$(grep -c '^[0-9]\{4\}-[0-9][0-9]-[0-9][0-9] ' "$ledger" 2>/dev/null || true)"
  p="$(grep -c -- '-> promoted' "$ledger" 2>/dev/null || true)"
  last="$(grep -o '<!-- retro [0-9-]* -->' "$ledger" | tail -1 | grep -o '[0-9]\{4\}-[0-9-]*')"
  if [ "$n" -gt "$p" ] && { [ -z "$last" ] || [ "$(( ($(date +%s) - $(date -j -f %Y-%m-%d "$last" +%s 2>/dev/null || date -d "$last" +%s)) / 86400 ))" -ge 7 ]; }; then
    echo "LEDGER: $((n - p)) unreviewed entries; last retro ${last:-never}. /factory-retro when convenient."
  fi
fi
if [ "$mode" = planning ]; then
  echo "PHASE: planning. Matt's planning skills are in control (interview, spec, tickets). Do not invoke poteto-mode, do not write production code, decisions go to the human. Switch with /mode-build or by starting a ticket."
else
  echo "PHASE: execute. New task? Playbook match or rigor needed -> invoke /poteto-mode. An issue reference (#N) -> the Ticket playbook. Casual turn or the user opts out -> don't."
fi
# A review in progress: spec-review step 1 writes this state, step 5 clears it, delegation.sh reads it.
review="${CLAUDE_PROJECT_DIR:-.}/.claude/state/review"
if [ -f "$review/files" ]; then
  echo "REVIEW: $(cat "$review/fixed-point" 2>/dev/null || echo unknown), $(wc -l < "$review/files" | tr -d ' ') files under review; the orchestrator's reads of them are blocked until spec-review step 5 clears .claude/state/review"
fi
