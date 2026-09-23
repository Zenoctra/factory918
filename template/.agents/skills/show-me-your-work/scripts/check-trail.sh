#!/usr/bin/env bash
# Refuses a show-me-your-work trail whose clock is not the run's clock: a header other than the
# template's, a row without six columns, a ts that is not a log.sh stamp, a row earlier than the
# stamped row above it, or a row outside the run. The run is the first to the last timestamp across
# the transcripts given, cut to the second, so the bounds come from the harness's clock and nobody
# types them.
# Usage: check-trail.sh <trail.tsv> <transcript.jsonl>...
# Prints one line per offending row, `line <n> <ts>: <reason>[; <reason>]`, the reasons always in
# the order columns, then stamp or earlier (a row that is not a stamp is not ordered), then outside.
# Exit 0 with one ok line; 1 with the offending lines; 2 on unreadable input; 64 on usage.
set -euo pipefail
[ "$#" -ge 2 ] || { echo 'usage: check-trail.sh <trail.tsv> <transcript.jsonl>...' >&2; exit 64; }
trail="$1"; shift
[ -f "$trail" ] || { echo "no trail at $trail" >&2; exit 2; }
header="$(cat "$(dirname "$0")/../references/decision-log-template.tsv")"
bounds="$(jq -rRn '[inputs | fromjson? | .timestamp? | strings | .[0:19] + "Z"] | select(length > 0) | "\(min) \(max)"' "$@")" || exit 2
[ -n "$bounds" ] || { echo "no timestamp in $*" >&2; exit 2; }
awk -F'\t' -v header="$header" -v first="${bounds% *}" -v last="${bounds#* }" '
function add(why, reason) { return why (why == "" ? "" : "; ") reason }
NR == 1 { if ($0 != header) { print "line 1: header is not the template'\''s"; bad = 1 }; next }
{
  ts = $1; why = ""
  if (NF != 6) why = "has " NF " columns, expected 6"
  if (ts !~ /^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[0-9][0-9]:[0-9][0-9]:[0-9][0-9]Z$/) why = add(why, "not a log.sh stamp")
  else {
    if (prev != "" && ts < prev) why = add(why, "earlier than line " pline " (" prev ")")
    if (ts < first || ts > last) why = add(why, "outside the run " first " to " last)
    prev = ts; pline = NR
  }
  if (why != "") { print "line " NR " " ts ": " why; bad = 1 }
}
END {
  if (NR == 0) { print "line 1: header is not the template'\''s"; bad = 1 }
  if (!bad) print "ok: " (NR > 0 ? NR - 1 : 0) " rows in order inside the run " first " to " last
  exit bad
}' "$trail"
