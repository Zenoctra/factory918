## Walk

1. `review-brief.sh` cuts the history at the last `restart` comment, then takes `top` from `/^round: [0-9]+ of [35]$/`, so a `round: 4 of 5` or `5 of 5` comment counts (table A rows 8, 11, 13).
2. It extracts the deciding comment as the last separator-delimited chunk holding a non-blank line, CR and trailing blanks stripped, so a rebuilt round decides in place (rows 16, 19).
3. From it, `wb` (last `^would-break fixed after ` line outside fences), `had_spec` (no `no spec: Standards axis only` under `h == "Spec"`) and `fixed_items` (Act on lines of `## Judgment` ending `fixed: <sha>`) (rows 3, 7, 15).
4. The gate fires FM, F6, F4/F5, FR, FP, FT in that order, each one line on stderr and `exit 1` at line ~205, before `mkdir -p "$dir"` (261) and before the empty-diff refusal (275) — rows 1, 2, 4, 5, 6, 8, 10, 11, 14, 17, 18. F4's text is byte-identical.
5. A round past three is allowed only when `wb` is set and `round -eq top + 1`; `$fixed` must rev-parse to `$wb`, so `paths` refuses (row 17).
6. `cap=3; [ "$round" -le 3 ] || cap=5` then `round: $round of $cap`; the same line stands in `review-comment.sh` (contract, "The cap").
7. `git rev-parse HEAD > "$dir/reviewed"` after `<dir>/round`, one code path for both forms (row 20).
8. `common()` prints `## The fix under review` with `$fix_rule` verbatim then `$fixed_items` when `round -ge 4`, after `## Changed files` and before `## Blast radius`/`## Diff`.
9. `review-comment.sh` computes `holes`, then the first Act on `fixed:` item whose `specs()` heading is `Would break`; with a hole it prints `restart`, else `would-break fixed after <reviewed>`, then `round: N of $cap`, then `act-on items:` last (table B rows 1-9).
10. `reviewed` is read only when the line is needed and refused unless `^[0-9a-f]{40}$` (row 3E); row 5E leaves it unread.
11. Prose: `SKILL.md` steps 1, 4, 5, 6; `ticket.md` step 8 and the new `### Would-break fix`; the babysit sentence byte-identical in both copies; ladder rung 1; MANUAL merge checklist; SOURCES 4, 6, 12; P20 and P30; `at most three rounds` blacklisted and gone from `template` and `docs/knowledge/core`.

## Would break

## Fails open

## Not asked for

hard findings: 0
