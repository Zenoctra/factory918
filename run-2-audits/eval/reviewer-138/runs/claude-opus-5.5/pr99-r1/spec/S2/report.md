## Walk

1. Criterion 1: `spec-review/SKILL.md` step 5 gains the design-hole paragraph before the trailing-fields list, and `review-ladder.md` rung 1 gains the sentence after "An Ask item waits for the human.". Both match the contract's text.
2. Criterion 2: `review-brief.sh` defines `spec_rule` and echoes it one blank line after `$step_rule` in both briefs, and `SKILL.md` step 4 carries it word for word. `review-comment.sh` `report()` refuses a counted item with no `^spec: $ref$` line after the `Documented step:` check. A fenced `spec:` line does not count.
3. Criterion 3: `review-comment.sh` refuses a `hole:` outside Act on, then an Act on `hole:` that fits no form, then one that differs from the report item's `spec:` value as `specs()` reads it (5D when the item is not counted). It subtracts `holes` from the count and prints `restart` before `round:`.
4. Criterion 4: `review-brief.sh` keeps only the comments after the last line that is exactly `restart` outside a fence and prints the `restart:` line between `ticket:` and `round:`. The round, the settled set and the fourth-round refusal all read the sliced history. Ticket step 8 points to the new `### Design hole` section, and both babysit files carry the restart sentence.
5. Criterion 5: `cites` gains the alternative `#[0-9]+ $ref`, still anchored with `$`. Rows 14 to 16 carry and row 17 drops.
6. Criterion 6: the tests cover every case the contract lists. Locally, `tests/spec-review/review-comment.sh` passes 134 assertions, `review-brief.sh` passes 414 and `no-stale-wording.sh` passes.
7. Criterion 7: the existing merge-ready sentences in both babysit files do not change, and the new sentence applies only to a comment with a `restart` line. I applied the three changed patches to the pinned upstreams under `research/`, and each result is identical to its template file.
8. `SOURCES.md` items 4, 6 and 12 describe the additions.

## Would break

1. **The Standards reviewer must cite a ticket artifact that its brief never shows it.** `review-brief.sh` echoes `$spec_rule` into `standards-brief.md` (`review-brief.sh:360`). `common()` never includes the ticket, so that brief has no scenario table, no `## Design` sketch and no acceptance criteria. The brief also says "Read nothing beyond this brief ... Run nothing." A Standards Would-break or Fails-open item rests on a documented standard, not on a ticket cell. The reviewer still has to write `spec: table …`, `design …` or `criterion k`, or `review-comment.sh` refuses the report. With no ticket at all (`no spec: Standards axis only`, `SKILL.md:38`), no valid reference exists. I reproduced this in a temp repo: `review-brief.sh HEAD~1 --previous <empty file>` wrote a Standards brief that carries the spec rule and has no ticket, criteria or Testing decisions section.
Documented step: `template/.agents/skills/spec-review/SKILL.md:84`, "Then the spec rule, word for word: "The same item carries a line `spec:` naming the artifact it rests on …""
Result: every counted Standards finding carries a reference the reviewer guessed. The refusal cannot tell a guess from a real reference, and the `hole:` check accepts it word for word. A hole on a Standards item then sends `architect` to an arbitrary cell or criterion. In a no-ticket review, the only other choice is a refusal loop the reviewer cannot satisfy.
spec: criterion 2

```
- [ ] Every Would-break and Fails-open item in both reports carries a `spec:` line naming what it rests on: `table <row>/<column>`, `design <signature>`, or `criterion <k>` (the k-th checkbox); `review-brief.sh` writes that rule into both briefs, and `review-comment.sh` refuses a counted item without it.
```

## Fails open

## Not asked for

hard findings: 1
