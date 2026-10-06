#!/usr/bin/env bash
# Feeds template/.claude/hooks/mode.sh the UserPromptSubmit JSON, one run per cell of the table under
# "## Testing decisions" on ticket #178, in its order. Asserts exit 0, stdout exactly, an empty stderr
# and the state file after. Exits 1 on the first miss.
set -euo pipefail
here="$(cd "$(dirname "$0")/../.." && pwd -P)"
hook="$here/template/.claude/hooks/mode.sh"
fx="$(mktemp -d)"
trap 'rm -rf "$fx"' EXIT
export CLAUDE_PROJECT_DIR="$fx"
today="$(date +%Y-%m-%d)"
planning="PHASE: planning. Matt's planning skills are in control (interview, spec, tickets). Do not invoke poteto-mode, do not write production code, decisions go to the human. Switch with /mode-build or by starting a ticket."
execute="PHASE: execute. New task? Playbook match or rigor needed -> invoke /poteto-mode. An issue reference (#N) -> the Ticket playbook. Casual turn or the user opts out -> don't."
nudge() { echo "LEDGER: 3 unreviewed entries; last retro $1. /factory-retro when convenient."; }

# ledger <absent|nostamp|recent|stale|template>: four dated entries, one promoted, so three unreviewed.
ledger() {
  rm -rf "$fx/docs"
  [ "$1" = absent ] && return
  mkdir -p "$fx/docs/agents"
  if [ "$1" = template ]; then
    cp "$here/template/docs/agents/ledger.md" "$fx/docs/agents/ledger.md"
    return
  fi
  {
    echo '# Ledger'
    echo '2026-09-01 | model | did a | wanted b'
    echo '2026-09-02 | model | did c | wanted d -> promoted 2026-09-10: rules/c.yml'
    echo '2026-09-03 | model | did e | wanted f'
    echo '2026-09-04 | model | did g | wanted h'
    case "$1" in
      recent) echo '<!-- retro 2020-01-01 -->'; echo "<!-- retro $today -->" ;;
      stale) echo '<!-- retro 2020-01-01 -->' ;;
    esac
  } > "$fx/docs/agents/ledger.md"
}

n=0
# expect <state before|none> <prompt> <state after|none> <stdout> <label>
expect() {
  rm -rf "$fx/.claude"
  if [ "$1" != none ]; then
    mkdir -p "$fx/.claude/state"
    echo "$1" > "$fx/.claude/state/mode"
  fi
  local out err code after
  set +e
  out="$(jq -cn --arg p "$2" '{hook_event_name:"UserPromptSubmit",prompt:$p}' | bash "$hook" 2>"$fx/stderr")"
  code=$?
  set -e
  err="$(cat "$fx/stderr")"
  after="$(cat "$fx/.claude/state/mode" 2>/dev/null || echo none)"
  if [ "$code" != 0 ] || [ "$out" != "$4" ] || [ -n "$err" ] || [ "$after" != "$3" ]; then
    echo "FAIL $5: exit $code, wanted 0; state $after, wanted $3"
    echo "  got:    $out"
    echo "  wanted: $4"
    [ -z "$err" ] || echo "  stderr: $err"
    exit 1
  fi
  n=$((n + 1))
}

ledger absent
expect execute  /to-spec              planning "$planning" "cell 1: R1 ledger absent, /to-spec flips to planning"
expect planning '/poteto-mode "#178"' execute  "$execute"  "cell 2: R1 ledger absent, /poteto-mode \"#178\" flips to execute"
expect planning hi                    planning "$planning" "cell 3: R1 ledger absent, hi leaves planning"

ledger nostamp
expect execute  /to-spec              planning "$(nudge never)
$planning" "cell 4: R2 no retro stamp, /to-spec flips to planning"
expect planning '/poteto-mode "#178"' execute  "$(nudge never)
$execute"  "cell 5: R2 no retro stamp, /poteto-mode \"#178\" flips to execute"
expect planning hi                    planning "$(nudge never)
$planning" "cell 6: R2 no retro stamp, hi leaves planning"

ledger recent
expect execute  /to-spec              planning "$planning" "cell 7: R3 stamps 2020-01-01 then today, /to-spec flips to planning"
expect planning '/poteto-mode "#178"' execute  "$execute"  "cell 8: R3 stamps 2020-01-01 then today, /poteto-mode \"#178\" flips to execute"
expect planning hi                    planning "$planning" "cell 9: R3 stamps 2020-01-01 then today, hi leaves planning"

ledger stale
expect execute  /to-spec              planning "$(nudge 2020-01-01)
$planning" "cell 10: R4 stamp 2020-01-01 only, /to-spec flips to planning"
expect planning '/poteto-mode "#178"' execute  "$(nudge 2020-01-01)
$execute"  "cell 11: R4 stamp 2020-01-01 only, /poteto-mode \"#178\" flips to execute"
expect planning hi                    planning "$(nudge 2020-01-01)
$planning" "cell 12: R4 stamp 2020-01-01 only, hi leaves planning"

ledger template
expect execute  /to-spec              planning "$planning" "cell 13: R5 the template's ledger, /to-spec flips to planning"
expect planning '/poteto-mode "#178"' execute  "$execute"  "cell 14: R5 the template's ledger, /poteto-mode \"#178\" flips to execute"
expect planning hi                    planning "$planning" "cell 15: R5 the template's ledger, hi leaves planning"
expect none     hi                    none     "$execute"  "cell 16: the template's ledger and no state file, hi defaults to execute"

echo "ok $n assertions"
