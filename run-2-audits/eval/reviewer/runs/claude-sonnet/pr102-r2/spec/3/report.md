## Walk

1. `review-brief.sh` reads the deciding comment (the last of the history) and extracts the `would-break fixed after <sha>` line (`wb_line`/`wb`) with the same fence-aware awk used for `round:`.
2. A malformed line (anything after the words but a 40-lowercase-hex sha, including nothing at all) is refused (`FM`) before any other check, using `-n "$wb_line"` to tell "no line" from "line present but empty" apart, since the case is empty in both.
3. `round` past 5 is refused (`F6`) before the round-3/4 gate runs.
4. Past round 3: no line, or the round is not exactly `top + 1`, refuses `F4` (top ≤ 3, round 4) or `F5` (otherwise); the line's sha must resolve here (`FR`) and equal the passed fixed point (`FP`); a fix-only round with no `--ticket` after a round that had a spec refuses (`FT`).
5. `cap=3; [ "$round" -le 3 ] || cap=5` and `round: $round of $cap` are printed identically in both scripts, held together by the test's `fragment()`.
6. `<dir>/reviewed` is written as `git rev-parse HEAD` right after `<dir>/round`, in both the PR form and the sweep form.
7. From round 4 on, `## The fix under review` (the `fix_rule` paragraph plus the deciding comment's fixed Act-on lines) is inserted before `## Diff` in both briefs.
8. `review-comment.sh` walks Act-on items ending `fixed: <hex>`, resolves each `[S<n>]`/`[P<n>]` to its report heading via `specs()`, and keeps the first one whose heading is "Would break" (`wb_first`).
9. When `wb_first` is set and no hole is marked, `<dir>/reviewed` must hold one line of 40 lowercase hex or the script refuses (`RM`) before any output, quoting the item's title and the file's content as written.
10. The comment's tail order is: `restart` (a hole) else `would-break fixed after <sha>` (a Would-break fix) else nothing, then `round: N of $cap`, then `act-on items: N`; the count never includes how many fixes were would-break.
11. Every prose file listed in the brief (SKILL.md, both babysit copies via their patches, ticket.md, review-ladder.md, MANUAL.md, DECISIONS.md P20/P30, SOURCES.md items 4/6/12, the no-stale-wording blacklist) carries the wording the ticket specifies, word for word where quoted.

## Would break

## Fails open

## Not asked for

hard findings: 0
