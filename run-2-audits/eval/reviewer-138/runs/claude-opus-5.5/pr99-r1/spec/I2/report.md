## Walk

1. Criterion 1: SKILL.md step 5 carries the design-hole paragraph as the contract words it; review-ladder.md rung 1 carries the shorter contract sentence.
2. Criterion 2: `spec_rule` is echoed one blank line after `step_rule` in both briefs; `stepless "$f" "^spec: $ref\$"` refuses a counted item without a well-formed, unfenced `spec:` line, after the step check.
3. Criterion 3: `holed()` finds `hole:` on lines not ending in `fixed:`/`ticket:`; placement, form and word-for-word value are refused in that order; `holes` is subtracted and `restart` printed before `round:`.
4. Criterion 4: review-brief.sh's awk cuts every comment up to the last one holding an unfenced `restart` line and prints the `restart:` line; ticket.md gains step 8's pointer and `### Design hole`; both babysit files gain the sentence.
5. Criterion 5: `cites:` gains `#[0-9]+ $ref`; rows 14 to 17 tested.
6. Criterion 6: all listed cases are asserted; the three suites pass here (414, 134, ok).
7. Criterion 7: the two babysit sentences are byte-identical, and the three changed patches applied to the research pins reproduce the template files exactly.

## Would break

1. **The Standards reviewer must name a ticket artifact it is never shown.** The spec rule reaches the Standards brief, but `common()` and the Standards block paste no ticket, and the brief says "Read nothing beyond this brief". With no ticket at all (no spec axis), no table, sketch or criterion exists. A genuine Standards finding either gets a made-up reference, which a later `hole:` must then repeat, or is refused with no way to correct it.
Documented step: `template/.agents/skills/spec-review/scripts/review-brief.sh`, the Standards brief: "The same item carries a line `spec:` naming the artifact it rests on: `table <row>/<column>` for a cell of the ticket's scenario table"
Result: the Standards reviewer cannot comply honestly; the gate accepts any well-formed reference.
spec: criterion 2

```
- [ ] Every Would-break and Fails-open item in both reports carries a `spec:` line naming what it rests on
```

2. **The manual calls a mid-restart PR ready.** When every Act on item is a hole, the comment ends `restart` / `act-on items: 0`. MANUAL.md's readiness list still reads only the last line, so a person following it sees a ready PR, which the ticket says is never merge-ready. The ticket's Files touched excludes MANUAL.md from the writer, so this may belong to the owner.
Documented step: `docs/knowledge/core/MANUAL.md:103`, "`spec-review`'s last line on the latest commit reads `act-on items: 0`"
Result: a PR returned to architect passes the human's merge checklist.
spec: criterion 4

```
A PR mid-restart is never merge-ready.
```

## Fails open

## Not asked for

hard findings: 2
