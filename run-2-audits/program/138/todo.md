# #138 todo (Ticket playbook, then Feature, then Opening a PR)
- [x] Read poteto-mode Principles
- [x] Ticket 0 digest: carried in the owner brief
- [x] Ticket 1 overlap.sh 138: base origin/feat/eco-tier; root override to origin/feat/unled-review-briefs (e710e99)
- [x] Ticket 2 read #138 (and the audit report)
- [x] Ticket 3 Blocked by #137: PR #140 verified by root, merging now
- [x] Ticket 4 falsifiability: criteria 1-2 fail at HEAD (P103 unmarked, briefs carry Risks); 3 fails (runs medium); 4-5 fail (no arms)
- [ ] Ticket 5 -> Feature
  - [ ] F1 how: skip: I read reviewer.py whole and the audit; the subsystem is one file
  - [ ] F2 architect: skip: audit 5c is the design; design sketch posted to the ticket under ## Design; not cross-cutting
  - [ ] F3 throughput checkpoint (below)
  - [ ] F4 delegate writer (tier-upper, worktree) + ground-truth lane (tier-upper, read-only)
  - [ ] F5 verify: reviewer.py check, refusals.sh, masked subsets apply, pilot (BLOCKED on effort)
  - [ ] F6 ordered commits
  - [ ] F7 interrogate: skip: not contested
  - [ ] F8 Opening a PR
- [ ] Ticket 6 design artifact on ticket (## Design)
- [ ] Ticket 7 verify
- [ ] Ticket 8 overlap --diff, open draft PR (base main if #140 merged)
- [ ] Ticket 9 spec-review rounds, trail review
- [ ] Records: P103 void line, M0 void line, P138 (after the run)
- [ ] Report

Throughput checkpoint
- Blocking first steps: effort high must be proven before any run (blocked: needs a new session).
- Independent workstreams: ground truth (reading) and runner/briefs (writing) are disjoint files.
- Shared mutable state: tests/eval/reviewer/truth is written by the GT lane to scratch; the writer reads a format only; I merge.
- Smallest safe decomposition: one writer for reviewer.py + fixtures (one file set, coupled).
