## Walk

1. `architect`'s runner prompt (patch + `template/.agents/skills/architect/references/runner-prompt.md:5-10`) makes the first deliverable the scenario table, contract, then test list for a design with state, and the usage and signature sketch otherwise; both are posted on the ticket by the orchestrator.
2. The same prompt carries the "refused with the tool's own message" cell and the rule that such a cell is cut only after the refusal was run and seen.
3. Ticket playbook step 6 (`template/.agents/skills/poteto-mode/playbooks/ticket.md:10`) names the artifact, its `## Testing decisions` / `## Design` home, the `Posted by the agent <date>` first line, the human's edit, the opt-in `/architect with checkpoint` stop, and the Spec brief.
4. `review-brief.sh:222-223` writes the whole ticket body to the brief, so the posted table reaches the Spec reviewer with no extra step.
5. Feature step 4, Bug fix step 3, Refactoring step 5 and Perf issue step 3 (patched and vendored copies) tell the writer to write the test from the table first, one assertion per cell, and to stop and report a cell it cannot implement.
6. `to-spec`'s Testing Decisions section names the table as the shape for stateful work, through `patches/mattpocock/to-spec/SKILL.md.patch` (context matches the pin at `research/1-matt-pocock/.../to-spec/SKILL.md:63`) and the vendored copy.
7. `SCENARIO-TABLE.md` is a sixth core document with a matching `CORE_DOCS` tuple, `INDEX.md` row (88 lines), glossary entry and slim project copy, so `/knowledge scenario table` finds it.
8. Both new patches sit in `patches/series` with headers that apply against the pinned upstreams.

## Would break

1. **The documented command replaces the ticket body instead of appending to it.** `gh issue edit N --body-file` overwrites the body with the file's contents. No step says to fetch the current body first (`gh issue view N --json body`), and `docs/agents/issue-tracker.md` documents `gh issue edit` only for labels and assignees. An agent that follows the line literally with a file holding the table wipes Problem, Decision and Acceptance criteria, and since `review-brief.sh` pastes the body as the spec, the spec goes with it.

```
before implementation the synthesized table is appended to the ticket's body under `## Testing decisions` with `gh issue edit N --body-file`
```

Documented step: `template/.agents/skills/poteto-mode/playbooks/ticket.md:10` (same sentence in `docs/knowledge/core/SCENARIO-TABLE.md:43`).
Result: the ticket body becomes the table alone; the criteria the review is judged against are gone.

2. **`build_knowledge.py`'s docstring still names four slim copies.** The diff adds the sixth core document to `CORE_DOCS`, which makes `build_core` copy five documents into `template/docs/factory918/`, but the file's own header still says four.

```
`docs/knowledge/core/*.md` are the six core documents. Edit directly, then run `python3 tools/build_knowledge.py`.
```

Documented step: `tools/build_knowledge.py:8`.
Result: a reader of the script is told `SCENARIO-TABLE.md` does not reach projects, when it does.

## Fails open

## Not asked for

hard findings: 2
