Round two, from the same fixed point and with the round-one fixes in the diff, found no hard finding on either axis: the Spec walk covered fifteen documented steps and reported nothing missing, and the Standards reviewer noted a bullet's position in step 4, a duplicated lookup and a ragged comment wrap, none worth a round. This corrects round one's closing sentence, which said the review could end at round one with the fixes marked; Manuel's rule on the ticket lets an unreviewed non-hard fix stand only from round three, so this round reviewed them, and the count is zero on the latest commit, fc75ac6.

## Standards

# Standards review report

## Would break

## Fails open

## Standards breaches

1. **The new step-4 bullet sits out of emission order.** `CODING_STANDARDS.md`, Markdown: "Written with `/writing-for-agents` when an agent reads it." Step 4's bullet list has until now run in the order the brief prints its sections (commits, changed files, blast radius, diff, settled). The new bullet is listed after `## Settled in earlier rounds`, but `common()` prints the section between the `--stat` list and `## Blast radius`. The bullet's own words carry the truth ("before the diff"), so nothing breaks; the list no longer reads as the file it describes. Move the bullet above the blast-radius one.

```
+- `## The fix under review`, from round four on, before the diff: the Act on items the last review comment marks `fixed: <sha>`, verbatim, under exactly this paragraph: ...
```

## Fix alongside

2. **Duplicated Code: the report-item heading lookup is written twice.** `review-comment.sh` already resolves a judgment line to its report item's heading in the `hole:` loop (lines 186-195); the new Would-break-fix loop repeats the same four steps (`ref_id` by sed, the `case` picking the file, `specs | sed -n Np`, the `at`/`want` split). → one helper, `rests <judgment line>`, called from both.

```
+  ref_id="$(printf '%s' "$line" | sed -nE 's/^[0-9]+\. \[([SP][0-9]+)\].*/\1/p')"
+  case "$ref_id" in S*) f="$dir/standards-report.md" ;; *) f="$dir/spec-report.md" ;; esac
+  rests="$(specs "$f" | sed -n "${ref_id#[SP]}p")"
```

3. **The header comment rewraps ragged.** `review-comment.sh` lines 6-8 leave a four-word line mid-sentence where the rest of the header fills to the margin. → rewrap the paragraph when the next edit touches it.

```
+# reviewed; the next round's fixed point), the round (`of 5` from round four), then act-on items
+# counted from the judgment's Act on items
 # neither fixed on this PR (`fixed: <sha>`), filed as a ticket (`ticket: #N`) nor marked a hole,
```

hard findings: 0

## Spec

## Walk

1. Criterion 2, the record: `review-brief.sh` writes `git rev-parse HEAD` to `<dir>/reviewed` on the line after `<dir>/round`, in the one code path both forms reach (table A row 20).
2. The round parse becomes `/^round: [0-9]+ of [35]$/`, so a `4 of 5` or `5 of 5` comment advances `top` and every comment written before this ticket still parses.
3. The deciding comment is cut as the last comment of the history holding a non-blank line, CR and trailing blanks stripped, so a rebuild decides in place (rows 16, 19) and a restart cuts it away first (row 13).
4. From it: `wb` (the last `would-break fixed after` line outside fenced text), `had_spec` (no `no spec: Standards axis only` under `h == "Spec"`), `fixed_items` (the judgment's Act on lines ending `fixed:`). Fenced and strangers' copies never reach it (row 15).
5. Criterion 1, the gate, in the contract's order: `FM` for a line that is not 40 lowercase hex (row 14), `F6` past five (row 11), then `F4` byte for byte when `top` is at most 3 and the round is four, else `F5` (rows 1, 2, 3B, 8).
6. Then `FR` when the named commit does not resolve (row 5), `FP` when the fixed point is not it, `paths` included (rows 4, 10, 17), `FT` when a fix-only round names no ticket after a round with a spec (row 6); row 7 passes with the Standards axis alone. All before `mkdir -p "$dir"` and the empty-diff and blast-radius refusals (row 18).
7. `cap=3; [ "$round" -le 3 ] || cap=5` in both scripts, held together by `fragment()`; the line prints `round: N of $cap`.
8. `common()` prints `## The fix under review`, `$fix_rule`, then `$fixed_items`, after the changed files and before `## Diff`, only from round four; `git diff <sha>...HEAD` and `git log <sha>..HEAD` make the diff and the commit list the fix commits alone.
9. Criterion 1, the kind: `review-comment.sh` resolves each `fixed:` Act on item to its report heading through `specs()`, as the `hole:` loop does, and prints the line only for `Would break` with no hole marked; fails-open, breach, prose, `ticket:` and `## Walk` lines print nothing (table B rows 1, 2, 5, 6, 8).
10. `RM` fires after the round-file refusal, only when the line is needed, naming the first Would-break fix and the file's content as written (row 3E; row 5E is not refused).
11. Tail order: the summary, `restart` else the WB line, `round:`, `act-on items:` last, the count and the summary unchanged, no would-break count printed.
12. Criterion 4: the babysit sentence is byte-identical in the playbook and the standalone skill, pinned by the brief test, and a PR ending at round three prints today's lines.
13. Criterion 3: step 5's paragraph gives the two judgment stops and says no count is compared; no cell and no line of code compares rounds.
14. Criterion 6: P20 amended with a dated line, P30 added, the ladder's rung 1 in one sentence, plus `MANUAL.md` rebuilt, `SOURCES.md` items 4, 6 and 12, and both script headers.
15. Criterion 5: `tests/spec-review/review-brief.sh` and `review-comment.sh` carry one assertion per cell of tables A and B, and `no-stale-wording.sh` blacklists `at most three rounds`, whose four hits are all rewritten.

## Would break

## Fails open

## Not asked for

hard findings: 0

## Judgment

## Act on

## Ask

## Consider

## Noted

1. [S1] **The new step-4 bullet sits out of emission order.** Valid; the bullet says "before the diff" itself, so a reader is not misled, and moving it is a vendored-file edit and a patch regeneration for no behavior, not worth a round.
2. [S2] **Duplicated Code: the report-item heading lookup is written twice.** Valid; no Act on fix touches either loop, and a helper shared with the hole loop is a refactor of reviewed code for no behavior.
3. [S3] **The header comment rewraps ragged.** Valid; the next edit that touches the header rewraps it.

## Dismissed

Standards: 0 would break, 0 fail open, of 3; Spec: 0 would break, 0 fail open, of 0; judged: act on 0 (0 fixed, 0 with a ticket), ask 0, consider 0, noted 3, dismissed 0; fixed point d8e382ca37233bce98724c785ecdbb677abc4e2a.
round: 2 of 3
act-on items: 0

Claude Fable 5.1 on Claude Code
