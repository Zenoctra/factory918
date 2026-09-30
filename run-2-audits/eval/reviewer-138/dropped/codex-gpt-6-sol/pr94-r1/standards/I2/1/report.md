## Would break

1. **A stateful change can skip the table.** `docs/knowledge/core/DECISIONS.md` P25 requires a scenario table for a design with a file it reads or writes, exit codes, rounds, or more than one actor. The new Ticket step 6 makes the table depend on the selected playbook's `architect` step, while Feature step 2 still allows that step to be skipped for a change that is not cross-cutting. A single-function CLI change that writes a file can therefore proceed without a table.

   Documented step: Ticket acceptance criterion 1 says `architect`'s first deliverable is the table "for any design with a file it reads or writes, exit codes, or more than one actor."

   Result: A permitted `architect skipped: <reason>` leaves no design artifact for the writer to test or the reviewer to read.

   spec: criterion 1

   ```text
   template/.agents/skills/poteto-mode/playbooks/feature.md:6
   2. `architect` for parallel design exploration. Skipping stays as `architect skipped: <reason>`, not accepted for a cross-cutting diff (Ticket step 5); do not fold the design decision silently into implementation.

   template/.agents/skills/poteto-mode/playbooks/ticket.md:10
   The selected playbook's architect step adds the ticket's own: when the design adds state (a file it reads or writes, exit codes, rounds, or more than one actor), `architect`'s first deliverable is the scenario table (its runner prompt gives the shape), and before implementation the synthesized table is appended to the ticket's body under `## Testing decisions` with `gh issue edit N --body-file`, first line `Posted by the agent <date>`, or `Approved by <name> <date>` when the human approved it first.
   ```

2. **The ticket update follows implementation in the stated step order.** `docs/knowledge/core/DECISIONS.md` P25 requires posting the table before implementation. Ticket step 5 says to run the selected playbook's steps verbatim; each selected playbook delegates implementation before Ticket step 6. `architect/SKILL.md` Phase C also proceeds directly to Phase D, with no ticket edit between them. The new posting instruction sits in Ticket step 6 and the runner prompt sent to candidate designers, rather than at a gate before the writer starts.

   Documented step: Ticket acceptance criterion 3 says the table is appended to the ticket body under `## Testing decisions` "before implementation."

   Result: Following the playbook steps in order starts the writer before `gh issue edit N --body-file`; the writer's brief and any later Spec brief can lack the agreed table.

   spec: criterion 3

   ```text
   template/.agents/skills/poteto-mode/playbooks/ticket.md:10
   The selected playbook's architect step adds the ticket's own: when the design adds state (a file it reads or writes, exit codes, rounds, or more than one actor), `architect`'s first deliverable is the scenario table (its runner prompt gives the shape), and before implementation the synthesized table is appended to the ticket's body under `## Testing decisions` with `gh issue edit N --body-file`, first line `Posted by the agent <date>`, or `Approved by <name> <date>` when the human approved it first.

   template/.agents/skills/poteto-mode/playbooks/feature.md:12
   The brief carries the ticket's design artifact (Ticket step 6). When it is a scenario table, the writer writes the test from the table before the implementation, one assertion per cell in the table's order, and the commit order shows it; a writer that cannot implement a cell as written stops and reports the cell, and never fills it in.
   ```

## Fails open

## Standards breaches

## Fix alongside

hard findings: 2
