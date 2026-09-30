## What to build

> agent (mid-mortem, 2026-09-22): "five concurrent PRs all appending Provisional rows to one file gave P25, P26, P26, P26, P27 collisions that had to be renumbered at every rebase. Append-only shared records do not survive parallel lanes."

> user: "I dont want to leave behind issues for the future to find again the hard way."

Facts the lane starts from. `docs/knowledge/core/DECISIONS.md` Provisional rows are numbered P<n> in one table, and `tools/build_knowledge.py` regenerates the slim copy and the index from it. In the 2026-09-22 stack, PRs #94, #96, #99, #101 and #102 each added the next number at branch time; every chain rebase renumbered the rows above it and every mention of them in prose, ledger lines and review comments (final: P25 #94, P26 #96, P27 #99, P28 and P29 #101, P30 #102). The ids are cited by `cites: DECISIONS.md P<n>` in review judgments, so a renumber also invalidates settled items.

## Acceptance criteria

- [ ] A Provisional row's id is stable across rebases: it is derived from the ticket (for example `P-<ticket>` or the ticket number in the id) or allocated in a way two parallel PRs cannot both take, and `tools/check_knowledge.py` refuses a duplicate id; the scenario table on this ticket has one row per collision shape (two PRs from the same base, a rebase, a row cited by a review comment) with an assertion each.
- [ ] Existing rows keep their ids; `cites:` references in posted comments stay valid; the build regenerates the slim copy and index with no hand edit.
- [ ] `docs/agents/issue-tracker.md` and the Ticket playbook say how a lane takes its id.

## Blocked by

None.

