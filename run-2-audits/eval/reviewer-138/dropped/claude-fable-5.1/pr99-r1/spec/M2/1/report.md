## Walk

1. `review-brief.sh` fetches the author's `act-on items:` comments (jq filter unchanged), strips CR and trailing blanks, then one awk keeps only the comments after the last line that is exactly `restart` outside a fence; a restart with nothing after it leaves `bodies` empty, so `top` is 0 and no `settled:` line or section is written (table A rows 5, 6, 8, 13).
2. The three-round refusal runs on the sliced history before any output; `ticket:`, then `restart: ...`, then `round:` print in that order, with `--round N` honored (rows 1B, 5B, 7).
3. `cites=` gains `#[0-9]+ $ref` inside the `$`-anchored group; `ref=` is one line copied into both scripts and `fragment()` holds the copies together (rows 14 to 17, criterion 5).
4. `spec_rule` is echoed one blank line after `step_rule` at both call sites; `SKILL.md` step 4 carries it word for word and the brief test pins the layout (criterion 2).
5. `review-comment.sh`: `report()` calls `stepless` twice, step first then `^spec: $ref$`, so a counted item without a well-formed `spec:` line, or with it only inside a fence, is refused before the judgment is read (table B rows 2 to 4).
6. After the reference-set check: `hole:` under Ask/Consider/Noted/Dismissed, then a form that fits no grammar, then a value that is not the report item's `spec:` (or an uncounted item), in that order; `holed()` excludes a line ending in `fixed:`/`ticket:`, so only the field that ends the line is a field (columns D to G, row 5, the notes).
7. `holes` is subtracted from the count and `restart` prints between the summary line and `round:`; a rerun with the dir prints the same comment (row 1D).
8. `SKILL.md` step 1, step 5 (the definition paragraph, "Four trailing fields", the `hole:` bullet), step 6 (count and refusals), `review-ladder.md` rung 1, the Ticket playbook's step 8 pointer and `### Design hole` section, and the byte-identical babysit sentence in `babysit.md` and `babysit/SKILL.md` all match the ticket's prose; `architect` has a Phase B and `arena` a judge for the section to name (criteria 1, 4, 7).
9. `tests/spec-review/review-brief.sh` (414 assertions), `review-comment.sh` (134), `no-stale-wording.sh`, `tests/shellcheck/gate.sh` and ShellCheck over the pinned set pass; `factory918.sh sync` re-applies all three patches and leaves `template/` and `SOURCES.md` identical to the reviewed commit; `check_knowledge.py` passes. `MANUAL.md` and `DECISIONS.md` P21 still describe three cite forms and no restart, which the ticket assigns to the owner, not the writer.

## Would break

## Fails open

## Not asked for

hard findings: 0
