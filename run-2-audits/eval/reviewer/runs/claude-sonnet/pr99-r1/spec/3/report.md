## Walk

1. `review-brief.sh` slices the PR's comment history at the last comment whose stripped body has a line exactly `restart` outside fenced text, prints `restart:` when it cut anything, and computes round/settled from the sliced history only (table A).
2. `review-brief.sh` writes the `spec_rule` into both `standards-brief.md` and `spec-brief.md`, unconditionally, right after the step rule.
3. `review-comment.sh` refuses a Would-break/Fails-open item with no `spec:` line in the reference grammar (`report()`'s new `stepless "$f" "^spec: $ref\$"` check), and refuses a `hole:` field that is outside Act on, fits no form, or doesn't repeat the judged item's `spec:` word for word; a well-formed hole is subtracted from the count and prints `restart` before `round:`.
4. Prose (`SKILL.md`, `review-ladder.md`, `ticket.md`'s new Design hole section, `babysit.md`/`babysit/SKILL.md`) documents the design-hole definition and routes a restart back to `architect` before babysit.

## Would break

1. **`spec:` is mandatory even when there is no ticket to rest it on.** `report_rules()`'s `spec_rule` ("naming the artifact it rests on: `table <row>/<column>` for a cell of the ticket's scenario table... `design <signature>` for... its `## Design` sketch, or `criterion <k>` for its k-th acceptance checkbox") is written into `standards-brief.md` unconditionally — the `echo "$spec_rule"` in the standards block runs whether or not `$ticket`/`$spec` is set, and `report "$dir/standards-report.md" ...` in `review-comment.sh` enforces the same `spec:` line on every Would-break/Fails-open Standards item with no exception for a ticket-less run. But the "no spec: Standards axis only" path (`SOURCES.md` item 6, `SKILL.md` step 2.4) is documented as a normal, independent path: "without a ticket, a passed path or a spec file, the Spec axis skips and says 'no spec: Standards axis only'." In that path there is no ticket, so none of the three artifacts (scenario table, `## Design` sketch, acceptance criteria) exists for a Standards finding to cite. Every legitimate Standards Would-break/Fails-open item is then refused by `review-comment.sh` for lacking a `spec:` line the reviewer has no artifact to write.
Documented step: `SOURCES.md` item 6, "without a ticket, a passed path or a spec file, the Spec axis skips and says \"no spec: Standards axis only\""
Result: `review-comment.sh` refuses every counted Standards item in a ticket-less review with "has no 'spec:' line... Ask the reviewer for it," since no ticket artifact exists to name.
spec: criterion 2

## Fails open

## Not asked for

hard findings: 1
