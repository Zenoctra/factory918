## Walk

1. Criterion 1: the design-hole definition is in `spec-review/SKILL.md` step 5 (the paragraph before "Four trailing fields") and in rung 1 of `template/docs/agents/review-ladder.md`, both word for word as the ticket's Contract wrote them; no root `docs/agents/review-ladder.md` exists to copy.
2. Criterion 2: `review-brief.sh` echoes `$spec_rule` one blank line after `$step_rule` at both call sites; `review-comment.sh` `report()` runs `stepless` twice, `Documented step:` first, then `^spec: $ref$`; a fenced `spec:` line and every malformed form in table B row 3 are refused with the row-2 message (test run: 134 assertions pass).
3. Criterion 3: `holed()` finds `hole:` on judgment lines not ending in `fixed:`/`ticket:`; placement (G), grammar (E) and value (F, 5D) are checked in that order after the reference set and before the round file; `holes` is subtracted and `restart` printed after the summary line, before `round:`. A `hole:` in an item's prose or title is refused as a field that fits no form or sits under the wrong heading, with a message that says where the field goes.
4. Criterion 4: `ticket.md` step 8 points to the new `### Design hole` section, six steps as the ticket wrote them; `review-brief.sh` slices the comment history after the last comment holding a bare `restart` outside fenced text, prints the `restart:` line after `ticket:` and before `round:`, and both derivations read the sliced history. Table A rows 5 to 8 and 11 to 13 run through the fake `gh` and the real jq filter (414 assertions pass); a `--previous` file whose restart comment is followed by only a separator, or whose `restart` line ends in CR, is round 1 with nothing carried.
5. Criterion 5: `cites` gains `#[0-9]+ $ref` inside the `$`-anchored group; rows 14 to 17 pass, `#42 table 12/A trailing` and `#42 criterion 0` are dropped.
6. Criterion 6: the test list in the ticket's Contract is present in both test files; `fragment()` holds the two `ref=` lines together.
7. Criterion 7: the added babysit sentence is byte-identical in `babysit/SKILL.md` and `playbooks/babysit.md`; the earlier merge-ready sentence is unchanged; table B columns A to C print as before.
8. Patches: the three patches apply cleanly to the pinned upstreams and reproduce the template copies exactly; `SOURCES.md` items 4, 6 and 12 describe the change; ShellCheck 0.11.0 is clean over the seven changed shell files; `no-stale-wording.sh` finds no `Three trailing fields`.

## Would break

## Fails open

## Not asked for

hard findings: 0
