#!/usr/bin/env bash
# Delegation guard. PreToolUse on Read, Write, Edit, NotebookEdit and Bash; exit 2 blocks the call.
# The orchestrating session briefs lanes and judges their results: while the phase is execute it
# does not write a lane's file or read a tracked file over 200 lines whole, and while a review is
# in progress it does not read the files under review. A sub-agent (agent_id in the input) passes.
# Anything that fails inside the hook lets the call through: exit 2 only on a decided block.
set -fuo pipefail
input="$(cat)"
parsed="$(printf '%s' "$input" | jq -r '[(.agent_id // ""), (.tool_name // ""), (.cwd // ""),
  (.tool_input.file_path // .tool_input.notebook_path // ""), (.tool_input.offset // "" | tostring),
  (.tool_input.limit // "" | tostring), (.tool_input.command // "")] | join("\n")' 2>/dev/null)" \
  || { echo "delegation.sh: could not parse the hook input; letting the call through" >&2; exit 0; }
field() { printf '%s\n' "$parsed" | sed -n "$1"; }
agent_id="$(field 1p)"
[ -z "$agent_id" ] || exit 0
tool="$(field 2p)"
cwd="$(field 3p)"
file="$(field 4p)"
offset="$(field 5p)"
limit="$(field 6p)"
command="$(field '7,$p')"
root="$(cd "${CLAUDE_PROJECT_DIR:-${cwd:-.}}" 2>/dev/null && pwd -P)" || exit 0
git -C "$root" rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0
[ -n "$cwd" ] || cwd="$root"
phase="$(cat "$root/.claude/state/mode" 2>/dev/null || echo execute)"
review="$root/.claude/state/review"
max_lines=200

block() { echo "$1" >&2; exit 2; }

# A path from a tool call or a command token, made repo-relative; fails when it is outside the repo.
# The tr alphabet is the one tokens() encodes with index(" \t|;&<>", c): keep the two in step.
relative() {
  local p base dir
  p="$(printf '%s' "$1" | tr '\001\002\003\004\005\006\007' ' \t|;&<>')"
  case "$p" in /*) ;; *) p="$cwd/$p" ;; esac
  base="$(basename "$p")"
  dir="$(cd "$(dirname "$p")" 2>/dev/null && pwd -P)" || return 1
  p="$dir/$base"
  case "$p" in "$root"/*) printf '%s\n' "${p#"$root"/}" ;; *) return 1 ;; esac
}

# untracked: git does not track it, or it lives in a directory nobody reviews;
# owned: the orchestrator's own records; lane: every other tracked path.
classify() {
  case "$1" in .claude/state/*|.artifacts/*|.scratch/*|.plans/*) echo untracked; return ;; esac
  git -C "$root" ls-files --error-unmatch -- "$1" >/dev/null 2>&1 || { echo untracked; return; }
  case "$1" in
    docs/agents/ledger.md|docs/adr/*|docs/knowledge/core/DECISIONS.md|docs/M0-findings.md) echo owned ;;
    *) echo lane ;;
  esac
}

guard_write() {
  [ "$phase" = execute ] || return 0
  [ "$(classify "$1")" = lane ] || return 0
  block "BLOCKED: writing $1 is a lane's job (P11). Brief a writer lane with the paths, the data shape and the success criteria, then review its diff. Your own files are docs/agents/ledger.md, docs/adr/*, docs/knowledge/core/DECISIONS.md, docs/M0-findings.md and the untracked directories."
}

# Under review: the changed files and their diff and stat. The briefs and reports beside them are
# the orchestrator's to read.
in_review() {
  local dir
  [ -f "$review/files" ] || return 1
  grep -Fxq -- "$1" "$review/files" && return 0
  dir="$(cat "$review/dir" 2>/dev/null)"
  [ -n "$dir" ] || return 1
  case "$1" in "$dir"/diff|"$dir"/stat) return 0 ;; esac
  return 1
}

guard_read() {
  local n
  if in_review "$1"; then
    block "BLOCKED: $1 is under review (fixed point $(cat "$review/fixed-point")); the orchestrator does not read the code under review. The reviewers have the diff in their briefs; wait for their reports, or rm -rf .claude/state/review to abandon the review."
  fi
  [ "$phase" = execute ] && [ "$2" = whole ] || return 0
  [ "$(classify "$1")" != untracked ] || return 0
  n="$(wc -l < "$root/$1" 2>/dev/null | tr -d ' ')" || return 0
  [ "$n" -gt "$max_lines" ] || return 0
  block "BLOCKED: $1 is $n lines; reading it whole is the explorer lane's job. Read it in ranges with offset and limit ($max_lines lines at most), ask /knowledge, or brief an explorer and read its report."
}

# scan_git <args>: under review, git diff, git show and git log -p reach the diff without a path.
scan_git() {
  local a
  if [ -f "$review/files" ]; then
    case "${1:-}" in
      diff|show) guard_diff "git $1" ;;
      log) for a in "$@"; do case "$a" in -p|--patch) guard_diff "git log $a" ;; esac; done ;;
    esac
  fi
  [ "${1:-}" = show ] || return 0
  for a in "$@"; do case "$a" in *:*) target_read "${a#*:}" whole ;; esac; done
}
guard_diff() {
  block "BLOCKED: $1 shows the code under review (fixed point $(cat "$review/fixed-point")); the orchestrator does not read it. The reviewers have the diff in their briefs; wait for their reports, or rm -rf .claude/state/review to abandon the review."
}

target_write() { local rel; rel="$(relative "$1")" || return 0; guard_write "$rel"; }
target_read() { local rel; rel="$(relative "$1")" || return 0; guard_read "$rel" "$2"; }

# One simple command per line, heredoc bodies dropped, quotes removed. Characters that would split
# a token or a command are kept as \001-\007 while they are quoted; relative() puts them back.
# The separators (; && || | and subshells) become newlines, and every > or >> becomes " > ".
tokens() {
  awk -v sq="'" '
    BEGIN { hre = "<<-?[ \t]*[\"" sq "]?[A-Za-z_][A-Za-z0-9_]*" }
    hd != "" { if ($0 == hd) hd = ""; next }
    {
      probe = $0; gsub(/<<</, "", probe)
      if (match(probe, hre)) { hd = substr(probe, RSTART, RLENGTH); sub("<<-?[ \t]*[\"" sq "]?", "", hd) }
      line = $0; out = ""; n = length(line)
      for (i = 1; i <= n; i++) {
        c = substr(line, i, 1)
        if (q == "") {
          if (c == "\"" || c == sq) { q = c; continue }
          if (c == "\\" && i < n) { i++; c = substr(line, i, 1); k = index(" \t|;&<>", c); if (k) c = sprintf("%c", k) }
        } else {
          if (c == q) { q = ""; continue }
          k = index(" \t|;&<>", c); if (k) c = sprintf("%c", k)
        }
        out = out c
      }
      gsub(/&&|\|\||;|\||\$?\(|\)|`/, "\n", out)
      gsub(/>>?/, " > ", out)
      print out
    }'
}

scan_head() {
  local n=10 a files=""
  while [ $# -gt 0 ]; do
    case "$1" in
      -n) n="${2:-10}"; shift ;;
      -n[0-9]*) n="${1#-n}" ;;
      --lines=*) n="${1#--lines=}" ;;
      -[0-9]*) n="${1#-}" ;;
      -*) ;;
      *) files="$files $1" ;;
    esac
    [ $# -gt 0 ] && shift
  done
  local kind=ranged
  [ "$n" -le "$max_lines" ] 2>/dev/null || kind=whole
  for a in $files; do target_read "$a" "$kind"; done
}

# sed -i writes its files; sed -n reads the range its script prints; any other sed prints them whole.
scan_sed() {
  local inplace=0 quiet=0 scripts=0 script="" args="" a b kind=whole
  while [ $# -gt 0 ]; do
    case "$1" in
      -e|--expression) scripts=$((scripts + 1)); script="${2:-}"; shift ;;
      -e*) scripts=$((scripts + 1)); script="${1#-e}" ;;
      --in-place*) inplace=1 ;;
      --quiet|--silent) quiet=1 ;;
      --*) ;;
      -*) case "$1" in *i*) inplace=1 ;; esac; case "$1" in *n*) quiet=1 ;; esac ;;
      *) args="$args $1" ;;
    esac
    [ $# -gt 0 ] && shift
  done
  set -- $args
  if [ "$scripts" = 0 ]; then script="${1:-}"; [ $# -gt 0 ] && shift; fi
  if [ "$inplace" = 1 ]; then for a in "$@"; do target_write "$a"; done; return 0; fi
  if [ "$quiet" = 1 ]; then
    case "$script" in
      *,*p) a="${script%%,*}"; b="${script#*,}"; b="${b%p}"
            case "$a$b" in ""|*[!0-9]*) ;; *) [ $((b - a + 1)) -le "$max_lines" ] && kind=ranged ;; esac ;;
      *p) a="${script%p}"; case "$a" in ""|*[!0-9]*) ;; *) kind=ranged ;; esac ;;
    esac
  fi
  for a in "$@"; do target_read "$a" "$kind"; done
}

scan_segment() {
  local a prev="" words="" cmd
  for a in "$@"; do
    if [ "$prev" = ">" ]; then target_write "$a"; prev=""; continue; fi
    if [ "$a" = ">" ]; then prev=">"; continue; fi
    words="$words $a"; prev=""
  done
  set -- $words
  while [ $# -gt 0 ]; do case "$1" in [A-Za-z_]*=*) shift ;; *) break ;; esac; done
  [ $# -gt 0 ] || return 0
  cmd="$1"; shift
  case "$cmd" in
    tee) for a in "$@"; do case "$a" in -*) ;; *) target_write "$a" ;; esac; done ;;
    cat) for a in "$@"; do case "$a" in -*) ;; *) target_read "$a" whole ;; esac; done ;;
    head) scan_head "$@" ;;
    sed) scan_sed "$@" ;;
    git) scan_git "$@" ;;
  esac
  return 0
}

case "$tool" in
  Write|Edit|NotebookEdit)
    rel="$(relative "$file")" || exit 0
    guard_write "$rel" ;;
  Read)
    rel="$(relative "$file")" || exit 0
    if [ -n "$offset$limit" ]; then guard_read "$rel" ranged; else guard_read "$rel" whole; fi ;;
  Bash)
    while IFS= read -r seg; do scan_segment $seg; done <<< "$(printf '%s\n' "$command" | tokens)" ;;
esac
exit 0
