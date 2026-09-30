## Walk

1. `review-brief.sh` fetches the author's `act-on items:` comments, then one awk (`review-brief.sh:141-152`) keeps only the comments after the last line that is exactly `restart` outside fenced text, CR and trailing blanks stripped by `split`; when it cut anything it prints `restart: the round and the settled items count from the last restart comment` after `ticket:` and before `round:` (rows A5-A8, A13, tested with the fake `gh` and `--previous`).
2. The round awk and the settled awk read the sliced history, so a restart in round three is round one and the fourth-round refusal counts the new series alone (A6, A7); `--round N` still overrides (A5B, A7B).
3. `cites:` gains `#N ` + `$ref`, `$`-anchored, and the three forms carry verbatim into both briefs; malformed cites are dropped and counted (A14-A17).
4. `spec_rule` is echoed one blank line after `step_rule` at both call sites; `SKILL.md` step 4 carries it word for word and the brief test pins the layout (criterion 2).
5. `review-comment.sh` `report()` runs `stepless` twice, `^Documented step:` first and `^spec: $ref$` second, so a counted item without a well-formed `spec:` line, or one only inside a fence, is refused with the message table B rows 2-4 give, before the judgment is read.
6. After the reference-set check, `holed()` takes judgment items whose line does not end in `fixed:`/`ticket:` and holds `hole:`; refusals run in the order placement (G), grammar (E), value against `specs()` (F, 5D); the greedy sed takes the trailing field, so `loophole:` prose before a well-formed trailing `hole:` passes (probed).
7. `holes` is subtracted from `act-on items`, `restart` prints after the summary and before `round:`, and a rerun with the dir prints the same comment (1D, two holes, last-field, rerun; all tested).
8. `SKILL.md` steps 1, 5 and 6, `review-ladder.md` rung 1, Ticket step 8 and the new `### Design hole` section, `babysit.md` and `babysit/SKILL.md` carry the contract's text; the two babysit sentences are byte-identical (checked); `SOURCES.md` items 4, 6, 12 describe the patches; `no-stale-wording.sh` blacklists `Three trailing fields`.
9. `tests/spec-review/review-brief.sh` (414 assertions), `review-comment.sh` (134) and `no-stale-wording.sh` pass; `tools/check_knowledge.py` passes; ShellCheck is clean over the five changed shell files; `factory918.sh sync` in a scratch copy reproduces `template/` byte for byte; the test commit is the oldest of the three (rule 3).
10. The `ref` grammar line is identical in both scripts and `fragment()` holds them together; the judgment loop's `ref` variable was renamed `ref_id` so the grammar is not clobbered.

## Would break

## Fails open

## Not asked for

hard findings: 0
