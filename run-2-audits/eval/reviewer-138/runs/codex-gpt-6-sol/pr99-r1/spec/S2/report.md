## Walk

1. The brief script reads the PR author's review comments, discards history through the last valid `restart` line, and derives the next round and settled citations.
2. It writes the same `spec:` reference rule into both reviewer briefs.
3. The comment script checks counted findings for a documented step and a valid `spec:` reference, then matches each judgment `hole:` mark to its report item.
4. It removes marked holes from the act-on count and prints one `restart` line before the round and final count.
5. The Ticket playbook sends a marked hole to architect, amends the ticket artifact, rewrites tests, and reviews the revised work from round one.
6. Babysit keeps a PR with a restart comment out of merge-ready until a later review comment has no restart line and zero act-on items.

## Would break

1. **Prose mentioning a hole is rejected as a mark.** `holed()` selects any judgment item containing `hole:`, even when that text is in the reason and no trailing field exists. A Noted item such as `1. [S1] **Breach.** The prose explains why a hole: reference is irrelevant here.` is refused as carrying a hole under Noted. The table says this is the no-mark case; only a field ending the line is a field.

```text
as today; a `spec:` line here is inert / 0
only the field that ends the line is a field
```

Documented step: Table B, row 5/A: a non-counted report item with no judgment mark proceeds as today.
Result: `review-comment.sh` exits 1 before printing the comment, saying the Noted item carries a `hole:` field.
spec: table 5/A

## Fails open

## Not asked for

hard findings: 1
