section() {
  awk '$0 == "## Reading pack" { on = 1; print; next }
    on && fence == "" && /^## / { exit }
    on { print }
    on && /^```+$/ { if (fence == "") fence = $0; else if ($0 == fence) fence = "" }' "$1"
}
fence() {
  if ! section "$1" | H="$2" F="$3" awk '
      st == 0 && $0 == ENVIRON["H"] { st = 1; next }
      st == 1 { st = ($0 == "") ? 2 : -1; next }
      st == 2 { ok = ($0 == ENVIRON["F"]); st = -1 }
      END { exit !ok }'; then
    echo "FAIL $4: $1: the entry $2 does not open with $3"; exit 1
  fi
  n=$((n + 1))
}
notext() {
  if ! section "$1" | L="$2" awk 'st == 0 && $0 == ENVIRON["L"] { st = 1; next } st == 1 { ok = ($0 == ""); st = 2 } END { exit !ok }'; then
    echo "FAIL $3: $1 lacks the line, then a blank line: $2"; exit 1
  fi
  n=$((n + 1))
}
at() { grep -m 1 -nxF -- "$2" "$1" | cut -d: -f1; }
