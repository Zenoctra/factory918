# Slice: receipts-and-diff audit
Distrust the PR body and the owner's report. Read the non-fixture diff whole (`git diff 86d156a..858974e --
':!tests/eval/reviewer/rounds'`), sample the fixture tree, and read the ticket:
1. Each acceptance criterion of #103 against the diff: file:line, unmet, or waived-pending-Manuel (criterion 3's
   matrix rows: the owner added notes instead; say whether the notes carry the same facts and whether the matrix
   test really forbids a fifth family, quoting it).
2. The posted design (and its 2026-09-23 amendment): one assertion in `refusals.sh` per design cell, named; tests
   before the runner in commit order (`git log --reverse --format='%h %ad %s' --date=iso-strict 86d156a..858974e`).
   Was the round-one restart handled per the Design hole section of `ticket.md` (return to architect, "restart"
   comment, rounds restart)?
3. Scope: every non-fixture file touched, grouped; anything outside the ask flagged. The model rule of 2026-09-22
   (never launch Fable; upper tier Opus 5.5, lower tier Opus 5): check the committed records and the proposed sheet
   change do not contradict it.
4. Receipts: the five review comments on PR #124 (round 1 restart, restarted round 1, round 2, round 3 with a
   Would-break fixed after f8fdfad, round 4 fix-only act-on 0); every act-on item marked fixed at a named commit or
   left as the Ask; round four's fixed point is the commit round three reviewed; CI green at the head;
   `gh pr view 124 --json headRefOid,baseRefName,mergeable,isDraft,closingIssuesReferences` (#103 only).
5. PR body per `AGENTS.md` "Pull requests" at the SHA: plain-sentence title, problem then fix, `## Blast Radius`
   if cross-cutting (no `## ` heading inside), `## Overlap` before `## Verification`, Verification with outcomes,
   `Closes #103` last before the attribution, attribution, then the model-and-harness line.
6. Forbidden edits: nothing hand-edited under `docs/knowledge/spec/`, `pages/`, `notes/`, `research/`;
   `template/docs/factory918/` matches a rebuild.
7. The owner's Decided and Blocked items: defect, judgment for Manuel, or nothing.
8. Chain-time conflicts: in a scratch clone, rebase #120's commits (origin/feat/speed-lessons, e090a38) onto main,
   then #121's (e9fd603) onto that, then this PR's onto that. List every conflict in this PR's commits and its
   obvious resolution; after resolving, run `check_knowledge.py`, `build_knowledge.py` (clean), `./factory918.sh
   sync` (clean), `tests/knowledge/provisional-ids.sh`, and the ShellCheck line. Push nothing. Save the resolved
   scratch branch tip SHAs and a short conflict log to your report so the root can repeat it.
Report: `/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.scratch/program/verify/124-858974e/worker-audit.md`.
