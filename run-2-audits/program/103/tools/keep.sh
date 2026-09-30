#!/bin/bash
cd "/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.claude/worktrees/agent-a91d9f1cee64cb2f2" || exit 1
for s in c83f166 0c63fa6 715100c 69bd412 01e5386 1362b48 52ccd8e 32978fa 384bb43 7956c69 7b01fd6 fc75ac6 ab47eb9 78be65e d8e382c; do
  full=$(git rev-parse --verify --quiet "$s^{commit}") || { echo "MISSING $s"; continue; }
  git update-ref "refs/keep/103/$s" "$full" && echo "kept $s $full"
done
