## Would break

1. **A stateful feature can skip the table.** `docs/knowledge/core/DECISIONS.md:93` (P25) requires a scenario table before implementation for any design with state. The changed Feature step bars skipping `architect` only for a cross-cutting diff. A single-file feature that writes a state file can still record `architect skipped: <reason>`. Ticket step 6 then has no synthesized table to post, and the writer's new table instruction does not apply.

   Documented step: Ticket acceptance criterion 3 says, "when a design adds state, the table is appended to the ticket's body under `## Testing decisions` ... before implementation."

   Result: A stateful, non-cross-cutting feature can proceed to implementation without a table on the ticket. The same gap applies to a local Bug fix, Refactoring, or Perf issue whose design stays within one function.

   spec: criterion 3

   ```diff
   +2. `architect` for parallel design exploration. Skipping stays as `architect skipped: <reason>`, not accepted for a cross-cutting diff (Ticket step 5); do not fold the design decision silently into implementation.
   +6. The spec's **Testing decisions** are the pre-agreed seams. `tdd` there, and nowhere the spec did not agree unless a criterion needs it. The selected playbook's architect step adds the ticket's own: when the design adds state (a file it reads or writes, exit codes, rounds, or more than one actor), `architect`'s first deliverable is the scenario table (its runner prompt gives the shape), and before implementation the synthesized table is appended to the ticket's body under `## Testing decisions` with `gh issue edit N --body-file`, first line `Posted by the agent <date>`, or `Approved by <name> <date>` when the human approved it first. When the design is code with no state that crosses a function boundary, the usage and signature sketch goes under `## Design` the same way. A prose change has no artifact beyond its criteria. Posting is the record: the human edits the ticket if the table is wrong, and a stop before implementation is asked for only with `/architect with checkpoint`. The Spec brief carries the table because `review-brief.sh` pastes the ticket body.
   ```

## Fails open

## Standards breaches

## Fix alongside

hard findings: 1
