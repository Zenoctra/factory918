#!/usr/bin/env bash
# Asserts tests/eval/reviewer/reviewer.py, rebuild.sh and fixes.sh against ticket #138. It builds a
# temporary repository whose base commit carries this tree's spec-review skill (the round's
# script_at), a reviewed head and two fix commits on top, a one-round fixture set `r1` briefed by
# rebuild.sh with two fix patches built by fixes.sh (the second applies only after the first), and
# hand-written subagent transcripts, and points every REVIEWER_* knob at them. Exits 1 on the first
# miss.
# shellcheck disable=SC2016 # the single-quoted strings are sed programs and Python; the backticks and $ are literal
set -euo pipefail
here="$(cd "$(dirname "$0")/../../.." && pwd -P)"
script="$here/tests/eval/reviewer/reviewer.py"
rebuild="$here/tests/eval/reviewer/rebuild.sh"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

C=claude:opus-5
F=claude:fable-5.1
g() { git -C "$tmp/repo" -c user.name=t -c user.email=t@example.com "$@"; }

git init -q -b main "$tmp/repo"
mkdir -p "$tmp/repo/template/.agents/skills"
cp -R "$here/template/.agents/skills/spec-review" "$tmp/repo/template/.agents/skills/"
printf 'one\ntwo\nthree\n' > "$tmp/repo/a.txt"
g add -A
g commit -q -m base
base="$(g rev-parse HEAD)"
printf 'one\nTWO\nthree\n' > "$tmp/repo/a.txt"
g commit -q -am "Change the second line (#7)"
head="$(g rev-parse HEAD)"
printf 'one\nTWO fixed\nthree\n' > "$tmp/repo/a.txt"
g commit -q -am "Fix the second line"
fix1="$(g rev-parse HEAD)"
printf 'one\nTWO fixed twice\nthree\n' > "$tmp/repo/a.txt"
g commit -q -am "Fix the second line again"
fix2="$(g rev-parse HEAD)"

fx="$tmp/fx"
mkdir -p "$fx/rounds/r1/inputs" "$fx/rounds/r1/review" "$fx/agents" "$tmp/agents" "$tmp/rep"
printf 'pr=1\nhead=%s\n' "$head" > "$fx/rounds/r1/round"
printf 'script_at=%s\nfixed_point=%s\nticket=7\nround=1\npr=1\n' "$base" "${base:0:7}" > "$fx/rounds/r1/inputs/recipe"
printf '## What to build\n\nChange the second line.\n' > "$fx/rounds/r1/inputs/ticket.md"
: > "$fx/rounds/r1/inputs/previous.txt"
{
  printf '# round\tid\tanchors\tfix\twhere\tsources\ttitle\n'
  printf 'r1\tG1\tunmatched glob && exits? 0\tf1.patch\ta.txt:2\tprobe\tAn unmatched glob is dropped\n'
  printf 'r1\tG2\tmissing ticket && refus\tf1.patch,f2.patch\ta.txt:2\tprobe\tA missing ticket is refused silently\n'
} > "$fx/truth"
{
  printf '# round\tpatch\tgit\tpaths\n'
  printf 'r1\tf1.patch\tshow %s\ta.txt\n' "$fix1"
  printf 'r1\tf2.patch\tdiff %s %s\ta.txt\n' "$fix1" "$fix2"
} > "$fx/fixes"
REBUILD_FIXTURES="$fx" REBUILD_REPO="$tmp/repo" bash "$here/tests/eval/reviewer/fixes.sh" --write > /dev/null
for a in review-lower-high review-upper-high review-fable-high; do
  printf -- '---\nname: %s\neffort: high\n---\n' "$a" > "$fx/agents/$a.md"
  cp "$fx/agents/$a.md" "$tmp/agents/$a.md"
done
REBUILD_FIXTURES="$fx" REBUILD_REPO="$tmp/repo" bash "$rebuild" r1 --write > /dev/null
reldir="$(sed -n 's/^Write your report to `\(.*\)\/standards-report.md`.*/\1/p' "$fx/rounds/r1/review/standards-brief.md")"

cat > "$tmp/rep/hit.md" <<'EOF'
## Would break

1. **An unmatched glob is dropped.** The gate exits 0 anyway.
Documented step: the gate.

## Fails open

## Standards breaches

2. **A missing ticket is refused.** Nothing says so.

## Fix alongside

hard findings: 1
EOF
cat > "$tmp/rep/both.md" <<'EOF'
## Would break

1. **A missing ticket is refused.** Nothing says so.

## Fails open

2. **A stale path.** It proceeds.

## Standards breaches

hard findings: 2
EOF
cat > "$tmp/rep/none.md" <<'EOF'
## Would break

## Fails open

hard findings: 0
EOF
grep -v '^hard findings' "$tmp/rep/hit.md" > "$tmp/rep/nocount.md"

cat > "$tmp/h.py" <<'EOF'
import json, os, re, shutil, sys

cmd, *args = sys.argv[1:]
if cmd in ("get", "field"):
    value = json.loads(args[0]) if cmd == "get" else json.load(open(args[0]))
    for key in args[1].split("."):
        value = value[int(key)] if isinstance(value, list) else value[key]
    print(value if isinstance(value, str) else json.dumps(value))
elif cmd == "checkout":
    print(re.search(r"You are working in `([^`]*)`", json.loads(args[0])["prompt"]).group(1))
