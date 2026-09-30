## Walk

1. Criterion 1: `SKILL.md` step 5 gains the design-hole paragraph word for word as the contract gives it, and `review-ladder.md` rung 1 gains the matching sentence after "An Ask item waits for the human."
2. Criterion 2: `review-brief.sh` defines `spec_rule` beside `step_rule` and echoes it one blank line after the step rule in the Spec brief. In the Standards brief it is echoed only when `$spec` is non-empty. `review-comment.sh` sets `has_spec` from `<dir>/spec-brief.md` before the Standards report is checked, and `report()` runs `stepless "$f" "^spec: $ref\$"` after the step check, only when a spec is present (table B rows 2 to 4, row 7).
3. Criterion 3: `holed()` takes the Act on lines that do not end in `fixed:`/`ticket:` and carry `hole:`. The checks run in this order: no spec, placement outside Act on, form (`hole: $ref$`), then value against `specs()` for the named report item (1D to 1G, 5D to 5G). `holes` is subtracted from the count, and `restart` is printed before `round:`.
4. Criterion 4: `ticket.md` gains the step 8 pointer and a `### Design hole` section with six steps (scope, two-runner architect Phase B, a dated amendment, tests first, round one, then step 9). In `review-brief.sh`, the new awk cuts every comment up to and including the last comment that has a bare `restart` line outside fenced text. `restarted` prints the `restart:` line between `ticket:` and `round:`. `top` and `settled` read the sliced history (rows 5 to 13).
5. Criterion 5: `cites` gains the alternative `#[0-9]+ $ref` inside the `$`-anchored group (rows 14 to 17).
6. Criterion 6: `tests/spec-review/review-comment.sh` covers rows 1 to 7 and the notes. `tests/spec-review/review-brief.sh` covers rows 5 to 8, 11 to 17, the `spec_rule` layout in both briefs, the no-spec layout, and `fragment()` holding `ref=`.
7. Criterion 7: the babysit sentence is added to `babysit.md` and to `babysit/SKILL.md` with the same text, through the patches and `SOURCES.md` items 4 and 12. Columns A to C of table B print as before (1A to 1C accepted with no `restart`).

## Would break

## Fails open

## Not asked for

hard findings: 0
