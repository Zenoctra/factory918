# Standards review: ab47eb9

## Would break

## Fails open

## Standards breaches

1. **P25 counts four patches quoting "Ticket step 5"; there are five.** CODING_STANDARDS.md, Markdown: "A count or a version in prose is true at the commit that lands it, with the command that regenerates it nearby." `grep -rl "Ticket step 5" patches` lists bug-fix, feature, perf-issue, refactoring and `opening-a-pr.md.patch` (line 17, "For a cross-cutting diff (Ticket step 5)"). No command sits near the count. The generated copy in `template/docs/factory918/DECISIONS.md` carries the same text.

```
Choices made in #89: the rule lives in Ticket step 6 (no renumbering, since "Ticket step 5" is quoted in four patches and `review-brief.sh`)
```

## Fix alongside

2. **Duplicated Code / Shotgun Surgery: one delegation sentence pasted into four playbooks.** The same 60-word sentence is added verbatim to Feature step 4, Bug fix step 3, Refactoring step 5 and Perf issue step 3, in both the template and the four patches. That makes eight edits for one rule. The rule already lives in Ticket step 6 and `SCENARIO-TABLE.md`. The four playbooks could point to it ("the writer works from the ticket's design artifact, Ticket step 6") so that a later rewording touches one place. Because these are vendored files, each patch is a separate sync risk.

```
The brief carries the ticket's design artifact (Ticket step 6). When it is a scenario table, the writer writes the test from the table before the implementation, one assertion per cell in the table's order, and the commit order shows it; a writer that cannot implement a cell as written stops and reports the cell, and never fills it in.
```

3. **Duplicated Code: the "with state" definition is restated in six places with drift.** Ticket step 6, runner-prompt, P25, the to-spec patch, GLOSSARY and SCENARIO-TABLE each define "state" in their own words. Some lists include "rounds" and some leave it out. The to-spec patch says "a file read or written, exit codes, more than one actor", with no rounds. The runner prompt says "a file it reads or writes, exit codes, rounds, or more than one actor". An agent routed through to-spec gets a narrower trigger than one routed through the architect.

```
+- For stateful work (a file read or written, exit codes, more than one actor), the shape is the scenario table
```

hard findings: 0