elif cmd == "finish":
    line, report, model, state, reach, root, name, effort = args
    prompt = json.loads(line)["prompt"]
    brief = re.match(r"Read `([^`]*)`", prompt).group(1)
    if report != "none":
        shutil.copyfile(report, brief.replace("-brief.md", "-report.md"))
    tool, sep, target = reach.partition("|")
    if not sep:
        tool, target = "Read", reach or brief
    tool_input = ({"file_path": target} if tool in ("Read", "Write", "Edit") else
                  {"command": target} if tool == "Bash" else {"path": target} if target else {})

    def at(s):
        return f"2026-09-23T10:00:0{s}.000Z"

    def usage(i, r, c, o):
        return {"input_tokens": i, "cache_read_input_tokens": r, "cache_creation_input_tokens": c, "output_tokens": o}

    lines = [
        {"type": "user", "message": {"role": "user", "content": prompt}, "timestamp": at(0)},
        {"type": "assistant", "requestId": "r1", "timestamp": at(1), "effort": effort, "message": {
            "model": model, "stop_reason": "tool_use", "usage": usage(10, 100, 5, 20),
            "content": [{"type": "tool_use", "name": tool, "input": tool_input}]}},
        {"type": "user", "message": {"role": "user", "content": [{"type": "tool_result", "content": "ok"}]}, "timestamp": at(2)},
    ]
    def synthetic(text, **extra):
        return {"type": "assistant", "timestamp": at(3), **extra, "message": {
            "model": "<synthetic>", "stop_reason": "stop_sequence", "content": [{"type": "text", "text": text}]}}

    if state == "usage":
        lines.append(synthetic("You've hit your usage limit · resets 3am", error="rate_limit", isApiErrorMessage=True))
    elif state == "session":
        lines.append(synthetic("You've hit your session limit · resets 1:40pm (America/Chicago)"))
    elif state == "late":
        lines.append(synthetic("API Error: 500 Internal server error", isApiErrorMessage=True))
    elif state == "dead":
        lines = [lines[0], synthetic("API Error: 500 Internal server error. " + "x" * 200, isApiErrorMessage=True)]
    elif state in ("finished", "textnull"):
        done = {"type": "assistant", "requestId": "r2", "timestamp": at(5), "effort": effort, "message": {
            "model": model, "stop_reason": "end_turn" if state == "finished" else None,
            "usage": usage(3, 200, 0, 7), "content": [{"type": "text", "text": "done"}]}}
        lines += [done, done, {"type": "attachment", "timestamp": at(6)}]
    path = os.path.join(root, "s", "subagents", f"agent-{name}.jsonl")
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w") as f:
        f.writelines(json.dumps(x) + "\n" for x in lines)
    print(path)
EOF

export REVIEWER_REPO="$tmp/repo" REVIEWER_FIXTURES="$fx" REVIEWER_WORK="$tmp/w" REVIEWER_AGENTS="$tmp/agents"

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
same() { cmp -s "$1" "$2"; }
h() { python3 "$tmp/h.py" "$@"; }
use() { export REVIEWER_OUT="$tmp/out/$1" REVIEWER_TRANSCRIPTS="$tmp/tr/$1"; }
fresh() {
  use "$1"
  mkdir -p "$REVIEWER_TRANSCRIPTS"
}
rundir() { echo "$REVIEWER_OUT/runs/${1//:/-}/r1/$2/$3"; }
t=0
transcript=""
# finish <launch line> <report> [model] [state] [tool|target] [effort]
finish() {
  t=$((t + 1))
  transcript="$(h finish "$1" "$2" "${3:-claude-opus-5}" "${4:-finished}" "${5:-}" "$REVIEWER_TRANSCRIPTS" "$t" "${6:-high}")"
}
line_for() { grep -F "/$1/$2\"" <<<"$out" || true; }
cell() {
  awk -F'|' -v c="$1" -v arm="$2" -v p="$3" '
    /^\| arm/ { for (i = 2; i < NF; i++) { h = $i; gsub(/^ +| +$/, "", h); if (h == c) k = i } }
    $2 == " " arm " " && $3 == " " p " " { v = $k; gsub(/ /, "", v); print v }' "$REVIEWER_OUT/table.md"
}

# rebuild.sh
REBUILD_FIXTURES="$fx" REBUILD_REPO="$tmp/repo" bash "$rebuild" r1 > "$tmp/rb" 2>&1 && code=0 || code=$?
out="$(cat "$tmp/rb")"
check "rebuild: the written briefs rebuild identical" is "$code:$out" "0:rebuild: r1: identical"
REBUILD_FIXTURES="$fx" REBUILD_REPO="$tmp/repo" bash "$rebuild" r1 --export "$tmp/ex" f1.patch f2.patch > "$tmp/rb"
folded="$(cat "$tmp/rb")"
check "rebuild --export: the fix commits are folded into the head" is "$(cat "$tmp/ex/a.txt")" "one
TWO fixed twice
three"
check "rebuild --export: the commit list keeps the head's one line" is "$(sed -n '/^## Commits$/,/^## Changed files$/p' "$tmp/ex/$reldir/standards-brief.md" | grep -c 'Change the second line')" 1
check "rebuild --export: no fix subject reaches the brief" lacks "$(cat "$tmp/ex/$reldir/standards-brief.md")" "Fix the second line"
check "rebuild --export: prints a new commit" test "$folded" != "$head"
set +e
REBUILD_FIXTURES="$fx" REBUILD_REPO="$tmp/repo" bash "$rebuild" r1 --export "$tmp/ex2" f2.patch > /dev/null 2> "$tmp/rb"
code=$?
set -e
check "rebuild --export: a fix that does not apply alone exits 3" is "$code" 3
check "rebuild --export: and names round and patch" has "$(cat "$tmp/rb")" "r1: the patches f2.patch do not apply"

# fixes.sh
REBUILD_FIXTURES="$fx" REBUILD_REPO="$tmp/repo" bash "$here/tests/eval/reviewer/fixes.sh" > "$tmp/rb" 2>&1 && code=0 || code=$?
check "fixes.sh: the written patches rebuild identical" is "$code:$(grep -c identical "$tmp/rb")" 0:2
cp -R "$fx" "$tmp/fx-nocommit"
printf 'r1\tf3.patch\tshow 1111111111111111111111111111111111111111\ta.txt\n' >> "$tmp/fx-nocommit/fixes"
REBUILD_FIXTURES="$tmp/fx-nocommit" REBUILD_REPO="$tmp/repo" bash "$here/tests/eval/reviewer/fixes.sh" > "$tmp/rb" 2>&1 && code=0 || code=$?
check "fixes.sh: a commit not in the repository exits 2" is "$code" 2
check "fixes.sh: naming it and the fetch" is "$(tail -1 "$tmp/rb")" "fixes: r1 f3.patch: commit 1111111111111111111111111111111111111111 is not in this repository; git fetch origin 'refs/keep/103/*:refs/keep/103/*'"

