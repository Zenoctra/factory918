#!/usr/bin/env bash
# Runs template/.agents/skills/spec-review/scripts/review-comment.sh against fixture reports and
# judgments in a temp repo and asserts the exact stdout of each accepted shape and the exact
# refusal line of each rejected one. A refusal leaves the review state in place; an accepted
# run clears it. Exits 1 on the first miss.
set -euo pipefail
here="$(cd "$(dirname "$0")/../.." && pwd -P)"
script="$here/template/.agents/skills/spec-review/scripts/review-comment.sh"
fx="$(mktemp -d)"
trap 'rm -rf "$fx"' EXIT
cd "$fx"
git init -q
git config user.email test@factory918.invalid
git config user.name test
git commit -q --allow-empty -m fixture
dir=.scratch/review/x
state=.claude/state/review

n=0
code=0
out=""
# reset: a fresh review with no reports and no spec brief.
reset() {
  rm -rf "$dir" "$state"
  mkdir -p "$dir" "$state"
  echo main > "$state/fixed-point"
  echo a.sh > "$state/files"
  echo "$dir" > "$state/dir"
}
run() {
  set +e
  out="$(bash "$script" 2>&1)"
  code=$?
  set -e
}
# refuse <message> <label>: exit 1, that one line on stderr, the state as it was (kept, or absent).
refuse() {
  local had=no
  [ -f "$state/dir" ] && had=yes
  run
  if [ "$code" != 1 ] || [ "$out" != "review-comment: $1" ] || [ "$([ -f "$state/dir" ] && echo yes || echo no)" != "$had" ]; then
    echo "FAIL $2: exit $code, wanted 1 and the state as it was"
    echo "  got:    $out"
    echo "  wanted: review-comment: $1"
    exit 1
  fi
  n=$((n + 1))
}
# accept <stdout> <label>: exit 0, exactly that output, the state cleared.
accept() {
  run
  if [ "$code" != 0 ] || [ "$out" != "$1" ] || [ -e "$state" ]; then
    echo "FAIL $2: exit $code, wanted 0 and the state cleared"
    echo "  got:"; printf '%s\n' "$out"
    echo "  wanted:"; printf '%s\n' "$1"
    exit 1
  fi
  n=$((n + 1))
}
empty_standards() { printf '## Would break\n\n## Standards breaches\n\n## Fix alongside\n\nhard findings: 0\n'; }
empty_spec() { printf '## Would break\n\n## Latent\n\n## Not asked for\n\nhard findings: 0\n'; }
empty_judgment() { printf '## Act on\n\n## Ask\n\n## Consider\n\n## Noted\n\n## Dismissed\n'; }

refuse "no review in progress ($state/dir is missing); run scripts/review-brief.sh first" "no state"

reset
refuse "$dir/standards-report.md is missing; wait for the Standards reviewer" "no Standards report"

printf '## Would break\n\n## Standards breaches\n\n## Fix alongside\n' > "$dir/standards-report.md"
refuse "$dir/standards-report.md has no 'hard findings: N' line; ask the reviewer for it" "Standards report without the count line"

printf '## Would break\n\n1. **One.** a\n\n## Standards breaches\n\n## Fix alongside\n\n1. **Smell.** b\n\nhard findings: 2\n' > "$dir/standards-report.md"
refuse "$dir/standards-report.md says 'hard findings: 2' but has 1 items under '## Would break'; only those count. Ask the reviewer to put each finding under the heading it belongs to and recount" "count line above the Would-break items"

printf '## Would Break\n\n## Standards breaches\n\nhard findings: 0\n' > "$dir/standards-report.md"
refuse "$dir/standards-report.md has the headings [Would Break|Standards breaches]; the shape is [Would break|Standards breaches|Fix alongside], in that order, each holding numbered items or nothing" "Standards report off its shape"

empty_standards > "$dir/standards-report.md"
echo brief > "$dir/spec-brief.md"
refuse "$dir/spec-report.md is missing; wait for the Spec reviewer" "Spec brief without a Spec report"

printf '## Would break\n\n## Not asked for\n\n## Latent\n\nhard findings: 0\n' > "$dir/spec-report.md"
refuse "$dir/spec-report.md has the headings [Would break|Not asked for|Latent]; the shape is [Would break|Latent|Not asked for], in that order, each holding numbered items or nothing" "Spec report headings out of order"

empty_spec > "$dir/spec-report.md"
refuse "$dir/judgment.md is missing; sort every report item into Act on, Ask, Consider, Noted or Dismissed with a one-line reason (SKILL.md step 5), then rerun" "no judgment"

printf '## Act on\n\n## Consider\n\n## Noted\n\n## Dismissed\n' > "$dir/judgment.md"
refuse "$dir/judgment.md has the headings [Act on|Consider|Noted|Dismissed]; the shape is [Act on|Ask|Consider|Noted|Dismissed], in that order, each holding numbered items or nothing" "judgment without Ask"

