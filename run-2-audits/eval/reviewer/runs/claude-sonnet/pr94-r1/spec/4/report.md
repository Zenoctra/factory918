## Walk

1. `architect`'s runner prompt patch (`patches/pstack/architect/references/runner-prompt.md.patch`, mirrored in `template/.agents/skills/architect/references/runner-prompt.md`) makes the first deliverable conditional: with state, a scenario table then the contract then the test list, in that order; without state crossing a function boundary, the usage-and-signature sketch; the orchestrator then appends the table under `## Testing decisions` or the sketch under `## Design`.
2. The same patch states a cell for an input outside the intended path reads "refused with the tool's own message" and costs no code, and is cut only after the refusal was run and seen.
3. `template/.agents/skills/poteto-mode/playbooks/ticket.md` step 6 (and the mirroring patch) says the architect step's table or sketch is appended before implementation with `gh issue edit N --body-file`, first line `Posted by the agent <date>` or `Approved by <name> <date>`, the human edits it, a stop is asked for only with `/architect with checkpoint`, and the Spec brief carries it because `review-brief.sh` pastes the ticket body.
4. The Feature (step 4), Bug fix (step 3), Refactoring (step 5) and Perf issue (step 3) playbook patches each add: the writer writes the test from the table before implementation, one assertion per cell in the table's order, and a writer that cannot implement a cell as written stops and reports it, never filling it in.
5. `to-spec/SKILL.md`'s patch and the template copy add a Testing Decisions bullet naming the scenario table as the shape for stateful work.
6. `docs/knowledge/core/SCENARIO-TABLE.md` (new, indexed in `docs/knowledge/INDEX.md` and cross-referenced from `GLOSSARY.md`'s new "Scenario table" entry) and its `template/docs/factory918/` copy give the page a person and an agent can read; `tools/build_knowledge.py`'s `CORE_DOCS` gains the sixth tuple so `build_knowledge.py` and `apply` carry it; `docs/agents/issue-tracker.md` documents the two possible extra sections on a ticket.

## Would break

None.

## Fails open

None.

## Not asked for

None.

hard findings: 0