# check
fresh check
run check
check "check: exit 0" is "$code" 0
check "check: the three agents" lines "$(grep '^ok agent' <<<"$out")" 3
check "check: the truth" has "$out" "ok truth r1: 2 bugs, 2 with a fix"
check "check: the patches rebuild" has "$out" "ok patches: 2 rebuild identical from their commits"
check "check: f1 alone briefs" has "$out" "ok masked r1: f1.patch"
check "check: f1 and f2 brief" has "$out" "ok masked r1: f1.patch f2.patch"
cp -R "$fx" "$tmp/fx-conflict"
awk -F'\t' -v OFS='\t' '$2 == "G2" { $4 = "f2.patch" } 1' "$fx/truth" > "$tmp/fx-conflict/truth"
REVIEWER_FIXTURES="$tmp/fx-conflict" run check
check "check: a subset that does not apply refuses" is "$code" 1
check "check: naming the round and the patches" has "$err" "round r1: the patches f2.patch do not apply"
check "check: and prints the conflict line" has "$out" "conflict r1: f2.patch"
cp -R "$fx" "$tmp/fx-tampered"
echo ' ' >> "$tmp/fx-tampered/rounds/r1/fixes/f1.patch"
REVIEWER_FIXTURES="$tmp/fx-tampered" run check
check "check: a patch that no longer matches its commits refuses" has "$err" "fixes.sh: fixes: r1 f1.patch differs from its commits"
cp -R "$tmp/agents" "$tmp/agents-drift"
echo drift >> "$tmp/agents-drift/review-upper-high.md"
REVIEWER_AGENTS="$tmp/agents-drift" run check
check "check: an installed agent that differs refuses" is "$code" 1
check "check: naming it" has "$err" "agents-drift/review-upper-high.md differs"
rm "$tmp/agents-drift/review-upper-high.md"
REVIEWER_AGENTS="$tmp/agents-drift" run check
check "check: a missing installed agent refuses" has "$err" "agents-drift/review-upper-high.md is missing"
cp -R "$fx" "$tmp/fx-gone"
printf 'pr=1\nhead=%s\n' 1111111111111111111111111111111111111111 > "$tmp/fx-gone/rounds/r1/round"
REVIEWER_FIXTURES="$tmp/fx-gone" run check
check "check: a head not in the objects refuses with the keep refs" has "$err" "git fetch origin 'refs/keep/103/*:refs/keep/103/*'"
REVIEWER_FIXTURES="$tmp/fx-gone" run next "$C"
check "next: a head not in the objects refuses the same way" has "$err" "'refs/keep/103/*:refs/keep/103/*'"

# The truth loader refuses a malformed row with its file and line.
i=0
for row in $'r1\tG3\tglob && exits\t-\t?\tx' \
           $'r9\tG3\tglob && exits\t-\t?\tx\tt' \
           $'r1\tS3\tglob && exits\t-\t?\tx\tt' \
           $'r1\tG1\tglob && exits\t-\t?\tx\tt' \
           $'r1\tG3\tglob\t-\t?\tx\tt' \
           $'r1\tG3\t(glob && exits\t-\t?\tx\tt' \
           $'r1\tG3\tglob && exits\tHEAD\t?\tx\tt' \
           $'r1\tG3\tglob && exits\t-\t?\tx\t ' \
           $'r1\tG3\tglob && exits\tnope.patch\t?\tx\tt'; do
  i=$((i + 1))
  cp -R "$fx" "$tmp/fx-bad$i"
  printf '%s\n' "$row" >> "$tmp/fx-bad$i/truth"
  REVIEWER_FIXTURES="$tmp/fx-bad$i" run check
  check "truth: malformed row $i refuses" is "$code" 1
  check "truth: malformed row $i names truth:4" starts "$err" "reviewer: fixtures: truth:4:"
done

# The run matrix.
fresh m
run next "$C" "$F"
check "next: exit 0" is "$code" 0
check "next: pass 1 only, both axes, both models" lines "$out" 4
check "next: the model order holds" starts "$(sed -n 1p <<<"$out")" "{\"run\": \"$(rundir "$C" standards 1)\""
l1="$(sed -n 1p <<<"$out")"
l2="$(sed -n 2p <<<"$out")"
lf="$(sed -n 3p <<<"$out")"
co1="$(h checkout "$l1")"
check "next: the lower tier agent" is "$(h get "$l1" agent.subagent_type)" review-lower-high
check "next: Fable through model fable" is "$(h get "$lf" agent.subagent_type)/$(h get "$lf" agent.model)" review-fable-high/fable
check "next: the prompt" is "$(h get "$l1" prompt)" "Read \`$co1/$reldir/standards-brief.md\` whole and follow it. You are working in \`$co1\`; every relative path in the brief is relative to it."
check "next: the checkout holds the head" is "$(sed -n 2p "$co1/a.txt")" TWO
check "next: the brief unchanged" same "$co1/$reldir/standards-brief.md" "$fx/rounds/r1/review/standards-brief.md"
check "next: the diff" exists "$co1/$reldir/diff"
check "next: not the other axis's brief" absent "$co1/$reldir/spec-brief.md"
check "next: no .git" absent "$co1/.git"
run next "$C" "$F"
check "next: prepared runs with no transcript are printed again" lines "$out" 4
check "next: the same line" is "$(sed -n 1p <<<"$out")" "$l1"
run collect
check "collect: four unlaunched" has "$out" "unlaunched 4"
finish "$l1" "$tmp/rep/hit.md"
finish "$l2" "$tmp/rep/both.md"
run next "$C"
check "next: nothing while pass 1 is in flight" is "$code:$out" "0:"
run collect
check "collect: two collected" has "$out" "collected 2 ·"
check "collect: the truth hit" has "$out" "$(rundir "$C" standards 1) truth G1 other 0 demoted 1"
run next "$C" --limit 4
check "next --limit 4: four pass-2 lines" lines "$out" 4
check "next --limit 4: pass 2 only" lacks "$out" "3\""
run next "$C"
check "next: the four prepared again, then the other two" lines "$out" 6
std_s2="$(line_for standards S2)"
std_m2="$(line_for standards M2)"
std_i2="$(line_for standards I2)"
spec_m2="$(line_for spec M2)"
spec_s2="$(line_for spec S2)"
co_s2="$(h checkout "$std_s2")"
co_m2="$(h checkout "$std_m2")"
co_i2="$(h checkout "$std_i2")"
co_spec_m2="$(h checkout "$spec_m2")"
check "I2: the brief unchanged" same "$co_i2/$reldir/standards-brief.md" "$fx/rounds/r1/review/standards-brief.md"
settled="$(sed -n '/^## Settled in earlier rounds$/,/^## Standards$/p' "$co_s2/$reldir/standards-brief.md")"
check "S2: the settled section before ## Standards" is "$settled" "## Settled in earlier rounds

These findings were raised in an earlier round and settled by the decision each one cites. Do not raise them again. Nothing in this section says what you should find or confirm.

