#!/bin/bash
C="/Users/manuel/Library/Application Support/Claude/claude-code/2.1.280/claude.app/Contents/MacOS/claude"
for m in "$@"; do
  echo "== $m"
  "$C" -p "Reply with the single word ok." --model "$m" --output-format json --max-turns 1 2>&1 | head -c 1800
  echo
done
