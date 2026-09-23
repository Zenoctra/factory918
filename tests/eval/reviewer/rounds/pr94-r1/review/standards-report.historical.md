# Standards report

## Would break

1. **`gh issue edit --body-file` replaces the body; nothing says to write the old body back.** The new rule is the system's first body-rewriting operation, and neither Ticket step 6, `SCENARIO-TABLE.md` "Where it goes", nor `docs/agents/issue-tracker.md` (which documents create, comment, label and assignee, but no body edit) says to fetch the body first and write body-plus-section to the file. An agent that types the named command with only the synthesized table in the file drops What to build, Acceptance criteria, Parent and Blocked by. `review-brief.sh:222` then pastes the truncated body as the spec, so the Spec axis reviews a ticket with no criteria and says nothing. Standard: `CODING_STANDARDS.md`, Bash — "Test a command the way a user types it"; and the ledger's own 2026-09-21 line, "a path an agent will type is tested the way it is typed".

Documented step: `template/.agents/skills/poteto-mode/playbooks/ticket.md:10` — "before implementation the synthesized table is appended to the ticket's body under `## Testing decisions` with `gh issue edit N --body-file`".

Result: the ticket body becomes the table alone; the spec sections are lost silently and the next Spec review has no criteria to check.

```
6. ... and before implementation the synthesized table is appended to the ticket's body under `## Testing decisions` with `gh issue edit N --body-file`, first line `Posted by the agent <date>`, ...
```

## Fails open

## Standards breaches

2. **The to-spec exemption covers half the rule it points at.** The rule above is "Do NOT include specific file paths or code snippets". The new bullet exempts only the snippet half, while the table it mandates names paths in every worked example (`.claude/state/program`, `tests/poteto-mode/overlap.sh`). An agent gets two instructions that disagree. Standard: `CODING_STANDARDS.md`, Markdown — written with `/writing-for-agents` when an agent reads it.

```
- For stateful work ... It is a decision, not a code snippet, so the rule above does not exclude it.
```

3. **`SOURCES.md` line 3 is left saying what this commit records as false.** The same commit adds `docs/M0-findings.md` "factory918.sh sync (0.3.0) bumps no VERSION and touches no network, against what SOURCES.md line 3 says", and edits `SOURCES.md` below that line without correcting it. Standard: `CODING_STANDARDS.md`, Markdown — "A count or a version in prose is true at the commit that lands it".

```
`factory918 sync` will re-fetch these pins, re-apply the patches, and bump VERSION.
```

## Fix alongside

4. **Duplicated Code / Shotgun Surgery.** The same 45-word writer sentence is pasted verbatim into four playbooks and their four patches, and the same rule is restated in Ticket step 6, `issue-tracker.md`, the runner prompt, P25, the glossary and `SCENARIO-TABLE.md`. The next wording change is an eight-file edit.

```
The brief carries the ticket's design artifact (Ticket step 6). When it is a scenario table, the writer writes the test from the table before the implementation, one assertion per cell in the table's order, ...
```

5. **The posted table feeds tokens back into `overlap.sh`.** Step 6 appends backticked tokens to the ticket body; a later step-1 check reads every backticked token outside `## Diff` as a pathspec, so a table cell quoting an unrelated path can print an overlap and stop the run.

hard findings: 1
