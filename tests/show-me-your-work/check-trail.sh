#!/usr/bin/env bash
# Runs template/.agents/skills/show-me-your-work/scripts/check-trail.sh against fixture trails and
# transcripts, and asserts the exit code, the exact stdout and the exact stderr of each cell of the
# scenario table under ## Testing decisions on ticket #111, in table order: rows 1 to 15, and in
# each row the columns no transcript, own, every writer and wrong. Own is a lane's transcript from
# 10:00:00.900Z to 11:00:00.100Z, so the cut to the second is exercised on both ends; every writer
# adds a second owner's from 12:00 to 13:00; wrong is an unrelated lane's the day before. Then a
# trail written by log.sh between two transcript records passes, and the script and log.sh are
# executable in the index. The fixture root has a space, and the script runs by the path the skill
# names, through the .claude/skills symlink. Exits 1 on the first miss.
set -euo pipefail
here="$(cd "$(dirname "$0")/../.." && pwd -P)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
fx="$tmp/with space"
mkdir -p "$fx/.claude" "$fx/t"
ln -s "$here/template/.agents/skills" "$fx/.claude/skills"
cd "$fx"
script=.claude/skills/show-me-your-work/scripts/check-trail.sh

own=t/own.jsonl
second=t/second.jsonl
wrong=t/wrong.jsonl
printf '%s\n' '{"type":"user","timestamp":"2026-09-22T10:00:00.900Z"}' '{"type":"custom-title"}' \
  '{"type":"assistant","timestamp":"2026-09-22T10:30:00.000Z"}' '{"type":"assistant","timestamp":"2026-09-22T11:00:00.100Z"}' > "$own"
printf '%s\n' '{"type":"user","timestamp":"2026-09-22T12:00:00.000Z"}' '{"type":"assistant","timestamp":"2026-09-22T13:00:00.000Z"}' > "$second"
printf '%s\n' '{"type":"user","timestamp":"2026-09-21T08:00:00.000Z"}' '{"type":"assistant","timestamp":"2026-09-21T08:30:00.000Z"}' > "$wrong"
run_own='outside the run 2026-09-22T10:00:00Z to 2026-09-22T11:00:00Z'
run_every='outside the run 2026-09-22T10:00:00Z to 2026-09-22T13:00:00Z'
run_wrong='outside the run 2026-09-21T08:00:00Z to 2026-09-21T08:30:00Z'
ok_own() { echo "ok: $1 rows in order inside the run 2026-09-22T10:00:00Z to 2026-09-22T11:00:00Z"; }
ok_every() { echo "ok: $1 rows in order inside the run 2026-09-22T10:00:00Z to 2026-09-22T13:00:00Z"; }
header="$(cat "$here/template/.agents/skills/show-me-your-work/references/decision-log-template.tsv")"
H="line 1: header is not the template's"
usage='usage: check-trail.sh <trail.tsv> <transcript.jsonl>...'

# trail <file> <ts>...: the template header, then one six-column row per ts.
trail() {
  local f="$1"; shift
  printf '%s\n' "$header" > "$f"
  for ts in "$@"; do printf '%s\tphase\tdecision\twhy\tevidence\tresult\n' "$ts" >> "$f"; done
}

n=0
fail() { echo "FAIL $1"; echo "  got:    $2"; echo "  wanted: $3"; exit 1; }
# run <args...>: the script, its exit in code, its stdout in out and its stderr in err.
run() { set +e; out="$("$script" "$@" 2> "$tmp/err")"; code=$?; set -e; err="$(cat "$tmp/err")"; }
# check <name> <exit> <stdout> <stderr> <args...>: all three exact.
check() {
  local name="$1" want="$2" wout="$3" werr="$4"; shift 4
  run "$@"
  if [ "$code" != "$want" ] || [ "$out" != "$wout" ] || [ "$err" != "$werr" ]; then
    fail "$name" "exit $code, stdout [$out], stderr [$err]" "exit $want, stdout [$wout], stderr [$werr]"
  fi
  n=$((n + 1))
}
# check_err <name> <args...>: exit 2, nothing on stdout, and jq's own message on stderr.
check_err() {
  local name="$1"; shift
  run "$@"
  if [ "$code" != 2 ] || [ -n "$out" ] || ! grep -q "Could not open file t/gone.jsonl" <<< "$err"; then
    fail "$name" "exit $code, stdout [$out], stderr [$err]" "exit 2, no stdout, jq's Could not open file t/gone.jsonl"
  fi
  n=$((n + 1))
}

