## Walk

1. **Design deliverables.** The patched runner requests table, contract, and fixture-specific assertions for stateful designs; stateless boundaries get usage before signatures.

   ```text
   the scenario table in the shape above, then the contract derived from it, then the test list
   ```

2. **Unsupported inputs.** The runner requires the tool's refusal and observed evidence before cutting a cell.

   ```text
   such a cell is cut only after the refusal was run and seen
   ```

3. **Ticket record.** Ticket step 6 specifies dated posting before implementation, human edits, opt-in checkpoints, and inclusion through the ticket body in the review brief. Both issue-tracker copies document the sections.

   ```text
   the table is appended to the ticket's body under `## Testing decisions`
   ```

4. **Implementation.** All four playbooks and their patches carry the artifact, require tests first, and stop writers at an unimplementable cell.

   ```text
   the test is written from the table before the implementation, one assertion per cell
   ```

5. **Planning.** The to-spec patch names the table as the stateful Testing Decisions format.

   ```text
   names the table as the shape for stateful work
   ```

6. **Knowledge.** The sixth core document explains the format and reproduces #42; the build tuple, index, glossary, decision, generated project copy, and knowledge corpus description include it.

   ```text
   The knowledge base has one page on the table (what it is, the shape, the #42 example)
   ```

## Would break

1. **Stateful work can still skip the table.** Bug fix and Perf issue step 3 invoke architect only across function boundaries; Feature step 2 still permits skipping for non-cross-cutting work. The new delegation clauses apply only when the artifact is a table.

   ```text
   For anything with state, the scenario table below.
   ```

   Documented step: "when a design adds state, the table is appended to the ticket's body" before implementation.

   Result: A file-handling or exit-code change confined to one function can proceed without architect, a posted table, or cell-based tests. The architect trigger must also cover stateful designs.

## Fails open

## Not asked for

hard findings: 1
