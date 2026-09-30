#!/usr/bin/env bash
# The total's edges at the chosen cutoffs: eight whole files of 8192 bytes, then a 2-byte file and a 70000-byte line.
set -euo pipefail
here=/tmp/p107.uRK0bc
r="$here/repo4"; rm -rf "$r"; mkdir "$r"; cd "$r"
git init -q; git config user.email t@t.invalid; git config user.name t
awk 'BEGIN { for (i = 0; i < 70000; i++) printf "l"; print "" }' > long.txt
git add -A; git commit -qm o0; o0="$(git rev-parse HEAD)"
for f in a b c d e f g h; do awk 'BEGIN { for (i = 0; i < 128; i++) printf "%063d\n", i }' > "$f.txt"; done
git add -A; git commit -qm o1
echo "== exactly the total"
"$here/pack.sh" "$o0" | grep '^### \|^Not carried'
echo i > i.txt
awk 'BEGIN { for (i = 0; i < 70000; i++) printf "m"; print "" }' > long.txt
git add -A; git commit -qm o2
echo "== plus a 2-byte file and a changed 70001-byte line"
"$here/pack.sh" "$o0" | grep '^### \|^Not carried'
