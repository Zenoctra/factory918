# Ticket #110, architect Phase B, candidate "lower" (Claude Opus 5, effort high)

The design has state: a file two lanes write and an exit code a third reads. The first deliverable is
the scenario table, then the contract, then the test list, then the usage and the signatures.

## Decisions, up front

Six decisions the ticket asked for, each with its reason. The rest of the document is these six worked
out.

1. **Id format: `P` followed by the ticket's number.** `P110` for a row recorded by the work on #110.
   It is derived, not allocated, so nothing is read from the file to choose it, two lanes on two
   tickets cannot collide by construction, and a rebase moves the row without touching the id. Chosen
   over `P-<ticket>` (the ticket's own example) because `P110` is the shape the legacy ids already
   have: `P1` to `P30` satisfy the new format without a grandfather list, and the `cites:` grammar
   matches it today with no change. `P-110` would need both.
2. **A second row from the same ticket takes the next letter from `b`.** `P110`, then `P110b`,
   `P110c`. The bare id is implicitly the `a`, so the first row is never renamed when a sibling
   appears later, and the common case (one row) carries no suffix. Ticket #91 recorded P28 and P29,
   two unrelated rules, so forcing one row per ticket was rejected as a design that merges decisions
   that have nothing to do with each other. The siblings are allocated by one lane inside one PR
   (one ticket is one PR, Ticket step 4), so the letter needs no coordination either.
3. **The `cites:` grammar changes, in one character class.** `review-brief.sh:248` becomes
   `DECISIONS\.md [A-Z]?[0-9]+[b-z]?`. Without it, `cites: DECISIONS.md P110b` matches nothing and the
   item is dropped from the next round's briefs silently, which is the failure P21 and #90 exist to
   prevent. `P110` alone would need no change, but a grammar that admits the first row of a ticket and
   drops its second is a trap. `spec-review/SKILL.md:137` documents the field as `DECISIONS.md <row id>`
   with examples `P17`, `19`; the examples gain `P110b`, through
   `patches/mattpocock/spec-review.SKILL.md.patch` (a one-line change inside a `+` line, so the hunk's
   context and line counts are untouched and `./factory918.sh sync` stays clean).
4. **Legacy P1 to P30 keep their ids and need no special case.** Every one of them matches
   `^P[0-9]+[b-z]?$`, including the promoted stub `P17`, so the check treats them exactly as it treats
   a new row: shape-valid and unique. There is no grandfather list, no cut-off number, and no dated
   exception to maintain. That is the whole reason the format is `P<ticket>` and not something prettier.
5. **The check lives in `tools/check_knowledge.py`,** as one pure function over the text of
   `docs/knowledge/core/DECISIONS.md` whose result joins the existing `problems` list. It is the tool
   CI already runs before `build_knowledge.py`, it already exits 1 on a list of problems, and putting
   the check in the builder instead would mean a tool that rewrites files deciding whether to refuse
   one. The **id cell** is the text between the first and second `|` of a line inside the Provisional
   section, stripped; only those two pipes matter, so a pipe or a `P25` mention anywhere else in the
   row cannot be read as an id.
6. **Yes, the check also refuses a malformed new id,** in the same pass and before the duplicate test.
   It costs one regex and it is what catches the near miss that duplicate detection cannot see: a
   lowercase `p110`, a `P-110`, a `P110a`, a stray space, an empty cell. A row that is off-form is
   reported per row and never also reported as a duplicate, so one mistake prints one line.

What the check deliberately does not do: it does not know which ticket a row belongs to, so it cannot
tell that `P31` (an agent falling back to max+1) is wrong on a single branch. That is prose's job, and
the net catches the pair the moment the two branches meet, which is the moment the old system renumbered
in silence. Stated as a tradeoff below, not hidden.

## Testing decisions

### Legend

Cell = what is printed / exit code / what the caller does next. The caller is CI
(`.github/workflows/factory-ci.yml:33`, on every PR and on every push to `main`) or the lane running the
check by hand.

- `OK` = `knowledge ok: <n> files` / 0 / CI goes on to `build_knowledge.py` and `git diff --exit-code`.
- `DUP(x, m)` = `DECISIONS.md line <n>: Provisional id x is already on line m; an id comes from its
  ticket (P<ticket>, then b, c, ... for a second row of the same ticket), so rename this row and its
  mentions` / 1 / CI fails; the lane renames its own row to its ticket's id and fixes the mentions it
  wrote. Printed on stdout with the other problems, one per line, as the script already prints them.
- `BAD(x)` = `DECISIONS.md line <n>: Provisional id 'x' is not P<ticket> with an optional b-z sibling
  letter` / 1 / CI fails; the lane fixes the cell.
- `GONE` = `DECISIONS.md: no Provisional row was read; the '## Provisional' section is missing or its
  table changed shape` / 1 / CI fails; whoever changed the section's shape restores it or updates the
  check. This is the cell that keeps the check from becoming a silent no-op.
- `CARRIED` / `DROPPED` = `review-brief.sh` matched (or did not match) the id in a `cites: DECISIONS.md
  <id>` field on a Noted or Dismissed judgment item; the `settled: carried <c>, dropped <d>` line counts
  it, and a carried item is pasted into the next round's briefs as settled.

`P110` stands for the id of ticket #110's first row throughout, `P111` for another lane's ticket.

### The table

| Situation | A. the row alone, on its lane's branch | B. beside the other lane's row (after the rebase, or on `main` once both merged) | C. the same id on two rows | E. `review-brief.sh` on `cites: DECISIONS.md <this id>` |
|---|---|---|---|---|
| 1. `P110`, the first row of ticket #110 | `OK` / 0 / the PR's CI is green on this step | `P110` and `P111` both present: `OK` / 0 / the rebase changed no id and no mention | `DUP(P110, m)` / 1 / rename the newer row | `CARRIED` / the item is settled in every later round |
| 2. `P110b`, a second row of the same ticket | `OK` / 0 | `P110` and `P110b` both present: `OK` / 0 / the sibling letter is chosen inside one PR, so the pair is never split across branches | `DUP(P110b, m)` / 1 | `CARRIED`, and only because the grammar gained `[b-z]?`; under today's grammar it would be `DROPPED` with no message on the item, which is why the change is not optional |
| 3. A legacy row, `P1` or `P30`, untouched | `OK` / 0 / no row is rewritten, and every posted `cites: DECISIONS.md P25` stays valid | `OK` / 0 | `DUP` as row 1 / 1 | `CARRIED` / unchanged from today; the grammar already matched it |
| 4. The promoted stub, `P17` (`(promoted)` in the Decision cell) | `OK` / 0 / a retired id is still an id and still occupies its number | as 3B | as 3C | `CARRIED` / pinned by an existing assertion in `tests/spec-review/review-brief.sh` |
| 5. An off-form id: `P-110`, `p110`, `P110a`, `110`, `P110B`, or an empty cell | `BAD(x)` / 1 / fix the cell | `BAD(x)` / 1 / unchanged by the other row's presence | two off-form rows print `BAD(x)` twice and no `DUP`: the shape is tested first, so one mistake prints one line per row | `DROPPED`, counted in `settled: carried 0, dropped 1`; unreachable in practice, because the check refuses the row before the PR is green |
| 6. The section's header (`\| # \|`) and separator (`\|---\|`) lines | skipped, not ids: `OK` / 0 | as 6A | as 6A | n/a |
| 7. A row whose Decision or Reason cell names another id (`see P25`) or holds an escaped pipe | skipped, not ids: `OK` / 0 / only the text between the first two pipes is read | as 7A | as 7A | n/a |
| D. No Provisional row is read at all: the `## Provisional` heading was renamed or removed, or the table lost its leading-pipe shape | `GONE` / 1 / restore the section or update the check | as D-A | as D-A | n/a |

### Contract

Every term the cells use.

**The Provisional section** of `docs/knowledge/core/DECISIONS.md`: the lines from the first line
beginning `## Provisional` up to the next line beginning `## ` or the end of the file. Nothing outside
it is read, so the Settled table and the "what the factory assumes it owns" table above it hold no ids.

**A row** is a line inside that section that starts with `|`.

**The id cell** is `line.split("|")[1].strip()`: the text between the first and second `|`, with
surrounding spaces removed. A `|` in a later cell cannot move it, and neither can a `P<n>` written in
prose inside the Decision or Reason cell.

Two id cells are **not ids** and are skipped: the header, whose cell is exactly `#`, and the separator,
whose cell is non-empty and made only of `-`, `:` and spaces. Every other row's id cell is an id,
including an empty one, which is then reported as off-form rather than ignored.

**A well-formed id** matches `^P[0-9]+[b-z]?$`: `P`, the ticket's number, and an optional sibling
letter from `b` to `z`. The bare id is the ticket's first row. A ticket that records a second row uses
`b`, a third `c`, in the order the rows are appended. `a` is not used, because the bare id is already
the first row and no row should have to be renamed when a sibling arrives. Legacy rows P1 to P30 were
allocated as a running count before this rule and are well-formed under it unchanged.

**A duplicate** is an id cell equal, character for character, to one already read further up the
section. The first occurrence is reported as the older row by line number; the second is the one the
message asks to rename, because the lane that is failing CI owns the row it just wrote.

**How a lane gets its id**: from the ticket number it was given, with no read of `DECISIONS.md` and no
allocation. The check is a net, not the allocator. It cannot know which ticket a row belongs to, so a
row numbered by the old max+1 habit (`P31`) is well-formed and unique on its own branch and is caught
only when it meets the other lane's identical `P31`, on the rebase or on `main`. The format prevents;
the check proves.

**Exit codes** are the script's existing ones: 0 with `knowledge ok: <n> files`, 1 with every problem
line printed on stdout. The id problems join the same list as the INDEX, line-cap and mini-TOC problems
and are printed with them.

**Unchanged by this design**: `build_knowledge.py` never reads a table's contents, so the slim copy in
`template/docs/factory918/DECISIONS.md` and `docs/knowledge/INDEX.md` regenerate with no hand edit,
whatever the id says. The generated copies are not checked separately; the source is checked, and CI's
`build_knowledge.py && git diff --exit-code` already proves the copies match the source.

### Test list

One assertion per cell, in cell order. New file `tests/knowledge/provisional-ids.sh`, in the style of the
existing bash tests, added to `.github/workflows/factory-ci.yml` beside the knowledge step and to
`AGENTS.md`'s verification list.

The fixture: `cp -R docs/knowledge "$tmp/docs/knowledge"` and `cp tools/check_knowledge.py
"$tmp/tools/"`, because the script resolves the knowledge base from its own path. Each case mutates
`$tmp/docs/knowledge/core/DECISIONS.md` with an in-place `sed` on an existing row's id cell, so the file
keeps its line count and the INDEX and line-cap checks stay quiet. Assertions are substring-on-output
plus exit code (`has`, `lacks`, as `tests/spec-review/review-brief.sh` writes them), so a case that
unavoidably trips another check still asserts its own line.

1. **1A** unmutated copy: output is `knowledge ok:`, exit 0. Fixture: the repository's own tree.
2. **1B** two ids rewritten to `P110` and `P111`: `knowledge ok:`, exit 0.
3. **1C** two ids rewritten to `P110`: the `is already on line` message naming `P110`, exit 1.
4. **2A** one id rewritten to `P110b`: `knowledge ok:`, exit 0.
5. **2B** two ids rewritten to `P110` and `P110b`: `knowledge ok:`, exit 0.
6. **2C** two ids rewritten to `P110b`: the duplicate message naming `P110b`, exit 1.
7. **3A/4A** unmutated copy asserts no output line contains `Provisional id`, exit 0: every legacy row
   and the `P17` stub are well-formed as they stand. (Same fixture as 1A, a second assertion on it.)
8. **3C** two ids rewritten to `P25`: the duplicate message naming `P25`, exit 1.
9. **5A** one id rewritten to `P-110`: the `is not P<ticket>` message showing `'P-110'`, exit 1. Then
   the same for `p110`, `P110a`, `110` and an emptied cell, each asserting its own value in the message.
10. **5C** two ids rewritten to `P-110`: the off-form message appears twice and `is already on line`
    appears zero times, exit 1.
11. **6A** unmutated copy asserts the message never names `'#'` or `'---'`, exit 0.
12. **7A** ` (see P25)` appended inside a Reason cell of one row: `knowledge ok:`, exit 0. Then a row
    whose Reason cell gains an escaped pipe: `knowledge ok:`, exit 0.
13. **D** the `## Provisional (added by agents; Manuel promotes or overrules)` heading rewritten to
    `## Agent decisions (added by agents; Manuel promotes or overrules)`: the `no Provisional row was
    read` message, exit 1. The mini-TOC problem for that heading also prints; the assertion is on the
    id message and the exit code.

In `tests/spec-review/review-brief.sh`, one new assertion beside the existing `DECISIONS.md P17`,
`P1` and `P16` cases:

14. **2E** a previous comment whose Dismissed item ends `cites: DECISIONS.md P110b`: the brief carries
    that item, and the `settled: carried` count includes it. Fixture: the existing `previous.md`
    fixture with one item's citation changed. Cells 1E, 3E and 4E are the assertions that file already
    holds (`P1`, `P16`, `P17`); 5E needs none, since an off-form id never reaches a posted comment.

## Usage

The sentence the two documents carry, one wording in both places:

> A Provisional row's id is `P` and the ticket's number, `P110` for work on #110; a second row recorded
> by the same ticket takes the next letter from `b`, `P110b`. Never the next free number: two lanes
> branched from the same base both take it, and every rebase then renumbers the rows above it and every
> mention of them. Rows P1 to P30 predate the rule and keep their ids. `tools/check_knowledge.py`
> refuses a duplicate or off-form id.

Three placements, in order of how much they matter.

- `template/docs/agents/issue-tracker.md`, a new bullet at the end of `## Conventions`, labelled
  **Record a decision** like the bullets around it. Then copied to `docs/agents/issue-tracker.md`, which
  is an identical copy.
- `template/.agents/skills/poteto-mode/playbooks/ticket.md`, appended as the last sentence of step 8,
  where the record lands with the PR. No new step and no renumbering, because "Ticket step 5" and
  "step 6" are quoted in four patches and in `review-brief.sh` (the constraint P25 recorded). Ticket
  #105 rewrites much of this file in a parallel PR; a sentence appended to the end of one line is the
  smallest thing to carry across that rebase, and if #105 lands first with step 8 rewritten, the
  sentence goes to `playbooks/opening-a-pr.md` instead, which #105 does not touch.
- `docs/knowledge/core/DECISIONS.md`, one line directly under the `## Provisional` heading, above the
  table. Beyond criterion 3 and worth its two lines: that heading is what the writer has open at the
  moment of choosing an id, and a rule that lives only in the two other files is the rule that gets
  missed. `build_knowledge.py` updates the line count and the mini-TOC offsets itself.

A lane's actual sequence, for the three readers of this design: the lane knows its ticket number from
step 1 of the Ticket playbook, writes `| P110 | ... |` at the end of the Provisional table, and runs
`python3 tools/check_knowledge.py` before the PR. Nothing is read to choose the id and nothing is
reserved.

## Signatures

`tools/check_knowledge.py`, one module-level constant, one pure function, one call site. The existing
25 lines are untouched apart from the call.

```python
PROVISIONAL_ID = re.compile(r"^P[0-9]+[b-z]?$")

def provisional_problems(text):
    """DECISIONS.md's Provisional ids: each is `P` and its ticket's number with an optional b-z
    sibling letter, and each is used once. The id comes from the ticket, so two lanes cannot pick the
    same one; this catches the pair the moment their branches meet, and an off-form id before that."""
    ids, problems, section = {}, [], False
    for n, line in enumerate(text.split("\n"), 1):
        if line.startswith("## "):
            section = line.startswith("## Provisional")
        if not section or not line.startswith("|"):
            continue
        cell = line.split("|")[1].strip()          # only the first two pipes; prose cannot shift it
        if cell == "#" or (cell and not cell.strip("-: ")):
            continue                               # the header row and the separator row
        if not PROVISIONAL_ID.match(cell):
            problems.append(f"DECISIONS.md line {n}: Provisional id {cell!r} is not P<ticket> with an optional b-z sibling letter")
        elif cell in ids:
            problems.append(f"DECISIONS.md line {n}: Provisional id {cell} is already on line {ids[cell]}; an id comes from its ticket (P<ticket>, then b, c, ... for a second row of the same ticket), so rename this row and its mentions")
        else:
            ids[cell] = n
    if not ids and not problems:
        problems.append("DECISIONS.md: no Provisional row was read; the '## Provisional' section is missing or its table changed shape")
    return problems
```

The call site, after the existing `for f in rows:` loop and before the `print`:

```python
problems += provisional_problems((kb / "core" / "DECISIONS.md").read_text())
```

`review-brief.sh:248`, the one changed character class:

```sh
cites='cites: (user: "[^"]+" on #[0-9]+|DECISIONS\.md [A-Z]?[0-9]+[b-z]?|#[0-9]+ comment [0-9]{4}-[0-9]{2}-[0-9]{2}|#[0-9]+ '"$ref"')$'
```

`patches/mattpocock/spec-review.SKILL.md.patch`, inside its added line for the `cites:` field, the
examples only:

```
-`DECISIONS.md <row id>` (`P17`, `19`)
+`DECISIONS.md <row id>` (`P110`, `P110b`, `P17`, `19`)
```

The vendored `template/.agents/skills/spec-review/SKILL.md` is edited identically, so
`./factory918.sh sync && git diff --exit-code` is clean.

## Rationale

### Problem

Five concurrent PRs appended rows to one table and each chose its id by reading the table at branch
time, which is a read of shared state at the one moment every lane sees the same value. The result was
P25, P26, P26, P26, P27, resolved by renumbering at every rebase, and a renumber invalidates every
`cites: DECISIONS.md P<n>` in a posted review comment and every `P<n>` in prose across the repository.
The constraints the fix has to honor: existing ids never change, because comments on closed PRs cite
them; `build_knowledge.py` must keep regenerating the slim copy and the index with no hand edit;
`review-brief.sh:248` matches `DECISIONS\.md [A-Z]?[0-9]+` and drops a non-matching citation with no
message on the item; `spec-review/SKILL.md` is vendored and reachable only through its patch, and
`./factory918.sh sync` must leave `git status` clean.

### Usage (caller's view)

Above, under **Usage**. The caller is a lane writing one row, and its whole interaction is "the id is
`P` plus your ticket number". The second caller is CI, whose interaction is the exit code it already
reads.

### Shape

The load-bearing decision is that the id is derived from data the lane already holds rather than
allocated from the file every lane shares. That removes the sharing instead of serializing it
(per separate-before-serializing-shared-state); there is no counter, no lock file, no reservation, and
no read of `DECISIONS.md` before writing to it. Rebase stability follows for free: the id depends on
nothing that a rebase can move.

The second decision is that the derived format is a superset of the format the legacy ids already have.
`P1` through `P30` pass `^P[0-9]+[b-z]?$` unchanged, so there is no grandfather list, no cut-off, and
no dated exception (per laziness-protocol and subtract-before-you-add: the cheapest way to keep thirty
rows valid is to choose a format they already satisfy). The same choice is what keeps `review-brief.sh`
matching `P110` with no change at all; only the sibling suffix costs a grammar edit.

The check is a pure function of the file's text with the I/O at the call site, so the logic is testable
by substituting text and the shell stays thin (per boundary-discipline). Validation happens at the one
boundary where a human or an agent writes a markdown table by hand. The invariant that cannot be
encoded in a type here is encoded in a check that CI already runs on every PR and every push to `main`
(per encode-lessons-in-structure): the mid-mortem's lesson becomes an exit code rather than a fourth
paragraph of prose.

Interface depth: the public surface is one function name and one regex, and behind it sits the whole
question of what a row is, which lines are not rows, and what an id cell is when prose contains pipes
and other ids. Callers get an exit code and a message that says what to do. The design deliberately does
not know about tickets, GitHub or git; it reads one file and compares strings, which is why it runs
offline, in a worktree, and in a project that has no `DECISIONS.md` history at all.

Running it twice changes nothing and reports the same thing (per make-operations-idempotent); there is
no state to converge.

### Tradeoffs accepted

- We accept that a lane which ignores the rule and writes `P31` passes its own PR's CI, in exchange for
  a check that needs no network, no ticket lookup and no list of live ticket numbers. The pair is caught
  when the branches meet, which is exactly where the old system renumbered in silence.
- We accept a markdown merge conflict when two lanes append rows to the end of the same table, in
  exchange for never renumbering. The resolution is "keep both rows, any order", and no mention
  anywhere else in the repository changes.
- We accept an id that no longer says when a decision was made, in exchange for one that says which
  ticket made it. Row order already fails to be numeric (P23 sits before P22), so the running count was
  not carrying that meaning either.
- We accept editing a vendored skill's patch for one parenthetical, in exchange for a documented `cites:`
  form that a reviewer can write without guessing.
- We accept a maximum of 25 rows from one ticket.

### Alternatives considered

- **`P-<ticket>`, the ticket's own example.** Hides no complexity the chosen form hides, and exposes
  more: it fails `^P[0-9]+[b-z]?$`, so the legacy rows would need a grandfather list, and it fails
  `DECISIONS\.md [A-Z]?[0-9]+`, so every citation of a new row needs the grammar changed even for the
  first row. It lost on cost alone.
- **Keep the running number, add a reservation step** (a lock file, a `.claude/state/` counter, or an
  id claimed on the ticket). Serializes the sharing instead of removing it, adds a file two actors
  write to fix a file two actors write, and a crash between claim and commit leaks a number. Rejected.
- **One row per ticket, siblings forbidden.** Would remove the suffix and the grammar change entirely,
  but #91's P28 and P29 are two unrelated rules and merging them would have produced a row that says
  two things. A record whose shape lies about the decisions in it is worse than a regex edit.
- **A directory of per-row files assembled by `build_knowledge.py`.** Removes the merge conflict too,
  and costs a new source layout, a new build path, a rewrite of how the orchestrator edits the record,
  and a contradiction with "core documents are edited directly". Far past the smallest thing that meets
  the criteria.
- **Check ids in `build_knowledge.py` rather than `check_knowledge.py`.** The builder rewrites files;
  a tool that rewrites and refuses is two jobs, and CI runs the checker first for that reason.

### Open questions and risks

- Should the rule also cover the `#` column header itself, renaming it from `#` to `Id`, so a reader
  does not read the column as a count? It costs one cell and a rebuild, and it would make the check's
  "skip the header" rule depend on a different literal.
- Ticket #105 rewrites much of `ticket.md` in a parallel PR. Is the trailing sentence on step 8 the
  right anchor, or should the Ticket playbook's copy of the rule go to `playbooks/opening-a-pr.md`,
  which #105 does not touch?
- Is a maximum of 25 sibling rows per ticket acceptable, or should the suffix be numeric (`P110.2`)
  against the day a ticket records more? The numeric form costs a wider `cites:` grammar (`\.[0-9]+`)
  for a case that has never occurred.
- Rows P1 to P30 keep ids that mean nothing now, and P6 is simply absent. Should the Provisional
  heading carry one dated line saying the ids below 100 are a retired running count, so a reader does
  not infer a missing row was deleted?

### Next implementation step

Write `tests/knowledge/provisional-ids.sh` with the fixture copy and assertions 1 to 13 against the
current `check_knowledge.py`, so the cells fail before `provisional_problems` exists.
