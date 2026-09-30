## Walk

1. `review-brief.sh` finds the deciding comment (last of the history) and reads its `would-break fixed after <sha>` line, whether it had a spec, and its fixed Act on items.
2. A malformed WB line (short, uppercase, trailing text, or none) is refused (`FM`) before any other gate, regardless of round.
3. `round > 5` is refused (`F6`); `round > 3` without a WB line naming this exact round, or with the wrong round, is refused as `F4` (top ≤ 3) or `F5` otherwise.
4. A round past three checks the WB sha resolves (`FR`), matches the passed fixed point (`FP`), and that a ticket is supplied when the prior round had a spec but the fix commits name none (`FT`).
5. `<dir>/round` and `<dir>/reviewed` (`git rev-parse HEAD`) are written for every accepted run, including the sweep form.
6. From round four, both briefs carry `## The fix under review` with the fixed items and `fix_rule`, before the diff.
7. `review-comment.sh` finds the first Would-break-headed Act on item marked `fixed:`, requires `<dir>/reviewed` to hold a 40-hex id (`RM` otherwise), and prints `would-break fixed after <sha>` unless a hole is marked; `cap` is 5 past round three.
8. Prose in `spec-review/SKILL.md`, `ticket.md`, `babysit`'s two copies, `review-ladder.md`, `MANUAL.md`, `DECISIONS.md` (P20, P30) and `SOURCES.md` describe the same round-four/five, fix-only, no-count-comparison rule.
9. `tests/spec-review/review-brief.sh` and `review-comment.sh` add one assertion per scenario-table cell; `no-stale-wording.sh` blacklists "at most three rounds".

## Would break

## Fails open

## Not asked for

hard findings: 0
