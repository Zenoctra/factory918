# #137 todo
- [x] Read Principles (poteto-mode SKILL.md)
Ticket playbook
- [x] 0. digest: carried in the owner brief and the launch prompt (poll rule, Closes link rule, no-run=conflict, body-file replaces)
- [x] 1. up-to-date trunk, clean checkout, overlap.sh 137 (base printed origin/feat/eco-tier; root override to origin/feat/risk-dispositions 6e5c539)
- [x] 2. read ticket (no parent) and audit sections 1-3
- [x] 3. Blocked by: #108 open; root stacks this on its PR #136 (override)
- [x] 4. falsifiability: each criterion fails at HEAD (phrases present at review-brief.sh:483,506,504,594,630; SKILL.md:77,81,88,99,110,118; P18; review-ladder.md:6; no-stale-wording lacks them; no fails-open line)
- [x] 5. select Feature (changed behavior of the review briefs). Not cross-cutting (review-brief.sh predicate: no hooks/settings/factory918 path) so no blast-radius
- [x] 6. testing decisions: skip: prose change, no artifact
- [x] 7. verify
- [x] 8. overlap --diff, Opening a PR, review rounds
- [x] 9. babysit to STACK-READY; trail review
Feature playbook
- [x] 1. how: skip: the audit report gives file:line of every line and its provenance; the change is wording
- [x] 2. architect skipped: prose-only change, no function boundary, no new state
- [x] 3. checkpoint: blocking first = branch + decide exact wording (owner); independent workstreams n/a: one file set sharing one test; shared mutable state: writer owns code/test/patch, owner owns DECISIONS.md P18 record commit; smallest decomposition: one writer, because every edit is held word for word by one test
- [x] 4. delegate to one tier-upper writer in a worktree
- [x] 5. verify
- [x] 6. ordered commits
- [x] 7. interrogate: skip: not contested, Manuel settled the list
- [x] 8. Opening a PR
