# #107 todo
Ticket
- [x] 0 digest (.scratch/program/107/digest.md)
- [x] 1 up-to-date base; overlap.sh 107 -> base origin/feat/fix-only-from-round-two; branch feat/review-reading-pack
- [x] 2 read ticket (no comments, no parent)
- [x] 3 Blocked by: none
- [x] 4 falsifiability: c1 grep '## Reading pack' in briefs fails at HEAD; c2 no total cap exists; c3 Report lacks pack sentence; c4 no table/assertions; c5 SKILL.md step 4 lacks section. One concern (the pack).
- [x] 5 Feature playbook (below); blast radius: skip, the diff is not cross-cutting (no hooks, settings.json or factory918 skill path)
- [x] 6 table on #107 under ## Testing decisions before the writer; amended 2026-09-23 with a dated append for writer flags 2, 4, 5
- [x] 7 verify: every AGENTS.md "Verifying" line at head f58308b, CI green (run 35858370668)
- [x] 8 overlap --diff in the PR body; draft PR #126; round one at first push (comment 5794486013); round two running
- [ ] 9 babysit to STACK-READY; trail review done (trail-review.md)
Feature
- [x] 1 how: done in-lane (single 548-line script read whole by the owner; a lane would re-read the same file)
- [x] 2 architect: two runners (tier-upper, tier-lower), adversarial inputs run by both
- [x] 3 throughput checkpoint: blocking = table on the ticket before the writer; workstreams = script, test, SKILL.md+patch, all coupled by the word-for-word drift test, so one writer; shared state = the test file, one writer; smallest safe = one writer lane (tier-upper) in its own worktree
- [x] 4 writer lane (tier-upper, worktree), tests first; owner read reading-pack.sh whole and the review-brief, SKILL.md, SOURCES, factory918.sh diffs, spot-read the test diff, reran the test and ran the pack on origin/main (pack-origin-main.md)
- [x] 5 verify on the surface: real run over the whole stack; Linux proven only by CI
- [x] 6 small ordered commits (tests first, script, docs, records, CI fix, count fix)
- [x] 7 interrogate: skip, the design is not contested (two candidates converged on section, placement, sweep; differences settled by measurement)
- [x] 8 Opening a PR
