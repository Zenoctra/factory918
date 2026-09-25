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
# The content check reads only commits made after the head, so each commit gets its own hour.
at() { GIT_COMMITTER_DATE="2026-01-01T0$1:00:00Z" GIT_AUTHOR_DATE="2026-01-01T0$1:00:00Z" g "${@:2}"; }
later_line="A line only the second fix commit holds"
head_line="A line the reviewed head already holds"
read_rule='You may open any file in the repository and run read-only commands, such as grep or the test suite.'

git init -q -b main "$tmp/repo"
mkdir -p "$tmp/repo/template/.agents/skills"
cp -R "$here/template/.agents/skills/spec-review" "$tmp/repo/template/.agents/skills/"
printf 'one\ntwo\nthree\n' > "$tmp/repo/a.txt"
printf '%s\n' "$head_line" > "$tmp/repo/base.md"
g add -A
at 1 commit -q -m base
base="$(g rev-parse HEAD)"
printf 'one\nTWO\nthree\n' > "$tmp/repo/a.txt"
at 2 commit -q -am "Change the second line (#7)"
head="$(g rev-parse HEAD)"
printf 'one\nTWO fixed in the first commit\nthree\n' > "$tmp/repo/a.txt"
at 3 commit -q -am "Fix the second line"
fix1="$(g rev-parse HEAD)"
printf 'one\nTWO fixed again in the second commit\nthree\n' > "$tmp/repo/a.txt"
ticket_line="A ticket line a later commit also copies"
printf '%s\n' "$later_line" "tiny line" "$head_line" "$read_rule" "$ticket_line" > "$tmp/repo/later.md"
g add later.md
at 4 commit -q -am "Fix the second line again"
fix2="$(g rev-parse HEAD)"
g update-ref refs/keep/103/fix2 "$fix2"

fx="$tmp/fx"
mkdir -p "$fx/rounds/r1/inputs" "$fx/rounds/r1/review" "$fx/agents" "$tmp/agents" "$tmp/rep"
printf 'pr=1\nhead=%s\n' "$head" > "$fx/rounds/r1/round"
printf 'script_at=%s\nfixed_point=%s\nticket=7\nround=1\npr=1\n' "$base" "${base:0:7}" > "$fx/rounds/r1/inputs/recipe"
printf '## What to build\n\nChange the second line.\n\n%s\n' "$ticket_line" > "$fx/rounds/r1/inputs/ticket.md"
printf '## Risks\n\nThe grounding the author wrote.\n' > "$fx/rounds/r1/inputs/blast-radius.md"
: > "$fx/rounds/r1/inputs/previous.txt"
{
  printf '# round\tid\tclass\tanchors\tfix\twhere\tsources\ttitle\n'
  printf 'r1\tG1\thard\tunmatched glob && exits? 0\tf1.patch\ta.txt:2\tprobe\tAn unmatched glob is dropped\n'
  printf 'r1\tG2\tnonhard\tmissing ticket && refus\tf1.patch,f2.patch\ta.txt:2\tprobe\tA missing ticket is refused loudly\n'
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
cat > "$tmp/rep/quoted.md" <<'EOF'
## Would break

1. **A later line.** It is quoted.

```
A line only the second fix commit holds
```

2. **An unquoted line.** Nothing fenced.

## Fails open

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
            "content": [{"type": "tool_use", "id": "u1", "name": tool, "input": tool_input}]}},
        {"type": "user", "message": {"role": "user", "content": [{"type": "tool_result", "tool_use_id": "u1", "content": os.environ.get("RESULT", "ok")}]}, "timestamp": at(2)},
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
    elif state == "plain":
        lines.append(synthetic("x"))
        lines[-1]["message"]["content"] = "API Error: 500 Internal server error"
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

# A gh on PATH that serves ticket #7 and PR #1 as GitHub holds them "now", and nothing when GH_OFFLINE is set.
mkdir -p "$tmp/bin"
cat > "$tmp/bin/gh" <<'STUB'
#!/usr/bin/env bash
[ -z "${GH_OFFLINE:-}" ] || { echo "error connecting to api.github.com" >&2; exit 1; }
case "$*" in
  "issue view 7 --json body -q .body") printf '## What to build\n\nChange the second line.\n' ;;
  "issue view 7 --json author,comments -q "*) : ;;
  "issue view 7 --repo Zenoctra/factory918 --json body,comments")
    printf '%s\n' '{"body": "## What to build\n\nChange the second line.\n\nA line written on the ticket after the review", "comments": [{"body": "A comment posted on the ticket later"}]}' ;;
  "pr view 1 --repo Zenoctra/factory918 --json body,comments") printf '%s\n' '{"body": "The PR body as edited after the review", "comments": []}' ;;
  *) exit 1 ;;
esac
STUB
chmod +x "$tmp/bin/gh"
export PATH="$tmp/bin:$PATH"
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
# cell <column> <arm> <pass> [axis]: one cell of the axis's table (standards by default).
cell() {
  awk -F'|' -v c="$1" -v arm="$2" -v p="$3" -v axis=", ${4:-standards}" '
    /^## / { on = substr($0, length($0) - length(axis) + 1) == axis }
    on && /^\| arm/ { for (i = 2; i < NF; i++) { h = $i; gsub(/^ +| +$/, "", h); if (h == c) k = i } }
    on && $2 == " " arm " " && $3 == " " p " " { v = $k; gsub(/ /, "", v); print v }' "$REVIEWER_OUT/table.md"
}

