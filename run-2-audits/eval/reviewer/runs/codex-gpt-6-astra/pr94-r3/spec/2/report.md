## Walk

1. **Post the complete artifact.** The Ticket playbook keeps the existing posting procedure and attribution, and now explicitly places every part of the table or usage sketch inside its single ticket section, using `###` headings.

   ```text
   The table is appended to this ticket's body under `## Testing decisions`, first line "Posted by the agent <date>".
   ```

2. **Keep artifact paths out of overlap checks.** The script's comment now states the section boundary explicitly. The fixture adds a backticked path under `### Contract` and retains the expected no-paths result, covering a nested artifact part without changing runtime behavior.

   ```text
   The whole artifact [...] stays inside that one section, its parts under `###` headings, because the skip ends at the next `## ` heading.
   ```

3. **Document the ticket shape consistently.** Both issue-tracker copies describe the same containment rule for the two design sections, matching the playbook.

   ```text
   Each section holds the whole artifact, with `###` headings for its parts, since the overlap check skips a section up to the next `## ` heading.
   ```

4. **Explain the historical example.** The core knowledge page and its generated counterpart distinguish #42's older heading structure from the rule for future artifacts, preserving the example while preventing its layout from contradicting the new instructions.

   ```text
   #42's record was written before this rule, so its table and contract sit under their own `## ` headings there. A table posted from now on keeps them under `###` inside the one section.
   ```

## Would break

## Fails open

## Not asked for

hard findings: 0
