#!/usr/bin/env bash
# run.sh: feeds each adversarial case through runner A's awk prototype.
here="$(dirname "$0")"
fenced='
  /^(```|~~~)/ { match($0, /^(`+|~+)/); m = substr($0, 1, RLENGTH); rest = substr($0, RLENGTH + 1)
    if (fence == "") { fence = m; next }
    if (substr(m, 1, 1) == substr(fence, 1, 1) && length(m) >= length(fence) && rest ~ /^[ \t\r]*$/) { fence = ""; next } }
  fence != "" { next }
'
prog=""
while IFS= read -r l; do case "$l" in *"spliced here"*) prog="$prog$fenced" ;; *) prog="$prog$l"$'\n' ;; esac; done < "$here/disposed.awk"
t() {
  local w=risks; [ "$1" = risks ] || w="writer flags"
  echo "== $1: $2"
  printf '%b' "$2" | awk -v mode="$1" -v w="$w" "$prog" | tr '\037' '|'
}
t risks '## Risks\n1. a accepted: ok\n```\nx\n```\n2. b\n'
t risks '## Risks\n1. a accepted: ok\n~~~~\n2. hidden\n~~~\n'
t risks '## Risks\n1. x accepted: fine fixed:\n'
t risks 'Risks\n-----\n1. a\n'
t risks '### Risks\n#### Risk 1\n1. a accepted: ok\n'
t risks '## Risks\n\t1. a accepted: ok\n2. b\n'
t flags '## Testing decisions\n### Writer flags 2026-09-23\n1. a accepted: ok\n### Test list\n1. x\n'
t flags '- [ ] reach the ticket as a dated `Writer flags` list with a disposition\n'
t flags '## Testing decisions\n### Writer flags 2026-09-23\n\n| flag | disp |\n|---|---|\n| a | accepted: ok |\n'
t risks '## Risks\n1. a fixed: abc1234. \n'
t risks '## Risks\n\n  1. a accepted: ok\n2. b\n'
t flags '### Writer Flags 2026-09-23\n1. a\n'
t risks '## Risks\n1. a accepted: ok\n## Cleared\n### Risks\n1. c\n'
