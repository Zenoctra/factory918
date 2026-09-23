# Spec review brief

Read nothing beyond this brief unless a finding needs the code around a hunk, and then read that one function or section, not the file. Run nothing.

## Commits

52ccd8e Say where a design hole goes, in the skill, the ladder and the playbooks
8b3de0a Return a design hole to architect and restart the review rounds
cc36280 Test the design-hole restart from ticket #90's tables before the scripts

## Changed files

 SOURCES.md                                         |   6 +-
 patches/mattpocock/spec-review.SKILL.md.patch      |  17 ++-
 patches/pstack/babysit/SKILL.md.patch              |   3 +-
 .../pstack/poteto-mode/playbooks/babysit.md.patch  |   6 +-
 template/.agents/skills/babysit/SKILL.md           |   1 +
 .../skills/poteto-mode/playbooks/babysit.md        |   2 +
 .../.agents/skills/poteto-mode/playbooks/ticket.md |  13 +-
 template/.agents/skills/spec-review/SKILL.md       |  15 +-
 .../skills/spec-review/scripts/review-brief.sh     |  64 ++++++--
 .../skills/spec-review/scripts/review-comment.sh   |  92 +++++++++---
 template/docs/agents/review-ladder.md              |   2 +-
 tests/spec-review/no-stale-wording.sh              |  11 +-
 tests/spec-review/review-brief.sh                  | 157 ++++++++++++++++++-
 tests/spec-review/review-comment.sh                | 166 ++++++++++++++++++++-
 14 files changed, 483 insertions(+), 72 deletions(-)

## Diff

The diff is 966 lines; read it from `.scratch/review/69bd412/diff`.

## The ticket (#90)

## Problem

Observed (agent): on PR #87 the core of the new script was redesigned in each of three fix rounds, by the writer under the orchestrator's brief, without returning to `architect`. The review playbook's only path for a finding is a fix on the PR, so a finding that changed what the mechanism meant was treated like an implementation bug, and each rewrite gave the next round new surface. On PR #92 the definition below was applied by hand: five hard findings, none changed the table, all fixed on the PR; the one design hole was found by the writer before review and returned to a narrow architect re-run scoped to the cell. Two lessons from that run shape the definition: the hole that occurred changed no cell's text but the contract's meaning of "a PR's own commits", and two findings (a detached HEAD, a 101st open PR) had no row yet were refusals under the existing "could not run" clause, not holes.

## Decision

> user: you mentioned 3 different designs that got proposed and every review agent changed which one it was grading against. That is a blatantly unnacceptable failure mode. Its a design practice mistake and should never have been allowed to happen on point of policy or principle.

> user: if review brings up a design hole in the system, then it starts all 3 reviews over. MEaning 3 more not just however many were left before the rereview.

> agent: a finding is a design hole when fixing it changes the scenario table, a cell's expected outcome or a new row or column. It is an implementation bug when the table stands and the code fails a cell. (amended 2026-09-21 after PR #92: or the meaning of a term the cells use; a refusal under an existing could-not-run clause is not a hole)

> user: Are you saying scenario table and usage/signature sketch are safe(er) things to automatically send back to the architect, but criterion change is not? The criterion were designed by an AI to begin with. So long as the architect and the orchestrator knows that the intent of the ticket is more important than any one criterion, I dont see why that shouldnt kick back too.

> agent: Yes to all three, and the caveat was about sharpness, not safety. A table cell or a signature is checkable line by line and a criterion is coarser, so more holes of that kind will slip past a reviewer. Test for all three anyway.

## Acceptance criteria

