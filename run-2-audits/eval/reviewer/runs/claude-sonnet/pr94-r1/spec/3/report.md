## Walk

1. `architect/references/runner-prompt.md.patch` makes the first deliverable, for a design with state, the scenario table, then the contract, then the test list; for stateless code crossing a function boundary, the usage/signature sketch; both note posting to the ticket (table under `## Testing decisions`, sketch under `## Design`), matching AC1.
2. The same patch states the "refused with the tool's own message" cell rule and that such a cell is cut only after the refusal was run and seen, matching AC2.
3. `poteto-mode/playbooks/ticket.md` step 6 (through its own diff, not a patch, since it is template-native) adds the table/sketch posting rule, first line `Posted by the agent <date>` or `Approved by <name> <date>`, human edits in place, stop only via `/architect with checkpoint`, and notes the Spec brief carries it via `review-brief.sh`, matching AC3.
4. The Feature, Bug fix, Refactoring and Perf issue patches each add, at their delegation step, that the writer writes the test from the table before implementation, one assertion per cell, and stops and reports (never fills) a cell it cannot implement, matching AC4.
5. `to-spec/SKILL.md.patch`'s Testing Decisions section names the scenario table as the shape for stateful work, matching AC5.
6. `SCENARIO-TABLE.md` is added as a sixth core document (`docs/knowledge/core/`, indexed in `INDEX.md`, mirrored to `template/docs/factory918/`), registered in `tools/build_knowledge.py`'s `CORE_DOCS`, and cross-linked from `GLOSSARY.md`, so `/knowledge scenario table` finds it via the glossary or a grep hit, matching AC6.
7. `patches/series` lists both new patch files and `SOURCES.md` documents them (entries 14, 15), so `factory918 sync` can re-apply them per AGENTS.md rule 3.
8. `docs/agents/issue-tracker.md` and its template copy document the `## Testing decisions` / `## Design` sections and their first-line convention, consistent with step 6.

## Would break

## Fails open

## Not asked for

1. **A ledger line unrelated to #89.** The diff adds a `docs/agents/ledger.md` entry about two explorer lanes dying when their worktree was removed mid-turn, which is a lesson from a different incident, not from designing or reviewing the scenario table.
```
2026-09-22 | fable | ended its turn while two explorer lanes were still reading, the harness removed its worktree, and both lanes died without a report | drain every lane before the turn ends; a lane with no worktree cannot report
```

hard findings: 0
