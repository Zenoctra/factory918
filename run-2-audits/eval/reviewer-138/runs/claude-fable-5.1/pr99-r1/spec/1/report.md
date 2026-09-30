## Walk

1. Criterion 1, the definition: `spec-review/SKILL.md` step 5 carries the design-hole paragraph and `docs/agents/review-ladder.md` rung 1 carries the sentence, both word for word as the ticket's prose block gives them; the patch reproduces the template (`factory918 sync` in a throwaway copy leaves the tree clean).
2. Criterion 2, the `spec:` rule: `review-brief.sh` echoes `$spec_rule` one blank line after `$step_rule` at both call sites, before the report-path line; `review-comment.sh` `report()` calls `stepless` twice, `^Documented step:` first, then `^spec: $ref$`, so a counted item without a well-formed `spec:` line is refused before the judgment is read (table B rows 2 to 4, in that order; a fenced `spec:` does not count).
3. Criterion 3, the mark: `holed()` takes the judgment items under a heading that do not end in `fixed:`/`ticket:` and carry `hole:`; after the reference-set check the script refuses a `hole:` under Ask/Consider/Noted/Dismissed, then an Act on `hole:` fitting no form, then one whose value is not the report item's `spec:` value (`specs()` gives the n-th item's reference, empty for an uncounted item, so row 5D says "carries no 'spec:' line"); `holes` is subtracted from the count and `restart` is printed after the summary line, before `round:`.
4. Criterion 4, the restart: one awk between the fetch and the round awk keeps only the lines whose comment index is after the last comment holding a line exactly `restart` outside fenced text (CR and trailing blanks stripped by `split`); everything before, the restart comment included, is gone before `top` and `settled` are derived, so round 1 with no `settled:` line and no section; the `restart:` line prints after `ticket:` and before `round:`, also under `--round N`; the three-round refusal counts the new series alone (row 7), and a PR with no restart cuts nothing and refuses what it did before. The Ticket playbook gains the step 8 pointer and the `### Design hole` section after Quick ticket, no step renumbered, with `architect` Phase B, two runners, the dated amendment line, tests before code, round one.
5. Criterion 5, the citation: `cites` gains `#[0-9]+ $ref` inside the group, still `$`-anchored; rows 14 to 17 are tested through `--previous`.
6. Criterion 6, the tests: `review-comment.sh` covers rows 1 (A to G), 2, 3 (four malformed forms and a fenced one), 4, 5 (A, D, E, F, G), 6, the two-holes, last-field and dir-rerun notes; `review-brief.sh` covers rows 5A/5B/5C, 6, 7A/7B, 8, 11, 12A/12C, 13, 14 to 16, 17, the `spec_rule` anti-drift and layout, and `fragment()` now holds the two `ref=` lines together. All three suites pass here (414, 134 assertions, no stale wording) and ShellCheck is clean.
7. Criterion 7, babysit: the sentence added to `babysit/SKILL.md` and `playbooks/babysit.md` is byte-identical once the bullet and indent prefixes are removed; the earlier merge-ready sentence is untouched, and table B columns A to C print as before.
8. The one grammar: `ref=` is the same line in both scripts; `review-comment.sh` still reads no `cites:` and `review-brief.sh` no `hole:`; the loop variable that used to be `ref` is renamed `ref_id` so the regex is not clobbered.
9. Out of the writer's scope by the ticket's own "Files touched": `MANUAL.md` (core and generated) still says a PR is ready when the last `spec-review` line reads `act-on items: 0`, which a restart comment can now read while not being ready; the owner's Provisional entry is where the ticket sends that.

## Would break

## Fails open

## Not asked for

hard findings: 0
