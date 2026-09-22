#!/usr/bin/env bash
# Ticket step 1 and step 8. `overlap.sh N` prints `go: <label or none>` (the newest line of
# .claude/state/program naming #N), then `#<pr> <head>: <paths>` for every open PR whose own
# commits (its diff from the nearest open-PR head under it, else origin/main) touch a path the
# ticket's body names in backticks (tokens without whitespace, those under `## Diff` skipped,
# passed together as pathspecs), ascending by PR number, then on exit 0 the ref to branch from:
# origin/main when nothing is shared, else the printed head that contains every other, else the
# lowest PR number's. `overlap.sh N --diff` compares the branch's own paths by the same rule (the
# own PR skipped, literal pathspecs), prints nothing when none is shared, the go and the PR lines
# otherwise, and no base. `overlap.sh go
# "<label>" N...` appends `<label>: #a #b ...` to the program file, its only writer; a linked
# worktree reads the main checkout's. Exit 0 decided, 1 a path shared with a PR no go covers (a go
# covers when some line names #N and some line names the ticket each printed PR closes; a PR that
# closes no ticket is never covered), 2 gh or git failed and its message is on stderr, `--diff` on
# a detached HEAD, or more than 100 open PRs, 64 usage.
# Every PR head is fetched fresh before any diff; no origin remote means nothing is in flight.
set -euo pipefail
trap 'exit 2' ERR
usage() { echo 'usage: overlap.sh N [--diff] | overlap.sh go "<label>" N...' >&2; exit 64; }
cd "$(git rev-parse --show-toplevel)"
prog="$(git rev-parse --git-common-dir)/../.claude/state/program"

if [ "${1:-}" = go ]; then
  [ $# -ge 3 ] || usage
  line="$2:"; shift 2
  for t in "$@"; do t="${t#\#}"; [[ $t =~ ^[0-9]+$ ]] || usage; line="$line #$t"; done
  mkdir -p "$(dirname "$prog")"; echo "$line" >> "$prog"; exit 0
fi
[ $# -ge 1 ] && [ $# -le 2 ] || usage
n="${1#\#}"; [[ $n =~ ^[0-9]+$ ]] || usage
diff=""; [ $# -eq 1 ] || { [ "$2" = --diff ] || usage; diff=1; }
cur="$(git branch --show-current)"
if [ -n "$diff" ] && [ -z "$cur" ]; then echo "detached HEAD; run from the ticket's branch" >&2; exit 2; fi

# The newest go naming the ticket is the one the human gave last.
l="$(grep -w -- "#$n" "$prog" 2>/dev/null | tail -n 1 || true)"
go="go: ${l%%: #*}"; [ -n "$l" ] || go="go: none"
covered=1; [ "$go" != "go: none" ] || covered=0

if ! git remote get-url origin >/dev/null 2>&1; then
  echo "no origin remote; nothing in flight" >&2
  [ -n "$diff" ] || printf '%s\nbase: main\n' "$go"
  exit 0
fi

if [ -z "$diff" ]; then
  body="$(gh issue view "$n" --json body -q .body)"
  outside="$(printf '%s\n' "$body" | awk '/^## /{skip=($0 ~ /^## Diff[[:space:]]*$/)} !skip')"
  # shellcheck disable=SC2016 # the backticks are the ticket's token delimiters, not command substitution
  paths="$(printf '%s\n' "$outside" | grep -oE '`[^`[:space:]]+`' | tr -d '`' | sort -u || true)"
  if [ -z "$paths" ]; then printf '%s\npaths: none\nbase: origin/main\n' "$go"; exit 0; fi
fi

# One line per open PR: number, head, the tickets it closes; heads refreshed in one fetch. A 101st
# line means the list is cut, and a PR the check cannot see cannot be ruled out.
prs="$(gh pr list --state open --limit 101 --json number,headRefName,closingIssuesReferences \
  -q 'sort_by(.number)[] | "\(.number)\t\(.headRefName)\t\(.closingIssuesReferences | map("#\(.number)") | join(" "))"')"
if [ "$(grep -c . <<< "$prs")" -gt 100 ]; then echo "more than 100 open PRs; the check cannot list them all" >&2; exit 2; fi
specs=(+refs/heads/main:refs/remotes/origin/main)
while IFS=$'\t' read -r num head closes; do
  [ -n "$num" ] || continue
  specs+=("+refs/heads/$head:refs/remotes/origin/$head")
done <<< "$prs"
git fetch -q origin "${specs[@]}"

# is_ancestor <a> <b>: 0 yes, 1 no; any other git exit ends the run, its message already on stderr.
is_ancestor() { git merge-base --is-ancestor "$1" "$2" && return 0; [ $? -eq 1 ] && return 1; exit 2; }
# nearest <ref> <own head>: the open-PR head under the ref with the fewest commits between, the
# ref's own head never (a head is not its own base), else origin/main.
nearest() {
  local base=origin/main best="" num head closes d
  while IFS=$'\t' read -r num head closes; do
    [ -n "$num" ] && [ "$head" != "$2" ] || continue
    is_ancestor "origin/$head" "$1" || continue
    d="$(git rev-list --count "origin/$head..$1")"
    [ "$d" -gt 0 ] || continue
    if [ -z "$best" ] || [ "$d" -lt "$best" ]; then best="$d"; base="origin/$head"; fi
  done <<< "$prs"
  echo "$base"
}

if [ -n "$diff" ]; then
  base="$(nearest HEAD "$cur")"
  paths="$(git diff --name-only "$base...HEAD")"
  [ -n "$paths" ] || exit 0
  export GIT_LITERAL_PATHSPECS=1
fi
IFS=$'\n' read -r -d '' -a toks <<< "$paths" || true

lines=""; printed=()
while IFS=$'\t' read -r num head closes; do
  [ -n "$num" ] || continue
  [ -z "$diff" ] || [ "$head" != "$cur" ] || continue
  base="$(nearest "origin/$head" "$head")"
  shared="$(git diff --name-only "$base...origin/$head" -- "${toks[@]}" | tr '\n' ' ')"
  [ -n "$shared" ] || continue
  lines+="#$num $head: ${shared% }"$'\n'
  printed+=("$head")
  [ -n "$closes" ] || covered=0
  for t in $closes; do grep -qw -- "$t" "$prog" 2>/dev/null || covered=0; done
done <<< "$prs"

if [ -n "$diff" ]; then
  [ -n "$lines" ] || exit 0
  printf '%s\n%s' "$go" "$lines"
  [ "$covered" = 1 ] || exit 1
  exit 0
fi
printf '%s\n%s' "$go" "$lines"
if [ -z "$lines" ]; then echo "base: origin/main"; exit 0; fi
[ "$covered" = 1 ] || exit 1
base="origin/${printed[0]}"
for h in "${printed[@]}"; do
  holds=1
  for o in "${printed[@]}"; do is_ancestor "origin/$o" "origin/$h" || holds=0; done
  if [ "$holds" = 1 ]; then base="origin/$h"; break; fi
done
echo "base: $base"
