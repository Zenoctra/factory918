## Walk

1. Round three's comment: `review-comment.sh` resolves each Act on item ending `fixed: <sha>` to its report heading through `specs()` and stops at the first under `## Would break`; with no hole marked it reads `<dir>/reviewed` and prints `would-break fixed after <sha>` between the summary and `round:` (table B 3B, 7B, 9).
2. A round whose fixes are all Fails-open, Standards-breaches or ticketed items prints no such line, so the round may be the last (table B 1, 2, 6).
3. `holed "Act on"` excludes lines ending in `fixed:`/`ticket:`, so `hole: X fixed: sha` is a fix and prints the line, while a real hole prints `restart` and suppresses it (table B 4, 5).
4. The cap: `cap=3; [ "$round" -le 3 ] || cap=5`, the identical line in both scripts and pinned by `fragment()`; `round: 3 of 3` is byte-unchanged (table B 1B, 3C, 3D).
5. `review-brief.sh` records the reviewed tip: `git rev-parse HEAD > "$dir/reviewed"` beside `<dir>/round`, one code path, so the sweep form writes it too (table A 20).
6. The gate cuts the deciding comment from `$bodies`, reads the last unfenced `would-break fixed after` line, `had_spec` and the fixed Act on items, then refuses in order FM, F6, F4/F5, FR, FP, FT, all before `mkdir -p "$dir"` and before the empty-diff and blast-radius refusals (table A 1-19).
7. A round past three is allowed only at `top + 1` with the line; the fixed point must rev-parse to that commit, so `git diff <sha>...HEAD` and `git log <sha>..HEAD` are the fix commits alone (table A 3, 4, 5, 9, 10).
8. `--ticket` is resolved from `$fixed..HEAD` before the gate, so FT fires only when the fix commits name no ticket and the previous round had a spec (table A 6, 7).
9. The round parse widened to `of [35]`; a restart comment still ends the history, and a round-one line changes nothing (table A 12, 13, 19).
10. Both briefs print `## The fix under review` from round four, the `fix_rule` paragraph then the fixed items verbatim, after `## Changed files` and before `## Blast radius` and `## Diff`.
11. Prose: `spec-review` step 5's two stops with no count compared; the `fixed:` bullet; the Ticket playbook's Would-break fix section; the byte-identical babysit sentence in both copies; `review-ladder.md` rung 1; both `MANUAL.md` copies; P20's amendment and P30; `SOURCES.md` 4, 6, 12; `no-stale-wording.sh` gains `at most three rounds`, which now has no hit.

## Would break

## Fails open

## Not asked for

hard findings: 0
