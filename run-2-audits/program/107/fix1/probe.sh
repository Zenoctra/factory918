#!/usr/bin/env bash
# probe.sh <helpers> <brief> <tries>: runs fence, notext and at under pipefail, counting misses per helper.
set -euo pipefail
. "$1"
n=0
fe=0 nt=0 att=0
for _ in $(seq 1 "$3"); do
  ( fence "$2" "### pk/early.md, whole, 1 line" '`````' "(probe)" > /dev/null ) || fe=$((fe + 1))
  ( notext "$2" "### pk/gone.txt, deleted at HEAD: no text" "(probe)" > /dev/null ) || nt=$((nt + 1))
  ( x="$(at "$2" '```')"; [ "$x" = 15 ] ) || att=$((att + 1))
done
section "$2" | awk '{ exit }' || true
echo "misses of $3: fence=$fe notext=$nt at=$att; section | early-exit reader PIPESTATUS: $(section "$2" | awk '{ exit }'; echo "${PIPESTATUS[*]}")"
