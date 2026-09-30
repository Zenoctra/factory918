## Walk

1. Criterion 1: the design-hole definition is in the `SKILL.md` step 5 paragraph and in rung 1 of `review-ladder.md`, in the words the contract gives.
2. Criterion 2: `spec_rule` is echoed one blank line after `step_rule` in both briefs, and `SKILL.md` step 4 carries it word for word. `review-comment.sh` runs `stepless` with `^spec: $ref$` after the step check. Rows B2 to B4 are tested.
3. Criterion 3: `hole:` on an Act on item is checked for its placement, its form and its value against `specs()`. It is subtracted from the count, and `restart` prints before `round:`. Columns D to G and row 5 are tested.
4. Criterion 4: the reset awk keeps only the comments after the last `restart` line outside fences. The `restart:` line prints before `round:`, and the round refusal counts only the new series. The Design hole section and the step 8 pointer are in `ticket.md`. Rows A5 to A8 and A11 to A13 are tested.
5. Criterion 5: the fourth `cites:` alternative, `#[0-9]+ $ref`, carries. Rows A14 to A17 are tested.
6. Criterion 6: the listed cases are all in `tests/spec-review/`. All three suites pass (414, 134, ok), and `shellcheck -x` is clean.
7. Criterion 7: the babysit sentence is byte-identical in both files. The three patches apply to the pinned upstreams and reproduce the template files exactly.

## Would break

1. **A reason that mentions a hole in prose is refused.** `holed()` matches the substring `hole:` anywhere on a judgment line, not only as a trailing field. A Dismissed reason such as `Not a design hole: the table stands.` is refused with advice to move it to Act on, which is wrong. `whole:` also matches.
Documented step: `template/.agents/skills/spec-review/SKILL.md` step 5, "the reason is one line"
Result: a valid judgment is refused, and the message sends the judge to the wrong fix.
spec: table 1/G

```
G. `hole:` under `## Ask`, `## Consider`, `## Noted` or `## Dismissed`
```

## Fails open

2. **A `hole:` on its own line under the item is ignored.** `items()` reads only the numbered opening line, so a judgment that copies the report's form (`hole: table 2/D` on the line after the item) passes with no refusal. Reproduced: exit 0, no `restart` line, `act-on items: 1`. Babysit then treats the hole as a fix on the PR, which is the failure this ticket exists to stop.
Documented step: `SKILL.md` step 5, "it repeats the judged report item's `spec:` line word for word"
Result: no `restart`. The hole is counted as an ordinary Act on item and fixed on the PR.
spec: table 1/E

```
E. `hole:` fitting no form (`hole: table 2`, `hole: cell 12A`, `hole: criterion 0`, trailing text)
```

## Not asked for

hard findings: 2
