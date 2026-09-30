# Candidate B: design hole, restart, and the `spec:` anchor (ticket #90)

## Problem

`spec-review` today can tell you a finding is real but not what it is *about*. Every Would-break and Fails-open item names a `Documented step:` — the line of documentation a user follows — and nothing names the artifact the work was built against. So the judge has no mechanical way to say "fixing this changes the table, not the code", and the playbook has no path for that answer: the only route for any finding is a fix on the PR. PR #87 is what that costs — three designs, each review grading against a different one. #90 closes the gap with four mechanisms that have to land as one: a `spec:` line on every counted item, a `hole:` mark in the judgment, a `restart` line in the posted comment, and three new `cites:` forms so a decision that rests on an artifact still carries.

The constraints that make the shape non-obvious are all in the existing plumbing. There is no database: the round and the settled set are recomputed from the PR's own comments on every run (`review-brief.sh:128-161`), and `.scratch/review/<id>` is destroyed each time (`:163`), so a restart cannot be a state file — it has to be a line in a posted comment. But only the PR author's comments carrying a line `act-on items:` are fetched at all (the jq filter at `:94`), and `BEGIN { r = 1 }` at `:134` makes *any* fetched comment force round two or more, so round one is unreachable once one review comment exists — that is precisely the knob a restart must turn. `act-on items: N` must stay the final printed line, because `SKILL.md:138`, `babysit.md:16`, `babysit/SKILL.md:40` and `review-ladder.md:6` all say so and every `accept` case in the comment test compares the whole stdout block. `SKILL.md` is a patched file, so each sentence lands twice (patch and template) in one commit or CI's vendoring gate fails; both scripts and `ticket.md` are kept files, edited directly. And `#91` (the walk's blast-radius lines) and `#93` (rounds four and five) own adjacent ground, so nothing here may depend on either.

## Usage (caller's view)

### 1. A clean round: the reviewer names what the finding rests on

The Standards reviewer reads its brief. Under `## Report` it now finds, immediately after the `Documented step:` rule:

> The same item carries a line `spec:` naming the artifact it rests on: `table <row>/<column>` for a cell of the ticket's scenario table, `design <signature>` for a signature or usage in its `## Design` sketch, or `criterion <k>` for its k-th acceptance checkbox; an item without a `spec:` line in one of those three forms is sent back.

It writes a hard item the way it always has, with one line more:

```
## Fails open

2. **The record step has no exit-2 branch.** Step 8 keys only on output and exit 1.
Documented step: `template/.agents/skills/poteto-mode/playbooks/ticket.md:12`
Result: the PR opens with no Overlap section and no signal the check failed.
spec: table 11/E
```

The orchestrator reads the two reports, writes `judgment.md`, and sorts that item under `## Act on` with no trailing field:

```
## Act on

3. [P1] **Step 8 had no exit-2 branch.** Real fails-open in the playbook text; rows 10E and 11E already say exit 2 stops and reports, so the table stands and the code does not match it. Implementation.
```

`scripts/review-comment.sh` prints exactly what it prints today — the two reports, the judgment, the summary, `round: 1 of 3`, `act-on items: 3` — and exits 0. Nothing about a clean round changed except that a counted item without its `spec:` line is now sent back to its reviewer the way a counted item without `Documented step:` already is.

### 2. A round that finds a hole

The Spec reviewer's item rests on a cell, and the fix would change that cell's text. The orchestrator judges it a design hole and marks it:

```
## Act on

1. [P2] **The contract diffs a stacked PR against `main`, so "its own commits" is wider than the table's "contains" column.** Real, and the fix changes what row 2/D means, not the code that implements it: the cell has to say the PR is diffed from the open PR it stacks on. Design hole. hole: table 2/D
```

`scripts/review-comment.sh` now prints three lines after the summary instead of two:

```
Standards: 0 would break, 1 fail open, of 4; Spec: 1 would break, 0 fail open, of 1; judged: act on 1 (0 fixed, 0 with a ticket, 1 a design hole), ask 0, consider 0, noted 3, dismissed 0; fixed point origin/main.
restart
round: 2 of 3
act-on items: 0
```

The orchestrator posts that comment, and then does **not** go to babysit. `ticket.md`'s new **Design hole** section takes over: the work returns to `architect` Phase B scoped to `table 2/D`, with the judgment item, its report item and the ticket's `## Testing decisions` section as grounding, two runners and the judge skipped when they converge; the architect's answer is appended to the ticket's artifact as a dated line —

```
Amended 2026-09-22 after #90 round two: each PR is diffed from the open PR it stacks on, else `main` (row 2/D and the contract's "own commits"); no assertion changed.
```

— the tests are rewritten from the amended cell, the work is redone, and the next `scripts/review-brief.sh origin/main` prints:

```
ticket: #42
restart: a design hole restarted this PR's review; the round and the settled set count from it
round: 1 of 3
settled: carried 0, dropped 0 without a citation
.scratch/review/origin_main/standards-brief.md
.scratch/review/origin_main/spec-brief.md
```

Three fresh rounds, not the one that was left.

### 3. The round after the redesign

Round one after a restart carries nothing. Both briefs have no `## Settled in earlier rounds` section, and the two reviewers see the PR as if it had never been reviewed. That is the point: every Noted and Dismissed item from before was judged against an artifact that no longer says the same thing, and the judgments that survive a redesign are the ones a reviewer will reach again anyway.

The orchestrator gets the earlier decisions back the way the system already provides for — by citing them. A decision it wants to keep goes into the *new* round's judgment with a citation, and from round two of the new count it carries as settled:

```
## Noted

4. [S3] **`--limit 100` truncates silently.** Valid and outside this repository's reality. cites: #42 comment 2026-09-21
5. [S4] **The stacked-PR base is the open PR under it.** Settled when the cell was amended. cites: #42 table 2/D
```

The second is the new form: a `cites:` that names a cell of the amended artifact. From here on it carries into every later round's briefs like any other settled item — and if a *later* restart amends that cell again, it is dropped again, along with everything else.

## Shape

*The text below is what gets appended to ticket #90 under `## Testing decisions`. Its inner headings are written `###` here so this package stays one document; on the ticket they are `##`.*

Posted by the agent 2026-09-22

The scenario table below is the spec for the round logic: what `review-brief.sh` prints over a PR's comment history, and what `review-comment.sh` prints over the reports and the judgment. A review finding that changes a cell's expected outcome, adds a row or a column, or changes the meaning of a term the cells use — `restart`, `spec:`, `hole:`, what counts as a comment this subsystem can see — is a design hole: it returns to `architect`, this section is amended with a dated line, and the count starts over. A finding that leaves every cell standing while the code fails one is an implementation bug, fixed on the PR. A refusal added under an existing could-not-run clause is not a hole.

### Scenario table

There are two tables because there are two scripts and two inputs. Table A is `review-brief.sh` over the PR's comment history; Table B is `review-comment.sh` over the reports and the judgment.

**Table A — `review-brief.sh <fixed-point>`, by comment history.**

Cell = prints / exit / what the caller does. Printed lines, in this order: `T` = `ticket: #N` when a ticket is known; `X` = `restart: a design hole restarted this PR's review; the round and the settled set count from it`; `R(n)` = `round: n of 3`; `S(c,d)` = `settled: carried c, dropped d without a citation`, printed whenever any comment was fetched; `B` = the brief paths (`<dir>/standards-brief.md`, then `<dir>/spec-brief.md` or `no spec: Standards axis only`). Exit 0 always ends with `B`. Exit 1 prints one line on stderr and writes no state. **"Comment" always means a comment by the PR's author whose body has a line starting `act-on items:`**; anything else is never fetched and appears in no cell.

