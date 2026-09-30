# Standards review, ab47eb9

## Would break

## Fails open

## Standards breaches

## Fix alongside

1. **Duplicated Code: one sentence added four times.** The same two sentences are appended to the delegation step of Feature, Bug fix, Refactoring and Perf issue, in the template and again in each patch. Eight copies must now change together. A single line pointing at Ticket step 6, or at `SCENARIO-TABLE.md`, would hold the rule once.

```
+... review the diff. The brief carries the ticket's design artifact (Ticket step 6). When it is a scenario table, the writer writes the test from the table before the implementation, one assertion per cell in the table's order, and the commit order shows it; a writer that cannot implement a cell as written stops and reports the cell, and never fills it in.
```

2. **Shotgun Surgery: the table's shape is restated in six places.** The shape definition (situations down the side, input across the top, printed / exit / next in each cell, one assertion per cell) appears in `runner-prompt.md`, `to-spec/SKILL.md`, Ticket step 6, `SCENARIO-TABLE.md`, the GLOSSARY entry and P25. A later change to the cell shape means editing all six, plus two patches. The runner prompt and `SCENARIO-TABLE.md` could hold the shape, and the others could name the page.

```
+- For stateful work (a file read or written, exit codes, more than one actor), the shape is the scenario table: situations down the side, the shape of the input across the top, and in every cell what is printed, the exit code and what the caller does next. The table is the test list, one assertion per cell.
```

3. **One Diátaxis mode per file (CODING_STANDARDS.md, Markdown), judgement call.** `SCENARIO-TABLE.md` reads mostly as explanation ("Why", "What it is"). "The shape" and "Where it goes" are reference and how-to content that the playbooks and runner prompt already state. This is borderline because an explanation page can describe its subject.

```
+## The shape
+
+The table has four parts and the test list follows from them.
```

hard findings: 0