check "1 no transcript" 64 "" "$usage" t/none.tsv
check "1 own" 2 "" "no trail at t/none.tsv" t/none.tsv "$own"
check "1 every writer" 2 "" "no trail at t/none.tsv" t/none.tsv "$own" "$second"
check "1 wrong" 2 "" "no trail at t/none.tsv" t/none.tsv "$wrong"

: > t/empty.tsv
check "2 no transcript" 64 "" "$usage" t/empty.tsv
check "2 own" 1 "$H" "" t/empty.tsv "$own"
check "2 every writer" 1 "$H" "" t/empty.tsv "$own" "$second"
check "2 wrong" 1 "$H" "" t/empty.tsv "$wrong"

printf 'ts\twhat\twhy\tevidence\tresult\n2026-09-22T10:10:00Z\tw\twhy\te\tr\n' > t/five.tsv
check "3 no transcript" 64 "" "$usage" t/five.tsv
check "3 own, a five-column header" 1 "$H"$'\nline 2 2026-09-22T10:10:00Z: has 5 columns, expected 6' "" t/five.tsv "$own"
check "3 every writer, a five-column header" 1 "$H"$'\nline 2 2026-09-22T10:10:00Z: has 5 columns, expected 6' "" t/five.tsv "$own" "$second"
check "3 wrong, a five-column header" 1 "$H"$'\nline 2 2026-09-22T10:10:00Z: has 5 columns, expected 6; '"$run_wrong" "" t/five.tsv "$wrong"
printf '%s\r\n2026-09-22T10:10:00Z\tp\td\tw\te\tr\r\n' "$header" > t/crlf.tsv
check "3 own, a CRLF header" 1 "$H" "" t/crlf.tsv "$own"
check "3 every writer, a CRLF header" 1 "$H" "" t/crlf.tsv "$own" "$second"
check "3 wrong, a CRLF header" 1 "$H"$'\nline 2 2026-09-22T10:10:00Z: '"$run_wrong" "" t/crlf.tsv "$wrong"

trail t/seven.tsv
printf '2026-09-22T10:10:00Z\tp\td\tw\te\tr\textra\n' >> t/seven.tsv
check "4 no transcript" 64 "" "$usage" t/seven.tsv
check "4 own" 1 "line 2 2026-09-22T10:10:00Z: has 7 columns, expected 6" "" t/seven.tsv "$own"
check "4 every writer" 1 "line 2 2026-09-22T10:10:00Z: has 7 columns, expected 6" "" t/seven.tsv "$own" "$second"
check "4 wrong" 1 "line 2 2026-09-22T10:10:00Z: has 7 columns, expected 6; $run_wrong" "" t/seven.tsv "$wrong"

trail t/header.tsv
check "5 no transcript" 64 "" "$usage" t/header.tsv
check "5 own" 0 "$(ok_own 0)" "" t/header.tsv "$own"
check "5 every writer" 0 "$(ok_every 0)" "" t/header.tsv "$own" "$second"
check "5 wrong" 0 "ok: 0 rows in order inside the run 2026-09-21T08:00:00Z to 2026-09-21T08:30:00Z" "" t/header.tsv "$wrong"

trail t/clean.tsv 2026-09-22T10:10:00Z 2026-09-22T10:20:00Z 2026-09-22T10:50:00Z
check "6 no transcript" 64 "" "$usage" t/clean.tsv
check "6 own" 0 "$(ok_own 3)" "" t/clean.tsv "$own"
check "6 every writer" 0 "$(ok_every 3)" "" t/clean.tsv "$own" "$second"
check "6 wrong" 1 "line 2 2026-09-22T10:10:00Z: $run_wrong
line 3 2026-09-22T10:20:00Z: $run_wrong
line 4 2026-09-22T10:50:00Z: $run_wrong" "" t/clean.tsv "$wrong"

