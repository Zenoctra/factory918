## Walk

1. **Choose the design artifact.** Architect Phase B now explicitly opens stateful packages with the table, contract and test list. Its vendored copy and registered patch agree; stateless packages retain the usage sketch.

   ```text
   the scenario table in the shape above, then the contract derived from it, then the test list
   ```

2. **Plan stateful tests.** The to-spec bullet retains the table shape and one assertion per cell, and clarifies that the rule about paths and snippets permits this artifact. The patch matches the skill.

   ```text
   `to-spec`'s Testing decisions section (through its patch or the factory's copy) names the table as the shape for stateful work.
   ```

3. **Post before implementation.** Ticket step 6 reads the current body, appends the dated section and writes the whole body back. A failed write stops implementation. The same procedure covers the stateless sketch; the checkpoint remains opt-in.

   ```text
   the table is appended to the ticket's body under `## Testing decisions`
   ```

4. **Check overlap.** The awk filter excludes all three named sections until another level-two heading. The added fixture covers tokens in both artifact sections; subsequent sections resume normal matching.

   ```text
   its `## Diff`, `## Testing decisions` and `## Design` sections excluded
   ```

5. **Carry the artifact into review.** The updated instructions preserve the explanation that the whole ticket body reaches the Spec brief, including the appended artifact.

   ```text
   The Spec brief carries it because `review-brief.sh` pastes the ticket body, and the playbook says so.
   ```

6. **Find the project documentation.** Both manual copies now list the scenario-table page as the fifth project document. The build-script description excludes CONVERSATION-DIGEST, and the index reflects the added manual line.

   ```text
   a project carries only the first five, under `docs/factory918/`.
   ```

## Would break

## Fails open

## Not asked for

hard findings: 0
