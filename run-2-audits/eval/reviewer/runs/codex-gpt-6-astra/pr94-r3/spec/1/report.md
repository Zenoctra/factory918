## Walk

1. **Post the artifact before implementation.** The Ticket playbook retains the body-replacement procedure, attribution line, and stop on a failed write. Its added instruction keeps every artifact part inside the designated ticket section.

   ```text
   The table is appended to the ticket's body under `## Testing decisions`, first line "Posted by the agent <date>" or "Approved by <name> <date>", before implementation.
   ```

2. **Nest the artifact's parts.** The playbook explicitly covers the legend, table, contract, test list, usage, and signatures. Both issue-tracker copies state the same heading rule.

   ```text
   Each section holds the whole artifact, with `###` headings for its parts, since the overlap check skips a section up to the next `## ` heading.
   ```

3. **Exclude artifact paths from overlap detection.** The script change documents the existing section boundary without changing executable behavior. The fixture adds a backticked path beneath `### Contract` and retains the expectation of no named paths or overlap.

   ```text
   The step-1 check skips both sections, so a path a cell quotes does not count as a path the ticket names.
   ```

4. **Explain the historical example.** The core knowledge page and its generated counterpart distinguish #42's older heading structure from the rule for newly posted artifacts.

   ```text
   #42's record was written before this rule, so its table and contract sit under their own `## ` headings there. A table posted from now on keeps them under `###` inside the one section.
   ```

## Would break

## Fails open

## Not asked for

hard findings: 0
