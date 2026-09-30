# #110 todo
- [x] Read poteto-mode Principles section in full
## Ticket playbook
- [x] 1. Up-to-date trunk (fetch origin; origin/main 86d156a), clean status, overlap.sh 110 -> base: origin/main; branch feat/provisional-ticket-ids
- [x] 2. Read the ticket (no parent, no CONTEXT.md/ADRs in this area)
- [x] 3. Blocked by: None
- [ ] 4. Falsifiability pass
- [ ] 5. Select playbook: Feature (new behavior: id scheme + duplicate refusal). how first. Cross-cutting? no (tools/, docs, ticket.md, spec-review scripts; no hooks/settings/factory918 skill) -> no blast-radius file
- [ ] 6. Scenario table (ticket demands it) on ticket under ## Testing decisions before implementation
- [ ] 7. Verify on matching surface
- [ ] 8. overlap.sh 110 --diff; Opening a PR
- [ ] 9. Babysit to merge-ready (STACK-READY per brief); never merge
## Feature playbook
- [ ] 1. how over build_knowledge.py, check_knowledge.py, DECISIONS.md Provisional, review-brief.sh cites grammar (inline)
- [ ] 2. architect: two runners (tier-upper, tier-lower), synthesize
- [ ] 3. Throughput checkpoint
- [ ] 4. Delegate to writer lane (tier-upper, worktree), review diff
- [ ] 5. Verify
- [ ] 6. Small ordered commits
- [ ] 7. interrogate if contested
- [ ] 8. Opening a PR
