## Walk

1. `review-brief.sh <fixed-point>` fetches the PR author's comments carrying a line `act-on items:`, or reads `--previous FILE`.
2. The new awk between the fetch and the round derivation keeps only the comments after the last one holding a line that is exactly `restart` outside fenced text, prints the count cut, and sets `restarted`.
3. The round awk, the three-round refusal and `--round N` then run on the sliced history alone; the refusal still fires before any state is written.
4. Output order is `ticket:`, `restart: the round and the settled items count from the last restart comment`, `round: N of 3`, `settled: carried c, dropped d ...`, then the brief paths.
5. `cites:` gains a fourth alternative `#N <reference>` in the shared `ref=` grammar; `spec_rule` is echoed one blank line after `step_rule` in both briefs and carried word for word in `SKILL.md` step 4.
6. Each reviewer writes items under the axis headings; every `## Would break` and `## Fails open` item carries `Documented step:`, `Result:` and now `spec: <reference>`.
7. `review-comment.sh` checks each report's shape, numbering, count line and ceiling, then `Documented step:` via `stepless`, then `spec:` via the same scanner with the reference regex.
8. It then checks the judgment's shape, numbering, item count and `[S<n>]`/`[P<n>]` set, then a `hole:` outside Act on, a `hole:` fitting no form, and a `hole:` that is not word for word the judged item's `spec:` value.
9. It prints the reports, the judgment, the summary, `restart` when any Act on item carries `hole:`, `round: N of 3`, and `act-on items:` with `holes` subtracted beside `fixed_here` and `ticketed`.
10. Ticket playbook step 8 routes a `restart` comment to the new **Design hole** section; both babysit copies refuse merge-ready on such a comment; rung 1 of the review ladder and `SKILL.md` step 5 carry the definition.

## Would break

1. **A review with no ticket cannot finish.** `review-brief.sh`'s `report_rules()` writes `spec_rule` into the Standards brief unconditionally, and `review-comment.sh:114` refuses any Would-break or Fails-open Standards item without `spec:` in one of the three forms. All three forms are defined against a ticket ("a cell of the ticket's scenario table", "its `## Design` sketch", "its k-th acceptance checkbox"). On the documented no-spec path, and in the sweep form (`SKILL.md:29`), there is no ticket, so no form can be satisfied as written.

```
- [ ] Every Would-break and Fails-open item in both reports carries a `spec:` line naming what it rests on: `table <row>/<column>`, `design <signature>`, or `criterion <k>` (the k-th checkbox); `review-brief.sh` writes that rule into both briefs, and `review-comment.sh` refuses a counted item without it.
```

Documented step: `template/.agents/skills/spec-review/SKILL.md:38`, "If nothing is found, the **Spec** sub-agent skips and the report says, in these words, \"no spec: Standards axis only\"."
Result: the first Standards finding on a PR with no ticket dead-ends the round. The refusal says "Ask the reviewer for it", but the reviewer has no table, no sketch and no criteria to name; the only escape is `design <signature>`, whose grammar (`design [^[:space:]].*`) accepts arbitrary text, so the reference is invented rather than checked. No cell of table B covers a report with no ticket.
spec: criterion 2

## Fails open

## Not asked for

hard findings: 1