# rebuild.sh
REBUILD_FIXTURES="$fx" REBUILD_REPO="$tmp/repo" bash "$rebuild" r1 > "$tmp/rb" 2>/dev/null && code=0 || code=$?
out="$(cat "$tmp/rb")"
check "rebuild: the written briefs rebuild identical" is "$code:$out" "0:rebuild: r1: identical"
REBUILD_FIXTURES="$fx" REBUILD_REPO="$tmp/repo" bash "$rebuild" r1 --export "$tmp/ex" f1.patch f2.patch > "$tmp/rb"
folded="$(cat "$tmp/rb")"
check "rebuild --export: the fix commits are folded into the head" is "$(cat "$tmp/ex/a.txt")" "one
TWO fixed again in the second commit
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
for bad in "bogus 1111111111111111111111111111111111111111|bogus 1111111111111111111111111111111111111111 is not show or diff" \
           "show 1111111111111111111111111111111111111111 2222222222222222222222222222222222222222|show takes one commit" \
           "diff 1111111111111111111111111111111111111111|diff takes two commits"; do
  cp -R "$fx" "$tmp/fx-badverb"
  printf 'r1\tf3.patch\t%s\ta.txt\n' "${bad%%|*}" >> "$tmp/fx-badverb/fixes"
  REBUILD_FIXTURES="$tmp/fx-badverb" REBUILD_REPO="$tmp/repo" bash "$here/tests/eval/reviewer/fixes.sh" > "$tmp/rb" 2>&1 && code=0 || code=$?
  check "fixes.sh: a malformed line is named for its verb or arity before its commits: ${bad#*|}" is "$code:$(tail -1 "$tmp/rb")" "2:fixes: r1 f3.patch: ${bad#*|}"
  rm -rf "$tmp/fx-badverb"
done

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
awk -F'\t' -v OFS='\t' '$2 == "G2" { $5 = "f2.patch" } 1' "$fx/truth" > "$tmp/fx-conflict/truth"
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
for row in $'r1\tG3\thard\tglob && exits\t-\t?\tx' \
           $'r9\tG3\thard\tglob && exits\t-\t?\tx\tt' \
           $'r1\tS3\thard\tglob && exits\t-\t?\tx\tt' \
           $'r1\tG1\thard\tglob && exits\t-\t?\tx\tt' \
           $'r1\tG3\tsoft\tglob && exits\t-\t?\tx\tt' \
           $'r1\tG3\thard\tglob\t-\t?\tx\tt' \
           $'r1\tG3\thard\t(glob && exits\t-\t?\tx\tt' \
           $'r1\tG3\thard\tglob && exits\tHEAD\t?\tx\tt' \
           $'r1\tG3\thard\tglob && exits\t-\t?\tx\t ' \
           $'r1\tG3\thard\tglob && exits\tnope.patch\t?\tx\tt'; do
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
check "next: the prompt" is "$(h get "$l1" prompt)" "Read \`$co1/$reldir/standards-brief.md\` whole and follow it. You are working in \`$co1\`; every relative path in the brief is relative to it. The ticket as it stood at this commit is \`$co1/$reldir/ticket.md\`, and the PR's grounding is \`$co1/$reldir/blast-radius.md\`. Your scratch folder for notes and any files you make is \`$co1/.scratch/work/\`."
check "next: the export holds the scratch folder" test -d "$co1/.scratch/work"
check "next: the export holds the frozen ticket, byte for byte" cmp -s "$co1/$reldir/ticket.md" "$fx/rounds/r1/inputs/ticket.md"
check "next: and the frozen grounding" cmp -s "$co1/$reldir/blast-radius.md" "$fx/rounds/r1/inputs/blast-radius.md"
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
check "collect: G1 filed hard, G2 found under a non-hard heading" has "$out" "$(rundir "$C" standards 1) filed hard G1 found G1,G2 other 0"
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
check "M2: G1's fix is applied" is "$(sed -n 2p "$co_m2/a.txt")" "TWO fixed in the first commit"
check "M2: run.json applied" is "$(h field "$(rundir "$C" standards M2)/run.json" applied)" '["f1.patch"]'
check "M2: G1 masked, G2 not (its fix is not all applied)" is "$(h field "$(rundir "$C" standards M2)/run.json" masked)" '["G1"]'
check "M2: the tree is the folded commit" test "$(h field "$(rundir "$C" standards M2)/run.json" tree)" != "$head"
check "M2: the brief briefs the folded tree" has "$(cat "$co_m2/$reldir/standards-brief.md")" "TWO fixed in the first commit"
check "M2: not the other axis's brief" absent "$co_m2/$reldir/spec-brief.md"
check "M2: the masked export holds the scratch folder" test -d "$co_m2/.scratch/work"
check "M2: the masked export holds the frozen ticket" cmp -s "$co_m2/$reldir/ticket.md" "$fx/rounds/r1/inputs/ticket.md"
check "M2 spec: G2 found, both patches applied" is "$(h field "$(rundir "$C" spec M2)/run.json" applied)" '["f1.patch", "f2.patch"]'
check "M2 spec: G1 and G2 masked" is "$(h field "$(rundir "$C" spec M2)/run.json" masked)" '["G1", "G2"]'
check "M2 spec: the tree holds both fixes" is "$(sed -n 2p "$co_spec_m2/a.txt")" "TWO fixed again in the second commit"
finish "$std_m2" "$tmp/rep/both.md"
finish "$std_s2" "$tmp/rep/none.md"
finish "$std_i2" "$tmp/rep/hit.md"
run collect
run next "$C"
check "next: the three standards pass-3 steps follow their pass 2" is "$(grep -c '/standards/[ISM]3"' <<<"$out")" 3
co_m3="$(h checkout "$(line_for standards M3)")"
check "M3: G1 from pass 1 and G2 from M2, both patches" is "$(h field "$(rundir "$C" standards M3)/run.json" applied)" '["f1.patch", "f2.patch"]'
check "M3: the tree holds both fixes" is "$(sed -n 2p "$co_m3/a.txt")" "TWO fixed again in the second commit"
check "S3: nothing hard in S2, so pass 1's line alone" is "$(sed -n '/^## Settled in earlier rounds$/,/^## Standards$/p' "$(h checkout "$(line_for standards S3)")/$reldir/standards-brief.md" | grep -cE '^[0-9]+\. \[S[0-9]+\] ')" 1
run table
check "table: exit 0" is "$code" 0
check "table: one table per axis for the model" is "$(grep -c "^## $C, " <<<"$out")" 2
check "table: the key's classes" has "$out" "The key: r1 1 hard, 1 non-hard."
check "table: standards pass 1 filed hard G1" is "$(cell "hard bugs filed hard" I 1)" 1.00
check "table: and found non-hard G2 under a non-hard heading" is "$(cell "non-hard bugs found" I 1):$(cell "non-hard filed hard" I 1)" 1.00:0.00
check "table: pass 1 found both, new" is "$(cell "new found" I 1)" 2.00
check "table: I2 found nothing new" is "$(cell "new found" I 2)" 0.00
check "table: M2 filed G2 hard: over-rated over the chain" is "$(cell "non-hard filed hard" M 2)" 1.00
check "table: but found nothing new" is "$(cell "new found" M 2)" 0.00
check "table: M2 keeps pass 1's hard G1 though its tree masks it" is "$(cell "hard bugs filed hard" M 2)" 1.00
check "table: M2's other hard item" is "$(cell "other hard items" M 2)" 1.00
check "table: chains" is "$(cell chains S 2)" 1
check "table: spec pass 1 over-rated G2 and filed nothing hard" is "$(cell "non-hard filed hard" I 1 spec):$(cell "hard bugs filed hard" I 1 spec)" 1.00:0.00
check "table: the standards table leads with found at all" has "$out" "| arm | pass | chains | hard bugs found | hard bugs filed hard |"
check "table: the spec table leads with filed hard" has "$out" "| arm | pass | chains | hard bugs filed hard | hard bugs found |"
check "table: the standards footnote names #144" is "$(grep -c '(#144, ' <<<"$out")" 1
check "table: scores.tsv carries the filed and found ids" has "$(cat "$REVIEWER_OUT/scores.tsv")" "$(printf '%s\tr1/standards\tM2\t\tG2\tG2\tG1\t' "$C")"

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
check "stopped: the table's chains count shows it" is "$(cell chains S 1):$(cell "context failures" S 1)" "1:1"

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

