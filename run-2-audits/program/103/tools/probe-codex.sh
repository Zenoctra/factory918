#!/bin/bash
cd /private/tmp/claude-501/-Users-manuel-Desktop-Work-Under-The-Sun-Collective-Core-918-factory918/48857ffb-f0e5-4af1-9b36-ecddce7fb416/scratchpad || exit 1
codex login status 2>&1 | head -3
for m in "$@"; do
  echo "== $m"
  codex exec --skip-git-repo-check --sandbox read-only --model "$m" --json "Reply with the single word ok." 2>&1 | tail -c 1500
  echo
done
