# Slice: receipts-and-diff audit
Distrust the PR body and the owner's report. Read `git diff a9ebdac..6e5c539` whole and the ticket:
1. Each of #108's criteria: file:line or unmet.
2. Tables A, B, C on #108: one labeled assertion per cell; tests before script.
3. Scope, grouped; vendored edits only through patches. Does the new blast-radius patch change upstream's wording
   beyond the disposition line? Manuel ruled on 2026-09-23 that upstream pstack's wording stays as it is.
4. Receipts: PR #136 comments (round one `act-on items: 0`); does this PR owe a round two under #106's rule? Check with
   `review-brief.sh` over the real comment history through a fake gh. CI green; `closingIssuesReferences` #108 only.
5. PR body per `AGENTS.md` "Pull requests": title, problem then fix, `## Blast Radius` if cross-cutting (no `## `
   inside), `## Overlap` before `## Verification`, outcomes, last three lines `Closes #108`, the attribution,
   `Claude Opus 5.5 on Claude Code`.
6. Forbidden edits; generated files match a rebuild.
7. Leading-witness check: Manuel ruled on 2026-09-23 that reviewer briefs must not prime a result, cap output, or limit
   reading (ticket #137). Quote any new brief sentence this PR adds that does any of those.
8. The owner's Decided and Blocked items (S1 unclosed fence; the rebase-sha hole in P108): defect, judgment for
   Manuel, or nothing.
Report: `/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.scratch/program/verify/136-6e5c539/worker-audit.md`.
