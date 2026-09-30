## Walk

1. `review-brief.sh` resolves the fixed point, reads the PR author's review comments, and takes the round after the last `restart` comment.
2. It carries cited Noted and Dismissed items from that remaining history and writes both reviewer briefs, or a Standards brief alone when no spec exists.
3. The briefs ask each reviewer to tie counted findings to a `spec:` reference; the reviewers write their reports.
4. `review-comment.sh` checks report shape, counted items' documented steps and references, then the judgment's item references and `hole:` marks.
5. It omits valid holes from `act-on items:`, prints `restart`, and the Ticket playbook returns them to `architect` for an amended artifact and a new review series.
6. Babysit waits for a later comment without `restart` and with `act-on items: 0` before treating the PR as review-ready.

## Would break

1. **Standards-only hard findings cannot be reported.** The skill explicitly supports a review with no ticket or spec, but the new rule requires every Standards hard finding to cite a ticket table, design sketch, or acceptance checkbox. None exists on that documented path. A reviewer must invent a reference or `review-comment.sh` rejects the finding, preventing the review comment from being produced.
Documented step: `template/.agents/skills/spec-review/SKILL.md:38`: "If nothing is found, the **Spec** sub-agent skips and the report says, in these words, \"no spec: Standards axis only\"."
Result: A Standards `## Would break` or `## Fails open` item with a valid documented step but no ticket artifact is refused for lacking `spec:`.
spec: criterion 2

```
- [ ] Every Would-break and Fails-open item in both reports carries a `spec:` line naming what it rests on: `table <row>/<column>`, `design <signature>`, or `criterion <k>` (the k-th checkbox); `review-brief.sh` writes that rule into both briefs, and `review-comment.sh` refuses a counted item without it.
```

## Fails open

## Not asked for

hard findings: 1
