## Final message

/private/tmp/wsbox/w-20261005-191213-1341/factory918/.scratch/review/ab47eb9/standards-report.md

## File written: factory918/.scratch/review/ab47eb9/standards-report.md

```
# Standards report

For a person: the vendored patches, the knowledge build and every count in prose all check out. One step tells an agent to append to a ticket body with a command that replaces it.

## Would break

1. **`gh issue edit --body-file` replaces the body; the step says "appended".** `--body-file` sets the whole body. Nothing in the step or in `docs/agents/issue-tracker.md` tells the agent to fetch the body first and concatenate, and no append idiom is documented anywhere else in the template (the only other `gh issue edit` uses are `--add-label` / `--add-assignee`). An agent that writes the table to a file and runs the named command loses **What to build**, **Acceptance criteria**, **Parent** and **Blocked by**; `gh` exits 0 and prints the URL, so nothing says it happened. `review-brief.sh:222` then pastes the remaining body as the whole spec, and the Spec reviewer reviews against a table with no criteria. Standard: `CODING_STANDARDS.md`, Markdown — "Written with `/writing-for-agents` when an agent reads it".

Documented step: `template/.agents/skills/poteto-mode/playbooks/ticket.md:10` — "before implementation the synthesized table is appended to the ticket's body under `## Testing decisions` with `gh issue edit N --body-file`".

Result: the ticket body is overwritten by the table alone, silently, and the ask is gone for every later session and for the Spec brief.

```
+6. ... and before implementation the synthesized table is appended to the ticket's body under `## Testing decisions` with `gh issue edit N --body-file`, first line `Posted by the agent <date>` ...
```

## Fails open

## Standards breaches

## Fix alongside

2. **Duplicated Code: the writer paragraph is copied verbatim into four playbooks.** The same 40-word sentence pair lands in `feature.md`, `bug-fix.md`, `refactoring.md` and `perf-issue.md` (and their four patches). A later wording change costs eight edits kept in sync by hand; the playbooks already point at shared text elsewhere, so one sentence pointing at Ticket step 6 would carry it.

```
+... The brief carries the ticket's design artifact (Ticket step 6). When it is a scenario table, the writer writes the test from the table before the implementation, one assertion per cell in the table's order, and the commit order shows it; a writer that cannot implement a cell as written stops and reports the cell, and never fills it in.
```

3. **The "before implementation" rule sits after the step that implements.** Ticket step 5 runs the selected playbook's steps "verbatim from step 1", implementation included; step 6 is read only afterwards. It is reachable only because each playbook's delegation step points forward to step 6. P25 records the trade (no renumbering, since "Ticket step 5" is quoted in four patches and `review-brief.sh`), so this is a documented choice, not a breach.

hard findings: 1
```