1. [S1] **An unmatched glob is dropped.** The gate exits 0 anyway. Documented step: the gate.

## Standards"
check "S2: the non-hard item is not settled" lacks "$settled" "missing ticket"
check "S2: run.json records the settled line" is "$(h field "$(rundir "$C" standards S2)/run.json" settled.0)" "1. [S1] **An unmatched glob is dropped.** The gate exits 0 anyway. Documented step: the gate."
check "S2 spec: every hard item of pass 1, in order, numbered with its P id" is "$(grep -E '^[0-9]+\. \[P[0-9]+\] ' <<<"$(sed -n '/^## Settled in earlier rounds$/,/^## The ticket/p' "$(h checkout "$spec_s2")/$reldir/spec-brief.md")" | cut -c1-8 | tr '\n' '|')" "1. [P1] |2. [P2] |"
check "M2: G1's fix is applied" is "$(sed -n 2p "$co_m2/a.txt")" "TWO fixed"
check "M2: run.json applied" is "$(h field "$(rundir "$C" standards M2)/run.json" applied)" '["f1.patch"]'
check "M2: G1 masked, G2 not (its fix is not all applied)" is "$(h field "$(rundir "$C" standards M2)/run.json" masked)" '["G1"]'
check "M2: the tree is the folded commit" test "$(h field "$(rundir "$C" standards M2)/run.json" tree)" != "$head"
check "M2: the brief briefs the folded tree" has "$(cat "$co_m2/$reldir/standards-brief.md")" "TWO fixed"
check "M2: not the other axis's brief" absent "$co_m2/$reldir/spec-brief.md"
check "M2 spec: G2 found, both patches applied" is "$(h field "$(rundir "$C" spec M2)/run.json" applied)" '["f1.patch", "f2.patch"]'
check "M2 spec: G1 and G2 masked" is "$(h field "$(rundir "$C" spec M2)/run.json" masked)" '["G1", "G2"]'
check "M2 spec: the tree holds both fixes" is "$(sed -n 2p "$co_spec_m2/a.txt")" "TWO fixed twice"
finish "$std_m2" "$tmp/rep/both.md"
finish "$std_s2" "$tmp/rep/none.md"
finish "$std_i2" "$tmp/rep/hit.md"
run collect
run next "$C"
check "next: the three standards pass-3 steps follow their pass 2" is "$(grep -c '/standards/[ISM]3"' <<<"$out")" 3
co_m3="$(h checkout "$(line_for standards M3)")"
check "M3: G1 from pass 1 and G2 from M2, both patches" is "$(h field "$(rundir "$C" standards M3)/run.json" applied)" '["f1.patch", "f2.patch"]'
check "M3: the tree holds both fixes" is "$(sed -n 2p "$co_m3/a.txt")" "TWO fixed twice"
check "S3: nothing hard in S2, so pass 1's line alone" is "$(sed -n '/^## Settled in earlier rounds$/,/^## Standards$/p' "$(h checkout "$(line_for standards S3)")/$reldir/standards-brief.md" | grep -cE '^[0-9]+\. \[S[0-9]+\] ')" 1
run table
check "table: exit 0" is "$code" 0
check "table: one table for the model" has "$out" "## $C"
check "table: I2 found nothing new" is "$(cell "new truth bugs" I 2)" 0.00
check "table: M2 found G2, new" is "$(cell "new truth bugs" M 2)" 1.00
check "table: M2 cumulative" is "$(cell cumulative M 2)" 2.00
check "table: pass 1 demoted G2 on one of two briefs" is "$(cell demoted I 1)" 0.50
check "table: M2's other hard item" is "$(cell "other hard items" M 2)" 1.00
check "table: chains" is "$(cell chains S 2)" 1
check "table: scores.tsv carries the hit ids" has "$(cat "$REVIEWER_OUT/scores.tsv")" "$(printf '%s\tr1/standards\tM2\t\tG2\tG1\t' "$C")"

# Receipts.
fresh fx-effort
run next "$C" --limit 1
finish "$out" "$tmp/rep/hit.md" claude-opus-5 finished "" medium
run collect
check "effort: a medium transcript refuses" is "$code" 1
check "effort: names the run and the effort" has "$err" "$C r1/standards step 1 ran at effort medium"
check "effort: says the fix" has "$err" "set \`effort: high\` in the agent definition"
check "effort: nothing collected" absent "$(rundir "$C" standards 1)/receipt.json"
fresh fx-model
run next "$C" --limit 1
finish "$out" "$tmp/rep/hit.md" claude-opus-5-5
run collect
check "model: a wrong served model refuses" has "$err" "was served claude-opus-5-5"
fresh stopped
run next "$C" --limit 2
finish "$(sed -n 1p <<<"$out")" "$tmp/rep/nocount.md"
finish "$(sed -n 2p <<<"$out")" "$tmp/rep/hit.md"
run collect
run next "$C"
check "stopped: a pass 1 whose report fails to parse stops its chain" starts "$out" "stopped $(rundir "$C" standards 1): no-count-line"
check "stopped: none of the steps that need it is prepared" lacks "$(grep '^{' <<<"$out" || true)" "/standards/"
check "stopped: the other axis goes on" has "$out" "/spec/S2\""
run table
check "stopped: the table's chains count shows it" is "$(cell chains S 1):$(cell "context failures" S 1)" "2:1"

fresh refused-one
run next "$C" --limit 2
finish "$(sed -n 1p <<<"$out")" "$tmp/rep/hit.md" claude-opus-5-5
finish "$(sed -n 2p <<<"$out")" "$tmp/rep/hit.md"
run collect
check "collect: one run's refusal still exits 1" is "$code" 1
check "collect: the other finished run is collected first" is "$(h field "$(rundir "$C" spec 1)/receipt.json" status)" complete
check "collect: the refused run has no receipt" absent "$(rundir "$C" standards 1)/receipt.json"
fresh dead
run next "$C" --limit 1
for attempt in 1 2 3; do
  finish "$out" none claude-opus-5 dead
  REVIEWER_SETTLE_SECONDS=0 run collect
  [ "$attempt" != 1 ] || check "no response: a lane with no served model is a dropout" is "$(h field "$(rundir "$C" standards 1)/receipt.json" status)" dropout
  [ "$attempt" != 1 ] || check "no response: named with the text it left" is "$(h field "$(rundir "$C" standards 1)/receipt.json" detail)" "no-response: API Error: 500 Internal server error. $(printf 'x%.0s' $(seq 82))"
  run next "$C" --limit 1
  [ "$attempt" = 3 ] || check "no response: attempt $attempt is prepared again" is "$(h get "$out" run)" "$(rundir "$C" standards 1)"
