# Spec review, c83f166 (#89)

## Walk

1. Criterion 1 (runner prompt first deliverable): `architect/SKILL.md` Phase B now says that for a design with state, the package opens with the scenario table, its contract and its test list, and it points to `references/runner-prompt.md` for the shape. This matches the runner prompt, and the change goes through the new `patches/pstack/architect/SKILL.md.patch`, which is listed in `series` and in SOURCES.md item 14.
2. Criterion 3 (Ticket step 6): the step now reads the body with `gh issue view`, adds `## Testing decisions` at the end with its `Posted by the agent <date>` line, and writes the whole file back with `gh issue edit --body-file`. A failed write stops the ticket before implementation. The step still covers the human's edit, the `/architect with checkpoint` stop and the fact that `review-brief.sh` pastes the body.
3. Criterion 5 (to-spec): the bullet now says that the rule above about paths and snippets does not exclude the table. That matches line 55 of `to-spec/SKILL.md`, which covers both paths and snippets.
4. Criterion 6 (knowledge page): `SCENARIO-TABLE.md` now appears in both copies of the MANUAL's reading list ("first five"). `build_knowledge.py` copies every core document except CONVERSATION-DIGEST, which gives five of the six, so the count is consistent.
5. Overlap check: the awk in `overlap.sh` skips `## Diff`, `## Testing decisions` and `## Design`. The new test is exact on its output, and it would fail if either new section were not skipped: `docs/a.md` hits feat-a and `src/z.txt` hits feat-b. P24 in both DECISIONS copies records the amendment with its date.

## Would break

## Fails open

## Not asked for

1. **Overlap check skips the two artifact sections.** The change is not literally in the criteria, but it follows from step 6: a table that quotes example paths would otherwise make step 1 report a false overlap on a resumed run. P24 records the change as an amendment. The match is case-sensitive, so a to-spec `## Testing Decisions` (capital D) section is still read for paths. This is correct, because that section comes from the spec and not from the posted artifact.
```
- [ ] The Ticket playbook's architect step says that when a design adds state, the table is appended to the ticket's body under `## Testing decisions`
```

hard findings: 0