fresh plain
run next "$C" --limit 1
finish "$out" none claude-opus-5 plain
REVIEWER_SETTLE_SECONDS=0 run collect
check "settle: a synthetic last line whose content is a plain string settles" is "$(h field "$(rundir "$C" standards 1)/receipt.json" detail)" "no-response: API Error: 500 Internal server error"

fresh late-drift
run next "$C" --limit 2
finish "$(sed -n 1p <<<"$out")" none claude-opus-5-5 late
finish "$(sed -n 2p <<<"$out")" none claude-opus-5 late "" medium
REVIEWER_SETTLE_SECONDS=0 run collect
check "drift: a lane that died after a wrong model is refused, not retried" has "$err" "$C r1/standards step 1 was served claude-opus-5-5"
check "drift: a lane that died after effort medium is refused, not retried" has "$err" "$C r1/spec step 1 ran at effort medium"
check "drift: the wrong model is not a dropout" absent "$(rundir "$C" standards 1)/receipt.json"
check "drift: effort medium is not a dropout" absent "$(rundir "$C" spec 1)/receipt.json"

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
RESULT="$later_line" finish "$out" "$tmp/rep/hit.md" claude-opus-5 finished "Bash|cat later.md"
run collect
check "content: a result line only a later commit holds is contamination" is "$(h field "$(rundir "$C" standards 1)/receipt.json" status)" contaminated
check "content: the detail names the tool call, the commit and the line" is "$(h field "$(rundir "$C" standards 1)/receipt.json" detail)" "Bash {\"command\": \"cat later.md\"} returned a line first added by ${fix2:0:7}: $later_line"
run next "$C" --limit 1
check "content: prepared again" is "$(h get "$out" run)" "$(rundir "$C" standards 1)"
check "content: the receipt is kept aside" exists "$REVIEWER_OUT/dropped/${C//:/-}/r1/standards/1/1/receipt.json"
i=0
for result in "     1→$later_line" "     1	$later_line" "later.md:1:$later_line" "later.md-1-$later_line" "1:$later_line"; do
  i=$((i + 1))
  fresh "prefix$i"
  run next "$C" --limit 1
  RESULT="$result" finish "$out" "$tmp/rep/hit.md" claude-opus-5 finished "Read|/elsewhere/later.md"
  run collect
  check "content: a tool's line prefix is stripped: $result" is "$(h field "$(rundir "$C" standards 1)/receipt.json" status)" contaminated
