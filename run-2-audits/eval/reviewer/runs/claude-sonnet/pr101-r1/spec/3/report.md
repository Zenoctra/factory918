## Walk

1. `review-brief.sh` gains `risk_rule`, appended to the `## Walk` bullet on the same line only when `grounding` is non-empty, matching criterion 1 and the Contract sentence word for word.
2. Risk-heading detection runs on `grounding` after the empty-grounding refusal and before `state=.claude/state/review` is written, via a shared `fenced`-aware awk matching `$0 == "## Risks" || $0 == "### Risks"` outside fenced text; not found triggers `rm -rf "$dir"` then the named refusal on stderr, exit 1 — criterion 2.
3. The refusal names the file when `--blast-radius FILE` was passed, else "the PR body's Blast Radius section" (`where` variable) — criterion 2's "each saying" of the source.
4. `review-comment.sh`'s `items()` already excludes every line under `h == "Walk"`, so risk lines (still numbered under `## Walk`) are excluded unchanged; only the test file gained a fixture (two risk lines appended) asserting identical counts — criterion 3.
5. `template/.agents/skills/poteto-mode/playbooks/opening-a-pr.md` (and its patch) now says the pasted file's `## ` headings are demoted to `###` and that `review-brief.sh` finds risks under `### Risks` — criterion 4.
6. `SKILL.md` step 1 carries the same detection/refusal paragraph and step 4 carries the risk sentence word for word; `tests/spec-review/review-brief.sh` pins both via `has`/`lacks`.
7. `SOURCES.md` items 3 and 6 and `ticket.md` step 5 updated to describe demoted headings and the `## Risks` hand-back shape.
8. `DECISIONS.md` gains P26 (this mechanism) and P27 (the unrelated stacked-PR workaround for #91's own execution); `ledger.md` gains two process-surprise lines.
9. The CI fixture (`factory-ci.yml`) rewrites `/tmp/blast.md` into heading form with a numbered risk and asserts the risk sentence is present in the Spec brief, absent from the Standards brief.
10. `tests/spec-review/review-brief.sh` adds one assertion per scenario-table cell (1A/1B, 2A, 3A/3B, 4A, 5A, 6A, 7A, 8A, 9A/9B, 10), each named by row/column, covering both Risks-heading levels, fenced exclusion, both-levels precedence, empty-under-heading, missing heading, undemoted PR headings, and `--blast-radius` naming no file.

## Would break

## Fails open

## Not asked for

hard findings: 0
