## Would break

1. **Local stateful work can bypass the table.** `docs/knowledge/core/DECISIONS.md` P25 requires the architect step's scenario table for a design with a file, exit codes, rounds, or multiple actors. The new Ticket step 6 makes the table depend on the selected playbook's architect step, while Bug fix step 3, Refactoring step 3, and Perf issue step 3 invoke `architect` only for a function boundary or cross-cutting diff. A single-function change to file state can therefore proceed to implementation without a table on the ticket. Require `architect` when the design has state, regardless of those skip clauses.

   Documented step: ticket acceptance criterion 3, “when a design adds state, the table is appended to the ticket's body under `## Testing decisions` … before implementation.”

   Result: a local stateful fix follows its selected playbook, skips `architect`, and reaches implementation with no table to append or test from.

   spec: criterion 3

   ```diff
   +6. The spec's **Testing decisions** are the pre-agreed seams. `tdd` there, and nowhere the spec did not agree unless a criterion needs it. The selected playbook's architect step adds the ticket's own: when the design adds state (a file it reads or writes, exit codes, rounds, or more than one actor), `architect`'s first deliverable is the scenario table (its runner prompt gives the shape), and before implementation the synthesized table is appended to the ticket's body under `## Testing decisions` with `gh issue edit N --body-file`, first line `Posted by the agent <date>`, or `Approved by <name> <date>` when the human approved it first. When the design is code with no state that crosses a function boundary, the usage and signature sketch goes under `## Design` the same way. A prose change has no artifact beyond its criteria. Posting is the record: the human edits the ticket if the table is wrong, and a stop before implementation is asked for only with `/architect with checkpoint`. The Spec brief carries the table because `review-brief.sh` pastes the ticket body.
   ```

## Fails open

## Standards breaches

## Fix alongside

hard findings: 1
