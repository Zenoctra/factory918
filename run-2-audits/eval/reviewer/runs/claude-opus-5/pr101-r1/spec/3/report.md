## Walk

1. Criterion 1, the Walk rule: `review-brief.sh` sets `walk` to the unchanged bullet and appends `$risk_rule` when `grounding` is non-empty, then `echo "$walk"`, so the Spec brief's `## Walk` bullet continues on its line with the Contract sentence and the bullet's own text still holds as a substring (`spec_bullets[0]`).
2. Criterion 1, word for word: the sentence is byte-identical in `review-brief.sh`, `template/.agents/skills/spec-review/SKILL.md` step 4, `patches/mattpocock/spec-review.SKILL.md.patch` and the test's `risk_rule`; the test pins it in the source `SKILL.md`.
3. Criterion 2, detection: inside the cross-cutting block, after the empty-grounding check and before any state, an awk over `$grounding` strips CR and trailing blanks, reuses the shared `fenced` fragment, and exits 0 on the first line that is exactly `## Risks` or `### Risks`; either level from either source (2A, 7A). The `fenced` fragment's `/^## /` rule does not `next`, so the heading still reaches the match rule.
4. Criterion 2, refusal: not found gives `rm -rf "$dir"`, the message naming `$blast` or "the PR body's Blast Radius section", stderr, exit 1, no state, no briefs (5A, 6A, 4A prose case).
5. Criterion 2, only with a grounding: `grounding` is assigned only under `[ -n "$crossing" ]`, so 1B, 3B and 9B get the bare bullet; the test asserts `lacks "$f" "$risk_rule"` in all three and in the Standards brief (1A, 3A).
6. Criterion 3: `review-comment.sh` is unchanged; `items()` and `numbered()` skip `h == "Walk"` whatever the numbers, and the new fixture in `tests/spec-review/review-comment.sh` inserts lines 4 and 5 into the walk and asserts the same `hard findings:` and `act-on items:`.
7. Criterion 4: the `## Blast Radius` bullet in `opening-a-pr.md` and its patch, `ticket.md` step 5, `SOURCES.md` items 3 and 6, P26, and the CI fixture's grounding all say the headings are demoted to `###`; the four sites carrying the old "verbatim" wording are all updated.

## Would break

## Fails open

## Not asked for

1. **P27 ships a stacked-PR rule to every project.** The decision the lane had to make is recorded, as `AGENTS.md` requires, but it is added to `template/docs/factory918/DECISIONS.md` as well, so a new factory rule about opening PRs against trunk travels with the template on a PR whose one concern is the Spec walk.

hard findings: 0
