## Would break

## Fails open

## Standards breaches

## Fix alongside

No smells rose to a judgment call worth naming: the round-cap logic (`review-brief.sh`, `review-comment.sh`) duplicates a one-line `cap=3; [ "$round" -le 3 ] || cap=5` fragment between the two scripts, but this follows the repo's existing pattern for the `fenced=`/`ref=` fragments and is pinned by `tests/spec-review/review-brief.sh`'s `fragment()` check, so it is a deliberate, guarded duplication rather than an unwatched one. Bash quoting, `set -euo pipefail`, portability (no `sed -i`, `date -d`, `readlink -f`), and the `shellcheck disable` convention are all unaffected by this diff; the one existing disable directive in `tests/spec-review/review-brief.sh` is unchanged context, not new. The extensive new test coverage in `tests/spec-review/review-brief.sh` and `tests/spec-review/review-comment.sh` (rows 1-20 and the Would-break tables) independently exercises the round-cap, fixed-point, and `reviewed`-file logic added in `review-brief.sh`/`review-comment.sh`, and it passes the documented-path/fails-open distinctions this review looks for: gates are checked and refused before any state is written, refusal messages match the code paths they describe, and the `would-break fixed after` / `restart` lines are kept mutually exclusive in the code (`review-comment.sh`: `holes` checked before `wb_first`).

hard findings: 0
