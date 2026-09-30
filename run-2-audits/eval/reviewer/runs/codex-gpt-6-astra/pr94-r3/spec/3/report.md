## Walk

1. **Post the artifact before implementation.** Ticket step 6 retains the body read, append, and replacement sequence, the attribution line, and the stop on a failed write. The added nesting instruction applies to both supported artifacts.

   ```text
   The Ticket playbook's architect step says that when a design adds state, the table is appended to the ticket's body under `## Testing decisions` ... before implementation
   ```

2. **Keep the whole artifact within its section.** The playbook, both issue-tracker copies, and the source and generated scenario-table pages consistently require `###` headings for the artifact's parts.

   ```text
   Each section holds the whole artifact, with `###` headings for its parts, since the overlap check skips a section up to the next `## ` heading.
   ```

3. **Exclude artifact paths from overlap detection.** The script's comment now states the existing section boundary explicitly. The fixture adds a backticked path beneath `### Contract` and retains the expected no-path result, covering a nested artifact part alongside `## Design`. No executable parser behavior changes in this diff.

   ```text
   The step-1 check skips both sections, so a path a cell quotes does not count as a path the ticket names.
   ```

4. **Explain the historical example.** The scenario-table page and its generated copy identify #42's separate second-level headings as predating the new rule and direct future artifacts to use third-level headings within the section.

   ```text
   The knowledge base has one page on the table (what it is, the shape, the #42 example), reachable through `/knowledge scenario table`.
   ```

5. **Carry the artifact into review.** The posting and review instructions still require the complete ticket body in the Spec brief; the nesting clarification preserves that review surface.

   ```text
   The Spec brief carries it because `review-brief.sh` pastes the ticket body, and the playbook says so.
   ```

## Would break

## Fails open

## Not asked for

hard findings: 0
