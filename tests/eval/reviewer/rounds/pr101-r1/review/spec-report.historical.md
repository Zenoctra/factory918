## Walk

1. Criterion 1, the Walk rule. `review-brief.sh` defines `risk_rule` as one sentence and, in the Spec brief only, appends it to the Walk bullet on the same line: `walk='- `## Walk`: ...'` then `[ -z "$grounding" ] || walk="$walk $risk_rule"`. The bullet's own text is unchanged, so the `spec_bullets[0]` substring assertion still holds.
2. Criterion 1, the wording. The sentence is byte-identical in the script, `SKILL.md` step 4, the mattpocock patch and the test's `risk_rule` (diffed all four). It names no level and no count, so `review-comment.sh` learns nothing new.
3. Criterion 2, detection. Inside the `[ -n "$crossing" ]` block, after the empty-grounding check and before `state=.claude/state/review`, an awk over `$grounding` with the shared `fenced` fragment (CR and trailing blanks stripped, fenced lines skipped by `fence != "" { next }`) accepts the first line that is exactly `## Risks` or `### Risks`. `### Risks` never matches `/^## /`, so `fenced`'s heading rule cannot swallow it.
4. Criterion 2, the refusal. Not found: `rm -rf "$dir"`, then the message naming `$blast` when the grounding came from a file and "the PR body's Blast Radius section" otherwise, stderr, exit 1. Word for word in `SKILL.md` step 1 and the test.
5. Criterion 2, only with a grounding. `grounding` is set only inside the cross-cutting block, so a non-cross-cutting diff keeps today's `plain`/`ignored` behaviour.
6. Criterion 2, the test. One assertion per cell, named by row and column: 1A, 1B, 2A, 3A, 3B, 4A (both halves), 5A, 6A, 7A, 8A, 9A, 9B, 10. `blast.md` is left as the bullet hand-back and now drives 5A.
7. Criterion 3. `review-comment.sh` excludes the `Walk` heading in `items()`, `stepless()` and `specs()`, so the two risk lines the new `review-comment.sh` fixture inserts after step 3 leave every count and the whole comment unchanged.
8. Criterion 4. The Opening a PR bullet, in the template and in its patch, says the file's `## ` headings are demoted to `###` and why. `ticket.md` step 5 and `SOURCES.md` items 3 and 6 say the same; the CI fixture's grounding gains the heading.

## Would break

## Fails open

## Not asked for

hard findings: 0
