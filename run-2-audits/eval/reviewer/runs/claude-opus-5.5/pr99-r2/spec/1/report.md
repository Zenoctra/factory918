## Walk

1. Criterion 1: the design-hole definition is in `spec-review/SKILL.md` step 5 (template and patch), in the rung-1 text of `review-ladder.md`, and in P26. It covers all three artifacts, puts intent above any one criterion, and excludes a could-not-run refusal.
2. Criterion 2 (as amended): `review-brief.sh` echoes `$spec_rule` after `$step_rule` in the Spec brief, and in the Standards brief only when `$spec` is set. `review-comment.sh` sets `has_spec` from `spec-brief.md` before the Standards report is checked, then calls `stepless` a second time with `^spec: $ref$`.
3. Criterion 3: `holed()` finds the `hole:` text on lines that do not end in `fixed:` or `ticket:`. The script refuses a hole in a review with no spec, a hole outside Act on, a value in no form, and a mismatch with `specs()`. It subtracts `holes` from the count and prints `restart` between the summary line and `round:`.
4. Criterion 4: `ticket.md` step 8 points to the new Design hole section. That section has six steps: scope, architect Phase B with two runners, a dated amendment, tests first, round one, and never merge-ready. In `review-brief.sh`, the slice awk keeps only the comments after the last unfenced `restart` line, prints the `restart:` line, and leaves the round refusal unchanged.
5. Criterion 5: `cites` gains the alternative `#[0-9]+ $ref`, still `$`-anchored.
6. Criterion 6: the tests cover the missing, malformed and fenced `spec:` cases, each reference form, 5D, the restart rows 5 to 8 and 11 to 13, the cites in rows 14 to 17, and the `fragment()` pin that keeps both `ref=` lines identical.
7. Criterion 7: `babysit.md` and `babysit/SKILL.md` get the same new sentence, and their merge-ready condition for columns A to C is unchanged.

## Would break

## Fails open

## Not asked for

1. **The merge read in MANUAL.md gains a restart clause.** `docs/knowledge/core/MANUAL.md` step 2 and the template copy now say a comment carrying `restart` is not ready. The ticket names babysit's merge-ready condition, and the contract says `MANUAL.md` is untouched by the writer. The owner's commit 384bb43 adds the clause, and it matches the babysit sentence, so it is consistent. It is still outside the ticket's file list.

```
No new file, no renumbered step; `arena`, `architect`, `MANUAL.md` and `DECISIONS.md` (the owner's Provisional entry) untouched by the writer.
```

hard findings: 0
