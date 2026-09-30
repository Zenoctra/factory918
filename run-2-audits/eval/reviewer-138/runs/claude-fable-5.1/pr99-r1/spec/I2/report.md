## Walk

1. Criterion 1: `SKILL.md` step 5 carries the design-hole paragraph and `review-ladder.md` rung 1 the sentence, both word for word as the ticket's Contract wrote them.
2. Criterion 2: `spec_rule` is one variable in `review-brief.sh`, echoed one blank line after `$step_rule` at both call sites; `tests/spec-review/review-brief.sh` pins it in `SKILL.md` and both briefs. `review-comment.sh` refuses a counted item without it through `stepless "$f" "^spec: $ref\$"`, after the step refusal (table B rows 2 to 4; a fenced `spec:` does not count).
3. Criterion 3: `holed()` collects Act on lines carrying `hole:`; placement (G), grammar (E), then value against `specs()` (F, 5D) are refused in that order after the reference-set check and before the round file; `holes` is subtracted and `restart` printed after the summary line.
4. Criterion 4: the one awk cuts `bodies` at the last comment with a line exactly `restart` outside fences, prints the `restart:` line after `ticket:` and before `round:`, and both the round and the settled derivations read the slice; the fourth-round refusal on a PR without a restart is unchanged. Ticket step 8 points at the new **Design hole** section, whose six steps match the Contract's text; architect Phase B runs arena, whose convergence path (`arena/SKILL.md:62`) is what "the judge is skipped" names.
5. Criterion 5: `cites` gains `#[0-9]+ $ref` inside the `$`-anchored group; rows 14 to 17 tested through `--previous`.
6. Criterion 6: every cell the ticket's test list names has an assertion; the three test scripts pass (414, 134 assertions, no stale wording).
7. Criterion 7: `babysit/SKILL.md:41` and `babysit.md:17` are byte-identical; the existing merge-ready sentence is untouched; table B columns A to C keep their exact stdout. `docs/knowledge/core/MANUAL.md:103` still states ready as `act-on items: 0` alone; the ticket's Files touched leaves it to the owner, so it is noted here, not counted.
8. The three patches re-apply cleanly to their pinned upstreams and reproduce the template copies; ShellCheck is clean over the five changed shell files; `SOURCES.md` items 4, 6 and 12 describe the change.

## Would break

## Fails open

## Not asked for

hard findings: 0
