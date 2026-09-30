# Standards report

## Would break

None.

## Fails open

None.

## Standards breaches

None.

## Fix alongside

1. **Duplicated Code: the writer-brief sentence repeats verbatim across four playbooks.** The sentence "The brief carries the ticket's design artifact (Ticket step 6). When it is a scenario table, the writer writes the test from the table before the implementation, one assertion per cell in the table's order, and the commit order shows it; a writer that cannot implement a cell as written stops and reports the cell, and never fills it in." is pasted identically into `bug-fix.md`, `feature.md`, `perf-issue.md`, and `refactoring.md` (each in both its `patches/pstack/poteto-mode/playbooks/*.md.patch` and its generated `template/.agents/skills/poteto-mode/playbooks/*.md` copy, eight occurrences total). The same shape already recurs for the pre-existing "architect first" sentence in three of the four files, so this compounds an existing duplication rather than introducing a new pattern.
```
+3. Plan the fix. If it crosses a function boundary, `architect` first; a cross-cutting diff (Ticket step 5) never skips it. ... review the diff. The brief carries the ticket's design artifact (Ticket step 6). When it is a scenario table, the writer writes the test from the table before the implementation, one assertion per cell in the table's order, and the commit order shows it; a writer that cannot implement a cell as written stops and reports the cell, and never fills it in.
```
Fixed only when a would-break fix already touches this code; it does not count toward hard findings. A shared reference (e.g. a line in `docs/agents/issue-tracker.md` or a short section in `ticket.md` that the four playbooks point to by name) would let one edit update all four instead of four synchronized pastes.

hard findings: 0
