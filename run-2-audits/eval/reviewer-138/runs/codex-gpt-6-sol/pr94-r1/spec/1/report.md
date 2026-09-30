## Walk

1. `to-spec` now names a scenario table as the Testing Decisions shape for stateful work.
2. Architect candidate runners now put the table, contract, and test list first for stateful designs, or a usage and signature sketch first for stateless code across a function boundary.
3. The Ticket playbook directs the orchestrator to append that artifact to the ticket with the specified first line; `review-brief.sh` pastes the ticket body into the Spec brief.
4. Feature, Bug fix, Refactoring, and Perf issue now direct writers to test table cells before implementation and report cells they cannot implement.
5. The knowledge build indexes and copies the new scenario-table page, and `/knowledge` can find it in the installed corpus.
6. The page explains the shape, posting rule, refusal rule, and the #42 example; provenance patches add the same instructions to future syncs.

## Would break

1. **Architect can implement before posting the table.** Ticket step 5 runs the selected playbook verbatim, which invokes Architect. Architect's unchanged Phase C proceeds directly to Phase D implementation; Ticket step 6 comes afterward. The runner prompt tells candidates that the orchestrator posts the artifact, but the calling workflow has no pause between synthesis and implementation.

   Documented step: ticket criterion 3, “the table is appended to the ticket's body under `## Testing decisions` ... before implementation.”
   Result: Architect can write code before the artifact exists on the ticket, so the writer and reviewer do not inherit a preimplementation decision.
   spec: criterion 3

   ```text
   - [ ] The Ticket playbook's architect step says that when a design adds state, the table is appended to the ticket's body under `## Testing decisions` ... before implementation
   ```

2. **Stateful changes can skip the table.** Bug fix, Perf issue, and Refactoring invoke Architect only for a function-boundary crossing or a cross-cutting diff. A stateful change confined to one function takes their implementation path without the Architect deliverable, while Ticket step 6 derives the table only from Architect.

   Documented step: ticket criterion 3, “when a design adds state, the table is appended to the ticket's body ... before implementation.”
   Result: a single-function stateful fix can be implemented and reviewed with no table or cell-based test.
   spec: criterion 3

   ```text
   - [ ] The Ticket playbook's architect step says that when a design adds state, the table is appended to the ticket's body under `## Testing decisions` ... before implementation
   ```

3. **The worked table leaves cells undecided.** The page says every cell contains print, exit, and caller action and has an assertion, but its #42 table has empty cells in rows 5, 6, 8–11 and abbreviated cells such as ` / 2` in row 10E. The example therefore teaches a shape that cannot produce the promised one-assertion-per-cell test list.

   Documented step: `docs/knowledge/core/SCENARIO-TABLE.md:30-35`, “Three facts ... in every cell” and “no cell goes without an assertion.”
   Result: a reader copying the page's example leaves scenario outcomes and tests unspecified.
   spec: criterion 6

   ```text
   - [ ] The knowledge base has one page on the table (what it is, the shape, the #42 example), reachable through `/knowledge scenario table`.
   ```

## Fails open

## Not asked for

4. **Unrelated ledger incident.** The new 2026-09-22 line records abandoned explorer lanes; it does not explain the scenario table or implement a ticket criterion.

   ```text
   - [ ] The knowledge base has one page on the table (what it is, the shape, the #42 example), reachable through `/knowledge scenario table`.
   ```

hard findings: 3
