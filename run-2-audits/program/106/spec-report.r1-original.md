## Walk

1. Round one's brief runs, records `HEAD` in `<dir>/reviewed`, writes no `fix-lines` (`round` is 1), and `common()` prints no fix section because `from` is empty. Stdout, diff and both briefs are what they were (criterion 1).
2. Round one's `review-comment.sh` computes `fixed_here` before the tail, and with `holes` 0 and `round` 1 sets `record="reviewed: $mine"` from a 40-hex `<dir>/reviewed`, plus `owed` when an Act on item ends in `fixed:`. Both print between the WB line's place and `round:`, in that order (criterion 4; table B 1A, 7A, 8A).
3. Round two's brief reads the deciding comment for `rv` (`reviewed: ` and 40 hex, length 50, outside fences). With `round` 2, `top` 1, `rv` resolving and an ancestor of `HEAD`, it writes `<dir>/fix-lines` from `git diff -U0 $rv HEAD`: markers stripped, trimmed, four characters or more, each once. The gate leaves `from` empty, so round two is whole-diff (criterion 1; table A rows 2, 3, 22).
4. Round two's `review-comment.sh` calls `outside`, which counts Would-break and Fails-open items in the Standards report and, with `has_spec`, the Spec report. An item is inside when a quoted fenced line's text is a fix line and every `+`/`-` line it quotes is one; fence lines, `@@` lines, texts under four characters and unmarked non-fix lines count nothing. Zero outside prints `fix only after <reviewed>`; the judgment is never read (criterion 2; table B rows 1 to 6 and 12).
5. Round three's brief reads `fo` the same way and, with `round` 3 and `top` 2, sets `from="$fo"` and `via="fix only after"`. The shared block refuses a commit that does not resolve (`FR`), a fixed point that is not it (`FP`, naming `$via`), and a missing ticket after a spec (`FT`), all before `mkdir -p "$dir"`. At rounds four and five `via` is `would-break fixed after`, so #93's strings stay byte-identical (criterion 3; table A rows 5, 7 to 11, 15 to 18).
6. `fixed_items` is computed after the gate: at round three every Act on line not ending in `ticket: #N`, otherwise #93's `fixed:` filter. `common()` prints `## The fix under review` whenever `from` is set (table A 5A, 15A).
7. Stickiness needs no code: round four exists only after a Would-break fix and is #93's fix-only round, so every round after a fix-only round three is fix-only (criterion 2).
8. Prose: `SKILL.md` steps 1, 4 and 6 through the patch with `SOURCES.md` item 6; the owed sentence byte-identical in both babysit copies with items 4 and 12; the `MANUAL.md` and `review-ladder.md` merge-ready clauses; P20 retitled and amended, P106 added; `no-stale-wording.sh` pins the rewritten step-1 phrase (criteria 4, 7).
9. Tests: one assertion per cell of both tables, `same` proving criterion 1 byte for byte, and #93's cells 13B, 5C and 5D given direct assertions (criteria 5, 6).

## Would break

## Fails open

## Not asked for

hard findings: 0
