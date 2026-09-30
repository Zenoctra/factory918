## Walk

1. Round three's comment (criterion 1, table B row 3B): `review-comment.sh` computes `holes`, then walks the Act on items matching `fixed: [0-9a-f]{7,40}$`, resolves each `[S<n>]`/`[P<n>]` through `specs()` to its report heading, and stops at the first whose heading is `Would break`. With a hit and no hole it requires `<dir>/reviewed` to hold 40 lowercase hex and prints `would-break fixed after <sha>` between the summary line and `round:`, so `act-on items:` stays last.
2. A round whose fixes are all Fails-open, Standards-breaches or prose items (criterion 1, table B row 2): the heading test fails for every fixed item, `wb_first` stays empty, `<dir>/reviewed` is never read, and the tail is today's. Row 6's `ticket: #N` item never matches the `fixed:` grep. Row 5's hole outranks the line: `restart` prints and the file is not read.
3. The reviewed commit (criterion 2): `review-brief.sh` writes `git rev-parse HEAD` to `<dir>/reviewed` on the line after `<dir>/round`, in both forms, and nothing else writes it. It is read back only from the PR comment.
4. Round four's brief (criterion 2, table A row 3): the gate cuts the deciding comment out of `$bodies`, reads its `would-break fixed after` line outside fenced text, `had_spec` and its fixed Act on lines; with the line present and `round == top + 1` it requires `<sha>` to resolve (`FR`) and to be the fixed point (`FP`), and a ticket when the previous round had a spec (`FT`). `common()` then emits `## The fix under review`, `$fix_rule` and the fixed items after `## Changed files`, before `## Blast radius` and `## Diff`, and the commit list is `<sha>..HEAD`.
5. The caps and refusals (criterion 1): `cap=3; [ "$round" -le 3 ] || cap=5` is one line in both scripts, pinned by `fragment()`. `FM` fires first on a hand-written line, then `F6` on any sixth round, then `F4` when `top <= 3` and the round is four (byte-identical to the old text), else `F5`. All fire before `mkdir -p "$dir"`, so no state is written.
6. Rounds one to three (criterion 4): a comment with no line parses as before (`round: [0-9]+ of [35]$` accepts every comment written so far), the gate is skipped, no fix section is emitted, and a round-one line is informational (table A row 12). A restart cut empties the history, so `restart` still wins (row 13).
7. The two stops (criterion 3): `spec-review` step 5's new paragraph gives the round-three look and the round-five report, draft and wait, and says no count is compared. No cell in either table counts or compares hard findings, and the summary line is unchanged.
8. Babysit (criterion 4): one sentence, byte-identical in `poteto-mode/playbooks/babysit.md` and `babysit/SKILL.md`, both pinned by the brief test; the patches and `SOURCES.md` items 4 and 12 carry the same words.
9. The records (criterion 6): P20 amended, P30 added, `review-ladder.md` rung 1 in one sentence, `MANUAL.md`'s merge checklist, the regenerated `template/docs/factory918/`, and `no-stale-wording.sh` blacklisting `at most three rounds`, which now has no hit under `template/` or `docs/knowledge/core/`.
10. The tests (criterion 5): `review-brief.sh`'s new block asserts table A rows 1 to 20 and `review-comment.sh`'s asserts table B rows 1 to 9, each named by its cell, with the three moved assertions gaining the line.

## Would break

## Fails open

## Not asked for

hard findings: 0
