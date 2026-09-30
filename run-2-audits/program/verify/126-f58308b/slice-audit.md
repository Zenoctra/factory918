# Slice: receipts-and-diff audit
Distrust the PR body and the owner's report. Read `git diff 0edf8c8..f58308b` whole and the ticket with its amendment:
1. Each of #107's acceptance criteria: file:line or unmet.
2. The table: one labeled assertion per cell (rows 1-27, both layouts); tests before script in commit order.
3. Scope: every file touched, grouped; anything outside the ask; vendored edits only through patches, in `series`,
   described in `SOURCES.md`. #127 (the owner's new ticket for three older pipelines): exists and says what it says.
4. Receipts: PR #126 comments: round 1 (5794486013) `act-on items: 0` with S1 marked `fixed: f58308b`, which per #125
   owes round 2; round 2 (5795119512) over the whole diff at f58308b, `act-on items: 0`. Run `review-brief.sh` against
   the real comment history through a fake gh fed the actual comments and quote its `round:` line, and check round two
   is correctly a whole-diff round (not fix-only) under #125's rule. CI green; `closingIssuesReferences` #107 only;
   base feat/fix-only-from-round-two.
5. PR body per `AGENTS.md` "Pull requests": plain-sentence title, problem then fix, `## Blast Radius` if cross-cutting
   (no `## ` inside), `## Overlap` before `## Verification`, outcomes, `Closes #107`, then the attribution, then the
   model-and-harness line last.
6. Forbidden edits; generated files match a rebuild.
7. The owner's Decided and Blocked items (the `.gitattributes` question, measuring the pack's value, the in-lane `how`
   without sign-off, the records commit not last): defect, judgment for Manuel, or nothing.
Report: `/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.scratch/program/verify/126-f58308b/worker-audit.md`.
