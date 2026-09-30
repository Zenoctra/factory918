#!/usr/bin/env bash
# probe2.sh <section> <tries>: the real 15.9 KB section written the way glibc awk writes to a pipe (in
# small flushes), read by the old and the new fence reader; counts the writer's SIGPIPE exits (141).
set -uo pipefail
w() { awk '{ print; if (NR % 40 == 0) fflush() }' "$1"; }
H="### pk/fenced.md, lines 281-288 of 325"
old=0 new=0 oldmiss=0 newmiss=0
for _ in $(seq 1 "$2"); do
  w "$1" | H="$H" F='`````' awk '$0 == ENVIRON["H"] { getline; if ($0 == "") { getline; ok = ($0 == ENVIRON["F"]) } exit }
      END { exit !ok }'
  s=("${PIPESTATUS[@]}"); [ "${s[0]}" = 141 ] && old=$((old + 1)); [ "${s[1]}" = 0 ] || oldmiss=$((oldmiss + 1))
  w "$1" | H="$H" F='`````' awk '
      st == 0 && $0 == ENVIRON["H"] { st = 1; next }
      st == 1 { st = ($0 == "") ? 2 : -1; next }
      st == 2 { ok = ($0 == ENVIRON["F"]); st = -1 }
      END { exit !ok }'
  s=("${PIPESTATUS[@]}"); [ "${s[0]}" = 141 ] && new=$((new + 1)); [ "${s[1]}" = 0 ] || newmiss=$((newmiss + 1))
done
echo "of $2 runs: old reader, writer killed by SIGPIPE $old times, reader missed $oldmiss; new reader, SIGPIPE $new, missed $newmiss"
