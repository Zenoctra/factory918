## Walk

1. Criterion 1: the definition is in SKILL.md step 5 and in review-ladder rung 1, both worded as the contract gives them.
2. Criterion 2: `spec_rule` is in both briefs, one blank line after the step rule. `review-comment.sh` checks `spec:` only when `spec-brief.md` exists.
3. Criterion 3: `hole:` is placed, parsed and compared with the item's `spec:`. It is left out of the count, and `restart` prints before `round:`.
4. Criterion 4: ticket.md has the Design hole section and the step 8 pointer. The restart slice passes rows A5 to A13 (414 assertions).
5. Criterion 5: the fourth `cites:` alternative carries items (rows A14 to A17).
6. Criterion 6: `tests/spec-review/review-comment.sh` fails at the reviewed commit.
7. Criterion 7: the two babysit sentences are byte-identical, and columns A to C pass.

## Would break

1. **Spec refusal skipped without a spec, so CI is red.** `review-comment.sh:116` returns before the `spec:` check when there is no `spec-brief.md`. The test's rows 2 to 4 run with no `spec-brief.md`.
Documented step: table B row 2, "refused before the judgment is read, in every column"; `.github/workflows/factory-ci.yml:25`
Result: the script gives the `judgment.md is missing` refusal. The test stops at "Fails-open item without a spec line, no judgment yet".
spec: table 2/A

```
refused before the judgment is read, in every column
```

2. **The column E and G refusal texts differ from the cells.** `review-comment.sh:178,181` add the value and a clause telling the judge to reword. With item 1 bypassed, 16 assertions still fail: 1E four times, 1G, G-before-E, 5E and 5G, in both layouts.
Documented step: table B cell 1E, "has a 'hole:' field that fits no form; it ends the line as ..."
Result: the text does not match, so the test fails.
spec: table 1/E

```
refused: `<dir>/judgment.md item '<N. **Title.**>' has a 'hole:' field that fits no form; it ends the line as ...
```

3. **The patch drifts from the template.** The template's SKILL.md has five passages the patch lacks: the no-spec sentence in step 4, the field-grammar and no-spec sentences in the `hole:` bullet, "in a review with a spec," and the no-spec `hole:` refusal clause. `./factory918.sh sync` reverts them.
Documented step: `AGENTS.md:45`, "`./factory918.sh sync` leaves `git status` clean."
Result: `M template/.agents/skills/spec-review/SKILL.md` after sync.
spec: criterion 3

```
refuses the mark on an item without a `spec:` reference, leaves it out of the count, and prints `restart`
```

## Fails open

4. **An unfenced `restart` line in a report resets the rounds.** `review-brief.sh:143` treats any bare `restart` line in the comment body as a restart, including one inside the pasted reports. A round-2 comment with no hole, whose report quotes the tail unfenced, gave `restart:`, `round: 1 of 3` and dropped its cited item.
Documented step: ticket Terms, "A 'restart comment' is a comment with a line that is exactly `restart` outside fenced text"
Result: the three-round cap resets and settled items drop, with no refusal.
spec: table 11/A

```
not a restart line: rows 2 to 4, no `X`
```

## Not asked for

5. **A no-spec mode for `spec:` and `hole:`.** Without a spec, the Standards brief leaves out the spec rule, `spec:` is not checked, and a `hole:` gets a new refusal. None of this is in table B.

```
`review-comment.sh` refuses a counted item without it.
```

hard findings: 4
