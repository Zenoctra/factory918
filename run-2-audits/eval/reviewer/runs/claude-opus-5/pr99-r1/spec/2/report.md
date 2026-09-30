## Walk

1. Criterion 1, the definition. `spec-review/SKILL.md` step 5 gains the paragraph naming the three artifacts, the intent-outranks-a-criterion rule and the could-not-run exemption; `template/docs/agents/review-ladder.md` rung 1 gains the same rule in one sentence, ending in `hole: <reference>`, the `restart` line and round one.
2. Criterion 2, the `spec:` line. `review-brief.sh` defines `spec_rule` beside `step_rule` and echoes it one blank line after the step rule in both briefs, before the report-path line; `SKILL.md` step 4 carries the same sentence word for word.
3. Criterion 2, the refusal. `review-comment.sh` parameterises `stepless()` on the required line's regex and calls it twice per report, the step refusal first and the `spec:` refusal second, so a counted item without `spec: table <row>/<column>`, `design <signature>` or `criterion <k>` is refused before the judgment is read.
4. Criterion 3, the mark. `holed()` selects Act on lines carrying `hole:` that do not end in `fixed:`/`ticket:`; three refusals run in order (outside Act on, no form, not the judged item's `spec:` word for word), `holes` is subtracted from the count, and `echo restart` sits between the summary and `round:`.
5. Criterion 4, the restart. One awk between `bodies` and the round awk keeps only the comments after the last comment holding a line that is exactly `restart` outside fenced text, prints the `restart:` line after `ticket:`, and leaves the round, the settled set and the fourth-round refusal reading the sliced history.
6. Criterion 4, the playbook. `ticket.md` step 8 points at the new `### Design hole` section, whose six steps scope the redesign to the reference, run `architect` Phase B, amend the artifact with a dated line, rewrite the tests, and review from round one.
7. Criterion 5, the cite. `review-brief.sh`'s `cites:` group gains `#[0-9]+ $ref` as a fourth alternative, still `$`-anchored; the `ref=` line is held identical between the two scripts by `fragment()`.
8. Criterion 6, the tests. `review-comment.sh` covers table B rows 1A–1G, 2, 3, 4, 5A/5D–5G, 6 and the notes; `review-brief.sh` covers table A rows 5–8, 11–17 and the `spec_rule` layout.
9. Criterion 7, babysit. One added bullet in `babysit/SKILL.md` and one added paragraph in `playbooks/babysit.md`, both patched upstream; the existing merge-ready sentences are untouched.

## Would break

## Fails open

## Not asked for

hard findings: 0
