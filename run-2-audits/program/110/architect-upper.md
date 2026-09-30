# #110 architect, upper runner: Provisional ids keyed by ticket

The id of a Provisional row becomes `P<ticket>`: the number of the ticket the PR closes, with a lowercase letter for that ticket's second and third rows (`P110`, `P110b`). `tools/check_knowledge.py` gains one block that refuses a duplicate id, an id in any other form, and a missing Provisional heading; legacy P1 to P30 already have that form and need no special case.

## Decisions (with reasons)

1. **Id format `P<ticket>`, second row `P<ticket>b`, third `P<ticket>c`.** One ticket is one PR (Ticket step 4) and every change has a ticket (P10), so the ticket number is known at branch time, is owned by exactly one lane, and no rebase changes it. The first row carries no letter, so the common case reads like the legacy ids (`P110` next to `P30`). The letter starts at `b` because the bare id is the first row. If `P<ticket>` is already on `main` (a follow-up PR on a reopened ticket, or a ticket numbered 1 to 30 whose number a legacy row holds), the lane takes the next free letter. That one rule covers both cases.
2. **`cites:` grammar.** `review-brief.sh:248` changes from `DECISIONS\.md [A-Z]?[0-9]+` to `DECISIONS\.md [A-Z]?[0-9]+[a-z]?`. This is a superset, so every posted cite (`P17`, `P1`, `19`) still matches. The file is ours (in `sync`'s `keep_files`, SOURCES.md item 6), so it is edited directly. Without the change a cite of `P110b` would be dropped silently, since the `$` anchor follows the digits. `spec-review/SKILL.md:137` does not change: it says `DECISIONS.md <row id>` with `P17` and `19` as examples, and `P110b` is a row id. No patch churn.
3. **Legacy P1 to P30 keep their ids.** They already match `P[0-9]+[a-z]?`, so the check treats them exactly like new ids: they count toward uniqueness and nothing else. The P17 `(promoted)` stub keeps its id cell and therefore keeps reserving `P17`. The absent P6 is not a problem, since the check looks only for duplicates and form, never for gaps.
4. **Where the check lives.** It is one flat block in `tools/check_knowledge.py`, after the per-file loop, appending to the existing `problems` list. The output and exit contract stay the same (print the problems, exit 1; otherwise `knowledge ok: N files`, exit 0). CI already runs this script first (`factory-ci.yml:33`). No new function, matching the script's flat style: the block has one caller.
5. **What counts as the id cell.** It is the text between the first and second `|` of a line that starts with `|`, with the whitespace stripped. The line must lie after the line starting `## Provisional` and before the next line starting with `#`, in `docs/knowledge/core/DECISIONS.md` (the source, never the generated copy). The header row (cell `#`) and the separator row (cell matching `:?-+:?`) are skipped. Prose lines in the section are ignored.
6. **Malformed new ids are refused.** An id cell must fully match `P[0-9]+[a-z]?`. Reason: an id outside that form cannot be cited. `review-brief.sh` drops such a cite without an error, so an id like `P-110` (the ticket's own example form) would create a decision that can never be settled in review. That is an input off the documented path proceeding silently, the fails-open class (P18). The refusal costs one `re.fullmatch`.
7. **A missing Provisional heading is refused.** Without it the block would check nothing and pass. One line.

Rejected, with reasons:
- `P-<ticket>` (the ticket's example). It fails the cites grammar, which would then need a wider change, and `SKILL.md:137`'s examples would go stale.
- Keeping the grammar unchanged by naming a second row `Q110`, or by giving it the PR's number (issues and PRs share GitHub's counter). `Q110` reads as noise. The PR number is not known until the PR opens, and a third row would need a third number.
- One row per ticket, with two decisions merged into it. #101 recorded two separate decisions (P28, P29), and a merged row makes a cite ambiguous.
- Per-ticket files (`core/provisional/110.md`) assembled into the table by `build_knowledge.py` (separate-before-serializing taken all the way). This would also remove the textual conflict at the table's end. It moves the record away from the file everyone reads, adds a build step and a new file layout for a conflict that "keep both rows" resolves mechanically. The conflict was never the cost. The renumbering was.
- A floor that refuses new ids between P31 and P100 to catch lanes that still take max+1. Open tickets below 110 exist (#41), so the floor would refuse legitimate ids. The rule sentence carries this, and a duplicate from two max+1 lanes is still caught.
- Checking that the id's number matches a `#N` in the row, or that the ticket exists. That repeats the id in the row, or needs the network in a check that runs offline.

## Scenario table

Legend (every cell uses these once defined).
- **ok**: prints `knowledge ok: <N> files`, exit 0. The caller goes on.
- **dup(<id>; <l1>, <l2>)**: prints `core/DECISIONS.md: Provisional id <id> is on lines <l1>, <l2>`, exit 1. The caller renames its own row to the next free letter of its ticket (`P110` becomes `P110b`) and the mentions of it on its branch. It never renames a row already on `main`.
- **bad(<line>; <id>)**: prints `core/DECISIONS.md:<line>: Provisional id '<id>' is not P<ticket> or P<ticket> and a lowercase letter`, exit 1. The caller renames the row to `P<ticket>`.
- **none**: prints `core/DECISIONS.md: no "## Provisional" heading`, exit 1. The caller restores the heading.
- **carried** / **dropped**: `review-brief.sh`'s `settled: carried <c>, dropped <d> without a citation` line, exit 0. A carried item is in both briefs as settled. A dropped item is not.

Every exit-1 message is one line among the check's other problems. Lines are those of `core/DECISIONS.md`. The line numbers in the cells are those of the named fixture.

Columns, the id shape the PR adds:
- **A.** One row, `P<ticket>`.
- **B.** Two rows from one ticket, `P<ticket>` and `P<ticket>b`.
- **C.** One row with a malformed id: `P-110`, `P110.2`, `` `P110` ``, `p110`, `110`, or empty.

| # | Situation | A: `P<ticket>` | B: `P<ticket>`, `P<ticket>b` | C: malformed |
|---|---|---|---|---|
| 1 | One PR on today's base (P1 to P30, P6 absent, P17 stub) | ok | ok | bad(<line>; <id>) once per malformed row; caller renames to `P<ticket>` |
| 2 | Two PRs from the same base for different tickets (#110, #111); #111 merged first; this PR rebased with its row and #111's both kept at the table's end | ok (git's conflict at the table's end is resolved by keeping both rows; no id or prose changes) | ok | bad, as row 1 |
| 3 | Two PRs for the same ticket open at once (outside the one-ticket-one-PR path); the first, holding `P110`, merged; this one rebased | dup(P110; l1, l2); caller takes `P110b` | dup(P110; ..), dup(P110b; ..); caller takes the next two free letters | bad, as row 1 |
| 4 | A chain rebase: this PR's parent in the stack merged, this PR rebased onto `main` | ok, ids and every prose mention unchanged | ok | bad, as row 1 |
| 5 | A later review round reads an earlier judgment item ending `cites: DECISIONS.md <id>` for this row | carried (`P110`) | carried (`P110b`, needs the grammar change) | dropped (`P-110`); cannot reach review, since row 1 refused the row |
| 6 | The ticket's number is held by a legacy row or the P17 stub (a ticket numbered 1 to 30; theoretical here, since those are closed) | dup(P17; 83, <new>); caller takes `P17b` | dup(P17; ..); caller takes `P17b`, `P17c` | bad, as row 1 |
| 7 | Two lanes each took max+1 (`P31`), as before this ticket; the first merged (one cell: the column is the old habit) | dup(P31; l1, l2); the second lane renames its row to `P<ticket>` | (same cell) | (same cell) |
| 8 | The `## Provisional` heading is renamed or removed (one cell) | none | (same cell) | (same cell) |
| 9 | `main` at HEAD, no new row (the regression cell) | ok | (same cell) | (same cell) |

Rows 7, 8 and 9 each have one cell, since the input column does not change the outcome. The check cannot tell that a single `P31` is not a ticket number. That gap is covered by the rule sentence and caught by row 7 once two lanes do it.

## Contract

- **Provisional section.** The lines of `docs/knowledge/core/DECISIONS.md` after the first line starting `## Provisional` and before the next line starting `#`, or before the end of the file.
- **Id cell.** For a section line starting `|`, the text between its first and second `|`, stripped of whitespace. The header cell `#` and a separator cell matching `:?-+:?` are not id cells.
- **Well formed.** The id cell fully matches `P[0-9]+[a-z]?`. Every legacy id is well formed.
- **Duplicate.** Two or more id cells with equal text. The message lists every line holding it, in file order, joined by `, `.
- **Next free letter.** For ticket N, the first of `P<N>`, `P<N>b`, `P<N>c`, ... that no id cell on `main` holds.
- **Carried.** As P21 and `review-brief.sh`: a Noted or Dismissed judgment line ending in a cites field that matches the grammar. The `DECISIONS.md` form becomes `DECISIONS\.md [A-Z]?[0-9]+[a-z]?`.
- **Invariant.** Every well-formed id is accepted by the cites grammar. A test holds the two regexes together (test 5.D below).
- The check reads only the source file. `build_knowledge.py` is untouched and still regenerates the slim copy and the index, since it never reads the table.

## Test list

New file `tests/knowledge/provisional-ids.sh`, added to CI and to AGENTS.md's Verifying list. It is already under the ShellCheck glob `tests/*/*.sh`. The seam needs no code change. The script resolves `kb` from its own path, so the test copies `tools/check_knowledge.py` to `$tmp/tools/` and `docs/knowledge/` to `$tmp/docs/knowledge/`. A helper `rows <fixture>` replaces the rows after the Provisional separator in the copy with the fixture's rows, rewrites `core/DECISIONS.md`'s count in the copy's `INDEX.md` to the new line count, runs the copy, and captures stdout and the exit code. Assertions compare the output lines that contain `Provisional` or `"## Provisional"`, plus the exit code. Row 5 goes in `tests/spec-review/review-brief.sh`, which already has the fake-gh harness and earlier-comment fixtures.

1.A `legacy+P110`: the real rows plus `P110`, so ok and exit 0.
1.B `legacy+P110+P110b`: ok, exit 0.
1.C `legacy+malformed`: the real rows plus six rows `P-110`, `P110.2`, `` `P110` ``, `p110`, `110`, empty. Exactly six bad lines with those ids and their line numbers, exit 1.
2.A `legacy+P111+P110` (#111's row first, as after the rebase): ok, exit 0.
2.B `legacy+P111+P110+P110b`: ok, exit 0.
2.C `legacy+P111+P-110`: one bad line for `P-110`, exit 1.
3.A `legacy+P110+P110`: dup(P110; both lines), exit 1.
3.B `legacy+P110+P110b+P110+P110b`: two dup lines (P110, P110b), exit 1.
3.C `legacy+P110+P-110`: one bad line and no dup line, since malformed cells are not compared, exit 1.
4.A `legacy+P110 then P112 appended` (the parent landed below): ok, and the `P110` line text is byte-identical to the fixture's.
4.B `legacy+P110+P110b then P112`: ok, exit 0.
4.C `legacy+P112+P110.2`: one bad line, exit 1.
5.A in `tests/spec-review/review-brief.sh`, fixture `previous-p110.md` (previous.md with the P17 cite replaced by `P110`): the brief has the item, and `settled: carried 2, dropped 0`-style counts match the fixture.
5.B fixture `previous-p110b.md` (`cites: DECISIONS.md P110b`): the item is carried. This fails before the grammar change.
5.C fixture `previous-pdash.md` (`cites: DECISIONS.md P-110`): the item is absent from both briefs and the dropped count rises by one.
5.D in `provisional-ids.sh`: every id the check accepts in fixtures 1.A and 1.B, including all legacy ids, matches the `DECISIONS.md` alternative extracted with `grep` from `review-brief.sh:248`. This is the invariant.
6.A `legacy+P17` (the new row): dup(P17; 83 and the new line), exit 1.
6.B `legacy+P17+P17b`: dup(P17) only, exit 1.
6.C `legacy+P17.1`: one bad line, exit 1.
7 `legacy+P31+P31`: dup(P31), exit 1.
8 `no-heading` (the copy's `## Provisional` line reworded to `## Provisionals`, line count kept): the none line, exit 1.
9 `head` (the unmodified copy): `knowledge ok:` and exit 0. The real repository run in CI stays the same check.

## Usage (how a lane takes its id)

The sentence for `template/docs/agents/issue-tracker.md` (copied to `docs/agents/issue-tracker.md`), as a bullet under Conventions:

> - **Record a decision**: a row a PR adds to a shared decisions table (Factory918's Provisional rows in `DECISIONS.md`) takes the id `P<N>`, where N is the ticket the PR closes (`P110`); the ticket's second and third rows take `P110b` and `P110c`, and an id already on `main` moves to the next free letter. Never take the highest id plus one: two PRs from the same base both take it, and every rebase renumbers it and the reviews that cite it.

The sentence for `template/.agents/skills/poteto-mode/playbooks/ticket.md`, a standalone paragraph after the `**Reply:**` line of `### Ticket` and before `### Quick ticket`. Its own paragraph, so #105's rewrite of the numbered steps rebases around it:

> **A decision this ticket records** goes in `DECISIONS.md` under Provisional as `P<N>`, N this ticket's number (a second row `P<N>b`); `python3 tools/check_knowledge.py` refuses a duplicate or any other form (`docs/agents/issue-tracker.md`, "Record a decision").

One clause in `docs/knowledge/core/DECISIONS.md`'s intro sentence (line 10), the place a writer is standing when they add the row: "Add to "Provisional", under the id `P<ticket>`, when you decide ...". Then run `build_knowledge.py`.

The PR's own decision is its first new-form row, `| P110 | Provisional row ids | P<ticket>, then P<ticket>b ... | ... |`.

Call sites as a lane sees them:

```
# on branch feat/110-..., ticket #110, one decision
| P110 | Provisional row ids | ... | ... |
python3 tools/check_knowledge.py          # knowledge ok: 57 files

# a judgment item that settles on it, carried into later rounds
2. [S1] **Id could collide.** Tickets own their number. cites: DECISIONS.md P110b
```

## Signatures

`tools/check_knowledge.py`, one block after the per-file loop, sharing `problems`:

```python
# A Provisional id is P<ticket>, a letter added for the ticket's second and third rows, so no two
# parallel PRs take the same one and no rebase changes it (#110). review-brief.sh's cites grammar
# accepts every such id; tests/knowledge/provisional-ids.sh holds the two together.
dec = (kb / "core" / "DECISIONS.md").read_text().split("\n")
start = next((i for i, l in enumerate(dec) if l.startswith("## Provisional")), None)
if start is None:
    problems.append('core/DECISIONS.md: no "## Provisional" heading')
else:
    ids = {}  # id -> [line numbers]
    for n, line in enumerate(dec[start + 1:], start + 2):
        if line.startswith("#"): break
        if not line.startswith("|"): continue
        cell = line.split("|")[1].strip()
        if cell == "#" or re.fullmatch(r":?-+:?", cell): continue
        if not re.fullmatch(r"P[0-9]+[a-z]?", cell):
            problems.append(f"core/DECISIONS.md:{n}: Provisional id '{cell}' is not P<ticket> or P<ticket> and a lowercase letter")
        else:
            ids.setdefault(cell, []).append(n)
    problems += [f"core/DECISIONS.md: Provisional id {i} is on lines {', '.join(map(str, ns))}"
                 for i, ns in ids.items() if len(ns) > 1]
```

The docstring's first line gains ", and every Provisional id in DECISIONS.md is unique and P<ticket>[letter]".

`template/.agents/skills/spec-review/scripts/review-brief.sh:248`:

```bash
cites='cites: (user: "[^"]+" on #[0-9]+|DECISIONS\.md [A-Z]?[0-9]+[a-z]?|#[0-9]+ comment [0-9]{4}-[0-9]{2}-[0-9]{2}|#[0-9]+ '"$ref"')$'
```

The comment above it gains "a Provisional id may end in a letter (P110b, #110)".

`tests/knowledge/provisional-ids.sh`: `rows <fixture-rows-file>` sets `$out` and `$code`, and `has`/`lacks` work as in `tests/spec-review/review-brief.sh`. `.github/workflows/factory-ci.yml` gains a step `bash tests/knowledge/provisional-ids.sh` named "check_knowledge.py refuses a duplicate or malformed Provisional id".

## Module map

- `tools/check_knowledge.py`: the check (decisions 4 to 7).
- `template/.agents/skills/spec-review/scripts/review-brief.sh`: the grammar (decision 2).
- `tests/knowledge/provisional-ids.sh` (new): rows 1 to 4 and 6 to 9, plus 5.D.
- `tests/spec-review/review-brief.sh`: 5.A to 5.C.
- `template/docs/agents/issue-tracker.md` and `docs/agents/issue-tracker.md`, `template/.agents/skills/poteto-mode/playbooks/ticket.md`, `docs/knowledge/core/DECISIONS.md`: the rule and row P110, then `build_knowledge.py`.
- `.github/workflows/factory-ci.yml`, `AGENTS.md` Verifying: the new test.
- Unchanged: `spec-review/SKILL.md` and its patch, `build_knowledge.py`, every existing id and prose mention.

## Problem

Provisional rows were numbered max+1 at branch time. Parallel PRs from one base took the same number, and every chain rebase renumbered rows, their prose mentions and the `cites:` in posted review comments. That settled review items silently stopped pointing at the right row. The constraints are these. Legacy ids P1 to P30 are cited in closed PRs and must not move. The cites grammar in `review-brief.sh` decides which items carry, and it fails silently on an id it does not match. `SKILL.md` is vendored and changes only through a patch. `build_knowledge.py` never reads the table.

## Shape

The data structure is the id itself. Deriving it from the ticket removes the shared counter, so there is nothing to serialize (per separate-before-serializing-shared-state: the sharing is eliminated, not locked). The one remaining shared thing is the table's end, where two appends conflict textually. That conflict is resolved by keeping both rows and no longer touches ids. The check is the boundary guard (per boundary-discipline). It validates the only human-and-agent-written input, the id cell, where CI already runs. The grammar extension keeps one rule across the writer (the check) and the reader (`review-brief.sh`). A test holds the two regex copies together, because they live in two languages (per encode-lessons-in-structure). The surface a lane sees is one sentence and one error message that says the correct form. Legacy handling costs nothing because the legacy ids are already well formed (per laziness-protocol).

## Synthesis decision

Left for arena.

## Tradeoffs accepted

- We accept a textual merge conflict at the table's end between parallel PRs in exchange for keeping the record in one file. Resolving it is "keep both" and changes no id.
- We accept that a single max+1 id (`P31`) passes the check in exchange for not needing the network or a floor that refuses real tickets. Only a second one collides.
- We accept two copies of the id grammar (Python and the bash regex) in exchange for no shared config between a tool and a vendored skill's script. Test 5.D holds them together.
- We accept that ids are not in numeric order in the table (P30, then P110, P103, ...). The table was already out of order (P23 before P22, P2 after P22).

## Alternatives considered

Covered under Decisions, "Rejected". The strongest contender was per-ticket files merged at build time. It hides the conflict completely but exposes a new layout to every reader and writer and a new build path, for a conflict that costs one "keep both".

## Open questions and risks

- CI on a PR runs once per push. If #111 merges while #110's run is already green, and both hold `P110` (row 3, outside the path), nothing reruns #110 before it merges. Does Manuel want a duplicate caught on `main`'s push run (today's behavior for any check) accepted as enough, given no branch protection (P3)?
- `issue-tracker.md` is the template's copy. Does a project keep Provisional rows at all? `knowledge/SKILL.md:26` tells a project agent to record under Provisional in `DECISIONS.md`, but a project's only copy is the generated `docs/factory918/DECISIONS.md`, which `apply` overwrites. The sentence is written to hold in both places, and it names the check only in the factory's ticket playbook sentence. The project question predates this ticket and could be its own ticket.
- Should the `(promoted)` stub convention be written next to the rule ("a promoted row stays as a stub so its id stays taken")? P17's own text says it. I left it unwritten.

## Next implementation step

Write `tests/knowledge/provisional-ids.sh` with the fixtures of rows 1 to 9, watch 1.C, 3.A, 6.A, 7 and 8 fail against today's `check_knowledge.py`, then add the block.
