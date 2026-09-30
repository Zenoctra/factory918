## Walk

1. `/to-spec` now names a scenario table in Testing Decisions for stateful work.
2. The Ticket playbook selects a content playbook; its architect runner prompt asks for a table, contract, and test list when that runner is used for a stateful design.
3. The runner prompt requires a tested refusal before removing a cell for an input outside the intended path.
4. Ticket step 6 describes appending the synthesized artifact to the issue body, with the required attribution line and optional checkpoint.
5. The four implementation playbooks tell writers who receive a table to write its assertions before implementation and report any cell they cannot implement.
6. `review-brief.sh` reads the whole issue body, so a posted table reaches the Spec reviewer.
7. `build_knowledge.py` includes the new core page in the index and slim project copy; `python3 tools/check_knowledge.py` reports `knowledge ok: 119 files`.
8. `/knowledge` searches the index and corpus, where the new page explains the table and reproduces the #42 example.

## Would break

1. **Stateful local work can bypass the table.** The new rule only runs through `architect`, but Feature step 2 permits `architect skipped: <reason>` unless the diff is cross-cutting. Bug fix, Refactoring, and Perf issue also call `architect` only for a function-boundary or cross-cutting change. A stateful change within one function can therefore reach delegation without any table or cell-based test.

   Documented step: `template/.agents/skills/poteto-mode/playbooks/ticket.md:10` says, “when the design adds state ... `architect`'s first deliverable is the scenario table,” while `template/.agents/skills/poteto-mode/playbooks/feature.md:6` allows an architect skip.

   Result: A permitted playbook path produces no first deliverable to append, and the writer's conditional “When it is a scenario table” instruction never applies.

   spec: criterion 3

   ```text
   - [ ] The Ticket playbook's architect step says that when a design adds state, the table is appended to the ticket's body under `## Testing decisions`, first line "Posted by the agent <date>" or "Approved by <name> <date>", before implementation; the human edits it if it is wrong; a stop before implementation is asked for only with "/architect with checkpoint". The Spec brief carries it because `review-brief.sh` pastes the ticket body, and the playbook says so.
   ```

2. **The posting step follows implementation in the Ticket sequence.** Ticket step 5 says to run the selected playbook's steps verbatim. Those playbooks delegate implementation, verify it, and open a PR before Ticket step 6, which contains the new posting instruction. Neither the Feature architect step nor `architect` Phase C places an orchestrator posting action between synthesis and implementation; Phase C instead says to proceed directly to implementation.

   Documented step: `template/.agents/skills/poteto-mode/playbooks/ticket.md:9` says “run that playbook's steps verbatim”; line 10 then says “the synthesized table is appended ... before implementation.”

   Result: Following the numbered steps in order posts the artifact after the writer has implemented and tested, so the writer's brief cannot carry the agreed table at the time it is needed.

   spec: criterion 3

   ```text
   - [ ] The Ticket playbook's architect step says that when a design adds state, the table is appended to the ticket's body under `## Testing decisions`, first line "Posted by the agent <date>" or "Approved by <name> <date>", before implementation; the human edits it if it is wrong; a stop before implementation is asked for only with "/architect with checkpoint". The Spec brief carries it because `review-brief.sh` pastes the ticket body, and the playbook says so.
   ```

3. **The teaching example leaves cells without outcomes.** The new knowledge page calls empty cells design holes and requires an assertion for each cell, but its reproduced #42 table has blank cells in rows 5 through 14 and cells such as row 3/C that give only `/ 1 / stop`. A reader following the page cannot derive the printed output or one assertion from those cells.

   Documented step: `docs/knowledge/core/SCENARIO-TABLE.md:29-37` requires the three facts in every cell and one assertion per cell; the example at `docs/knowledge/core/SCENARIO-TABLE.md:59-70` omits them.

   Result: The page reachable through `/knowledge scenario table` demonstrates the very incomplete table shape it says to prevent, so its example does not serve as a usable model for the required test list.

   spec: criterion 6

   ```text
   - [ ] The knowledge base has one page on the table (what it is, the shape, the #42 example), reachable through `/knowledge scenario table`.
   ```

## Fails open

## Not asked for

hard findings: 3
