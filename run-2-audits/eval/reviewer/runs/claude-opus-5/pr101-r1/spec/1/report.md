## Walk

1. Criterion 1, the `## Walk` rule. `review-brief.sh` defines `risk_rule` beside `blast_rule`, and the Spec brief builds its Walk bullet as `walk="$walk $risk_rule"` when `$grounding` is non-empty, so the sentence lands on the same line after the per-step rule; the bullet's own text is unchanged, so the existing `spec_bullets[0]` substring assertions still hold.
2. Criterion 2, both heading forms. Detection sits inside the `if [ -n "$crossing" ]` block, after the empty-grounding refusal and before `state=.claude/state/review`, over `$grounding` whatever its source: CR and trailing blanks stripped, the shared `fenced` awk skipping fenced text, matching the first line that is exactly `## Risks` or `### Risks` and exiting; `END { exit !found }`. On a miss it does `rm -rf "$dir"`, names the source (`$blast` when set, else the PR body's section) and exits 1. `### Risks` is not matched by `fenced`'s `/^## /` rule, so it reaches the new rule intact.
3. Criterion 2, the rule only with a grounding. `grounding` stays empty unless `crossing` is non-empty, so a non-cross-cutting diff never appends the sentence and never fetches the body (3B).
4. Criterion 2, the test. `tests/spec-review/review-brief.sh` asserts one cell per row: 1A/2A/7A/8A the sentence present, 3A the PR-body form, 5A/6A/4A the refusal with no state and no briefs via `refused_risks`, 9A the older refusal, 10 the usage block, 1B/3B/9B the sentence absent, and `lacks "$std" "$risk_rule"` for the Standards brief. `risk_rule` is also pinned against the source `SKILL.md`.
5. Criterion 3, `review-comment.sh`. Unchanged; `items()` and the shape check both skip `h == "Walk"`, and the new fixture inserts two risk lines into the Spec walk and asserts the same counts and the same comment.
6. Criterion 4, the playbooks. `opening-a-pr.md` and its patch both say the file's `## ` headings are demoted to `###` when pasted, with the reason, and that `review-brief.sh` finds the risks under `### Risks`; `ticket.md` step 5 says the hand-back is written with each part under a `## ` heading and one numbered risk per line under `## Risks`, and "that file verbatim" became "that file with its `## ` headings demoted to `###`". `SKILL.md` steps 1 and 4 and its patch carry the refusal and the sentence word for word, `SOURCES.md` items 3 and 6 record both, and the CI fixture's grounding gained the heading.
7. Cells 4A and 5A run through the same message. A PR body with undemoted headings loses everything from the inner `## ` on; prose left gives the new refusal naming the body, nothing left gives the older one.

## Would break

## Fails open

## Not asked for

hard findings: 0