- [ ] The definition, in `spec-review` step 5 and `docs/agents/review-ladder.md`: a finding is a design hole when its fix changes the artifact the work was built against rather than the code that implements it. Three artifacts, every ticket has at least one (#89): the scenario table (a cell's expected outcome, a new row or column, or the contract's meaning of a term the cells use, such as what counts as in flight, a named path, a covering go); the usage and signature sketch under `## Design` (a signature, a type, or how a caller uses it); the acceptance criteria (what a criterion asks for). The ticket's intent, its What to build or Decision quotes, outranks any one criterion: a criterion that must change is a hole, and architect re-derives it from the intent. A refusal added under an existing could-not-run clause is not a hole. Detection is sharpest for a table and softest for a criterion; all three are tested for.
- [ ] Every Would-break and Fails-open item in both reports carries a `spec:` line naming what it rests on: `table <row>/<column>`, `design <signature>`, or `criterion <k>` (the k-th checkbox); `review-brief.sh` writes that rule into both briefs, and `review-comment.sh` refuses a counted item without it.
- [ ] The judgment can mark an Act on item `hole: <the spec reference>` the way `fixed:` and `ticket:` work; `review-comment.sh` refuses the mark on an item without a `spec:` reference, leaves it out of the count, and prints `restart` on its own line.
- [ ] A design hole is never fixed on the PR: the Ticket playbook returns the work to `architect` Phase B scoped to the cell, signature or criterion, with the finding and the artifact as grounding (two runners; the judge is skipped when they converge), the artifact on the ticket is amended with a dated line (a criterion by re-deriving it from the intent), and the redesigned work is reviewed from round one; `review-brief.sh` reads the restart from the PR's comments (a comment containing the `restart` line resets the count) and refuses nothing it did before.
- [ ] A spec reference is citable in the judgment grammar as `cites: #N table <row>/<column>`, `cites: #N design <signature>` or `cites: #N criterion <k>`, so a Noted or Dismissed item resting on one carries forward as settled.
- [ ] `tests/spec-review/` covers: a report item missing its `spec:` line, each of the three reference forms, a hole mark on an item without a reference, a restart comment resetting the round, and a cite of a cell carrying forward.
- [ ] `babysit`'s merge-ready condition is unchanged for a PR with no design hole.

## Run under

Until #89, #90, #91 and #93 merge, the lane that runs this ticket follows their rules by hand; following them is part of the ticket. The worked example of every artifact named here is ticket #42 (its `## Testing decisions` section) and PR #92 (its description and its three review comments); read both first. The rules: (1) `how` and `blast-radius` as the Ticket playbook says. (2) When the change has state (a file it reads or writes, exit codes, rounds, or more than one actor) the architect step writes a scenario table before any code: situations down the side, the shape of the input across the top, and in every cell what is printed, the exit code and what the caller does; a cell for an input outside the intended path reads "refused with the tool's own message" and costs no code, and such a cell is cut only after the refusal was run and seen. When the change is code with no state that crosses a function boundary, the architect step posts the usage and signature sketch (the caller's usage first, then types and signatures) on the ticket under `## Design` instead; a prose change has no artifact beyond its acceptance criteria. The table is appended to this ticket's body under `## Testing decisions`, first line "Posted by the agent <date>"; the human edits it if it is wrong, and a stop before implementation is asked for only with the phrase "/architect with checkpoint". (3) The test is written from the table before the implementation, one assertion per cell, and the commit order shows it. (4) A writer that cannot implement a cell as written stops and reports the cell; it never fills it. (5) In review, a finding is a design hole when its fix changes the artifact the work was built against rather than the code that implements it: a table cell or a term its cells use, a signature or a usage in the sketch, or an acceptance criterion (the ticket's intent, its What to build or Decision quotes, outranks any one criterion, so a criterion that must change goes back to architect, which re-derives it from the intent and amends the ticket with a dated line); a design hole is not fixed on the PR but returns to architect, scoped to that cell, and the review count restarts (on this PR with a comment that says "restart" and why); a refusal added under an existing could-not-run clause is not a hole. (6) The Spec reviewer's walk has one line per risk in the blast-radius grounding. (7) A round that fixed a Would-break item is followed by another round even past three, reviewing only the fix (the previous reviewed commit as the fixed point), up to five; at five with Would-break items still found, stop, write a report for the human, mark the PR unfinished and wait. (8) `shellcheck` on every changed shell file before the PR opens. This ticket has state (rounds, comments, markers), so rule 2 yields a table for the round logic: situations are the PR's comment history (no review yet, N rounds, a restart comment, a comment without a round line), inputs are the judgment's marks; cells name what `review-brief.sh` prints and refuses. Its files overlap #89's, #91's and #93's; under the program's go it stacks on the printed PR (the check prints the lowest-numbered first).

## Blocked by

- #42



## Testing decisions

Posted by the agent 2026-09-22

The two tables below are the spec for the round logic and the marks; the contract under them is what the scripts implement. Table A is `review-brief.sh` over the PR's comment history, table B is `review-comment.sh` over one round's reports and judgment. A review finding that changes a cell, adds a row or a column, or changes the meaning of a term the cells use (what counts as a comment, a restart comment, a counted item, a reference) is a design hole under this ticket's own rule: it returns to architect and this section is amended with a dated line. A finding that leaves the tables standing while the code fails a cell is an implementation bug fixed on the PR. A refusal added under an existing could-not-run clause is not a hole. Rounds four and five (#93) and the Spec walk's blast-radius lines (#91) are out of scope; no cell depends on them. Amended 2026-09-22 by the writer's report (PR for #90, before review): the note under table B that the three field greps are `$`-anchored and so mutually exclusive is false for `design <signature>`, which takes the rest of the line; the rule the note states, "only the field that ends the line is a field", is what `review-comment.sh` implements (a `hole:` before a trailing `fixed:` or `ticket:` is text), so it costs code the note said it would not; no cell's outcome and no assertion changed.

## Scenario table

Terms. A "comment" is a comment on the PR by its author whose body has a line starting `act-on items:` (the jq filter at `review-brief.sh:94`); anything else is never fetched and appears in no cell. A "restart comment" is a comment with a line that is exactly `restart` outside fenced text. A "counted item" is a report item under `## Would break` or `## Fails open`. A "reference" is `table <row>/<column>`, `design <signature>` or `criterion <k>` in the contract's grammar. A history is written oldest first; `(2 restart)` is a round-two comment carrying `restart`; `(1')` is the first comment after a restart.

Cell = prints / exit / what the caller does. `X` = the line `restart: the round and the settled items count from the last restart comment`, printed after `ticket:` and before `round:` when a restart comment was fetched. `R(n)` = the line `round: n of 3`. `S(c,d)` = the line `settled: carried c, dropped d without a citation`, printed whenever a comment follows the last restart; "no S" = the line absent and no `## Settled in earlier rounds` in either brief. `paths` = the brief paths, printed last on exit 0. Exit 1 is the existing three-round refusal on stderr, `review-brief: three rounds were run on this PR; the remaining Act on items are fixed here and marked ` `` `fixed: <sha>` `` `, not reviewed in a fourth round`, before any output or state.

**Table A: `review-brief.sh <fixed-point>` over the comment history**

| Situation | A. default (`gh`) | B. `--round N` | C. `--previous FILE` |
|---|---|---|---|
| 1. No comment (no PR, no comments, only strangers') | `R(1)`, no S, `paths` / 0 / round one, unchanged | `R(N)` / 0; N > 3: the refusal / 1 | an empty file: as A |
| 2. One comment (1) with c cited and d uncited Noted or Dismissed items | `R(2)`, `S(c,d)`, `paths` / 0 / unchanged; the cited lines under `## Settled in earlier rounds` in both briefs | `R(N)`, same S / 0 | as A, from the file |
| 3. (1), (2) | `R(3)`, S over both, each distinct line once / 0 / unchanged | `R(N)` / 0 | as A |
| 4. (1), (2), (3), no restart | the refusal / 1 / fix what remains, mark `fixed: <sha>`, rebuild with `review-comment.sh <dir>`; unchanged | `--round 3`: `R(3)`, S / 0 (a rebuild); `--round 4`: the refusal / 1 | as A |
| 5. (1), (2 restart) | `X`, `R(1)`, no S, `paths` / 0 / the redesign's round one | `X`, `R(N)`, no S / 0 | a file holding both, separated as `gh` separates them: as A |
| 6. (1), (2), (3 restart) | `X`, `R(1)`, no S / 0 / round one; not refused: the gate counts what follows the last restart | `X`, `R(N)`, no S / 0 | as A |
| 7. (1), (2 restart), (1'), (2'), (3') | the refusal / 1 / as row 4 for the new series | `--round 3`: `X`, `R(3)`, S over (1'), (2'), (3') only / 0 | as A |
| 8. (1 restart), (1'), (2' restart), (1'') | `X`, `R(2)`, S over (1'') only / 0 / round two of the third series | `X`, `R(N)`, S over (1'') / 0 | as A |
| 9. A comment with no `round:` line (from before the line existed) | counts as round 1: as row 2 / unchanged; with a `restart` line it is a restart comment: row 5 | `R(N)` / 0 | as A |
| 10. A comment by anyone but the PR's author, whatever it holds (`restart`, `round: 3 of 3`, cited items) | not fetched: rows 1 to 9 on the rest / unchanged | same | the file is trusted wholesale, as today |
| 11. `restart` inside a comment's prose (`the writer asked for a restart`), inside a fenced hunk, or with trailing text (`restart: table 2/D`) | not a restart line: rows 2 to 4, no `X` / 0 | same | as A |
| 12. A body with a `restart` line and no `act-on items:` line | not fetched: the round does not reset, no `X` / 0 / post the comment `review-comment.sh` printed, which always carries both lines; a hand-written restart is not a review comment | same | the file is trusted, so it is a restart comment: row 5 |
| 13. Cited Noted or Dismissed items in the restart comment or in any comment before it | dropped with the history: `X`, no S / 0 / a decision still needed is cited again in the new series and carries from its round two | same | as A |
| 14. The last comment's Noted item ends `cites: #42 table 12/A` | `S(1,·)`; the line pasted verbatim under `## Settled in earlier rounds` in both briefs / 0 | same | as A |
| 15. `cites: #42 design overlap.sh N --diff` | carried, as row 14 / 0 | same | as A |
| 16. `cites: #42 criterion 3` | carried, as row 14 / 0 | same | as A |
| 17. A malformed cite (`cites: #42 cell 12A`, `cites: table 12/A` with no `#N`, `cites: #42 criterion 0`, `cites: #42 table 12/A trailing`, `cites:` not last on its line) | dropped, counted in d, as an uncited item today / 0 / nothing; no code | same | as A |

Rerunning any row in the same round prints the same lines: the round and the settled set are functions of the fetched comments alone, and `.scratch/review/<id>` is rebuilt from scratch each run. A `--previous` file carries one comment unless it holds the literal record separator `gh` emits, so the multi-comment rows are tested through the fake `gh` (`pr me me:c1.md me:c2.md`).

**Table B: `review-comment.sh [<dir>]` over one round's reports and judgment**

The report item is down the side; the judgment's mark on the item that judges it is across the top. A refusal is one line `review-comment: <message>` on stderr, exit 1, before any output, clearing nothing; the caller sends a report refusal to the lane that wrote it, or fixes the judgment, then reruns `review-comment.sh <dir>`, the same round. Checks run in source order and the first failure is the only message: each report's shape, numbering, `hard findings:` line, ceiling, `Documented step:`, then `spec:`; then the judgment's existence, shape, numbering, item count, references, then `hole:` placement, `hole:` grammar, `hole:` value; then the round file. `count` = |Act on| − |fixed:| − |ticket:| − |hole:| + |Ask|. "As today" = the comment as printed today, no `restart` line, `round: N of 3`, then `act-on items: count` last.

| Report item | A. no mark | B. `fixed: <sha>` | C. `ticket: #N` | D. `hole: <ref>` equal to the item's `spec:`, under `## Act on` | E. `hole:` fitting no form (`hole: table 2`, `hole: cell 12A`, `hole: criterion 0`, trailing text) | F. `hole: <ref>` well formed but differing from the item's `spec:` | G. `hole:` under `## Ask`, `## Consider`, `## Noted` or `## Dismissed` |
|---|---|---|---|---|---|---|---|
| 1. Counted (`## Would break` or `## Fails open`) with `Documented step:`, `Result:` and a well-formed `spec:` line | as today; counted / 0 / fix on the PR, unchanged | as today; not counted / 0 / unchanged | as today; not counted / 0 / unchanged | the comment with its summary line unchanged, then `restart` on its own line, then `round: N of 3`, then `act-on items: count` with the hole left out / 0 / post it; then the Ticket playbook's Design hole section scoped to `<ref>`; nothing is fixed on the PR | refused: `<dir>/judgment.md item '<N. **Title.**>' has a 'hole:' field that fits no form; it ends the line as 'hole: table <row>/<column>', 'hole: design <signature>' or 'hole: criterion <k>'` / 1 / fix the judgment | refused: `<dir>/judgment.md item '<N. **Title.**>' is marked 'hole: criterion 4' but [P2] rests on 'table 2/D'; the mark repeats the report item's 'spec:' line word for word` / 1 / fix the judgment, or the report goes back to the reviewer to change its reference | refused: `<dir>/judgment.md item '<N. **Title.**>' carries a 'hole:' field under '## Noted'; 'hole:' marks an Act on item, as 'fixed:' and 'ticket:' do` / 1 / fix the judgment |
| 2. Counted, no `spec:` line | refused before the judgment is read, in every column: `<dir>/standards-report.md item '2. **Open, silently.**' under '## Fails open' has no 'spec:' line; a counted item names what it rests on, one of 'spec: table <row>/<column>', 'spec: design <signature>' or 'spec: criterion <k>', on its own line. Ask the reviewer for it` / 1 / back to the reviewer, same round | ← | ← | ← | ← | ← | ← |
| 3. Counted, `spec:` fitting no form (`spec: cell 12A`, `spec: table 12A`, `spec: criterion 0`, trailing text) or inside a fenced hunk | the same refusal as row 2, in every column / 1 / back to the reviewer | ← | ← | ← | ← | ← | ← |
| 4. Counted, `spec:` present, no `Documented step:` | the step refusal first, as today, in every column / 1 / unchanged | ← | ← | ← | ← | ← | ← |
| 5. Not counted (`## Standards breaches`, `## Fix alongside`, `## Not asked for`), with or without a `spec:` line | as today; a `spec:` line here is inert / 0 | as today / 0 | as today / 0 | refused: `<dir>/judgment.md item '<N. **Title.**>' is marked 'hole: table 2/D' but [S3] carries no 'spec:' line: it is under '## Standards breaches' in <dir>/standards-report.md, not a counted item` / 1 / fix the judgment, or the report goes back to its reviewer to re-sort the item | as 1E / 1 | as 5D / 1 | as 1G / 1 |
| 6. A `## Walk` line | not an item: never numbered with the findings, never counted, never judged; a `spec:` or `hole:` written on it is invisible / 0 / unchanged; #91's per-risk walk lines land here and change no cell | ← | ← | ← | ← | ← | ← |

Notes on the whole table. Two or more holes print one `restart` line and each is left out of the count. A `hole:` beside `fixed:` or `ticket:` on one line: only the field that ends the line is a field, counted per the last field (each grep is `$`-anchored, so at most one matches and the count cannot go negative); no code. `cites:` in any form on any judgment item is passed through verbatim and read by `review-brief.sh` next round (table A rows 14 to 17). A rerun with the dir after the state is gone prints the same output, `restart` included when a hole is still marked; same round. Every refusal the script gives today (shape, numbering, count line, ceiling, missing file, reference set, round file) is unchanged and in the same order.

Babysit on these cells: a comment from columns A to C reads as today. A comment from column D carries `restart`; the sentence added to babysit says such a comment makes the PR neither review-ready nor a blocker to fix here, whatever its count, so a mid-restart PR reading `act-on items: 0`, or `round: 3 of 3` with `act-on items: 0`, cannot read as ready; the redesign's own review comment is the one babysit reads next.

## Contract

**One reference grammar.** Both scripts hold it on one line, spelled identically; `tests/spec-review/review-brief.sh`'s `fragment()` holds the two copies together as it does for `fenced`:

```sh
ref='(table [^[:space:]/]+/[^[:space:]/]+|design [^[:space:]].*|criterion [1-9][0-9]*)'
```

`table <row>/<column>`: the table's own row and column labels, no spaces or slashes (`table 12/A`). `design <signature>`: the rest of the line, a signature or usage as the `## Design` sketch writes it. `criterion <k>`: the k-th `- [ ]` checkbox, from 1. Three uses:

- `review-comment.sh`, the report line on every counted item, `^spec: $ref$`, checked by the scanner that checks `Documented step:` today: `stepless()` takes the required line's regex as a parameter and is called twice, the step refusal first, the `spec:` refusal second (table B rows 2 to 4). A fenced line satisfies neither.
- `review-comment.sh`, the judgment field on an Act on item's own line, `$`-anchored like `fixed:` and `ticket:`: `hole: $ref$`. After the reference-set check and before the round file, three refusals in this order: a `hole:` outside Act on (column G); an Act on `hole:` whose value fits no form (column E); an Act on `hole:` whose value is not, word for word, the `spec:` value of the report item the judgment item names (column F, and row 5D when that item carries none). `holes` is counted beside `fixed_here` and `ticketed` and subtracted from the count.
- `review-brief.sh:151`, a fourth `cites:` alternative `#[0-9]+ $ref` inside the existing group, still `$`-anchored: `cites: #N table <row>/<column>`, `cites: #N design <signature>`, `cites: #N criterion <k>`. `review-comment.sh` still never reads `cites:`; `review-brief.sh` still never reads `hole:`.

**The spec rule in both briefs.** A fifth shell variable beside `step_rule` (`review-brief.sh:240`), echoed one blank line after `$step_rule` at both call sites (`:324`, `:352`) and before the report-path line, so the pinned layouts hold; its word-for-word twin in `SKILL.md` step 4 (`:84`, "then the spec rule, word for word"); the brief test asserts it in `SKILL.md` and in both briefs beside the step rule:

```sh
spec_rule='The same item carries a line `spec:` naming the artifact it rests on: `table <row>/<column>` for a cell of the ticket'"'"'s scenario table, `design <signature>` for a signature or usage in its `## Design` sketch, or `criterion <k>` for its k-th acceptance checkbox; an item without a `spec:` line in one of those three forms is sent back.'
```

**The comment's tail (`review-comment.sh:157-158`).** The summary line unchanged; then `restart` on its own line when any Act on item carries `hole:`; then `round: N of 3`; then `act-on items: N` with the holes subtracted, still last. Every existing `accept` expectation in the comment test is unchanged.

**The reset (`review-brief.sh`).** One awk between fetching `bodies` (`:107`) and the round awk (`:133`) keeps only the comments after the last restart comment: a line that is exactly `restart` outside fenced text, with CR and trailing blanks stripped as `split` strips them; a restart comment with no separator after it (a `--previous` file) cuts at EOF. When it cut anything, the script prints `restart: the round and the settled items count from the last restart comment` after `ticket:` and before `round:`, whether or not `--round` overrides the round. Both derivations then read the sliced history and change nothing: `top` is 0 when nothing follows (round 1), the `settled:` line and section are absent, the three-round refusal counts only what follows, `--round N` overrides as before, and a PR with no restart refuses exactly what it refused before. Nothing before a restart carries as settled, including the restart comment's own items. The script's header comment and the round-rule comment above `top=0` gain the clause.

**Prose, per file, as the text to add.**

- `spec-review/SKILL.md` (patch, template and `SOURCES.md` item 6 in one commit). Step 1 (`:25`, after "so a comment rebuilt in the same round does not advance it."): "A comment carrying a line that is exactly `restart` (step 6: a design hole returned to architect) ends the history: the round and the settled items are read from the comments after the last such comment, the script says so with a line `restart:`, so the redesign's first review is round 1 with nothing carried, and the fourth-round refusal counts only what follows it." Step 4 (`:84`, after the step rule's quote): "Then the spec rule, word for word: "<spec_rule>"." Step 5, a paragraph before the trailing-fields list: "A finding is a design hole when its fix changes the artifact the work was built against rather than the code that implements it. Three artifacts, and every ticket has at least one: the scenario table under `## Testing decisions` (a cell's expected outcome, a new row or column, or the contract's meaning of a term the cells use, such as what counts as in flight, a named path, a covering go); the usage and signature sketch under `## Design` (a signature, a type, or how a caller uses it); the acceptance criteria (what a criterion asks for). The ticket's intent, its What to build or Decision quotes, outranks any one criterion: a criterion that must change is a hole, and architect re-derives it from the intent. A refusal added under an existing could-not-run clause is not a hole. Detection is sharpest for a table and softest for a criterion; test for all three. Every counted report item names what it rests on in its `spec:` line (step 4): the finding is a hole when its fix changes that thing, and an implementation bug when the artifact stands and the code fails it." The list's lead (`:130`) becomes "Four trailing fields, each with one grammar:", and after the `fixed:` bullet: "- `hole: <reference>` on an Act on item says the finding's fix changes the artifact, not the code: it repeats the judged report item's `spec:` line word for word (`table <row>/<column>`, `design <signature>` or `criterion <k>`); step 6 leaves it out of the count and prints the line `restart`. A hole is never fixed on this PR: the Ticket playbook's Design hole section returns the work to `architect` scoped to that reference, and the redesign is reviewed from round one." Step 6 (`:138`): after "a one-line summary," insert "the line `restart` on its own when any Act on item carries `hole:`,", and the count's definition reads "without a `fixed:`, `ticket:` or `hole:` field"; the refusal list (`:140`) gains, after the `Documented step:` clause: "when a `## Would break` or `## Fails open` item has no `spec:` line in one of the three forms (ask the reviewer for it); when a `hole:` field sits under a heading other than Act on, fits no form, or is not, word for word, the `spec:` value of the report item it judges (a wrong reference, or an item that carries no `spec:` line);".
- `docs/agents/review-ladder.md` rung 1 (`:6`, after "An Ask item waits for the human."): "A finding is a design hole when its fix changes the artifact the work was built against rather than the code that implements it: a cell of the ticket's scenario table (its expected outcome, a new row or column, or the meaning of a term the cells use), a signature or a usage in its `## Design` sketch, or an acceptance criterion; the ticket's intent, its What to build or Decision quotes, outranks any one criterion, so a criterion that must change is a hole and `architect` re-derives it from the intent. A refusal added under an existing could-not-run clause is not a hole. Detection is sharpest for a table and softest for a criterion; all three are marked the same way. A hole is never fixed on the PR: the judgment marks it `hole: <reference>`, the comment carries the line `restart`, the work returns to `architect` scoped to that cell, signature or criterion, and the redesign is reviewed from round one."
- `poteto-mode/playbooks/ticket.md` (kept file). Step 8, after "Then run **Opening a PR**.": "A `spec-review` comment carrying the line `restart` names a design hole: go to **Design hole** below, not on to step 9." A new section `### Design hole` after Quick ticket, no step renumbered: "**A finding whose fix changes the artifact is not fixed on the PR.** When a round's review comment carries a `restart` line, before babysit: 1. Read the `hole:` reference on each marked item: a cell, a signature or a criterion. That is the scope; nothing wider is redesigned. 2. Run `architect` Phase B scoped to it, with the judgment item, its report item and the artifact (the ticket's `## Testing decisions` table, its `## Design` sketch, or the criterion with the ticket's What to build and Decision quotes) as grounding. Two runners; the judge is skipped when they converge. 3. Amend the artifact on the ticket with a dated line, never a rewrite: `Amended <date> by #N (review round <r>, hole at <reference>): <what changed and why>; <which assertions moved>`. A criterion is re-derived from the ticket's intent and the line shows the old and the new wording. 4. Rewrite the tests from the amended artifact before the code (step 6), then redo the work on this branch; the PR stays open. 5. Review the redesigned work from round one: `review-brief.sh` reads the restart from the PR's comments and starts the count over; nothing from before it carries as settled, so a decision still needed is cited again in the new round one's judgment. 6. Then step 9. A PR mid-restart is never merge-ready."
- `poteto-mode/playbooks/babysit.md` (patch, template, `SOURCES.md` item 4) and `babysit/SKILL.md` (patch, template, item 12): one new indented paragraph after `babysit.md:16` and one new bullet after `babysit/SKILL.md:40`, those two lines byte-identical (criterion 7): "A review comment carrying the line `restart` names a design hole and is not a merge-ready comment whatever its count: the Ticket playbook's Design hole section returns the work to `architect`, and the PR is ready only when a later review comment without a `restart` line reads `act-on items: 0`."
- `tests/spec-review/no-stale-wording.sh`: `Three trailing fields` added to the blacklist.

**Tests, one assertion per cell.** `tests/spec-review/review-comment.sh`: row 1 columns D (exact stdout with `restart` before `round:` and the hole out of the count), E, F, G; row 2; row 3 (a malformed `spec:` and a fenced one); row 4; row 5 columns A and D; row 6; the notes' two-holes, last-field and rerun cases. `tests/spec-review/review-brief.sh`: the `spec_rule` anti-drift and layout beside `step_rule`; `fragment()` holding the two `ref=` lines together; rows A5, A6 (the `X` line, `round: 1 of 3`, no `settled:` line, no settled section), A7 (refused after three post-restart comments, exact message, no state), A8, A11 (prose, fenced and trailing-text `restart`), A12 (through `pr me me:<file>` and the fake `gh`, so the jq filter is what is tested), A13, A14 to A16 (each form carried, the exact `settled:` line and the pasted line in both briefs), A17 (dropped and counted), and the `--round 4` refusal unchanged on a PR with no restart.

**Criteria map.** Criterion 1: the `SKILL.md` step 5 paragraph and the rung-1 sentence. Criterion 2: `spec_rule` at both call sites and table B rows 2 to 4. Criterion 3: table B columns D to G, `holes` in the count, the `restart` line, the step 6 count definition. Criterion 4: the Design hole section and the step 8 pointer, table A rows 5 to 8 and 13, the `X` line, the babysit sentence. Criterion 5: the fourth `cites:` alternative and table A rows 14 to 17. Criterion 6: the test list. Criterion 7: `babysit.md:16` and `babysit/SKILL.md:40` byte-identical, table B columns A to C unchanged.

**Files touched.** `template/.agents/skills/spec-review/scripts/review-brief.sh`; `template/.agents/skills/spec-review/scripts/review-comment.sh`; `template/.agents/skills/spec-review/SKILL.md` with `patches/mattpocock/spec-review.SKILL.md.patch`; `template/docs/agents/review-ladder.md`; `template/.agents/skills/poteto-mode/playbooks/ticket.md`; `template/.agents/skills/poteto-mode/playbooks/babysit.md` with `patches/pstack/poteto-mode/playbooks/babysit.md.patch`; `template/.agents/skills/babysit/SKILL.md` with `patches/pstack/babysit/SKILL.md.patch`; `SOURCES.md` items 4, 6, 12; `tests/spec-review/review-brief.sh`, `review-comment.sh`, `no-stale-wording.sh`. No new file, no renumbered step; `arena`, `architect`, `MANUAL.md` and `DECISIONS.md` (the owner's Provisional entry) untouched by the writer.

## Report

A hard finding is one of two things: the documented path gives a wrong or silent result, or an input outside it proceeds silently (fails open). An input outside the documented path that is refused with a message saying how to correct it is not a finding; it is the design. Zero items is the expected result for a clean change.

- Manuel: "there are an infinite amount of unhappy paths and only 1 happy one"
- Manuel: "AT MOST hardening to fail fast and loud if we move outside of that"
- Manuel: "we notice the variable is unexpected and flag that without having to diagnose every reason the variable might be wrong for the user"
- Manuel: "An edge case outside the intended path being unsupported is not a flag."
- Manuel: "Primary focus must be the happy path, then unhappy paths that error in a way the user can correct."

Write the report as Markdown with exactly these `## ` headings, in this order, each holding numbered items or nothing:

- `## Walk`: one numbered line per documented step of the path the change touches (the ticket's criteria and the documentation the diff changes), each saying what the code does at that step. A walk, not findings: its lines are numbered 1..K on their own and count nothing.
- `## Would break`: a requirement missing, partial, or implemented so that the documented path gives a wrong or silent result.
- `## Fails open`: an input outside the documented path that proceeds silently instead of being refused with a message saying how to correct it.
- `## Not asked for`: behaviour in the diff the ticket did not ask for.

Each item opens with a line of the form `1. **Title.** body` and quotes the spec line it rests on in a fenced block (a criterion can carry `## ` or `1. ` lines, and only fenced text is exempt from the report shape); number the items continuously across the headings from `## Would break` on, so the judgment can name your third item as [P3]. Read nothing beyond this brief unless a finding needs the code around a hunk, and then read that one function or section, not the file. Under 400 words.

Every item under `## Would break` or `## Fails open` carries a line `Documented step:` quoting the ticket line or the `file:line` of the documentation the user follows, and a line `Result:` saying what happens instead; an item without its `Documented step:` line is sent back.

The same item carries a line `spec:` naming the artifact it rests on: `table <row>/<column>` for a cell of the ticket's scenario table, `design <signature>` for a signature or usage in its `## Design` sketch, or `criterion <k>` for its k-th acceptance checkbox; an item without a `spec:` line in one of those three forms is sent back.

Write your report to `.scratch/review/69bd412/spec-report.md` and reply with only that path.
End the report with exactly one line `hard findings: N`, where N is the number of items under `## Would break` and `## Fails open` and nothing else.
