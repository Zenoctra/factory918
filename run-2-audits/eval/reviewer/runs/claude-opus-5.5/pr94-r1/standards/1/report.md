# Standards review, ab47eb9

## Would break

## Fails open

## Standards breaches

## Fix alongside

1. **Duplicated Code / Shotgun Surgery: the writer rule is copied into four playbooks.** One sentence about the writer, the scenario table and the test is pasted word for word into Feature step 4, Bug fix step 3, Refactoring step 5 and Perf issue step 3. Each copy also has its own patch. Ticket step 6 already owns the artifact rule, so all four could point at it ("the writer follows Ticket step 6"). The rule would then live in one place and would change in one place.

```
+ The brief carries the ticket's design artifact (Ticket step 6). When it is a scenario table, the writer writes the test from the table before the implementation, one assertion per cell in the table's order, and the commit order shows it; a writer that cannot implement a cell as written stops and reports the cell, and never fills it in.
```

2. **Duplicated Code: the table's shape is defined in three places.** The runner prompt, the to-spec patch and `SCENARIO-TABLE.md` each define the shape. Each says situations go down the side, the input's shape goes across the top, and a cell holds what is printed, the exit code and the next step. P25 and the glossary restate it a fourth and fifth time. A later change to the cell format has to find every copy. The runner prompt and to-spec could name `SCENARIO-TABLE.md` ("The shape") as the definition and keep one line each.

```
+- For stateful work (a file read or written, exit codes, more than one actor), the shape is the scenario table: situations down the side, the shape of the input across the top, and in every cell what is printed, the exit code and what the caller does next.
```

Checked and clean:
- The "six core documents" and "119 files" counts are correct at this commit, and the regenerate command sits next to each.
- Every change to a vendored skill has a patch, a line in `series` and a line in `SOURCES.md` (items 13 to 15). `ticket.md` is the factory's own file (SOURCES item 2), so editing it directly is correct.
- `template/docs/factory918/` changes only through `build_knowledge.py`: the diff adds one `CORE_DOCS` tuple.
- The ledger line and the M0 finding each carry a date. The choice made in #89 is recorded as P25 under Provisional.

hard findings: 0
