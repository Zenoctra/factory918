## Walk

1. AC1 (runner prompt first deliverable): `patches/pstack/architect/references/runner-prompt.md.patch` and the matching `template/.agents/skills/architect/references/runner-prompt.md` diff make the first deliverable a scenario table, then the contract, then the test list for a stateful design, else the usage/signature sketch, posted under `## Design` by the same rule.
2. AC2 (out-of-path cells): the same patch adds "a cell for an input outside the intended path reads 'refused with the tool's own message' and costs no code. Cut such a cell only after the refusal was run and seen."
3. AC3 (Ticket playbook step 6): `template/.agents/skills/poteto-mode/playbooks/ticket.md` step 6 adds the append-to-`## Testing decisions` / `## Design` rule, the "Posted by the agent `<date>`" line, human-edit-in-place, and the `/architect with checkpoint` opt-in stop; it also states the Spec brief carries it via `review-brief.sh`.
4. AC4 (delegation steps): `bug-fix.md`, `feature.md`, `perf-issue.md`, `refactoring.md` (patch and template copy, each) all add the identical sentence: writer builds the test from the table before implementation, one assertion per cell, stops and reports a cell it cannot implement, never fills it in.
5. AC5 (to-spec): `patches/mattpocock/to-spec/SKILL.md.patch` and `template/.agents/skills/to-spec/SKILL.md` both add the scenario-table bullet to Testing Decisions.
6. AC6 (knowledge page): `docs/knowledge/core/SCENARIO-TABLE.md` (new, 88 lines) plus `INDEX.md`, `GLOSSARY.md`, `tools/build_knowledge.py`, and the template's slim `SCENARIO-TABLE.md` copy are all added/updated consistently; `docs/agents/issue-tracker.md` and its template copy document the two new ticket sections.

## Would break

None found.

## Fails open

None found.

## Not asked for

None found.

hard findings: 0