done
for case in "tiny line|a later line under the floor" "$head_line|a later line the head already holds" \
            "$read_rule|a later line the brief carries" "$ticket_line|a later line the exported ticket holds" "TWO fixed again in the second commit TWO|no line of the future, only part of one"; do
  fresh "clean-${case#*|}"
  run next "$C" --limit 1
  RESULT="${case%%|*}" finish "$out" "$tmp/rep/hit.md" claude-opus-5 finished "Bash|cat later.md"
  run collect
  check "content: ${case#*|} is not contamination" is "$(h field "$(rundir "$C" standards 1)/receipt.json" status)" complete
done
fresh giveup
run next "$C" --limit 1
for attempt in 1 2 3; do
  RESULT="$later_line" finish "$out" "$tmp/rep/hit.md" claude-opus-5 finished "Bash|cat later.md"
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
check "give up: the model's excluded runs" has "$(cat "$REVIEWER_OUT/table.md")" "Contaminated runs excluded from recall: 3."

for case in "A line written on the ticket after the review|live #7" "A comment posted on the ticket later|live #7" \
            "The PR body as edited after the review|live PR #1"; do
  fresh "live-${case#*|}"
  run next "$C" --limit 1
  RESULT="${case%%|*}" finish "$out" "$tmp/rep/hit.md" claude-opus-5 finished "Bash|gh issue view 7"
  run collect
  check "live: text GitHub holds now and the frozen inputs do not is contamination (${case#*|})" \
    is "$(h field "$(rundir "$C" standards 1)/receipt.json" detail)" "Bash {\"command\": \"gh issue view 7\"} returned a line first added by ${case#*|}: ${case%%|*}"
done
fresh live-frozen
run next "$C" --limit 1
RESULT="Change the second line." finish "$out" "$tmp/rep/hit.md" claude-opus-5 finished "Bash|gh issue view 7"
run collect
check "live: a ticket line the frozen inputs hold is not" is "$(h field "$(rundir "$C" standards 1)/receipt.json" status)" complete
GH_OFFLINE=1 run collect --recheck
check "live: with the text cached, the check runs offline" is "$code" 0
fresh live-offline
run next "$C" --limit 1
finish "$out" "$tmp/rep/hit.md"
GH_OFFLINE=1 run collect
check "live: no cache and no network refuses" is "$code" 1
check "live: naming the fetch" has "$err" "\`gh issue view 7 --repo Zenoctra/factory918 --json body,comments\` failed"
check "live: and collects nothing" absent "$(rundir "$C" standards 1)/receipt.json"

pad=/private/tmp/claude-501/-Users-x-proj/1111-2222/scratchpad
for case in "Read|$pad/notes.md|contaminated|a scratchpad file another run wrote" \
            "Bash|cat /tmp/claude-501/-Users-x-proj/1111-2222/scratchpad/notes.md|contaminated|the same file by its /tmp name, from Bash" \
            "Grep|$pad/rv89|contaminated|a search of another run's scratchpad folder" \
            "Read|$tmp/w/0123456789ab/factory918/a.txt|contaminated|another run's export" \
            "Bash|ls $pad|complete|the bare scratchpad folder, which names no file"; do
  IFS='|' read -r tool target want what <<<"$case"
  fresh "cross-${what// /-}"
  run next "$C" --limit 1
  finish "$out" "$tmp/rep/hit.md" claude-opus-5 finished "$tool|$target"
  run collect
  check "cross-run: $what is $want" is "$(h field "$(rundir "$C" standards 1)/receipt.json" status)" "$want"
  [ "$want" = complete ] || check "cross-run: named as a cross-run read ($what)" starts "$(h field "$(rundir "$C" standards 1)/receipt.json" detail)" "cross-run read at call 1: $tool "
done
fresh cross-own-work
run next "$C" --limit 1
co="$(h checkout "$out")"
finish "$out" "$tmp/rep/hit.md" claude-opus-5 finished "Read|$co/.scratch/work/notes.md"
run collect
check "cross-run: a read inside its own .scratch/work is clean" is "$(h field "$(rundir "$C" standards 1)/receipt.json" status)" complete

fresh record
run next "$C" --limit 1
RESULT="$later_line" finish "$out" "$tmp/rep/quoted.md" claude-opus-5 finished "Bash|cd /elsewhere/repo && cat later.md"
run collect
check "record: the first contaminated call's ordinal" is "$(h field "$(rundir "$C" standards 1)/receipt.json" first_contaminated.call)" 1
check "record: and its time" is "$(h field "$(rundir "$C" standards 1)/receipt.json" first_contaminated.timestamp)" "2026-09-23T10:00:02.000Z"
check "record: an item's quote first seen at call 1" is "$(h field "$(rundir "$C" standards 1)/receipt.json" sightings.0.call)" 1
check "record: an item that quotes nothing has no sighting" is "$(h field "$(rundir "$C" standards 1)/receipt.json" sightings.1.call)" null
check "record: a cd outside the export is recorded" is "$(h field "$(rundir "$C" standards 1)/receipt.json" outside)" '["1 Bash /elsewhere/repo"]'
fresh record-clean
run next "$C" --limit 1
finish "$out" "$tmp/rep/hit.md" claude-opus-5 finished "Read|/elsewhere/a.txt"
run collect
check "record: a Read outside the export is recorded" is "$(h field "$(rundir "$C" standards 1)/receipt.json" outside)" '["1 Read /elsewhere/a.txt"]'
check "record: but does not exclude the run" is "$(h field "$(rundir "$C" standards 1)/receipt.json" status)" complete
check "record: a clean run has no first contaminated call" is "$(h field "$(rundir "$C" standards 1)/receipt.json" first_contaminated)" null

