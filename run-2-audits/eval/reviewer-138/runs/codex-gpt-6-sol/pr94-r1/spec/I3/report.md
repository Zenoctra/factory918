## Walk

1. `to-spec` now names the scenario table as the Testing decisions shape for stateful work.
2. The architect runner prompt asks candidates for the table first, then its contract and test list; stateless code crossing a function boundary gets a usage and signature sketch.
3. Ticket step 6 directs the orchestrator to append the synthesized artifact to the issue body before implementation, where `review-brief.sh` later reads it.
4. The four execution playbooks tell the writer to test each table cell before implementation and to report any cell it cannot implement.
5. The core knowledge page describes the table, its placement, and the #42 example; the build lists it in the factory index and copies it into the slim project docs.
6. The `/knowledge` skill selects the installed factory corpus or the slim project docs, then requires an index before looking up a page.

## Would break

1. **Stateful work can skip the table.** Bug fix, Refactoring, and Perf issue call `architect` only for a function-boundary or cross-cutting change. A local change with exit codes, file state, or rounds can take their documented path without an architect step, so Ticket step 6 has no table to post and the writer has no cells to test.

   Documented step: Ticket acceptance criterion 3 requires the table when a design adds state; `template/.agents/skills/poteto-mode/playbooks/bug-fix.md:9` makes `architect` conditional.

   Result: The ticket proceeds to implementation without the required `## Testing decisions` artifact.

   spec: criterion 3

   ```text
   The Ticket playbook's architect step says that when a design adds state, the table is appended to the ticket's body under `## Testing decisions`, first line "Posted by the agent <date>" or "Approved by <name> <date>", before implementation; the human edits it if it is wrong; a stop before implementation is asked for only with "/architect with checkpoint". The Spec brief carries it because `review-brief.sh` pastes the ticket body, and the playbook says so.
   ```

2. **The project-local knowledge path cannot open the page.** The updated knowledge skill advertises `docs/factory918` as its fallback corpus, but its first procedure step requires `$KB/INDEX.md`. The slim copy contains `SCENARIO-TABLE.md` and no `INDEX.md`.

   Documented step: `template/.agents/skills/knowledge/SKILL.md:13` selects the slim fallback; line 17 requires reading its index.

   Result: `/knowledge scenario table` fails at the first step in an applied project without an installed factory corpus, despite the new page being present.

   spec: criterion 6

   ```text
   The knowledge base has one page on the table (what it is, the shape, the #42 example), reachable through `/knowledge scenario table`.
   ```

## Fails open

## Not asked for

hard findings: 2
