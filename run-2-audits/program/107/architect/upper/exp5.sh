#!/usr/bin/env bash
# A gitlink made with update-index (no submodule clone), an empty directory at its path, and git add -A.
set -euo pipefail
here=/tmp/p107.uRK0bc
r="$here/repo5"; rm -rf "$r"; mkdir "$r"; cd "$r"
git init -q; git config user.email t@t.invalid; git config user.name t
echo a > a; git add -A; git commit -qm a; a="$(git rev-parse HEAD)"
mkdir sub; git update-index --add --cacheinfo "160000,$a,sub"; git commit -qm sub; k0="$(git rev-parse HEAD)"
echo b > a; git add -A; git commit -qm b; b="$(git rev-parse HEAD)"
git update-index --cacheinfo "160000,$b,sub"; echo c > a; git add -A; git commit -qm c
git status --short; git ls-tree HEAD
"$here/pack.sh" "$k0" | grep '^###'
: > a; git add -A; git commit -qm empty
"$here/pack.sh" HEAD~1 | cat
