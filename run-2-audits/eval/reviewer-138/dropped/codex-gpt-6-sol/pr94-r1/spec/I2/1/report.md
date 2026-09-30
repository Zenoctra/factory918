## Walk

1. `to-spec` puts the scenario-table shape in Testing Decisions for work with state.
2. The Ticket playbook selects a matching playbook, which invokes `architect` for the relevant design before delegating implementation.
3. The architect runner prompt asks each candidate for a scenario table, its contract, and a cell-by-cell test list, or a usage and signature sketch for stateless code.
4. Ticket step 6 instructs the orchestrator to append the synthesized artifact to the issue body before implementation; `review-brief.sh` later copies that body into the Spec brief.
5. The four implementation playbooks tell the writer to test the table before code, one assertion per cell, and to report any cell the writer cannot implement.
6. The knowledge builder indexes the new core page and copies it into the project's slim `docs/factory918`; the knowledge skill selects a corpus for `/knowledge scenario table`.

## Would break

1. **The Ticket playbook reaches implementation before its posting step.** Step 5 says to run the selected playbook verbatim, and each selected playbook delegates implementation inside that run. Step 6 is where the new posting instruction lives. The architect skill's Phase C also proceeds directly to implementation. Following the numbered path therefore reaches code before the table or sketch is appended to the ticket.

   Documented step: `template/.agents/skills/poteto-mode/playbooks/ticket.md:9` says “run that playbook's steps verbatim from step 1”; line 10 says “before implementation the synthesized table is appended.”

   Result: The writer can start implementation with the original issue body; the promised pre-implementation record and test contract are absent.

   spec: criterion 3

   ```text
   - [ ] The Ticket playbook's architect step says that when a design adds state, the table is appended to the ticket's body under `## Testing decisions`, first line "Posted by the agent <date>" or "Approved by <name> <date>", before implementation; the human edits it if it is wrong; a stop before implementation is asked for only with "/architect with checkpoint". The Spec brief carries it because `review-brief.sh` pastes the ticket body, and the playbook says so.
   ```

2. **The architect's synthesis path does not require the table.** The patch changes only the candidate runner prompt. The architect skill still tells Arena to synthesize a package shaped by `rationale-template.md`, with caller usage first and no table, contract, or cell test list in that template. The instruction to append a *synthesized* first deliverable can therefore have no table to append even when candidates supplied one.

   Documented step: `template/.agents/skills/architect/SKILL.md:32` specifies the candidate package and line 42 says Arena returns one synthesized design package; `template/.agents/skills/architect/references/runner-prompt.md:10` directs the orchestrator to append its first deliverable.

   Result: The documented synthesis can discard the candidate tables and leave the ticket without the table, contract, and test list required for a stateful design.

   spec: criterion 1

   ```text
   - [ ] `architect`'s runner prompt (through its patch) makes the first deliverable, for any design with a file it reads or writes, exit codes, or more than one actor, the scenario table in the shape above, then the contract derived from it, then the test list; for code with no state that crosses a function boundary, the usage and signature sketch it already asks for, posted on the ticket under `## Design` by the same rule as the table.
   ```

3. **The project's documented knowledge fallback cannot open its index.** The changed knowledge skill explicitly offers the project's slim `docs/factory918` as a corpus containing the scenario table, then requires `$KB/INDEX.md` as its first read. The builder copies only core documents into that slim directory, and `template/docs/factory918/INDEX.md` does not exist.

   Documented step: `template/.agents/skills/knowledge/SKILL.md:13` selects the project fallback; line 17 says “Read `$KB/INDEX.md` whole.”

   Result: On the documented fallback path, `/knowledge scenario table` stops at a missing index instead of reaching the new page.

   spec: criterion 6

   ```text
   - [ ] The knowledge base has one page on the table (what it is, the shape, the #42 example), reachable through `/knowledge scenario table`.
   ```

4. **The worked table contradicts the page's cell rule.** The page says every cell states output, exit code, and the caller's next action, with one assertion per cell. Its verbatim #42 example leaves 28 cells blank; other cells say only `/ 1 / stop`, `/ 2`, or `n/a`. Its legend also says exit 0 always ends with `base:`, while the `--diff` column has exit-0 cases that print nothing.

   Documented step: `template/docs/factory918/SCENARIO-TABLE.md:21` says “Three facts ... in every cell”; line 26 says “one assertion per cell”; lines 46–61 present the example.

   Result: An agent using the page as the example can leave situations undecided while believing the table and test list are complete—the design hole this rule is meant to expose.

   spec: criterion 6

   ```text
   - [ ] The knowledge base has one page on the table (what it is, the shape, the #42 example), reachable through `/knowledge scenario table`.
   ```

## Fails open

## Not asked for

hard findings: 4
