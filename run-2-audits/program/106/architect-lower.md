## Testing decisions

Posted by the agent 2026-09-23

The two tables below are the spec for the fix-only round three and for the three new comment lines; the contract under them is what the scripts implement. Table A is `review-brief.sh` over the PR's comment history, table B is `review-comment.sh` over one round's reports and judgment. A review finding that changes a cell, adds a row or a column, or changes the meaning of a term the cells use (a changed line, an item's quoted hunk, the deciding comment, a fix-only round, sticky) is a design hole under this ticket's own rule: it returns to architect and this section is amended with a dated line. A finding that leaves the tables standing while the code fails a cell is an implementation bug fixed on the PR. A refusal added under an existing could-not-run clause is not a hole. Every cell of #90's and #93's tables A and B keeps its outcome; the assertions this design moves are named under Tests, each with the cell that moves it, and #93's cells 13B, 5C and 5D gain the direct assertions criterion 6 asks for.

Where this design lands, in one paragraph. Rounds one and two are untouched: `review-brief.sh` prints today's lines and writes today's briefs for them. Rounds four and five are untouched: #93's `would-break fixed after <sha>` line still licenses them and still names their fixed point. The one round this ticket changes is **round three**, which becomes fix-only when round two's comment says so. Stickiness is then a consequence, not a second rule: a fix-only round's whole diff is the fix, so nothing it reports can be outside the fix, and rounds four and five are fix-only already.

### Terms

Every term of #90 and #93 stands: a "comment", a "restart comment", the "history", the "deciding comment" (the last comment of the history), `top`, a "would-break item", a "Would-break fix", the "reviewed commit", the "WB line", the "cap".

A "hard item" is a report item under `## Would break` or `## Fails open` in the Standards or the Spec report, whatever the judgment did with it. The judgment is not consulted: criterion 2 says what the round *reported*, so an item the judgment Dismissed or Noted still counts. An item under `## Standards breaches`, `## Fix alongside` or `## Not asked for`, and every `## Walk` line, is not a hard item.

The "changed lines of the fix commits" are the lines `git diff --unified=0 <prev>...HEAD` adds or removes, each stripped of its `+`/`-` marker, trimmed of leading and trailing whitespace, kept only when at least four characters are left, and each distinct line once. `<prev>` is the reviewed commit of the previous round, from the deciding comment's `reviewed:` line. This is how criterion 2's "the fix commits' changed ranges" is recorded: as the set of lines those ranges hold, so a report's quoted hunk can be tested against them without re-locating the hunk in the diff, which no round-one or round-two brief could ask a reviewer to make locatable. A line under four characters (`}`, `fi`, `done`) is in every diff and identifies nothing, so it is dropped on both sides. A **removed** line is a changed line: criterion 2 says "the lines of the fix commits", and a finding that quotes a line the fix deleted is a finding about the fix. The file is `<dir>/fix-lines`, written by `review-brief.sh` on every run that writes state, empty when there is no usable `<prev>` (no previous comment, a comment from before this ticket, a `reviewed:` line that is not 40 lowercase hex, a commit that does not resolve) and in the sweep form.

An "item's quoted lines" are the lines inside the fenced blocks between that item's opening line and the next item or heading, each stripped of one leading `+`, `-` or space, trimmed and kept at four characters or more, by the same rule. A hard item is **inside the fix** when one of its quoted lines is a changed line of the fix commits; it is **outside** otherwise, which includes an item that quotes nothing, an item whose quoted block is a spec line rather than a hunk (a Spec item normally quotes the criterion it rests on), and every item of round one, whose fix-line set is empty. Outside is the conservative direction: it costs a whole-diff round, never a skipped one. Nothing a human writes decides this: the orchestrator's judgment gains no field, and the reports' shape is unchanged, so the round-one and round-two briefs stay byte for byte what they are today.

A "fix-only round" is a round whose diff is the previous round's fix commits and nothing else. Rounds four and five are fix-only by #93 (the WB line). Round three is fix-only when the deciding comment carries the line `fix-only next`. `review-brief.sh` records the fact for the round it is briefing in `<dir>/fix-only`, which holds the commit the diff starts from; the file's presence is what `review-comment.sh` reads. Rounds one and two never have it (criterion 1).

The "verdict" is the line `fix-only next`, printed by `review-comment.sh` when this round is itself fix-only (`<dir>/fix-only` exists), or when the round is two or more and every hard item is inside the fix (vacuously, when the reports carry no hard item). It is never printed at round one: round one reviewed no fix, so nothing it found can be inside one, and criterion 1 says round two reviews the whole diff. It is never printed beside `restart`: a hole cuts the history and the redesign's round one is a whole-diff round.

The "reviewed line" is `reviewed: <sha>`, `<sha>` 40 lowercase hex, printed by `review-comment.sh` on every comment whose `<dir>/reviewed` holds a full commit id, the last such line in a comment being its own, as for `round:`. It is how the reviewed commit of a round reaches the next brief, which the WB line did for rounds four and five alone; the review ladder already claims the comment names the commit it reviewed. It is the next round's `<prev>`, and, when the next round is fix-only, its required fixed point. A comment without it (written before this ticket, or a run whose `<dir>/reviewed` was lost) makes the next round a whole-diff round with an empty `fix-lines`.

The "owed line" is `another round is owed`, printed at round one or two when any Act on item of the judgment ends in `fixed: <sha>`. Criterion 4: those fixes were made before the review was over, so the comment is not review-ready whatever its count, and babysit reads the line.

A history is written oldest first. `(1 r)` is a round-one comment carrying `reviewed: r`; `(2 r)` a round-two comment carrying `reviewed: r` and no verdict; `(2F r)` one carrying `reviewed: r` and `fix-only next`; `(1X r)` a round-one comment carrying the owed line; `(2O)` a comment from before this ticket, with no `reviewed:` line; `(3)`, `(3W s)`, `(4W t)` as #93 writes them. `o` is the original fixed point (`origin/main`), `x` any other ref.

### Scenario table

**Legend, table A.** Cell = prints / exit / what the caller does. `R(n)` = the line `round: n of 3` for n of 1 to 3, `of 5` for 4 and 5. `S` = #90's `settled:` line and section. `X` = #90's `restart:` line. `FIX` = both briefs carry `## The fix under review` before `## Diff`; "no FIX" = absent. `paths` = the brief paths last. `L(r)` = `<dir>/fix-lines` holds the changed lines of `git diff --unified=0 r...HEAD`; `L0` = it is written empty. `M(r)` = `<dir>/fix-only` holds `r`; "no M" = absent. Exit 1 is one line on stderr before any output or state. `F4`, `F5`, `F6`, `FM`, `FR(n,s)`, `FT(n)` are #93's refusals, byte for byte. Two change or are new:

- `FP(n,s,x,src)` = #93's `FP` with its source clause parameterised: `review-brief: round <n> reviews only the fix from <s>, the commit round <n-1> reviewed (<src>); <x> is not that commit`. `src` is "the `would-break fixed after` line of the last review comment" at rounds four and five, so every #93 cell keeps its exact string, and "the `reviewed:` line of the last review comment" at round three.
- `FV` = `review-brief: the last review comment carries `fix-only next` but no `reviewed: <sha>` line naming the commit it reviewed; post the comment the script printed`

Refusal order is unchanged, with the round-three gate in the place the round-past-three gate holds: `FM`, `F6`, then for a round past three `F5`/`F4` and for round three `FV`, then `FR`, `FP`, `FT` for whichever gate fired, all before the empty-diff and blast-radius refusals and before `mkdir -p "$dir"`.

**Table A: `review-brief.sh <fixed-point>` over the comment history**

| Situation | A. default (`gh`) | B. `--round N` | C. `--previous FILE` |
|---|---|---|---|
| 1. No comment (no PR, no comments, only strangers') | `R(1)`, no S, no FIX, no M, `L0`, `paths` / 0 / round one, byte for byte as today | `--round 3`: `R(3)`, no FIX, `L0` / 0; `--round 4`, `5`, `6`: #93 row 1B unchanged | an empty file: as A |
| 2. `(1 r)`, fixed point `o` | `R(2)`, `S`, no FIX, no M, `L(r)`, `paths` / 0 / round two reviews the whole diff from `o`, byte for byte as today (criterion 1); the fix lines are recorded for round two's verdict | `--round 2`: as A | as A |
| 3. `(1X r)` (round one marked a fix, so its comment carries the owed line), fixed point `o` | as row 2: the owed line is babysit's, and changes no brief | as A | as A |
| 4. `(1 r1)`, `(2 r2)`: round two reported a hard item in unchanged code, so no verdict line | `R(3)`, `S`, no FIX, no M, `L(r2)`, `paths` / 0 / round three reviews the whole diff from `o`, as today | `--round 3`: as A | as A |
| 5. `(1 r1)`, `(2F r2)`, fixed point `r2` | `R(3)`, `S` over both, `FIX` with round two's Act on items, `M(r2)`, `L(r2)`, `paths` / 0 / round three reviews `r2..HEAD`, the fix and nothing else; `--ticket N` passed (row 8) | `--round 3`: as A; `--round 2`: `R(2)`, no FIX (the gate is off below three, and the fixed point is not checked) | a file holding `(2F r2)` alone: `R(3)`, `S` over it, `FIX`, `M(r2)` / 0 |
| 6. `(1 r1)`, `(2F r2)`, fixed point `x` != `r2` (`o`, `HEAD~1`, one of the fix commits) | `FP(3,r2,x,reviewed)` / 1 / rerun with `r2` | `--round 3`: same | as A |
| 7. `(1 r1)`, `(2F r2)`, `r2` does not resolve in this clone | `FR(3,r2)` / 1 / fetch the PR's branch, rerun | same | as A |
| 8. `(2F r2)`, fixed point `r2`, no `--ticket`, the fix commits name no `#N`, and `(2F)` had a spec | `FT(3)` / 1 / rerun with `--ticket N` | same | as A |
| 9. As row 8 but `(2F)` carries `no spec: Standards axis only` under `## Spec` | `R(3)`, `S`, `FIX`, `M(r2)`, the Standards path, `no spec: Standards axis only` / 0 / Standards axis only | same | as A |
| 10. `(2F)` carrying `fix-only next` with no `reviewed:` line, or one that is not 40 lowercase hex | `FV` / 1 / post the comment the script printed; a hand-written verdict has no commit to review | same | as A: the file is trusted, the pair still has to fit |
| 11. `(2O)`, or `(2 r2)` whose `reviewed:` line is malformed, with no verdict line | as row 4, `L0` / 0 / an old or damaged comment falls back to the whole diff | same | as A |
| 12. A round-one comment carrying `fix-only next` (hand-written; `review-comment.sh` never writes it at round one) | as row 2: below round three the verdict line is not read (criterion 1) | `--round 2`: as A | as A |
| 13. `fix-only next` or `reviewed:` in a stranger's comment, in a comment before the deciding one, inside a fenced hunk, or as prose inside a line | not the deciding comment's line: rows 4 and 11 for the rest / no code | same | as A |
| 14. `(2F r2)` posted from the web UI (CRLF) | as row 5: `split` strips the CR | same | a CRLF file: as row 5 |
| 15. Round two rebuilt: `(1)`, `(2F r2)`, `(2 r2)`, or the two the other way round | the last decides: `(2 r2)` last is row 4, `(2F r2)` last is row 5 | same | as A |
| 16. `(1)`, `(2F r2)`, `(3 restart)`, or a `--previous` comment carrying both `restart` and `fix-only next` | `X`, `R(1)`, no S, no FIX, no M, `L0` / 0 / restart wins: the redesign's round one reviews the whole diff from `o` | `X`, `R(N)`, no FIX / 0 (13B of #93, now asserted directly) | as A |
| 17. `(1)`, `(2F r2)`, `(3)`: round three ran fix-only and its comment carries no WB line | `F4` / 1 / unchanged: the cap is three, fix what remains and mark it `fixed: <sha>` | `--round 4`: `F4`; `--round 5`: `F5` | as A |
| 18. `(1)`, `(2F r2)`, `(3W s)`, fixed point `s` | `R(4)`, `S`, `FIX`, `M(s)`, `L(s)` / 0 / #93 row 3, unchanged; sticky holds, round four is fix-only whatever round three's verdict said | `--round 4`: as A | as A |
| 19. `(3W s)` carrying `fix-only next` as well (a fix-only round three) | as row 18: past three the WB line decides the round and its fixed point | same | as A |
| 20. `(3W s)`, `(4W t)`, fixed point `t` | `R(5)`, `S`, `FIX`, `M(t)` / 0 / #93 row 9, unchanged | `--round 5`: as A | as A |
| 21. `(2F r2)`, fixed point `r2`, and `git diff r2...HEAD` empty (the fix lane committed nothing) | the existing refusal `review-brief: the diff is empty; nothing to review since <r2>` / 1 / as today, no code | same | as A |
| 22. The sweep form (`--paths P... --commits SHA...`) on a branch whose history ends in `(2F r2)` | `FP(3,r2,paths,reviewed)` / 1 / the sweep has no fix-only round: the fix lands on its own PR and is reviewed there from round one; no code | same | as A |
| 23. Any run that writes state, both forms | `<dir>/fix-lines` beside `<dir>/round` and `<dir>/reviewed`; `<dir>/fix-only` only for a fix-only round; a refusal writes none of them | same | same |

Rerunning any row in the same round prints the same lines: the round, the settled set, both gates and the fix section are functions of the fetched comments and the fixed point alone, and `.scratch/review/<id>` is rebuilt from scratch each run.

**Legend, table B.** `T` = the comment's tail as #93 leaves it: the summary line, `restart` when any Act on item carries `hole:`, else the WB line when any Act on item is a Would-break fix, `round: N of <cap>`, `act-on items: count` last. `+R` = the line `reviewed: <sha>` from `<dir>/reviewed`. `+F` = the line `fix-only next`. `+O` = the line `another round is owed`. The order of the tail is fixed: summary, `restart` or the WB line, `+O`, `+R`, `+F`, `round:`, `act-on items:`. No refusal is added by this ticket; #93's `RM` is unchanged and still fires only when the WB line is needed.

**Table B: `review-comment.sh [<dir>]` over one round's reports and judgment**

| The reports' hard items | A. `<dir>/round` absent or `1` | B. `2` | C. `3`+, `<dir>/fix-only` absent | D. `<dir>/fix-only` present (3, 4 or 5) | E. `<dir>/reviewed` absent or not 40 lowercase hex | F. `<dir>/fix-lines` absent or empty |
|---|---|---|---|---|---|---|
| 1. None (no item under `## Would break` or `## Fails open` in either report) | `T`, `+R` / 0 / round two is a whole-diff round | `T`, `+R`, `+F` / 0 / nothing was found outside the fix, so round three is fix-only | as B | `T`, `+R`, `+F` / 0 | `T` only, neither `+R` nor `+F` / 0 / the next round falls back to the whole diff | as this row's column: nothing to place |
| 2. Every hard item quotes a changed line of the fix commits | `T`, `+R` / 0 / round one licenses nothing | `T`, `+R`, `+F` / 0 / criterion 2's case: the hard findings were all on the fix | as B | `T`, `+R`, `+F` / 0 / by the marker, without placing the items | `T` only / 0 | `T`, `+R` / 0 / no fix lines, so no item is inside |
| 3. One hard item quotes no changed line (a finding in unchanged code) | `T`, `+R` | `T`, `+R` / 0 / round three reviews the whole diff again | as B | `T`, `+R`, `+F` / 0 / the marker outranks placement: this round's whole diff is the fix | `T` only | `T`, `+R` |
| 4. A hard item with no fenced block, or whose quoted lines are all under four characters | as row 3 | as row 3 / 0 / unplaceable is outside | as row 3 | as row 3D | `T` only | as row 3 |
| 5. The unplaced item is under `## Fails open`, or is in the Spec report, or the judgment Dismissed or Noted it | as row 3: either axis, either heading, whatever the judgment did | as row 3 | as row 3 | as row 3D | `T` only | as row 3 |
| 6. Only `## Standards breaches`, `## Fix alongside`, `## Not asked for` items and `## Walk` lines fall outside the fix | as row 1: they are not hard items and the verdict ignores them | as row 1 | as row 1 | as row 1 | `T` only | as row 1F |
| 7. Any Act on item ends in `fixed: <sha>` | `T`, `+O`, `+R`, and `+F` by rows 1 to 4 / 0 / criterion 4: the fix went in before the review was over, another round is owed | as A | `T`, no `+O` / 0 / from round three the last-round path marks fixes; the line is a round-one and round-two rule | as C | `+O` prints, `+R` does not | as its row |
| 8. A Would-break fix, so the WB line prints | `T` with the WB line, then `+O`, `+R` / 0 / both lines: the WB line licenses rounds four and five, the owed line says this one is not ready | as A | `T` with the WB line, no `+O` | as C | #93's `RM` / 1 / unchanged | as its row |
| 9. A hole marked (`restart` prints) | `T` with `restart`, `+O` by row 7, `+R`, never `+F` / 0 / the redesign's round one is a whole-diff round | as A | as A | `restart`, `+R`, no `+F` / 0 / the marker does not survive a restart | `restart`, no `+R` | as its row |
| 10. The sweep form (`fixed point paths`) | `T`, `+R` / 0 / `fix-lines` is empty, so only row 1 prints `+F`; table A row 22 refuses the fix-only round anyway | as A | as A | as A | `T` only | as A |
| 11. A rerun with the dir after the state is gone | the same output as the first run, the three new lines included / 0 | as A | as A | as A | as A | as A |

Notes on the whole table. Each new line prints at most once. `<dir>/round` is trusted as today. The summary line is unchanged: the comment never counts hard findings inside or outside the fix, because a count in the comment is the count comparison #93's criterion 3 forbids. `+R` and the WB line can carry the same sha at rounds three and four; they answer different questions, so both stay: the WB line says a round is owed and licenses rounds four and five, `+R` says which commit this round read.

Babysit on these cells: a comment from rows 1 to 6 reads as today, `+R` and `+F` being instructions for the next brief and not merge-ready signals. A comment carrying `+O` is never review-ready whatever its count, exactly as one carrying the WB line. Row 9 is #90's restart sentence, unchanged.

### Contract

**The three calls.** `scripts/review-brief.sh <fixed-point> [--ticket N] ...` (rounds one and two, and a whole-diff round three: the fixed point the user pinned, as today); `scripts/review-brief.sh <sha> --ticket N` (a fix-only round: `<sha>` the deciding comment's `reviewed:` line at round three, its WB line at rounds four and five); `scripts/review-comment.sh [<dir>]` unchanged in its arguments. Exit codes as today: 0 the briefs written, 1 refused before any state with the message on stderr.

**The reviewed line (`review-comment.sh`).** After the summary line and the `restart`/WB line, and after the owed line: `<dir>/reviewed`'s first line, when it matches `^[0-9a-f]{40}$`, prints as `reviewed: <sha>`. No refusal: a missing or malformed file drops the line, and the next round is a whole-diff round with no fix lines, which is the safe direction. #93's `RM` is untouched and still fires first when a Would-break fix needs the value.

**The owed line (`review-comment.sh`).** `[ "$round" -le 2 ] && [ "$fixed_here" -gt 0 ]` prints `another round is owed`, `fixed_here` being the count the summary line already computes. Placed before the reviewed line.

**The verdict (`review-comment.sh`).** After the reviewed line, and only when it printed and `holes` is zero:

```sh
if [ -f "$dir/fix-only" ]; then verdict=yes
elif [ "$round" -ge 2 ]; then verdict=yes
  while IFS= read -r q; do
    grep -Fxq "$q" "$dir/fix-lines" 2>/dev/null || { verdict=""; break; }
  done < <(placed "$dir/standards-report.md"; placed "$dir/spec-report.md")
fi
```

`placed <file>` prints one line per hard item: the first of that item's quoted lines, or, for an item with no usable quoted line, the item's own opening line, which carries `**` and can never be a changed line, so an unplaceable item fails the test. It mirrors the fence rule the file already carries, capturing the fenced lines instead of skipping them, and trims each with the fragment both scripts hold word for word:

```awk
gsub(/^[ \t]+|[ \t]+$/, "", s); if (length(s) >= 4
```

`verdict` prints `fix-only next`.

**The fix lines (`review-brief.sh`).** After `git rev-parse HEAD > "$dir/reviewed"`:

```sh
if [ -n "$prev" ] && git rev-parse --verify -q "$prev^{commit}" >/dev/null; then
  git diff --unified=0 "$prev...HEAD" | awk '
    /^(\+\+\+|---|@@)/ { next }
    /^[-+]/ { s = substr($0, 2); gsub(/^[ \t]+|[ \t]+$/, "", s); if (length(s) >= 4 && !seen[s]++) print s }
  ' > "$dir/fix-lines"
else
  : > "$dir/fix-lines"
fi
```

`prev` is empty in the sweep form. For a fix-only round `prev` is the fixed point, so the file holds the briefed diff's own lines; `review-comment.sh` never needs it there, because `<dir>/fix-only` decides first.

**The deciding comment (`review-brief.sh`).** Beside #93's `wb_line`, `had_spec` and the fixed items, from the same `deciding` text with the same `fenced` rule: `prev` = the text after `reviewed: ` of the last line starting with those words, kept only when it matches `^[0-9a-f]{40}$`, else empty; `fix_only_line` = yes when a line is exactly `fix-only next`.

**The gates (`review-brief.sh`).** #93's `FM` and `F6` first, unchanged. Then the round-past-three block, unchanged, except that `FR`, `FP` and `FT` move into one helper both gates call, `fix_only_gate <expected> <source clause>`, so rounds four and five print the same strings they print today. Then, new, for round three:

```sh
elif [ "$round" -eq 3 ] && [ -n "$fix_only_line" ]; then
  [ -n "$prev" ] || { echo "review-brief: the last review comment carries \`fix-only next\` but no \`reviewed: <sha>\` line naming the commit it reviewed; post the comment the script printed" >&2; exit 1; }   # FV
  fix_only_gate "$prev" "the \`reviewed:\` line of the last review comment"
fi
```

`fix_only_gate` sets `fix_only=<expected>` when it passes; the round-past-three branch sets it to `$wb`. Below round three neither branch runs, so `fix_only_line` is read and ignored (table A row 12).

**The fix marker and the fix section (`review-brief.sh`).** `[ -z "$fix_only" ] || echo "$fix_only" > "$dir/fix-only"`, beside `<dir>/round`. In `common()` the section's gate becomes `[ -n "$fix_only" ]` in place of `[ "$round" -ge 4 ]`; rounds four and five are unchanged by it. `$fix_rule` is unchanged, word for word, and still pinned to `SKILL.md` step 4.

**The section's items (`review-brief.sh`).** `fixed_items` becomes the deciding comment's `## Judgment` Act on lines that end in neither `ticket: #<N>` nor a `hole:` field, whether or not they end in `fixed: <sha>`:

```awk
j && h == "Act on" && /^[0-9]+\. / && !/ticket: #[0-9]+$/ && !/hole: .*$/
```

Why the rule widens: at rounds one and two the fix lane fixes the Act on items **after** the comment is posted, so a round-two comment's Act on items carry no `fixed:` field and #93's filter would leave round three's section empty. The items the section must carry are the ones the fix lane was handed: every Act on item that was neither filed as a ticket nor marked a hole. At rounds three and four the last-round path marks every Act on item, so the set is the one #93 carried and no cell of #93's tables moves.

**The comment's tail, in order.** The summary line; `restart`, else the WB line; `another round is owed`; `reviewed: <sha>`; `fix-only next`; `round: N of <cap>`; `act-on items: K` last. A PR that ends at round two with no fixes marked prints today's lines plus `reviewed: <sha>`.

**Prose, per file.** `spec-review/SKILL.md` (through `patches/mattpocock/spec-review.SKILL.md.patch`, with `SOURCES.md` item 6 in the same commit): step 1 says which rounds are fix-only and why (round three when the deciding comment carries `fix-only next`, four and five by the WB line, one and two never), names `<dir>/fix-lines` and `<dir>/fix-only`, and lists `FV` and the round-three `FP` among the refusals; step 4's fix bullet reads "from a fix-only round on" in place of "from round four on"; step 5 says the fix lane's round-one and round-two fixes land after the comment, so marking one `fixed:` there owes another round; step 6 gains the three new lines and says none of them adds a refusal. `poteto-mode/playbooks/babysit.md` and `babysit/SKILL.md` (both patched, both copies byte-identical, pinned by the brief test) gain, after the WB sentences: "A comment carrying the line `another round is owed` is not review-ready either, whatever its count: a round one or round two whose judgment marked an Act on item `fixed: <sha>` fixed it before the review was over, and the orchestrator runs the next round. The lines `reviewed: <sha>` and `fix-only next` are the next brief's, not merge-ready signals: babysit reads neither." `docs/agents/review-ladder.md` rung 1 gains the same two facts in one sentence. `poteto-mode/playbooks/ticket.md`, the `### Would-break fix` section, gains one sentence saying round three's fixed point comes from the deciding comment's `reviewed:` line when it carries `fix-only next`. `docs/knowledge/core/DECISIONS.md` P20 is the owner's: a dated amendment and a title that no longer reads "Three review rounds at most" (criterion 6). `MANUAL.md`'s merge checklist gains the owed line beside the `restart` and WB clauses, then `python3 tools/build_knowledge.py`.

### Tests, one assertion per cell

`tests/spec-review/review-comment.sh`. **Moved:** every `accept` expectation gains the line `reviewed: 0123456789abcdef0123456789abcdef01234567` after the summary line and after any `restart` or WB line (table B row 1A; `rearm()` already writes `<dir>/reviewed`). **New fixtures:** `rearm()` also writes `<dir>/fix-lines` holding one line, `the hook exits 0 on a miss`, and the Standards report's Would-break item gains a fenced block quoting it, so the fixture places inside by default; `unplaced()` rewrites that block to quote a line no fix touched. **New assertions, in table order:** 1A, 1B, 1C, 1D (reports with no hard item at rounds 1, 2, 3 and with the marker: `+F` from round two on, never at one); 1E (`rm "$dir/reviewed"`: neither line, the state kept, exit 0, which is distinct from #93's `RM`); 1F (`: > "$dir/fix-lines"`: `+F` still prints, nothing to place); 2A to 2F (the placed fixture at each column, including `rm "$dir/fix-lines"`); 3A to 3F (`unplaced` at each column, 3D asserting `+F` prints from the marker alone after `rm "$dir/fix-lines"`); 4B (a Would-break item with no fenced block; and one quoting only `}` and `fi`: no `+F`); 5B four times (the unplaced item under `## Fails open`, in the Spec report, Dismissed, Noted: no `+F` each); 6B (only a `## Standards breaches` item and a `## Walk` line quoting unrelated text: `+F` prints); 7A, 7B (`judged " fixed: abc1234" "" "" ""` at rounds 1 and 2: `+O` prints), 7C (round 3: no `+O`), 7E (`rm "$dir/reviewed"` at round 1 with a Fails-open fix: `+O` prints, `+R` does not); 8A (the WB line and `+O` both print, in that order); 9A, 9D (a hole: `restart`, `+R`, never `+F`, with and without the marker); 10 (the sweep fixture: `+R`, no `+F` with an unplaced item); 11 (the rerun-from-dir case after 2B prints the same output). **#93's cells gaining direct assertions here:** 5C and 5D (`judged " hole: table 2/D" " fixed: abc1234" "" ""` with `<dir>/round` = 4 and 5: `restart`, no WB line, `round: 4 of 5` and `round: 5 of 5`, `act-on items: 0`).

`tests/spec-review/review-brief.sh`, a new block after #93's and before #91's, so the fixture repo's `HEAD~1` stays what the later blocks expect. Setup: `r1="$(git rev-parse HEAD)"`, a fix commit `echo four > a.txt; git commit -qam "fix the walk, #7"`, `r2="$(git rev-parse HEAD)"`, then a second fix commit, so `r2..HEAD` is one commit; fixtures `previous-1r.md` (`previous.md` plus `reviewed: $r1`), `previous-1x.md` (plus `another round is owed`), `previous-2r.md`, `previous-2f.md` (`previous-2.md` plus `reviewed: $r2` and `fix-only next`), `previous-2f-nosha.md`, `previous-2f-nospec.md`, `previous-2o.md` (no `reviewed:` line at all). Assertions, one per cell, in the table's order: 1A (`fix-lines` written and empty, no `fix-only`); 1B (`--round 3` with no comment: `round: 3 of 3`, no fix section); 2A (`printed` byte for byte today's round-two output, `lacks` the fix section, and `<dir>/fix-lines` holds the fix commit's added line and not a line only the original commits touched); 3A (`previous-1x.md`: the same output as 2A); 4A (`previous-2r.md`: `round: 3 of 3`, no fix section, no `fix-only`, `fix-lines` from `r2`); 5A (`previous-2f.md`, `review-brief.sh "$r2" --ticket 7`: `printed` "ticket: #7 / round: 3 of 3 / settled: ... / .scratch/review/$r2/standards-brief.md / .scratch/review/$r2/spec-brief.md", `<dir>/fix-only` = `$r2`, both briefs `fixed_section` with `$fix_rule` and round two's unmarked Act on item, `only_commit` the fix commit); 5B (`--round 2` on the same history: `round: 2 of 3`, no fix section, the original fixed point accepted); 5C (`--previous previous-2f.md`: as 5A); 6A (`review-brief.sh HEAD~1 --ticket 7` and `review-brief.sh "$r1" --ticket 7` -> `fp 3 "$r2" ...` with the `reviewed:` clause, no state); 7A (a copy naming `0000000000000000000000000000000000000000` -> `FR(3)`); 8A (a fix commit whose message names no ticket -> `FT(3)`); 9A (`previous-2f-nospec.md`: the Standards path and `no spec: Standards axis only`, the fix section present); 10A (`previous-2f-nosha.md`, and one whose `reviewed:` line is `abc1234` -> `FV` each); 11A (`previous-2o.md` -> as 4A with `fix-lines` empty); 12A (`previous.md` plus `fix-only next` at round one -> today's round-two output); 13A (the verdict line in a stranger's comment, inside a fence, and in a comment before the deciding one -> as 4A each); 14C (a CRLF `previous-2f.md` -> as 5C); 15A (`previous-2f.md` then `previous-2r.md` -> 4A; the other order -> 5A); 16A (a restart comment after `(2F)` -> `X`, `round: 1 of 3`, no fix section) and **#93's 13B** (`--round 2` over the `(3W s)` + restart history -> `X`, `round: 2 of 3`, no fix section); 17A (`previous-2f.md` then `previous-3.md` -> `$f4`); 18A, 19A, 20A (#93's rows 3 and 9 rerun with a `reviewed:` line, and for 19A a `fix-only next` line added to `previous-3w.md`: the same output #93 asserts today); 21A (`review-brief.sh "$r2" --ticket 7` before the fix commit is made -> the empty-diff refusal); 22A (`--paths a.txt --commits HEAD` after `(2F)` -> `FP(3,r2,paths,reviewed)`); 23 (`fix-lines` present after a sweep run and after 5A, `fix-only` absent for every whole-diff row). The anti-drift pins: `fragment()` gains the trim-and-threshold fragment, held together across both scripts beside the `cap=3;` and `fenced` copies; the babysit sentence `has` in both `template/.agents/skills/poteto-mode/playbooks/babysit.md` and `template/.agents/skills/babysit/SKILL.md`; `has "$source_skill/SKILL.md" "$fix_rule"` unchanged. The block ends with `rm pr.json`.

`tests/spec-review/no-stale-wording.sh`: no new entry; `at most three rounds` is already in the grep.

### Criteria map

1. Table A rows 1 to 3 and 12 (round two is the whole diff whatever the lines say), the contract's gate (below round three neither branch runs), and 2A's byte-for-byte `printed` assertion.
2. Terms (hard item, changed lines, inside the fix, the verdict), table B rows 1 to 6 (the verdict computed from the reports and `fix-lines`, never from the judgment), table A rows 4, 5 and 11 (a comment that cannot say falls back to the whole diff), rows 18 and 19 with table B column D (sticky, by the marker).
3. Table A rows 5 to 9, 21 and 22 (`FP`, `FR`, `FT`, the empty diff, the sweep), the fix section and `$fix_rule` unchanged, rows 17 to 20 (the cap and the round after a Would-break fix untouched).
4. Table B rows 7 and 8 (the owed line, both rounds, beside the WB line), the babysit sentence in both copies, pinned by the brief test.
5. Every row of both tables carries its assertion in the Tests list, in the tables' order, written before the script changes.
6. #93's 13B in the brief test, 5C and 5D in the comment test, each named above; the P20 amendment and the ladder sentence in the prose list.

### Files touched

`template/.agents/skills/spec-review/scripts/review-brief.sh`; `template/.agents/skills/spec-review/scripts/review-comment.sh`; `template/.agents/skills/spec-review/SKILL.md` with `patches/mattpocock/spec-review.SKILL.md.patch`; `template/.agents/skills/poteto-mode/playbooks/babysit.md` and `template/.agents/skills/babysit/SKILL.md` with their patches; `template/.agents/skills/poteto-mode/playbooks/ticket.md`; `template/docs/agents/review-ladder.md`; `docs/knowledge/core/MANUAL.md`, then `python3 tools/build_knowledge.py` (regenerates `template/docs/factory918/`); `SOURCES.md` items 4, 6, 12; `tests/spec-review/review-brief.sh` and `review-comment.sh`. `docs/knowledge/core/DECISIONS.md` (P20 and a Provisional row) is the owner's, in its own commit. No new script, no new file under `template/`, no renumbered step; the judgment's grammar, `GLOSSARY.md`, `overlap.sh` and the delegation hook untouched, so #107 and #108 stack on unchanged ground.

### The open questions, answered

1. **Where the code location comes from.** From the report item's own quoted hunk, placed by `review-comment.sh` against `<dir>/fix-lines`, which `review-brief.sh` wrote from the fix commits. Not from a new judgment field: the orchestrator is told not to read the diff (step 1), so it cannot honestly write `at: <path>:<line>`, and a field it guessed would be the human's word criterion 2 forbids. Not from a report rule added at round three: the decision is made from round two's report, and the round-two brief is frozen. Matching content rather than line numbers avoids re-locating a hunk in the diff, which is the only reason ranges would be needed. A deletion counts: a line the fix removed is a line of the fix. Round one has no fix, so its set is empty and every item is outside; the verdict is suppressed there outright, because a round one with zero hard findings would otherwise license a fix-only round two and break criterion 1.
2. **How the reviewed commit reaches the next brief.** A new line `reviewed: <sha>` on every comment whose `<dir>/reviewed` holds a full id. Every comment, not only the ones that license a round: round two needs round one's commit to know which lines are the fix, the ladder already claims the comment names the commit it reviewed, and a per-round condition would be a rule with no reader. A comment without the line falls back to a whole-diff round with an empty fix-line set.
3. **Which items go under `## The fix under review` at round three.** The deciding comment's Act on items that carry neither `ticket:` nor `hole:`, marked `fixed:` or not, because at rounds one and two the fix lands after the comment. The set is unchanged at rounds four and five, where every Act on item is marked.
4. **Criterion 4's line.** `another round is owed`, printed at round one or two when any Act on item ends in `fixed: <sha>`, before the reviewed line. Babysit gains one sentence, byte-identical in both copies.
5. **How sticky is decided.** Not from the history. `review-brief.sh` writes `<dir>/fix-only` for the round it briefs; `review-comment.sh` prints the verdict from that file without placing any item, because a fix-only round's whole diff is the fix. A restart clears it with the history.

The residual risk, named. A Spec hard item quotes the criterion it rests on, not code, so it places outside and forces a whole-diff round even when it is about the fix. That is the safe direction, and it is what criterion 2 says for a missing requirement, but it will make round three whole-diff more often than the #88 data suggests. If a round of real use shows the feature never firing, the fix is a Spec-brief rule from round three on, which is a new ticket, not a change to these cells.
