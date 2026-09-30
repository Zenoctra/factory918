## Walk

1. Criterion 1, the kind of a fix: `review-comment.sh` goes through the Act on items that end in `fixed: <sha>`. It resolves each `[S<n>]`/`[P<n>]` reference through `specs()` to its report heading and prints `would-break fixed after <reviewed>` when a fixed item sits under `Would break` and no hole is marked. Fails-open items, standards breaches and prose print no line (table B rows 1, 2, 3, 6).
2. Criterion 1, the gate: `review-brief.sh` takes the last comment of the history as the deciding comment and reads its WB line outside fenced text. It refuses a malformed line (FM), any round past five (F6), and a round past three with no line or not `top + 1` (F4, whose text is unchanged byte for byte, or F5). This matches the contract's block.
3. Criterion 2, the fix-only fixed point: `review-brief.sh` writes `git rev-parse HEAD` to `<dir>/reviewed` beside `<dir>/round`. At rounds four and five it requires the fixed point to resolve to the WB sha (FR, then FP). It requires `--ticket` when the deciding comment had a spec and the fix commits name no ticket (FT). The ticket resolves before the gate runs. For the sweep form, `$fixed=paths` gives FP (row 17).
4. Criterion 2, the prose: step 1 of `spec-review`, step 8 of the Ticket playbook and its new Would-break fix section all name `review-brief.sh <sha> --ticket N`. From round four on, `common()` prints `## The fix under review`, the `fix_rule` paragraph and the fixed Act on lines before the diff. The same paragraph appears word for word in step 4 of `SKILL.md`.
5. Criterion 3: no code compares counts, and the summary line is unchanged. The step 5 paragraph carries both stops as written in the ticket (look at three, continue to five; at five: report, `gh pr ready --undo`, go on with other work, wait).
6. Criterion 4: the babysit sentence is byte-identical in both templates and both patches. A PR that ends at three prints `round: 3 of 3` (`cap=3`), and the babysit condition is unchanged for it.
7. Criterion 5: the tests cover round four from `$s` (3A/3C), round five (9A), F6 (11A), FP, FR and FT, and the empty-diff case.
8. Criterion 6: the P20 amendment and P30 are added, and rung 1 of `review-ladder.md` gains the one sentence. `at most three rounds` is blacklisted.

## Would break

## Fails open

## Not asked for

hard findings: 0
