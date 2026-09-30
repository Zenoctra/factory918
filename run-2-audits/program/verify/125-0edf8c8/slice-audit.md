# Slice: receipts-and-diff audit
Distrust the PR body and the owner's report. Read `git diff 01a1e5f..0edf8c8` whole and the ticket with its amendment:
1. Each of #106's seven criteria: file:line or unmet. The amended Terms and tables versus Manuel's quoted intent in the
   ticket ("at least one pass goes with zero new happy path hard bugs found before we commit ourself to diff only
   reviews"): does the new rule honor it? Say where it could still fail open.
2. Tables: one labeled assertion per cell, or the one-line reason (6B, 6C, 20B, 20C, 21B) on both the ticket and in
   the test; judge each reason. Tests before scripts for both waves (7b7d1fb before aa155fc, 8fd83e1 before f33a08a).
3. The Design hole route per the Ticket playbook at the SHA: `restart` comment (5792876117) with a `hole:` mark, ticket
   amended with a dated line, rounds restarted (5793367657 round one, `act-on items: 0`, reviewed 0edf8c8). Does
   `review-brief.sh`, run against the PR's real comment history through a fake gh fed the actual comments, count the
   rounds correctly (the voided 5792617219 ignored, the restart honored)? Quote its `round:` line.
4. Scope; vendored edits only through patches, in `series`, described in `SOURCES.md`.
5. PR body per `AGENTS.md` "Pull requests" at the SHA: `Closes #106`, then the attribution, then the model-and-harness
   line last; `## Overlap` before `## Verification`; outcomes; `closingIssuesReferences` #106 only; base
   feat/reviewer-model-eval; CI green at the head.
6. Forbidden edits; generated files match a rebuild.
7. P106 as written matches the code (quote both); the owner's Decided items: defect, judgment for Manuel, or nothing.
Report: `/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.scratch/program/verify/125-0edf8c8/worker-audit.md`.
