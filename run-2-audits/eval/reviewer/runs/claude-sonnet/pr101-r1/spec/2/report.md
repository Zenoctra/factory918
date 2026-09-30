## Walk

1. `review-brief.sh` locates the Risks heading in the grounding text (file or PR-body section) with the shared `fenced` awk, checking each unfenced line for exact equality with `## Risks` or `### Risks` after stripping CR and trailing whitespace, and stops at the first match.
2. When a cross-cutting diff's grounding has no such heading, the script removes the already-created `.scratch/review/<id>` directory and exits 1 on stderr with a message naming the file or "the PR body's Blast Radius section" and quoting the required heading forms, before `.claude/state/review` is ever created.
3. When the heading is found, the script sets `risk_rule` (the fixed sentence) and appends it, with one space, to the `## Walk` bullet's own text only when `$grounding` is non-empty, so the Standards brief and any non-cross-cutting brief never carry it.
4. `SKILL.md` step 1's cross-cutting paragraph and step 4's report-shape bullet, and both patches (`spec-review.SKILL.md.patch`, `opening-a-pr.md.patch`) plus the direct copies (`SKILL.md`, `opening-a-pr.md`, `ticket.md`), carry the refusal message and the risk sentence word for word, matching the strings pinned in `review-brief.sh` and in `tests/spec-review/review-brief.sh`.
5. `review-comment.sh` is unchanged; its `items()` helper excludes any line under `h == "Walk"` regardless of how many numbered lines are there, so appended risk lines are never counted, confirmed by the new `review-comment.sh` fixture that inserts two risk lines and asserts identical counts.
6. `tests/spec-review/review-brief.sh` adds one assertion per scenario-table cell (1A/1B, 2A, 3A/3B, 4A, 5A, 6A, 7A, 8A, 9A/9B, 10), each named by row and column, covering both heading levels, both fenced and unfenced placement, both levels present, an empty Risks section, an undemoted PR body, and the missing-file usage case.
7. `SOURCES.md` items 3 and 6 and `docs/knowledge/core/DECISIONS.md` / `template/docs/factory918/DECISIONS.md` (P26) record the demotion rule and the walk contract; `docs/knowledge/INDEX.md`'s line count is bumped to match the file's new line count.

## Would break

None found.

## Fails open

None found.

## Not asked for

None found.

hard findings: 0
