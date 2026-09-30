## Walk

1. Criterion 1, comment side: `review-comment.sh` goes through the Act on items ending in `fixed: <sha>`, finds each one's report heading through `specs()`, and prints `would-break fixed after $reviewed` between the summary line and `round:` when a fixed item sits under `## Would break` and no hole is marked. A comment whose fixes are all Fails-open, breach or prose items prints today's tail (table B rows 1 to 3).
2. Criterion 1, brief side: `review-brief.sh` takes the deciding comment (the last in the history) and reads its WB line outside fenced text. A malformed line is refused (FM), and so is a sixth round (F6). A round past three is allowed only as `top + 1` after a comment that carries the line; otherwise it refuses with F4 (byte-identical to today) or F5. The refusals fire before `mkdir -p "$dir"`.
3. Criterion 2: the WB sha has to resolve (FR) and has to equal the fixed point that was passed (FP). With no ticket, a round whose previous round had a spec is refused (FT); the ticket is resolved first, from `git log $fixed..HEAD`. From round four both briefs carry `## The fix under review`, with `fix_rule` and the deciding comment's fixed Act on lines, before the diff. `<dir>/reviewed` records `git rev-parse HEAD` in both forms. SKILL.md step 1 and the Would-break fix section of `ticket.md` name `review-brief.sh <sha> --ticket N`.
4. Criterion 3: the step 5 paragraph states that no count is compared between rounds. It gives the two judgment stops (the round-three look, then on to five) and the round-five report, `gh pr ready --undo`, work that continues elsewhere, and the wait. Neither script counts or compares Would-break items across rounds, and the summary line is unchanged.
5. Criterion 4: the babysit sentence is byte-identical in `babysit.md` and `babysit/SKILL.md` (the patches and `SOURCES.md` 4 and 12 match), and the test pins it. A PR that ends at round three with no WB line reads as it does today.
6. Criterion 5: the tests cover the round-four fix-only brief (3A/3C, with the fix section before `## Diff`), FP, FR, FT, round five (9A), the sixth-round F6 (11A), and table B's columns C, D and E.
7. Criterion 6: P20 carries a dated #93 amendment, and P30 records the round-five draft. The ladder's rung 1 states the rule in one sentence. MANUAL's merge checklist has gained the line check, and `build_knowledge` output is in the diff.

## Would break

## Fails open

## Not asked for

hard findings: 0
