## Walk

1. `review-brief.sh` fetches the author's `act-on items:` comments, cuts the history at the last line that is exactly `restart` outside a fence, prints `restart: ...` after `ticket:`, and takes the round and the settled set from what follows; `--round` still overrides and a fourth post-restart round is refused before any state (table A rows 5-8, 11-13 run in `tests/spec-review/review-brief.sh`, 414 assertions pass).
2. `cites: #N table <r>/<c>`, `#N design <sig>`, `#N criterion <k>` carry as settled; malformed cites are dropped and counted (rows 14-17 pass).
3. Both briefs carry the spec rule one blank line after the step rule, and `SKILL.md` step 4 holds its word-for-word twin; `fragment()` holds the two `ref=` lines together.
4. `review-comment.sh` refuses a counted item with no `spec:` in the grammar, after the `Documented step:` check and before the judgment is read (table B rows 2-4, 134 assertions pass).
5. A `hole:` outside Act on, in no form, or differing from the item's `spec:` is refused in that order; a valid one prints `restart` before `round:` and is left out of the count; the field ending the line wins (columns D-G, rows 5-6, the notes).
6. Prose: `SKILL.md` step 5 definition and fourth field, step 6 count, rung 1, the Ticket playbook's Design hole section and step 8 pointer, the byte-identical babysit sentence in both files; the three patches re-apply to the pinned upstreams and reproduce the template copies; `SOURCES.md` items 4, 6, 12 updated; `no-stale-wording.sh` and ShellCheck clean.

## Would break

1. **A Standards-only review cannot pass a hard finding.** The spec rule is written into the Standards brief unconditionally (`review-brief.sh:360`), and `review-comment.sh` refuses every counted Standards item without a `spec:` naming a cell, signature or criterion of "the ticket". On the documented no-ticket paths there is no ticket to name, so the review is stuck at the refusal or the reviewer invents a reference.
Documented step: `template/.agents/skills/spec-review/SKILL.md:38`, "If nothing is found, the **Spec** sub-agent skips and the report says, in these words, "no spec: Standards axis only"", and `:29`, "A sweep over units already on `main` ... is the same skill with the same state"
Result: with one Would-break Standards item and no ticket, `review-comment.sh` answers `has no 'spec:' line ... Ask the reviewer for it` on every rerun; no comment, no `act-on items:` line, babysit never sees the PR as reviewed.
spec: criterion 2

```
- [ ] Every Would-break and Fails-open item in both reports carries a `spec:` line naming what it rests on: `table <row>/<column>`, `design <signature>`, or `criterion <k>` (the k-th checkbox); `review-brief.sh` writes that rule into both briefs, and `review-comment.sh` refuses a counted item without it.
```

## Fails open

## Not asked for

hard findings: 1
