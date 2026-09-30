## Walk

1. `/to-spec` now tells a planner to put a scenario table in Testing Decisions for stateful work.
2. Ticket step 5 selects a playbook; its architect runner prompt asks for the scenario table first, followed by a contract and a test list, or a usage and signature sketch for stateless code crossing a function boundary.
3. The runner prompt tells the designer to keep an outside-path cell as a refusal and to remove it only after observing the tool refuse it.
4. Ticket step 6 tells the orchestrator to append the synthesized artifact to the issue body before implementation, with a dated first line; `review-brief.sh` later copies that body into the Spec brief.
5. The four selected playbooks tell a writer with a table to write the tests before implementation, with one assertion per cell, and to report a cell it cannot implement.
6. `build_knowledge.py` copies the new core page into the project's slim knowledge directory, while the knowledge skill offers a full-install path and a project-local fallback for `/knowledge scenario table`.
7. The new knowledge page defines the shape and prints the #42 table as its worked example.

## Would break

1. **The posting gate follows implementation.** Ticket step 5 says to run the selected playbook verbatim, including architect and delegation; step 6 is the first Ticket step that posts the artifact. Architect's own Phase C says to proceed directly to implementation, and its Phase D implements the sketch. The runner prompt tells the orchestrator to post first, but it is passed to candidate runners and no orchestrator-facing phase inserts the issue edit between synthesis and implementation. A literal Feature or Bug fix run can therefore send the writer a brief before the table exists on the ticket and post the table only after code is written.

   Documented step: Ticket criterion 3 requires the table on the ticket before implementation; criterion 4 requires the writer to test from that table.
   Result: Ticket step 5 and architect Phase C/D advance through implementation before Ticket step 6 edits the issue; the promised preimplementation record and writer input are absent at the point they are needed (`template/.agents/skills/poteto-mode/playbooks/ticket.md:9-10`, `template/.agents/skills/architect/SKILL.md:44-56`).
   spec: criterion 3

   ```text
   - [ ] The Ticket playbook's architect step says that when a design adds state, the table is appended to the ticket's body under `## Testing decisions`, first line "Posted by the agent <date>" or "Approved by <name> <date>", before implementation; the human edits it if it is wrong; a stop before implementation is asked for only with "/architect with checkpoint". The Spec brief carries it because `review-brief.sh` pastes the ticket body, and the playbook says so.
   ```

2. **The project-local knowledge path has no index.** The changed knowledge skill explicitly offers `docs/factory918` as its fallback directory, then requires `$KB/INDEX.md` as its first lookup step. `build_knowledge.py` writes the index only to `docs/knowledge/INDEX.md`; the slim directory copied by `factory918 apply` contains the five core pages and no index. A project using the documented fallback cannot complete `/knowledge scenario table` by following the skill.

   Documented step: `template/.agents/skills/knowledge/SKILL.md:13-17` names the project-local fallback and requires reading its index first.
   Result: `template/docs/factory918/INDEX.md` does not exist, so the first required read fails before the new page can be found.
   spec: criterion 6

   ```text
   - [ ] The knowledge base has one page on the table (what it is, the shape, the #42 example), reachable through `/knowledge scenario table`.
   ```

3. **The worked table leaves cells empty.** The page says every cell contains printout, exit code, and caller action and that every cell yields one assertion. Its #42 example has blank cells across rows 5, 6, 8, and 9, and rows 10 and 11 omit outcomes for several columns. The page presents this as the verbatim model without explaining how those blanks are covered by a shared outcome, so a writer using the example can produce a table with undecided situations and no corresponding assertions.

   Documented step: `template/docs/factory918/SCENARIO-TABLE.md:19-26` requires three facts and an assertion for every cell; the example follows at lines 46-61.
   Result: the displayed Markdown table includes empty cells, so the worked shape does not meet its own rule or the ticket's stated table shape.
   spec: criterion 6

   ```text
   - [ ] The knowledge base has one page on the table (what it is, the shape, the #42 example), reachable through `/knowledge scenario table`.
   ```

## Fails open

## Not asked for

hard findings: 3
