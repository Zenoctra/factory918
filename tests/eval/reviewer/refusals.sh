#!/usr/bin/env bash
# Asserts tests/eval/reviewer/reviewer.py against the `## Design` section of ticket #103: first the
# cells of the scenario table in its order (rows 1 to 24; within a row the columns run Claude, run
# Codex, run withheld, collect, table, a dash skipped), then one check per scoring rule of the
# Contract. It builds a temporary repository, a one-round fixture set `r1` whose Standards brief
# carries one label, a fake pstack-runner and hand-written subagent transcripts, and points every
# REVIEWER_* knob at them. Exits 1 on the first miss.
set -euo pipefail
here="$(cd "$(dirname "$0")/../../.." && pwd -P)"
script="$here/tests/eval/reviewer/reviewer.py"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

C=claude:opus-5
X=codex:gpt-6-astra
W=claude:fable-5.1

git init -q "$tmp/repo"
echo 'echo hi' > "$tmp/repo/a.sh"
git -C "$tmp/repo" add a.sh
git -C "$tmp/repo" -c user.name=t -c user.email=t@example.com commit -q -m init
head="$(git -C "$tmp/repo" rev-parse HEAD)"
short="${head:0:7}"

brief() {
  cat <<EOF
Review the change.
The diff is long; read it from \`.scratch/review/x/diff\`.
Write your report to \`.scratch/review/x/$1-report.md\` and reply with only that path.
EOF
}
fx="$tmp/fx"
mkdir -p "$fx/rounds/r1/review" "$tmp/rep"
printf 'pr=1\nhead=%s\n' "$head" > "$fx/rounds/r1/round"
brief standards > "$fx/rounds/r1/review/standards-brief.md"
brief spec > "$fx/rounds/r1/review/spec-brief.md"
echo 'diff --git a/a.sh b/a.sh' > "$fx/rounds/r1/review/diff"
{
  printf '# brief\tid\tkind\tanchors\ttitle\n'
  printf 'r1/standards\tS1\tfixed\tunmatched glob && exits? 0\tAn unmatched glob is dropped\n'
} > "$fx/labels"

cat > "$tmp/rep/hit.md" <<'EOF'
## Would break

1. **An unmatched glob is dropped.** The gate exits 0 anyway.
Documented step: the gate.

## Fails open

## Standards breaches

## Fix alongside

hard findings: 1
EOF
grep -v '^hard findings' "$tmp/rep/hit.md" > "$tmp/rep/nocount.md"
sed 's/^hard findings: 1$/hard findings: 2/' "$tmp/rep/hit.md" > "$tmp/rep/exceeds.md"
cat > "$tmp/rep/noheadings.md" <<'EOF'
## Standards breaches

1. **An unmatched glob is dropped.** The gate exits 0 anyway.

hard findings: 0
EOF
cat > "$tmp/rep/fencedcount.md" <<'EOF'
## Would break

1. **An unmatched glob is dropped.** The gate exits 0 anyway.

## Fails open

~~~
hard findings: 1
~~~
EOF
cat > "$tmp/rep/fencedheadings.md" <<'EOF'
## Standards breaches

1. **An unmatched glob is dropped.** The gate exits 0 anyway.

~~~
## Would break
~~~

hard findings: 0
EOF
cat > "$tmp/rep/badcal.md" <<'EOF'
## Would break

1. **A missing ticket line.** The brief refuses.

2. **An unmatched glob is dropped.** The gate exits 0 anyway.

## Fails open

hard findings: 2
EOF
cp "$tmp/rep/hit.md" "$fx/rounds/r1/review/standards-report.historical.md"

cp -R "$fx" "$tmp/fx-gone"
printf 'pr=1\nhead=%s\n' 1111111111111111111111111111111111111111 > "$tmp/fx-gone/rounds/r1/round"
cp -R "$fx" "$tmp/fx-badcal"
cp "$tmp/rep/badcal.md" "$tmp/fx-badcal/rounds/r1/review/standards-report.historical.md"
for m in m1 m2 m3 m4 m5; do cp -R "$fx" "$tmp/$m"; done
printf 'r1/standards\tS2\tfixed\n' >> "$tmp/m1/labels"
printf 'r9/standards\tS2\tfixed\tglob && exits\tx\n' >> "$tmp/m2/labels"
printf 'r1/spec\tP1\tfixed\t(unclosed && exits\tx\n' >> "$tmp/m3/labels"
printf '%s\n' "Also read \`.scratch/review/x/missing\`." >> "$tmp/m4/rounds/r1/review/spec-brief.md"
printf 'pr=1\n' > "$tmp/m5/rounds/r1/round"

cat > "$tmp/fake-runner" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
while [ "$#" -gt 0 ]; do
  case "$1" in
    --model) model=$2 ;;
    --effort) effort=$2 ;;
    --mode) mode=$2 ;;
    --prompt) prompt=$2 ;;
    --receipt) receipt=$2 ;;
  esac
  shift 2
done
echo "$model $effort $mode" >> "$FAKE_CALLS"
[ "$FAKE_STATUS" != crash ] || exit 64
brief="$(sed -E 's/^Read `([^`]*)`.*/\1/' "$prompt")"
error=null
if [ "$FAKE_STATUS" = complete ]; then
  [ "$FAKE_REPORT" = none ] || cp "$FAKE_REPORT" "${brief%-brief.md}-report.md"
elif [ "${FAKE_ERROR:-none}" = usage-limit ]; then
  error="{\"message\":\"child exited with status 1\",\"evidence\":\"{\\\"type\\\":\\\"error\\\",\\\"message\\\":\\\"You have hit your usage limit. Try again at Sep 23rd, 2026 2:44 AM.\\\"}\"}"
else
  error='"HTTP 400 not supported when using Codex with a ChatGPT account"'
fi
printf '{"schemaVersion":1,"status":"%s","model":"%s","effort":"%s","reportedModel":null,"modelVerified":false,"modelEvidence":"pinned-argv","elapsedMs":4000,"usage":{"inputTokens":1000,"cachedInputTokens":600,"cacheCreationInputTokens":0,"outputTokens":50},"error":%s}\n' \
  "$FAKE_STATUS" "$model" "$effort" "$error" > "$receipt"
EOF
chmod +x "$tmp/fake-runner"

cat > "$tmp/h.py" <<'EOF'
import json, os, re, shutil, sys

cmd, *args = sys.argv[1:]
if cmd in ("get", "field"):
    value = json.loads(args[0]) if cmd == "get" else json.load(open(args[0]))
    for key in args[1].split("."):
        value = value[key]
    print(value if isinstance(value, str) else json.dumps(value))
elif cmd == "checkout":
    print(re.search(r"You are working in `([^`]*)`", json.loads(args[0])["prompt"]).group(1))
elif cmd == "mtime":
    print(os.stat(args[0]).st_mtime_ns)
elif cmd == "finish":
    line, report, model, state, read, root, name = args
    prompt = json.loads(line)["prompt"]
    brief = re.match(r"Read `([^`]*)`", prompt).group(1)
    if report != "none":
        shutil.copyfile(report, brief.replace("-brief.md", "-report.md"))
    tool, sep, target = read.partition("|")
    if not sep:
        tool, target = "Read", read or brief
    tool_input = {"file_path": target} if tool in ("Read", "Write", "Edit") else {"path": target} if target else {}

    def at(s):
        return f"2026-09-22T10:00:0{s}.000Z"

    def usage(i, r, c, o):
        return {"input_tokens": i, "cache_read_input_tokens": r, "cache_creation_input_tokens": c, "output_tokens": o}

    lines = [
        {"type": "user", "message": {"role": "user", "content": prompt}, "timestamp": at(0)},
        {"type": "assistant", "requestId": "r1", "timestamp": at(1), "message": {
            "model": model, "stop_reason": "tool_use", "usage": usage(10, 100, 5, 20),
            "content": [{"type": "tool_use", "name": tool, "input": tool_input}]}},
        {"type": "user", "message": {"role": "user", "content": [{"type": "tool_result", "content": "ok"}]}, "timestamp": at(2)},
    ]
    if state in ("finished", "textnull"):
        done = {"type": "assistant", "requestId": "r2", "timestamp": at(5), "message": {
            "model": model, "stop_reason": "end_turn" if state == "finished" else None,
            "usage": usage(3, 200, 0, 7),
            "content": [{"type": "text", "text": "done"}]}}
        lines += [done, done, {"type": "attachment", "timestamp": at(6)}]
    elif state == "toolnull":
        lines.append({"type": "assistant", "requestId": "r2", "timestamp": at(5), "message": {
            "model": model, "stop_reason": None, "usage": usage(3, 200, 0, 7),
            "content": [{"type": "tool_use", "name": tool, "input": tool_input}]}})
    path = os.path.join(root, "s", "subagents", f"agent-{name}.jsonl")
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w") as f:
        f.writelines(json.dumps(x) + "\n" for x in lines)
    print(path)
EOF

export REVIEWER_REPO="$tmp/repo" REVIEWER_FIXTURES="$fx" REVIEWER_WORK="$tmp/w" \
  REVIEWER_RUNNER="$tmp/fake-runner" FAKE_CALLS="$tmp/calls"

out=""
err=""
code=0
run() {
  set +e
  out="$(python3 "$script" "$@" 2>"$tmp/stderr")"
  code=$?
  set -e
  err="$(cat "$tmp/stderr")"
}
n=0
check() {
  local label=$1
  shift
  if "$@"; then
    n=$((n + 1))
    echo "ok $n $label"
  else
    echo "FAIL $label"
    echo "  exit:   $code"
    echo "  stdout: $out"
    echo "  stderr: $err"
    exit 1
  fi
}
is() { [ "$1" = "$2" ]; }
has() { grep -qF -- "$2" <<<"$1"; }
lacks() { ! grep -qF -- "$2" <<<"$1"; }
starts() { [[ "$1" == "$2"* ]]; }
lines() { [ "$(grep -c . <<<"$1" || true)" = "$2" ]; }
exists() { [ -e "$1" ]; }
absent() { [ ! -e "$1" ]; }
h() { python3 "$tmp/h.py" "$@"; }
row() {
  local IFS=$'\t'
  echo "$*"
}
use() { export REVIEWER_OUT="$tmp/out/$1" REVIEWER_TRANSCRIPTS="$tmp/tr/$1"; }
fresh() {
  use "$1"
  mkdir -p "$REVIEWER_TRANSCRIPTS"
  : > "$FAKE_CALLS"
  export FAKE_STATUS=complete FAKE_REPORT="$tmp/rep/hit.md" FAKE_ERROR=none
}
rundir() { echo "$REVIEWER_OUT/runs/${1//:/-}/r1/$2/$3"; }
scores() { cat "$REVIEWER_OUT/scores.tsv"; }
t=0
transcript=""
finish() {
  t=$((t + 1))
  transcript="$(h finish "$1" "$2" "${3:-claude-opus-5}" "${4:-finished}" "${5:-}" "$REVIEWER_TRANSCRIPTS" "$t")"
}
cell() {
  awk -F'|' -v c="$1" -v m="$2" '
    NR == 1 { for (i = 2; i < NF; i++) { h = $i; gsub(/^ +| +$/, "", h); if (h == c) k = i } }
    index($0, m) == 1 { v = $k; gsub(/ /, "", v); print v }' "$REVIEWER_OUT/table.md"
}

# Row 1
fresh r1c
run run "$C" r1/standards 2
check "1 run claude: exit 0" is "$code" 0
check "1 run claude: one launch line per run" lines "$out" 2
l1="$(sed -n 1p <<<"$out")"
l2="$(sed -n 2p <<<"$out")"
co1="$(h checkout "$l1")"
co2="$(h checkout "$l2")"
check "1 run claude: the agent is tier-lower" is "$(h get "$l1" agent.subagent_type)" tier-lower
check "1 run claude: the description" is "$(h get "$l1" description)" "Review $short standards"
check "1 run claude: the organic prompt" is "$(h get "$l1" prompt)" "Read \`$co1/.scratch/review/x/standards-brief.md\` whole and follow it. You are working in \`$co1\`; every relative path in the brief is relative to it."
check "1 run claude: each run has its own checkout" test "$co1" != "$co2"
check "1 run claude: the checkout holds the tree" exists "$co1/a.sh"
check "1 run claude: the checkout holds the brief" exists "$co1/.scratch/review/x/standards-brief.md"
check "1 run claude: the checkout holds the diff" exists "$co1/.scratch/review/x/diff"
check "1 run claude: not the other axis's brief" absent "$co1/.scratch/review/x/spec-brief.md"
check "1 run claude: not the historical report" absent "$co1/.scratch/review/x/standards-report.historical.md"
check "1 run claude: no .git" absent "$co1/.git"
fresh r1x
run run "$X" r1/standards 2
check "1 run codex: exit 0" is "$code" 0
check "1 run codex: one score line per run" lines "$(grep 'recall 1/1' <<<"$out" || true)" 2
check "1 run codex: k=1 collected complete" is "$(h field "$(rundir "$X" standards 1)/receipt.json" status)" complete
check "1 run codex: k=2 collected complete" is "$(h field "$(rundir "$X" standards 2)/receipt.json" status)" complete
check "1 run codex: the checkout is removed" absent "$(h field "$(rundir "$X" standards 1)/run.json" checkout)"
check "1 run codex: Standards at effort medium, isolated-write" has "$(cat "$FAKE_CALLS")" "gpt-6-astra medium isolated-write"
run run "$X" r1/spec 1
check "1 run codex: Spec at effort high" has "$(cat "$FAKE_CALLS")" "gpt-6-astra high isolated-write"
fresh r1w
run run "$W" r1/standards 3
check "1 run withheld: exit 0" is "$code" 0
check "1 run withheld: the dropout line" has "$out" "dropout $(rundir "$W" standards 1) withheld:"
check "1 run withheld: a dropout receipt" is "$(h field "$(rundir "$W" standards 1)/receipt.json" status)" dropout
check "1 run withheld: no report" absent "$(rundir "$W" standards 1)/report.md"
check "1 run withheld: k=2 not attempted" absent "$(rundir "$W" standards 2)"
fresh r1collect
run collect
check "1 collect: exit 0" is "$code" 0
check "1 collect: the zero summary" is "$out" "collected 0 · in flight 0 · unlaunched 0 · stuck 0"

# Row 2
fresh r2
for d in claude:nope codex:nope fable:nope; do
  run run "$d" r1/standards 1
  check "2 unknown descriptor $d: exit 2" is "$code" 2
  check "2 unknown descriptor $d: invalid choice" has "$err" "invalid choice"
done

# Row 3
for d in "$C" "$X" "$W"; do
  run run "$d" r9/standards 1
  check "3 unknown brief, $d: exit 2" is "$code" 2
  check "3 unknown brief, $d: invalid choice" has "$err" "invalid choice"
done

# Row 4
for d in "$C" "$X" "$W"; do
  run run "$d" r1/standards 0
  check "4 N=0, $d: exit 2" is "$code" 2
  check "4 N=0, $d: must be at least 1" has "$err" "must be at least 1"
  run run "$d" r1/standards x
  check "4 N=x, $d: exit 2" is "$code" 2
  check "4 N=x, $d: invalid" has "$err" "invalid"
done

# Row 5
fresh r5
REVIEWER_FIXTURES="$tmp/fx-gone" run run "$C" r1/standards 1
check "5 run claude: exit 1" is "$code" 1
check "5 run claude: names the keep ref" has "$err" "refs/keep/103/1111111"
check "5 run claude: names the fetch command" has "$err" "git fetch origin 'refs/keep/103/*:refs/keep/103/*'"
check "5 run claude: nothing written" absent "$REVIEWER_OUT/runs"
REVIEWER_FIXTURES="$tmp/fx-gone" run run "$X" r1/standards 1
check "5 run codex: exit 1" is "$code" 1
check "5 run codex: names the keep ref" has "$err" "refs/keep/103/1111111"
check "5 run codex: names the fetch command" has "$err" "git fetch origin 'refs/keep/103/*:refs/keep/103/*'"
check "5 run codex: nothing written" absent "$REVIEWER_OUT/runs"
check "5 run codex: the runner is not called" is "$(cat "$FAKE_CALLS")" ""
REVIEWER_FIXTURES="$tmp/fx-gone" run run "$W" r1/standards 1
check "5 run withheld: exit 0" is "$code" 0
check "5 run withheld: a dropout receipt" is "$(h field "$(rundir "$W" standards 1)/receipt.json" status)" dropout

# Row 6
fresh r6c
run run "$C" r1/standards 1
finish "$out" "$tmp/rep/hit.md"
run collect
m1="$(h mtime "$(rundir "$C" standards 1)/receipt.json")"
run run "$C" r1/standards 2
check "6 run claude: k=1 skipped" has "$out" "collected $(rundir "$C" standards 1)"
check "6 run claude: one launch line, for k=2" lines "$(grep '^{' <<<"$out" || true)" 1
fresh r6x
run run "$X" r1/standards 1
run run "$X" r1/standards 2
check "6 run codex: k=1 skipped" has "$out" "collected $(rundir "$X" standards 1)"
check "6 run codex: the runner is called once per k" lines "$(cat "$FAKE_CALLS")" 2
fresh r6w
run run "$W" r1/standards 1
run run "$W" r1/standards 2
check "6 run withheld: dropout printed" has "$out" "dropout $(rundir "$W" standards 1)"
check "6 run withheld: no second receipt" absent "$(rundir "$W" standards 2)"
use r6c
run collect
check "6 collect: counted collected" has "$out" "collected 1 ·"
check "6 collect: the receipt is not rewritten" is "$(h mtime "$(rundir "$C" standards 1)/receipt.json")" "$m1"
run table
check "6 table: included" has "$(scores)" "$(row "$C" r1/standards 1)"

# Row 7
fresh r7
FAKE_STATUS=crash run run "$X" r1/standards 1
: > "$FAKE_CALLS"
run run "$X" r1/standards 1
check "7 run codex: exit 1" is "$code" 1
check "7 run codex: names the directory" has "$err" "$(rundir "$X" standards 1)"
check "7 run codex: the runner is not called" is "$(cat "$FAKE_CALLS")" ""
run collect
check "7 collect: listed stuck" has "$out" "stuck $(rundir "$X" standards 1)"
run run "$X" r1/spec 1
run table
check "7 table: excluded" lacks "$(scores)" "$(row "$X" r1/standards)"

# Row 8
fresh r8
run run "$C" r1/standards 1
line="$out"
run run "$C" r1/standards 1
check "8 run claude: the same launch line again" is "$out" "$line"
run collect
check "8 collect: listed unlaunched" has "$out" "unlaunched $line"
run run "$X" r1/spec 1
run table
check "8 table: excluded" lacks "$(scores)" "$C"

# Row 9
fresh r9
run run "$C" r1/standards 1
finish "$out" none claude-opus-5 inflight
run run "$C" r1/standards 1
check "9 run claude: nothing printed" is "$code:$out" "0:"
run collect
check "9 collect: counted in flight" has "$out" "in flight 1"
check "9 collect: no receipt" absent "$(rundir "$C" standards 1)/receipt.json"
run run "$X" r1/spec 1
run table
check "9 table: excluded" lacks "$(scores)" "$C"

# Row 10
fresh r10
run run "$C" r1/standards 2
l1="$(sed -n 1p <<<"$out")"
l2="$(sed -n 2p <<<"$out")"
finish "$l1" "$tmp/rep/hit.md"
t1="$transcript"
finish "$l1" "$tmp/rep/hit.md"
t2="$transcript"
finish "$l2" "$tmp/rep/hit.md"
run run "$C" r1/standards 2
check "10 run claude: exit 1" is "$code" 1
check "10 run claude: names the first transcript" has "$err" "$t1"
check "10 run claude: names the second transcript" has "$err" "$t2"
run collect
check "10 collect: exit 1" is "$code" 1
check "10 collect: nothing collected" absent "$(rundir "$C" standards 1)/receipt.json"
check "10 collect: not even the finished sibling" absent "$(rundir "$C" standards 2)/receipt.json"

# Row 11
fresh r11
run run "$C" r1/standards 1
rm -rf "$REVIEWER_TRANSCRIPTS"
run run "$C" r1/standards 1
check "11 run claude: exit 1" is "$code" 1
check "11 run claude: names the directory" has "$err" "$REVIEWER_TRANSCRIPTS"
run collect
check "11 collect: exit 1" is "$code" 1

# Row 12
fresh r12
FAKE_STATUS=unavailable-model run run codex:gpt-6-terra r1/standards 3
check "12 run codex: exit 0" is "$code" 0
check "12 run codex: a dropout receipt" is "$(h field "$(rundir codex:gpt-6-terra standards 1)/receipt.json" status)" dropout
check "12 run codex: carrying the error" has "$(h field "$(rundir codex:gpt-6-terra standards 1)/receipt.json" detail)" "unavailable-model: HTTP 400"
check "12 run codex: later k not attempted" lines "$(cat "$FAKE_CALLS")" 1
run table
check "12 table: the row reads dropout" has "$(cat "$REVIEWER_OUT/table.md")" "dropout unavailable-model"

# Rows 13 to 17: every failure on one Codex brief, then the same failures through Claude transcripts.
fresh rfail
FAKE_STATUS=timed-out run run "$X" r1/standards 2
o13="$code:$out"
calls13="$(cat "$FAKE_CALLS")"
FAKE_REPORT=none run run "$X" r1/standards 3
o14="$out"
FAKE_REPORT="$tmp/rep/nocount.md" run run "$X" r1/standards 4
o15="$out"
FAKE_REPORT="$tmp/rep/exceeds.md" run run "$X" r1/standards 5
o16="$out"
FAKE_REPORT="$tmp/rep/noheadings.md" run run "$X" r1/standards 6
o17="$out"
run table
fail_scores="$(scores)"
fresh rfailc
run run "$C" r1/standards 4
for k in 1 2 3 4; do
  report=(none "$tmp/rep/nocount.md" "$tmp/rep/exceeds.md" "$tmp/rep/noheadings.md")
  finish "$(sed -n "${k}p" <<<"$out")" "${report[$((k - 1))]}"
done
run collect
c14="$out"

use rfail
check "13 run codex: a context failure" has "$o13" "0:$(rundir "$X" standards 1) context-failure timed-out"
check "13 run codex: the next k still runs" lines "$calls13" 2
check "13 table: counted a context failure" has "$fail_scores" "$(row "$X" r1/standards 1 timed-out)"
use rfail
check "14 run codex: no report" has "$o14" "$(rundir "$X" standards 3) context-failure no-report"
use rfailc
check "14 collect: no report" has "$c14" "$(rundir "$C" standards 1) context-failure no-report"
use rfail
check "14 table: counted a context failure" has "$fail_scores" "$(row "$X" r1/standards 3 no-report)"
check "15 run codex: no count line" has "$o15" "$(rundir "$X" standards 4) context-failure no-count-line"
use rfailc
check "15 collect: no count line" has "$c14" "$(rundir "$C" standards 2) context-failure no-count-line"
use rfail
check "15 table: counted a context failure" has "$fail_scores" "$(row "$X" r1/standards 4 no-count-line)"
check "16 run codex: count exceeds items" has "$o16" "$(rundir "$X" standards 5) context-failure count-exceeds-items"
use rfailc
check "16 collect: count exceeds items" has "$c14" "$(rundir "$C" standards 3) context-failure count-exceeds-items"
use rfail
check "16 table: counted a context failure" has "$fail_scores" "$(row "$X" r1/standards 5 count-exceeds-items)"
check "17 run codex: no hard headings" has "$o17" "$(rundir "$X" standards 6) context-failure no-hard-headings"
use rfailc
check "17 collect: no hard headings" has "$c14" "$(rundir "$C" standards 4) context-failure no-hard-headings"
use rfail
check "17 table: counted a context failure" has "$fail_scores" "$(row "$X" r1/standards 6 no-hard-headings)"

# Row 18
check "18 run codex: model_verified false" is "$(h field "$(rundir "$X" standards 6)/receipt.json" model_verified)" false
fresh r18
run run "$C" r1/standards 1
finish "$out" "$tmp/rep/hit.md" claude-opus-5-5
run collect
check "18 collect: exit 1" is "$code" 1
check "18 collect: names the served model" has "$err" "claude-opus-5-5"
check "18 collect: nothing collected" absent "$(rundir "$C" standards 1)/receipt.json"

# Row 19
fresh r19
run run "$C" r1/standards 1
finish "$out" "$tmp/rep/hit.md" claude-opus-5 finished /etc/hosts
run collect
check "19 collect: exit 0" is "$code" 0
check "19 collect: contaminated" is "$(h field "$(rundir "$C" standards 1)/receipt.json" status)" contaminated
check "19 collect: the offending path in detail" has "$(h field "$(rundir "$C" standards 1)/receipt.json" detail)" /etc/hosts
run run "$X" r1/spec 1
run table
check "19 table: excluded from scores" lacks "$(scores)" "$C"
check "19 table: counted contaminated" is "$(cell contaminated "| $C | standards |")" 1
i=0
for reach in 'Grep|' 'Glob|' 'Grep|/etc' 'Glob|/etc'; do
  i=$((i + 1))
  tool="${reach%%|*}"
  path="${reach#*|}"
  fresh "r19$i"
  run run "$C" r1/standards 1
  finish "$out" "$tmp/rep/hit.md" claude-opus-5 finished "$reach"
  run collect
  check "19 collect: $tool ${path:-with no path} is contaminated" \
    is "$(h field "$(rundir "$C" standards 1)/receipt.json" status)" contaminated
  check "19 collect: $tool ${path:-with no path} named in detail" \
    has "$(h field "$(rundir "$C" standards 1)/receipt.json" detail)" "$tool ${path:-with no path}"
done
fresh r19overflow
run run "$C" r1/standards 1
finish "$out" "$tmp/rep/hit.md" claude-opus-5 finished "Read|$REVIEWER_TRANSCRIPTS/s/tool-results/b0gweyh98.txt"
run collect
check "19 collect: a Read of the harness's own overflow is not contamination" \
  is "$(h field "$(rundir "$C" standards 1)/receipt.json" status)" complete
fresh r19transcripts
run run "$C" r1/standards 1
finish "$out" "$tmp/rep/hit.md" claude-opus-5 finished "Read|$REVIEWER_TRANSCRIPTS/s/notes.txt"
run collect
check "19 collect: another Read under the transcripts directory is still contamination" \
  is "$(h field "$(rundir "$C" standards 1)/receipt.json" status)" contaminated

# Row 20
fresh r20
for cell in "$C" "$X" "$W" collect table; do
  for m in m1 m2 m3 m4 m5; do
    case "$cell" in
      collect | table) args=("$cell") ;;
      *) args=(run "$cell" r1/standards 1) ;;
    esac
    REVIEWER_FIXTURES="$tmp/$m" run "${args[@]}"
    check "20 $cell, fixture $m: exit 1" is "$code" 1
    check "20 $cell, fixture $m: a fixtures refusal" starts "$err" "reviewer: fixtures:"
  done
done

# Row 21
fresh r21
run table
check "21 table, nothing collected: exit 1" is "$code" 1
check "21 table, nothing collected: says so" has "$err" "no collected runs"
use r1x
run table
check "21 table: exit 0" is "$code" 0
check "21 table: writes scores.tsv" exists "$REVIEWER_OUT/scores.tsv"
check "21 table: writes table.md" exists "$REVIEWER_OUT/table.md"

# Row 22
fresh r22
FAKE_ERROR=usage-limit FAKE_STATUS=child-failed run run "$X" r1/standards 3
check "22 run codex: exit 0" is "$code" 0
check "22 run codex: a dropout receipt" is "$(h field "$(rundir "$X" standards 1)/receipt.json" status)" dropout
check "22 run codex: the detail names the usage limit" \
  starts "$(h field "$(rundir "$X" standards 1)/receipt.json" detail)" usage-limit
check "22 run codex: later k still attempted" lines "$(cat "$FAKE_CALLS")" 3
check "22 run codex: no report" absent "$(rundir "$X" standards 1)/report.md"
run collect
check "22 collect: counted collected until a later run removes it" has "$out" "collected 3 ·"
run run "$X" r1/spec 1
run table
check "22 table: excluded from scores" lacks "$(scores)" "$(row "$X" r1/standards)"
check "22 table: counted per model" is "$(cell "usage limit" "| $X | standards |")" 3
: > "$FAKE_CALLS"
run run "$X" r1/standards 1
check "22 run codex: the usage-limit run is prepared again" has "$out" "recall 1/1"
check "22 run codex: the runner is called once more" lines "$(cat "$FAKE_CALLS")" 1
check "22 run codex: the receipt is now complete" is "$(h field "$(rundir "$X" standards 1)/receipt.json" status)" complete

# Row 23
fresh r23
run run "$C" r1/standards 1
finish "$out" "$tmp/rep/hit.md" claude-opus-5 textnull
export REVIEWER_SETTLE_SECONDS=0
run run "$C" r1/standards 1
check "23 run claude: a settled text-only last line reads as finished" has "$out" "finished $(rundir "$C" standards 1)"
run collect
check "23 collect: it is collected" has "$out" "in flight 0"
check "23 collect: its receipt is complete" is "$(h field "$(rundir "$C" standards 1)/receipt.json" status)" complete
run table
check "23 table: a settled run is included in scores.tsv" has "$(scores)" "$(row "$C" r1/standards 1)"
check "23 table: and in the table" is "$(cell runs "| $C | standards |")" 1

fresh r23young
run run "$C" r1/standards 1
finish "$out" "$tmp/rep/hit.md" claude-opus-5 textnull
export REVIEWER_SETTLE_SECONDS=3600
run collect
check "23 collect: the same line before it settles stays in flight" has "$out" "in flight 1"
check "23 collect: no receipt" absent "$(rundir "$C" standards 1)/receipt.json"
run run "$X" r1/spec 1
run table
check "23 table: an unsettled run is excluded" lacks "$(scores)" "$C"

fresh r23tool
run run "$C" r1/standards 1
finish "$out" "$tmp/rep/hit.md" claude-opus-5 toolnull
export REVIEWER_SETTLE_SECONDS=0
run collect
check "23 collect: a last line holding a tool_use stays in flight" has "$out" "in flight 1"
check "23 collect: no receipt" absent "$(rundir "$C" standards 1)/receipt.json"
unset REVIEWER_SETTLE_SECONDS

# Row 24
fresh r24
FAKE_REPORT="$tmp/rep/fencedcount.md" run run "$X" r1/standards 1
check "24 run codex: a count line only inside a fence" has "$out" "$(rundir "$X" standards 1) context-failure no-count-line"
FAKE_REPORT="$tmp/rep/fencedheadings.md" run run "$X" r1/standards 2
check "24 run codex: a hard heading only inside a fence" has "$out" "$(rundir "$X" standards 2) context-failure no-hard-headings"
run table
check "24 table: both counted in the context failures column" is "$(cell "context failures" "| $X | standards |")" 2
check "24 table: the fenced count line scores no-count-line" has "$(scores)" "$(row "$X" r1/standards 1 no-count-line)"
check "24 table: the fenced heading scores no-hard-headings" has "$(scores)" "$(row "$X" r1/standards 2 no-hard-headings)"
fresh r24c
run run "$C" r1/standards 2
finish "$(sed -n 1p <<<"$out")" "$tmp/rep/fencedcount.md"
finish "$(sed -n 2p <<<"$out")" "$tmp/rep/fencedheadings.md"
run collect
check "24 collect: a count line only inside a fence" has "$out" "$(rundir "$C" standards 1) context-failure no-count-line"
check "24 collect: a hard heading only inside a fence" has "$out" "$(rundir "$C" standards 2) context-failure no-hard-headings"

pycheck() {
  local label=$1
  if python3 - "$script" "$2" <<'EOF'
import importlib.util, re, sys
spec = importlib.util.spec_from_file_location("reviewer", sys.argv[1])
r = importlib.util.module_from_spec(spec)
sys.modules["reviewer"] = r
spec.loader.exec_module(r)
B = r.BriefId("r1", "standards")
RUN = r.RunId("codex:gpt-6-astra", B, 1)

def L(i, *anchors):
    return r.Label(B, i, "fixed", tuple(re.compile(a) for a in anchors))

def report(hard=(), soft=(), count=None):
    n, out = 0, ["## Would break", ""]
    for t in hard:
        n += 1
        out += [f"{n}. {t}", ""]
    out += ["## Fails open", "", "## Standards breaches", ""]
    for t in soft:
        n += 1
        out += [f"{n}. {t}", ""]
    out.append(f"hard findings: {len(hard) if count is None else count}")
    return "\n".join(out) + "\n"

exec(sys.argv[2])
EOF
  then
    n=$((n + 1))
    echo "ok $n $label"
  else
    echo "FAIL $label"
    exit 1
  fi
}

pycheck "rule: one item claims one label, the one with more anchors" '
labels = (L("S1", "glob", "exits"), L("S2", "glob", "exits", "unmatched"))
s = r.score(RUN, r.parse_report(report(["An unmatched glob; the gate exits 0."])), labels)
assert s.hits == frozenset({"S2"}) and s.unlabeled == 0, s'
pycheck "rule: a numbered line inside a fence is not an item" '
items = r.parse_report(report(["An unmatched glob is dropped. The gate exits 0 anyway.\n\n~~~\n6. A quoted criterion.\n~~~"]))
assert [(i.n, i.hard) for i in items] == [(1, True)], items
assert "6. a quoted criterion." in items[0].text, items[0].text
s = r.score(RUN, items, (L("S1", "unmatched glob", "exits? 0"),))
assert s.hits == frozenset({"S1"}) and s.unlabeled == 0, s'
pycheck "rule: a heading inside a fence does not change the heading" '
items = r.parse_report(report(["An unmatched glob exits 0.\n\n~~~\n## Standards breaches\n~~~", "A missing ticket line."]))
assert [(i.n, i.hard) for i in items] == [(1, True), (2, True)], items'
pycheck "rule: the pr94-r1 standards report parses to the items its headings number" '
import pathlib
text = (pathlib.Path(sys.argv[1]).parent / "rounds/pr94-r1/review/standards-report.historical.md").read_text()
items = r.parse_report(text)
assert [(i.n, i.hard) for i in items] == [(1, True), (2, False), (3, False), (4, False), (5, False)], items
s = r.score(RUN, items, (L("S1", "body-file", "drops what to build"),))
assert s.hits == frozenset({"S1"}) and s.unlabeled == 0, s'
pycheck "rule: ## Walk steps are not items and claim no label" '
text = "## Walk\n\n1. An unmatched glob exits 0.\n2. A second step.\n\n## Would break\n\n1. A missing ticket line.\n\n## Fails open\n\nhard findings: 1\n"
items = r.parse_report(text)
assert [(i.n, i.hard) for i in items] == [(1, True)], items
s = r.score(RUN, items, (L("S1", "unmatched glob", "exits? 0"),))
assert s.hits == frozenset() and s.demoted == frozenset() and s.unlabeled == 1, s'
pycheck "rule: a label matched only outside the hard headings is demoted" '
s = r.score(RUN, r.parse_report(report(soft=["An unmatched glob; the gate exits 0."])), (L("S1", "unmatched glob", "exits? 0"),))
assert s.hits == frozenset() and s.demoted == frozenset({"S1"}) and s.unlabeled == 0, s'
pycheck "rule: a second item on a claimed label is a duplicate, not unlabeled" '
text = report(["An unmatched glob exits 0.", "Another unmatched glob, it exits 0 too.", "A missing ticket line."])
s = r.score(RUN, r.parse_report(text), (L("S1", "unmatched glob", "exits? 0"),))
assert s.hits == frozenset({"S1"}) and s.unlabeled == 1, s'
pycheck "rule: a context failure on a labeled brief misses its labels and leaves the unlabeled mean" '
lab = (L("S1", "unmatched glob", "exits? 0"),)
f = r.score(RUN, r.parse_report(report(["An unmatched glob exits 0."]).replace("hard findings: 1\n", "")), lab)
assert f.failure == "no-count-line" and f.hits == frozenset() and f.labels == 1, f
good = r.score(r.RunId(RUN.descriptor, B, 2), r.parse_report(report(["An unmatched glob exits 0.", "A missing ticket line.", "A stale path."])), lab)
row = next(l for l in r.render_table([f, good], []).splitlines() if l.startswith("| codex:gpt-6-astra | standards |"))
cells = [c.strip() for c in row.strip("|").split("|")]
assert cells[3] == "1" and cells[4] == "1/2 (0.50)" and cells[10] == "2.00", cells'
use r1x
receipt="$(rundir "$X" standards 1)/receipt.json"
check "rule: Codex input is input minus cached" is "$(h field "$receipt" tokens.input)/$(h field "$receipt" tokens.cache_read)" 400/600
use r6c
receipt="$(rundir "$C" standards 1)/receipt.json"
check "rule: Claude usage is counted once per requestId" is "$(h field "$receipt" tokens.input)/$(h field "$receipt" tokens.cache_read)/$(h field "$receipt" tokens.cache_write)/$(h field "$receipt" tokens.output)" 13/300/5/27
check "rule: Claude wall clock is the last timestamp minus the first" is "$(h field "$receipt" wall_ms)" 6000
pycheck "rule: the noise band is the best model's replicate spread" '
def sc(d, k, hits, labels):
    return r.Score(r.RunId(d, B, k), None, frozenset(f"S{i}" for i in range(hits)), frozenset(), 0, labels)
bands = r.noise([sc("a", 1, 2, 2), sc("a", 2, 1, 2), sc("a", 3, 2, 2), sc("b", 1, 3, 5), sc("c", 1, 2, 5)], "standards")
assert bands["a"][1] == 0.5 and bands["a"][2] == 1.0, bands
assert r.within(bands) == frozenset({"a", "b"}), bands'
pycheck "rule: a replicate short of a labeled brief is out of the band and still in the recall" '
B2 = r.BriefId("r2", "standards")
def sc(k, brief, hits, labels):
    return r.Score(r.RunId("a", brief, k), None, frozenset(f"S{i}" for i in range(hits)), frozenset(), 0, labels)
scores = [sc(1, B, 1, 2), sc(1, B2, 1, 2), sc(2, B, 2, 2), sc(2, B2, 1, 2),
          sc(3, B, 1, 2), sc(3, B2, 2, 2), sc(4, B, 0, 2)]
bands = r.noise(scores, "standards")
assert (bands["a"][1], bands["a"][2]) == (0.5, 0.75), bands
assert bands["a"][3] == r.statistics.pstdev([0.5, 0.75, 0.75]), bands
assert bands["a"][0] == 8 / 14, bands'
run check
check "rule: calibration passes on the matching item" is "$code:$out" "0:ok r1/standards S1"
REVIEWER_FIXTURES="$tmp/fx-badcal" run check
check "rule: calibration refuses a label claimed by another item" is "$code" 1
check "rule: calibration names the mismatch" has "$out" "mismatch r1/standards S1"
run check --list
check "rule: check --list prints the brief ids" is "$out" "r1/standards
r1/spec"

echo "all $n checks passed"
