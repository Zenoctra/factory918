## Walk

1. **Design output.** The runner prompt and its patch require the table, contract, and ordered fixture assertions for stateful designs; stateless boundaries get caller usage and signatures.
   ```text
   the scenario table in the shape above, then the contract derived from it, then the test list
   ```
2. **Unsupported inputs.** The runner requires the tool's refusal and observed evidence before removing a cell.
   ```text
   such a cell is cut only after the refusal was run and seen
   ```
3. **Ticket record.** Ticket step 6 specifies the section, dated attribution, posting before implementation, optional checkpoint, and whole-body review transport. Issue-tracker documentation repeats the record format.
   ```text
   the table is appended to the ticket's body under `## Testing decisions`
   ```
4. **Implementation.** All four playbooks and patches carry the artifact, require tests first when it is a table, and stop writers at unimplementable cells.
   ```text
   one assertion per cell
   ```
5. **Planning.** The to-spec copy and registered patch name the scenario table in Testing Decisions.
   ```text
   names the table as the shape for stateful work
   ```
6. **Knowledge.** The new core page explains the shape and reproduces #42; the index, build registration, project copy, glossary, decision, and knowledge skill expose it.
   ```text
   reachable through `/knowledge scenario table`
   ```

## Would break

1. **Stateful local fixes can bypass the table.** Bug fix and Perf issue step 3 still require architect only for a function-boundary crossing or cross-cutting diff. A single-function fix introducing a state file can reach implementation without architect. Ticket step 6 attaches the new requirement to that architect step; delegation requires cell assertions only when an artifact is already a table. Require architect/table creation for stateful work even within one function.

   Documented step: “For anything with state, the scenario table below.”

   Result: A supported stateful fix can be implemented without the table or its tests.
   ```text
   When the change has state (a file it reads or writes, exit codes, rounds, or more than one actor) the architect step writes a scenario table before any code
   ```

## Fails open

## Not asked for

hard findings: 1
