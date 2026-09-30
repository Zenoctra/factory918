# Slice: receipts-and-diff audit
Distrust the PR body and the owner's report. Read `git diff d8e382c..fc75ac6` whole and the ticket:
1. Each of the ticket's six acceptance criteria against the diff: file:line or unmet.
2. The `## Testing decisions` tables on ticket #93 (with the round-one amendment): one assertion per cell in
   `tests/spec-review/review-brief.sh` and `review-comment.sh`, named by row and column; commit order shows tests
   before the scripts (`git log --reverse --format='%h %ad %s' --date=iso-strict d8e382c..fc75ac6`). Any cell without
   an assertion, or an assertion the table does not say, is a finding. Say what the amendment changed and whether it
   was a design hole handled per #99's rule (return to architect, "restart" comment) or a criterion re-derivation;
   the owner says no restart happened.
3. Scope: every file the diff touches, grouped; anything outside the ticket's ask flagged. It must not alter #99's
   restart logic or #101's walk rule beyond what the fix-only rounds need.
4. Receipts: two review comments on PR #102 by the author's account, `round: 1 of 3` and `round: 2 of 3`, both
   `act-on items: 0`; round one's Standards items marked `fixed: fc75ac6`; round two reviewed fc75ac6; CI at both
   heads; `gh pr view 102 --json headRefOid,baseRefName,mergeable,isDraft,closingIssuesReferences` (#93 only).
   The owner says round one's comment wrongly claimed the review could end there and round two ran to correct it:
   judge whether that is the rule applied correctly (a non-hard fix is unreviewed only from round three).
5. PR body shape per `AGENTS.md` "Pull requests" at the SHA: plain-sentence title, problem then fix, `## Blast
   Radius` if cross-cutting (say whether the diff touches hooks, settings or the factory918 skill), `## Overlap`
   before `## Verification`, Verification with outcomes, `Closes #93` last before the attribution, attribution,
   model-and-harness line.
6. Forbidden edits: nothing hand-edited under `docs/knowledge/spec/`, `pages/`, `notes/`, `research/`; generated
   files match a rebuild.
7. The owner's `## Decided` and `## Blocked` items (P30, the draft as the round-five mark via `gh pr ready --undo`,
   not exercised on a real PR): defect, judgment for Manuel, or nothing.
Report: `/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.scratch/program/verify/102-fc75ac6/worker-audit.md`.
