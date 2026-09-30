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



## Testing decisions

Posted by the agent 2026-09-22, synthesized from two architect runners (Claude Opus 5.5 and Claude Opus 5 on Claude Code), who converged on the id format and the check.

### Design

A Provisional row's id is `P` and the number of the ticket its PR closes: `P110`. A second row from the same ticket takes the next letter from `b` (`P110b`, `P110c`); the bare id is the first row, so it is never renamed when a sibling arrives. Nothing is read from `DECISIONS.md` to choose the id, so two lanes on two tickets cannot take the same one and a rebase changes no id. Legacy rows `P1` to `P30` (the `P17` promoted stub included) already have this form and keep their ids with no special case.

`tools/check_knowledge.py` gains one pure function over the text of `docs/knowledge/core/DECISIONS.md`, whose problems join the script's existing list (print, exit 1). It refuses an off-form id and a duplicate id, and refuses a Provisional section from which no row was read, so the check cannot pass by reading nothing.

`review-brief.sh:248`'s `cites:` grammar changes from `DECISIONS\.md [A-Z]?[0-9]+` to `DECISIONS\.md [A-Z]?[0-9]+[b-z]?`, a superset, so every posted cite (`P17`, `P1`, `19`) still matches and a cite of `P110b` carries instead of being dropped silently. `spec-review/SKILL.md:137` is unchanged: its `DECISIONS.md <row id>` form already covers `P110b`.

