#!/usr/bin/env bash
# Prototype of the reading pack for #107. Run inside a git repo:
#   pack.sh <fixed>                              the section for git diff <fixed>...HEAD
#   pack.sh --sweep <commit>... -- <path>...     the section for the sweep form
# Prints the section (heading included) on stdout; the carried byte count on stderr.
set -euo pipefail
pack_whole=${W:-8192} pack_unit=${U:-4096} pack_total=${T:-65536}
sweep="" fixed="" commits=() paths=()
if [ "$1" = --sweep ]; then
  sweep=yes; shift
  while [ "$1" != -- ]; do commits+=("$1"); shift; done; shift
  paths=("$@")
else
  fixed="$1"
fi
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
empty="$(git hash-object -t tree /dev/null)"
: > "$tmp/entries"

# units <kind> <line>...: the file on stdin; prints merged "a b" ranges, one per line.
units() {
  local kind="$1"; shift
  awk -v kind="$kind" -v targets="$*" -v unit="$pack_unit" '
    function blank(i) { return t[i] ~ /^[ \t]*$/ }
    function ind(i) { match(t[i], /^[ \t]*/); return RLENGTH }
    function comment(i,  s) { if (hd[i]) return 0; s = t[i]; sub(/^[ \t]+/, "", s); return s ~ /^(#|\/\/)/ }
    function cont(i,  s, w) {
      if (hd[i] || blank(i)) return 1
      s = t[i]; sub(/^[ \t]+/, "", s)
      if (s ~ /^[\])}'"'"'"]/ || s ~ /^;;/) return 1
      w = s; sub(/[ \t;:(].*/, "", w)
      return w ~ /^(fi|done|esac|else|elif|then|do|except|finally)$/
    }
    # the quote open at the end of line s, given the one open at its start: none, a single or a double quote
    function quotes(s, q,  i, c, n, prev) {
      n = length(s); prev = " "
      for (i = 1; i <= n; i++) {
        c = substr(s, i, 1)
        if (q == "\047") { if (c == "\047") q = "" }
        else if (q == "\"") { if (c == "\\") i++; else if (c == "\"") q = "" }
        else if (c == "\\") i++
        else if (c == "#" && prev ~ /[ \t]/) break
        else if (c == "\047" || c == "\"") q = c
        prev = c
      }
      return q
    }
    function bytes(a, b,  i, n) { n = 0; for (i = a; i <= b; i++) n += length(raw[i]) + 1; return n }
    # the widest range L-r..L+r, clipped to lo..hi, within unit bytes; at least line L
    function around(L, lo, hi,  r, x, y) {
      S = L; E = L
      for (r = 1; ; r++) { x = (L - r < lo) ? lo : L - r; y = (L + r > hi) ? hi : L + r
        if (x == S && y == E) break; if (bytes(x, y) > unit) break; S = x; E = y }
    }
    # a..b widened one line at a time on each side, within lo..hi, while it stays within unit bytes
    function widen(a, b, lo, hi,  x, y) {
      S = a; E = b
      for (;;) { x = (S > lo) ? S - 1 : S; y = (E < hi) ? E + 1 : E
        if (x == S && y == E) break; if (bytes(x, y) > unit) break; S = x; E = y }
    }
    function block(s, from,  k, j) {
      k = ind(s)
      for (j = from + 1; j <= N; j++) if (!blank(j) && ind(j) <= k && !cont(j)) break
      j--; while (j > from && blank(j)) j--
      E = j
      for (j = s - 1; j >= 1 && comment(j) && ind(j) == k; j--) ;
      S = j + 1
    }
    { raw[NR] = $0; t[NR] = $0; sub(/\r$/, "", t[NR]) }
    END {
      N = NR
      if (kind == "sh") {
        word = ""; q = ""
        for (i = 1; i <= N; i++) {
          if (word != "") { s = t[i]; if (dash) sub(/^\t+/, "", s); hd[i] = 1; if (s == word) word = ""; continue }
          if (q != "" || (i > 1 && t[i-1] ~ /\\$/)) hd[i] = 1
          q = quotes(t[i], q)
          if (!comment(i) && match(t[i], /<<-?[ \t]*['"'"'"]?[A-Za-z_][A-Za-z0-9_]*/) && substr(t[i], RSTART, 3) != "<<<") {
            w = substr(t[i], RSTART + 2, RLENGTH - 2); dash = (w ~ /^-/); sub(/^-?[ \t]*['"'"'"]?/, "", w); word = w
          }
        }
      }
      if (kind == "md") {
        fence = ""
        for (i = 1; i <= N; i++) {
          s = t[i]; sub(/^[ \t]+/, "", s)
          if (match(s, /^(```+|~~~+)/)) {
            m = substr(s, 1, RLENGTH); rest = substr(s, RLENGTH + 1)
            if (fence == "") { fence = m; continue }
            if (substr(m, 1, 1) == substr(fence, 1, 1) && length(m) >= length(fence) && rest ~ /^[ \t]*$/) { fence = ""; continue }
          }
          if (fence == "" && t[i] ~ /^#{1,6}([ \t]|$)/) head[i] = 1
        }
      }
      nt = split(targets, tg, " ")
      for (q = 1; q <= nt; q++) {
        L = tg[q] + 0; if (L < 1) L = 1; if (L > N) L = N
        if (kind == "md") {
          for (s = L; s > 1 && !head[s]; s--) ;
          for (e = L + 1; e <= N && !head[e]; e++) ;
          e--; while (e > s && blank(e)) e--
          a = s; b = e
          if (bytes(a, b) > unit) { around(L, s, e); a = S; b = E }
        } else {
          A = L
          if (blank(A) || comment(A)) {
            for (A = L; A <= N && (blank(A) || comment(A)); A++) ;
            if (A > N) for (A = L; A > 1 && (blank(A) || comment(A)); A--) ;
          }
          nc = 0
          for (s = A; s >= 1; s--) if (!blank(s) && !comment(s) && !cont(s)) break
          if (s < 1) s = 1
          ch[++nc] = s; k = ind(s)
          for (j = s - 1; j >= 1 && k > 0; j--) if (!blank(j) && !comment(j) && !cont(j) && ind(j) < k) { ch[++nc] = j; k = ind(j) }
          a = 0
          for (c = nc; c >= 1; c--) { block(ch[c], A); if (bytes(S, E) <= unit) { a = S; b = E; break } }
          if (a && c < nc) { block(ch[c + 1], A); widen(a, b, S, E); a = S; b = E }
          if (!a) { block(ch[1], A); around(L, S, E); a = S; b = E }
          if (L < a) a = L; if (L > b) b = L
        }
        ra[q] = a; rb[q] = b
      }
      for (i = 2; i <= nt; i++) { x = ra[i]; y = rb[i]; for (j = i - 1; j >= 1 && ra[j] > x; j--) { ra[j+1] = ra[j]; rb[j+1] = rb[j] } ra[j+1] = x; rb[j+1] = y }
      ca = ra[1]; cb = rb[1]
      for (i = 2; i <= nt; i++) { if (ra[i] <= cb + 1) { if (rb[i] > cb) cb = rb[i] } else { print ca, cb; ca = ra[i]; cb = rb[i] } }
      if (nt) print ca, cb
    }'
}
kind_of() {
  case "$1" in
    *.md|*.markdown) echo md ;;
    *.sh|*.bash) echo sh ;;
    *) if head -n 1 | grep -qE '^#!.*[/ ](ba)?sh([ ]|$)'; then echo sh; else echo code; fi ;;
  esac
}
# emit <header> [<label> <textfile>]
emit() { printf '%s\t%s\t%s\n' "$1" "${2:-}" "${3:-}" >> "$tmp/entries"; }
slice() { awk -v a="$1" -v b="$2" 'NR >= a && NR <= b { print }'; }
k=0
one_file() {
  local st="$1" old="$2" p="$3" mode size lines gen bin hunks f kind from=""
  case "$p" in *$'\n'*) emit "$(printf '%q' "$p"), a path holding a newline: read it from the repository"; return ;; esac
  if [ "$st" = D ]; then emit "$p, deleted at HEAD: no text"; return; fi
  mode="$(git ls-tree HEAD -- ":(literal)$p" | cut -d' ' -f1)"
  case "$mode" in
    120000) emit "$p, a symbolic link to $(git cat-file blob "HEAD:$p"): no text"; return ;;
    160000) emit "$p, a submodule: no text"; return ;;
  esac
  gen="$(git check-attr --source HEAD linguist-generated -- "$p" | sed 's/.*: //')"
  case "$gen" in set|true) emit "$p, generated (linguist-generated): no text"; return ;; esac
  bin="$(git diff --numstat "$empty" HEAD -- ":(literal)$p" | cut -f1)"
  [ "$bin" != - ] || { emit "$p, binary: no text"; return; }
  size="$(git cat-file -s "HEAD:$p")"
  k=$((k + 1)); f="$tmp/t$k"
  git cat-file blob "HEAD:$p" > "$f.src"
  lines="$(awk 'END { print NR }' "$f.src")"
  [ "$st" != R ] || from=", renamed from $old"
  if [ "$size" -le "$pack_whole" ]; then
    slice 1 "$lines" < "$f.src" > "$f"; emit "$p$from, whole, $lines lines" "$p whole" "$f"; return
  fi
  if [ -n "$sweep" ]; then emit "$p, $lines lines, $size bytes: over $pack_whole bytes, so a sweep does not carry it; read it at HEAD"; return; fi
  if [ "$st" = A ]; then emit "$p, added, $lines lines, $size bytes: its text is the diff's added lines"; return; fi
  local pathspec=(":(literal)$p"); [ "$st" != R ] || pathspec=(":(literal)$old" ":(literal)$p")
  hunks="$(git diff --no-color --no-ext-diff -M -U0 "$fixed...HEAD" -- "${pathspec[@]}" |
    awk '/^@@ / { split(substr($3, 2), r, ","); c = (r[2] == "") ? 1 : r[2] + 0
      if (c == 0) { print r[1]; print r[1] + 1 } else for (i = r[1]; i < r[1] + c; i++) print i }' | tr '\n' ' ')"
  if [ -z "${hunks// /}" ]; then emit "$p$from, $lines lines, no line changed: no text"; return; fi
  kind="$(kind_of "$p" < "$f.src")"
  local n=0 a b
  while read -r a b; do
    n=$((n + 1)); slice "$a" "$b" < "$f.src" > "$f.$n"; emit "$p$from, lines $a-$b of $lines" "$p lines $a-$b" "$f.$n"
  done < <(units "$kind" $hunks < "$f.src")
}
if [ -n "$sweep" ]; then
  while IFS= read -r -d '' p; do
    if git cat-file -e "HEAD:$p" 2>/dev/null; then one_file M "$p" "$p"; else one_file D "$p" "$p"; fi
  done < <(git show -z --name-only --format= "${commits[@]}" -- "${paths[@]}" | sort -zu)
else
  while IFS= read -r -d '' st; do
    case "$st" in
      R*) IFS= read -r -d '' old; IFS= read -r -d '' new; one_file R "$old" "$new" ;;
      *) IFS= read -r -d '' new; one_file "${st:0:1}" "$new" "$new" ;;
    esac
  done < <(git diff -z -M --name-status --no-ext-diff "$fixed...HEAD")
fi
echo "## Reading pack"
echo
n=0
while IFS=$'\t' read -r header label text; do
  n=$((n + 1)); sz=0; [ -z "$text" ] || sz="$(wc -c < "$text" | tr -d ' ')"
  printf '%s\t%s\n' "$sz" "$n"
done < "$tmp/entries" | sort -t$'\t' -k1,1n -k2,2n > "$tmp/bysize"
used=0; : > "$tmp/keep"
while IFS=$'\t' read -r sz i; do
  if [ $((used + sz)) -le "$pack_total" ]; then used=$((used + sz)); echo "$i" >> "$tmp/keep"; fi
done < "$tmp/bysize"
n=0 missed=""
while IFS=$'\t' read -r header label text; do
  n=$((n + 1))
  if [ -z "$text" ]; then echo "### $header"; echo; continue; fi
  if ! grep -qx "$n" "$tmp/keep"; then missed="$missed; $label"; continue; fi
  run="$(awk '{ s = $0; while (match(s, /`+/)) { if (RLENGTH > m) m = RLENGTH; s = substr(s, RSTART + RLENGTH) } } END { print m + 0 }' "$text")"
  [ "$run" -ge 3 ] || run=2
  fence="$(printf '%*s' $((run + 1)) '' | tr ' ' '`')"
  echo "### $header"; echo; echo "$fence"; cat "$text"; echo "$fence"; echo
done < "$tmp/entries"
[ -z "$missed" ] || { echo "Not carried, over the pack's $pack_total bytes: ${missed#; }. Read these at HEAD from the repository."; echo; }
echo "pack-bytes: $used carried $(wc -l < "$tmp/keep" | tr -d " ") of $(grep -c "	.*	." "$tmp/entries")" >&2