trail t/edges.tsv 2026-09-22T10:00:00Z 2026-09-22T10:00:00Z 2026-09-22T11:00:00Z
check "7 no transcript" 64 "" "$usage" t/edges.tsv
check "7 own" 0 "$(ok_own 3)" "" t/edges.tsv "$own"
check "7 every writer" 0 "$(ok_every 3)" "" t/edges.tsv "$own" "$second"
check "7 wrong" 1 "line 2 2026-09-22T10:00:00Z: $run_wrong
line 3 2026-09-22T10:00:00Z: $run_wrong
line 4 2026-09-22T11:00:00Z: $run_wrong" "" t/edges.tsv "$wrong"

trail t/earlier.tsv 2026-09-22T10:30:00Z 2026-09-22T10:20:00Z 2026-09-22T10:40:00Z
check "8 no transcript" 64 "" "$usage" t/earlier.tsv
check "8 own" 1 "line 3 2026-09-22T10:20:00Z: earlier than line 2 (2026-09-22T10:30:00Z)" "" t/earlier.tsv "$own"
check "8 every writer" 1 "line 3 2026-09-22T10:20:00Z: earlier than line 2 (2026-09-22T10:30:00Z)" "" t/earlier.tsv "$own" "$second"
check "8 wrong" 1 "line 2 2026-09-22T10:30:00Z: $run_wrong
line 3 2026-09-22T10:20:00Z: earlier than line 2 (2026-09-22T10:30:00Z); $run_wrong
line 4 2026-09-22T10:40:00Z: $run_wrong" "" t/earlier.tsv "$wrong"

trail t/outside.tsv 2026-09-22T09:59:59Z 2026-09-22T13:00:01Z
check "9 no transcript" 64 "" "$usage" t/outside.tsv
check "9 own" 1 "line 2 2026-09-22T09:59:59Z: $run_own
line 3 2026-09-22T13:00:01Z: $run_own" "" t/outside.tsv "$own"
check "9 every writer" 1 "line 2 2026-09-22T09:59:59Z: $run_every
line 3 2026-09-22T13:00:01Z: $run_every" "" t/outside.tsv "$own" "$second"
check "9 wrong" 1 "line 2 2026-09-22T09:59:59Z: $run_wrong
line 3 2026-09-22T13:00:01Z: $run_wrong" "" t/outside.tsv "$wrong"

trail t/both.tsv 2026-09-22T10:30:00Z 2026-09-22T09:00:00Z
check "10 no transcript" 64 "" "$usage" t/both.tsv
check "10 own" 1 "line 3 2026-09-22T09:00:00Z: earlier than line 2 (2026-09-22T10:30:00Z); $run_own" "" t/both.tsv "$own"
check "10 every writer" 1 "line 3 2026-09-22T09:00:00Z: earlier than line 2 (2026-09-22T10:30:00Z); $run_every" "" t/both.tsv "$own" "$second"
check "10 wrong" 1 "line 2 2026-09-22T10:30:00Z: $run_wrong
line 3 2026-09-22T09:00:00Z: earlier than line 2 (2026-09-22T10:30:00Z); $run_wrong" "" t/both.tsv "$wrong"

trail t/typed.tsv 2026-09-22T10:30:00Z 17:45:00Z
printf '\n' >> t/typed.tsv
printf '2026-09-22 10:40:00\tp\td\tw\te\tr\n2026-09-22T10:20:00Z\tp\td\tw\te\tr\n' >> t/typed.tsv
typed='line 3 17:45:00Z: not a log.sh stamp
line 4 : has 0 columns, expected 6; not a log.sh stamp
line 5 2026-09-22 10:40:00: not a log.sh stamp'
check "11 no transcript" 64 "" "$usage" t/typed.tsv
check "11 own" 1 "$typed
line 6 2026-09-22T10:20:00Z: earlier than line 2 (2026-09-22T10:30:00Z)" "" t/typed.tsv "$own"
check "11 every writer" 1 "$typed
line 6 2026-09-22T10:20:00Z: earlier than line 2 (2026-09-22T10:30:00Z)" "" t/typed.tsv "$own" "$second"
check "11 wrong" 1 "line 2 2026-09-22T10:30:00Z: $run_wrong
$typed
line 6 2026-09-22T10:20:00Z: earlier than line 2 (2026-09-22T10:30:00Z); $run_wrong" "" t/typed.tsv "$wrong"

