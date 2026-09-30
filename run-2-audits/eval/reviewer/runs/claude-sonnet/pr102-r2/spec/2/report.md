## Walk

1. `review-brief.sh` computes `top` from the highest `round: N of 3` **or** `of 5` line among the PR's `act-on items:` comments (criterion 1; table A legend).
2. It isolates the deciding comment (last of the history) and reads its `would-break fixed after <sha>` line (`wb`), whether it had a spec (`had_spec`), and its fixed Act on items (`fixed_items`) (Terms: deciding comment, WB line).
3. Before any state: it refuses a hand-written WB line that is not 40 lowercase hex (`FM`), then a sixth round (`F6`), then a round past three that is not licensed by the WB line naming `round == top + 1` (`F4`/`F5`), then a fixed point that does not resolve (`FR`) or does not equal the WB sha (`FP`), then a fix-only round whose commits name no ticket while the previous round had a spec (`FT`) — in that order (criterion 2; the gate code block).
4. It sets `cap=3; [ "$round" -le 3 ] || cap=5` and prints `round: $round of $cap`, the identical line held in both scripts by `tests/spec-review/review-brief.sh`'s `fragment()` (criterion 1, 4).
5. On every accepted run, including the sweep form, it writes `git rev-parse HEAD` to `<dir>/reviewed` right after `<dir>/round` (criterion 2, table A row 20).
6. From round four on, `common()` emits `## The fix under review` with `$fix_rule` and the deciding comment's fixed items, before `## Blast radius`/`## Diff` (criterion 2).
7. `review-comment.sh` computes the same `cap`, finds the first fixed Act on item whose report heading is `Would break` (`wb_first`), and, when no hole is marked, requires `<dir>/reviewed` to hold a full commit id or refuses (`RM`) (criterion 1, 3).
8. It prints `restart` when a hole is marked, else `would-break fixed after <sha>` when `wb_first` is set, then `round: N of $cap`, then `act-on items: N` unchanged (criterion 1, 3).
9. `spec-review/SKILL.md`, `ticket.md`'s new **Would-break fix** section, both `babysit` copies, `review-ladder.md`, `MANUAL.md`, `SOURCES.md` and `DECISIONS.md` (P20, P30) are updated in prose to describe rounds four and five, the fix-only diff, and the round-five human stop (criteria 3, 4, 6).
10. `tests/spec-review/review-brief.sh` and `review-comment.sh` add one assertion per cell of tables A and B, and `no-stale-wording.sh` blacklists "at most three rounds" (criterion 5).

## Would break

## Fails open

## Not asked for

hard findings: 0
