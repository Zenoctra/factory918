## Walk

1. The patched architect runner prompt asks stateful design candidates for a scenario table first, then a contract and test list; stateless code crossing a function boundary gets a usage and signature sketch.
2. The runner prompt specifies the tool's own refusal message for inputs outside the intended path and requires observing that refusal before cutting a cell.
3. Ticket step 6 tells the orchestrator to append the synthesized artifact to the issue body before implementation, with a dated first line; `review-brief.sh` reads the whole issue body.
4. The four patched execution playbooks tell a writer who receives a table to write tests from its cells before implementation and report any cell that cannot be implemented.
5. The `to-spec` patch adds the scenario table to Testing Decisions for stateful work.
6. The knowledge build lists and copies a sixth core page, and the knowledge skill names it in the project fallback.

## Would break

1. **A stateful change can skip the table.** Bug fix and Perf issue invoke `architect` only when a fix crosses a function boundary or is cross cutting; Refactoring has the same gate, and Feature permits a recorded skip. A change confined to one function that reads a file or changes an exit code meets the ticket's state trigger but can reach delegation without running `architect`. Ticket step 6 depends on that architect step to produce the table, and each delegation clause acts only *when* a table is already in the brief.

   Documented step: Ticket acceptance criterion 1 requires the runner prompt's first deliverable for **any** design with a file read or written or exit codes; ticket acceptance criterion 3 requires the table on the ticket before implementation.

   Result: On this documented stateful path there is no table to post, no cell based test list, and no artifact in the review brief.

   spec: criterion 1

   ```text
   - [ ] `architect`'s runner prompt (through its patch) makes the first deliverable, for any design with a file it reads or writes, exit codes, or more than one actor, the scenario table in the shape above, then the contract derived from it, then the test list; for code with no state that crosses a function boundary, the usage and signature sketch it already asks for, posted on the ticket under `## Design` by the same rule as the table.
   ```

2. **The project knowledge fallback cannot start its lookup.** `template/.agents/skills/knowledge/SKILL.md:13` explicitly selects the project's `docs/factory918` when neither factory location is available, and the change adds `SCENARIO-TABLE.md` there. The skill's mandatory first step at line 17 still opens `$KB/INDEX.md`, but `template/docs/factory918` contains no `INDEX.md`. The fallback therefore stops before it can search or open the new page.

   Documented step: Ticket acceptance criterion 6 requires the page to be reachable through `/knowledge scenario table`.

   Result: On the documented project fallback, the first read targets a missing file; the command cannot reach the scenario table through its prescribed procedure.

   spec: criterion 6

   ```text
   - [ ] The knowledge base has one page on the table (what it is, the shape, the #42 example), reachable through `/knowledge scenario table`.
   ```

3. **The worked table leaves cells undecided.** `docs/knowledge/core/SCENARIO-TABLE.md:29-37` says every cell gives printed output, exit code, and caller action and that each cell yields an assertion. Its purported verbatim #42 example at lines 55-70 leaves multiple cells empty (for example row 5, columns B through E) and gives only `/ 1 / stop` for row 3, columns C and D. A reader using this page as the specified shape cannot derive one assertion from each of those cells.

   Documented step: Ticket acceptance criterion 6 requires one page containing both the table's shape and the #42 example; the ticket's “The table's shape” says “in every cell what is printed, the exit code and what the caller does next.”

   Result: The example demonstrates blank or partial cells precisely where the page says a design hole must be filled, so the advertised cell by cell test list cannot be produced from it.

   spec: criterion 6

   ```text
   - [ ] The knowledge base has one page on the table (what it is, the shape, the #42 example), reachable through `/knowledge scenario table`.
   ```

## Fails open

## Not asked for

hard findings: 3
