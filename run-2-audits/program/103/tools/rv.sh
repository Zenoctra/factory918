#!/bin/bash
# rv.sh <reviewer.py args...>  runs the eval runner from the owner worktree with the shared output dir
cd "/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.claude/worktrees/agent-a91d9f1cee64cb2f2" || exit 1
export REVIEWER_OUT="/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.scratch/eval/reviewer"
export REVIEWER_WORK="/private/tmp/claude-501/review-work"
exec python3 tests/eval/reviewer/reviewer.py "$@"
