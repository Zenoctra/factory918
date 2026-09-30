# Standards report

## Would break

None.

## Fails open

None.

## Standards breaches

None.

## Fix alongside

None found worth flagging. The round-cap logic in `review-brief.sh` (the `top`/`deciding`/`wb`/`want` chain around the `round -gt 3` gate) is dense and adds several new branches, but every unhappy path it opens (a hand-written `would-break fixed after` line, a wrong fixed point, a sixth round, a fix-only round with no ticket after a spec'd round) is refused with a specific message before any state is written, matching CODING_STANDARDS.md's rule that a gated failure prints before anything continues. The duplicated `cap=3; [ "$round" -le 3 ] || cap=5` line between `review-brief.sh` and `review-comment.sh` is Duplicated Code by the baseline, but it follows the same already-established pattern as the file's existing `fenced=`/`ref=` fragments, which are kept identical by a dedicated test (`tests/spec-review/review-brief.sh`, the `fragment()` check, extended in this diff to also pin `cap=3;`); the repo standard of holding paired scripts together with a diff-lockstep test overrides the baseline here.

Reviewed: `template/.agents/skills/spec-review/scripts/review-brief.sh` and `review-comment.sh` (the only behavior-changing hunks), their patch mirrors, and the prose/doc changes (SOURCES.md, DECISIONS.md P20/P30, MANUAL.md, review-ladder.md, babysit copies). The bash follows `set -euo pipefail`, quotes paths and variables, uses `awk`/`sed` for markdown text parsing (not JSON/YAML, so the jq/python3 rule does not apply), and every new failure path names what to do next. No BSD/GNU portability divergence was introduced (no `sed -i`, `date -d`, or `readlink -f` added). The `# shellcheck disable=SC2016` line already present in the test file keeps its reason comment.

hard findings: 0
