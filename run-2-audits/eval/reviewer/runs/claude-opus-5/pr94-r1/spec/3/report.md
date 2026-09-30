## Walk

1. `to-spec`'s Testing decisions gains the table as the shape for stateful work, in the vendored copy and in `patches/mattpocock/to-spec/SKILL.md.patch`; the hunk matches the pinned upstream at lines 63-68, so `sync` re-applies it.
2. Ticket playbook step 6 carries the rule: the selected playbook's architect step writes the table, the synthesized table is appended under `## Testing decisions` with `gh issue edit N --body-file` before implementation, first line `Posted by the agent <date>` or `Approved by <name> <date>`, a sketch under `## Design` for stateless code, a stop only with `/architect with checkpoint`, and the Spec brief carries it.
3. `architect`'s runner prompt makes the table, then the contract, then the test list the first deliverable for a design with state, the usage and signature sketch otherwise, with the "refused with the tool's own message" cell and the cut-only-after-the-refusal-was-seen rule; the orchestrator posts the synthesized deliverable. Its patch hunk matches the pinned upstream at lines 2-9.
4. Feature step 4, Bug fix step 3, Refactoring step 5 and Perf issue step 3 tell the writer to write the test from the table first, one assertion per cell, and to stop and report a cell it cannot implement; template copies and patches agree.
5. `review-brief.sh:222` fetches the whole ticket body and the brief prints it under `## The ticket`, so the table reaches the reviewer with no extra step.
6. `docs/agents/issue-tracker.md` and its template copy document the two appended sections.
7. `tools/build_knowledge.py` CORE_DOCS gains `core/SCENARIO-TABLE.md`; the core page, the INDEX row, the GLOSSARY entry, the slim project copy and the `knowledge` skill's `$KB` line follow, so `/knowledge scenario table` finds it.
8. `patches/series` lists both new patches; DECISIONS P25, the ledger line and the M0 finding record the decisions.

## Would break

1. **The manual still says a project carries four core documents.** `build_core` copies every core document but the digest, so a project now carries five, including `SCENARIO-TABLE.md`, and the human-facing list that names them was not extended.
Documented step:
```
Everything below lives in the factory clone (`~/.factory918`); a project carries only the first four, under `docs/factory918/`.
```
Result: `docs/knowledge/core/MANUAL.md:165` and the generated `template/docs/factory918/MANUAL.md:146` miscount, and the reader is never told the scenario-table page is in their project; the four bullets under that line stop at `GLOSSARY.md`.

2. **The build script's own docstring names four copied documents.** The diff added the fifth tuple below it and left the prose.
Documented step: `tools/build_knowledge.py:8`
```
then copies PHILOSOPHY, MANUAL, DECISIONS and GLOSSARY (headers
stripped) into template/docs/factory918/ for projects.
```
Result: the file's header contradicts `build_core` (line 136 copies every core document except `CONVERSATION-DIGEST.md`), the behaviour the M0 finding in this same diff relies on.

## Fails open

## Not asked for

hard findings: 2
