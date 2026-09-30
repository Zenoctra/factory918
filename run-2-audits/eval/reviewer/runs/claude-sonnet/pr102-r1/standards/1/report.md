# Standards report

## Would break

None.

## Fails open

None.

## Standards breaches

None.

## Fix alongside

None.

## Notes

Traced the new round-cap logic end to end against `CODING_STANDARDS.md` and the smell baseline:

- `review-brief.sh`'s gate on `round > 3` (checking `wb`, `top`, the `$wb^{commit}` resolution, and the `--ticket` requirement for a spec-less fix-only round) and `review-comment.sh`'s `wb_first`/`holes` selection (a hole outranks a would-break line; `<dir>/reviewed` is validated as a full commit id before the line is printed) both match the documented behavior in `template/.agents/skills/spec-review/SKILL.md` and `docs/knowledge/core/DECISIONS.md` P20/P30 word for word.
- The shared `cap=3; [ "$round" -le 3 ] || cap=5` line and the `fenced`/`ref` awk fragments stay identical between `review-brief.sh` and `review-comment.sh`, per the existing copy-fragment convention, and `tests/spec-review/review-brief.sh` pins the fragment (`fragment()` now also captures `cap=3; `).
- `docs/knowledge/core/DECISIONS.md`'s stated line count (98) matches the file's actual length, and the SOURCES.md, MANUAL.md, review-ladder.md and babysit copies all restate the three/five-round rule consistently.
- No unquoted path, no `sed`-based structured edit, and no new `shellcheck disable` without a reason comment appear in the diff's bash hunks.

Found no hard findings and no baseline smells worth flagging; the round-cap feature is a clean, internally consistent change with test coverage (`tests/spec-review/review-brief.sh`, `tests/spec-review/review-comment.sh`) matching the code paths read here.

hard findings: 0
