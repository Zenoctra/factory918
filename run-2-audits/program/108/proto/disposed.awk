function field(s,   rest, off, k, v) {        # the last fixed:/accepted: field, or none
  k = ""; off = 0; rest = s
  while (match(rest, /(^|[ \t])(fixed|accepted):/)) {
    k = (substr(rest, RSTART, RLENGTH) ~ /fixed:$/) ? "fixed" : "accepted"
    off += RSTART + RLENGTH - 1; v = substr(s, off + 1); rest = v
  }
  if (k == "") return "none" US
  sub(/^[ \t]+/, "", v); return k US v
}
BEGIN { US = "\037"; base = -1 }
{ sub(/\r$/, ""); sub(/[ \t]+$/, "") }
/^(```|~~~)/ && fence == "" { opened = on ? $0 : "" }
# ... "$fenced" spliced here ...
{ t = tolower($0); lv = 0; if (match($0, /^#+[ \t]/)) lv = RLENGTH - 1 }
(mode == "risks" && ($0 == "## Risks" || $0 == "### Risks")) ||
(mode == "flags" && $0 ~ /^### Writer flags [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]$/) { on = 1; top = lv; base = -1; next }
{ x = t; sub(/^#+[ \t]+/, "", x) }
(lv && index(x, w) == 1 && substr(x, length(w) + 1, 1) !~ /[a-z]/) ||
t ~ ("^[*_]*" w "[ 0-9-]*[*_]*[:.]?[*_]*$") { print "near" US US $0; if (lv && lv <= top) on = 0; next }
lv && lv <= top { on = 0; next }
!on || $0 == "" { next }
{ match($0, /^[ \t]*/); if (base < 0) base = RLENGTH; if (RLENGTH > base) next; print field($0) US $0 }
END { if (fence != "" && opened != "") print "fence" US US opened }