done
check "no response: the third is given up" starts "$out" "given up $(rundir "$C" standards 1): failed 3 times"
finish "$(grep '^{' <<<"$out")" "$tmp/rep/hit.md"
run collect
run table
check "no response: counted in the table" is "$(cell "no response" I 1)" 3
check "no response: not as a usage limit" is "$(cell "usage limit" I 1)" 0

fresh late
run next "$C" --limit 1
finish "$out" none claude-opus-5 late
REVIEWER_SETTLE_SECONDS=3600 run collect
check "settle: a young <synthetic> last line stays in flight" has "$out" "in flight 1"
REVIEWER_SETTLE_SECONDS=0 run collect
check "no response: a lane that answered once and then died is a dropout" is "$(h field "$(rundir "$C" standards 1)/receipt.json" detail)" "no-response: API Error: 500 Internal server error"
run next "$C" --limit 1
check "no response: it is prepared again, not stopped" is "$(h get "$out" run)" "$(rundir "$C" standards 1)"

fresh fx-fable
run next "$F" --limit 1
finish "$out" "$tmp/rep/hit.md" claude-fable-5-1
run collect
check "model: Fable 5.1 is collected" is "$(h field "$(rundir "$F" standards 1)/receipt.json" status)" complete
check "receipt: the effort" is "$(h field "$(rundir "$F" standards 1)/receipt.json" effort)" high
check "receipt: usage counted once per requestId" is "$(h field "$(rundir "$F" standards 1)/receipt.json" tokens.output)" 27
check "receipt: wall clock" is "$(h field "$(rundir "$F" standards 1)/receipt.json" wall_ms)" 6000

fresh usage
run next "$F" --limit 1
first="$out"
finish "$first" none claude-fable-5-1 usage
REVIEWER_SETTLE_SECONDS=0 run collect
check "usage limit: a dropout receipt" is "$(h field "$(rundir "$F" standards 1)/receipt.json" status)" dropout
check "usage limit: named" starts "$(h field "$(rundir "$F" standards 1)/receipt.json" detail)" usage-limit
fresh session
run next "$F" --limit 1
finish "$out" none claude-fable-5-1 session
REVIEWER_SETTLE_SECONDS=0 run collect
check "session limit: the real wording, a synthetic line, is a usage-limit dropout" starts "$(h field "$(rundir "$F" standards 1)/receipt.json" detail)" usage-limit
run next "$F"
check "session limit: the model is paused" starts "$out" "paused $F: usage limit at "
use usage
run next "$C" "$F" --limit 1
check "usage limit: the model is paused" starts "$out" "paused $F: usage limit at "
check "usage limit: the pause says how to resume" has "$out" "after the reset run: python3 tests/eval/reviewer/reviewer.py next --resume $F"
check "usage limit: the other model goes on" has "$out" "\"run\": \"$(rundir "$C" standards 1)\""
check "usage limit: nothing prepared for the paused model" lacks "$out" "${F//:/-}"
check "usage limit: the receipt stays until resumed" is "$(h field "$(rundir "$F" standards 1)/receipt.json" status)" dropout
run next "$F" --limit 1
check "usage limit: still paused without --resume" is "$(grep -c '^paused' <<<"$out"):$(grep -c '^{' <<<"$out" || true)" 1:0
run next --resume "$F" --limit 1
check "usage limit: --resume prepares the limited run again" is "$(h get "$out" run)" "$(rundir "$F" standards 1)"
check "usage limit: with a new checkout" test "$(h checkout "$out")" != "$(h checkout "$first")"
check "usage limit: the receipt is kept aside" exists "$REVIEWER_OUT/dropped/${F//:/-}/r1/standards/1/1/receipt.json"
finish "$out" "$tmp/rep/hit.md" claude-fable-5-1
run collect
run table
check "usage limit: counted in the table" is "$(cell "usage limit" I 1)" 1
check "usage limit: out of the metrics" is "$(cell chains I 1)" 1

fresh contaminated
run next "$C" --limit 1
co="$(h checkout "$out")"
finish "$out" "$tmp/rep/hit.md" claude-opus-5 finished "Bash|cd $co && gh issue view 7"
run collect
check "contamination: cd <export> && gh is contaminated" is "$(h field "$(rundir "$C" standards 1)/receipt.json" status)" contaminated
check "contamination: the detail says gh" has "$(h field "$(rundir "$C" standards 1)/receipt.json" detail)" "runs gh"
run next "$C" --limit 1
check "contamination: prepared again" is "$(h get "$out" run)" "$(rundir "$C" standards 1)"
check "contamination: the receipt is kept aside" exists "$REVIEWER_OUT/dropped/${C//:/-}/r1/standards/1/1/receipt.json"
fresh giveup
run next "$C" --limit 1
for attempt in 1 2 3; do
  co="$(h checkout "$out")"
  finish "$out" "$tmp/rep/hit.md" claude-opus-5 finished "Bash|cd $co && gh issue view 7"
  run collect
  run next "$C" --limit 1
  [ "$attempt" = 3 ] || check "give up: contamination $attempt is prepared again" is "$(h get "$out" run)" "$(rundir "$C" standards 1)"
done
check "give up: the third contamination is given up" starts "$out" "given up $(rundir "$C" standards 1): contaminated 3 times"
check "give up: the given-up run is not prepared again" lacks "$out" "\"run\": \"$(rundir "$C" standards 1)\""
check "give up: the next run goes on" has "$out" "\"run\": \"$(rundir "$C" spec 1)\""
finish "$(grep '^{' <<<"$out")" "$tmp/rep/hit.md"
run collect
check "give up: the other axis is collected" is "$(h field "$(rundir "$C" spec 1)/receipt.json" status)" complete
run next "$C"
check "give up: no step that needs it is prepared" lacks "$(grep '^{' <<<"$out" || true)" "/standards/"
check "give up: the other axis goes on to pass 2" has "$out" "/spec/I2\""
run table
check "give up: the table counts all three contaminations" is "$(cell contaminated I 1)" 3

