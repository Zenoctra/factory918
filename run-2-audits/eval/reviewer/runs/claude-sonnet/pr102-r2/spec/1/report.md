## Walk

1. `review-brief.sh` computes `top` from the last `round: N of 3` (or `of 5`) line across the comment history, unchanged except the regex now accepts `of 5`.
2. It finds the "deciding comment" (the last comment in the sliced history) and reads its `would-break fixed after <sha>` line, whether it had a spec, and its fixed Act on items.
3. A malformed `would-break fixed after` line (not 40 lowercase hex) is refused (`FM`) before any other round check.
4. A round past 5 is refused (`F6`).
5. A round past 3 with no valid WB line, or not exactly `top + 1`, is refused as `F4` (when `top <= 3`) or `F5` otherwise.
6. When the WB line licenses the round, the fixed point must resolve to and equal the named sha (`FR`, `FP`), and a missing ticket after a round that had a spec is refused (`FT`).
7. `round: N of <cap>` is printed with `cap=3` for rounds 1-3 and `cap=5` for 4-5, identically in both scripts.
8. `<dir>/reviewed` is written as `git rev-parse HEAD` right after `<dir>/round`, in both the branch form and the sweep form.
9. From round 4 on, both briefs carry `## The fix under review` (the fixed items of the deciding comment) before `## Diff`.
10. `review-comment.sh` computes `holes` and, when zero, finds the first Act on item ending `fixed: <sha>` whose report item sits under `## Would break`; if found, it requires `<dir>/reviewed` to hold 40 lowercase hex (`RM` otherwise) and prints `would-break fixed after <sha>` between the summary line and `round:`, never beside `restart`.
11. The summary line's fixed-here/ticketed/holes counts are unchanged; the comment never states how many fixes were would-break.
12. `ticket.md` step 8 and the new "Would-break fix" section route the orchestrator to run the fix-only round or, at round five, to write the human report and mark the PR a draft.
13. `SKILL.md` step 5, the ladder, `MANUAL.md`, `SOURCES.md` items 4/6/12 and both babysit copies restate the round-5-with-line stop and the no-count-comparison rule in prose, pinned byte-identical between the two babysit copies and tested by `no-stale-wording.sh`'s new blacklist entry.

## Would break

## Fails open

## Not asked for

hard findings: 0
