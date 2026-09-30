#!/bin/bash
# verify.sh: the AGENTS.md Verifying lines this diff can affect, plus the new test
cd "/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.claude/worktrees/agent-a91d9f1cee64cb2f2" || exit 1
out=/private/tmp/claude-501/-Users-manuel-Desktop-Work-Under-The-Sun-Collective-Core-918-factory918/48857ffb-f0e5-4af1-9b36-ecddce7fb416/scratchpad/verify.out
echo "HEAD $(git rev-parse HEAD)"
bash .github/shellcheck.sh factory918.sh template/.github/shellcheck.sh 'template/.claude/hooks/*.sh' 'template/.agents/skills/*/scripts/*.sh' 'tests/*/*.sh' tests/eval/reviewer/refusals.sh > "$out" 2>&1
echo "shellcheck exit $? $(tail -1 "$out")"
for t in tests/shellcheck/gate.sh tests/hooks/delegation.sh tests/spec-review/review-comment.sh tests/spec-review/review-brief.sh tests/poteto-mode/overlap.sh tests/eval/reviewer/refusals.sh; do
  bash "$t" > "$out" 2>&1
  echo "$t exit $? $(tail -1 "$out")"
done
python3 tests/eval/reviewer/reviewer.py check > "$out" 2>&1
echo "reviewer.py check exit $? ok lines $(grep -c '^ok ' "$out")"
python3 tools/build_knowledge.py > /dev/null 2>&1 && python3 tools/check_knowledge.py | tail -1
./factory918.sh sync > "$out" 2>&1
echo "sync exit $?"
echo "status lines after build and sync: $(git status --short | wc -l)"
