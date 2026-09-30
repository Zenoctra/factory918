## Walk

1. Runner prompt (template and `patches/pstack/architect/references/runner-prompt.md.patch`, now in `series`): for a design with state, the first deliverable is the scenario table in the ticket's shape (situations, input shape, cell = printed / exit / caller's next step, legend), then the contract, then the test list with one assertion per cell in order, each naming its fixture. For stateless code that crosses a function boundary, the first deliverable is the usage and signature sketch. The orchestrator posts it under `## Design` (Ticket step 6).
2. The runner prompt says the out-of-path cell reads "refused with the tool's own message" and costs no code. It says such a cell is cut only after the refusal was run and seen.
3. Ticket step 6 appends the table under `## Testing decisions` with `gh issue edit N --body-file` before implementation. Its first line is `Posted by the agent <date>` or `Approved by <name> <date>`. The human edits the ticket, and the only stop is `/architect with checkpoint`. The step also says the Spec brief carries the table because `review-brief.sh` pastes the body. `issue-tracker.md` adds both sections to the ticket shape.
4. The Feature (step 4), Bug fix (step 3), Refactoring (step 5) and Perf issue (step 3) patches, and their regenerated copies, say the brief carries the artifact. The writer writes the test from the table first, one assertion per cell in order, and the commit order shows it. A writer that cannot implement a cell stops and reports it, and never fills it.
5. The `to-spec` patch and copy name the scenario table as the Testing decisions shape for stateful work.
6. `core/SCENARIO-TABLE.md` is a sixth core document: `CORE_DOCS` tuple, INDEX row, generated `template/docs/factory918/SCENARIO-TABLE.md`, glossary entry, and the knowledge skill's slim-corpus list. It covers what the table is, its shape, and the #42 legend, table and contract.
7. P25 records the choices, including that the rule lives in step 6 to avoid renumbering.

## Would break

## Fails open

## Not asked for

1. **Unrelated ledger line.** The 2026-09-22 ledger entry is about lanes dying when a worktree is removed. It records a surprise from this run rather than anything #89 asks for. AGENTS.md sends surprises to the ledger, so it is allowed, but it is a second concern in this PR.
```
- The knowledge base has one page on the table (what it is, the shape, the #42 example), reachable through `/knowledge scenario table`.
```

hard findings: 0
