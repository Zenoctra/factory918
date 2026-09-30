## Would break

1. **Local stateful changes can skip the table.** The new Bug fix rule still invokes `architect` only across a function boundary or for a cross-cutting diff. A fix within one function that reads a file or returns an exit code meets the table rule in `docs/knowledge/core/DECISIONS.md` P25, but can reach the writer without a table. The Feature, Refactoring, and Perf issue playbooks retain the same gap.

   Documented step: Ticket criterion 1 says the scenario table is the first deliverable "for any design with a file it reads or writes, exit codes, or more than one actor."

   Result: The writer implements the local stateful change without a posted table or its per-cell test list.

   spec: criterion 1

   ```diff
   +3. Plan the fix. If it crosses a function boundary, `architect` first; a cross-cutting diff (Ticket step 5) never skips it. Delegate implementation through provider dispatch using your configured bug-fix descriptor (default `codex:gpt-5.6-sol@max`) with `isolated-write`, a dedicated worktree, and a specific scope; review the diff. The brief carries the ticket's design artifact (Ticket step 6). When it is a scenario table, the writer writes the test from the table before the implementation, one assertion per cell in the table's order, and the commit order shows it; a writer that cannot implement a cell as written stops and reports the cell, and never fills it in.
   ```

2. **The ticket posts the design after the selected playbook has run.** `template/.agents/skills/poteto-mode/playbooks/ticket.md:5` says to run the selected playbook's steps verbatim. Those steps delegate implementation before Ticket step 6. The new step 6 says to post before implementation, but supplies no handoff before the selected playbook's delegation step. This conflicts with `docs/knowledge/core/DECISIONS.md` P25 and the Ticket playbook's own order.

   Documented step: Ticket criterion 3 says to append the table to the ticket "before implementation."

   Result: Following the numbered Ticket steps puts the issue edit after the writer has started, so the writer's brief and the review record can lack the table.

   spec: criterion 3

   ```diff
   +6. The spec's **Testing decisions** are the pre-agreed seams. `tdd` there, and nowhere the spec did not agree unless a criterion needs it. The selected playbook's architect step adds the ticket's own: when the design adds state (a file it reads or writes, exit codes, rounds, or more than one actor), `architect`'s first deliverable is the scenario table (its runner prompt gives the shape), and before implementation the synthesized table is appended to the ticket's body under `## Testing decisions` with `gh issue edit N --body-file`, first line `Posted by the agent <date>`, or `Approved by <name> <date>` when the human approved it first.
   ```

## Fails open

## Standards breaches

## Fix alongside

hard findings: 2