fresh contaminated-read
run next "$C" --limit 1
finish "$out" "$tmp/rep/hit.md" claude-opus-5 finished /etc/hosts
run collect
check "contamination: a Read outside the export" has "$(h field "$(rundir "$C" standards 1)/receipt.json" detail)" "Read /etc/hosts"
fresh overflow
run next "$C" --limit 1
finish "$out" "$tmp/rep/hit.md" claude-opus-5 finished "Read|$REVIEWER_TRANSCRIPTS/s/tool-results/b0gweyh98.txt"
run collect
check "contamination: a Read of the harness's own overflow is not" is "$(h field "$(rundir "$C" standards 1)/receipt.json" status)" complete
fresh unchecked
run next "$C" --limit 1
finish "$out" "$tmp/rep/hit.md" claude-opus-5 finished "WebFetch|https://example.com"
run collect
check "contamination: a tool outside the checked six is contaminated" is "$(h field "$(rundir "$C" standards 1)/receipt.json" status)" contaminated
check "contamination: named as unchecked" is "$(h field "$(rundir "$C" standards 1)/receipt.json" detail)" "WebFetch (unchecked tool)"
for tool in Skill Agent WebSearch; do
  fresh "unchecked-$tool"
  run next "$C" --limit 1
  finish "$out" "$tmp/rep/hit.md" claude-opus-5 finished "$tool|x"
  run collect
  check "contamination: $tool is unchecked" is "$(h field "$(rundir "$C" standards 1)/receipt.json" detail)" "$tool (unchecked tool)"
done
for tool in TodoWrite ToolSearch; do
  fresh "passes-$tool"
  run next "$C" --limit 1
  finish "$out" "$tmp/rep/hit.md" claude-opus-5 finished "$tool|x"
  run collect
  check "contamination: $tool reads nothing and passes" is "$(h field "$(rundir "$C" standards 1)/receipt.json" status)" complete
done

fresh foreign
old="$(rundir "$C" standards 1)"
mkdir -p "$old"
printf '{"version": 1, "run": {"descriptor": "%s", "round": "r1", "axis": "standards", "k": 1}, "status": "complete", "detail": "complete", "reported_model": "claude-opus-5", "model_verified": true, "effort": "medium", "tokens": null, "wall_ms": 1, "source": "x"}\n' "$C" > "$old/receipt.json"
run collect
check "foreign: collect lists a #103 receipt as stuck" has "$out" "stuck $old"
check "foreign: and does not count it collected" has "$out" "collected 0 ·"
run next "$C"
check "foreign: next refuses" is "$code" 1
check "foreign: saying what to do" is "$err" "reviewer: $old: a receipt from another measurement (version 1); set REVIEWER_OUT to a fresh directory or move it aside"
run table
check "foreign: table refuses the same way" has "$err" "$old: a receipt from another measurement (version 1)"
rm "$old/receipt.json"
printf '{"run": {"descriptor": "%s", "round": "r1", "axis": "standards", "k": 1}, "nonce": "n", "checkout": "/x", "prompt": "p"}\n' "$C" > "$old/run.json"
run collect
check "foreign: a #103 run.json is stuck too" has "$out" "stuck $old"
run next "$C"
check "foreign: next refuses a #103 run.json" has "$err" "$old: a run.json from another measurement (version None)"
default_out="$(env -u REVIEWER_OUT python3 -c 'import importlib.util, sys
spec = importlib.util.spec_from_file_location("reviewer", sys.argv[1])
r = importlib.util.module_from_spec(spec)
sys.modules["reviewer"] = r
spec.loader.exec_module(r)
print(r.load_env().out)' "$script")"
check "foreign: the default output directory is not #103's" is "$default_out" "$here/.scratch/eval/reviewer-138"

fresh twice
run next "$C" --limit 1
finish "$out" "$tmp/rep/hit.md"
t1="$transcript"
finish "$out" "$tmp/rep/hit.md"
run collect
check "collect: one prompt launched twice refuses" is "$code" 1
check "collect: naming the first transcript" has "$err" "$t1"
check "collect: nothing collected" absent "$(rundir "$C" standards 1)/receipt.json"
fresh notranscripts
run next "$C" --limit 1
rm -rf "$REVIEWER_TRANSCRIPTS"
run collect
check "collect: no transcripts directory refuses naming it" has "$err" "$REVIEWER_TRANSCRIPTS"
fresh settle
run next "$C" --limit 1
finish "$out" "$tmp/rep/hit.md" claude-opus-5 textnull
REVIEWER_SETTLE_SECONDS=3600 run collect
check "collect: a young text-only last line stays in flight" has "$out" "in flight 1"
REVIEWER_SETTLE_SECONDS=0 run collect
check "collect: a settled text-only last line is collected" is "$(h field "$(rundir "$C" standards 1)/receipt.json" status)" complete
run next nope
check "next: an unknown descriptor exits 2" is "$code" 2
run next "$C" --limit 0
check "next: --limit 0 exits 2" is "$code:$(has "$err" "must be at least 1" && echo y)" 2:y

