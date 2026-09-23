#!/usr/bin/env bash
# spec-review step 1, called by review-brief.sh: prints the `## Reading pack` section both briefs
# carry after the diff, so a reviewer reads the code around each change without opening the
# repository. Each changed file's text at HEAD, whole when it is small; in a larger file, per changed
# line, the shell function, the comment-led block or the Markdown section around it, else a window
# around the line; the entries that do not fit the total are named on one closing line instead.
#   reading-pack.sh <fixed-point>
#   reading-pack.sh --paths P... --commits SHA...
# The sweep form carries no pack. Exits 1, with git's message on stderr, when a git command fails.
set -euo pipefail
# Bytes, a missing final newline counted as present: a file carried whole, one unit, the whole pack.
pack_whole=8192 pack_unit=4096 pack_total=65536
# awk's length() counts bytes only in the C locale.
export LC_ALL=C
if [ "${1:-}" = --paths ]; then
  echo "## Reading pack"
  echo
  echo "The sweep form carries no reading pack: its diff numbers lines as the swept commits did, so the files at HEAD are not the code it shows."
  echo
  exit 0
fi
fixed="$1"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
empty="$(git hash-object -t tree /dev/null)"

# Entry k is $tmp/k.head, and for a carried text $tmp/k.label and $tmp/k.text.
k=0
# note <header>: an entry with no text.
note() {
  k=$((k + 1))
  printf '%s\n' "$1" > "$tmp/$k.head"
}
# carry <header> <label> <a> <b>: an entry holding lines a to b of the file at HEAD; awk ends the
# last line with a newline.
carry() {
  k=$((k + 1))
  printf '%s\n' "$1" > "$tmp/$k.head"
  printf '%s\n' "$2" > "$tmp/$k.label"
  awk -v a="$3" -v b="$4" 'NR >= a && NR <= b' "$tmp/blob" > "$tmp/$k.text"
}

# units <kind> <line>...: the file at HEAD on stdin; prints the merged ranges "a b", one per line,
# of the units around the changed lines. Line tests read each line less a trailing CR.
units() {
  local kind="$1"
  shift
  awk -v kind="$kind" -v lines="$*" -v unit="$pack_unit" '
    { t = $0; sub(/\r$/, "", t); tx[NR] = t; cum[NR] = cum[NR - 1] + length($0) + 1 }
    function bytes(a, b) { return cum[b] - cum[a - 1] }
    function blank(i) { return tx[i] ~ /^[ \t]*$/ }
    # The widest range L-r..L+r clipped to lo..hi within the unit, always at least line L.
    function window(L, lo, hi,  r, x, y) {
      S = L; E = L
      for (r = 1; ; r++) {
        x = (L - r < lo) ? lo : L - r; y = (L + r > hi) ? hi : L + r
        if ((x == S && y == E) || bytes(x, y) > unit) break
        S = x; E = y
      }
    }
    function shell(L,  i, s, e, k, re, j) {
      s = 0
      for (i = L; i >= 1; i--) if (fend[i] >= L) { s = i; e = fend[i]; break }
      if (s && bytes(s, e) <= unit) { S = s; E = e; return }
      for (k = L; k >= 1 && !hash[k]; k--) ;
      if (k < 1) { S = 1; re = 0 }
      else { for (S = k; S > 1 && hash[S - 1]; S--) ; for (re = k; re < NR && hash[re + 1]; re++) ; }
      j = (re > L) ? re : L
      for (j++; j <= NR && !hash[j]; j++) ;
      E = j - 1
      if (s) { if (S < s) S = s; if (E > e) E = e }
      if (bytes(S, E) > unit) window(L, S, E)
    }
    function markdown(L,  s, e) {
      for (s = L; s > 1 && !head[s]; s--) ;
      for (e = L + 1; e <= NR && !head[e]; e++) ;
      for (e--; e > L && blank(e); e--) ;
      S = s; E = e
      if (bytes(S, E) > unit) window(L, s, E)
    }
    END {
      if (kind == "shell") {
        for (i = 1; i <= NR; i++) {
          hash[i] = (tx[i] ~ /^#/)
          if (tx[i] ~ /^[A-Za-z_][A-Za-z0-9_]*[(][)][ \t]*[{]?[ \t]*$/ || tx[i] ~ /^function[ \t]+[A-Za-z_][A-Za-z0-9_]*[ \t]*([(][)])?[ \t]*[{]?[ \t]*$/)
            for (j = i + 1; j <= NR; j++) if (tx[j] ~ /^}/) { fend[i] = j; break }
        }
      }
      # Headings outside fenced text, by the fence rule of review-brief.sh with up to three leading spaces.
      if (kind == "markdown") {
        fence = ""
        for (i = 1; i <= NR; i++) {
          s = tx[i]
          if (match(s, /^ +/) && RLENGTH <= 3) s = substr(s, RLENGTH + 1)
          if (s ~ /^(```|~~~)/) {
            match(s, /^(`+|~+)/); m = substr(s, 1, RLENGTH); rest = substr(s, RLENGTH + 1)
            if (fence == "") { fence = m; continue }
            if (substr(m, 1, 1) == substr(fence, 1, 1) && length(m) >= length(fence) && rest ~ /^[ \t]*$/) { fence = ""; continue }
          }
          if (fence != "") continue
          if (match(tx[i], /^#+/) && RLENGTH <= 6) { c = substr(tx[i], RLENGTH + 1, 1); head[i] = (c == "" || c == " " || c == "\t") }
        }
      }
      n = split(lines, ls, " ")
      for (q = 1; q <= n; q++) {
        L = ls[q] + 0
        if (kind == "shell") shell(L)
        else if (kind == "markdown") markdown(L)
        else window(L, 1, NR)
        ra[q] = S; rb[q] = E
      }
      for (i = 2; i <= n; i++) {
        x = ra[i]; y = rb[i]
        for (j = i - 1; j >= 1 && ra[j] > x; j--) { ra[j + 1] = ra[j]; rb[j + 1] = rb[j] }
        ra[j + 1] = x; rb[j + 1] = y
      }
      a = ra[1]; b = rb[1]
      for (i = 2; i <= n; i++) {
        if (ra[i] <= b + 1) { if (rb[i] > b) b = rb[i] }
        else { print a, b; a = ra[i]; b = rb[i] }
      }
      print a, b
    }'
}

# one <status> <old> <path>: the entries of one changed file; the first rule that matches wins.
one() {
  local st="$1" old="$2" p="$3" from="" mode target gen numstat size lines count changed kind a b
  [ "$old" = "$p" ] || from=", renamed from $old"
  case "$p" in *$'\n'*) note "### $(printf %q "$p"), a path holding a newline: no text"; return ;; esac
  if [ "$st" = D ]; then note "### $p$from, deleted at HEAD: no text"; return; fi
  mode="$(git ls-tree HEAD -- ":(literal)$p")"
  case "$mode" in
    120000*) target="$(git cat-file blob "HEAD:$p")"; note "### $p$from, a symbolic link to $target: no text"; return ;;
    160000*) note "### $p$from, a submodule: no text"; return ;;
  esac
  gen="$(git check-attr linguist-generated -- "$p")"
  case "${gen##*: }" in set|true) note "### $p$from, generated (linguist-generated): no text"; return ;; esac
  numstat="$(git diff --numstat --no-ext-diff "$empty" HEAD -- ":(literal)$p")"
  case "$numstat" in -*) note "### $p$from, binary: no text"; return ;; esac
  git cat-file blob "HEAD:$p" > "$tmp/blob"
  read -r lines size < <(awk '{ b += length($0) + 1 } END { print NR, b + 0 }' "$tmp/blob")
  if [ "$size" -eq 0 ]; then note "### $p$from, empty at HEAD: no text"; return; fi
  if [ "$size" -le "$pack_whole" ]; then
    count="$lines lines"
    [ "$lines" -ne 1 ] || count="1 line"
    carry "### $p$from, whole, $count" "$p whole" 1 "$lines"
    return
  fi
  if [ "$st" = A ]; then note "### $p$from, added, $lines lines; the diff carries it whole: no text"; return; fi
  # The new side +c[,d] of each hunk: lines c to c+d-1, or c and c+1 around a pure deletion.
  changed="$(git diff --no-color --no-ext-diff -M -U0 "$fixed...HEAD" -- ":(literal)$old" ":(literal)$p" |
    awk -v n="$lines" '/^@@ / { split(substr($3, 2), r, ","); c = r[1] + 0; d = (r[2] == "") ? 1 : r[2] + 0
      a = c; b = (d == 0) ? c + 1 : c + d - 1
      for (i = a; i <= b; i++) if (i >= 1 && i <= n) print i }')"
  if [ -z "$changed" ]; then note "### $p$from, $lines lines, no line changed: no text"; return; fi
  case "$p" in
    *.md|*.markdown) kind=markdown ;;
    *.sh|*.bash) kind=shell ;;
    *) if head -n 1 "$tmp/blob" | tr -d '\r' | grep -qE '^#!.*[/ ](ba)?sh([[:space:]]|$)'; then kind=shell; else kind=other; fi ;;
  esac
  # shellcheck disable=SC2086 # the changed lines are words
  units "$kind" $changed < "$tmp/blob" > "$tmp/units"
  while read -r a b; do
    carry "### $p$from, lines $a-$b of $lines" "$p lines $a-$b" "$a" "$b"
  done < "$tmp/units"
}

