# Digest for #107 (Ticket step 0)

Required reading
- Ticket #107 body (criteria 1-5; no comments). No worked example in the ticket; the scenario table is ours to write (criterion 4).
- Script: template/.agents/skills/spec-review/scripts/review-brief.sh (common(), report_rules(), the diff block); test: tests/spec-review/review-brief.sh (suite(), has/lacks/printed helpers, layout.sh).
- spec-review/SKILL.md step 4 (vendored; patches/mattpocock/spec-review.SKILL.md.patch, patches/README.md command).
- #106 Testing decisions (tables A/B) and P106; #93 tables; #90 table: every cell keeps its outcome.
- Playbooks from this worktree: ticket.md (step 0 digest, poll rule, round one at first push, gh run watch), feature.md (act-on lists before round one), opening-a-pr.md.
Facts
- A lane's completion notification reaches the root, not me: poll the exact absolute path I told the lane to write, inside my turn.
- `Closes #N` links only on a PR whose base is the default branch; my PR's base is feat/fix-only-from-round-two, so closingIssuesReferences will be empty: report it, do not retarget.
- Actions creates no pull_request run for a PR that conflicts with its base.
- `gh issue edit --body-file` replaces the body: read it whole, append, write back.