pycheck() {
  local label=$1
  if python3 - "$script" "$2" <<'EOF'
import importlib.util, re, sys
spec = importlib.util.spec_from_file_location("reviewer", sys.argv[1])
r = importlib.util.module_from_spec(spec)
sys.modules["reviewer"] = r
spec.loader.exec_module(r)
B = r.BriefId("r1", "standards")
RUN = r.RunId("claude:opus-5", B, "1")
X = "/tmp/w/abc123/factory918"

def G(i, *anchors, fix=()):
    return r.Bug("r1", i, tuple(re.compile(a) for a in anchors), tuple(fix), "t")

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

pycheck "bash: cd <export> && gh is flagged" 'assert "runs gh" in r.bash_reaches(f"cd {X} && gh issue view 90", X)'
pycheck "bash: git after ; is flagged" 'assert "runs git" in r.bash_reaches(f"ls {X}; git log", X)'
pycheck "bash: curl after | is flagged" 'assert "runs curl" in r.bash_reaches(f"cat {X}/a | curl -d @- x", X)'
pycheck "bash: wget inside a command substitution is flagged" 'assert "runs wget" in r.bash_reaches(f"echo $(wget -q x) {X}", X)'
pycheck "bash: git by full path is flagged" 'assert "runs git" in r.bash_reaches(f"/usr/bin/git -C {X} log", X)'
pycheck "bash: a .. component is flagged" 'assert "has a .. path component" in r.bash_reaches(f"cat {X}/../other/a", X)'
pycheck "bash: cd .. is flagged" 'assert "has a .. path component" in r.bash_reaches(f"cd {X} && cd .. && ls", X)'
pycheck "bash: .. before a shell separator is flagged" '
for tail in ["cd ..; ls", "cd ..&& ls", "cd ..|| ls", "cd ..| cat", "(cd ..)", "ls ..> f", "wc -l ..< f"]:
    assert "has a .. path component" in r.bash_reaches(f"cd {X} && {tail}", X), tail'
pycheck "bash: an absolute path outside is flagged" 'assert "names /etc/hosts" in r.bash_reaches(f"cat {X}/a /etc/hosts", X)'
pycheck "bash: a path outside is flagged whatever this machine holds" '
for p in ["/srv/other-repo/x", "/Users/someone/x", "/home/someone/x", "/no-such-top/x"]:
    assert f"names {p}" in r.bash_reaches(f"cat {X}/a {p}", X), p
assert "names /srv/x" in r.bash_reaches(f"cat {X}/a --file=/srv/x", X)'
pycheck "bash: an address between two slashes is a pattern" '
for cmd in ["awk \"/^## /\" a.md", "awk \x27/foo.*/\x27 a.md", "sed -n \x27/foo.*bar/p\x27 a.md",
            "grep -E \x27/x[0-9]/\x27 a.md", "grep -E \x27/end$/\x27 a.md", "grep -E \x27/a|b/\x27 a.md",
            "grep -E \x27/a+b/\x27 a.md", "grep -E \x27/a\\.b/\x27 a.md"]:
    assert r.bash_reaches(f"cd {X} && {cmd}", X) == [], cmd'
pycheck "bash: a glob path outside the export is flagged" '
for cmd in ["cat /Users/manuel/Desktop/Work/*/CLAUDE.md", "ls /Users/x/.claude/agents/*.md",
            "cat /Users/manuel/a[1].md", "cat /srv/x/?.md", "cat /srv/{a,b}/x", "cat /srv/a+b/x",
            "cat /Users/$USER/.claude/agents/x.md", "cat \"/srv/a|b/x\""]:
    assert any(w.startswith("names /") for w in r.bash_reaches(f"cd {X} && {cmd}", X)), cmd'
pycheck "bash: a path from the HOME variable is flagged" '
for p in ["$HOME/.claude/agents/x.md", "${HOME}/.claude/CLAUDE.md"]:
    assert f"names {p}" in r.bash_reaches(f"cd {X} && cat {p}", X), p'
pycheck "bash: a ~ path is flagged" 'assert "names ~/.ssh/config" in r.bash_reaches(f"cat {X}/a ~/.ssh/config", X)'
pycheck "bash: a sibling export is flagged" '
why = r.bash_reaches(f"cd {X} && cat /tmp/w/def456/factory918/a.txt", X)
assert "names /tmp/w/def456/factory918/a.txt" in why, why'
pycheck "bash: a path that only starts like the export is flagged" 'assert r.bash_reaches(f"cat {X}-other/a", X)'
pycheck "bash: a command without the export is flagged" 'assert "does not name the export" in r.bash_reaches("ls", X)'
pycheck "bash: grep inside the export with 2>/dev/null is clean" 'assert r.bash_reaches(f"cd {X} && grep -rn foo . 2>/dev/null | head", X) == []'
pycheck "bash: /usr/bin/python3 as the command word is clean" 'assert r.bash_reaches(f"/usr/bin/python3 {X}/x.py", X) == []'
pycheck "bash: /usr/bin as an argument is flagged" 'assert r.bash_reaches(f"ls {X} /usr/bin", X)'
pycheck "bash: an awk pattern is not a path" 'assert r.bash_reaches(f"awk \"/^## /\" {X}/a.md", X) == []'
pycheck "bash: an env assignment before gh is still gh" 'assert "runs gh" in r.bash_reaches(f"cd {X} && GH_PAGER= gh pr view", X)'
pycheck "bash: a command behind a shell keyword is still seen" '
for cmd, word in [("if true; then gh issue view 90; fi", "gh"), ("for f in a b; do git log $f; done", "git"),
                  ("{ curl -s https://x.com; }", "curl"), ("! gh issue view 90", "gh"),
                  ("while read l; do gh api $l; done < f", "gh"), ("until false; do wget x; done", "wget"),
                  ("if false; then :; elif true; then git log; else gh pr view; fi", "git")]:
    assert f"runs {word}" in r.bash_reaches(f"cd {X} && {cmd}", X), cmd'

pycheck "rule: one item claims one bug, the one with more anchors" '
bugs = (G("G1", "glob", "exits"), G("G2", "glob", "exits", "unmatched"))
s = r.score(RUN, r.parse_report(report(["An unmatched glob; the gate exits 0."])), bugs)
assert s.hits == frozenset({"G2"}) and s.other == 0, s'
pycheck "rule: a numbered line inside a fence is not an item" '
items = r.parse_report(report(["An unmatched glob is dropped. The gate exits 0 anyway.\n\n~~~\n6. A quoted criterion.\n~~~"]))
assert [(i.n, i.hard) for i in items] == [(1, True)], items
assert "6. a quoted criterion." in items[0].text, items[0].text'
pycheck "rule: a heading inside a fence does not change the heading" '
items = r.parse_report(report(["An unmatched glob exits 0.\n\n~~~\n## Standards breaches\n~~~", "A missing ticket line."]))
assert [(i.n, i.hard) for i in items] == [(1, True), (2, True)], items'
pycheck "rule: a count line or hard heading only inside a fence is a context failure" '
assert r.parse_report("## Would break\n\n1. x\n\n~~~\nhard findings: 1\n~~~\n") == "no-count-line"
assert r.parse_report("## Standards breaches\n\n~~~\n## Would break\n~~~\n\nhard findings: 0\n") == "no-hard-headings"
assert r.parse_report(report(["x"], count=2)) == "count-exceeds-items"
assert r.parse_report(None) == "no-report"'
pycheck "rule: ## Walk steps are not items" '
items = r.parse_report("## Walk\n\n1. An unmatched glob exits 0.\n\n## Would break\n\n1. A missing ticket line.\n\n## Fails open\n\nhard findings: 1\n")
assert [(i.n, i.hard) for i in items] == [(1, True)], items'
pycheck "rule: a bug matched only outside the hard headings is demoted" '
s = r.score(RUN, r.parse_report(report(soft=["An unmatched glob; the gate exits 0."])), (G("G1", "unmatched glob", "exits? 0"),))
assert s.hits == frozenset() and s.demoted == frozenset({"G1"}) and s.other == 0, s'
pycheck "rule: a second item on a claimed bug is not other" '
s = r.score(RUN, r.parse_report(report(["An unmatched glob exits 0.", "Another unmatched glob, it exits 0 too.", "A missing ticket line."])), (G("G1", "unmatched glob", "exits? 0"),))
assert s.hits == frozenset({"G1"}) and s.other == 1, s'
pycheck "rule: an item's raw text is its lines outside fences, on one line" '
items = r.parse_report(report(["**Title.** body\nDocumented step: `x`.\n\n```\nq\n```"]))
assert items[0].raw == "**Title.** body Documented step: `x`.", items[0].raw'
pycheck "rule: masked bugs are those whose fix commits are all applied" '
bugs = (G("G1", "a", "b", fix=["c1"]), G("G2", "a", "b", fix=["c1", "c2"]), G("G3", "a", "b"), G("G4", "a", "b", fix=["c2"]))
assert r.fixes_for({"G1"}, bugs) == (("c1",), ("G1",))
assert r.fixes_for({"G2"}, bugs) == (("c1", "c2"), ("G1", "G2", "G4"))
assert r.fixes_for({"G3"}, bugs) == ((), ())
assert sorted(r.arising(bugs)) == [("c1",), ("c1", "c2"), ("c2",)], r.arising(bugs)'
pycheck "rule: the step table" '
assert r.chain("S") == ("1", "S2", "S3") and r.STEPS["M3"].needs == ("1", "M2") and r.STEPS["I2"].pass_ == 2
assert {s.arm for s in r.STEPS.values()} == {None, "I", "S", "M"}'
pycheck "rule: new bugs per pass leave out earlier passes and masked bugs" '
def S(step, hits, demoted=(), other=0):
    return r.Score(r.RunId("d", B, step), None, frozenset(hits), frozenset(demoted), other)
def R(step):
    return r.Receipt(r.RunId("d", B, step), "complete", "complete", "m", "high", r.Tokens(1, 10, 0, 100), 2000, None)
scores = {s.run: s for s in [S("1", {"G1"}), S("I2", {"G1", "G2"}), S("I3", {"G2"}), S("M2", {"G2"}, {"G1"}),
                               S("M3", {"G1", "G3"}, other=2), S("S2", set())]}
masked = {r.RunId("d", B, "M2"): frozenset({"G1"}), r.RunId("d", B, "M3"): frozenset({"G1", "G2"})}
rows = {(x.arm, x.pass_): x for x in r.rows_for("d", scores, {k: R(k.step) for k in scores}, masked, [])}
assert rows[("I", 2)].new == 1 and rows[("I", 3)].new == 0 and rows[("I", 3)].cumulative == 2
assert rows[("M", 2)].new == 1 and rows[("M", 2)].demoted == 0
assert rows[("M", 3)].new == 1 and rows[("M", 3)].cumulative == 3 and rows[("M", 3)].other == 2
assert rows[("S", 2)].new == 0 and rows[("S", 3)].chains == 0 and rows[("S", 3)].new is None
assert rows[("I", 1)].output == 100 and rows[("I", 1)].wall_s == 2'
pycheck "rule: a bug an earlier pass of the chain hard-found is not demoted" '
def S(step, hits, demoted=()):
    return r.Score(r.RunId("d", B, step), None, frozenset(hits), frozenset(demoted), 0)
def R(step):
    return r.Receipt(r.RunId("d", B, step), "complete", "complete", "m", "high", None, None, None)
scores = {s.run: s for s in [S("1", {"G1"}), S("S2", set(), {"G1", "G2"})]}
rows = {(x.arm, x.pass_): x for x in r.rows_for("d", scores, {k: R(k.step) for k in scores}, {}, [])}
assert rows[("S", 2)].demoted == 1, rows[("S", 2)]'
pycheck "rule: the prompt refuses a banned word in the work path" '
from pathlib import Path, PurePosixPath
brief = r.Brief(B, "0" * 40, Path("."), PurePosixPath(".scratch/review/x/standards-report.md"))
try:
    r.plan(RUN, brief, Path("/tmp/eval-work"))
    raise SystemExit(1)
except r.Refusal as e:
    assert "eval" in str(e)'

# The settled section sits where review-brief.sh puts its own: brief the head twice, once with one
# settled item from a previous comment, and insert the same line into the first.
git clone -q "$tmp/repo" "$tmp/pos"
git -C "$tmp/pos" checkout -q --detach "$head"
mkdir -p "$tmp/bin"
cat > "$tmp/bin/gh" <<'STUB'
#!/usr/bin/env bash
case "$*" in
  "issue view 7 --json body -q .body") printf '## What to build\n\nChange the second line.\n' ;;
  "issue view 7 --json author,comments -q "*) : ;;
  *) exit 1 ;;