git diff -z -M --name-status --no-ext-diff "$fixed...HEAD" > "$tmp/files"
while IFS= read -r -d '' st; do
  case "$st" in
    R*) IFS= read -r -d '' old; IFS= read -r -d '' new; one "${st:0:1}" "$old" "$new" ;;
    *) IFS= read -r -d '' new; one "${st:0:1}" "$new" "$new" ;;
  esac
done < "$tmp/files"

# Smallest first, ties in production order, while the carried text fits the total.
i=0
while [ "$i" -lt "$k" ]; do
  i=$((i + 1))
  [ ! -f "$tmp/$i.text" ] || echo "$(($(wc -c < "$tmp/$i.text"))) $i"
done | sort -n -k1,1 -k2,2 | awk -v total="$pack_total" '{ if (sum + $1 <= total) { sum += $1; print $2 } }' > "$tmp/keep"

echo "## Reading pack"
echo
missed=""
i=0
while [ "$i" -lt "$k" ]; do
  i=$((i + 1))
  if [ ! -f "$tmp/$i.text" ]; then
    cat "$tmp/$i.head"
    echo
  elif grep -qx "$i" "$tmp/keep"; then
    # One backtick more than the longest run anywhere in the text, and at least three.
    run="$(awk '{ s = $0; while (match(s, /`+/)) { if (RLENGTH > m) m = RLENGTH; s = substr(s, RSTART + RLENGTH) } } END { print m + 0 }' "$tmp/$i.text")"
    [ "$run" -ge 2 ] || run=2
    fence="$(printf '%*s' $((run + 1)) '' | tr ' ' '`')"
    cat "$tmp/$i.head"
    echo
    echo "$fence"
    cat "$tmp/$i.text"
    echo "$fence"
    echo
  else
    missed="$missed; $(cat "$tmp/$i.label")"
  fi
done
if [ -n "$missed" ]; then
  echo "Not carried, over the pack's $pack_total bytes: ${missed#; }. Read these at HEAD from the repository."
  echo
fi
