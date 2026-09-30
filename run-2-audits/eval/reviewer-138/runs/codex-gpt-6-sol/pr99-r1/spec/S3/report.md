## Walk

1. The skill and review ladder define a hole by whether its fix changes a table cell or term, a design sketch, or a criterion; the Ticket playbook sends that artifact back to architect.
2. `review-brief.sh` puts the `spec:` rule in both briefs; `review-comment.sh` refuses a counted report item without a valid reference after checking its documented step.
3. `review-comment.sh` validates an Act on item's trailing `hole:` against the judged report item, subtracts valid holes from the count, and prints `restart` before the round and count.
4. `review-brief.sh` drops the restart comment and all earlier comments before deriving the next round and settled items, so the redesigned work starts at round one.
5. `review-brief.sh` carries cited table cells, design signatures, and criteria from later Noted or Dismissed items into both briefs.
6. The Ticket playbook scopes architect Phase B to each marked artifact, records a dated amendment, rewrites tests before code, and reviews the redesign; babysit waits for a later comment without `restart`.

## Would break

## Fails open

## Not asked for

hard findings: 0
