The six criteria are met in the text, the patches re-apply byte-for-byte (`./factory918.sh sync` in a scratch copy reproduced `template/.agents/skills`), and `tools/build_knowledge.py` plus `check_knowledge.py` leave the tree clean. Two items: the manual now understates what a project carries, and a stateful design that skips `architect` still gets no table and nothing sends it back.

## Walk

1. Criterion 1: `template/.agents/skills/architect/references/runner-prompt.md:6-9` makes the first deliverable the table, then the contract, then the test list for a design with state, else the usage and signature sketch; line 9 has the orchestrator append it to the ticket (`## Testing decisions` or `## Design`). The patch `patches/pstack/architect/references/runner-prompt.md.patch` is in `series` and applies.
2. Criterion 2: `runner-prompt.md:7` carries "refused with the tool's own message and costs no code" and "cut such a cell only after the refusal was run and seen".
3. Criterion 3: `template/.agents/skills/poteto-mode/playbooks/ticket.md:10` (step 6) has the append with `gh issue edit N --body-file`, both first-line forms, the human-edits rule, `/architect with checkpoint` (which `architect/SKILL.md:48` recognises), and the `review-brief.sh` sentence; `review-brief.sh:222` writes the whole body to the brief.
4. Criterion 4: Feature step 4, Bug fix step 3, Perf issue step 3, Refactoring step 5 in both the template copies and their patches carry the test-from-table sentence and the stop-and-report sentence; `SOURCES.md` item 13 records it.
5. Criterion 5: `template/.agents/skills/to-spec/SKILL.md:66` through `patches/mattpocock/to-spec/SKILL.md.patch`, listed in `series`, applied.
6. Criterion 6: `docs/knowledge/core/SCENARIO-TABLE.md` (what it is, the shape, the #42 example, why), listed in `INDEX.md` at 88 lines (matches `wc -l`), `GLOSSARY.md` points at it, `build_knowledge.py` CORE_DOCS carries it and the slim copy lands in `template/docs/factory918/`; `knowledge/SKILL.md:13` names the slim set.
7. Record: `DECISIONS.md` P25, `issue-tracker.md` body-shape paragraph (factory and template copies identical), `AGENTS.md` "six core documents", `M0-findings.md` dated line.

## Would break

1. **The manual says a project carries four documents; it now carries five.** `docs/knowledge/core/MANUAL.md:165` ("a project carries only the first four, under `docs/factory918/`") and its list at lines 167-170 name MANUAL, PHILOSOPHY, DECISIONS and GLOSSARY. `build_knowledge.py` now also copies `SCENARIO-TABLE.md` into `template/docs/factory918/` (verified in the rebuild), so the one place a person is told what their project holds omits the new page, and the count is wrong. The generated `template/docs/factory918/MANUAL.md` carries the same sentence.
   ```
   - [ ] The knowledge base has one page on the table (what it is, the shape, the #42 example), reachable through `/knowledge scenario table`.
   ```
   Documented step: `docs/knowledge/core/MANUAL.md:165`, "Where to read more".
   Result: the reader is told four documents and never sees `SCENARIO-TABLE.md` named; only the `/knowledge` route finds it.
   spec: criterion 6

## Fails open

2. **A stateful design that skips `architect` gets no table, and nothing sends it back.** Ticket step 6 binds the table to `architect`'s first deliverable. Bug fix step 3 and Perf issue step 3 run `architect` only "if it crosses a function boundary"; Feature step 2 still allows `architect skipped: <reason>` for any diff that is not cross-cutting. A design that adds state (a state file, exit codes) but does not cross a function boundary, or a Feature where the orchestrator skips with a reason, runs no `architect`, so no table is written, and implementation proceeds with the criteria alone. The ticket's Problem names this as the gap ("nothing sent it back for them when the design added state"); the cross-cutting clause has a "never skips" sentence, state has none.
   ```
   - [ ] The Ticket playbook's architect step says that when a design adds state, the table is appended to the ticket's body under `## Testing decisions`, first line "Posted by the agent <date>" or "Approved by <name> <date>", before implementation; the human edits it if it is wrong; a stop before implementation is asked for only with "/architect with checkpoint". The Spec brief carries it because `review-brief.sh` pastes the ticket body, and the playbook says so.
   ```
   Documented step: `template/.agents/skills/poteto-mode/playbooks/ticket.md:10`, "when the design adds state ... `architect`'s first deliverable is the scenario table".
   Result: with `architect` not run, the condition is never evaluated; the ticket gets no `## Testing decisions`, the writer's brief carries no artifact, and the review judges against criteria the ticket says are the weakest artifact. No message, no stop.
   spec: criterion 3

## Not asked for

3. **Two record lines outside the ticket's scope.** `docs/agents/ledger.md:25` (explorer lanes died when the turn ended) and the second half of the `M0-findings.md` line (sync bumps no VERSION and touches no network, against `SOURCES.md` line 3, which the diff leaves unchanged). Both follow standing rules in `AGENTS.md` (a surprise goes to the ledger; a verified fact gets a dated line); neither is in the criteria, and the `SOURCES.md` line 3 disagreement is recorded rather than fixed.
   ```
   2026-09-22. A sixth core document costs one CORE_DOCS tuple in tools/build_knowledge.py and no other code ... factory918.sh sync (0.3.0) bumps no VERSION and touches no network, against what SOURCES.md line 3 says; the code is the truth (#89).
   ```

hard findings: 2
