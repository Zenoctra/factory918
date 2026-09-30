## Walk

1. Runner prompt (`template/.agents/skills/architect/references/runner-prompt.md:5-10`, via `patches/pstack/architect/references/runner-prompt.md.patch`, listed in `series` and SOURCES item 14): for a design with state, the first deliverable is the scenario table, then the contract, then the test list, in the ticket's shape (legend, one assertion per cell, fixture state named); without state, the usage and signature sketch; the orchestrator appends the synthesized deliverable under `## Testing decisions` or `## Design`.
2. Same bullet: an off-path cell reads "refused with the tool's own message", costs no code, and is cut only after the refusal was run and seen.
3. Ticket playbook step 6 (`ticket.md:10`): the table is appended with `gh issue edit N --body-file`, first line `Posted by the agent <date>` or `Approved by <name> <date>`; the human edits; a stop only with `/architect with checkpoint`; the Spec brief carries it because `review-brief.sh` pastes the body. `ticket.md` is a factory file, so no patch is needed.
4. Feature step 4, Bug fix step 3, Refactoring step 5, Perf issue step 3, each with its patch updated: the brief carries the artifact; the test comes from the table first, one assertion per cell; a writer that cannot implement a cell stops and reports it, never fills it.
5. `to-spec` Testing Decisions, as a copy and as the new patch `mattpocock/to-spec/SKILL.md.patch` in `series`: the scenario table is the shape for stateful work.
6. Knowledge: `core/SCENARIO-TABLE.md` holds what it is, the shape, where it goes, the #42 example and why. `CORE_DOCS` builds it into `INDEX.md` and `template/docs/factory918/`. The `knowledge` skill's slim-corpus line names it. The glossary entry points to the page.
7. `issue-tracker.md` (both copies) documents the two appended sections; P25 records the decision.

## Would break

## Fails open

## Not asked for

1. **An unrelated ledger line.** `docs/agents/ledger.md` gains a 2026-09-22 line about lanes dying when a worktree was removed. It records a process surprise from this run. It does not concern the scenario table.

```
2026-09-22 | fable | ended its turn while two explorer lanes were still reading, the harness removed its worktree, and both lanes died without a report
```

2. **An M0 finding on `sync` and SOURCES.md.** The new `docs/M0-findings.md` line also notes that `factory918.sh sync` bumps no VERSION, against SOURCES.md line 3. The ticket did not ask for that. The line leaves SOURCES.md line 3 as it is.

```
factory918.sh sync (0.3.0) bumps no VERSION and touches no network, against what SOURCES.md line 3 says
```

hard findings: 0
