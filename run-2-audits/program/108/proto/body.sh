#!/usr/bin/env bash
# body.sh <risks|flags> <file>: runner A's prototype over a whole file.
here="$(dirname "$0")"
fenced='
  /^(```|~~~)/ { match($0, /^(`+|~+)/); m = substr($0, 1, RLENGTH); rest = substr($0, RLENGTH + 1)
    if (fence == "") { fence = m; next }
    if (substr(m, 1, 1) == substr(fence, 1, 1) && length(m) >= length(fence) && rest ~ /^[ \t\r]*$/) { fence = ""; next } }
  fence != "" { next }
'
prog=""
while IFS= read -r l; do case "$l" in *"spliced here"*) prog="$prog$fenced" ;; *) prog="$prog$l"$'\n' ;; esac; done < "$here/disposed.awk"
w=risks; [ "$1" = risks ] || w="writer flags"
awk -v mode="$1" -v w="$w" "$prog" "$2" | tr '\037' '|'
echo "exit/lines: $(awk -v mode="$1" -v w="$w" "$prog" "$2" | wc -l)"
