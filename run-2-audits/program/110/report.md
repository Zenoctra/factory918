# #110 owner report

PR #121 makes a Provisional row's id come from its ticket (`P110`, then `P110b` for a second row). The knowledge check now refuses a duplicate or off-form id, so parallel PRs can no longer collide and a rebase no longer renumbers. It is green and reviewed with nothing left to act on. The root needs to know one thing: #120 (the #105 PR) adds its row as `P31` under the old habit, and that row should become `P105` before it lands.

## Status

STACK-READY. Head `e9fd603752d1eeacf345c9853e34d0f33e20813c`. `rev-parse HEAD` and `ls-remote origin refs/heads/feat/provisional-ticket-ids` agree. Branch `feat/provisional-ticket-ids`. PR https://github.com/Zenoctra/factory918/pull/121, which is ready (not a draft), MERGEABLE, and links `Closes #110`. Base branch `main`. Patch base: I branched from `origin/main` at `86d156a`. Intended parent: `main`.

PR body amended after the root's verifier audit: it now ends with the line `Claude Opus 5.5 on Claude Code` after the attribution line. Only the body was edited (fetched, appended, written back whole with `gh pr edit --body-file`). No commit was pushed, and the head is still e9fd603752d1eeacf345c9853e34d0f33e20813c.

## Overlap

Step 1 (`overlap.sh 110`, before branching):
```
go: autopilot-stack
base: origin/main
```
Step 8 (`overlap.sh 110 --diff`, at e9fd603, exit 0):
```
go: autopilot-stack
#120 feat/speed-lessons: AGENTS.md docs/M0-findings.md docs/agents/ledger.md docs/knowledge/INDEX.md docs/knowledge/core/DECISIONS.md template/.agents/skills/poteto-mode/playbooks/ticket.md template/docs/factory918/DECISIONS.md
```
Expect conflicts at chain time in four places. The first is the end of the Provisional table: keep both rows. The second is the INDEX line count: rebuild. The third is `AGENTS.md` Verifying: the ShellCheck count and the new test line. The fourth is the appended ledger and M0 lines. My `ticket.md` edit is one paragraph between the Ticket `**Reply:**` line and `### Quick ticket`.

## Criteria

1. The id is stable across rebases and derived from the ticket, `check_knowledge.py` refuses a duplicate, and the scenario table has one row per collision shape with assertions. Proof: the table is posted on #110 under `## Testing decisions`, with rows for two PRs from one base, a same-ticket duplicate, a rebase, a cited row, a legacy collision, a max+1 pair, a reshaped section and HEAD. `tests/knowledge/provisional-ids.sh` passes 26 assertions. It was committed before the check and failed against the old check (P-110 gave `knowledge ok`, exit 0). Row 5 (a cited row) is in `tests/spec-review/review-brief.sh`, 660 assertions. The `P110b` cite failed before the grammar change.
2. Existing rows keep their ids, posted `cites:` stay valid, and the build needs no hand edit. Proof: P1 to P30 are untouched and pass. The `cites:` grammar only widens (`[A-Z]?[0-9]+[b-z]?`), and the old P17, P1 and P16 cite tests pass. `build_knowledge.py` leaves the status clean. CI ran check, build and diff --exit-code, all green.
3. `issue-tracker.md` and the Ticket playbook say how a lane takes its id. Proof: a "Record a decision" bullet is in `template/docs/agents/issue-tracker.md` and its byte-identical copy. A paragraph in `template/.agents/skills/poteto-mode/playbooks/ticket.md` covers the next free letter when `P<N>` is taken. There is also a line under `## Provisional` in DECISIONS.md.

Local runs at head: ShellCheck line (21 files), gate.sh 17, delegation.sh 55, review-comment.sh 192, review-brief.sh 660, overlap.sh 57, provisional-ids.sh 26, no-stale-wording, check_knowledge ok, build clean, `./factory918.sh sync` clean.

## Reviews

- Round 1: https://github.com/Zenoctra/factory918/pull/121#issuecomment-5788317065, `act-on items: 1` (test file mode). The next commit fixed it.
- Round 2: https://github.com/Zenoctra/factory918/pull/121#issuecomment-5788368757, `act-on items: 0`, `round: 2 of 3`, over the whole diff from origin/main at e9fd603. There were no restarts.
- Trail review (a tier-upper lane): eight items. I fixed 1 (the legacy-collision clause, in commit 09bdf44), 3 (the M0 line), 4 (the ledger line), 5 (the PR body wording), and 6 and 8 (trail rows). Item 2 is filed as #122. Item 7 is the #120 flag under Blocked.

## CI

Run 35813400632, head e9fd603752d1eeacf345c9853e34d0f33e20813c, conclusion success. Earlier runs also passed: 35812936133 on 9dde5a4 and 35812751691 on 87c5ad9.

## Records

- Provisional: `| P110 | Provisional row ids | ... |`, appended at the end of the table. There is also a rule line directly under the `## Provisional` heading.
- Ledger: "2026-09-22 | Claude Opus 5.5 | as the #110 owner lane, told its writer lane to write its report to a path in the owner's worktree; the writer's worktree isolation refused the write, so the report landed in the writer's own worktree and the owner's nine-minute poll on the named path ended without it ... | ... polls for it there by glob ... (#110)".
- M0: "2026-09-22. Claude Code desktop 2.2553.13 (Agent SDK 0.3.280), an Agent-tool lane in its own worktree (#110 ...): the Write and Edit tools refuse any path outside the lane's own worktree ... a plain Bash `cp` or `printf >>` works. The same isolation check refuses a whole Bash command it cannot verify stays in the worktree ...".

## Decided

- The id format is `P<ticket>` rather than the ticket's example `P-<ticket>`, because the legacy ids and the existing `cites:` grammar already fit it. Sibling rows take letters `b` to `z`, and `P110a` is refused.
- `spec-review/SKILL.md` and its patch stay unchanged, since `<row id>` covers `P110b`.
- The check also refuses a section from which no row is read, so a reshaped table cannot pass silently.
- A lone max+1 id (for example `P31`) passes its own CI. It is caught only when a second one meets it. I accepted this rather than add a floor that would refuse real tickets below #110.
- The project-side question stays out of this PR and is filed as #122: a project's DECISIONS.md is generated and overwritten by `apply`.

## Blocked

Nothing waits on Manuel for #121 itself. For the root: #120 adds `| P31 | Where the run's speed lessons live (#105) |`. Under this rule that row should be `P105`, with its mentions renamed, before either PR lands. If the #103 PR also takes `P31`, `check_knowledge.py` fails the chain at the rebase that joins them, which is the intended catch.

## Trail

`/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.scratch/program/110/decisions.tsv`. The same files are also in the owner worktree's `.scratch/110/`.
