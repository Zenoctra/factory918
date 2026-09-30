## Walk

1. `architect/references/runner-prompt.md.patch` makes the first deliverable, for a design with state, a scenario table then a contract then a test list, else the usage/signature sketch, and has the orchestrator post the synthesized deliverable on the ticket.
2. The runner prompt says a cell for an input outside the intended path reads "refused with the tool's own message," costs no code, and is cut only after the refusal was run and seen.
3. `ticket.md` step 6 says the table is appended under `## Testing decisions` before implementation, first line "Posted by the agent \<date\>" or "Approved by \<name\> \<date\>," the human edits it, a stop is asked for only with "/architect with checkpoint," and the Spec brief carries it because `review-brief.sh` pastes the ticket body.
4. Feature, Bug fix, Refactoring and Perf issue playbooks' delegation steps (via their patches) say the test is written from the table before implementation, one assertion per cell, and a writer who cannot implement a cell stops and reports it rather than filling it in.
5. `to-spec/SKILL.md`'s Testing Decisions section (patch and template copy, identical text) names the scenario table as the shape for stateful work.
6. `docs/knowledge/core/SCENARIO-TABLE.md` is added as a sixth core document, indexed in `INDEX.md`, glossed in `GLOSSARY.md`, registered in `tools/build_knowledge.py`'s `CORE_DOCS`, and copied to `template/docs/factory918/SCENARIO-TABLE.md`, reachable through `/knowledge`.

## Would break

None found.

## Fails open

None found.

## Not asked for

1. **A ledger entry unrelated to the ticket's subject.** `docs/agents/ledger.md` gains a 2026-09-22 line about an agent ending its turn while explorer lanes were still reading and losing their worktree ("drain every lane before the turn ends"). Nothing in the ticket's Problem, Decision, or acceptance criteria concerns lane draining or turn-ending discipline; it reads as a surprise from a different session folded into this diff rather than the #89 design-artifact work.
   ```
   2026-09-22 | fable | ended its turn while two explorer lanes were still reading, the harness removed its worktree, and both lanes died without a report | drain every lane before the turn ends; a lane with no worktree cannot report
   ```

hard findings: 0
