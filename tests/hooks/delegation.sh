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
mkdir -p docs/agents docs/knowledge/core template/docs/factory918 .scratch .claude/state
echo ledger > docs/agents/ledger.md
echo tracker > docs/agents/issue-tracker.md
echo findings > docs/M0-findings.md
echo decisions > docs/knowledge/core/DECISIONS.md
mkdir -p docs/adr
echo adr > docs/adr/0001-x.md
echo generated > template/docs/factory918/DECISIONS.md
git add -A
git commit -qm fixture
echo scratch > .scratch/x.txt
echo execute > .claude/state/mode
export CLAUDE_PROJECT_DIR="$fx"

write_msg() { echo "BLOCKED: writing $1 is a lane's job (P11). Brief a writer lane with the paths, the data shape and the success criteria, then review its diff. Your own files are docs/agents/ledger.md, docs/adr/*, docs/knowledge/core/DECISIONS.md, docs/M0-findings.md and the untracked directories."; }
diff_msg="BLOCKED: git diff shows the code under review (fixed point main); the orchestrator does not read it. The reviewers have the diff in their briefs; wait for their reports, or rm -rf .claude/state/review to abandon the review."
cap_msg="BLOCKED: big.sh is 250 lines; reading it whole is the explorer lane's job. Read it in ranges with offset and limit (200 lines at most), ask /knowledge, or brief an explorer and read its report."
review_msg() { echo "BLOCKED: $1 is under review (fixed point main); the orchestrator does not read the code under review. The reviewers have the diff in their briefs; wait for their reports, or rm -rf .claude/state/review to abandon the review."; }

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
edit() { jq -cn --arg p "$fx/$1" --arg o "$2" --arg n "$3" '{file_path:$p,old_string:$o,new_string:$n}'; }

expect 2 "$(write_msg big.sh)" orchestrator Write "$(path big.sh)" "orchestrator Write to big.sh"
expect 2 "$(write_msg big.sh)" orchestrator Edit "$(path big.sh)" "orchestrator Edit of big.sh"
expect 2 "$(write_msg big.sh)" orchestrator NotebookEdit "$(jq -cn --arg p "$fx/big.sh" '{notebook_path:$p}')" "orchestrator NotebookEdit of big.sh"
expect 2 "$(write_msg template/docs/factory918/DECISIONS.md)" orchestrator Write "$(path template/docs/factory918/DECISIONS.md)" "Write to the template's DECISIONS.md"
expect 2 "$(write_msg big.sh)" orchestrator Bash "$(bash_cmd 'echo x >> big.sh')" "append to big.sh"
expect 2 "$cap_msg" orchestrator Bash "$(bash_cmd 'cat big.sh')" "cat big.sh"
expect 2 "$(write_msg big.sh)" orchestrator Bash "$(bash_cmd "sed -i '' s/a/b/ big.sh")" "sed -i big.sh"
expect 2 "$(write_msg big.sh)" orchestrator Bash "$(bash_cmd 'cat > big.sh <<EOF
echo hello
EOF')" "heredoc into big.sh"
expect 2 "$(write_msg big.sh)" orchestrator Bash "$(bash_cmd 'echo x | tee big.sh')" "tee big.sh"
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
expect 2 "$(write_msg docs/agents/issue-tracker.md)" orchestrator Write "$(path docs/agents/issue-tracker.md)" "Write to a docs/agents copy of the template"
expect 0 "" orchestrator Write "$(path docs/M0-findings.md)" "Write to the findings"
expect 0 "" orchestrator Write "$(path docs/knowledge/core/DECISIONS.md)" "Write to the core DECISIONS.md"
expect 0 "" orchestrator Write "$(path docs/adr/0001-x.md)" "Write to an ADR"
expect 0 "" orchestrator Bash "$(bash_cmd 'git diff main...HEAD')" "git diff with no review in progress"
expect 0 "" orchestrator Write "$(path new-file.sh)" "Write to a file git does not track"
expect 0 "" orchestrator Bash "$(bash_cmd 'cat .scratch/x.txt')" "cat under .scratch"

