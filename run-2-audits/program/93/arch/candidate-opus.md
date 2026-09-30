# Candidate design for #93 (`claude:opus@high`)

The first part is the `## Testing decisions` section as it goes on the ticket. The second part, after the rule, is the rationale and is not posted.

---

## Testing decisions

Posted by the agent 2026-09-22

The two tables below are the spec for the extra rounds; the contract under them is what the scripts implement. Table A is `review-brief.sh` over the PR's comment history, table B is `review-comment.sh` over one round's judgment and reports. A review finding that changes a cell, adds a row or a column, or changes the meaning of a term the cells use (what a would-break fix is, what the reviewed commit is, what the last comment is) is a design hole under P27: it returns to architect and this section is amended with a dated line. A finding that leaves the tables standing while the code fails a cell is an implementation bug fixed on the PR. A refusal added under an existing could-not-run clause is not a hole. The design rests on one new comment line and one new file in the review dir; everything else is prose and readers. #90's tables A and B stand unchanged: no cell of theirs moves, and the two rows this ticket adds to each are marked.

### Terms

A **comment** is a comment on the PR by its author whose body has a line starting `act-on items:` (`review-brief.sh:100`); anything else is never fetched and appears in no cell. A **restart comment** is a comment with a line that is exactly `restart` outside fenced text (#90). The **surviving history** is the comments after the last restart comment, the restart comment itself cut (`review-brief.sh:144-159`); every term below is read from it alone. The **last comment** is the last comment of the surviving history, so a comment rebuilt in the same round supersedes the one it replaces.

A **counted item** is a report item under `## Would break` or `## Fails open`. A **would-break item** is a report item under `## Would break` in either report, whatever the judgment says about it; `## Fails open`, `## Standards breaches`, `## Fix alongside` and `## Not asked for` items are not would-break. A **would-break fix** is a judgment item under `## Act on` whose line ends in a well-formed `fixed: <sha>` field and whose `[S<n>]`/`[P<n>]` reference names a would-break item; the heading comes from `specs()` (`review-comment.sh:77-85`), which already prints `<heading>\t<reference>` per counted report item in document order, and the `<heading>` half is filled even in a review with no spec. A would-break item marked `ticket: #N`, marked `hole: <ref>`, or sorted under `## Ask`, `## Consider`, `## Noted` or `## Dismissed` is not a would-break fix.

The **reviewed commit** is the commit the round's diff ran against at brief time, `git rev-parse HEAD` when `review-brief.sh` wrote the dir, held in `<dir>/reviewed` as 40 hex characters. It is not the fixed point: `<dir>/fixed-point` holds the ref the diff was taken *from*, and the reviewed commit is the tip the diff was taken *to*. `review-comment.sh` cannot compute it, because it runs after the fix lane committed.

The **`another round:` line** is the comment's new machine line, in one of two forms:

- the **fix form**, `another round: a would-break item was fixed here; this round reviewed <40 hex>`
- the **stop form**, `another round: none; the fifth round fixed a would-break item too, so this PR is unfinished and waits for the human`

**Owed** means the last comment carries the fix form: one more round is owed, its number is that comment's round plus one, and its fixed point is the commit that line names. **Stopped** means the last comment carries the stop form: no further round runs on this PR until a human acts.

The **cap in force** is 3, or 5 from the fourth round on: the `round:` line reads `round: N of 3` for N of 1 to 3 and `round: N of 5` for N of 4 or 5, so a PR that never owes a fourth round prints exactly what it prints today.

### Scenario table

Cell = prints / exit / what the caller does next.

Legend. `P(n)` = a comment of round n carrying no `another round:` line. `W(n)` = a comment of round n carrying the fix form, naming commit `c`. `S` = a round-five comment carrying the stop form. `X` = the line `restart: the round and the settled items count from the last restart comment` (#90). `R(n)` = the line `round: n of 3` for n ≤ 3, `round: n of 5` for n ≥ 4. `T` = the line `ticket: #N`. `E(c,d)` = the line `settled: carried c, dropped d without a citation` (#90). `Fx` = the fix-only paragraph in both briefs (contract, "The fix-only paragraph"). `paths` = the brief paths, printed last on exit 0. A history is written oldest first.

The refusals, each one line on stderr, exit 1, before `mkdir -p "$dir"` and before any state:

- `D1` = `review-brief: three rounds were run on this PR; the remaining Act on items are fixed here and marked ` `` `fixed: <sha>` `` `, not reviewed in a fourth round` — today's message, byte for byte.
- `D2` = `review-brief: the last review comment on this PR names no would-break fix, so no further round is owed; the remaining Act on items are fixed here and marked ` `` `fixed: <sha>` ``
- `D3` = `review-brief: five rounds is the cap on one PR and a sixth is not run; when five rounds fixed would-break items the PR is unfinished, and the report for the human on it is what unblocks it`
- `D4` = `review-brief: round <N> reviews the would-break fixes only: its fixed point is <c>, the commit the last round reviewed, and <fixed> is not that commit. Rerun as ` `` `review-brief.sh <c>` ``
- `D5` = `review-brief: the last review comment carries ` `` `another round: <rest>` `` `, which fits neither form; scripts/review-comment.sh writes the fix form, naming a 40-character commit id, or the round-five form ending ` `` `waits for the human` ``
- `V` = the warning `review-brief: round <N> reviews the fixes, whose commits need not name the ticket; none was named, so the Spec axis is skipped. Pass --ticket N when the earlier rounds had one`, on stderr, exit unaffected, the run continues.

**Table A: `review-brief.sh <fixed-point> [--ticket N]` over the comment history**

| Situation | A. default (`gh`) | B. `--round N` | C. `--previous FILE` |
|---|---|---|---|
| 1. No comment | `T`, `R(1)`, `paths` / 0 / round one, unchanged | `R(N)`, N ≤ 3 / 0; N = 4 or 5: `D1` / 1; N ≥ 6: `D3` / 1 | an empty file: as A |
| 2. `P(1)`, `P(2)`, `P(3)`: three rounds, no would-break fix | `D1` / 1 / the review is over; fix what remains, mark `fixed: <sha>`, rebuild with `review-comment.sh <dir>` — unchanged from today | `--round 3`: `R(3)`, `E` / 0 (a rebuild); `--round 4`: `D1` / 1 | as A |
| 3. `P(1)`, `P(2)`, `W(3)` at commit `c`, fixed point `c` | `T`, `R(4)`, `E`, `paths` / 0, both briefs carry `Fx` / round four reviews `c...HEAD`, the fixes alone | `--round 4`: as A / 0; `--round 5`: `D2` / 1 (the line licenses round four only) | as A, from the file |
| 4. `P(1)`, `P(2)`, `W(3)` at `c`, fixed point anything but `c` (`origin/main`, `HEAD~1`, a sha that is not `c`) | `D4` / 1 / rerun with `c` | same | same |
| 5. `P(1)`, `P(2)`, `W(3)` at `c`, and no commit since `c` (nothing was fixed) | the existing empty-diff refusal, `review-brief: the diff is empty; nothing to review since <c>` / 1 / commit the fixes first — existing message, no code | same | same |
| 6. `W(3)`, `P(4)`: round four fixed no would-break item | `D2` / 1 / the review is over; the round-four Act on items are fixed here and marked | `--round 5`: `D2` / 1 | as A |
| 7. `W(3)`, `W(4)` at `c'`, fixed point `c'` | `T`, `R(5)`, `E`, `paths` / 0, `Fx` / round five reviews the fixes alone; it is the last | `--round 5`: as A | as A |
| 8. `W(4)`, `S` (round five fixed a would-break item) | `D3` / 1, whatever the fixed point and whatever `--round` says / stop: the report for the human is on the PR, the PR is unfinished, take up the work that does not depend on it and wait | `D3` / 1, any N | as A |
| 9. `W(4)`, `P(5)`: round five fixed no would-break item | `D3` / 1 / the review converged at five; the PR is review-ready when that comment reads `act-on items: 0` | `D3` / 1 | as A |
| 10. `W(1)` with `act-on items: 0`, or `W(2)` (a would-break item fixed in round one or two) | `T`, `R(2)` or `R(3)`, `E`, `paths` / 0, no `Fx` / round two or three reviews the whole diff from the original fixed point, as today; the line only says another round is owed, and babysit will not call the PR ready on `W(1)` | `R(N)`, N ≤ 3 / 0 | as A |
| 11. `P(1)`, `W(2)`, `P(3)`: the would-break fix was two rounds back | `D1` / 1 / only the **last** comment decides; round three found no would-break fix, so the review is over | `--round 4`: `D1` / 1 | as A |
| 12. `W(3)` rebuilt in round three (an Ask answered, `review-comment.sh <dir>` rerun) so the last comment is `P(3)` | `D1` / 1 / the rebuild supersedes: the re-sort moved the item out of Act on, so nothing is owed | same | as A |
| 13. `P(3)` rebuilt as `W(3)` (the re-sort marked a would-break item `fixed:`) | as row 3 / 0 | same | as A |
| 14. A comment carrying both `restart` and the fix form (only reachable through `--previous`; `review-comment.sh` never writes both, table B row 9) | the restart cuts the history at and including that comment, so its line is never read: `X`, `R(1)`, no `E` / 0 / the redesign's round one | `X`, `R(N)` / 0 | as A |
| 15. The fix form inside a fenced hunk, in prose, or with trailing text | not the line: rows 2 and 11 / 1 or 0 as they say | same | as A |
| 16. Two `another round:` lines in the last comment (a quoted hunk above its own) | the last one in the comment is its own: rows 3 to 9 on that one | same | as A |
| 17. A comment by anyone but the PR's author carrying either form | not fetched: rows 1 to 16 on the rest / unchanged | same | the file is trusted wholesale, as today |
| 18. A body carrying the fix form and no `act-on items:` line | not fetched: the round and the owed state come from the rest | same | trusted: as row 3 |
| 19. The last comment carries `another round:` and the rest fits neither form (a truncated sha, a paste, `another round: yes`) | `D5` / 1 / the comment was hand-edited; post the comment `review-comment.sh` printed | same | same |
| 20. `W(3)` at `c` and `c` no longer resolves (the branch was rebased since round three) | `D4` / 1, naming `c` / the reviewed commit is gone; the fix-only round cannot run, so the human rebases back or closes the round at three — no second lookup, `D4` compares `git rev-parse <fixed>^{commit}` with `c` as strings | same | same |
| 21. Round four or five and no ticket was named or found in the fix commits | `V` on stderr, then as row 3 or 7 with the Standards axis only / 0 / pass `--ticket N`; the playbook's command does | same | as A |
| 22. Round four or five whose fix diff touches a cross-cutting path with no grounding | the existing cross-cutting refusal / 1 / unchanged, no code | same | as A |
| 23. The sweep form (`--paths ... --commits ...`) after a `W` comment on the checked-out branch | `fixed` is the word `paths`, so the fixed-point check is skipped: `R(4)`, `Fx`, `paths` / 0 / the sweep names its own diff by commits and paths | same | as A |

Rerunning any row in the same round prints the same lines: the round, the owed state and the settled set are functions of the fetched comments alone, and `.scratch/review/<id>` is rebuilt from scratch each run. `--previous` carries one comment unless the file holds the record separator `gh` emits, so the multi-comment rows are tested through the fake `gh` (`pr me me:c1.md me:c2.md`).

**Table B: `review-comment.sh [<dir>]` over one round's judgment and reports**

The judgment's fixed items are down the side; what the round and the reports hold is across. "As today" = the tail as printed today: the summary line, then `restart` when a hole is marked, then `round: N of 3`, then `act-on items: N` last. `A` = the fix form printed between the summary line and `round:`, in `restart`'s place, with the commit from `<dir>/reviewed`. `B` = the stop form in the same place. `C1` = the refusal `review-comment: <dir>/reviewed is missing; it holds the commit this round reviewed, which the next round needs as its fixed point because a would-break item is marked ` `` `fixed:` `` ` here. scripts/review-brief.sh writes it, and a dir from an older one has none: write that commit to <dir>/reviewed and rerun` — one line on stderr, exit 1, before any output, clearing nothing.

| The judgment's Act on items | A. round 1 or 2 | B. round 3 | C. round 4 | D. round 5 | E. `<dir>/reviewed` absent | F. review with no spec |
|---|---|---|---|---|---|---|
| 1. None marked `fixed:` | as today / 0 / unchanged | ← | as today with `round: 4 of 5` / 0 / the review is over unless the count is nonzero | as today with `round: 5 of 5` / 0 | as today / 0 / the file is never read | as today / 0 |
| 2. One `fixed: <sha>` on a `[S<n>]` under the Standards `## Would break` | as today plus `A` / 0 / another round is owed; babysit does not call the PR ready | ← | ← with `round: 4 of 5` | as today plus `B`, `round: 5 of 5` / 0 / post it, write the human the report, mark the PR unfinished, wait | `C1` / 1 / write the file and rerun | as row 2A; `specs` fills the heading with no `spec:` line, so no spec is needed to know the kind |
| 3. One `fixed: <sha>` on a `[P<n>]` under the Spec `## Would break` | as row 2 | ← | ← | ← | `C1` / 1 | cannot occur: a review with no spec has no `[P<n>]` items (the reference set is checked against 0 Spec items) |
| 4. One `fixed: <sha>` on an item under `## Fails open` | as today / 0 / the round may be the last; Manuel: a fail-open fix at round three "isnt all that dangerous" | ← | ← | ← | as today / 0 / never read | as today / 0 |
| 5. One `fixed: <sha>` on an item under `## Standards breaches`, `## Fix alongside` or `## Not asked for` | as today / 0 | ← | ← | ← | as today / 0 | as today / 0 |
| 6. Two or more would-break fixes | one `A` line, as row 2 / 0 / one line however many fixes | ← | ← | one `B` line / 0 | `C1` / 1 | as row 2F |
| 7. A would-break item `ticket: #N`, and a `## Fails open` item `fixed:` | as today / 0 / nothing is owed: a ticketed finding is not fixed here | ← | ← | ← | as today / 0 | as today / 0 |
| 8. A would-break item under `## Noted` or `## Dismissed`, nothing fixed under Act on | as today / 0 / a would-break item the judgment did not act on is not a fix | ← | ← | ← | as today / 0 | as today / 0 |
| 9. A would-break item `hole: <ref>`, another would-break item `fixed: <sha>` | as today: `restart`, no `another round:` line / 0 / the restart wins, the work returns to architect and the review restarts at round one | ← | ← | ← | as today / 0 / the file is not read when a hole is marked | the existing no-spec `hole:` refusal / 1 / unchanged |
| 10. One item whose line reads `hole: table 2/D fixed: abc1234` (the last field is the field, #90) | counted as a fix: as row 2 / 0 / no `restart`; the `hole:` is text | ← | ← | ← | `C1` / 1 | as row 2F |
| 11. A `## Walk` line carrying `fixed:` | not an item: never counted, never judged, invisible / 0 / unchanged | ← | ← | ← | as today / 0 | ← |
| 12. A would-break fix in the sweep form (`fixed point paths`) | as row 2; `<dir>/reviewed` holds the checked-out HEAD / 0 / table A row 23 | ← | ← | ← | `C1` / 1 | as row 2F |

Notes on the whole table. The `another round:` line is printed only when no hole is marked, so a comment carries `restart` or `another round:`, never both (row 9). `act-on items:` stays last and its arithmetic is unchanged: a would-break fix is a `fixed:` item and was already uncounted. The summary line is unchanged, `(X fixed, Y with a ticket)` included; the comment never prints how many of the fixes were would-break, because a count in the comment is the count comparison criterion 3 forbids. Every refusal the script gives today, in the same order, is unchanged; `C1` is the last check, after the round file.

Babysit on these cells. A comment from rows 1, 4, 5, 7, 8 and 11 reads exactly as today, so a PR that ends at round three is unchanged (criterion 4). A comment from row 2, 3, 6, 10 or 12 carries an `another round:` line, and babysit's new sentence makes it not merge-ready whatever its count: in the fix form because the next round reviews the fix, in the stop form because the PR is unfinished and waits for the human — a wait, like an `## Ask` item, not a blocker to fix on this PR. Row 9 is #90's restart sentence, unchanged.

### Contract

**The new comment line (`review-comment.sh`).** Between the summary line and the `round:` line, in `restart`'s place and never beside it, one line when at least one would-break fix is marked and no hole is:

```
another round: a would-break item was fixed here; this round reviewed 4f1c0b1d0a1e2f3a4b5c6d7e8f90a1b2c3d4e5f6
```

at rounds one to four, and at round five:

```
another round: none; the fifth round fixed a would-break item too, so this PR is unfinished and waits for the human
```

The commit is 40 hex characters, `git rev-parse HEAD` as `review-brief.sh` wrote it into `<dir>/reviewed`; a short id would need a second resolution in `review-brief.sh` and could be ambiguous, and the value is compared as a string.

**The changed line.** `round: $round of $cap`, where `cap=3; [ "$round" -le 3 ] || cap=5`. That line is written identically in both scripts and `tests/spec-review/review-brief.sh`'s `fragment()` gains `/^cap=3;/p` beside `fenced` and `ref`, so the two copies cannot drift. `review-brief.sh`'s parse becomes `/^round: [0-9]+ of [35]$/` (`:169`), so every comment written before this ticket still parses. The trap is that `of 3` is also the item total in the summary line; the anchor stays the whole line.

**The new file.** `echo "$(git rev-parse HEAD)" > "$dir/reviewed"` in `review-brief.sh` beside `<dir>/round` (`:266`), in both forms. It is written once and read once: nothing syncs it, and no other reader derives the reviewed commit. `.claude/state/review/` is unchanged, since the fact is needed after the state is cleared.

**What `review-comment.sh` adds.** One helper beside `holed()`:

```sh
# wb_fixed: the Act on items ending in a `fixed: <sha>` field whose report item is under `## Would break`.
wb_fixed() {
  local line n f
  while IFS= read -r line; do
    n="$(printf '%s' "$line" | sed -nE 's/^[0-9]+\. \[([SP][0-9]+)\].*/\1/p')"
    case "$n" in S*) f="$dir/standards-report.md" ;; *) f="$dir/spec-report.md" ;; esac
    [ "$(specs "$f" | sed -n "${n#[SP]}p" | cut -f1)" = "Would break" ] || continue
    printf '%s\n' "$line"
  done < <(items "$dir/judgment.md" "Act on" | grep -E 'fixed: [0-9a-f]{7,40}$' || true)
}
```

`specs` and the `[SP]<n>`-to-line-number map are the two lines the `hole:` path already runs (`:185-188`); nothing new parses a report. `holes` moves up beside the `hole:` checks so the `C1` refusal fires before any output, as every other refusal does. The print is then

```sh
if [ "$holes" -eq 0 ] && [ -n "$wb" ]; then
  if [ "$round" -ge 5 ]; then echo "another round: none; ..."; else echo "another round: a would-break item was fixed here; this round reviewed $(cat "$dir/reviewed")"; fi
fi
```

**What `review-brief.sh` adds.** After the restart slice and before the round is derived, the last surviving comment's `another round:` line, its last one, outside fenced text:

```sh
found="$(printf '%s\n' "$bodies" | awk -v sep="$rs" '{ t = $0; sub(/\r$/, "", t); sub(/[ \t]+$/, "", t) } t == sep { v = "" }'"$split$fenced"'
  /^another round: / { v = $0 }
  END { print v }
')"
```

then, in this order, all before `mkdir -p "$dir"`:

1. `found` non-empty and matching neither form exactly (the fix form's tail must be `[0-9a-f]{40}`) → `D5`.
2. `found` is the stop form → `D3`, whatever the round.
3. `round` = `--round N`, else `top + 1`; `cap` as above.
4. `round` ≥ 4 and not (`found` is the fix form **and** `round` equals `top + 1`) → `D1` when `top` ≤ 3, `D2` otherwise. The fix form licenses exactly the round after the comment that carries it, so `--round 5` on a round-three comment is `D2` and `--round 4` with no comments is `D1`, byte for byte what it prints today.
5. `round` ≥ 6 → `D3`. Unreachable through `gh`, reachable through `--round` and `--previous`; criterion 1 asks for it by name.
6. `round` ≥ 4 and `fixed` is not the word `paths` and `git rev-parse "$fixed^{commit}"` differs from the commit the fix form names → `D4`.
7. `round` ≥ 4 and no ticket was named or found → `V` on stderr; the run continues. Refusing would block a PR that legitimately has no spec, and the Spec axis being skipped silently is the failure worth naming.

**The fix-only paragraph.** A sixth shell variable beside `step_rule`, echoed inside `common()` one blank line after the "Read nothing beyond this brief" paragraph and before `## Commits`, only when `$round` ≥ 4, so both briefs carry it and no layout a test pins moves. `SKILL.md` step 4 carries it word for word, and `tests/spec-review/review-brief.sh` asserts it in `SKILL.md` and in both briefs, as it does for the other five rules:

```sh
fix_rule='This round reviews only the commits that fixed the last round'"'"'s would-break findings: the diff above is those commits, taken from the commit that round reviewed. The change as a whole was reviewed in the earlier rounds and their reports are on the PR. Walk only the steps these commits touch, report only what these commits get wrong, and do not raise what an earlier round settled.'
```

Without it the Spec reviewer at round four walks the whole ticket against a two-line diff and reports every criterion as missing. This is the one place the rule lives; the playbook and `SKILL.md` say it in words.

**Prose, per file, as the text to add.**

- `spec-review/SKILL.md` (patch, template and `SOURCES.md` item 6 in one commit). **Step 1** (`:25`), replacing "One PR gets at most three rounds, and a round is over when its comment is posted." with: "One PR gets three rounds, and five when a would-break fix keeps landing; a round is over when its comment is posted." And after "…the fourth-round refusal counts only what follows it.": "A round whose judgment marks a `## Would break` report item `fixed: <sha>` is followed by another round, past three and up to five: step 6 prints `another round: a would-break item was fixed here; this round reviewed <sha>`, and `review-brief.sh` reads that line from the last comment, allows the round after it, and prints `round: N of 5` from the fourth on. A round past three reviews the fixes alone: its fixed point is the commit the line names, the script refuses any other fixed point, and both briefs say so (step 4). The fix commits need not name the ticket, so pass `--ticket N`; without one the Spec axis is skipped and the script says so. When round five marks a would-break fix too, step 6 prints `another round: none; …` instead and `review-brief.sh` opens no further round on this PR: that is the block, and the human's read of the report is what lifts it." **Step 4**, after the spec rule's quote: "Then, in a round past three, the fix-only paragraph, word for word: \"<fix_rule>\"." **Step 5**, a paragraph after the design-hole paragraph: "At round three, when would-break items are still being found, look for what is causing them before you judge: one named cause is worth more than three more rounds — a term the table leaves undefined, a criterion the code reads differently than the reviewer does, a documented step that does not exist. When the cause is not obvious, do not go hunting: mark the fixes and let the rounds run to five. At five with would-break items still being found, stop. Write the human a report on this PR saying what the five rounds found and what you think is causing it, leave the PR unfinished (the round-five comment's `another round: none` line is that mark, and `review-brief.sh` opens no further round on it), carry on with the work that does not depend on this PR, and wait: five rounds of would-break findings is evidence the factory needs changing, not evidence this PR needs a sixth round. Nothing here compares one round's count with another's; the question is only whether would-break items are still being found at all." The `fixed:` bullet (`:136`) gains, after "Those fixes are not reviewed again": "unless the item is a `## Would break` one, which earns another round: step 6 says so in the comment and the Ticket playbook's Another round section runs it." **Step 6** (`:141`): after "the line `restart` on its own when any Act on item carries `hole:`," insert "the line `another round:` on its own when no hole is marked and an Act on item fixed here judges a `## Would break` report item, naming the commit this round reviewed from `<dir>/reviewed`, or at round five saying none and that the PR is unfinished,"; "the line `round: N of 3`" becomes "the line `round: N of 3`, or `round: N of 5` from the fourth round on". The refusal list (`:143`) gains, after the `hole:` clauses: "when `<dir>/reviewed` is missing and a would-break item is marked `fixed:` (the next round's fixed point cannot be named);".
- `poteto-mode/playbooks/ticket.md` (kept file). **Step 8**, after the `restart` sentence: "A `spec-review` comment carrying an `another round:` line means the review is not over: go to **Another round** below, not on to step 9." A new section `### Another round` after Design hole, no step renumbered: "**A would-break fix is never left unreviewed.** When a round's review comment carries `another round: a would-break item was fixed here; this round reviewed <sha>`, before babysit: 1. Commit the fixes, then run the review again from that commit: `.claude/skills/spec-review/scripts/review-brief.sh <sha> --ticket N`. The diff is the fixes alone and both briefs say so; `--ticket N` is needed because the fix commits need not name the ticket. 2. Judge and post as any round; the comment reads `round: 4 of 5`. 3. Repeat while each round's comment carries the line, to five. 4. A comment with no `another round:` line and `act-on items: 0` is review-ready: step 9. 5. When round five's comment reads `another round: none; …`, stop: post the report for the human on this PR saying what the five rounds found and what you think is causing it, say in the PR body that the PR is unfinished, take up the work that does not depend on it, and wait for the human. There is no sixth round, and `review-brief.sh` refuses one."
- `poteto-mode/playbooks/babysit.md` (patch, template, `SOURCES.md` item 4) and `babysit/SKILL.md` (patch, template, item 12): one new indented paragraph after `babysit.md:18` and one new bullet after `babysit/SKILL.md:41`, byte-identical in both: "A review comment carrying an `another round:` line is not a merge-ready comment whatever its count: a would-break item was fixed in that round and the next round reviews the fix, or five rounds fixed would-break items and the PR is unfinished. Either way it is a wait, like an `## Ask` item, not a blocker to fix on this PR: the fix form is the Ticket playbook's Another round section, and the round-five form waits for the human's read of the report on the PR. The PR is ready only when a later review comment without such a line reads `act-on items: 0`." In the same edit, "The review runs at most three rounds on one PR" becomes "The review runs three rounds on one PR, and five when a round's fixes include a would-break item" in both copies.
- `docs/agents/review-ladder.md` rung 1 (`:6`): "One PR gets at most three rounds, and the review stops earlier at `act-on items: 0`;" becomes "One PR gets three rounds, and five when a round fixes a would-break item: such a round's comment carries an `another round:` line naming the commit it reviewed, the next round reviews those fixes alone from that commit, and at five with would-break items still found the comment reads `another round: none`, the PR is unfinished and waits for the human's read of the report on it; the review stops earlier at `act-on items: 0`;" (criterion 6's one sentence).
- `docs/knowledge/core/DECISIONS.md` P20 (`:87`): the Decision cell becomes "Three review rounds, five when a would-break fix lands"; the Choice cell gains, before the existing amendment: "Amended 2026-09-22 (#93): a round whose judgment marks a `## Would break` report item `fixed: <sha>` is followed by another round, past three and up to five; `review-comment.sh` prints `another round: a would-break item was fixed here; this round reviewed <sha>` from `<dir>/reviewed`, `review-brief.sh` reads that line from the last comment, allows only the round after it and only from that commit, prints `round: N of 5` from the fourth on, and refuses a sixth; a round whose fixes are all fails-open, prose or standards breaches may be the last and prints nothing new. At five with a would-break fix the comment reads `another round: none; …`, no further round is opened, and the PR is unfinished until the human reads the report on it. No rule compares hard-finding counts between rounds; the judgment prose in `spec-review` step 5 has two stops, three (look for the cause) and five (stop and report)." Reason cell gains: "Manuel on #93: \"never leave a hard bug change unreviewed\"; a fails-open fix at round three \"isnt all that dangerous\"; a rule keyed on the count between rounds is \"a hard pass\", since one finding in round one and two in round two can be a perfect run. On PR #87 round three found would-break items in the happy path and their fixes shipped unreviewed; on PR #92 the round-three fixes were two refusals and a sentence. 2026-09-22." Then `python3 tools/build_knowledge.py`.
- `docs/knowledge/core/MANUAL.md:103`: "and that comment carries no `restart` line" becomes "and that comment carries no `restart` line and no `another round:` line (a would-break fix earns another round, and five of them leave the PR unfinished with a report for you on it)".
- `review-brief.sh`'s header comment: the `round: N of 3` sentence gains "…and a fourth is refused unless the last comment's `another round:` line names a would-break fix, which earns one more round, up to five, reviewing the fixes alone from the commit that line names; the cap in the printed line is 3 through round three and 5 after it." `review-comment.sh`'s header: the tail list gains the `another round:` line and `<dir>/reviewed`.
- `SOURCES.md` item 4 and item 12: "The review runs at most three rounds on one PR" becomes "The review runs three rounds on one PR, and five when a round's fixes include a would-break item", and each gains: "A comment carrying an `another round:` line is not merge-ready whatever its count: the fix form earns another round and the round-five form leaves the PR unfinished, waiting for the human, not a blocker to fix here." Item 6 gains: "A round whose judgment marks a `## Would break` report item `fixed: <sha>` earns another round past three, up to five: `review-comment.sh` prints `another round:` naming the commit the round reviewed (`<dir>/reviewed`, written by `review-brief.sh`), `review-brief.sh` allows only the round after that comment and only from that commit, prints `round: N of 5` from the fourth on, refuses a sixth, and writes a fix-only paragraph into both briefs; at five the line reads `another round: none` and no further round opens."
- `tests/spec-review/no-stale-wording.sh`: `at most three rounds` added to the blacklist, with the header's sentence extended. It catches the five places that state the cap as a flat three inside `template/` (`spec-review/SKILL.md`, both babysit copies, the ladder) and `docs/knowledge/core/` (P20); `babysit/SKILL.md:42`'s "three rounds of fix → push → recheck" is upstream's own unrelated loop and is not matched.

### Tests, one assertion per cell

`tests/spec-review/review-comment.sh`. The fixture is the existing `judged()`/`above()` block, whose `[S1]` is under `## Would break` and `[P2]` under `## Fails open`; `rearm()` gains `echo 4f1c0b1d0a1e2f3a4b5c6d7e8f90a1b2c3d4e5f6 > "$dir/reviewed"`.

- B1A: `judged "" "" "" ""` — the existing comment, unchanged, no `another round:` line.
- B2A: `judged " fixed: abc1234" "" "" ""` at round 1 — exact stdout with the fix form between the summary and `round: 1 of 3`. **This is the assertion at `:684-690` moving**; it is the cell that requires it.
- B2B: the same at round 3 — `round: 3 of 3`, the line present. **This is the assertion at `:367-381` moving** (its judgment marks `[S1] … fixed: abc1234`), the cell that requires it, and the whole point of the ticket: that PR is no longer review-ready.
- B2C: `echo 4 > "$dir/round"` — the line, then `round: 4 of 5`.
- B2D: `echo 5 > "$dir/round"` — the stop form, then `round: 5 of 5`.
- B2E: `rm "$dir/reviewed"` with the round-1 fixture — the exact `C1` refusal, exit 1, state kept.
- B2F: no `spec-brief.md`, a Standards-only judgment marking `[S1] … fixed:` — the fix form prints; the kind is known without a spec.
- B3A: `judged "" " fixed: abc1234" "" ""` where `[P1]` is the Spec report's `## Would break` item — the line prints.
- B4A: a `fixed:` mark on `[P2]` (`## Fails open`) — no line, the comment as today.
- B5A: a `fixed:` mark on `[S2]` (`## Standards breaches`) through `breach()` — no line.
- B6A: both `[S1]` and `[P1]` marked `fixed:` — exactly one line.
- B7A: `[S1] … ticket: #12` with `[P2] … fixed:` — no line.
- B8A: a would-break item under `## Noted` — no line.
- B9A: `[S1] … hole: table 2/D` with `[P1] … fixed: abc1234` — `restart`, no `another round:` line, the hole out of the count.
- B10A: `judged " hole: table 2/D fixed: abc1234"` (the existing `:719` fixture) — the fix form prints and no `restart` does; the last field is the field.
- B11A: a `## Walk` line carrying `fixed: abc1234` — no line, counts unchanged.
- B12A: `echo paths > "$dir/fixed-point"` with a would-break fix — the line prints, `fixed point paths` in the summary.

`tests/spec-review/review-brief.sh`. The fixtures derive from `previous.md` by `sed`/`awk` as the existing rows do; `owed.md` is `previous-3.md` with the fix form inserted above its `round:` line, naming the repository's own `HEAD` sha (captured into a variable, since the fixed-point check resolves it).

- A1B: `--round 4` with no `pr.json` — `D1`, byte for byte, no state. **The existing assertion at `:515-526`, unchanged.**
- A2A: `pr me me:previous.md me:previous-2.md me:previous-3.md` — `D1`, no state. **The existing assertions at `:327-339` and `:394-407`, unchanged.**
- A3A: `pr me me:previous.md me:previous-2.md me:owed.md`, fixed point the named sha — exact stdout with `round: 4 of 5`, and `Fx` in both briefs.
- A3B: the same with `--round 5` — `D2`.
- A4A: the same history, fixed point `HEAD~1` — `D4` naming both, no state.
- A5A: the same history with the fixed point equal to `HEAD` — the existing empty-diff refusal.
- A6A: `…me:owed.md me:previous-4.md` (a round-four comment with no line) — `D2`.
- A7A: `…me:owed.md me:owed-4.md` — `round: 5 of 5`, `Fx`.
- A8A: `…me:owed-4.md me:stopped-5.md` — `D3`, no state; and with `--round 2`, `D3` again.
- A9A: `…me:owed-4.md me:previous-5.md` — `D3`.
- A10A: `pr me me:owed-1.md` (the fix form on a round-one comment) — `round: 2 of 3`, no `Fx`, the fixed point unchecked.
- A11A: `pr me me:previous.md me:owed-2.md me:previous-3.md` — `D1`: only the last comment decides.
- A12A: `pr me me:owed.md me:previous-3.md` (the rebuild) — `D1`.
- A13A: `pr me me:previous-3.md me:owed.md` — as A3A.
- A14C: `--previous` on a file holding `restart` and the fix form in one comment — `X`, `round: 1 of 3`, nothing carried.
- A15A: the fix form in prose, inside a fence and with trailing text — `D1`, no owed round.
- A16A: a comment holding a quoted fix form above its own — the last one decides, as A3A.
- A17A: the fix form in a stranger's comment — `D1`.
- A18A: the fix form in a body with no `act-on items:` line — `D1` through `gh`; trusted through `--previous`, as A3A.
- A19A: `another round: yes` and `another round: a would-break item was fixed here; this round reviewed abc1234` (a short sha) — `D5` each, no state.
- A20A: the fix form naming a sha the repository does not have — `D4`.
- A21A: A3A without `--ticket` and with no ticket in the fix commits — `V` on stderr, `no spec: Standards axis only` on stdout.
- A22A: A3A with the fix commit touching `$hooks` and no grounding — the existing cross-cutting refusal.
- A23A: `--paths a.txt --commits <sha>` after an owed comment — exit 0, no `D4`.
- Anti-drift: `fragment()` holds the `cap=3;` line together with `fenced` and `ref` across both scripts; `SKILL.md` step 4 carries `fix_rule` word for word; both briefs carry it at round 4 and neither does at round 3.

`tests/spec-review/no-stale-wording.sh`: `at most three rounds` in the blacklist, and the suite still prints `ok: no stale wording` after the prose edits.

### Criteria map

- **Criterion 1** (a would-break fix earns another round to five; the kind is read from the previous comment; a sixth is refused): table B rows 2, 3, 6, 10 and 12 against rows 4, 5, 7 and 8; table A rows 3, 6, 7, 9 and 1B/A8A; contract "The new comment line", `wb_fixed`, steps 2 and 5 of the `review-brief.sh` order, `D3`.
- **Criterion 2** (a round past three reviews the fix only, from the commit the previous round reviewed, and the playbook and `spec-review` say so): table A rows 3, 4, 5, 20 and 23; contract "The new file", step 6 of the order (`D4`), "The fix-only paragraph"; `ticket.md`'s Another round section, `SKILL.md` steps 1 and 4.
- **Criterion 3** (no count comparison; step 5's two stops; babysit reads round five as a wait): the `SKILL.md` step 5 paragraph, whose last sentence forbids the comparison; the note under table B that the comment prints no would-break count; table A row 8 and table B row 2D; the babysit sentence's "a wait, like an `## Ask` item, not a blocker to fix on this PR".
- **Criterion 4** (babysit reads the same lines and is unchanged for a PR that ends at round three): table B rows 1, 4, 5, 7, 8 and 11 print byte-identical tails; the `round: N of 3` form is unchanged through round three; table A row 2 keeps `D1` byte for byte; the two assertions that move are named in the test list with the cells that require them, and both are the central behavior change, not collateral.
- **Criterion 5** (tests cover round four with a fix-only fixed point and the round-five stop): A3A, A4A, A7A, A8A, B2C, B2D.
- **Criterion 6** (P20 amended; the ladder says the same in one sentence): the P20 and `review-ladder.md` entries under "Prose, per file".

The seven questions of the design constraints are answered at: **Q1** in Terms ("would-break fix", "the reviewed commit") and the contract's first three blocks; **Q2** in Terms ("the cap in force"), the legend's `D1` to `D5` and table A rows 1 to 9, 11 and 19; **Q3** in table B row 2D, the babysit sentence, the `SKILL.md` step 5 paragraph and `ticket.md`'s Another round step 5; **Q4** in table A row 10 and table B row 2A, with the babysit sentence answering the ready question; **Q5** in Terms ("the last comment") and table A rows 12, 13 and 14 with table B row 9; **Q6** in "Prose, per file"; **Q7** in table B column E and the `C1` refusal.

### Files touched

`template/.agents/skills/spec-review/scripts/review-brief.sh`; `template/.agents/skills/spec-review/scripts/review-comment.sh`; `template/.agents/skills/spec-review/SKILL.md` with `patches/mattpocock/spec-review.SKILL.md.patch`; `template/.agents/skills/poteto-mode/playbooks/ticket.md`; `template/.agents/skills/poteto-mode/playbooks/babysit.md` with `patches/pstack/poteto-mode/playbooks/babysit.md.patch`; `template/.agents/skills/babysit/SKILL.md` with `patches/pstack/babysit/SKILL.md.patch`; `template/docs/agents/review-ladder.md`; `docs/knowledge/core/DECISIONS.md` and `docs/knowledge/core/MANUAL.md` with `python3 tools/build_knowledge.py`; `SOURCES.md` items 4, 6 and 12; `tests/spec-review/review-brief.sh`, `review-comment.sh`, `no-stale-wording.sh`. No new script, no new state file outside the review dir, no renumbered step.

---

## Rationale

Not part of the ticket section.

## Problem

The review gate stops at three rounds whatever the third round fixed. On PR #92 that was safe: the two would-break items were found in round one and reviewed twice more, and what shipped unreviewed was two refusals and a playbook sentence. On PR #87 round three still found would-break items in the happy path and their fixes, one a behavior change, shipped unreviewed. Nothing in the system can tell the two apart, because nothing records what kind of finding a round fixed.

Three constraints from Phase A shape the answer. The comment is the only record: `review-brief.sh` reconstructs everything by reading the PR's earlier comments through `gh`, and `review-comment.sh` deletes the working state as its last act, so any fact a later round needs has to be written into the comment first. Nothing today records the commit a round reviewed — `<dir>/fixed-point` holds the ref the diff came *from* — and `review-comment.sh` cannot compute it, because it runs after the fix lane committed. And babysit, the ladder, P20, `MANUAL.md` and two vendored copies all key on the two tail lines, so changing their form unconditionally would cost six prose edits, three patches and roughly thirty-six pinned assertions, for a PR that ends at round three exactly as it does today.

## Usage (the orchestrator's view)

Round three finds a would-break item. The fix lane fixes it and commits; the orchestrator marks the item, renumbers and runs step 6:

```
$ .claude/skills/spec-review/scripts/review-comment.sh .scratch/review/origin_main
...
Standards: 1 would break, 0 fail open, of 3; Spec: 0 would break, 0 fail open, of 1; judged: act on 1 (1 fixed, 0 with a ticket), ask 0, consider 0, noted 2, dismissed 0; fixed point origin/main.
another round: a would-break item was fixed here; this round reviewed 4f1c0b1d0a1e2f3a4b5c6d7e8f90a1b2c3d4e5f6
round: 3 of 3
act-on items: 0
```

`act-on items: 0`, and the PR is still not ready: babysit reads the `another round:` line and waits. The orchestrator takes the commit off that line and opens round four on the fixes alone:

```
$ .claude/skills/spec-review/scripts/review-brief.sh 4f1c0b1d0a1e2f3a4b5c6d7e8f90a1b2c3d4e5f6 --ticket 93
ticket: #93
round: 4 of 5
settled: carried 2, dropped 0 without a citation
.scratch/review/4f1c0b1d0a1e2f3a4b5c6d7e8f90a1b2c3d4e5f6/standards-brief.md
.scratch/review/4f1c0b1d0a1e2f3a4b5c6d7e8f90a1b2c3d4e5f6/spec-brief.md
```

The diff is two commits and both briefs open with the fix-only paragraph, so neither reviewer walks the whole ticket against it. If the orchestrator forgets and passes the original fixed point:

```
$ .claude/skills/spec-review/scripts/review-brief.sh origin/main --ticket 93
review-brief: round 4 reviews the would-break fixes only: its fixed point is 4f1c0b1d0a1e2f3a4b5c6d7e8f90a1b2c3d4e5f6, the commit the last round reviewed, and origin/main is not that commit. Rerun as `review-brief.sh 4f1c0b1d0a1e2f3a4b5c6d7e8f90a1b2c3d4e5f6`
```

Round four's fixes are all fails-open, so its comment carries no `another round:` line and reads `round: 4 of 5` and `act-on items: 0`; babysit calls the PR ready. Had round four fixed another would-break item, round five would run the same way. At round five with one more:

```
another round: none; the fifth round fixed a would-break item too, so this PR is unfinished and waits for the human
round: 5 of 5
act-on items: 0
```

The orchestrator posts the report for the human as its own comment on the PR, says in the PR body that the PR is unfinished, and moves to the work that does not depend on it. Any later attempt to open a round answers:

```
review-brief: five rounds is the cap on one PR and a sixth is not run; when five rounds fixed would-break items the PR is unfinished, and the report for the human on it is what unblocks it
```

A PR whose third round fixed only fails-open items, prose or standards breaches reads exactly as it does today, down to the byte: no new line, `round: 3 of 3`, `act-on items: 0`, ready.

## Shape

**One line in the comment carries both facts, and each reader takes what it needs.** The line says a would-break item was fixed and names the commit the round reviewed. `review-brief.sh` uses the presence to allow a fourth or fifth round and the commit as the required fixed point; babysit uses the presence alone; a human reads the sentence. That is the deep interface: one string, one grammar, three readers, and no reader re-derives the other's fact. The alternative — one line for the kind and another for the commit — would expose the internals of the decision to every reader and let the two lines disagree.

**The kind is computed once, where the reports are.** `review-comment.sh` is the only script that holds the two reports, and `specs()` already maps a `[S<n>]`/`[P<n>]` reference to the heading its report item sits under; the `hole:` path runs exactly those two lines today. So `wb_fixed` is a loop over the `fixed:`-marked Act on items through machinery that exists, and `review-brief.sh` never parses a report. Single source of truth per invariant, per the runner prompt: the kind is decided once and written down, not re-derived from the comment's pasted reports next round.

**The reviewed commit is recorded once, at the only moment it is knowable.** `review-brief.sh` writes `<dir>/reviewed` beside `<dir>/round`; `review-comment.sh` reads it and prints it. Nothing syncs, nothing else derives it. Its absence refuses rather than prints, because printing without it leaves a hard fix unreviewed, which is the bug this ticket exists to remove; the refusal only fires when a would-break fix is marked, so every dir written before this change and every existing fixture keeps working on every other path.

**Conditional, so the old path is byte-identical.** The new line prints only on the condition that changes the outcome; the denominator of the `round:` line is the cap in force, which is 3 until a fourth round is owed. Rounds one to three print what they print today, `D1` is unchanged, and the thirty-odd assertions pinning `round: N of 3` stay green. Two assertions move, both marking a would-break item `fixed:`, and both are the ticket's own behavior change rather than collateral: a PR whose round three fixed a would-break item is no longer finished.

**The block is a refusal, not a label.** Criterion 3's "mark the PR blocked as unfinished" is carried by the stop form and by `review-brief.sh` refusing to open any further round while the last comment holds it. No new label, no draft toggle, no forge call. And it is self-clearing in exactly the right way: a `restart` comment cuts the history, so the architect route back through a redesign lifts the block without anyone remembering to.

**Restart outranks.** The `another round:` line is suppressed when a hole is marked, so no comment says both. It would have been inert anyway — the restart slice drops the comment that carries it — but a comment that told a human two contradictory things would be a worse artifact than one line of code is worth.

**What the design deliberately does not do.** It never compares counts: the predicate is "did this round fix a would-break item", evaluated inside one round, and the comment prints no would-break count for a later round to compare against. It adds nothing to `.claude/state/review/`, since the fact is needed after the state is cleared. It does not teach `review-brief.sh` what a report heading is. It does not change the summary line, the count arithmetic, or the position of `act-on items:`.

## Tradeoffs accepted

- We accept three refusal messages where two would do (`D1` kept byte-identical for the common case, `D2` for the general one) in exchange for criterion 4's letter: the two existing fourth-round assertions and the message an orchestrator has seen for weeks stay exactly as they are.
- We accept a 40-character sha in a line a human reads, in exchange for a string comparison with no second `git rev-parse` and no ambiguity; a short id would have to be resolved, and resolving it would need its own refusal when the branch was rebased.
- We accept that `review-brief.sh` refuses a wrong fixed point at round four rather than leaving it to the playbook. Passing the original fixed point produces a full-diff review that looks right and costs a full round, which is a silent wrong result; the script has the commit in hand and the check is two lines.
- We accept a warning, not a refusal, when a round past three names no ticket. A PR that genuinely has no spec can still owe a fourth round, and the script cannot tell that case from a forgotten `--ticket N`; the loud line plus the playbook's command is the honest middle.
- We accept that a would-break item fixed in round one or two prints the line even though rounds two and three review from the original fixed point. The line means "another round is owed" and the commit is used only past three; without it, a round-one comment reading `act-on items: 0` with a hard fix in it would be merge-ready, which is the same bug one round earlier.
- We accept the fix-only paragraph as a sixth pinned brief string. Without it the Spec reviewer at round four walks the whole ticket against a two-commit diff and reports every criterion as missing, which would burn the extra round the ticket bought.

## Alternatives considered

**Record the reviewed commit and the kind in a file under `.claude/state/`, not in the comment.** Rejected: the whole loop is designed so the PR's comments are the only durable record, and `review-comment.sh` deletes the live state as its last act. A state file would assume the next round runs from the same working tree, which the design deliberately does not assume, and it would give two sources for one invariant.

**Rename the cap to five everywhere: `round: N of 5` from round one, `review-brief.sh` refusing only the sixth.** The simplest shape, and it loses. It changes every round-three comment, so criterion 4 fails on its face; roughly thirty-six pinned assertions move; six prose places, three patches and two SOURCES entries restate a cap that is now wrong for the common PR; and babysit's `round: 3 of 3` sentence would have to be rewritten for a fact that did not change. It also tells a lie: most PRs still get three rounds, and printing `1 of 5` invites a fourth round nobody owes. The conditional cap hides that policy behind one derived variable instead of exposing it to every reader.

**Let the orchestrator remember the commit and the kind, with prose only and no machine line.** Rejected by the ticket ("`review-brief.sh` reads the kind of the fixed items from the previous round's comment") and by the system: `spec-review` runs in a fresh context, so there is no memory to read; the round gate exists precisely because the orchestrator's memory is not the record.

**Reuse the existing `fixed: <sha>` marks: let `review-brief.sh` read the pasted reports out of the previous comment and work out which fixed item was under `## Would break`.** It costs no new comment line, and it is the wrong shape. It puts report parsing — headings, the `Walk` exclusion, the `[S<n>]` index — into a second script, duplicating `specs()` and its subtleties; a comment's reports are pasted text that a later edit can break; and it would still leave the reviewed commit unrecorded, which is the harder half. Information leakage by the book: the report's internal structure would become a thing two modules depend on.

**A separate line per fact (`reviewed: <sha>` always, `would-break fixed: yes` when it applies).** Rejected: `reviewed:` on every comment breaks criterion 4 immediately, and two lines can disagree. One line that exists only when it decides something is both smaller and harder to misread.

## Open questions and risks

- Should a would-break item marked `ticket: #N` at round three — filed elsewhere because it is outside this PR's scope — earn another round too? The design says no (the fix is not on this PR, so there is nothing here to review), but Manuel's "never leave a hard bug change unreviewed" could be read either way.
- At round five the orchestrator posts the report as its own comment on the PR. Should it also go somewhere durable, `docs/agents/ledger.md` or a ticket, given that five rounds of would-break findings is meant to be evidence the factory needs changing?
- Is the fix-only round the right thing to review, or should round four review the whole diff again from the original fixed point at the cost of a full round? The ticket accepts the agent's fix-only proposal; the risk is a fix whose damage shows only against code the fix diff does not contain, which a fix-only round cannot see.
- Round five's stop leaves the PR open and unfinished with `act-on items: 0` on it. Is an open PR nobody may merge the right resting state, or should the orchestrator convert it to a draft so the forge shows it too?

## Next implementation step

Write `tests/spec-review/review-comment.sh`'s B2A assertion and `rearm()`'s `<dir>/reviewed` line, then `wb_fixed` and the two-form print in `review-comment.sh`, since every other part of the design reads the line that block produces.
