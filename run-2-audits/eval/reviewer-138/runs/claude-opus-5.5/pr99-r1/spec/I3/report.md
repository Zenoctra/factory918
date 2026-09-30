## Walk

1. Criterion 1: `SKILL.md` step 5 gains the design-hole paragraph and `review-ladder.md` rung 1 the sentence, both in the contract's wording.
2. Criterion 2: `review-brief.sh` echoes `spec_rule` one blank line after `step_rule` in both briefs; `review-comment.sh` `report()` runs `stepless` twice, the step check first, then `^spec: $ref$`, and refuses with table B row 2's message.
3. Criterion 3: `review-comment.sh` checks `hole:` placement (Ask to Dismissed), then grammar, then the value against `specs()` for the judged item; it subtracts `holes` from the count and prints `restart` before `round:`. A `hole:` before a trailing `fixed:`/`ticket:` is text, per the 2026-09-22 amendment.
4. Criterion 4: `ticket.md` step 8 points to the new `### Design hole` section (Phase B, two runners, a dated amendment, tests first, then round one). `review-brief.sh` cuts the history at the last exact `restart` line outside a fence, prints the `restart:` line, and derives the round and the settled items from what follows; the three-round refusal still fires before any output.
5. Criterion 5: `cites` gains `#[0-9]+ $ref` in the existing `$`-anchored group.
6. Criterion 6: I ran `tests/spec-review/review-comment.sh` (134 assertions), `review-brief.sh` (414) and `no-stale-wording.sh`; all pass. Table A rows 5 to 8 and 11 to 17 and table B rows 1 to 6 have assertions.
7. Criterion 7: the same `restart` sentence is added to `babysit.md` and `babysit/SKILL.md`. The three changed patches apply to the pinned upstream copies under `research/` and reproduce the template files byte for byte.
8. The `SKILL.md` step 1 paragraph describes the reset as the script implements it.

## Would break

1. **The Standards reviewer cannot write a true `spec:` line.** The spec rule reaches both briefs, but only the Spec brief carries the ticket (`review-brief.sh`, the `## The ticket (#$ticket)` block inside `if [ -n "$spec" ]`). The Standards brief says to read nothing beyond itself and names no scenario table, `## Design` sketch or criteria. So a Standards Would-break or Fails-open item must name a cell, signature or criterion it never saw. On the no-spec path (a sweep, or a diff whose commits name no ticket), no such artifact exists. Either way the reviewer invents a well-formed reference, `review-comment.sh` accepts it, and a `hole:` mark then matches that invented reference and scopes architect to it. The only honest alternative is to omit the line, which draws a refusal that has no correct answer.
Documented step: `template/.agents/skills/spec-review/SKILL.md:84`, "Then the spec rule, word for word" (step 4, common to both briefs), with `SKILL.md:86` "**The Standards brief** adds:" (standards and smells only) and `SKILL.md:38` "no spec: Standards axis only"
Result: a counted Standards finding carries a fabricated artifact reference that is accepted silently, or it is refused with no reference it could give.
spec: criterion 2

```
- [ ] Every Would-break and Fails-open item in both reports carries a `spec:` line naming what it rests on: `table <row>/<column>`, `design <signature>`, or `criterion <k>` (the k-th checkbox); `review-brief.sh` writes that rule into both briefs, and `review-comment.sh` refuses a counted item without it.
```

## Fails open

## Not asked for

hard findings: 1
