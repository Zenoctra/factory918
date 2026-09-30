## Walk

1. Criterion 1: `spec-review/SKILL.md` step 5 (template and patch) gains the design-hole paragraph with the three artifacts, intent over criterion, the could-not-run exclusion and "test for all three"; `review-ladder.md` rung 1 carries the same definition.
2. Criterion 2: `review-brief.sh` defines `spec_rule` and echoes it one blank line after `step_rule` in both briefs; SKILL.md step 4 quotes it word for word. `review-comment.sh` calls `stepless` a second time with `^spec: $ref$` after the step check, so a counted item with no `spec:` line, or a fenced or malformed one, is refused with the reviewer-facing message.
3. Criterion 3: `holed()` finds Act on items whose last field is `hole:`. The checks run in this order: a hole outside Act on (G), a hole in no form (E), and a hole whose value is not the judged item's `spec:` value from `specs()` (F, and 5D when the item has no `spec:`). `holes` is subtracted from the count, and `restart` prints before `round:`.
4. Criterion 4: the Ticket playbook's step 8 pointer and the new `### Design hole` section cover the scoped architect Phase B (two runners), the dated amendment line, tests first, review from round one, and "never merge-ready". In `review-brief.sh`, the slice awk keeps only the comments after the last comment that has a line exactly `restart` outside fenced text, cuts at EOF when no separator follows, and prints the `restart:` line between `ticket:` and `round:`. The round and settled derivations read the sliced history unchanged.
5. Criterion 5: `cites` gains the `#[0-9]+ $ref` alternative inside the `$`-anchored group, and the `ref=` line is identical in both scripts. `fragment()` now holds both copies together.
6. Criterion 6: the brief tests cover table A rows 5 to 8 and 11 to 17. The comment tests cover table B rows 1 to 6 across columns A to G, and the two-holes, last-field and rerun notes.
7. Criterion 7: the babysit sentence is added to `babysit.md` and to `babysit/SKILL.md` step 4 with identical wording. The existing merge-ready text and columns A to C are unchanged.

## Would break

## Fails open

## Not asked for

hard findings: 0
