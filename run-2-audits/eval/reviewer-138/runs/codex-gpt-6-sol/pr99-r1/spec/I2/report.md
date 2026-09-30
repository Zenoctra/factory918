## Walk

1. `spec-review` finds a ticket or runs the Standards axis alone.
2. `review-brief.sh` reads prior author comments, cuts history after the last `restart`, and builds both briefs.
3. Reviewers write findings with `Documented step:`, `Result:`, and `spec:` lines.
4. `review-comment.sh` validates the reports and judgment, excludes marked holes from the count, and prints `restart`.
5. The Ticket playbook sends each hole to `architect`, amends the artifact, and redoes tests before code.
6. The next brief starts at round one; babysit waits for a later comment without `restart` and with `act-on items: 0`.

## Would break

1. **A standards-only finding has no reference to name.** The new `spec:` gate requires a ticket artifact even when the documented review path has no spec. A Standards reviewer with a valid Would-break finding must invent a table, design, or criterion reference or have the report rejected.
Documented step: `template/.agents/skills/spec-review/SKILL.md:38`, "If nothing is found, the **Spec** sub-agent skips and the report says ... 'no spec: Standards axis only'."
Result: `review-comment.sh` refuses the truthful Standards report, so that review cannot complete.
spec: criterion 2

```
Every Would-break and Fails-open item in both reports carries a `spec:` line naming what it rests on: `table <row>/<column>`, `design <signature>`, or `criterion <k>`
```

2. **Title text is mistaken for a hole mark.** `holed()` searches the entire judgment line for `hole:`. An unmarked item titled `**Design hole: unclear contract.**` is rejected as a malformed or misplaced field, although only a trailing field is a mark.
Documented step: Ticket #90, table B row 1/A, "as today; counted / 0 / fix on the PR, unchanged".
Result: `review-comment.sh` exits 1 before printing the comment for a valid no-mark judgment.
spec: table 1/A

```
only the field that ends the line is a field
```

## Fails open

## Not asked for

hard findings: 2
