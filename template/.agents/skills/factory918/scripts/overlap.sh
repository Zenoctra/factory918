#!/usr/bin/env bash
# Ticket playbook step 4 and Opening a PR. Prints every open PR whose diff against origin/main
# shares a path with the paths ticket N names, one line each, `#<pr> <head>: <path> <path>`, in
# ascending PR number, under a first line `program: <line>` holding .claude/state/program (read through the git
# common dir, so a linked worktree sees the main checkout's file) or `program: none`.
# Nothing shared: prints nothing, exit 0. Shared and the program names #N: exit 2, stack on
# that PR. Shared and no program naming #N: exit 1, stop. The ticket's paths are the backticked
# tokens of its body outside a `## Diff` section, resolved against origin/main's tree, so a file,
# a directory or a glob token becomes the tracked files it covers, and a token git rejects prints
# git's message and counts as no path; a ticket that names none says so on stderr and exits 0. With --diff the paths are this branch's own diff against
# origin/main instead, and the PR whose head is this branch is skipped. Every PR head is fetched
# fresh, since refs/remotes is shared across worktrees and Ticket step 1 refreshes only main.
set -euo pipefail
usage() { echo "usage: overlap.sh N [--diff]" >&2; exit 64; }
[ $# -ge 1 ] || usage
n="${1#\#}"; diff=0
[ $# -lt 2 ] || { [ "$2" = --diff ] && diff=1 || usage; }
cd "$(git rev-parse --show-toplevel)"
branch="$(git branch --show-current)"
if [ "$diff" = 1 ]; then
  named="$(git diff --name-only origin/main...HEAD)"
else
  body="$(gh issue view "$n" --json body -q .body)"
  empty="$(git hash-object -t tree /dev/null)"
  named=""
  while IFS= read -r tok; do
    [ -n "$tok" ] || continue
    hits="$(git diff --name-only "$empty" origin/main -- "$tok" || true)"
    [ -z "$hits" ] || named="$named$hits"$'\n'
  done <<< "$(printf '%s\n' "$body" | awk '/^## /{skip = ($0 ~ /^## Diff/)} !skip' | grep -oE '`[^`[:space:]]+`' | tr -d '`' | sort -u)"
  [ -n "$named" ] || { echo "overlap.sh: #$n names no tracked path; the --diff run at Opening a PR is the check" >&2; exit 0; }
fi
prog="$(git rev-parse --git-common-dir)/../.claude/state/program"
line=none; [ ! -f "$prog" ] || line="$(cat "$prog")"
prs="$(gh pr list --state open --json number,headRefName --limit 100 -q '.[] | "\(.number) \(.headRefName)"' | sort -n)"
out=""
while read -r pr head; do
  [ -n "$pr" ] || continue
  [ "$diff" = 1 ] && [ "$head" = "$branch" ] && continue
  git fetch -q origin "+refs/heads/$head:refs/remotes/origin/$head"
  files="$(git diff --name-only "origin/main...origin/$head")"
  paths=""
  while IFS= read -r f; do
    [ -n "$f" ] && grep -Fxq -- "$f" <<< "$named" && paths="$paths $f"
  done <<< "$files"
  [ -n "$paths" ] && out="$out#$pr $head:$paths"$'\n'
done <<< "$prs"
[ -n "$out" ] || exit 0
printf 'program: %s\n%s' "$line" "$out"
grep -qw -- "#$n" <<< "$line" && exit 2
exit 1
