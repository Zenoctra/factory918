## Walk

1. `review-brief.sh` reads the deciding (last) history comment, extracts the `would-break fixed after <sha>` line outside fenced text via `wb_line`/`wb`, whether it had a spec (`had_spec`), and its fixed Act on items (`fixed_items`).
2. It refuses (`FM`) when a WB line is present but its content is not 40 lowercase hex.
3. It refuses a sixth round (`F6`) when `round > 5`.
4. For `round > 3`, it requires `wb` non-empty and `round == top + 1`, else refuses `F4` (top ≤ 3, round 4) or `F5` (otherwise).
5. It verifies the WB sha resolves (`FR`) and equals the fixed point passed (`FP`).
6. It refuses `FT` when the fix commits name no ticket while the previous round had a spec.
7. It prints `round: N of $cap` with `cap=3` for rounds ≤3, `cap=5` otherwise, and writes `git rev-parse HEAD` to `<dir>/reviewed` right after `<dir>/round`, unconditionally (both the PR and sweep forms).
8. From round 4 on, both briefs carry `## The fix under review` with `$fix_rule` and the deciding comment's fixed Act on items, placed before `## Diff`.
9. `review-comment.sh` computes `cap` the same way, finds the first Would-break-heading Act on item marked `fixed:` (`wb_first`), and when found with no hole marked, reads `<dir>/reviewed`, refusing (`RM`) if missing or not a full commit id.
10. The comment's tail prints `restart` when a hole exists, else `would-break fixed after <sha>` when `wb_first` is set, then `round: N of $cap`, then `act-on items: N` (unchanged formula).
11. Prose (`SKILL.md` step 1/4/5/6, `ticket.md` step 8 and new "Would-break fix" section, `babysit.md`/`babysit/SKILL.md`, `review-ladder.md`, `MANUAL.md`, `DECISIONS.md` P20/P30, `SOURCES.md` items 4/6/12) and tests (`review-brief.sh`, `review-comment.sh`, `no-stale-wording.sh`) were updated to describe and cover this behavior.

## Would break

## Fails open

## Not asked for

hard findings: 0
