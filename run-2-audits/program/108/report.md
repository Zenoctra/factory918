# #108 owner report

For a person: PR #136 makes `review-brief.sh` refuse a review in two cases, a blast-radius risk line with no `fixed: <sha>` or `accepted: <reason>`, and a writer flag on the ticket with none. CI is green, round one of the review ended `act-on items: 0`, and two items from the trail review are Manuel's call (below, under Blocked).

## Status

STACK-READY.
- Head SHA: `6e5c539f44f90a341495aaf4bb3b44dd7b6e16c8`. `git rev-parse HEAD` and `git ls-remote origin refs/heads/feat/risk-dispositions` both print it.
- Branch: `feat/risk-dispositions`.
- PR: https://github.com/Zenoctra/factory918/pull/136 (ready, `MERGEABLE`).
- PR base branch: `main`.
- Patch base: `a9ebdac034bc8389895096b7b93d9cd52ea19588` (origin/main).
- Intended parent: `main`.

Commits, in order:
1. `7cfdceb` adds the tests (tables A, B, C).
2. `4ad87b9` adds the script.
3. `bf459a9` adds the prose and patches.
4. `d016a2e` fixes writer flag 12.
5. `6e5c539` adds the records.

## Overlap

Step 1, `overlap.sh 108`:
```
go: autopilot-stack
base: origin/main
```
Step 8, `overlap.sh 108 --diff` (exit 0), is in the PR body's `## Overlap`:
```
go: autopilot-stack
#135 feat/eco-tier: SOURCES.md docs/agents/ledger.md docs/knowledge/INDEX.md docs/knowledge/core/DECISIONS.md template/.agents/skills/poteto-mode/playbooks/ticket.md template/docs/factory918/DECISIONS.md
```
#135 closes #109, the sibling that runs in parallel. The records files are appended at the end. `ticket.md` is edited in steps 5 and 6 here. The root resolves the overlap at chain time.

## Criteria

1. **A risk without a disposition is refused.** The test is `tests/spec-review/review-brief.sh`: table A cells A3, A4 and A7 across the F, P, R and S forms, 22 cells in table B column r, and table C column r. Each refusal asserts exit 1, the exact stderr, and no `.claude/state/review` or `.scratch/review/<id>`. A1 covers a diff that is not cross-cutting. The suite prints `ok 1720 assertions`.
2. **A writer flag without a disposition is refused, and a ticket with no list is unaffected.** Cells A5, A6 and A8, table B column f, and table C column f cover it. C7/f checks this ticket's own lines. The real run was round one's brief, `review-brief.sh origin/main --ticket 108`. It briefed over #108's live list of 15 dispositioned flags and resolved `fixed: d016a2e` and `fixed: 6e5c539`. The writer's hand run of the same body with a bare flag exited 1 and named the line.
3. **The walk reads each disposition.** `risk_rule` asks whether the diff honors the disposition. The A3 cells assert it in the Walk bullet. The SKILL.md step 4 pin and `no-stale-wording.sh`, which retires the old tail, hold it.
4. **The table is on the ticket, and the tests come before the script.** The table is on #108 under `## Testing decisions`, posted 2026-09-23 before the writer started. `7cfdceb` precedes `4ad87b9`. Run against the old script, it fails every new refusal cell (writer report, "Failing first").
5. **The disposition line appears in Opening a PR and the blast-radius hand-back.** Both lines go through their patches. The blast-radius patch is new: `patches/pstack/blast-radius/SKILL.md.patch`, with its `series` line and SOURCES item 19. The test pins both lines, and `./factory918.sh sync` leaves the tree clean.

Every cell of the #90, #91, #93, #106 and #107 tables keeps its outcome. The whole existing suite passes. The #91 fixtures gained `accepted: fixture`, so their outcomes are unchanged.

## Reviews

- Round 1: https://github.com/Zenoctra/factory918/pull/136#issuecomment-5802001018 ended with `act-on items: 0` at `round: 1 of 3`.
  - Spec (tier-upper, per P103): 0 items.
  - Standards (tier-lower): 0 hard findings and 2 Fix alongside items. S1 (an unclosed fence above the flags list hides the list) was noted and cites P108. S2 (duplicated refusal blocks) was noted.