mkdir -p .claude/state/review .scratch/review/main
echo main > .claude/state/review/fixed-point
echo big.sh > .claude/state/review/files
echo .scratch/review/main > .claude/state/review/dir
echo diff > .scratch/review/main/diff
echo stat > .scratch/review/main/stat
echo report > .scratch/review/main/standards-report.md
echo brief > .scratch/review/main/standards-brief.md
expect 0 "" orchestrator Read "$(path small.md)" "Read of an unlisted file under review"
expect 2 "$(review_msg big.sh)" orchestrator Read "$(ranged big.sh 5)" "ranged Read of big.sh under review"
expect 2 "$(review_msg big.sh)" orchestrator Bash "$(bash_cmd 'head -n 5 big.sh')" "head of big.sh under review"
expect 2 "$diff_msg" orchestrator Bash "$(bash_cmd 'git diff main...HEAD')" "git diff under review"
expect 2 "${diff_msg/git diff/git show}" orchestrator Bash "$(bash_cmd 'git show HEAD')" "git show under review"
expect 2 "${diff_msg/git diff/git log -p}" orchestrator Bash "$(bash_cmd 'git log -p -1')" "git log -p under review"
expect 0 "" orchestrator Bash "$(bash_cmd 'git log --oneline -3')" "git log without a patch under review"
expect 2 "$(review_msg .scratch/review/main/diff)" orchestrator Bash "$(bash_cmd 'cat .scratch/review/main/diff')" "cat of the review diff under review"
expect 2 "$(review_msg .scratch/review/main/diff)" orchestrator Read "$(path .scratch/review/main/diff)" "Read of the review diff under review"
expect 2 "$(review_msg .scratch/review/main/stat)" orchestrator Read "$(path .scratch/review/main/stat)" "Read of the review stat under review"
expect 2 "$(review_msg .scratch/review/main/standards-brief.md)" orchestrator Read "$(path .scratch/review/main/standards-brief.md)" "Read of a brief under review"
expect 0 "" orchestrator Read "$(path .scratch/review/main/standards-report.md)" "Read of a report under review"

expect 0 "" agent Write "$(path big.sh)" "sub-agent Write to big.sh"
expect 0 "" agent Bash "$(bash_cmd 'cat big.sh')" "sub-agent cat big.sh"
expect 0 "" agent Bash "$(bash_cmd "sed -i '' s/a/b/ big.sh")" "sub-agent sed -i big.sh"
expect 0 "" agent Read "$(path big.sh)" "sub-agent Read big.sh whole"
expect 0 "" agent Read "$(ranged big.sh 5)" "sub-agent Read of big.sh under review"
expect 0 "" agent Bash "$(bash_cmd 'git diff main...HEAD')" "sub-agent git diff under review"
expect 0 "" agent Bash "$(bash_cmd 'cat .scratch/review/main/diff')" "sub-agent cat of the review diff"
expect 0 "" agent NotebookEdit "$(jq -cn --arg p "$fx/big.sh" '{notebook_path:$p}')" "sub-agent NotebookEdit of big.sh"
expect 0 "" agent Write "$(path template/docs/factory918/DECISIONS.md)" "sub-agent Write to the template's DECISIONS.md"

for tier in none eco junk; do
  case "$tier" in
    none) rm -f .claude/state/tier ;;
    eco) echo eco > .claude/state/tier ;;
    junk) printf 'ECO\nfast\n' > .claude/state/tier ;;
  esac
  expect 2 "$(write_msg small.md)" orchestrator Edit "$(edit small.md 1 one)" "tier $tier: B1 orchestrator one-line Edit of small.md"
  expect 2 "$(write_msg big.sh)" orchestrator Edit "$(edit big.sh 'echo 1' 'echo 0')" "tier $tier: B2 orchestrator Edit of big.sh"
  expect 2 "$(write_msg small.md)" orchestrator Bash "$(bash_cmd 'echo x >> small.md')" "tier $tier: B3 orchestrator append to small.md"
  expect 0 "" orchestrator Write "$(path docs/agents/ledger.md)" "tier $tier: B4 orchestrator Write to the ledger"
  expect 0 "" orchestrator Write "$(path .claude/state/tier)" "tier $tier: B5 orchestrator Write to the tier file"
  expect 0 "" orchestrator Bash "$(bash_cmd 'bash .claude/skills/spec-review/scripts/review-brief.sh main')" "tier $tier: B6 orchestrator runs the review script"
  expect 0 "" agent Edit "$(edit small.md 1 one)" "tier $tier: B7 sub-agent Edit of small.md"
done
rm -f .claude/state/tier

echo planning > .claude/state/mode
expect 0 "" orchestrator Write "$(path big.sh)" "planning: Write to big.sh"
expect 0 "" orchestrator Read "$(path small.md)" "planning: Read small.md"
expect 2 "$(review_msg big.sh)" orchestrator Read "$(ranged big.sh 5)" "planning: Read of big.sh under review"

rm .claude/state/review/dir
expect 2 "$(review_msg big.sh)" orchestrator Read "$(ranged big.sh 5)" "review state without dir: Read of big.sh"
expect 0 "" orchestrator Read "$(path small.md)" "review state without dir: Read of small.md, no cat error"

set +e
err="$(printf 'not json' | bash "$hook" 2>&1 >/dev/null)"
code=$?
set -e
if [ "$code" != 0 ] || [ "$err" != "delegation.sh: could not parse the hook input; letting the call through" ]; then
  echo "FAIL bad JSON: exit $code, wanted 0"; echo "  got:    $err"; exit 1
fi
n=$((n + 1))

echo "ok $n assertions"
