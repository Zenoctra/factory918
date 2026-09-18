#!/usr/bin/env bash
# Feeds template/.claude/hooks/delegation.sh the JSON Claude Code sends a PreToolUse hook
# (docs/M0-findings.md, "Hook input and sub-agent identity") and asserts the exit code and the
# BLOCKED line for each call. Exits 1 on the first miss.
set -euo pipefail
here="$(cd "$(dirname "$0")/../.." && pwd -P)"
hook="$here/template/.claude/hooks/delegation.sh"
fx="$(mktemp -d)"
trap 'rm -rf "$fx"' EXIT
cd "$fx"
git init -q
git config user.email test@factory918.invalid
git config user.name test
seq 1 250 | sed 's/^/echo /' > big.sh
seq 1 10 > small.md
mkdir -p docs/agents .scratch .claude/state
echo ledger > docs/agents/ledger.md
echo findings > docs/M0-findings.md
git add -A
git commit -qm fixture
echo scratch > .scratch/x.txt
echo execute > .claude/state/mode
export CLAUDE_PROJECT_DIR="$fx"

write_msg="BLOCKED: writing big.sh is a lane's job (P11). Brief a writer lane with the paths, the data shape and the success criteria, then review its diff. Your own files are docs/agents/*, DECISIONS.md, docs/M0-findings.md and the untracked directories."
cap_msg="BLOCKED: big.sh is 250 lines; reading it whole is the explorer lane's job. Read it in ranges with offset and limit (200 lines at most), ask /knowledge, or brief an explorer and read its report."
review_msg="BLOCKED: big.sh is under review (fixed point main); the orchestrator does not read the code under review. The reviewers have the diff in their briefs; wait for their reports, or rm -rf .claude/state/review to abandon the review."

n=0
code=0
err=""
# call <orchestrator|agent> <tool> <tool_input JSON>: runs the hook, sets code and err (stderr).
call() {
  local extra='{}'
  [ "$1" = agent ] && extra='{"agent_id":"a1b2c3","agent_type":"general-purpose"}'
  set +e
  err="$(jq -cn --arg cwd "$fx" --arg tool "$2" --argjson input "$3" --argjson extra "$extra" \
    '{session_id:"s1",transcript_path:"/tmp/t.jsonl",cwd:$cwd,scratchpad_dir:"/tmp/s",prompt_id:"p1",
      permission_mode:"default",effort:"high",hook_event_name:"PreToolUse",tool_name:$tool,
      tool_input:$input,tool_use_id:"u1"} + $extra' | bash "$hook" 2>&1 >/dev/null)"
  code=$?
  set -e
}
# expect <exit> <message> <who> <tool> <tool_input JSON> <label>
expect() {
  call "$3" "$4" "$5"
  if [ "$code" != "$1" ] || [ "$err" != "$2" ]; then
    echo "FAIL $6: exit $code, wanted $1"
    echo "  got:    $err"
    echo "  wanted: $2"
    exit 1
  fi
  n=$((n + 1))
}
path() { jq -cn --arg p "$fx/$1" '{file_path:$p}'; }
ranged() { jq -cn --arg p "$fx/$1" --argjson l "$2" '{file_path:$p,limit:$l}'; }
bash_cmd() { jq -cn --arg c "$1" '{command:$c}'; }

expect 2 "$write_msg" orchestrator Write "$(path big.sh)" "orchestrator Write to big.sh"
expect 2 "$write_msg" orchestrator Edit "$(path big.sh)" "orchestrator Edit of big.sh"
expect 2 "$cap_msg" orchestrator Bash "$(bash_cmd 'cat big.sh')" "cat big.sh"
expect 2 "$write_msg" orchestrator Bash "$(bash_cmd "sed -i '' s/a/b/ big.sh")" "sed -i big.sh"
expect 2 "$write_msg" orchestrator Bash "$(bash_cmd 'cat > big.sh <<EOF
echo hello
EOF')" "heredoc into big.sh"
expect 2 "$write_msg" orchestrator Bash "$(bash_cmd 'echo x | tee big.sh')" "tee big.sh"
expect 2 "$cap_msg" orchestrator Bash "$(bash_cmd 'git show HEAD:big.sh')" "git show HEAD:big.sh"
expect 2 "$cap_msg" orchestrator Bash "$(bash_cmd 'head -n 300 big.sh')" "head -n 300 big.sh"
expect 2 "$cap_msg" orchestrator Bash "$(bash_cmd "sed -n '10,\$p' big.sh")" "sed -n to the end"
expect 2 "$cap_msg" orchestrator Bash "$(bash_cmd "cat \"$fx/big.sh\"")" "cat of a quoted absolute path"
expect 2 "$cap_msg" orchestrator Read "$(path big.sh)" "Read big.sh whole"
expect 0 "" orchestrator Read "$(ranged big.sh 100)" "Read big.sh with limit"
expect 0 "" orchestrator Read "$(path small.md)" "Read small.md whole"
expect 0 "" orchestrator Bash "$(bash_cmd 'head -n 50 big.sh')" "head -n 50 big.sh"
expect 0 "" orchestrator Bash "$(bash_cmd "sed -n '1,50p' big.sh")" "sed -n ranged"
expect 0 "" orchestrator Bash "$(bash_cmd 'grep -n echo big.sh | wc -l')" "grep on big.sh"
expect 0 "" orchestrator Write "$(path .claude/state/todo.md)" "Write to .claude/state"
expect 0 "" orchestrator Write "$(path docs/agents/ledger.md)" "Write to the ledger"
expect 0 "" orchestrator Write "$(path docs/M0-findings.md)" "Write to the findings"
expect 0 "" orchestrator Write "$(path new-file.sh)" "Write to a file git does not track"
expect 0 "" orchestrator Bash "$(bash_cmd 'cat .scratch/x.txt')" "cat under .scratch"

mkdir -p .claude/state/review .scratch/review/main
echo main > .claude/state/review/fixed-point
echo big.sh > .claude/state/review/files
echo .scratch/review/main > .claude/state/review/dir
expect 0 "" orchestrator Read "$(path small.md)" "Read of an unlisted file under review"
expect 2 "$review_msg" orchestrator Read "$(ranged big.sh 5)" "ranged Read of big.sh under review"
expect 2 "$review_msg" orchestrator Bash "$(bash_cmd 'head -n 5 big.sh')" "head of big.sh under review"

expect 0 "" agent Write "$(path big.sh)" "sub-agent Write to big.sh"
expect 0 "" agent Bash "$(bash_cmd 'cat big.sh')" "sub-agent cat big.sh"
expect 0 "" agent Bash "$(bash_cmd "sed -i '' s/a/b/ big.sh")" "sub-agent sed -i big.sh"
expect 0 "" agent Read "$(path big.sh)" "sub-agent Read big.sh whole"
expect 0 "" agent Read "$(ranged big.sh 5)" "sub-agent Read of big.sh under review"

echo planning > .claude/state/mode
expect 0 "" orchestrator Write "$(path big.sh)" "planning: Write to big.sh"
expect 0 "" orchestrator Read "$(path small.md)" "planning: Read small.md"
expect 2 "$review_msg" orchestrator Read "$(ranged big.sh 5)" "planning: Read of big.sh under review"

set +e
err="$(printf 'not json' | bash "$hook" 2>&1 >/dev/null)"
code=$?
set -e
if [ "$code" != 0 ]; then echo "FAIL bad JSON: exit $code, wanted 0"; exit 1; fi
n=$((n + 1))

echo "ok $n assertions"
