## Walk

1. **Choose the design artifact.** Architect Phase B and its registered patch now put the scenario table, contract and test list first for stateful designs, retaining the usage sketch for stateless designs.

   ```text
   the scenario table in the shape above, then the contract derived from it, then the test list
   ```

2. **Plan stateful testing.** The to-spec bullet and its patch retain the table shape and clarify its exemption from the paths-and-snippets restriction.

   ```text
   `to-spec`'s Testing decisions section (through its patch or the factory's copy) names the table as the shape for stateful work.
   ```

3. **Publish before implementation.** Ticket step 6 reads the current body, appends the dated artifact, writes the whole body back, and stops on a failed write. The same procedure covers the stateless sketch; checkpointing remains opt-in.

   ```text
   the table is appended to the ticket's body under `## Testing decisions`
   ```

4. **Carry the artifact into implementation and review.** The displayed knowledge section retains ticket-body inclusion in the Spec brief, tests before implementation, and stopping when a cell cannot be implemented as written.

   ```text
   The writer gets the table in its brief and writes the test from it before the implementation
   ```

5. **Check overlap after posting.** The awk filter skips Diff, Testing decisions and Design until the next other level-two heading. The added fixture checks that artifact-only paths yield no named paths and the main base.

   ```text
   The step-1 check skips both sections, so a path a cell quotes does not count as a path the ticket names.
   ```

6. **Find the project documentation.** The manual adds SCENARIO-TABLE as the fifth project document; its generated copy, index count and build-script description agree with that change.

   ```text
   a project carries only the first five, under `docs/factory918/`.
   ```

## Would break

## Fails open

## Not asked for

hard findings: 0
