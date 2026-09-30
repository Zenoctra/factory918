## Walk

1. Criterion 1: `architect/SKILL.md` Phase B now says a stateful design's package opens with the scenario table, contract and test list, pointing at `references/runner-prompt.md`; the change goes through the new `patches/pstack/architect/SKILL.md.patch`, which is listed in `series` and described in `SOURCES.md` item 14.
2. Criterion 2: the runner prompt's "refused with the tool's own message" rule is unchanged by this diff. `SOURCES.md` item 14 still describes it.
3. Criterion 3: Ticket step 6 reads the body with `gh issue view`, appends `## Testing decisions` with the `Posted by`/`Approved by` first line, writes the whole file back with `--body-file`, and stops if the write fails. It keeps the `/architect with checkpoint` and `review-brief.sh` sentences. SCENARIO-TABLE.md (core and template) says the same.
4. Criterion 5: the to-spec bullet (patch and copy) names the table as the shape for stateful work. The wording now matches the "paths and snippets" rule above it.
5. Criterion 6: MANUAL (core and template) lists `SCENARIO-TABLE.md` as the fifth document a project carries. The `build_knowledge.py` docstring says every core document except CONVERSATION-DIGEST is copied. INDEX line count updated.
6. The step-1 `overlap.sh` awk skips `## Testing decisions` and `## Design` along with `## Diff`. The header comment, P24 (core and template) and the test (a table cell path and a Design path give `paths: none`, exit 0) match it.

## Would break

## Fails open

## Not asked for

1. **The overlap matcher now skips two more sections.** The ticket does not mention `overlap.sh`. The diff changes the script's matching rule and amends P24. The change follows from posting the table: without it, a path quoted in a cell would count as a path the ticket names. It is recorded as an amendment dated 2026-09-22.

```
The table is appended to this ticket's body under `## Testing decisions`
```

hard findings: 0
