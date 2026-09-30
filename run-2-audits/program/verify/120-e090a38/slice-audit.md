# Slice: receipts-and-diff audit
Distrust the PR body and the owner's report. Read `git diff 86d156a..e090a38` whole and the ticket:
1. Each acceptance criterion of #105 against the diff: file:line or unmet. The owner claims 16.
2. Scope: every file the diff touches, grouped; anything outside the ticket's ask flagged. The owner fixed four
   "after CI is green" docs at a reviewer's request, doing #119's work: judge whether that is in scope and whether
   #119 is now redundant (`gh issue view 119`).
3. Vendored edits only through patches: for every changed file under `template/.agents/skills/` that is vendored
   (see `SOURCES.md`), a patch in `patches/` carries it.
4. Receipts: four review comments on PR #120 (round 1 act-on 3, round 2 act-on 3, round 3 act-on 0 with a Would-break
   fixed at e090a38, round 4 fix-only `round: 4 of 5` act-on 0); each act-on item marked fixed with the commit the
   owner names; round four's fixed point f810542 is the commit round three reviewed; CI green at the head;
   `gh pr view 120 --json headRefOid,baseRefName,mergeable,isDraft,closingIssuesReferences` (#105 only).
5. PR body shape per `AGENTS.md` "Pull requests" at the SHA: plain-sentence title, problem then fix, `## Blast
   Radius` if cross-cutting (no `## ` heading inside it), `## Overlap` before `## Verification`, Verification with
   outcomes, `Closes #105` last before the attribution, attribution, then the model-and-harness line.
6. Forbidden edits: nothing hand-edited under `docs/knowledge/spec/`, `pages/`, `notes/`, `research/`;
   `template/docs/factory918/` matches a rebuild.
7. The owner's `## Decided` and `## Blocked` items: defect, judgment for Manuel, or nothing.
8. Chain-time conflicts with PR #121 (`origin/feat/provisional-ticket-ids`, head e9fd603): in a scratch clone, rebase
   this PR's commits onto e9fd603 and list every conflict and its obvious resolution; after resolving (keep both
   rows, rebuild INDEX), run `python3 tools/check_knowledge.py` and `bash tests/knowledge/provisional-ids.sh`. Push nothing.
Report: `/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.scratch/program/verify/120-e090a38/worker-audit.md`.
