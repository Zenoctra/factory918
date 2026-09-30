## Walk

1. `review-brief.sh` computes `grounding` from `--blast-radius FILE` or the PR body's `## Blast Radius` section as before, and refuses (`E`) when it is empty (criterion 1, acceptance criterion for the empty-grounding path, unchanged).
2. When `grounding` is non-empty, a new awk pass strips CR and trailing whitespace, skips fenced text via the shared `$fenced` fragment, and looks for the first line that is exactly `## Risks` or `### Risks`; not found triggers the new refusal (`N`) naming the file or "the PR body's Blast Radius section", `rm -rf "$dir"`, exit 1 before any state (criterion 2).
3. When found, the script proceeds to write the diff/log/files/state as before, and later builds `walk="$walk $risk_rule"` only when `grounding` is non-empty, appending the pinned `risk_rule` sentence to the Spec brief's `## Walk` bullet on the same line; the Standards brief's walk bullet is left untouched (criterion 1, criterion 3).
4. `SKILL.md` step 4 and step 1 carry the `risk_rule` sentence and the Risks-heading paragraph word for word, pinned against the script's copy by `tests/spec-review/review-brief.sh`'s `has` assertions (criterion 1).
5. `opening-a-pr.md` (through its patch) and `ticket.md` step 5 both say the pasted grounding's `## ` headings are demoted to `###` so the `## Blast Radius` section survives and `review-brief.sh` finds `### Risks` (criterion 4).
6. `tests/spec-review/review-brief.sh` adds one assertion per scenario-table cell (1A/1B, 2A, 3A/3B, 4A, 5A, 6A, 7A, 8A, 9A/9B, 10), covering both refusal forms, both heading levels, fenced exclusion, and the ignored/not-cross-cutting paths (criterion 2).
7. `tests/spec-review/review-comment.sh` adds a fixture where the Spec report's walk continues with two risk lines after the last documented step, asserting the same `hard findings`/`act-on items` counts as without them, i.e. risk lines are not counted as items (criterion 3).
8. The CI fixture (`factory-ci.yml`) updates its blast.md sample to the new `## Risks` heading shape and asserts the risk sentence appears in the Spec brief and not the Standards brief.

## Would break

## Fails open

## Not asked for

hard findings: 0
