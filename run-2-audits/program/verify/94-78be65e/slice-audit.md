# Slice: receipts-and-diff audit

Distrust the PR body and the owner's report. Read the actual diff `git diff ab47eb9...78be65e` (it is
yours to read whole) and the ticket, and check:
1. Each of the ticket's six acceptance criteria against the diff: name the file:line that satisfies it or
   say it is unmet. The report claims criterion 3 was placed in Ticket step 6 because the playbook has no
   architect step; judge whether that satisfies the criterion's intent or dodges it.
2. Scope: one concern per PR. List every file the diff touches and flag anything outside the ticket's ask
   (the report admits a two-token change to `overlap.sh` plus a test cell, a P24 amendment, an amendment
   of closed ticket #42's body, a new core document, ledger and M0 lines). Say for each whether it belongs.
3. Receipts: the two review comments on PR #94 exist, are by the PR author's account, end with
   `act-on items: 5` and `act-on items: 0`, carry `round: 1 of 3` and `round: 2 of 3`, and the four fix
   commits the report names exist between the rounds. Commit 78be65e is claimed unreviewed: confirm and
   list exactly what it changes.
4. PR body shape per `AGENTS.md` "Pull requests": plain-sentence title, problem then fix, `## Overlap`
   before `## Verification`, `## Verification` naming what ran and its outcome, `Closes #89` as the last
   line before the attribution, and the attribution line. Note anything missing.
5. Forbidden edits: nothing under `docs/knowledge/spec/`, `pages/`, `notes/`, `research/` was hand-edited
   (generated files may change only as `build_knowledge.py` output; say whether `template/docs/factory918/`
   changes match a rebuild).
6. The `## Attention` items in the owner's report at
   `/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.scratch/program/89/report.md`:
   for each, say whether it is a defect in this PR, a judgment for Manuel, or nothing.
Report file: `/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.scratch/program/verify/94-78be65e/worker-audit.md`.
