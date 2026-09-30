## Walk

1. **Design order.** Architect Phase B now puts the scenario table, contract and test list first for stateful designs; its new patch is registered in `patches/series`.

   ```text
   the scenario table in the shape above, then the contract derived from it, then the test list
   ```

2. **Planning shape.** The to-spec copy and patch agree that scenario tables are decisions permitted by the restriction on paths and snippets.

   ```text
   `to-spec`'s Testing decisions section (through its patch or the factory's copy) names the table as the shape for stateful work.
   ```

3. **Post the artifact.** Ticket step 6 reads the current body, appends the dated section and writes the whole body back. A failed write stops implementation; the checkpoint remains opt-in.

   ```text
   the table is appended to the ticket's body under `## Testing decisions`
   ```

4. **Other artifacts.** Stateless sketches use the same posting procedure under Design; prose retains its criteria.

   ```text
   the usage and signature sketch goes under `## Design` the same way.
   ```

5. **Overlap check.** The awk filter skips Diff, Testing decisions and Design until another level-two heading. The added fixture checks that both artifact sections contribute no paths.

   ```text
   The step-1 check skips both sections, so a path a cell quotes does not count as a path the ticket names.
   ```

6. **Implementation and review handoff.** The scenario-table documentation retains the ticket-body handoff to reviewers and test-before-implementation instruction, including stopping on an unimplementable cell.

   ```text
   The writer gets the table in its brief and writes the test from it before the implementation
   ```

7. **Find the guidance.** Both manual copies now list SCENARIO-TABLE among the five project documents; the index count and build-script description are updated consistently.

   ```text
   a project carries only the first five, under `docs/factory918/`.
   ```

## Would break

## Fails open

## Not asked for

hard findings: 0
