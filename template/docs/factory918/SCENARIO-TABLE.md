# Factory918: the scenario table

The scenario table is the design artifact Factory918 asks for before any code that has state: a file it reads or writes, exit codes, review rounds, or more than one actor. Situations go down the side, the shape of the input across the top, and every cell says what must happen. This page says what the table is, what shape it takes, where it goes, and why two runs of the same ticket made it a rule. It is for the person who opens a ticket and finds a table under `## Testing decisions`, and for the agent that has to write one.

## What it is

A design tool, not a fix for one ticket. On #42 Manuel asked whether the "stateful helper with a scenario table" was a solution specific to that issue or a more fundamental design tool. The agent answered:

> It is a general design tool, not a #42 thing. For anything with state, a file, exit codes, or several actors, you write the inputs and states across the top and down the side, and every cell says what must happen. Before code. The table is then the test, row by row.

The table forces the question a prose sketch lets you skip. A sketch can say "the script prints the base to branch from" and stop. A table has a cell for a stale ref, a cell for a missing remote, a cell for a body with no token, and each one is empty until someone decides what happens there. The empty cells are the design holes, and the table shows them before any code is written.

Writing the table does not stop the work. The agent posts it on the ticket and goes on to implementation; the human reads it there and edits it when it is wrong. Manuel chose that over a mandatory pause: "I agree with your choice completely."

## The shape

The table has four parts and the test list follows from them.

- **Situations down the side.** The states the world can be in. On #42: no go, a covering go, a stale ref, a failing tool, a body with no token.
- **The shape of the input across the top.** On #42: no overlap, one PR, siblings, one containing the other, the caller's own.
- **A cell.** What is printed, the exit code, and what the caller does next. Three facts, in that order, in every cell.
- **A legend.** Defines the cell vocabulary once, above the table, so a cell can say `G`, `L(k)` or `B(x)` and stay short.

The contract follows the table and defines every term the cells use: what counts as in flight, what a named path is, what a covering go is. A term the cells use and the contract does not define is a hole.

The test list has one assertion per cell, in the order the cells are written, each naming the fixture state it needs. The table is the test. Nothing is asserted that no cell says, and no cell goes without an assertion.

Two rules cover the inputs the tool is not for. A cell for an input outside the intended path reads "refused with the tool's own message" and costs no code. Manuel set that line on #81: an edge case outside the intended path being unsupported is not a flag, at most hardening to fail fast and loud. The second rule is stricter. Cut such a cell only after the refusal was run and seen. The ledger records why:

> 2026-09-21 | fable | cut the detached-HEAD cell from the #42 scenario table on the judge's word that git would fail loudly on its own; git ran fine with an empty branch name and round two found the record step reporting the ticket's own PR | a cell cut as 'the tool refuses it' is cut only after the refusal was run and seen; an assumption about a tool's failure mode is a rung-1 claim until then

## Where it goes

On the ticket, before implementation. The Ticket playbook's step 6 reads the current body into a file, adds the table at the end under `## Testing decisions`, and writes the whole file back with `gh issue edit N --body-file`, because that command replaces the body and never merges. The section's first line is `Posted by the agent <date>`, or `Approved by <name> <date>` when the human approved it first. If the write fails, the agent stops and reports the error, and implementation does not start. Posting is the record. The human edits the ticket if the table is wrong, and a stop before implementation is asked for only with `/architect with checkpoint`.

