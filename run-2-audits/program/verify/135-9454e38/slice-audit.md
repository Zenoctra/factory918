# Slice: receipts-and-diff audit
Distrust the PR body and the owner's report. Read `git diff a9ebdac..9454e38` whole and the ticket:
1. Each of #109's five criteria: file:line or unmet.
2. Tables A, B, C on #109: one assertion or walked proof per cell; tests before behavior.
3. Scope, grouped; vendored edits only through patches. Manuel ruled on 2026-09-23 that upstream pstack wording stays
   (ticket #137): does this PR change any upstream sentence beyond what the eco rule needs?
4. Receipts: review rounds on PR #135 through round four, each act-on item marked fixed at a named commit; round four
   `act-on items: 0`; check the round count with `review-brief.sh` over the real comment history through a fake gh.
   CI green; `closingIssuesReferences` #109 only.
5. PR body per `AGENTS.md` "Pull requests": title, problem then fix, `## Blast Radius` (no `## ` inside), `## Overlap`
   before `## Verification`, outcomes, last three lines `Closes #109`, the attribution, `Claude Opus 5.5 on Claude Code`.
6. Forbidden edits; generated files match a rebuild.
7. Leading-witness check (Manuel, ticket #137): quote any new sentence this PR adds to a judging lane's brief (the
   trail review's launch count, the adversarial judge) that primes a result, caps output, or limits reading.
8. The owner's Decided and Blocked items (the extra drops; the skipped `interrogate` in safe mode; the silent worktree
   tier file): defect, judgment for Manuel, or nothing.
Report: `/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.scratch/program/verify/135-9454e38/worker-audit.md`.
