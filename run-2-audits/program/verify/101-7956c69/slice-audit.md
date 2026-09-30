# Slice: receipts-and-diff audit
Distrust the PR body and the owner's report. Read `git diff 52ccd8e..7956c69` whole and the ticket, and check:
1. Each of the ticket's four acceptance criteria against the diff: file:line that satisfies it or unmet.
2. The `## Testing decisions` table on ticket #91 (first line "Posted by the agent 2026-09-22"): one assertion per
   cell in `tests/spec-review/review-brief.sh`, in the table's order, and the commit order shows tests before the
   script (`git log --reverse --format='%h %ad %s' --date=iso-strict 52ccd8e..7956c69`). Any cell without an
   assertion, or any assertion that tests something the table does not say, is a finding.
3. Scope: list every file the diff touches, grouped; flag anything outside the ticket's ask. The diff must not
   re-implement or alter #90's round logic in `review-brief.sh` beyond what the walk rule needs.
4. Receipts: one review comment on PR #101 by the author's account ending `round: 1 of 3` / `act-on items: 0`; CI
   run at 7956c69 success; `gh pr view 101 --json headRefOid,baseRefName,mergeable,isDraft,closingIssuesReferences`
   (closing reference #91 only; mergeable is expected CONFLICTING, say so).
5. PR body shape per `AGENTS.md` "Pull requests" at the SHA: plain-sentence title, problem then fix, `## Blast Radius`
   present with inner headings demoted (this diff is cross-cutting: it touches `template/.claude/hooks/`? check; if
   not, say why the section is or is not required), `## Overlap` before `## Verification`, `## Verification` naming
   what ran and its outcome, `Closes #91` last before the attribution, attribution, model-and-harness line.
6. Forbidden edits: nothing hand-edited under `docs/knowledge/spec/`, `pages/`, `notes/`, `research/`; generated
   files match a rebuild.
7. Process facts for the root's record (state each as a fact, not a verdict): the owner branched from PR #99's head
   although the overlap check printed `base: origin/feat/shellcheck`; the owner retargeted PR #99 (another lane's PR)
   to `main` and back so GitHub would link `Closes #90`; ticket #100 was filed. Confirm each against the PR body's
   `## Overlap`, PR #99's timeline (`gh api repos/Zenoctra/factory918/issues/99/timeline` shows base changes), and
   `gh issue view 100`. Say whether PR #99's base is `feat/shellcheck` now.
8. The `## Attention` items in the owner's report, if any: defect, judgment for Manuel, or nothing.
Report: `/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.scratch/program/verify/101-7956c69/worker-audit.md`.
