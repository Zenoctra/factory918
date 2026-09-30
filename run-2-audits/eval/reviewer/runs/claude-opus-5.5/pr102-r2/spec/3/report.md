## Walk

1. Criterion 1, the comment: `review-comment.sh` resolves each Act on line ending `fixed: <sha>` to its report heading through `specs()`; when one sits under `## Would break` and no hole is marked, it reads `<dir>/reviewed` (refusing it missing or not 40 hex) and prints `would-break fixed after <sha>` between the summary and `round:`. Fails-open, breach and ticketed fixes print no line (table B rows 1, 2, 6).
2. Criterion 1, the brief: `review-brief.sh` cuts the deciding comment (last of the history, CR and trailing blanks stripped), reads its WB line outside fences, and then refuses in order FM, F6, F4/F5, FR, FP, FT, before any state. `F4` is byte-identical. A sixth round is refused in every case.
3. Criterion 2: a round past three is allowed only when it is `top + 1` after a comment that carries the line, and only when the fixed point resolves to that sha. Both briefs carry `## The fix under review` with `fix_rule` and the deciding comment's fixed Act on lines, placed before blast radius and the diff. `ticket.md` gains the Would-break fix section, and SKILL.md step 1 names `review-brief.sh <sha> --ticket N`.
4. The reviewed commit: `git rev-parse HEAD > <dir>/reviewed` is written after `round` on the one shared path, so the sweep form writes it too.
5. Criterion 3: SKILL.md step 5 gains the paragraph that sets two judgment stops. It compares no count between rounds and, at round five, calls for the report, `gh pr ready --undo` and a wait. The comment's summary line prints no would-break count.
6. Criterion 4: the babysit sentence is byte-identical in both templates and both patches, and the brief test pins it. A comment ending at `round: 3 of 3` with no line reads as before.
7. Criterion 5: `tests/spec-review/review-brief.sh` asserts table A rows 1 to 20. That includes 3A (round four from `s`, fix section, one commit) and 9A/11A (round five, then F6). `review-comment.sh` asserts table B 1C to 9, including 3D and 3E.
8. Criterion 6: P20 is amended, and P30 is added as the round-five stop. Ladder rung 1 is one sentence. MANUAL's merge checklist gains the line, and the generated copies are rebuilt.
9. The anti-drift checks: `fragment()` now includes the `cap=3;` line. `no-stale-wording.sh` blacklists `at most three rounds`, and all four hits are rewritten.

## Would break

## Fails open

## Not asked for

hard findings: 0