printf '## Would break\n\n1. **One.** a\n\n## Standards breaches\n\n2. **Two.** b\n\n## Fix alongside\n\nhard findings: 1\n' > "$dir/standards-report.md"
printf '## Would break\n\n## Latent\n\n1. **Edge.** c\n\n## Not asked for\n\nhard findings: 0\n' > "$dir/spec-report.md"
printf '## Act on\n\n1. [S1] **One.** yes\n\n## Ask\n\n## Consider\n\n## Noted\n\n## Dismissed\n' > "$dir/judgment.md"
refuse "$dir/judgment.md has 1 items; the reports have 3 (Standards 2, Spec 1). Every report item appears exactly once in the judgment" "judgment short of the reports"

printf '## Act on\n\n1. [S1] **One.** yes\n\n## Ask\n\n## Consider\n\n## Noted\n\n1. [S4] **Two.** later\n\n## Dismissed\n\n1. [P1] **Edge.** no\n' > "$dir/judgment.md"
refuse "$dir/judgment.md does not name every report item exactly once: missing [S2], unknown or repeated [S4]; the reports have 2 Standards items and 1 Spec items" "reference to an item that does not exist"

printf '## Act on\n\n1. [S1] **One.** yes\n\n## Ask\n\n## Consider\n\n## Noted\n\n1. [S1] **One again.** twice\n\n## Dismissed\n\n1. [P1] **Edge.** no\n' > "$dir/judgment.md"
refuse "$dir/judgment.md does not name every report item exactly once: missing [S2], unknown or repeated [S1]; the reports have 2 Standards items and 1 Spec items" "repeated reference"

printf '## Act on\n\n1. [S1] **One.** yes\n\n## Ask\n\n## Consider\n\n## Noted\n\n1. **Two.** no reference\n\n## Dismissed\n\n1. [P1] **Edge.** no\n' > "$dir/judgment.md"
refuse "$dir/judgment.md item '1. **Two.** no reference' does not open with [S<n>] or [P<n>], the report item it judges" "item without a reference"

rm "$dir/spec-brief.md" "$dir/spec-report.md"
printf '## Act on\n\n1. [S1] **One.** yes\n\n## Ask\n\n## Consider\n\n## Noted\n\n1. [P1] **Edge.** no\n\n## Dismissed\n' > "$dir/judgment.md"
refuse "$dir/judgment.md does not name every report item exactly once: missing [S2], unknown or repeated [P1]; the reports have 2 Standards items and 0 Spec items" "Spec reference without a Spec axis"

reset
empty_standards > "$dir/standards-report.md"
empty_judgment > "$dir/judgment.md"
accept "## Standards

## Would break

## Standards breaches

## Fix alongside

hard findings: 0

## Spec

no spec: Standards axis only

## Judgment

## Act on

## Ask

## Consider

## Noted

## Dismissed

Standards: 0 would break of 0; Spec: no spec; judged: act on 0, ask 0, consider 0, noted 0, dismissed 0; fixed point main.
act-on items: 0" "nothing found, no spec"

reset
cat > "$dir/standards-report.md" <<'EOF'
## Would break

1. **Hook exits 0 on a miss.** The guard returns before blocking.

```sh
## Would break
1. a numbered line inside a quoted hunk is not an item
```

## Standards breaches

2. **Bare number.** P3 wants the constant named.

## Fix alongside

3. **Duplicated Code.** The two loops share a shape.

hard findings: 1
EOF
echo brief > "$dir/spec-brief.md"
cat > "$dir/spec-report.md" <<'EOF'
## Would break

1. **Sweep form ignores --ticket.** "add `--ticket N` when the commits do not name the ticket".

## Latent

2. **Token in the log.** The state file could carry a secret.

## Not asked for

hard findings: 1
EOF
cat > "$dir/judgment.md" <<'EOF'
## Act on

1. [S1] **Hook exits 0 on a miss.** The test proves it.
2. [P1] **Sweep form ignores --ticket.** The commit list is empty there.

## Ask

1. [P2] **Token in the log.** Data retention is the human's call.

## Consider

## Noted

1. [S3] **Duplicated Code.** Fixed alongside S1 if the loops are touched.

## Dismissed

1. [S2] **Bare number.** The constant is named two lines up.
EOF
accept "## Standards

$(cat "$dir/standards-report.md")

## Spec

$(cat "$dir/spec-report.md")

## Judgment

$(cat "$dir/judgment.md")

Standards: 1 would break of 3; Spec: 1 would break of 2; judged: act on 2, ask 1, consider 0, noted 1, dismissed 1; fixed point main.
act-on items: 3" "two Act on and one Ask"

reset
printf '## Would break\n\n## Standards breaches\n\n## Fix alongside\n\n1. **Mysterious Name.** x\n2. **Middle Man.** y\n\nhard findings: 0\n' > "$dir/standards-report.md"
printf '## Act on\n\n## Ask\n\n## Consider\n\n## Noted\n\n## Dismissed\n\n1. [S1] **Mysterious Name.** the name is the domain term\n2. [S2] **Middle Man.** one caller, kept inline\n' > "$dir/judgment.md"
accept "## Standards

$(cat "$dir/standards-report.md")

## Spec

no spec: Standards axis only

## Judgment

$(cat "$dir/judgment.md")

Standards: 0 would break of 2; Spec: no spec; judged: act on 0, ask 0, consider 0, noted 0, dismissed 2; fixed point main.
act-on items: 0" "Dismissed only"

echo "ok $n assertions"