- No restart and no further round.
- The trail review (tier-lower, Claude Opus 5) is at `.scratch/program/108/trail-review/report.md`. `check-trail.sh`: `ok: 8 rows in order inside the run`. Flags 2 and 3 are settled by a trail row. Flag 4 is settled: the prototype was copied to `.scratch/program/108/proto/`. Flags 1 and 5 are under Blocked. Flags 6, 7 and 8 are under Decided.

## CI

Run 35912356052 at head `6e5c539f44f90a341495aaf4bb3b44dd7b6e16c8` concluded `success`, with the Factory and Fixture jobs both green.

## Records

- Provisional P108 (DECISIONS.md) is "How a risk or a writer flag carries its disposition". It covers the grammar, where the two checks run, the accepted holes, and runner B's rejected variant.
- P28 is amended with "Amended 2026-09-23 (#108): each risk line also says whether the diff honors the disposition the risk's line ends with (...), and a grounding whose risk lines lack a disposition is refused (P108)".
- Ledger: "2026-09-23 | Claude Opus 5.5 | as the #108 owner in a worktree-isolated lane, found its own Write tool refused the main checkout's `.scratch/program/108/` path the brief names, and its Bash refused a heredoc or a compound command that also named git; the owner wrote each file in its own worktree and copied it with a plain `cp` | the owner brief names the plain-`cp` route for the owner itself, not only for the lanes it launches".
- M0: none.
- Ticket #108 body: `## Testing decisions` gained the table and contract, then `### Writer flags 2026-09-23` with 15 dispositioned flags.

## Decided

- **The grammar.** Runner A (Claude Opus 5.5) is the base. An item is every unindented list line, whatever its shape. A disposition is the last `fixed:` or `accepted:` field. A `fixed:` sha must resolve and be an ancestor of HEAD. Near-miss openers are refused. An unclosed fence is refused when it opened inside a list. Runner B's list-marker items and its placement refusal were rejected: they add messages and close no fail-open.
- **The flag list** is read anywhere in the ticket body. Ticket step 6 names the placement.
- **Check order.** The risk check runs before the flag check. The ticket fetch moved, unchanged, to before every state write.
- **The test grid** was trimmed from runner A's 99 cells to the ones that prove each form and site. Blank R, S and f cells are not asserted.
- **The CI fixture grounding** (`.github/workflows/factory-ci.yml`) gained `accepted: a fixture`. This is the rule applied to the fixture.
- **The four playbook pointers** now read "(Ticket steps 5 and 6 give the forms; ...)", fixed by the fix lane.
- **Trail flag 6.** Standards ran on tier-lower because astra, P103's measured pick, is not reachable from this harness. The 0/0 round is weaker evidence than it would be on the measured model.
- **Trail flag 7.** CI ran the suite on Ubuntu, but no step prints `awk --version`, so "mawk ran it" is assumed, not shown.
- **Trail flag 8.** The owner accepted 13 of the 15 writer flags alone. Their reasons are on the ticket.

## Blocked

Two items for Manuel. Neither blocks the stack.
1. **S1, the unclosed fence above a flags list.** A stray unclosed fence anywhere above `### Writer flags <date>` in a ticket body turns the list into fenced text. The flag check then passes with nothing printed. GitHub also renders that list as code. The design (P108) scopes the fence refusal to a fence opened inside a list, so that a ticket with no list stays unaffected. If Manuel wants the hole closed, a follow-up ticket could refuse an unclosed fence whose fenced text holds a `### Writer flags` line. The trail reviewer's point stands: the round cited a record that this PR itself writes.
2. **Trail flag 5, for the root.** #108's Writer flags list carries `fixed: d016a2e` and `fixed: 6e5c539`. If the chain rebase rewrites this branch before any later review of #136, update those two shas in #108's body to the rebased commits. Otherwise `review-brief.sh` refuses the brief and names both. That is the accepted hole in P108, and #136 is its first instance.

## Trail

`/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.scratch/program/108/decisions.tsv`
