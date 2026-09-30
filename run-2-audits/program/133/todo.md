# #133 todo
- [x] Read poteto-mode Principles in full (loaded with the skill)

Ticket
- [ ] 0. Digest at .scratch/program/133/digest.md
- [x] 1. overlap.sh 133 -> base origin/feat/trail-clock; branch feat/fix-only-no-hard-item
- [ ] 2. Read the ticket (+ #106, P106, verify reports)
- [ ] 3. Blocked by: None
- [ ] 4. Falsifiability pass
- [ ] 5. Select playbook: Feature. Cross-cutting check
- [ ] 6. Testing decisions: #106's table as amended; post changed cells on #133 before tests
- [ ] 7. Verify
- [ ] 8. overlap --diff, Opening a PR, review rounds
- [ ] 9. Babysit to merge-ready; trail review

Feature
- [ ] 1. how over spec-review scripts
- [ ] 2. architect (or skip with reason)
- [ ] 3. throughput checkpoint (4 items)
- [ ] 4. delegate writer (tier-upper, worktree)
- [ ] 5. verify on surface
- [ ] 6. ordered commits
- [ ] 7. interrogate if contested
- [ ] 8. Opening a PR

Throughput checkpoint (Feature step 3)
- Blocking first steps: changed cells posted on #133 (done), #106 amended (done).
- Independent workstreams: n/a: scripts, tests and prose patches describe one rule and share the patch regeneration; one writer.
- Shared mutable state: the writer works on wt/133-writer in its own worktree; I only fast-forward.
- Smallest safe decomposition: one writer (tier-upper), tests commit before scripts commit, prose commit after; records commit mine.
Status: digest done; falsifiability: all 5 criteria fail at HEAD (2B asserts FO for inside items; grep fix-ranges hits; #106/P106/SKILL.md unamended).
