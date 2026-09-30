# Slice: receipts-and-diff audit
Distrust the PR body and the owner's report. Read `git diff 86d156a..e9fd603` whole and the ticket:
1. Each acceptance criterion of #110 against the diff: file:line or unmet.
2. The scenario table on ticket #110: one assertion per row in `tests/knowledge/provisional-ids.sh` or
   `tests/spec-review/review-brief.sh`, named by row; commit order shows tests before the check
   (`git log --reverse --format='%h %ad %s' --date=iso-strict 86d156a..e9fd603`). A row without an assertion, or an
   assertion the table does not say, is a finding.
3. Scope: every file the diff touches, grouped; anything outside the ticket's ask flagged. Vendored-skill edits only
   via patches.
4. Receipts: review comments on PR #121 by the author's account (`round: 1`, `act-on items: 1`; `round: 2 of 3`,
   `act-on items: 0` over the whole diff at e9fd603); round one's item marked fixed; CI green at the head;
   `gh pr view 121 --json headRefOid,baseRefName,mergeable,isDraft,closingIssuesReferences` (#110 only). The trail
   review's items: #122 filed for item 2 (check it exists and says what the owner says).
5. PR body shape per `AGENTS.md` "Pull requests" at the SHA: plain-sentence title, problem then fix, `## Blast
   Radius` if cross-cutting (no `## ` heading inside it), `## Overlap` before `## Verification`, Verification with
   outcomes, `Closes #110` last before the attribution, attribution, model-and-harness line.
6. Forbidden edits: nothing hand-edited under `docs/knowledge/spec/`, `pages/`, `notes/`, `template/docs/factory918/`,
   `research/`; generated files match a rebuild.
7. The owner's `## Decided` items (`P<ticket>` not `P-<ticket>`; letters b to z; a lone max+1 id passes its own CI;
   the project-side question left to #122) and the flag that PR #120 adds its row as `P31`: defect, judgment for
   Manuel, or nothing. Confirm what #120's head actually carries (`gh pr diff 120 --repo Zenoctra/factory918`).
Report: `/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.scratch/program/verify/121-e9fd603/worker-audit.md`.