esac
STUB
chmod +x "$tmp/bin/gh"
item='1. [S1] **Hook in Python.** A port is a later ticket. cites: DECISIONS.md P17'
printf '## Judgment\n\n## Noted\n\n%s\n\nround: 1 of 3\nact-on items: 0\n' "$item" > "$tmp/prev.md"
: > "$tmp/empty.md"
bs="$here/template/.agents/skills/spec-review/scripts/review-brief.sh"
(cd "$tmp/pos" && PATH="$tmp/bin:$PATH" bash "$bs" "${base:0:7}" --ticket 7 --previous "$tmp/empty.md" --round 1 > /dev/null)
cp "$tmp/pos/$reldir/standards-brief.md" "$tmp/plain-standards.md"
cp "$tmp/pos/$reldir/spec-brief.md" "$tmp/plain-spec.md"
(cd "$tmp/pos" && PATH="$tmp/bin:$PATH" bash "$bs" "${base:0:7}" --ticket 7 --previous "$tmp/prev.md" --round 2 > /dev/null)
for axis in standards spec; do
  pycheck "settle: the $axis section lands where the script prints it" "
from pathlib import Path
got = r.settle(Path('$tmp/plain-$axis.md').read_text(), '$axis', ['$item'])
want = Path('$tmp/pos/$reldir/$axis-brief.md').read_text()
assert '## Settled in earlier rounds' in want
assert got == want"
done
pycheck "settle: no lines leaves the brief as it is" 'assert r.settle("x\n## Standards\n", "standards", []) == "x\n## Standards\n"'

echo "all $n checks passed"
