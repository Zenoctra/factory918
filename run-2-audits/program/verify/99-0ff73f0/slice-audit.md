# Slice: receipts-and-diff audit
Distrust the PR body and the owner's report. Read `git diff 070c1fa..0ff73f0` whole (in file groups) and the ticket:
1. Each of the ticket's seven acceptance criteria (with their dated amendments) against the diff: file:line or unmet.
2. Tables A and B on ticket #90 (`## Testing decisions`, "Posted by the agent 2026-09-22", with amendments): one
   assertion per cell in `tests/spec-review/review-brief.sh` and `review-comment.sh`, named by row and column; the
   commit order shows tests before the script (`git log --reverse --format='%h %ad %s' --date=iso-strict 070c1fa..0ff73f0`).
   Any cell without an assertion, or an assertion the table does not say, is a finding.
3. The restart on this PR's own round one: the two design holes the owner reports, what changed in the table (the
   dated amendments), the "restart" comment 5780539782, and that the review count restarted (round 1 then round 2
   after it, ending at `act-on items: 0`). Confirm the holes were fixed by returning to architect (the ticket's
   amendments and the `.scratch/program/90/architect/` artifacts), not on the PR silently.
4. The rebase delta: compare `git diff 69bd412..384bb43` (pre-rebase patch) with `git diff 070c1fa..0ff73f0` file by
   file; every difference must be a conflict resolution against #94's and #96's content (SOURCES.md, the ledger,
   DECISIONS P26->P27 and the P20 clause, generated files, shellcheck directive lines). Anything else is an issue.
   Confirm no line of #96's own diff (`git diff 715100c..070c1fa`) was lost in the files both touch.
5. Scope: every file the diff touches, grouped; anything outside the ticket's ask flagged. This ticket's ask is the
   design-hole route; it must not implement #91's walk rule or #93's fix-only rounds.
6. Receipts: the review comments on PR #99 by the author's account, their `round:` and `act-on items:` lines and the
   `restart` comment, in order with timestamps; the fix commits between; `gh pr view 99 --json
   headRefOid,baseRefName,mergeable,isDraft,closingIssuesReferences` (closing reference #90 only).
7. PR body shape per `AGENTS.md` "Pull requests" at the SHA: plain-sentence title, problem then fix, `## Blast Radius`
   if the diff is cross-cutting (does it touch `template/.claude/hooks/`, `.claude/settings.json` or the factory918
   skill? say), `## Overlap` before `## Verification`, Verification with outcomes, `Closes #90` last before the
   attribution, attribution, model-and-harness line.
8. Forbidden edits: nothing hand-edited under `docs/knowledge/spec/`, `pages/`, `notes/`, `research/`; generated
   files match a rebuild.
9. The owner's report `## Attention` items, if any: defect, judgment for Manuel, or nothing. Also: another lane
   (ticket #91's owner) retargeted this PR to `main` and back for eight seconds to get GitHub to link `Closes #90`;
   confirm from the PR timeline that the base is `feat/shellcheck` now and the head was never changed by that.
Report: `/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.scratch/program/verify/99-0ff73f0/worker-audit.md`.
