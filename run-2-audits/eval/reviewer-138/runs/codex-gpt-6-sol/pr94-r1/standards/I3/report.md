## Would break

1. **A local stateful fix can skip the scenario table.** `docs/knowledge/core/DECISIONS.md` P25 requires the table for a design with a file, an exit code, rounds, or several actors. The changed Bug fix step still calls `architect` only when the fix crosses a function boundary or a cross-cutting path. A fix that adds an exit code inside one function can therefore reach the writer without a table. The Perf issue and Refactoring playbooks have the same condition.

   Documented step: `template/.agents/skills/poteto-mode/playbooks/ticket.md:10` says, "when the design adds state ... before implementation the synthesized table is appended to the ticket's body under `## Testing decisions`."

   Result: No architect step runs for that local fix, so there is no table to post or turn into tests before implementation.

   spec: criterion 3

   ```diff
   +3. Plan the fix. If it crosses a function boundary, `architect` first; a cross-cutting diff (Ticket step 5) never skips it. Delegate implementation through provider dispatch using your configured bug-fix descriptor (default `codex:gpt-5.6-sol@max`) with `isolated-write`, a dedicated worktree, and a specific scope; review the diff. The brief carries the ticket's design artifact (Ticket step 6). When it is a scenario table, the writer writes the test from the table before the implementation, one assertion per cell in the table's order, and the commit order shows it; a writer that cannot implement a cell as written stops and reports the cell, and never fills it in.
   ```

## Fails open

## Standards breaches

## Fix alongside

hard findings: 1
