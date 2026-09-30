## Walk

1. Criterion 1: `spec-review/SKILL.md` step 5 gains the design-hole paragraph word for word from the contract, and `review-ladder.md` rung 1 gains the sentence after "An Ask item waits for the human."; the patch carries the same text.
2. Criterion 2: `review-brief.sh` defines `spec_rule` and echoes it one blank line after `$step_rule` in both briefs; `SKILL.md` step 4 carries it word for word; `review-comment.sh` calls `stepless` twice (step regex, then `^spec: $ref$`), so a counted item with no `spec:`, a malformed one or a fenced one is refused after the step check.
3. Criterion 3: `holed()` collects judgment items with `hole:` not ending in `fixed:`/`ticket:`; refusals run in the order G (outside Act on), E (fits no form), F/5D (compared with `specs()` positional value); `holes` is subtracted from the count and `restart` is printed before `round:`.
4. Criterion 4: the new awk in `review-brief.sh` cuts `bodies` at the last unfenced `restart` line, so `top` and the settled set read only the kept comments; `X` is printed after `ticket:` and before `round:`; the Ticket playbook adds the step 8 pointer and a `### Design hole` section (architect Phase B, two runners, dated amendment, round one again).
5. Criterion 5: `cites` gains `#[0-9]+ $ref` inside the `$`-anchored group; the `ref=` line is spelled the same in both scripts, and `fragment()` checks that.
6. Criterion 6: the tests cover table B rows 1A to 1G, 2, 3 (malformed and fenced), 4, 5A/5D/5E/5F/5G, 6, the two-hole, last-field and rerun notes; table A rows 5 to 8 and 11 to 17, plus the `--round 4` refusal that was already there.
7. Criterion 7: babysit's existing sentences are unchanged; the new sentence is the same text in `babysit.md` and `babysit/SKILL.md`, with a matching patch and `SOURCES.md` items 4 and 12.

## Would break

## Fails open

## Not asked for

1. **`hole:` in prose on a Noted or Dismissed item is refused.** `holed()` matches `hole:` anywhere in the line and only excludes lines ending in `fixed:` or `ticket:`. A Noted item whose prose contains `hole:` before a trailing `cites:` gets the column G refusal, although the contract says "only the field that ends the line is a field". The refusal names the item, so the judge can fix it; it is stricter than the table.

```
A `hole:` beside `fixed:` or `ticket:` on one line: only the field that ends the line is a field
```

hard findings: 0
