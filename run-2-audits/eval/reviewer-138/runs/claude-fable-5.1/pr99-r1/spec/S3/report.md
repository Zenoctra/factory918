## Walk

1. Criterion 1: the design-hole definition is in `SKILL.md` step 5 (the paragraph before "Four trailing fields") and in `review-ladder.md` rung 1, both word for word as the ticket's Prose section gives them.
2. Criterion 2: `spec_rule` is echoed one blank line after `step_rule` at both call sites; `review-comment.sh` calls `stepless` twice, the step refusal first, and refuses a counted item without `spec: <ref>` on its own line (table B rows 2 to 4, run by the tests).
3. Criterion 3: `holed()` finds `hole:` on Act on items, refuses placement, grammar, then value against `specs()`; `holes` is subtracted and `restart` prints after the summary, before `round:` (columns D to G, run by the tests).
4. Criterion 4: the Ticket playbook's step 8 pointer and `### Design hole` section carry the six steps the ticket wrote; `architect` has a Phase B that runs arena. `review-brief.sh` slices the history after the last `restart` line outside fenced text, prints the `restart:` line, then derives round and settled from the slice (rows A5 to A8, A11 to A13, run by the tests).
5. Criterion 5: `cites` gains `#[0-9]+ $ref` inside the `$`-anchored group (rows A14 to A17, run by the tests).
6. Criterion 6: `tests/spec-review/review-brief.sh` (414 assertions) and `review-comment.sh` (134) pass at this commit; `no-stale-wording.sh` passes with `Three trailing fields` blacklisted.
7. Criterion 7: the babysit paragraph and bullet are identical, and the existing merge-ready sentence is untouched.
8. The `ref=` line is identical in both scripts and `fragment()` holds them together; `review-brief.sh` reads no `hole:` and `review-comment.sh` reads no `cites:`.
9. `DECISIONS.md` P19 and P20 still define the count without `hole:`; the ticket leaves them to the owner's Provisional entry.

## Would break

## Fails open

## Not asked for

1. **`hole:` inside prose is read as a field.** `holed()` matches `hole:` anywhere on an Act on, Ask, Consider, Noted or Dismissed line that does not end in `fixed:`/`ticket:`. A reason such as `Not a design hole: the table stands. cites: DECISIONS.md P17` under Noted is refused as "carries a 'hole:' field under '## Noted'", and the same words under Act on as "fits no form", while `Not fixed: the code fails the cell` stays inert (hand run, exit 1 in both `hole:` cases). The contract asks for the field `$`-anchored like the two older ones; column E's "trailing text" is text after a field, not a field inside prose. The result is a refusal with a message, so the orchestrator can reword; nothing proceeds silently.

```
`review-comment.sh`, the judgment field on an Act on item's own line, `$`-anchored like `fixed:` and `ticket:`: `hole: $ref$`.
```

hard findings: 0
