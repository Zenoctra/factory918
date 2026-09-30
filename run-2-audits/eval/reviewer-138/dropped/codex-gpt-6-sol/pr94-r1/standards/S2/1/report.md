## Would break

1. **Local stateful changes can skip the table.** `docs/knowledge/core/SCENARIO-TABLE.md:12` says the table comes before any code with state, and `docs/knowledge/core/DECISIONS.md:93` (P25) makes it the architect step's first deliverable. Ticket step 6 delegates that rule to the selected playbook's architect step, but Bug fix still invokes `architect` only for a function-boundary or cross-cutting change. A fix that adds a file write or changes an exit code inside one function takes neither route.

   Documented step: Ticket acceptance criterion 3 says, "when a design adds state, the table is appended to the ticket's body under `## Testing decisions` ... before implementation."

   Result: The selected playbook delegates implementation without running `architect`, so no table is posted and the writer has no cells to test before the fix.

   spec: criterion 3

   ```diff
   +6. The spec's **Testing decisions** are the pre-agreed seams. `tdd` there, and nowhere the spec did not agree unless a criterion needs it. The selected playbook's architect step adds the ticket's own: when the design adds state (a file it reads or writes, exit codes, rounds, or more than one actor), `architect`'s first deliverable is the scenario table (its runner prompt gives the shape), and before implementation the synthesized table is appended to the ticket's body under `## Testing decisions` with `gh issue edit N --body-file`, first line `Posted by the agent <date>`, or `Approved by <name> <date>` when the human approved it first. When the design is code with no state that crosses a function boundary, the usage and signature sketch goes under `## Design` the same way. A prose change has no artifact beyond its criteria. Posting is the record: the human edits the ticket if the table is wrong, and a stop before implementation is asked for only with `/architect with checkpoint`. The Spec brief carries the table because `review-brief.sh` pastes the ticket body.
   +3. Plan the fix. If it crosses a function boundary, `architect` first; a cross-cutting diff (Ticket step 5) never skips it. Delegate implementation through provider dispatch using your configured bug-fix descriptor (default `codex:gpt-5.6-sol@max`) with `isolated-write`, a dedicated worktree, and a specific scope; review the diff. The brief carries the ticket's design artifact (Ticket step 6). When it is a scenario table, the writer writes the test from the table before the implementation, one assertion per cell in the table's order, and the commit order shows it; a writer that cannot implement a cell as written stops and reports the cell, and never fills it in.
   ```

## Fails open

## Standards breaches

## Fix alongside

hard findings: 1
