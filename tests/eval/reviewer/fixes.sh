#!/usr/bin/env bash
# Build every fix patch the `fixes` file lists from its commits and compare it byte for byte with
# rounds/<round>/fixes/<patch>, or write it there with --write. Each line runs `git show --format=
# --no-color --no-ext-diff <sha> -- <paths>` or `git diff --no-color --no-ext-diff <a> <b> --
# <paths>`. REBUILD_FIXTURES (this directory) holds
# `fixes` and rounds/; REBUILD_REPO (this repository) holds the commits, which live under
# refs/keep/103/* or on main. Exit 0 when every patch matches, 1 naming the first that differs,
# 2 on a setup error.
set -euo pipefail
case "${1:-}" in
  "") mode="compare" ;;
  --write) mode="write" ;;
  *) echo "usage: fixes.sh [--write]" >&2; exit 2 ;;
esac
here="$(cd "$(dirname "$0")" && pwd -P)"
fx="${REBUILD_FIXTURES:-$here}"
repo="${REBUILD_REPO:-$(git -C "$here" rev-parse --show-toplevel)}"
[ -f "$fx/fixes" ] || { echo "fixes: $fx/fixes missing" >&2; exit 2; }
tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT
while IFS=$'\t' read -r round patch cmd paths; do
  case "$round" in "#"* | "") continue ;; esac
  read -r -a words <<<"$cmd"
  read -r -a files <<<"$paths"
  case "${words[0]}" in
    show) [ ${#words[@]} -eq 2 ] || { echo "fixes: $round $patch: show takes one commit" >&2; exit 2; }
          git -C "$repo" show --format= --no-color --no-ext-diff "${words[1]}" -- "${files[@]}" > "$tmp" ;;
    diff) [ ${#words[@]} -eq 3 ] || { echo "fixes: $round $patch: diff takes two commits" >&2; exit 2; }
          git -C "$repo" diff --no-color --no-ext-diff "${words[1]}" "${words[2]}" -- "${files[@]}" > "$tmp" ;;
    *) echo "fixes: $round $patch: $cmd is not show or diff" >&2; exit 2 ;;
  esac
  [ -s "$tmp" ] || { echo "fixes: $round $patch: the git command gives an empty patch" >&2; exit 2; }
  target="$fx/rounds/$round/fixes/$patch"
  if [ "$mode" = write ]; then
    mkdir -p "$(dirname "$target")"
    cp "$tmp" "$target"
    echo "fixes: $round $patch: written"
  elif ! cmp -s "$tmp" "$target"; then
    echo "fixes: $round $patch differs from its commits" >&2
    exit 1
  else
    echo "fixes: $round $patch: identical"
  fi
done < "$fx/fixes"
