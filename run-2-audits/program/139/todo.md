# #139 todo
Ticket playbook
- [x] 0 digest (carried in the owner brief)
- [x] 1 up to date; overlap.sh 139 -> base origin/feat/unled-review-briefs; branch feat/unreadable-writer-flags at e710e99
- [x] 2 read ticket and comment
- [x] 3 Blocked by: PR #136 open; stacking is the go (autopilot-stack)
- [x] 4 falsifiability: c1 fails at HEAD (hyphenated, singular, quoted, fenced heading brief with exit 0); c2, c3 pass at HEAD by construction (regression guards); c4 is a review property
- [x] 5 Feature playbook; how = read the flag block of review-brief.sh directly (small)
- [ ] 6 scenario table on #139 under ## Testing decisions
- [ ] 7 verify
- [ ] 8 overlap --diff, Opening a PR (draft), review rounds
- [ ] 9 babysit, trail review
Feature
- [x] data shape: heading lines (line match) and item records (the disposed awk); guard = heads present and zero records
- skip: architect runners (one conditional, no new state; owner writes the table)
- skip: blast-radius (not a cross-cutting path)
- [ ] writer lane (tier-upper, worktree): tests commit first, then the script
- [ ] review diff, deslop
- [ ] verification lines from AGENTS.md the diff touches
