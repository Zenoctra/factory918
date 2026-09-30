## Walk

1. Runner prompt (patch and template copy, identical): the first deliverable with state (file, exit codes, rounds, more than one actor) is the table, then contract, then test list, in the ticket's shape. Without state, it is the usage and signature sketch. The orchestrator posts the result under `## Testing decisions` or `## Design` (Ticket step 6).
2. Runner prompt: an out-of-path cell reads "refused with the tool's own message", costs no code, and is cut only after the refusal was run and seen.
3. Ticket step 6: when a design adds state, the table is appended with `gh issue edit N --body-file`. Its first line is `Posted by the agent <date>` or `Approved by <name> <date>`, and the human edits it. A stop is asked for only with `/architect with checkpoint`. The step says `review-brief.sh` pastes the ticket body. A stateless sketch goes under `## Design`.
4. Feature step 4, Bug fix step 3, Refactoring step 5 and Perf issue step 3 (patches and template): the test is written from the table first, one assertion per cell, and the commit order shows it. A writer that cannot implement a cell stops, reports it, and never fills it.
5. to-spec Testing Decisions (patch in `series`, template copy): the table is the shape for stateful work.
6. `core/SCENARIO-TABLE.md` is added to CORE_DOCS, INDEX and the glossary, and copied to `template/docs/factory918/`. The slim corpus list in the knowledge skill names it, so `/knowledge scenario table` reaches it in the factory and in a project.
7. P25 records the choices. SOURCES.md items 13 to 15 describe the patches.

## Would break

## Fails open

## Not asked for

1. **Unrelated ledger line.** `docs/agents/ledger.md` gains a 2026-09-22 line about lanes dying when a turn ended. It is a surprise from the run, not part of #89. AGENTS.md sends surprises to the ledger, so this is allowed, but it falls outside the ticket's concern.
```
- [ ] The knowledge base has one page on the table (what it is, the shape, the #42 example), reachable through `/knowledge scenario table`.
```
2. **Unrelated M0 finding on sync.** `docs/M0-findings.md` adds a note that `factory918.sh sync` touches no VERSION and no network, which contradicts SOURCES.md line 3. That is a finding about a different file, and it is left unfixed.
```
- [ ] `to-spec`'s Testing decisions section (through its patch or the factory's copy) names the table as the shape for stateful work.
```
3. **issue-tracker.md ticket-shape paragraph.** Both copies now describe the optional `## Testing decisions` and `## Design` sections. The paragraph supports criterion 3, but no criterion asked for it.
```
- [ ] The Ticket playbook's architect step says that when a design adds state, the table is appended to the ticket's body under `## Testing decisions`
```

hard findings: 0
