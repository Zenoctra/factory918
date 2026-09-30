## Walk

1. Criterion 1: `SKILL.md` step 5 and `review-ladder.md` rung 1 carry the design-hole definition as the contract words it.
2. Criterion 2: `review-brief.sh` echoes `spec_rule` one blank line after `step_rule` in both briefs; `review-comment.sh` `report()` runs `stepless` twice, step refusal first, then `^spec: $ref$`, on both reports.
3. Criterion 3: `holed()` checks placement, then grammar, then word-for-word match against `specs()`; `holes` is subtracted from the count and `restart` printed before `round:`.
4. Criterion 4: the slicing awk in `review-brief.sh` keeps comments after the last exact `restart` line outside fences and prints the `restart:` line; `ticket.md` gains the step 8 pointer and the Design hole section.
5. Criterion 5: `cites` gains `#[0-9]+ $ref`, still `$`-anchored.
6. Criterion 6: the tests cover table A rows 5 to 8 and 11 to 17 and table B rows 1 to 6 with the notes' cases.
7. Criterion 7: the babysit sentence is added in both places; columns A to C print as before.

## Would break

1. **The Standards report cannot name a spec reference it has no way to see.** `review-comment.sh` refuses every counted Standards item without `spec: table|design|criterion`. The Standards brief does not include the ticket (only the Spec brief prints `## The ticket`). A review with no ticket at all (`no spec: Standards axis only`, or the `--paths` sweep form) has no table, sketch or criterion to cite. In those cases a truthful Standards `## Would break` or `## Fails open` item is refused, and the refusal's fix, "Ask the reviewer for it", cannot be met. The reviewer either makes up a reference or the round can never finish. A made-up reference then feeds `hole:` checks on an artifact that does not exist.

```
- [ ] Every Would-break and Fails-open item in both reports carries a `spec:` line naming what it rests on
```

Documented step: `SKILL.md` step 6, "when a `## Would break` or `## Fails open` item has no `spec:` line in one of the three forms (ask the reviewer for it)"
Result: a standards-only review, or a Standards reviewer without the ticket, cannot produce an accepted report for a real counted finding without making up its `spec:` line.
spec: criterion 2

## Fails open

## Not asked for

hard findings: 1
