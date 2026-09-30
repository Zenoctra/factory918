## Walk

1. `architect/SKILL.md` Phase B gains a sentence: for a design with state the package opens with the scenario table, its contract and its test list, matching `references/runner-prompt.md` (decision P14/#89).
2. A new `patches/pstack/architect/SKILL.md.patch` vendors that same sentence and is registered in `patches/series` right after the poteto-mode playbook patches, before `pstack/architect/references/runner-prompt.md.patch`.
3. `to-spec/SKILL.md`'s Testing Decisions bullet (and its `patches/mattpocock/to-spec/SKILL.md.patch`) is reworded so "the rule above" is named explicitly as the "paths and snippets" rule from Implementation Decisions.
4. `poteto-mode/playbooks/ticket.md` step 6 now says the agent reads the current ticket body (`gh issue view N --json body -q .body`), appends the section, and writes the whole file back with `gh issue edit N --body-file`, stopping and reporting if the write fails.
5. `SCENARIO-TABLE.md` (core and template copy) documents the same read-append-write-whole-file procedure and notes the step-1 overlap check skips both the `## Testing decisions` and `## Design` sections.
6. `overlap.sh`'s section-skip regex is extended from matching only `## Diff` to matching `## Diff`, `## Testing decisions` or `## Design`, so example paths quoted inside a posted table or design sketch no longer count as ticket-named paths.
7. `tests/poteto-mode/overlap.sh` gains a fixture with both `## Testing decisions` and `## Design` sections, asserting the tool reports `paths: none`.
8. `MANUAL.md` (core and template) and `INDEX.md` bump the line count to 175 and add `SCENARIO-TABLE.md` as the fifth project document a project carries.
9. `tools/build_knowledge.py`'s docstring is corrected to say every core document except `CONVERSATION-DIGEST` is copied, matching the code's existing `p.name != "CONVERSATION-DIGEST.md"` filter.

## Would break

## Fails open

## Not asked for

Verified against the working tree: `docs/knowledge/core/MANUAL.md` is actually 175 lines (matches its own updated header and the `INDEX.md` entry), `DECISIONS.md` is 93, `SCENARIO-TABLE.md` is 88 (both unchanged, consistent with their net-zero-line diffs), and `tools/build_knowledge.py` line 136 already reads `if p.name != "CONVERSATION-DIGEST.md":`, so the corrected docstring matches real behavior rather than describing it wrong. The `architect/SKILL.md` template edit and its new `patches/pstack/architect/SKILL.md.patch` are byte-identical, and the `to-spec` template bullet matches its patch. The `overlap.sh` awk skip pattern and its test fixture agree with the new header comment and with `SCENARIO-TABLE.md`'s "Where it goes" note. No requirement from the ticket's acceptance criteria is missing, partial, or contradicted in this diff, and nothing outside it proceeds silently.

hard findings: 0
