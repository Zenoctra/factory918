## Walk

1. The skill and review ladder define a design hole by whether the fix changes a ticket artifact, and name the table, design sketch, and criteria.
2. `review-brief.sh` puts the `spec:` rule in both reviewer briefs; `review-comment.sh` checks counted items for that line after `Documented step:`.
3. `review-comment.sh` compares an Act on item's `hole:` reference with its report item's `spec:`, removes holes from the count, and prints `restart`.
4. `review-brief.sh` discards comments through the last restart comment, then derives the round and settled citations from those remaining.
5. The brief parser carries cited table cells, design signatures, and criteria into the next round.
6. The Ticket playbook sends a restart to scoped architect work and a dated ticket amendment; babysit waits for a later clean review comment.
7. The focused tests exercise the new reference forms, restart behavior, and unchanged no-hole output.

## Would break

1. **A mention of `hole:` in a judgment reason is rejected as a marker.** `holed()` selects any item line containing `hole:`, then rejects it unless the line ends in a valid mark. A normal one-line reason such as “The proposed hole: criterion 3 is an implementation bug; fix the code.” has no trailing field, but `review-comment.sh` exits 1 before printing the comment. I reproduced that refusal with a valid counted report item and judgment.
Documented step: Ticket #90, Table B notes: “only the field that ends the line is a field”.
Result: The review comment is refused although the Act on item has no `hole:` field.
spec: table 1/A

```
A `hole:` beside `fixed:` or `ticket:` on one line: only the field that ends the line is a field, counted per the last field
```

## Fails open

## Not asked for

hard findings: 1
