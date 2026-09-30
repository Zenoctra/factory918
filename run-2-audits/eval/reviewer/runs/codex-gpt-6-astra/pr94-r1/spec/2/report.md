## Walk

1. **Design output.** The runner patch requests the table, contract and fixture-based test list for stateful designs; stateless boundaries get usage before signatures.
   ```text
   the scenario table in the shape above, then the contract derived from it, then the test list
   ```
2. **Unsupported inputs.** The runner requires the tool's refusal and observed evidence before cutting a cell.
   ```text
   such a cell is cut only after the refusal was run and seen
   ```
3. **Ticket record.** Ticket step 6 specifies dated posting, both section names, optional checkpointing and ticket-body inclusion in the review brief.
   ```text
   the table is appended to the ticket's body under `## Testing decisions`
   ```
4. **Implementation.** All four playbooks and their patches carry the artifact, require tests first and tell blocked writers to report the cell.
   ```text
   one assertion per cell
   ```
5. **Planning.** The to-spec patch names the table as the stateful Testing decisions format.
   ```text
   names the table as the shape for stateful work
   ```
6. **Knowledge.** The core page includes the shape and #42 example; the build tuple, index, glossary and project copy expose it through the knowledge corpus.
   ```text
   reachable through `/knowledge scenario table`
   ```

## Would break

1. **Stateful work can still skip the artifact-producing step.** Ticket step 6 attaches table creation to the selected playbook's architect step, but Bug fix and Perf issue still invoke architect only across a function boundary; Feature still allows skipping it for non-cross-cutting work. Route stateful work through architect regardless of those skip rules.
   ```text
   For anything with state, the scenario table below.
   ```
   Documented step: Ticket #89, “For anything with state, the scenario table below.”
   Result: A single-function bug fix that adds file state can proceed directly to implementation without architect producing a table; the writer's new requirement applies only “When it is a scenario table.”

## Fails open

## Not asked for

hard findings: 1