| Situation | A. default (`gh`) | B. `--previous FILE` | C. `--round N` |
|---|---|---|---|
| 1. No comment (no PR, empty PR, only strangers') | `T`, `R(1)`, `B` / 0 / brief both lanes, round one. A `gh` failure other than "no pull requests found" adds its existing stderr line and changes nothing else | an empty or absent-of-comments file is the same cell | `R(N)`; `--round 4` is row 4's refusal |
| 2. One comment, `round: 1 of 3` | `T`, `R(2)`, `S(c,d)`, `B` / 0 / round two; the cited items are in both briefs under `## Settled in earlier rounds` | same, from the file; the file is trusted wholesale, so a stranger's comment pasted in does count | `R(N)` overrides; `S(c,d)` unchanged |
| 3. Two comments, rounds 1 and 2 | `T`, `R(3)`, `S(c,d)`, `B` / 0 / the last round | same | `R(N)` |
| 4. Three comments, rounds 1, 2, 3 | `review-brief: three rounds were run on this PR; the remaining Act on items are fixed here and marked ``fixed: <sha>``, not reviewed in a fourth round` / 1 / stop; fix what is left on the PR and mark each `fixed: <sha>`. Nothing is printed on stdout and no state is written | same | `--round 3` prints `R(3)` and proceeds; `--round 4` is the same refusal |
| 5. Three comments, rounds 1, 2, 3, the third carrying `restart` | `T`, `X`, `R(1)`, `S(0,0)`, `B` / 0 / three fresh rounds; both briefs have no settled section | same | `R(N)` overrides the round, `X` still prints, so a caller sees the derivation it overrode |
| 6. Two comments, rounds 1 and 2, the second carrying `restart` | `T`, `X`, `R(1)`, `S(0,0)`, `B` / 0 / as row 5 | same | as row 5 |
| 7. A restart, then two more comments, rounds 1 and 2 | `T`, `X`, `R(3)`, `S(c,d)` over the comments after the restart only, `B` / 0 / the last round of the new count | same | as row 5 |
| 8. Two restart comments | `T`, `X`, `R(1)`, `S(0,0)`, `B` / 0 / counted from the later restart; a rebuilt restart comment is the same cell, so rerunning is idempotent | same | as row 5 |
| 9. A comment with no `round:` line | counts as round 1 (`BEGIN { r = 1 }`, unchanged): row 2's cell | same | `R(N)` |
| 10. Only comments by someone other than the PR's author | the jq author filter drops them: row 1's cell | `--previous` bypasses both filters, so the file's comments count: row 2's cell | `R(N)` |
| 11. The word "restart" inside a comment's prose ("we restart the count") | `^restart$` is anchored both ends: no reset, no `X`, row 2's or row 3's cell | same | same |
| 12. A `restart` line inside a fenced hunk | the shared `fenced` fragment skips it: no reset, no `X` | same | same |
| 13. A comment with a `restart` line but no `act-on items:` line | never fetched; invisible to the round scan and to carry-forward, so the round is row 2's or row 3's and no `X` prints / 0 / this is why `review-comment.sh` prints `restart` inside a full review comment, never on its own | same, unless the file holds it (`--previous` is trusted) | `R(N)` |
| 14. An earlier judgment's Noted item carries `cites: #42 table 2/D` | `S(c+1,d)`; the item's line is in both briefs' settled section verbatim / 0 | same | same |
| 15. `cites: #42 design nearest(ref)` | as row 14 | same | same |
| 16. `cites: #42 criterion 4` | as row 14 | same | same |
| 17. `cites: #42 table 2` (no column), `cites: #42 criterion` (no k), or any other malformed reference | no alternative matches, so the item is dropped: `S(c,d+1)` / 0 / the item is a normal one and the next round's reviewer may raise it again | same | same |
| 18. A restart in the last comment, with a cited Noted item in an earlier one | the cited item is dropped with everything else: `X`, `R(1)`, `S(0,0)` / 0 / to keep the decision, cite it again in the new round one's judgment | same | same |

**Table B — `review-comment.sh [<dir>]`, by what the report item carries and how the judgment marks it.**

Cell = prints / exit / what the caller does. A refusal is one line on stderr, `review-comment: <message>`, exit 1, before any stdout, clearing nothing; the caller fixes the named file and reruns `scripts/review-comment.sh <dir>`, which is the same round. Checks run in source order and the first failure is the only message: each report's shape, numbering, `hard findings:` line, the count ceiling, `Documented step:`, then `spec:`; then the judgment's existence, shape, numbering, item-count identity, `[S<n>]`/`[P<n>]` references, `hole:` placement, `hole:` value. `H` = the `restart` line, printed on its own line between the summary and `round: N of 3`, so `act-on items: N` stays last.

| Report item | A. no mark | B. `fixed: <sha>` | C. `ticket: #N` | D. `hole: <ref>` equal to the item's `spec:`, under `## Act on` | E. `hole: <ref>` well formed, different from the item's `spec:` | F. `hole: table 2` (malformed) | G. `hole: <ref>` under `## Ask`, `## Consider`, `## Noted` or `## Dismissed` |
|---|---|---|---|---|---|---|---|
| 1. `## Would break` item with `spec: table 2/D` | the comment, no `H`; the item is in `act-on items:` / 0 / fix it on the PR this round | not counted; summary reads `(1 fixed, 0 with a ticket, 0 a design hole)` / 0 / the fix is not reviewed again | not counted; `(0 fixed, 1 with a ticket, 0 a design hole)` / 0 / the finding is its own ticket | the comment, `H`, the item out of the count, summary `(0 fixed, 0 with a ticket, 1 a design hole)` / 0 / post it, then **Design hole** in the Ticket playbook: architect Phase B scoped to `table 2/D`, the ticket amended, review from round one. Not merge-ready | refused: `<dir>/judgment.md item '1. **Title.**' is marked 'hole: criterion 4' but [P2] rests on 'table 2/D'; the mark repeats the report item's 'spec:' line word for word` / 1 / correct the mark, or ask the reviewer to re-anchor the report item | the same refusal, with `'hole: table 2'` against `'table 2/D'` / 1 / the mark's grammar is checked by this equality; there is no second grammar to keep in step | refused: `<dir>/judgment.md item '1. **Title.**' carries a 'hole:' field under '## Ask'; 'hole:' marks an Act on item, as 'fixed:' and 'ticket:' do` / 1 / move it to `## Act on` and renumber, or drop the mark. An Ask item is never marked; it waits for the human |
| 2. `## Fails open` item with `spec: criterion 4` | as 1A | as 1B | as 1C | as 1D, scoped to `criterion 4`; architect re-derives the criterion from the ticket's intent (its **What to build** and Decision quotes) and the amendment names the old and the new wording | as 1E | as 1F | as 1G |
| 3. `## Would break` or `## Fails open` item with no `spec:` line | refused in every column, before the judgment is read: `<dir>/standards-report.md item '2. **Open, silently.**' under '## Fails open' has no 'spec:' line; a counted item names the artifact it rests on, one of 'spec: table <row>/<column>', 'spec: design <signature>' or 'spec: criterion <k>'. Ask the reviewer for it` / 1 / the report goes back to its reviewer with the refusal text; a new round is not started for it | ← | ← | ← | ← | ← | ← |
| 4. Counted item with `spec: table 2` or any reference outside the grammar | the same refusal as row 3, in every column: the message carries the three forms, so a reviewer who wrote a malformed line and one who wrote none are told the same correct thing / 1 | ← | ← | ← | ← | ← | ← |
| 5. `## Standards breaches`, `## Fix alongside` or `## Not asked for` item (never counted), with or without a `spec:` line | unchanged from today / 0 | unchanged / 0 | unchanged / 0 | refused: `... is marked 'hole: table 2/D' but [S3] rests on ''; the mark repeats the report item's 'spec:' line word for word` / 1 / a hole is marked only on a counted item; if the finding really changes the artifact, the reviewer re-sorts it under `## Would break` or `## Fails open` with its `spec:` line and the round is rebuilt | as 5D | as 5D | as 1G (placement is checked first) |
| 6. A `## Walk` line | not an item: not numbered with the findings, not counted, not judged, carries no `spec:`; a `hole:` written on a walk line is invisible / 0 / unchanged. #91's per-risk walk lines land here and change no cell | ← | ← | ← | ← | ← | ← |
| 7. A `spec:` line inside a fenced hunk under a counted item | does not satisfy the rule, exactly as a fenced `Documented step:` does not: row 3's refusal / 1 / the reviewer moves the line out of the hunk | ← | ← | ← | ← | ← | ← |

### Contract

**One reference grammar, one place.** Both scripts hold the same shell fragment, on one line, spelled identically:

```sh
ref='(table [^[:space:]/]+/[^[:space:]/]+|design [^[:space:]].*|criterion [0-9]+)'
```

`tests/spec-review/review-brief.sh` extends its existing `fragment()` helper (`:342`) to extract `^ref='…'$` from each script and fail when the two differ, the way it already holds the two copies of `fenced` together. Everything below is built from `$ref`, so there is one grammar per field and no second copy to drift:

- The `spec:` line on a counted report item: `^spec: $ref$`. Checked by `review-comment.sh`.
- The `hole:` field on an Act on judgment item: `hole: $ref$`, trailing text on the item's own single line, as `fixed:` and `ticket:` are. Its grammar is enforced **transitively**: the value must equal, word for word, the `spec:` value of the report item the judgment item names, and that value is already grammar-checked. One invariant, one checker.
- The three new `cites:` forms: a fourth alternative in `review-brief.sh:151`, `#[0-9]+ $ref`, beside the existing three, still `$`-anchored, so `cites:` remains the last field on its line:

```sh
cites='cites: (user: "[^"]+" on #[0-9]+|DECISIONS\.md [A-Z]?[0-9]+|#[0-9]+ comment [0-9]{4}-[0-9]{2}-[0-9]{2}|#[0-9]+ '"$ref"')$'
```

`review-comment.sh` still never reads `cites:`; `review-brief.sh` still never reads `hole:`.

**The rule `review-brief.sh` writes into both briefs.** A fifth shell variable beside `step_rule` and `count_rule` (`:240-243`), echoed at the same two call sites (`:324` Standards, `:352` Spec), one blank line after `$step_rule` and before the report-path line, so neither the test's "definition, blank, first quote" pin (`tests/spec-review/review-brief.sh:126-129`) nor the "no blank line between the report path and the count rule" layout moves:

```sh
spec_rule='The same item carries a line `spec:` naming the artifact it rests on: `table <row>/<column>` for a cell of the ticket'\''s scenario table, `design <signature>` for a signature or usage in its `## Design` sketch, or `criterion <k>` for its k-th acceptance checkbox; an item without a `spec:` line in one of those three forms is sent back.'
```

Its word-for-word twin goes into `SKILL.md` step 4, in the same sentence that already carries the step rule and the count rule (`:84`), and the brief test asserts it against `SKILL.md` alongside the other four strings (`:112-120`, `:153-160`).

**One scanner, not two.** `review-comment.sh`'s `stepless()` (`:54-62`) is replaced, not duplicated, by one fence-aware pass per report:

```sh
# rests <file> <prefix>: one line per numbered item, tab-separated:
#   <prefix><n>  <heading>  <the item's opening line>  <1 if it carries Documented step:>  <its spec: value or empty>
# Walk lines are not items; a line inside a fenced hunk satisfies nothing.
rests() { :; }   # TODO: the stepless() awk, carrying n, at, item, step and spec, flushed per item
```

`report()` reads it once and raises, in this order, the existing `Documented step:` refusal for the first counted item whose step flag is 0 — **message byte-identical to today's** — then the new `spec:` refusal for the first counted item whose `spec:` value does not match `^$ref$`. Adding a second scanner over the same items with the same fence rules would be the Duplicated Code smell the Standards axis flags, and PR #92 spent three rounds on exactly that shape in `overlap.sh`; the single pass removes one before adding none.

**The two new refusals on `hole:`**, both after the reference-set check at `:126` (so a judgment that misnames a report item fails on that first), both through `fail()`, exit 1, nothing cleared, nothing printed on stdout:

1. Placement. Any judgment item carrying a `hole:` field outside `## Act on`:
   `<dir>/judgment.md item '<N. **Title.**>' carries a 'hole:' field under '## <heading>'; 'hole:' marks an Act on item, as 'fixed:' and 'ticket:' do`
   A silently ignored hole mark would print no `restart` line and leave the count standing — a fail-open by the reports' own definition — so this is refused rather than passed through the way a stray `fixed:` on a Noted item is today.
2. Value. Any Act on item whose `hole:` value (everything after the last `hole: ` to end of line) differs from the `spec:` value `rests` recorded for the report item the item names:
   `<dir>/judgment.md item '<N. **Title.**>' is marked 'hole: <value>' but [S3] rests on '<spec value or empty>'; the mark repeats the report item's 'spec:' line word for word`
   This one refusal covers a malformed reference, a reference to the wrong artifact, and a hole marked on an item that rests on nothing.

**The count and the comment.** `holes="$(items "$dir/judgment.md" "Act on" | grep -cE "hole: $ref\$" || true)"`, beside `fixed_here` and `ticketed`; the three are mutually exclusive per line because each is `$`-anchored, so the arithmetic cannot go negative. The last three lines become:

```sh
echo "Standards: … judged: act on $act ($fixed_here fixed, $ticketed with a ticket, $holes a design hole), ask $ask, …"
[ "$holes" -eq 0 ] || echo "restart"
echo "round: $round of 3"
echo "act-on items: $((act - fixed_here - ticketed - holes + ask))"
```

`restart` sits between the summary and `round:`. `act-on items:` is still the last line and is still present and still `act-on items: 0` when zero, so `SKILL.md:138`, `review-ladder.md:6`, `babysit.md:16` and `babysit/SKILL.md:40` stay true and byte-identical. The summary gains `, N a design hole` inside the existing parentheses so a reader can reconcile `act on 1` with `act-on items: 0`; that is the only change to the 18 pinned `accept` strings per layout.

**The round after a restart, in `review-brief.sh`.** A third shared awk fragment, appended after `"$split$fenced"` in both awks so it is fence-aware:

```sh
restart_mark='
  /^restart$/ { rst = 1 }
'
```

`split`'s separator action (`:118`) and both awks' `END` blocks gain the same branch: when the comment just closed carried a restart, the accumulator is zeroed instead of folded, and the carried set is emptied —

```awk
$0 == sep { if (rst) { top = 0; n = 0; delete seen; delete out } else if (r > top) top = r
            fence = ""; h = ""; j = 0; r = 1; rst = 0; next }
```

— and `END { if (rst) top = 0; else if (r > top) top = r; print top }`, which matters because `--previous FILE` supplies one body with no trailing separator while `gh` emits one after every body. So: **the round is one more than the highest `round: N of 3` line among the comments that follow the last comment carrying a `restart` line; with no such comment the derivation is exactly today's.** Because the restart comment itself is on the wrong side of the reset, a restart comment posted last gives round 1. `--round N` still overrides everything, and the fourth-round refusal at `:140-143` still fires, before any stdout and before any state, for every history that reaches round 4 — a PR with no restart refuses exactly what it refused before.

`## Settled in earlier rounds` follows the same reset: the `judged` awk buffers its deduped lines and prints them at `END`, so the separator's `n = 0; delete seen` drops everything raised before the restart. A restart therefore carries nothing: `settled: carried 0, dropped 0 without a citation`, no settled section in either brief, and a decision worth keeping is cited again in the new round one's judgment. The authority of a settled item is its citation, and a citation to `#N table 2/D` points at the very cell the restart is amending; dropping the set is the honest answer and the one line of awk.

One new printed line, only when a restart was seen, between `ticket:` and `round:`:

```
restart: a design hole restarted this PR's review; the round and the settled set count from it
```

It prints whether or not `--round` overrode the derivation, so a caller who forces a round sees what it disagreed with. Round 1 on a PR with three review comments would otherwise read as a bug.

**Idempotence and derivation.** Nothing is stored. Rerunning `review-brief.sh` in the same round reads the same comments and prints the same `restart:`, `round:` and `settled:` lines; rerunning `review-comment.sh <dir>` on the same three files prints the same comment including `restart`. A restart comment reposted in the same round (an Ask answered, the judgment re-sorted) carries `restart` again and resets to the same round 1. Two restart comments in a history reset from the later one. `<dir>/round` is still written only so `review-comment.sh` can echo it back; it is not a counter.

**Babysit.** On a restart comment babysit reads what it reads today: `act-on items: 0` on the latest commit, and `round: N of 3`. Both existing sentences (`babysit.md:16`, `babysit/SKILL.md:40`) stay byte-identical, and for a PR with no design hole nothing about merge-ready changes — no `restart` line is printed, so the new clause never fires. But a hole marked in round three would print `round: 3 of 3` and `act-on items: 0`, which is exactly the sentence that makes a PR review-ready even when fix commits come later; so one sentence is added as its own new paragraph after `babysit.md:16` and its own new bullet after `babysit/SKILL.md:40`, leaving those two lines untouched:

> A comment carrying a line `restart` is not a merge-ready comment whatever its count: a design hole returns the work to `architect` (the Ticket playbook, **Design hole**), and the PR is ready only when a later review comment carries no `restart` line.

That is what makes a PR mid-restart unable to read as review-ready in every round, not only in rounds one and two where the missing-comment-on-the-latest-commit rule would have caught it once the redesign landed.

**The prose edits, per file, as the sentence to add.**

| File | Vendoring | The edit |
|---|---|---|
| `template/.agents/skills/spec-review/scripts/review-brief.sh` | kept, direct | `ref=`, the fourth `cites:` alternative, `restart_mark`, the reset in `split` and both `END`s, the buffered `judged`, the `restart:` line, `spec_rule` at both call sites |
| `template/.agents/skills/spec-review/scripts/review-comment.sh` | kept, direct | `ref=`, `rests()` replacing `stepless()`, the `spec:` refusal, the two `hole:` refusals, `holes` in the summary and the count, the `restart` line |
| `template/.agents/skills/spec-review/SKILL.md` + `patches/mattpocock/spec-review.SKILL.md.patch` | patched pair, one commit | **Step 1**: "A comment carrying a line `restart` on its own restarts the count: the round is one more than the highest `round: N of 3` among the comments after the last such comment, nothing earlier carries as settled, and a fourth round is refused exactly as before." **Step 4**: `$spec_rule` word for word, in the sentence at `:84` that already carries the step rule and the count rule. **Step 5**: the design-hole definition (below), and `Three trailing fields` → `Four trailing fields`, with the `hole:` bullet after `fixed:`: "`hole: <reference>` on an Act on item says the finding's fix changes the artifact the work was built against, not the code: it repeats that report item's `spec:` line word for word, step 6 does not count it and prints `restart`, and the fix is never made on this PR — the Ticket playbook's **Design hole** section returns the work to `architect`." **Step 6**: the three new refusals added to the list at `:140`, and "`restart` prints on its own line between the summary and `round: N of 3` when any Act on item is marked `hole:`; `act-on items: N` is still the last line." |
| `template/docs/agents/review-ladder.md` (rung 1, `:6`) | ours, direct; no root copy | "A finding is a design hole when its fix changes the artifact the work was built against rather than the code that implements it: a cell of the ticket's scenario table (its expected outcome, a new row or column, or the meaning of a term the cells use), a signature or a usage in its `## Design` sketch, or an acceptance criterion — the ticket's intent, its **What to build** or Decision quotes, outranks any one criterion, so a criterion that must change is a hole and `architect` re-derives it from the intent. A refusal added under an existing could-not-run clause is not a hole. Detection is sharpest for a table and softest for a criterion; all three are marked the same way. A design hole is never fixed on the PR: the judgment marks it `hole: <reference>`, the comment carries a `restart` line, and the review starts again at round one on the redesigned work." |
| `template/.agents/skills/poteto-mode/playbooks/ticket.md` | kept, direct | Step 9 gains one sentence, no renumbering: "A review comment carrying a `restart` line goes to **Design hole** below, not to babysit." Then a new `### Design hole` section after the **Reply** line, parallel to `### Quick ticket` (content below). |
| `template/.agents/skills/poteto-mode/playbooks/babysit.md` + its patch | patched pair | the restart sentence, as a new indented paragraph after `:16`; `:16` unchanged |
| `template/.agents/skills/babysit/SKILL.md` + its patch | patched pair | the same sentence, as a new bullet after `:40`; `:40` unchanged |
| `SOURCES.md` items 6, 4 and 12 | prose of the patches | one clause each, describing the `spec:` line, the `hole:` mark, the `restart` reset and the restart clause in babysit |
| `tests/spec-review/review-brief.sh`, `review-comment.sh`, `no-stale-wording.sh` | tests | the assertions below; `Three trailing fields` added to the stale-wording blacklist |

**The Ticket playbook's `### Design hole` section**, in full:

> **A finding whose fix changes the artifact is not fixed on the PR.** When the round's review comment carries a `restart` line, stop before babysit and do this instead.
>
> 1. Read the `hole:` reference on each marked item: a cell, a signature or a criterion. That is the scope, and nothing wider is redesigned in this pass.
> 2. Run `architect` Phase B scoped to it, with the judgment item, its report item and the artifact itself (the ticket's `## Testing decisions` table, its `## Design` sketch, or the criterion with the ticket's **What to build** and Decision quotes) as grounding. Two runners; the judge is skipped when they converge.
> 3. Amend the artifact on the ticket with a dated line in its own section — "Amended `<date>` by #N: `<what changed and why>`; `<which assertions moved>`" — never a rewrite of what was there. A criterion is re-derived from the ticket's intent, and the line names the old and the new wording.
> 4. Rewrite the tests from the amended artifact before the code, as step 6 says, then redo the work.
> 5. Review the redesigned work from round one: `review-brief.sh` reads the restart from the PR's own comments and starts the count over. Nothing from before the restart carries as settled; a decision worth keeping is cited again in the new round one's judgment.
> 6. Only then step 9. A PR mid-restart is never merge-ready.

**The tests, one per new cell.** In `tests/spec-review/review-comment.sh`: a counted item with each of the three `spec:` forms (accept); one with none and one malformed (refuse, same message); one whose `spec:` sits in a fenced hunk (refuse); a `hole:` matching its item's `spec:` (accept, exact stdout with `restart` between the summary and `round:`, and `act-on items:` excluding it); a `hole:` on an item whose report item rests on nothing (refuse); a `hole:` that differs from its item's `spec:` (refuse); a `hole:` under `## Noted` (refuse). In `tests/spec-review/review-brief.sh`: the restart rows through `pr me me:c1.md me:c2.md` and the fake `gh`, since `--previous` carries one body only; a restart as the third comment; two restarts; `restart` in prose and inside a fence; a cite of a cell, a signature and a criterion carrying forward, and a malformed one dropped; the `--round 4` refusal unchanged on a PR with no restart; and `fragment()` extended to hold the two copies of `ref` together.

**Criteria map.** Criterion 1 → the rung-1 sentence and `SKILL.md` step 5. Criterion 2 → `spec_rule` at both call sites, Table B rows 1–4 and 7. Criterion 3 → Table B columns D–G, the `holes` term and the `restart` line. Criterion 4 → the `### Design hole` section, Table A rows 5–8 and 13, the babysit sentence. Criterion 5 → the fourth `cites:` alternative, Table A rows 14–18. Criterion 6 → the test list above. Criterion 7 → `babysit.md:16` and `babysit/SKILL.md:40` byte-identical, Table B row 1 columns A–C unchanged. Nothing here reads a round above 3 (#93) or writes a `## Walk` line (#91).

## Tradeoffs accepted

- We accept that the `hole:` reference is written twice — once as the report item's `spec:` line, once as the judgment's mark — in exchange for a single grammar with a single checker: the mark must repeat the line word for word, so a malformed reference, a typo and a mark on the wrong item are all one refusal, and the judgment never invents an artifact the reports did not rest on.
- We accept that the judge cannot widen a hole's scope beyond what the report item rests on, in exchange for the judgment staying a sorting step. The architect lane gets the finding and the whole artifact as grounding and decides what to redesign; if the reviewer anchored the item wrongly, the report goes back to the reviewer, which is the existing route for a report that says the wrong thing.
- We accept that a restart drops every settled item, including ones cited to `DECISIONS.md` or to a user quote, in exchange for one line of awk and an unambiguous rule. The alternative — keeping the older citation forms and dropping only artifact citations — needs the awk to know which comment each line came from, and it would leave decisions standing that were made against a table that no longer says the same thing.
- We accept one new printed line in `review-brief.sh` (`restart: …`) and four new words in `review-comment.sh`'s summary (`, N a design hole`), in exchange for a reader being able to reconcile round 1 on a much-reviewed PR and `act on 1` with `act-on items: 0`. The cost is mechanical churn in the pinned `accept` strings, which the tests catch immediately.
- We accept replacing `stepless()` rather than adding a sibling, in exchange for one fence-aware scan over the items. The refusal messages stay byte-identical, and the refusal order (step before spec) is named in the contract so it is a decision rather than an accident.
- We accept two added sentences in patched babysit files, in exchange for a PR mid-restart being unable to read as review-ready in round three, where the existing "fix commits may come later" sentence would otherwise pass it.
- We accept that `hole:` on a non-Act-on item is refused rather than ignored, which is a departure from how a stray `fixed:` behaves today, because a hole mark that is silently dropped prints no `restart` line and lets the PR read as done.

## Alternatives considered

- **Count the hole item instead of excluding it.** `act-on items:` would go nonzero on its own and babysit would block with no new sentence anywhere, which is cheaper and semantically defensible — a hole is the most work of all. It loses because criterion 3 says the mark leaves the item out of the count, and because the count then means two different things: work to do on this PR, and work to do after a redesign. The interface stays smaller with one meaning and one extra line.
- **A `## Design hole` heading in the judgment instead of a trailing field.** A sixth bucket reads well and needs no per-line grammar. It loses on interface depth: it breaks the fixed five-heading shape that `shape()` and three prose surfaces pin, it forces every `[S<n>]` reference-set check and every numbering rule to learn a new heading, and it hides nothing the trailing field does not hide. `fixed:` and `ticket:` already set the pattern for "this Act on item is settled another way".
- **A `restart` marker recorded in `.claude/state/` or `<dir>/`.** It would make the reset a boolean read rather than a derivation. It loses outright: `review-brief.sh:163` destroys the review dir on every run and `review-comment.sh:159` clears the state, so nothing there survives to the next round; a restart has to live in a posted comment, and deriving it there is also what makes the reruns idempotent.
- **`restart: <reference>` instead of a bare `restart`.** It would put the scope in the machine-readable line. It loses because a comment can carry several holes, so the line would have to repeat or carry a list, and `review-brief.sh` needs only the boolean. The scope is already in the judgment's `hole:` items, in the same comment, next to their reasons.
- **Check `spec:` for presence only, and check `hole:`'s grammar separately.** Two regexes, two refusals, and one more place for the grammar to drift. It loses to the equality check, which needs one grammar and gives a message that names both strings.
- **Put the restart rule in `arena/SKILL.md`.** "Two runners; the judge is skipped when they converge" would live beside the arena it modifies. It loses because arena has no patch file today, so it would cost a new patch and a new `series` line for one sentence, and because the rule is about this transition, not about arena in general — it belongs in the Ticket playbook's **Design hole** section.

## Open questions and risks

- Should a hole marked in round three still print `round: 3 of 3`, or should the printed round be suppressed when a restart is present, since the number no longer means anything to the next run? The contract above keeps it, because `<dir>/round` is what `review-comment.sh` echoes and suppressing it would make one more prose surface conditional — is that the call you want?
- A restart drops every settled item, including one cited to a `user:` quote that the redesign cannot touch. Is re-citing it in the new round one acceptable friction, or would you rather keep the three older citation forms across a restart and drop only the new artifact-citing ones?
- Should `review-brief.sh` refuse when a PR has, say, three restarts — a signal that the design is being reworked round after round rather than reviewed — or is that the human's read rather than a gate? Nothing in the contract counts restarts today.
- The `hole:` mark must equal the report item's `spec:` line word for word. If a reviewer anchors an item to `criterion 4` and the judge is certain the real hole is `table 2/D`, the route is back through the reviewer. Is that the right ownership, or should the judge be allowed to name any reference the reports carry?
- `DECISIONS.md` P18 (what a finding is), P20 (three rounds) and P21 (what carries) all become inexact once a restart exists. Those amendments are yours to write; do you want them as inline "Amended `<date>` (#90)" clauses on the three rows, or a new Provisional row for the design hole?
- Risk: `--previous FILE` carries one comment body only unless the file holds literal RS bytes, so every restart test has to go through the fake `gh` path (`pr me me:c1.md me:c2.md`). That path is already exercised (`tests/spec-review/review-brief.sh:252-305`), but the restart rows are the first to depend on multi-comment histories heavily.

## Next implementation step

Add `ref='…'` to both scripts and extend `tests/spec-review/review-brief.sh`'s `fragment()` to fail when the two copies differ — the one-grammar invariant goes in first, as a test, before any rule that reads it.