fresh masked-given
run next "$C" --limit 2
finish "$(sed -n 1p <<<"$out")" "$tmp/rep/hit.md"
finish "$(sed -n 2p <<<"$out")" "$tmp/rep/none.md"
run collect
run next "$C" --limit 3
RESULT="TWO fixed in the first commit" finish "$(line_for standards M2)" "$tmp/rep/none.md"
RESULT="TWO fixed in the first commit" finish "$(line_for standards I2)" "$tmp/rep/none.md"
run collect
check "content: a fix line the masked tree was given is not contamination" is "$(h field "$(rundir "$C" standards M2)/receipt.json" status)" complete
check "content: the same line in an unmasked pass is" is "$(h field "$(rundir "$C" standards I2)/receipt.json" status)" contaminated
check "content: the masked pass kept its brief and diff" exists "$(rundir "$C" standards M2)/given/standards-brief.md"

for tool in Agent WebFetch WebSearch; do
  fresh "undated-$tool"
  run next "$C" --limit 1
  finish "$out" "$tmp/rep/hit.md" claude-opus-5 finished "$tool|x"
  run collect
  check "content: $tool, whose results cannot be dated, is contamination" starts "$(h field "$(rundir "$C" standards 1)/receipt.json" detail)" "$tool ("
done
for tool in Skill ToolSearch TodoWrite Read Grep; do
  fresh "dated-$tool"
  run next "$C" --limit 1
  finish "$out" "$tmp/rep/hit.md" claude-opus-5 finished "$tool|/anywhere/at/all"
  run collect
  check "content: $tool is judged by what it returned" is "$(h field "$(rundir "$C" standards 1)/receipt.json" status)" complete
done

