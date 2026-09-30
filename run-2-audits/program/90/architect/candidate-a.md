# Candidate A: design for ticket #90 (design holes, `spec:`, `hole:`, `restart`)

## Problem

`spec-review` has one path for a finding: fix it on the PR, up to three rounds. A finding whose fix changes the artifact the work was built against (a cell of the ticket's scenario table, a signature in its `## Design` sketch, an acceptance criterion) is a different thing: the reviews so far graded a design that no longer exists, so the count must start over and the redesign must go through `architect`, not through a fix lane. The shape is constrained by what exists: the PR's own comments are the only memory (`review-brief.sh:94` fetches only the author's comments carrying `act-on items:`; `:133-137` derives the round from their `round: N of 3` lines with `BEGIN { r = 1 }`, so any fetched comment forces round 2 or more); `act-on items: N` is the last printed line and babysit, the ladder and the MANUAL read it; `fixed:` and `ticket:` are `$`-anchored trailing fields on an Act on item's own line (`review-comment.sh:149-150`); `Documented step:` is the one continuation line a counted item must carry, checked by `stepless()` (`:54-62`) and refused at `:91`; `cites:` is one `$`-anchored regex at `review-brief.sh:151`, read nowhere else; `step_rule` is one shell variable echoed at two call sites with a word-for-word twin in `SKILL.md:84` that the brief test pins. `SKILL.md`, `babysit.md` and `babysit/SKILL.md` are patched, so each edit is patch plus template plus `SOURCES.md`; the two scripts, `ticket.md` and `review-ladder.md` are ours. Rounds four and five (#93) and the Spec walk's blast-radius lines (#91) are out of scope and nothing here depends on them.

## Usage (caller's view)

Three walk-throughs in the orchestrator's own steps, on a #42-shaped ticket (a scenario table with rows `1.`–`14.` and columns `A`–`E`, a `## Contract`) reviewed on a #92-shaped PR.

**1. A clean round.** Step 1: `scripts/review-brief.sh origin/main --ticket 42` prints `ticket: #42`, `round: 1 of 3`, the two brief paths. Both briefs carry, right after the step rule, the new spec rule (one sentence, below). The Spec reviewer writes a hard item with three continuation lines:

```
## Fails open

1. **Step 8 has no exit-2 branch, so a failed check reads as "no overlap".** ...

Documented step: `template/.agents/skills/poteto-mode/playbooks/ticket.md:12`
Result: a PR opens with no Overlap section and no signal that the check failed.
spec: table 11/E
```

The orchestrator judges it an implementation bug (the cell already says exit 2 stops) and writes `1. [P1] **Step 8 had no exit-2 branch.** Real; rows 10E and 11E already say exit 2 stops, no cell changes. fixed: 1df787a`. Step 6: `scripts/review-comment.sh` prints the comment exactly as today; its tail is the summary line, `round: 1 of 3`, `act-on items: 0`. No `restart` line. The orchestrator posts it; babysit reads the last line as it does now.

**2. A round that finds a hole.** Round two. The Standards reviewer finds that a stacked PR is diffed against `main`, so `L(k)` includes the parent's commits, and writes `spec: table 2/D` under it (the cell whose "contains" outcome the fix would change). The orchestrator judges: the fix changes what "a PR's own commits" means in the contract, a term every `L(k)` cell uses, so it is a hole, and writes

```
## Act on

1. [S1] **A stacked PR's own commits include its parent's.** Real; the fix changes the contract's meaning of "own commits", which every L(k) cell uses. hole: table 2/D
```

`scripts/review-comment.sh` checks that `[S1]` is under `## Would break` or `## Fails open` and that its `spec:` line reads `spec: table 2/D`, then prints the comment whose tail is

```
Standards: 1 would break, 0 fail open, of 3; Spec: 0 would break, 0 fail open, of 1; judged: act on 1 (0 fixed, 0 with a ticket), ask 0, consider 0, noted 2, dismissed 0; fixed point origin/main.
restart
round: 2 of 3
act-on items: 0
```

The orchestrator posts it and follows Ticket step 8's new sentence: nothing is fixed on the PR; back to step 5's playbook at its `architect` step, Phase B only, scoped to `table 2/D`, with the finding (the report item and the judgment line) and the table as grounding, two runners, and the judge skipped when they converge. The synthesized cell goes onto the ticket under `## Testing decisions` as a dated line: `Amended 2026-09-22 by PR #92 (review round 2, hole at table 2/D): each PR is diffed from the open PR it stacks on, else main; the contract's "own commits" now says so; no assertion changed.` Steps 6 to 8 run again on the same branch (test from the amended cell, implementation, push). The next `scripts/review-brief.sh origin/main --ticket 42` sees a restart comment as the last one, reads the history after it (nothing), and prints `ticket: #42`, `round: 1 of 3`, the brief paths, and no `settled:` line.

**3. The round after the redesign.** Round one of the new series has no `## Settled in earlier rounds`: the two Noted items of the old rounds (`[S4] The prs walk appears three times`, uncited, and `[S2] Whole DECISIONS.md is writable. cites: DECISIONS.md P17`, cited) do not carry, because they were settled against a design that no longer exists; a reviewer who raises either again is answered the same way, and the judge re-dismisses the second with the same `cites:` line. The new round one comment ends `round: 1 of 3`, `act-on items: 1`. Round two of the new series then prints `round: 2 of 3` and `settled: carried 1, dropped 1 without a citation`: the re-cited `DECISIONS.md P17` item carries, the uncited one does not, and nothing from before the restart appears. Three rounds after the restart, `review-brief.sh` refuses a fourth with the message it prints today.

## Shape

Posted by the agent 2026-09-22

The two scenario tables are the spec for the round logic and the marks: table A is `review-brief.sh` over the PR's comment history, table B is `review-comment.sh` over one round's reports and judgment. A review finding that changes a cell, or the contract's meaning of a term the cells use, is a design hole and returns the work to architect under this ticket's own rule; a finding that leaves the tables standing is an implementation bug fixed on the PR. A cell that reads "refused" names the message and costs no code beyond the refusal.

### Scenario table

Cell = prints / exit / what the caller does. `R(n)` = the line `round: n of 3`. `S(c,d)` = the line `settled: carried c, dropped d without a citation`; "no S" = the line absent and no `## Settled in earlier rounds` in either brief. `paths` = the brief paths printed last (both, or the Standards one plus `no spec: Standards axis only`). Exit 0 writes the briefs and the state; exit 1 is the existing three-round refusal, `review-brief: three rounds were run on this PR; the remaining Act on items are fixed here and marked ` `` `fixed: <sha>` `` `, not reviewed in a fourth round` on stderr, before any output or state. A "restart comment" is a comment by the PR's author carrying a line `act-on items:` and a line that is exactly `restart` outside fenced text. A history is written oldest first; `(2 restart)` is a round-two comment carrying `restart`.

**Table A: `review-brief.sh` over the comment history**

| Situation (the PR's comments by its author) | A. `review-brief.sh <fixed-point>` (gh) | B. with `--round N` | C. with `--previous FILE` |
|---|---|---|---|
| 1. No review comment, or gh finds no PR | `R(1)`, no S, `paths` / 0 / round one, as today | `R(N)`, no S / 0 (N > 3: exit 1) | an empty file: as A |
| 2. One comment, `round: 1`, with c cited and d uncited Noted or Dismissed items | `R(2)`, `S(c,d)`, `paths` / 0 / as today | `R(N)`, `S(c,d)` / 0 | as A from the file |
| 3. Two comments (1), (2) | `R(3)`, S over both, each distinct line once / 0 / as today | `R(N)`, same S / 0 | as A |
| 4. Three comments (1), (2), (3), no restart | the three-round message / 1 / fix what remains, mark `fixed: <sha>`, rebuild with `review-comment.sh <dir>`; unchanged | `--round 3`: `R(3)`, S / 0 (a rebuild); `--round 4`: the message / 1 | as A |
| 5. A restart among them: (1), (2 restart) | `R(1)`, no S, `paths` / 0 / the redesign's round one | `R(N)`, no S / 0 | a file holding both comments, separated as gh separates them: as A |
| 6. The restart is the third: (1), (2), (3 restart) | `R(1)`, no S / 0 / round one; not refused, the gate counts what follows the restart | `R(N)`, no S / 0 | as A |
| 7. Three rounds after a restart: (1), (2 restart), (1'), (2'), (3') | the three-round message / 1 / as row 4 for the new series | `--round 3`: `R(3)`, S over (1'), (2'), (3') only / 0 | as A |
| 8. Two restarts: (1 restart), (1'), (2' restart), (1'') | `R(2)`, S over (1'') only / 0 / round two of the third series | `R(N)`, S over (1'') / 0 | as A |
| 9. A comment without a `round:` line (from before the line existed) | counts as round 1: `R(2)`, S / 0 / unchanged; with a `restart` line and no `round:` line it is a restart comment, row 5 | `R(N)` / 0 | as A |
| 10. A comment by anyone but the PR's author, whatever it holds (`restart`, `round: 3 of 3`, cited items) | not fetched (the jq author filter): as if absent, rows 1–9 on the rest / unchanged | same | the file is trusted wholesale, as today: the caller writes only the author's comments into it |
| 11. The word `restart` in a comment's prose (`the writer asked for a restart`), in a fenced hunk, or with trailing text (`restart: table 2/D`) | not a restart line: rows 2–4 / 0 | same | as A |
| 12. A comment with a line `restart` but no `act-on items:` line | not fetched (the `act-on items:` filter at `:94`): as if absent, the round does not reset / 0 / post the comment `review-comment.sh` printed, which always carries both lines; a hand-written restart is not a review comment | same | the file is trusted, so it is a restart comment there: row 5 |
| 13. Cited Noted or Dismissed items in the restart comment or in any comment before it | dropped with the history, no S line; a decision still needed is cited again in the new series and carries from its round two on | same | as A |
| 14. The last comment carries `1. [S2] **T.** r. cites: #42 table 12/A` | `S(1,·)`; the line is pasted verbatim under `## Settled in earlier rounds` in both briefs / 0 | same | as A |
| 15. `cites: #42 design overlap.sh N --diff` | carried, as row 14 / 0 | same | as A |
| 16. `cites: #42 criterion 3` | carried, as row 14 / 0 | same | as A |
| 17. A malformed cite: `cites: #42 cell 12A`, `cites: table 12/A` (no `#N`), `cites: #42 criterion 0`, `cites: #42 table 12/A trailing`, `cites:` not last on its line | dropped, counted in d, as an uncited item is today / 0 / nothing; no code | same | as A |

Rerunning any row in the same round prints the same lines: the round and the settled set are functions of the fetched comments alone, and `.scratch/review/<id>` is rebuilt from scratch each run.

**Table B: `review-comment.sh` over one round's reports and judgment**

Refusals are one line `review-comment: <message>` on stderr, exit 1, before any output, clearing nothing; every refusal precedes the round check, so `<dir>/round` is read only for an accepted run. `count` = `|Act on| − |fixed:| − |ticket:| − |hole:| + |Ask|`. "Back to the reviewer" means the orchestrator sends the refusal text to the lane that wrote the report and reruns the script on the rewritten file, same round; "fix the judgment" means the orchestrator edits `judgment.md` and reruns.

| Situation (the input of one round) | `review-comment.sh` prints | exit | what the caller does |
|---|---|---|---|
| 1. Every Would-break and Fails-open item carries `Documented step:`, `Result:` and a well-formed `spec:` line; the judgment has no mark | the comment as today: no `restart` line, `round: N of 3`, `act-on items: count` last | 0 | post it; babysit reads the last line; unchanged |
| 2. `fixed: <sha>` on an Act on item | as today: not counted | 0 | unchanged |
| 3. `ticket: #N` on an Act on item | as today: not counted | 0 | unchanged |
| 4. `hole: <ref>` on an Act on item judging a Would-break or Fails-open item whose `spec:` line reads `spec: <ref>` | the comment, then the line `restart`, then `round: N of 3`, then `act-on items: count` with the hole left out | 0 | post it; then Ticket step 8's return to architect scoped to `<ref>`; no fix lands on the PR, the count is informational |
| 5. Two or more holes | one `restart` line; each hole left out of the count | 0 | as row 4, architect scoped to each reference |
| 6. `hole:` on an Act on item judging an item under `## Standards breaches`, `## Fix alongside` or `## Not asked for`, with or without a `spec:` line | refused: `<dir>/judgment.md item '<line>' marks [S3] as a design hole, but [S3] is under '## Standards breaches' in <dir>/standards-report.md; only a Would-break or Fails-open item, the ones that carry a 'spec:' line, can be one` | 1 | fix the judgment (it is not a hole), or the report goes back to the reviewer to move the item |
| 7. `hole:` whose reference fits no form (`hole: cell 12A`, `hole: table 12A`, `hole: criterion 0`, `hole:` not last on its line) | refused: `<dir>/judgment.md item '<line>' has a 'hole:' field that fits no form; it ends the line as 'hole: table <row>/<column>', 'hole: design <signature>' or 'hole: criterion <k>'` | 1 | fix the judgment |
| 8. `hole: <ref>` where the judged item's `spec:` line names a different reference | refused: `<dir>/judgment.md item '<line>' names 'table 2/B' where [S3] rests on 'table 12/A' (its 'spec:' line in <dir>/standards-report.md); the hole repeats the reviewer's reference, or the report goes back to the reviewer to change it` | 1 | fix the judgment, or back to the reviewer |
| 9. `hole:` under `## Ask`, `## Consider`, `## Noted` or `## Dismissed` | refused: `<dir>/judgment.md item '<line>' carries 'hole:' under '## Noted'; a design hole is an Act on item` | 1 | fix the judgment |
| 10. `hole:` and `fixed:` or `ticket:` on one Act on line | only the field that ends the line is a field; the rest is prose: counted per the last field | 0 | nothing; no code (the three greps are `$`-anchored, so at most one matches a line and the count cannot go negative) |
| 11. A Would-break or Fails-open item with no `spec:` line | refused: `<dir>/standards-report.md item '2. **Open, silently.**' under '## Fails open' has no 'spec:' line; a counted item names what it rests on, one of 'spec: table <row>/<column>', 'spec: design <signature>' or 'spec: criterion <k>', on its own line. Ask the reviewer for it` | 1 | back to the reviewer, same round |
| 12. A counted item whose `spec:` line fits no form (`spec: cell 12A`, `spec: table 12A`, `spec: criterion 0`, `spec: table 12/A` inside a fenced hunk, `spec:` with trailing text) | the same refusal as row 11 (the message names the three forms) | 1 | back to the reviewer |
| 13. A counted item with `spec:` but no `Documented step:` | the step refusal first, as today (`stepless` runs before the spec scan) | 1 | back to the reviewer; unchanged |
| 14. `spec:` on an item that is not counted | inert: never read, never refused; a hole on that item is row 6 | 0 | nothing; no code |
| 15. `cites:` in any form, well-formed or not, on any judgment item | passed through verbatim; `review-brief.sh` reads it next round (table A rows 14–17) | 0 | unchanged |
| 16. Rerun with the dir after the state is gone (an answered Ask, a rewritten report) | the same output, `restart` included when a hole is still marked | 0 | same round; unchanged |
| 17. Any refusal the script gives today (shape, numbering, count line, ceiling, missing file, reference set, round file) | as today, in the same order; the new checks run after the reference-set check and before the round check | 1 | as today |

Babysit on these cells: a comment from row B1–B3 reads as it does today. A comment from row B4 or B5 carries `restart`; babysit's new sentence says such a comment makes the PR neither review-ready nor a blocker to fix here, whatever its count, so a mid-restart PR with `act-on items: 0` (the hole was the only Act on item) or with `round: 3 of 3` and `act-on items: 0` (row A6) cannot read as ready; after the redesign, the new series' comment is the one on the latest commit, and babysit reads that.

### Contract

**One reference grammar, three fields.** Both scripts define, word for word on one line, and the brief test pins the two copies equal the way it pins `fenced`:

```sh
ref='(table [^/ ]+/[^/ ]+|design [^ ].*|criterion [1-9][0-9]*)'
```

`table <row>/<column>`: the table's own row and column labels, no spaces or slashes (`table 12/A`, `table 2/D`). `design <signature>`: the rest of the line, a signature or usage as the `## Design` sketch writes it (`design overlap.sh N --diff`). `criterion <k>`: the k-th `- [ ]` checkbox, from 1. The three uses:

- The report line, `review-comment.sh`, on every Would-break and Fails-open item, checked by the scanner: `^spec: (table [^/ ]+/[^/ ]+|design [^ ].*|criterion [1-9][0-9]*)$`, passed to awk as `-v want="^spec: $ref\$"`.
- The judgment field, `review-comment.sh`, on an Act on item's own line, `$`-anchored like `fixed:` and `ticket:`: `hole: (table [^/ ]+/[^/ ]+|design [^ ].*|criterion [1-9][0-9]*)$`. A line is inspected for the field by ` hole: `, then must match this.
- The citation, `review-brief.sh:151`, one new alternative inside the existing group so `cites:` stays the last field on its line:

```sh
cites='cites: (user: "[^"]+" on #[0-9]+|DECISIONS\.md [A-Z]?[0-9]+|#[0-9]+ comment [0-9]{4}-[0-9]{2}-[0-9]{2}|#[0-9]+ '"$ref"')$'
```

`SKILL.md` step 5 states the same three forms in prose and names nothing else.

**The spec rule, `review-brief.sh`.** A fifth shell variable beside `step_rule` (`:240`), echoed on the line after `$step_rule` at both call sites (`:324`, `:352`), inside the same paragraph so the pinned layout (definition, blank, first quote; report path then count rule with no blank) is untouched; `SKILL.md:84` gets the twin, "then the spec rule, word for word: …", and the brief test asserts it in `SKILL.md` and in both briefs beside `step_rule`:

```sh
spec_rule='Every item under `## Would break` or `## Fails open` also carries a line `spec:` naming what it rests on, one of `spec: table <row>/<column>` (a cell of the ticket'"'"'s scenario table), `spec: design <signature>` (a signature or usage in its `## Design` sketch) or `spec: criterion <k>` (its k-th acceptance checkbox); an item without one is sent back.'
```

**The scanner, `review-comment.sh`.** `stepless()` (`:54-62`) becomes `lacking <file> <regex>`, the same awk with `-v want=` in place of the literal `/^Documented step:/`; `report()` calls it twice, `lacking "$f" '^Documented step:'` with today's refusal, then `lacking "$f" "^spec: $ref\$"` with row B11's refusal. Fenced lines never satisfy either; a `spec:` line under an uncounted item is never visited.

**The hole checks, `review-comment.sh`.** After the reference-set check (`:126`) and before the round (`:128`), so every refusal precedes output:

```sh
# specof <file> <n>: the heading and the `spec:` line of the report's n-th item, tab-separated.
specof() { awk -v n="$2" "$fenced"'/^## / { next } h != "" && h != "Walk" && /^[0-9]+\. / { i++; if (i == n) at = h } i == n && /^spec: / { s = $0 } END { print at "\t" s }' "$1"; }
for hd in Ask Consider Noted Dismissed; do
  line="$(items "$dir/judgment.md" "$hd" | grep -E ' hole: ' | head -1 || true)"
  [ -z "$line" ] || fail "$dir/judgment.md item '$line' carries 'hole:' under '## $hd'; a design hole is an Act on item"
done
holes=0
while IFS= read -r line; do
  printf '%s' "$line" | grep -qE "hole: $ref\$" || fail "... has a 'hole:' field that fits no form; ..."   # row B7
  id="$(printf '%s' "$line" | sed -nE 's/^[0-9]+\. \[([SP][0-9]+)\].*/\1/p')"
  case "$id" in S*) f="$dir/standards-report.md" ;; *) f="$dir/spec-report.md" ;; esac
  IFS=$'\t' read -r at spec <<< "$(specof "$f" "${id#?}")"
  case "$at" in "Would break"|"Fails open") ;; *) fail "... marks [$id] as a design hole, but [$id] is under '## $at' in $f; ..." ;; esac   # row B6
  [ "$spec" = "spec: ${line##* hole: }" ] || fail "... names '${line##* hole: }' where [$id] rests on '${spec#spec: }' ..."   # row B8
  holes=$((holes + 1))
done < <(items "$dir/judgment.md" "Act on" | grep -E ' hole: ' || true)
```

The output tail (`:157-158`) becomes: the summary line unchanged, then `[ "$holes" -eq 0 ] || echo restart`, then `echo "round: $round of 3"`, then `echo "act-on items: $((act - fixed_here - ticketed - holes + ask))"`. `restart` sits on its own line immediately before `round:`; `act-on items:` stays last, so `SKILL.md:138`, the ladder, and the two babysit sentences that read the last line stay true, and every existing `accept` expectation is unchanged. The summary line does not change (18 exact-stdout cases per layout rest on it); the hole is visible in the judgment's `hole:` field and in the `restart` line.

**The reset, `review-brief.sh`.** One awk between fetching `bodies` (`:107`) and the round awk (`:133`), before either derivation, so both read the same history and neither changes:

```sh
# A review comment carrying a line `restart` (step 6: a design hole returned to architect) ends
# the history: the comments after the last such comment are the PR's history for the round and
# the carry, so the redesign's first review is round 1 with nothing carried.
bodies="$(printf '%s\n' "$bodies" | awk -v sep="$rs" '
  { raw[NR] = $0; s = $0; sub(/\r$/, "", s); sub(/[ \t]+$/, "", s); if (s == sep && pending) { cut = NR; pending = 0 } }
  '"$split$fenced"'
  /^restart$/ { pending = 1 }
  END { if (pending) cut = NR; for (i = cut + 1; i <= NR; i++) print raw[i] }
')"
```

The first rule runs before `split`'s `next` on the separator, so the cut lands on the separator that ends the restart comment; `fenced` precedes the `restart` rule, so a fenced `restart` does not cut; `split` strips CR and trailing blanks, so `^restart$` holds for a web-posted comment; a restart comment with no separator after it (a single-comment `--previous` file) cuts at EOF. What follows: `top` is 0 when nothing follows (round 1), the `settled:` line is not printed when `bodies` is empty (as for a fresh PR), and the three-round refusal counts only the comments after the last restart. `--round N` overrides the round as before; `--previous FILE` is sliced the same way. Nothing before a restart carries into `## Settled in earlier rounds`, including the restart comment's own items: they were settled against the old design, and a decision the new series still needs is cited again in its round one and carries from its round two. The header comment (`:8-13`) gains one sentence saying so.

**Prose edits, per file, as the sentence to add.**

- `spec-review/SKILL.md` step 1 (`:25`, after "…so a comment rebuilt in the same round does not advance it."): "A comment carrying the line `restart` (step 6: a design hole returned to architect) ends the history: the round and the settled items are read from the comments after the last such comment, so the redesign's first review is round 1 with nothing carried, and the fourth-round refusal counts only what follows it."
- `spec-review/SKILL.md` step 4 (`:84`, after the step rule's quote): "Then the spec rule, word for word: "<`spec_rule`>"." (the test pins it).
- `spec-review/SKILL.md` step 5, a paragraph before "Three trailing fields" and that line reading "Four trailing fields, each with one grammar:": "A finding is a design hole when its fix changes the artifact the work was built against rather than the code that implements it. Three artifacts, and every ticket has at least one: the scenario table under `## Testing decisions` (a cell's expected outcome, a new row or column, or the contract's meaning of a term the cells use, such as what counts as in flight, a named path, a covering go), the usage and signature sketch under `## Design` (a signature, a type, or how a caller uses it), and the acceptance criteria (what a criterion asks for). The ticket's intent, its What to build or Decision quotes, outranks any one criterion: a criterion that must change is a hole, and architect re-derives it from the intent. A refusal added under an existing could-not-run clause is not a hole. Detection is sharpest for a table and softest for a criterion; test for all three. Every counted report item names what it rests on in its `spec:` line (step 4); it is a hole when its fix changes that thing." And the fourth bullet after `fixed:`: "- `hole: <reference>` on an Act on item repeats the judged item's `spec:` reference, `table <row>/<column>`, `design <signature>` or `criterion <k>`, and says its fix changes that artifact: a design hole. Step 6 leaves it out of the count and prints the line `restart`. A hole is never fixed on this PR: the Ticket playbook (step 8) returns it to architect scoped to that reference, and no other Act on item is fixed here until the redesign is reviewed from round one."
- `spec-review/SKILL.md` step 6 (`:138`): after "a one-line summary," insert "the line `restart` on its own when any Act on item carries `hole:`,"; in the refusal sentence (`:140`) after the `Documented step:` clause: "when a `## Would break` or `## Fails open` item has no `spec:` line in one of the three forms (ask the reviewer for it); when a `hole:` field fits no form, sits under a heading other than Act on, marks an item that is not under `## Would break` or `## Fails open`, or names a reference other than that item's `spec:` line;".
- `docs/agents/review-ladder.md` rung 1 (`:6`, after "An Ask item waits for the human."): "A finding is a design hole when its fix changes the artifact the work was built against rather than the code that implements it: the ticket's scenario table (a cell's expected outcome, a new row or column, or the contract's meaning of a term the cells use), its `## Design` sketch (a signature, a type, or how a caller uses it) or an acceptance criterion (what it asks for; the ticket's intent outranks any one criterion, and architect re-derives one that must change); a refusal added under an existing could-not-run clause is not a hole. A hole is never fixed on the PR: the judgment marks it `hole: <reference>`, the comment carries the line `restart`, the work returns to architect scoped to that cell, signature or criterion, and the redesign is reviewed from round one."
- `poteto-mode/playbooks/ticket.md` step 8 (after "Then run **Opening a PR**."): "A `spec-review` comment carrying the line `restart` names a design hole (`hole: <reference>` in its judgment) and is never fixed on this PR: go back to step 5's playbook at its `architect` step, Phase B only, scoped to that cell, signature or criterion, with the finding and the artifact as grounding, two runners, and the judge skipped when they converge; amend the artifact on the ticket with a dated line (`Amended <date> by PR #<pr> (review round <r>, hole at <reference>): …`; a criterion is re-derived from the ticket's intent, its What to build or Decision quotes, and the line shows old and new); then steps 6 to 8 again on this branch, the PR already open. The next review starts at round one."
- `poteto-mode/playbooks/babysit.md` step 6 (`:16`, appended to the paragraph) and `babysit/SKILL.md` step 4 (`:40`, appended to the bullet), the same sentence: "A review comment carrying the line `restart` names a design hole: it makes the PR neither review-ready nor a blocker to fix here, whatever its count, and the Ticket playbook (step 8) owns the return to architect; the redesign's own review, from round one, is what babysit reads next." Everything before it is byte-identical, which is criterion 7.
- `SOURCES.md` item 6: one sentence on `spec:`, `hole:`, `restart` and the reset; items 4 and 12: the babysit sentence.

**Files touched, with the reason.** `template/.agents/skills/spec-review/scripts/review-brief.sh` (the slice, `ref`, the `cites` alternative, `spec_rule`, the header); `template/.agents/skills/spec-review/scripts/review-comment.sh` (`ref`, `lacking`, `specof`, the hole checks, `restart`, the count, the header); `template/.agents/skills/spec-review/SKILL.md` with `patches/mattpocock/spec-review.SKILL.md.patch` (steps 1, 4, 5, 6); `template/docs/agents/review-ladder.md` (rung 1); `template/.agents/skills/poteto-mode/playbooks/ticket.md` (step 8); `template/.agents/skills/poteto-mode/playbooks/babysit.md` with `patches/pstack/poteto-mode/playbooks/babysit.md.patch` and `template/.agents/skills/babysit/SKILL.md` with `patches/pstack/babysit/SKILL.md.patch` (one sentence each); `SOURCES.md` (items 4, 6, 12); `tests/spec-review/review-brief.sh` and `tests/spec-review/review-comment.sh`. No new file, no renumbered step; `arena`, `architect`, `MANUAL.md`, `DECISIONS.md` (the owner's Provisional entry amending P18, P20, P21) and `no-stale-wording.sh` untouched.

**Tests, one assertion per cell.** `tests/spec-review/review-comment.sh`: rows B4 (the `restart` line before `round:`, the count without the hole, exact stdout), B5, B6, B7, B8, B9, B10 (accepted, count per the last field), B11, B12 (a malformed `spec:` and a fenced one), B13 (step refusal wins), B14 (accepted). `tests/spec-review/review-brief.sh`: the `spec_rule` anti-drift and layout beside `step_rule`; the `ref=` line equal across the two scripts (beside `fragment()`); rows A5, A6 (three comments, the third a restart, `round: 1 of 3`, no `settled:` line, no settled section), A7 (refused after three post-restart comments, exact message, no state), A8, A11 (prose, fenced and trailing-text `restart`), A12 (through `pr me me:<file>` and the fake gh, so the jq filter is what is tested), A13, A14–A16 (each form carried, the exact `settled:` line and the pasted line in both briefs), A17 (dropped and counted).

## Tradeoffs accepted

- We accept that nothing before a restart carries as settled, even an item cited to a `user:` quote or a `DECISIONS.md` row that the redesign did not touch, in exchange for one rule with no exceptions ("the history is what follows the last restart") and two derivations that stay untouched behind one slice. The cost is one re-raised item per still-valid decision in the new round one, re-dismissed with the same cite.
- We accept that `hole:` repeats the reviewer's `spec:` reference instead of deriving it, because criterion 3 fixes the grammar; the equality check (row B8) is what keeps the copy honest, and a judge who disagrees with the reference sends the report back, the existing route for an off-shape report.
- We accept that a `hole:` is refused outside Act on and when malformed, while `fixed:` and `ticket:` stay inert text outside their grammar today, because a hole silently ignored costs a redesign cycle and a stray `fixed:` costs one counted item the judge sees.
- We accept a restart comment whose `act-on items:` reads 0 and can read `round: 3 of 3`, in exchange for leaving the count's meaning and the "last line" contract as they are; the one sentence in the two babysit files is what makes that comment unreadable as ready.
- We accept that on a restart the round's other Act on items are neither fixed nor marked (they wait for the redesign and are re-found by it or not), so the count on a restart comment is informational; fixing on a design about to change is the waste the ticket names.
- We accept `design [^ ].*` as a loose grammar for a signature, because a signature carries spaces and parentheses and the line's end is the only reliable delimiter; the `$` anchor and "last field" rule still hold.

## Alternatives considered

- **A restart flag inside the two awks instead of slicing `bodies`.** `split`'s fold becomes `if (restart) top = 0; else if (r > top) top = r`, and the `judged` awk buffers lines and clears its buffer on `restart`. It touches both derivations and the shared `split` fragment, and the judged buffer has to know a `restart` line comes after the items it has already collected. Lost on reader load: two changed derivations against one slice they never see.
- **Carry settled items cited to a decision (`user:`, `DECISIONS.md`, `#N comment`) across a restart and drop only artifact cites.** Better recall of settled decisions, but it needs the judged awk to know each line's position relative to the last restart and two citation classes to be filtered differently, and it leaves an artifact-cited item from a cell the redesign did not touch dropped anyway. Lost on rule count: one exception where the chosen shape has none.
- **Count holes in `act-on items:` so a restart comment never reads 0.** Would make babysit safe with no babysit edit, but contradicts criterion 3 ("leaves it out of the count") and blurs what the count means (items still to act on here).
- **Print `restart` after `act-on items:`.** Breaks the "always last" contract that three prose surfaces and 18 exact-stdout cases per suite state, and babysit reads the last line.
- **A `## Hole` bucket in the judgment instead of a field on an Act on item.** Changes the five-heading shape every report and test pins and the reference-set check; the field form is what `fixed:` and `ticket:` already are, and the criterion asks for it.
- **A `restart` comment written by hand with no count line.** Invisible to the existing jq filter, so it would need a second filter or a second fetch; the printed comment already carries `act-on items:`, so the restart rides on the comment the script prints.

## Open questions and risks

- Is dropping every settled item at a restart acceptable to you, or do you want decision-cited items (`user:`, `DECISIONS.md`, `#N comment`) to survive it? The chosen shape drops all; the alternative costs a second filter.
- Should the round-three procedure (fix the remaining Act on items here, mark `fixed:`) still run when the third round finds a hole, or do those items wait for the redesign as designed here? The script allows `fixed:` marks beside a `hole:`; the playbook sentence says the fixes wait.
- Is `table <row>/<column>` the right cell address for tables whose columns are unlabeled, or whose contract, not a cell, is what changed? The design points such a hole at the cell whose meaning changed; a `contract <term>` form would be a fourth grammar.
- Ticket step 8 is where the restart sentence lands because `spec-review` runs inside "Opening a PR"; is that the step you read for it, or step 9? The sentence moves without changing shape.
- Risk: `design [^ ].*` accepts any text after `design `, so a typo in a signature is a well-formed reference; the judge's equality check catches a mismatch between reviewer and judge, not a wrong signature they agree on.
- Risk: the babysit sentence is prose read by an agent; nothing mechanical stops a hand-run babysit from calling a mid-restart PR ready. The ladder and both babysit files say the same thing, and the Ticket playbook never reaches step 9 mid-restart.
- The Provisional entry amending P18, P20 and P21 is yours to write; the design gives its rows the words above.

## Next implementation step

Write the two test cases first, row B4 in `tests/spec-review/review-comment.sh` (exact stdout with `restart` before `round:` and the hole out of the count) and row A6 in `tests/spec-review/review-brief.sh` (three comments, the third a restart, printing `round: 1 of 3` with no `settled:` line), then the `ref=` line in both scripts.
