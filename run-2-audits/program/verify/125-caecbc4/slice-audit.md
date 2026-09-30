# Slice: receipts-and-diff audit
Distrust the PR body and the owner's report. Read `git diff 01a1e5f..caecbc4` whole and the ticket:
1. Each of #106's seven acceptance criteria: file:line or unmet. Criterion 2 says "once a round is fix-only every later
   round is"; the owner says that takes no code because only round three is decided. Judge.
2. The scenario table on #106: one labeled assertion per cell, named by row and column; tests before scripts.
3. Scope: every file touched, grouped; anything outside the ask; vendored edits only through patches, listed in
   `series`, described in `SOURCES.md`.
4. Receipts: PR #125 comments. One voided comment (5792617219) that first held another PR's review text: confirm it now
   carries no `act-on items:` and no `restart` line and that `review-brief.sh` ignores it (run it against the PR's real
   comment history via a fake gh fed the actual comments). The real round one (5792623153): `act-on items: 0`,
   reviewed caecbc4. CI green; `gh pr view 125 --json headRefOid,baseRefName,mergeable,isDraft,closingIssuesReferences`
   (#106 only; base feat/reviewer-model-eval).
5. PR body per `AGENTS.md` "Pull requests" at the SHA: plain-sentence title, problem then fix, `## Blast Radius` if
   cross-cutting (no `## ` inside), `## Overlap` before `## Verification`, outcomes, `Closes #106` last before the
   attribution, attribution, model-and-harness line.
6. Forbidden edits: nothing hand-edited under generated or vendored paths; generated files match a rebuild.
7. The owner's Decided and Blocked items, especially the location rule (P106) and its accepted false-inside: defect,
   judgment for Manuel, or nothing. Would a later round-two hard finding in unchanged code whose quoted text coincides
   with a fix line wrongly skip the whole-diff round three? How likely, with an example.
Report: `/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.scratch/program/verify/125-caecbc4/worker-audit.md`.
