# Standards review report

## Would break

None.

## Fails open

None.

## Standards breaches

None.

## Fix alongside

1. **Shotgun Surgery: the design-artifact sentence is pasted identically into four playbooks.** One logical change (wiring "the brief carries the ticket's design artifact" into the delegate step) forced the same sentence into `bug-fix.md`, `feature.md`, `perf-issue.md`, and `refactoring.md` (via their patches). A future wording fix to this rule needs four synchronized edits with nothing to catch a missed one.
```
+3. Plan the fix. If it crosses a function boundary, `architect` first; a cross-cutting diff (Ticket step 5) never skips it. ... The brief carries the ticket's design artifact (Ticket step 6). When it is a scenario table, the writer writes the test from the table before the implementation, one assertion per cell in the table's order, and the commit order shows it; a writer that cannot implement a cell as written stops and reports the cell, and never fills it in.
```
(same sentence repeated verbatim in `patches/pstack/poteto-mode/playbooks/feature.md.patch`, `perf-issue.md.patch`, `refactoring.md.patch`)

2. **`tools/build_knowledge.py`'s module docstring is now stale.** The docstring still names only "PHILOSOPHY, MANUAL, DECISIONS and GLOSSARY" as the files copied into `template/docs/factory918/`, but `build_core` derives that list from `CORE_DOCS` (minus `CONVERSATION-DIGEST.md`), which this diff extends with `SCENARIO-TABLE.md` — and the diff does add `template/docs/factory918/SCENARIO-TABLE.md`. The code is correct; the comment a future reader trusts is not.
```
    docs/knowledge/core/*.md                 HAND-MAINTAINED. Edit these files directly. This script only
                                           refreshes the header line and the mini-TOC of each one in place,
                                           then copies PHILOSOPHY, MANUAL, DECISIONS and GLOSSARY (headers
                                           stripped) into template/docs/factory918/ for projects.
```

hard findings: 0