Rejected: `P-<ticket>` (fails the legacy form and the `cites:` grammar, so both need exceptions); one row per ticket (#101 recorded two unrelated decisions); a reservation file or counter (serializes the sharing instead of removing it); per-ticket files assembled at build time (a new layout and build path for a conflict that "keep both rows" resolves); a floor refusing ids between P31 and P100 (open tickets below 110 exist, #41).

### Legend

- **ok**: prints `knowledge ok: <n> files`, exit 0. CI goes on.
- **dup(x)**: prints `DECISIONS.md line <n>: Provisional id x is already on line <m>; ...rename this row and its mentions`, exit 1. The lane renames its own row (the later line) to its ticket's next free letter and the mentions it wrote; it never renames a row already on `main`.
- **bad(x)**: prints `DECISIONS.md line <n>: Provisional id 'x' is not P<ticket> with an optional b-z sibling letter`, exit 1. The lane fixes the cell. An off-form cell is never also compared for duplicates, so one mistake prints one line.
- **gone**: prints `DECISIONS.md: no Provisional row was read; ...`, exit 1. Whoever changed the section's shape restores it or updates the check.
- **carried** / **dropped**: `review-brief.sh` does or does not match the id in a judgment item's `cites: DECISIONS.md <id>`; a carried item is in the next round's briefs as settled and counted in `settled: carried <c>, dropped <d>`.

### Contract

- **Provisional section**: the lines of `docs/knowledge/core/DECISIONS.md` from the first line starting `## Provisional` to the next line starting `## `, or the end of the file.
- **Id cell**: for a section line starting `|`, the text between its first and second `|`, stripped. A pipe or a `P<n>` mention in a later cell cannot move it. The header cell `#` and a separator cell made only of `-`, `:` and spaces are not ids; every other cell is, an empty one included.
- **Well formed**: the id cell fully matches `P[0-9]+[b-z]?`.
- **Duplicate**: an id cell equal to one on an earlier line of the section; the message names the later line and the earlier one.
- **Next free letter** for ticket N: the first of `P<N>`, `P<N>b`, `P<N>c`, ... that no id cell on `main` holds.
- **Invariant**: every well-formed id matches the `DECISIONS.md` alternative of the `cites:` grammar; a test holds the Python and the bash regex together.
- The check reads only the source file. `build_knowledge.py` is unchanged; it never reads the table, so the slim copy and the index regenerate with no hand edit.

### Scenario table

Columns are the id shape the PR adds. A: one row `P<ticket>`. B: two rows from one ticket, `P<ticket>` and `P<ticket>b`. C: an off-form id (`P-110`, `p110`, `P110a`, `P110.2`, `110`, empty).

| # | Situation | A | B | C |
|---|---|---|---|---|
| 1 | One PR on today's base (P1 to P30, P6 absent, P17 stub) | ok | ok | bad(x) once per off-form row |
| 2 | Two PRs from the same base for different tickets (#110, #111); #111 merges first and #110 is rebased, the textual conflict at the table's end resolved by keeping both rows | ok; no id and no mention changes | ok | bad(x), as row 1 |
| 3 | Two PRs for the same ticket (off the one-ticket-one-PR path); the first, holding `P110`, merges and the second is rebased | dup(P110); the second takes `P110b` | dup(P110), dup(P110b); the second takes the next two free letters | bad(x), as row 1 |
| 4 | A chain rebase: the parent PR merges and this PR is rebased onto `main` | ok; the row's line is byte-identical before and after | ok | bad(x), as row 1 |
| 5 | A later review round reads an earlier judgment item ending `cites: DECISIONS.md <id>` for this row | carried (`P110`) | carried (`P110b`; dropped under today's grammar) | dropped (`P-110`); unreachable, since row 1 refuses the row before the PR is green |
| 6 | The ticket's number is a legacy id (a ticket numbered 1 to 30, or `P17` the promoted stub) | dup(P17); the lane takes `P17b` | dup(P17); the lane takes `P17b`, `P17c` | bad(x), as row 1 |
| 7 | Two lanes each took max+1 (`P31`), the habit this ticket retires; the first merged (one cell) | dup(P31); the second renames its row to `P<ticket>` | (same cell) | (same cell) |
| 8 | The `## Provisional` heading renamed or removed, or the table lost its leading pipes (one cell) | gone | (same cell) | (same cell) |
| 9 | `main` at HEAD, no new row: the legacy ids, the header and separator rows, a Reason cell mentioning `P25` (one cell) | ok, and no output line contains `Provisional id` | (same cell) | (same cell) |

### Test list

`tests/knowledge/provisional-ids.sh` (new; CI and `AGENTS.md` "Verifying" run it) copies `tools/check_knowledge.py` and `docs/knowledge/` into a temp tree, since the script resolves the knowledge base from its own path. Each case rewrites existing rows' id cells in the copy's `DECISIONS.md` in place, or appends rows and updates the copy's `INDEX.md` count, and asserts the check's id lines and exit code. Row 5 goes in `tests/spec-review/review-brief.sh`, beside the existing `P17`, `P1` and `P16` cites.

1. 1A: one id rewritten to `P110`: ok, exit 0.
2. 1B: two ids rewritten to `P110` and `P110b`: ok, exit 0.
3. 1C: one id rewritten to each of `P-110`, `p110`, `P110a`, `P110.2`, `110`, empty, one case each: bad naming that value, exit 1.
4. 2A: rows `P111` then `P110` (the order after the rebase): ok, exit 0.
5. 2B: rows `P111`, `P110`, `P110b`: ok, exit 0.
6. 2C: rows `P111`, `P-110`: one bad line, exit 1.
7. 3A: two rows `P110`: dup(P110), exit 1.
8. 3B: rows `P110`, `P110b`, `P110`, `P110b`: dup lines for `P110` and `P110b`, exit 1.
9. 3C: rows `P110`, `P-110`: one bad line and no dup line, exit 1.
10. 4A: row `P110`, then `P112` added above it: ok, and the `P110` line is byte-identical to the fixture's.
11. 4B: rows `P110`, `P110b`, then `P112`: ok, exit 0.
12. 4C: rows `P112`, `P110.2`: one bad line, exit 1.
13. 5A: a previous comment's Dismissed item ending `cites: DECISIONS.md P110`: carried.
14. 5B: the same ending `cites: DECISIONS.md P110b`: carried (fails before the grammar change).
15. 5C: the same ending `cites: DECISIONS.md P-110`: dropped, the dropped count one higher.
16. 5D: every id the check accepts in 1A, 1B and the unmodified copy matches the `DECISIONS.md` alternative extracted from `review-brief.sh`'s `cites=` line.
17. 6A: a new row `P17`: dup(P17), exit 1.
18. 6B: new rows `P17`, `P17b`: dup(P17) only, exit 1.
19. 6C: a new row `P17.1`: one bad line, exit 1.
20. 7: two rows `P31`: dup(P31), exit 1.
21. 8: the copy's `## Provisional` heading reworded, line count kept: gone, exit 1.
22. 9: the unmodified copy, plus ` (see P25)` appended inside one Reason cell: `knowledge ok:`, exit 0, and no line contains `Provisional id`.

### Usage

The rule, in `template/docs/agents/issue-tracker.md` (and its copy `docs/agents/issue-tracker.md`) as a **Record a decision** bullet, in the Ticket playbook as its own paragraph after the `### Ticket` reply line, and as one line under the `## Provisional` heading of `DECISIONS.md`: a row a PR adds takes `P<N>`, N the ticket the PR closes, and a second row `P<N>b`; never the highest id plus one, because two lanes from one base both take it and every rebase renumbers it and the reviews that cite it.