trail t/shared.tsv 2026-09-22T10:10:00Z 2026-09-22T10:50:00Z 2026-09-22T12:10:00Z 2026-09-22T12:50:00Z
check "12 no transcript" 64 "" "$usage" t/shared.tsv
check "12 own" 1 "line 4 2026-09-22T12:10:00Z: $run_own
line 5 2026-09-22T12:50:00Z: $run_own" "" t/shared.tsv "$own"
check "12 every writer" 0 "$(ok_every 4)" "" t/shared.tsv "$own" "$second"
check "12 wrong" 1 "line 2 2026-09-22T10:10:00Z: $run_wrong
line 3 2026-09-22T10:50:00Z: $run_wrong
line 4 2026-09-22T12:10:00Z: $run_wrong
line 5 2026-09-22T12:50:00Z: $run_wrong" "" t/shared.tsv "$wrong"

check "13 no transcript" 64 "" "$usage" t/clean.tsv
check_err "13 own" t/clean.tsv t/gone.jsonl
check_err "13 every writer" t/clean.tsv "$own" t/gone.jsonl
check_err "13 wrong" t/clean.tsv "$wrong" t/gone.jsonl

printf '%s\n' '{"type":"custom-title"}' '{"type":"agent-name","timestamp":7}' > t/untimed.jsonl
printf '%s\n' '{"type":"last-prompt"}' > t/untimed2.jsonl
check "14 no transcript" 64 "" "$usage" t/clean.tsv
check "14 own" 2 "" "no timestamp in t/untimed.jsonl" t/clean.tsv t/untimed.jsonl
check "14 every writer" 2 "" "no timestamp in t/untimed.jsonl t/untimed2.jsonl" t/clean.tsv t/untimed.jsonl t/untimed2.jsonl
check "14 wrong" 2 "" "no timestamp in t/untimed2.jsonl" t/clean.tsv t/untimed2.jsonl

# A live lane's transcript: a line that is not JSON, and a torn last record whose prefix would
# widen the run to 23:59 if it were read.
torn='{"type":"assistant","timestamp":"2026-09-22T23:59:59.000Z","mess'
{ cat "$own"; echo 'not json'; printf '%s' "$torn"; } > t/own-live.jsonl
{ cat "$wrong"; echo 'not json'; printf '%s' "$torn"; } > t/wrong-live.jsonl
check "15 no transcript" 64 "" "$usage" t/clean.tsv
check "15 own, as row 6" 0 "$(ok_own 3)" "" t/clean.tsv t/own-live.jsonl
check "15 every writer, as row 6" 0 "$(ok_every 3)" "" t/clean.tsv t/own-live.jsonl "$second"
check "15 wrong, as row 6" 1 "line 2 2026-09-22T10:10:00Z: $run_wrong
line 3 2026-09-22T10:20:00Z: $run_wrong
line 4 2026-09-22T10:50:00Z: $run_wrong" "" t/clean.tsv t/wrong-live.jsonl

stamp() { printf '{"type":"user","timestamp":"%s.000Z"}\n' "$(date -u +%Y-%m-%dT%H:%M:%S)"; }
stamp > t/live.jsonl
.claude/skills/show-me-your-work/scripts/log.sh t/log.tsv build "wrote the check" "the ticket asks" "commit abc" "tests green"
.claude/skills/show-me-your-work/scripts/log.sh t/log.tsv review "ran the check" "before merge" "t/log.tsv" "ok"
stamp >> t/live.jsonl
run t/log.tsv t/live.jsonl
if [ "$code" != 0 ] || ! grep -q '^ok: 2 rows in order inside the run ' <<< "$out" || [ -n "$err" ]; then
  fail "log.sh rows between two transcript records" "exit $code, stdout [$out], stderr [$err]" "exit 0, ok: 2 rows ..."
fi
n=$((n + 1))

for f in check-trail.sh log.sh; do
  mode="$(git -C "$here" ls-files -s "template/.agents/skills/show-me-your-work/scripts/$f" | cut -d' ' -f1)"
  [ "$mode" = 100755 ] || fail "$f is executable in the index" "${mode:-not tracked}" 100755
  n=$((n + 1))
done

echo "ok $n assertions"