Code with no state that crosses a function boundary gets the other artifact `architect` already produces, the usage and signature sketch (the caller's usage first, then types and signatures), under `## Design` by the same rule. The step-1 overlap check skips both sections, so a path a cell quotes does not count as a path the ticket names. The whole artifact stays inside the one section, its parts (the legend, the table, the contract, the test list) under `###` headings, because the skip ends at the next `## ` heading. A prose change has its acceptance criteria and nothing else.

The reviewer reads the table without any extra step, because `review-brief.sh` pastes the whole ticket body into the Spec brief. Whatever is under `## Testing decisions` is spec from then on. The writer gets the table in its brief and writes the test from it before the implementation, one assertion per cell in the table's order, so the commit order shows the test came first. A writer that cannot implement a cell as written stops and reports the cell, and never fills it in.

## The #42 example

The durable copy is the `## Testing decisions` section of ticket #42 and the description of PR #92. #42's record was written before this rule, so its table and contract sit under their own `## ` headings there. A table posted from now on keeps them under `###` inside the one section. The legend and the table, verbatim:

> Cell = prints / exit / what the agent does. `G` = first line `go: <label>` or `go: none`. `L(k)` = `#k <head>: <paths>`, the named paths k's own commits touch (its diff from `nearest`, the open-PR head under it, else `origin/main`), ascending by PR number. `B(x)` = last line `base: <x>`. Exit 0 always ends with a `base:` line; exit 1 prints `G` and the `L` lines and no base; exit 2 prints the tool's message on stderr and nothing decided. "Covered" = a line of `.claude/state/program` names #N and, for every printed PR, the ticket it closes (`closingIssuesReferences`).

| Situation | A. no overlap | B. one PR k overlaps | C. siblings k1, k2 | D. k2 contains k1 | E. `--diff` at step 8 |
|---|---|---|---|---|---|
| 1. No go names N | `G none`, `B(origin/main)` / 0 / branch from main | `G none`, `L(k)` / 1 / stop; reply: merge #k or say `stack #N on #M` | `G none`, `L(k1)`, `L(k2)` / 1 / stop, names both | `G none`, `L(k1)`, `L(k2)` / 1 / stop | own PR skipped; nothing else: prints nothing / 0 / no section; another PR j overlaps: `G none`, `L(j)` / 1 / section written, reply names #j to merge first |
| 2. Covered (go names N and every printed PR's ticket) | `G`, `B(origin/main)` / 0 | `G`, `L(k)`, `B(origin/<head k>)` / 0 / branch from k, report k as parent | `G`, `L(k1)`, `L(k2)`, `B(lowest number's head)` / 0 / branch, report both, root chains | `G`, `L(k1)`, `L(k2)`, `B(head k2)` / 0 / the head that contains the other | own PR skipped; parent's shared paths print with `G` / 0 / section verbatim |
| 3. Go names N, a printed PR's ticket is not on any line (Q1) | as 2A | `G`, `L(k)` / 1 / stop; reply: merge #k or add its ticket to the go | / 1 / stop | / 1 / stop | as 1E |
| 4. Program file present, no line names N | as 1A | as 1B (`G none`) | as 1C | as 1D | as 1E |
| 5. Program died; its line left behind | rows 2 to 4 apply unchanged: a line covers only stacks among the tickets it names while their PRs are open; nothing to clean up | | | | |
| 6. One-off go during a live program: `overlap.sh go "stack on #M" N` appends a line | rows 2 to 4 with that line; the program's lines untouched | | | | |
| 7. Review ticket (sweep) or body with no token: tokens under `## Diff` ignored | `G`, `paths: none`, `B(origin/main)` / 0 / branch; step 8 is the check | cannot overlap | | | as 1E / 2E |
| 8. Ticket names a file only PR k creates | pathspec matches the created file, on the creating PR's line only: as rows 1 to 4 | | | | |
| 9. Stale or missing remote-tracking ref | every open PR head fetched with a forced refspec before any diff: as rows 1 to 4 with fresh tips | | | | |
| 10. A PR head with no merge base against its base | git's `no merge base` on stderr / 2 / stop, report; the human closes or rebases that PR | | | | / 2 |
| 11. gh fails or is absent | gh's message (or `command not found`) on stderr / 2 / stop, report | | | | / 2 |
| 12. No origin remote | stderr `no origin remote; nothing in flight`, `G none`, `B(main)` / 0 / branch from main; gh not called | cannot overlap | | | prints nothing / 0 |
| 13. Token that is no path (`gh`, `#9`, `set -e` never a token, `{a,b}`) | matches nothing: as rows 1 to 4 for the real tokens beside it | | | | n/a |
| 14. Token outside the repository (a dot-dot path or an absolute path, unbackticked here so this ticket's own check does not trip on it) | git's own fatal on stderr / 2 / stop; the human fixes the body | | | | n/a |

The contract opens by naming the three calls and the exit codes, then the named paths. Its first two paragraphs:

> `.claude/skills/poteto-mode/scripts/overlap.sh N` (check, Ticket step 1); `overlap.sh N --diff` (record, Ticket step 8); `overlap.sh go "<label>" N...` (append `<label>: #a #b ...` to `.claude/state/program`, creating it; the only writer). `N` with or without `#`. Exit 0 decided (last line `base:`), 1 overlap without a covering go, 2 the check could not run (`trap 'exit 2' ERR` under `set -euo pipefail`; stderr carries the tool's message), 64 usage (no N; a flag other than `--diff`; a third argument).
>
> Named paths (check): every backticked token without whitespace outside a `## Diff` section, deduped, passed together as pathspecs to one `git diff --name-only "$(nearest origin/$head)...origin/$head" -- "${toks[@]}"` per open PR, where `nearest <ref>` is the open-PR head, other than the ref's own, that is an ancestor of the ref with the fewest commits between, else `origin/main`; a stacked PR's line carries only its own commits; its output is `L(k)`. No token: `paths: none` and no PR loop. `--diff`: own paths = `git diff --name-only $(nearest HEAD)...HEAD`, the own PR's head excluded; the per-PR diff runs with `GIT_LITERAL_PATHSPECS=1`; the PR whose head is the current branch is skipped.

Read the table beside `tests/poteto-mode/overlap.sh`: its header says the cases run in the order of the table, and each case asserts the exit code and the output of one call.

## Why

Ticket #42 ran twice, and the two runs differ in one thing.

The first run, PR #87, settled a script, a state file and two exit-code decisions in prose sketches. Nobody wrote out the situations with an expected outcome per cell. The three review rounds found the empty cells one at a time, 2, 4 and 4 hard findings, and each fix round redesigned the core of the matcher. The PR was closed.

The second run, PR #92, wrote the table first and posted it on the ticket. The writer found the one design hole at the test, before any review: the contract diffed a stacked PR against `main`, which contradicted the table's "contains" column, and the contract was amended with a dated line. The three rounds then found 2, 1 and 2 items. None of them changed a cell.

That is the whole case. A reviewer who reads a prose sketch has to imagine the situations and finds them one round at a time. A reviewer who reads a table checks cells, and a finding either changes a cell, which sends the work back to design, or leaves the table standing, which makes it an implementation bug fixed on the PR. The table turns the review from a search into a check.
