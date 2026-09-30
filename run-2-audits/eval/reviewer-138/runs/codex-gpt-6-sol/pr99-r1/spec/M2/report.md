## Walk

1. The skill and review ladder define a design hole against the table, design sketch, or acceptance criterion, with ticket intent governing a changed criterion.
2. `review-brief.sh` puts the `spec:` rule in both reviewer briefs; `review-comment.sh` rejects counted items without a valid reference.
3. `review-comment.sh` checks an Act on item's `hole:` against its report reference, excludes the hole from the act-on count, and prints `restart`.
4. The Ticket playbook sends a marked hole to architect Phase B, amends the ticket artifact, rewrites tests, and reviews the redesigned work on the open PR.
5. `review-brief.sh` starts the round and settled-item history after the last restart comment and retains cited decisions from later comments.
6. The citation grammar carries table cells, design signatures, and criteria into later briefs; the targeted suites exercise these forms and the restart paths.
7. Babysit requires a later review comment without `restart` and with `act-on items: 0` before treating the PR as review-ready.

## Would break

## Fails open

## Not asked for

hard findings: 0
