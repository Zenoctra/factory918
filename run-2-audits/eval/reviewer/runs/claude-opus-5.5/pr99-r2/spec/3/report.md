# Spec review, #90

## Walk

1. Criterion 1: `SKILL.md` step 5 gains the design-hole paragraph (three artifacts, intent outranks a criterion, could-not-run refusals excluded, detection sharpest for a table); review-ladder rung 1 carries the same definition.
2. Criterion 2: `spec_rule` is echoed after `step_rule` in the Spec brief and, only when `$spec` is set, in the Standards brief; `report()` runs `stepless` with `^spec: $ref$` after the step check, only with `has_spec`.
3. Criterion 3: `holed()` finds the `hole:` field (lines not ending in `fixed:`/`ticket:`); refusals run in order no-spec, placement, form, value-versus-`specs()`; `holes` is subtracted from the count and one `restart` line prints before `round:`.
4. Criterion 4: `review-brief.sh` slices the fetched bodies after the last comment with an exact `restart` line outside fences, prints the `restart:` line after `ticket:`, then derives round and settled from the slice; with no restart the slice is the whole history. `ticket.md` gains the step 8 pointer and the Design hole section (architect Phase B, two runners, dated amendment, round one).
5. Criterion 5: `cites` gains `#[0-9]+ $ref` inside the `$`-anchored group.
6. Criterion 6: tests cover a missing and malformed `spec:`, all three forms, a hole on an item without `spec:` (5D), restart rows 5 to 8, 11 to 13, and cites rows 14 to 17.
7. Criterion 7: babysit's existing ready condition is untouched; the new sentence is identical in `babysit.md` and `babysit/SKILL.md` apart from the bullet marker.

## Would break

## Fails open

## Not asked for

1. **Merge-read clause in MANUAL.md.** Commit 384bb43 adds a `restart` clause to the merge-read step in `docs/knowledge/core/MANUAL.md` and `template/docs/factory918/MANUAL.md`, and adds DECISIONS P26, a P21 amendment and two ledger lines. The ticket says MANUAL.md is untouched by the writer. This is the owner's record commit, and it matches the babysit sentence, so it is consistent, but no criterion asks for the MANUAL.md change.

```
No new file, no renumbered step; `arena`, `architect`, `MANUAL.md` and `DECISIONS.md` (the owner's Provisional entry) untouched by the writer.
```

hard findings: 0
