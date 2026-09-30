section() {
  awk '$0 == "## Reading pack" { on = 1; print; next }
    on && fence == "" && /^## / { exit }
    on { print }
    on && /^```+$/ { if (fence == "") fence = $0; else if ($0 == fence) fence = "" }' "$1"
}
fence() {
  if ! section "$1" | H="$2" F="$3" awk '$0 == ENVIRON["H"] { getline; if ($0 == "") { getline; ok = ($0 == ENVIRON["F"]) } exit }
      END { exit !ok }'; then
    echo "FAIL $4: $1: the entry $2 does not open with $3"; exit 1
  fi
  n=$((n + 1))
}
notext() {
  if ! section "$1" | L="$2" awk '$0 == ENVIRON["L"] { getline; ok = ($0 == ""); exit } END { exit !ok }'; then
    echo "FAIL $3: $1 lacks the line, then a blank line: $2"; exit 1
  fi
  n=$((n + 1))
}
at() { grep -nxF -- "$2" "$1" | head -1 | cut -d: -f1; }
