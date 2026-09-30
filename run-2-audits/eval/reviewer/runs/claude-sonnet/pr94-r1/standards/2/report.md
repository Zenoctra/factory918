# Standards report

## Would break

None.

## Fails open

None.

## Standards breaches

None.

## Fix alongside

1. **Duplicated Code: the delegation-step sentence is quadrupled.** The same policy sentence is inserted verbatim into all four playbooks (bug-fix, feature, perf-issue, refactoring) and their four patch files, eight copies of one logical rule:

```
The brief carries the ticket's design artifact (Ticket step 6). When it is a scenario table, the writer writes the test from the table before the implementation, one assertion per cell in the table's order, and the commit order shows it; a writer that cannot implement a cell as written stops and reports the cell, and never fills it in.
```

This follows the pre-existing convention of restating the `architect`-skip clause identically across the same four files (SOURCES.md item 13), so a documented repo pattern arguably covers it, but it is still eight places to keep in sync if the rule ever changes. Fixed only if a would-break fix already touches one of these playbooks.

hard findings: 0