fresh recheck
run next "$C" --limit 2
l1="$(sed -n 1p <<<"$out")"
l2="$(sed -n 2p <<<"$out")"
finish "$l1" "$tmp/rep/hit.md"
t1="$transcript"
finish "$l2" "$tmp/rep/hit.md"
run collect
RESULT="$later_line" finish "$l1" none claude-opus-5 finished "Bash|cat later.md"
mv "$transcript" "$t1"
python3 - "$(rundir "$C" spec 1)/receipt.json" <<'PY'
import json, sys
j = json.load(open(sys.argv[1]))
j.update(status="contaminated", detail="Bash (runs gh) cd x && gh issue view 7")
json.dump(j, open(sys.argv[1], "w"))
PY
run collect --recheck
check "recheck: a complete run whose transcript shows later code turns contaminated" is "$(h field "$(rundir "$C" standards 1)/receipt.json" status)" contaminated
check "recheck: and says so" has "$out" "recheck $(rundir "$C" standards 1): complete -> contaminated: Bash {\"command\": \"cat later.md\"} returned a line first added by ${fix2:0:7}"
check "recheck: a run the old rule flagged, clean now, with its report, is complete" is "$(h field "$(rundir "$C" spec 1)/receipt.json" status)" complete
check "recheck: and says so" has "$out" "recheck $(rundir "$C" spec 1): contaminated -> complete"
run collect --recheck
check "recheck: a second pass changes nothing" lacks "$out" "recheck "
run next "$C" --limit 1
check "recheck: next sets the contaminated run aside" exists "$REVIEWER_OUT/dropped/${C//:/-}/r1/standards/1/1/receipt.json"
mkdir -p "$REVIEWER_OUT/dropped/${C//:/-}/r1/spec/1"
mv "$(rundir "$C" spec 1)" "$REVIEWER_OUT/dropped/${C//:/-}/r1/spec/1/1"
python3 - "$REVIEWER_OUT/dropped/${C//:/-}/r1/spec/1/1/receipt.json" <<'PY'
import json, sys
j = json.load(open(sys.argv[1]))
j.update(status="contaminated", detail="Read /etc/hosts")
json.dump(j, open(sys.argv[1], "w"))
PY
run collect --recheck
check "recheck: a set-aside run clean now comes back when its place is free" is "$(h field "$(rundir "$C" spec 1)/receipt.json" status)" complete
check "recheck: and says where" has "$out" "back at $(rundir "$C" spec 1)"
mkdir -p "$REVIEWER_OUT/dropped/${C//:/-}/r1/spec/1"
mv "$(rundir "$C" spec 1)" "$REVIEWER_OUT/dropped/${C//:/-}/r1/spec/1/1"
python3 - "$REVIEWER_OUT/dropped/${C//:/-}/r1/spec/1/1/receipt.json" <<'PY'
import json, sys
j = json.load(open(sys.argv[1]))
j.update(status="contaminated", detail="Read /etc/hosts")
json.dump(j, open(sys.argv[1], "w"))
PY
rm "$REVIEWER_OUT/dropped/${C//:/-}/r1/spec/1/1/report.md"
run collect --recheck
check "recheck: one whose report is gone stays set aside" is "$(h field "$REVIEWER_OUT/dropped/${C//:/-}/r1/spec/1/1/receipt.json" status)" contaminated
check "recheck: and says why" has "$out" "clean now, but its report is gone; it stays set aside"

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

def G(i, *anchors, fix=(), hard=True):
    return r.Bug("r1", i, hard, tuple(re.compile(a) for a in anchors), tuple(fix), "t")

def mis(name, round_):
    import os
    from pathlib import Path
    text = Path(os.environ["MIS"], name + ".md").read_text() + "\n\n## Would break\n\nhard findings: 0\n"
    return r.score(RUN, r.parse_report(text), r.load_fixtures(Path(sys.argv[1]).parent).truth[round_])

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

# Four items the answer-key audit (2026-09-24) found credited to the wrong bug, verbatim from the #138
# reports; each is scored alone against this tree's truth.
export MIS="$tmp/mis"
mkdir -p "$MIS"
cat > "$MIS/opus-5-pr94-r1-spec-1-4.md" <<'EOF'
## Fails open

4. **A stateful design whose playbook skipped `architect` still produces no artifact, and nothing sends it back.** The posting rule hangs off the architect step. Feature step 2 still allows `architect skipped: <reason>` for any diff that is not cross-cutting, and Bug fix 3, Refactoring 3 and Perf issue 3 run `architect` only when the change crosses a function boundary. So a one-file change that writes a state file or adds an exit code reaches implementation with no table, no stop and no record — the failure this ticket opens with. The intent outranks the criteria, so the gap belongs back in design, not on the PR.

```
The ticket had no Testing decisions because it was planned as prose, and nothing sent it back for them when the design added state.
```

Documented step: `template/.agents/skills/poteto-mode/playbooks/feature.md:6` (`architect skipped: <reason>`), `bug-fix.md:9`, `perf-issue.md:16`, `refactoring.md:9` ("If the target crosses a function boundary")
Result: state ships with no design artifact and nothing refuses it; the reviewer has only the criteria to judge against, which is the pre-#89 state.
spec: criterion 3
EOF
cat > "$MIS/opus-5-pr96-r1-standards-1-1.md" <<'EOF'
## Fails open

1. **The zero-argument gate passes over 6 of the factory's 20 files.** `template/.github/shellcheck.sh:35` defaults to a project's layout. At the factory root those globs resolve through `.claude/hooks`, a symlink into `template/`, so the run finds the five hooks and the gate itself, matches nothing for `.agents/skills/*/scripts/*.sh` (the factory has no `.agents/` at its root) and exits 0. The refusal at `:39-42` fires only when *every* argument matches nothing, so one glob matching nothing beside one that matches is silent. The same silence covers a glob that goes stale: the five globs in `AGENTS.md:38` and `.github/workflows/factory-ci.yml:19` are the only record of the factory's set, and a layout move shrinks that set with CI still green. Cheapest hardening is to refuse when any one argument matches no file and name it: at the factory root that refusal points at `.agents/skills/*/scripts/*.sh` and sends the lane to the `AGENTS.md:38` command. It would also refuse a project whose hooks were all deleted (the 6-file case the fixture grounding names), which is the judgement to make.
Documented step: `template/.agents/skills/poteto-mode/playbooks/opening-a-pr.md:9`, "Run `bash .github/shellcheck.sh` on every shell file the diff changes before the PR opens; it is the gate CI runs" — the playbook this repository runs on itself (`AGENTS.md`, "The nesting rule"); `template/.github/shellcheck.sh:5` documents the zero-argument form as "this project's shell files" and `template/AGENTS.md:63` as "which is what CI runs". The standard breached is `CODING_STANDARDS.md:13`, "Test a command the way a user types it: absolute paths, from another directory, through the installed symlink".
Result: at the factory root `bash .github/shellcheck.sh` prints `ShellCheck 0.11.0, files checked: 6` and exits 0. A lane that runs the gate through the new root symlink the way the playbook writes it gets a green pass over the five hooks and the gate script, while the fourteen other files CI checks — `factory918.sh`, the five scripts under `template/.agents/skills/*/scripts/`, the eight under `tests/` — are never read.
spec: table zero-argument form/expected result (the `## Design` row `tests/shellcheck/gate.sh:5-6` names "the zero-argument form from a project's root" and asserts a project's count; no row covers the same command at the factory root).

```sh
# template/.github/shellcheck.sh:35-43
if [ "$#" = 0 ]; then set -- '.claude/hooks/*.sh' '.agents/skills/*/scripts/*.sh' '.github/shellcheck.sh'; fi
files=()
for g in "$@"; do
  for f in $g; do if [ -f "$f" ]; then files+=("$f"); fi; done
done
if [ "${#files[@]}" = 0 ]; then
  echo "shellcheck.sh: no file matched $*; the gate checked nothing" >&2
  exit 1
fi
```

```
$ bash .github/shellcheck.sh                 # at the factory root
ShellCheck 0.11.0, files checked: 6
EXIT=0
$ bash .github/shellcheck.sh factory918.sh template/.github/shellcheck.sh \
    'template/.claude/hooks/*.sh' 'template/.agents/skills/*/scripts/*.sh' 'tests/*/*.sh'
ShellCheck 0.11.0, files checked: 20
EXIT=0
```
EOF
cat > "$MIS/opus-5-pr99-r1-standards-1-1.md" <<'EOF'
## Would break

1. **The Standards brief carries no ticket, so no counted Standards item can satisfy the new spec rule.** `report()` is shared by both reports, so the spec check runs on `standards-report.md`, and all three forms name a part of the ticket. The Standards brief is `common` + the standards files + the smell baseline + the report rules; the ticket body reaches only the Spec brief. Breaches CODING_STANDARDS.md, Bash: "Every doctor check carries its fix as the third argument. A `FAIL` with no fix is a bug" — this reviewer cannot perform the fix the refusal names. It bit this review: I could not ground a cell, signature or criterion for this item.
Documented step: `template/.agents/skills/spec-review/SKILL.md:84`, "The same item carries a line `spec:` naming the artifact it rests on: `table <row>/<column>` for a cell of the ticket's scenario table, `design <signature>` ... or `criterion <k>` ..."; the brief's contents are `SKILL.md:86`.
Result: a real breach is dropped, or filed with an invented reference that `review-comment.sh` then validates word for word against the invention once it is marked `hole:`.
spec: design report <file> <heading>...

```sh
  line="$(stepless "$f" "^spec: $ref\$")"
  [ -z "$line" ] || fail "$f item '$(title "${line#*: }")' under '## ${line%%: *}' has no 'spec:' line; a counted item names what it rests on ... Ask the reviewer for it"
```
EOF
cat > "$MIS/fable-5.1-pr94-r1-standards-1-3.md" <<'EOF'
## Fix alongside

3. **Step order: the posting rule lives after the step that runs implementation.** Ticket step 5 says "run that playbook's steps verbatim from step 1", and Feature step 4 delegates with a brief that "carries the ticket's design artifact (Ticket step 6)"; a reader in step order reaches step 6 after step 5 has already delegated, and nothing checks that the brief carried an artifact. The runner prompt and P25 say "before implementation", so the intent is recoverable by cross-reference, not by reading down. A sentence in step 5 ("before the playbook's delegation step, do step 6") or moving the posting into the four playbooks' architect steps would close it. Judgement call; not filed hard because the Standards brief carries no ticket criteria to cite.
   ```
   +6. The spec's **Testing decisions** are the pre-agreed seams. ... The selected playbook's architect step adds the ticket's own: ... before implementation the synthesized table is appended to the ticket's body ...
   ```
EOF
pycheck 'anchors: opus-5 pr94-r1/spec/1#4, a skipped architect step, is G6, not the failed post G5' '
s = mis("opus-5-pr94-r1-spec-1-4", "pr94-r1")
assert s.hits == frozenset({"G6"}) and s.found == frozenset({"G6"}), s'
pycheck 'anchors: opus-5 pr96-r1/standards/1#1, the bare gate at the factory root, is G4, not G1' '
s = mis("opus-5-pr96-r1-standards-1-1", "pr96-r1")
assert s.hits == frozenset({"G4"}) and s.found == frozenset({"G4"}), s'
pycheck 'anchors: opus-5 pr99-r1/standards/1#1, a Standards brief with no ticket in it, is G4, not G2' '
s = mis("opus-5-pr99-r1-standards-1-1", "pr99-r1")
assert s.hits == frozenset({"G4"}) and s.found == frozenset({"G4"}), s'
pycheck 'anchors: fable-5.1 pr94-r1/standards/1#3, step order, is not G1: "close" is not "lose"' '
s = mis("fable-5.1-pr94-r1-standards-1-3", "pr94-r1")
assert s.hits == frozenset() and s.found == frozenset(), s'
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
pycheck "rule: a bug matched only outside the hard headings is found, not filed hard" '
s = r.score(RUN, r.parse_report(report(soft=["An unmatched glob; the gate exits 0."])), (G("G1", "unmatched glob", "exits? 0"),))
assert s.hits == frozenset() and s.found == frozenset({"G1"}) and s.other == 0, s'
pycheck "rule: a hard item claims a bug before a non-hard one, and a non-hard item claims one bug too" '
bugs = (G("G1", "glob", "exits"), G("G2", "glob", "exits", "unmatched", hard=False))
s = r.score(RUN, r.parse_report(report(["A glob; the gate exits 0."], ["An unmatched glob; the gate exits 0."])), bugs)
assert s.hits == frozenset({"G1"}) and s.found == frozenset({"G1", "G2"}), s
s = r.score(RUN, r.parse_report(report(soft=["An unmatched glob; the gate exits 0.", "A glob; the gate exits 0."])), bugs)
assert s.hits == frozenset() and s.found == frozenset({"G1", "G2"}), s
s = r.score(RUN, r.parse_report(report(["A glob; the gate exits 0."], ["Another glob; the gate exits 0."])), bugs[:1])
assert s.hits == frozenset({"G1"}) and s.found == frozenset({"G1"}), s'
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
pycheck "rule: the chain counts, by class, leave out masked bugs; new found leaves out earlier passes" '
truth = {"r1": (G("G1", "a", "b"), G("G2", "a", "b"), G("G3", "a", "b", hard=False))}
def S(step, hits, found=(), other=0):
    return r.Score(r.RunId("d", B, step), None, frozenset(hits), frozenset(hits) | frozenset(found), other)
def R(step):
    return r.Receipt(r.RunId("d", B, step), "complete", "complete", "m", "high", r.Tokens(1, 10, 0, 100), 2000, None)
scores = {s.run: s for s in [S("1", {"G1"}, {"G3"}), S("I2", {"G1", "G2"}), S("I3", {"G2"}), S("M2", {"G2"}, {"G1"}),
                               S("M3", {"G1", "G3"}, other=2), S("S2", set())]}
masked = {r.RunId("d", B, "M2"): frozenset({"G1"}), r.RunId("d", B, "M3"): frozenset({"G1", "G2"})}
rows = {(x.arm, x.pass_): x for x in r.rows_for("d", "standards", scores, {k: R(k.step) for k in scores}, masked, [], truth)}
one = rows[("I", 1)]
assert (one.filed_hard, one.hard_found, one.nonhard_found, one.over_rated, one.new) == (1, 1, 1, 0, 2), one
assert rows[("I", 2)].new == 1 and rows[("I", 2)].filed_hard == 2 and rows[("I", 3)].new == 0
assert rows[("M", 2)].new == 1 and rows[("M", 2)].filed_hard == 2 and rows[("M", 2)].nonhard_found == 1
assert rows[("M", 3)].new == 0 and rows[("M", 3)].over_rated == 1 and rows[("M", 3)].other == 2
assert rows[("S", 2)].new == 0 and rows[("S", 3)].chains == 0 and rows[("S", 3)].new is None
assert one.output == 100 and one.wall_s == 2
assert not r.rows_for("d", "spec", scores, {k: R(k.step) for k in scores}, masked, [], truth)[0].chains'
pycheck "rule: a bug found non-hard, then filed hard later in the chain, counts once as filed hard" '
truth = {"r1": (G("G1", "a", "b"),)}
def R(step):
    return r.Receipt(r.RunId("d", B, step), "complete", "complete", "m", "high", None, None, None)
scores = {s.run: s for s in [r.Score(r.RunId("d", B, "1"), None, frozenset(), frozenset({"G1"}), 0),
                             r.Score(r.RunId("d", B, "S2"), None, frozenset({"G1"}), frozenset({"G1"}), 0)]}
rows = {(x.arm, x.pass_): x for x in r.rows_for("d", "standards", scores, {k: R(k.step) for k in scores}, {}, [], truth)}
assert (rows[("S", 1)].filed_hard, rows[("S", 1)].hard_found) == (0, 1), rows[("S", 1)]
assert (rows[("S", 2)].filed_hard, rows[("S", 2)].hard_found, rows[("S", 2)].new) == (1, 1, 0), rows[("S", 2)]'
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
pycheck "prompt: each kept round names its frozen ticket, and pr96-r1 its grounding" '
from pathlib import Path
fx = r.load_fixtures(Path(sys.argv[1]).parent)
for rnd, grounding in (("pr94-r1", False), ("pr96-r1", True), ("pr99-r1", False)):
    for axis in r.AXES:
        brief = fx.briefs[r.BriefId(rnd, axis)]
        prompt = r.plan(r.RunId("claude:opus-5", brief.id, "1"), brief, Path("/w")).prompt
        nonce = prompt.split("/w/")[1].split("/")[0]
        here = f"/w/{nonce}/factory918/{brief.report_relpath.parent}"
        assert f"The ticket as it stood at this commit is `{here}/ticket.md`" in prompt, prompt
        assert (f"grounding is `{here}/blast-radius.md`." in prompt) == grounding, prompt
        assert not [w for w in r.BANNED if w in prompt.lower()], prompt'
pycheck "cross-run: a scratchpad file this run wrote first is its own" '
from pathlib import Path
pad = "/private/tmp/claude-501/-Users-x/abcd/scratchpad"
def use(i, name, **inp):
    return {"type": "assistant", "timestamp": f"t{i}", "message": {"content": [{"type": "tool_use", "id": f"u{i}", "name": name, "input": inp}]}}
export = Path("/w/nonce1/factory918")
own = [use(1, "Write", file_path=f"{pad}/mine.md"), use(2, "Read", file_path=f"{pad}/mine.md"),
       use(3, "Bash", command=f"S={pad}/rv89; rm -rf $S; mkdir -p $S && cp -R /w/nonce1/factory918 $S"),
       use(4, "Bash", command=f"S={pad}/rv89; cd $S/factory918 && grep -n x a.md"),
       use(5, "Bash", command=f"git diff > {pad}/d.txt"), use(6, "Read", file_path=f"{pad}/d.txt"),
       use(7, "Bash", command="cat /w/nonce1/factory918/a.md")]
assert r.cross_run_reads(own, export) == [], r.cross_run_reads(own, export)
other = own + [use(8, "Bash", command=f"cat {pad}/theirs.md"), use(9, "Read", file_path="/w/nonce2/factory918/x.md")]
assert [(c, p) for c, _, p, _ in r.cross_run_reads(other, export)] == [(8, pad.removeprefix("/private") + "/theirs.md"), (9, "/w/nonce2/factory918/x.md")], r.cross_run_reads(other, export)'
pycheck "content: a heading of up to three words dates nothing; a longer comment does" '
assert r.dated("## Testing decisions") is None and r.dated("### The scenario table") is None, "short headings"
assert r.dated("# in place of the one it rebuilt") == "# in place of the one it rebuilt"'
pycheck "settle: no lines leaves the brief as it is" 'assert r.settle("x\n## Standards\n", "standards", []) == "x\n## Standards\n"'

echo "all $n checks passed"
