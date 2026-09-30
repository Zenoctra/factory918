## Walk

1. Criterion 1, the runner prompt: `patches/pstack/architect/references/runner-prompt.md.patch` makes the first deliverable a scenario table, then the contract, then the test list, for a design with state (file, exit codes, rounds, several actors). For stateless code that crosses a function boundary it is the usage and signature sketch. The orchestrator appends the table under `## Testing decisions` or the sketch under `## Design` (Ticket step 6). The template copy matches: `./factory918.sh sync` on a copy applied all 19 patches, including the two new ones, and left `git status` clean.
2. Criterion 2: the runner prompt carries "refused with the tool's own message", "costs no code" and "Cut such a cell only after the refusal was run and seen" word for word.
3. Criterion 3, Ticket step 6 (`template/.agents/skills/poteto-mode/playbooks/ticket.md:10`): the table is appended with `gh issue edit N --body-file` before implementation. Its first line is `Posted by the agent <date>` or `Approved by <name> <date>`. The human edits it. A stop needs `/architect with checkpoint`, which matches architect's Phase C opt-in (`architect/SKILL.md:48`). The step also says the Spec brief carries the table. I checked `review-brief.sh:222`: it pastes the body whole.
4. Criterion 4: the Feature step 4, Bug fix step 3, Perf issue step 3 and Refactoring step 5 patches each add the same text: the brief carries the artifact; when it is a table, the test comes from the table before the implementation, one assertion per cell in order; a writer that cannot implement a cell stops, reports it and never fills it in. The template copies match after sync.
5. Criterion 5: `patches/mattpocock/to-spec/SKILL.md.patch` is in `series` and applies. It names the table as the Testing Decisions shape for stateful work and exempts it from the no-code-snippets rule.
6. Criterion 6: `docs/knowledge/core/SCENARIO-TABLE.md` covers what the table is, its shape, where it goes, the #42 example and why. I diffed its table against the live #42 body and they are identical. It is in `CORE_DOCS`, `INDEX.md` and the glossary, and it is copied to `template/docs/factory918/`. The knowledge skill's slim-corpus line names it. `build_knowledge.py` leaves the tree clean and `check_knowledge.py` passes.
7. Supporting docs: `SOURCES.md` items 13 to 15, DECISIONS P25, and the issue-tracker ticket-shape paragraph (factory and template copies identical) all describe the same rule.
8. Run-under rules 6 to 8: no changed path is cross-cutting, so there is no blast-radius grounding to walk, and no shell file changed. `review-brief.sh` (334), `overlap.sh` (56) and `no-stale-wording.sh` all pass on the copy.

## Would break

1. **The table depends on an architect step the playbooks still let a stateful change skip.** Ticket step 6 ties the table to "the selected playbook's architect step". The playbooks still allow skipping that step for a stateful design that is not cross-cutting. Feature step 2 accepts `architect skipped: <reason>` for any diff that is not cross-cutting. Bug fix step 3, Perf issue step 3 and Refactoring step 3 run `architect` only "if it crosses a function boundary". Nothing added in the diff makes state trigger `architect`. So a new stateful script or hook in a non-cross-cutting Feature can skip `architect`, and so can a single-function Bug fix with exit codes. Such a change gets no table and nothing sends it back. That is the ticket's own problem: "nothing sent it back for them when the design added state".
   ```
   - [ ] `architect`'s runner prompt (through its patch) makes the first deliverable, for any design with a file it reads or writes, exit codes, or more than one actor, the scenario table ...
   ```
   ```
   Three, and every ticket has at least one. For anything with state, the scenario table below.
   ```
   Documented step: `template/.agents/skills/poteto-mode/playbooks/ticket.md:10` ("The selected playbook's architect step adds the ticket's own: when the design adds state ...") together with `template/.agents/skills/poteto-mode/playbooks/feature.md:6` ("Skipping stays as `architect skipped: <reason>`, not accepted for a cross-cutting diff").
   Result: a stateful, non-cross-cutting change that skips `architect` (with a reason, or because it stays inside one function) goes to implementation with no `## Testing decisions` table. The table rule silently does not apply.
   spec: criterion 1

2. **The page shipped to projects points at the factory's ticket, PR and test by bare number and path.** `template/docs/factory918/SCENARIO-TABLE.md` goes into every project. It says the durable copy is "the `## Testing decisions` section of ticket #42 and the description of PR #92" and tells the reader to read the table "beside `tests/poteto-mode/overlap.sh`". In a project, `#42` and `#92` are that project's own issues, and `tests/poteto-mode/overlap.sh` does not exist, because `template/` has no `tests/`. The table is inlined, so the example survives. The pointers are still wrong outside the factory. The fix is to name the factory's repository, or to drop the pointers in the copied page.
   ```
   - [ ] The knowledge base has one page on the table (what it is, the shape, the #42 example), reachable through `/knowledge scenario table`.
   ```
   Documented step: `template/docs/factory918/SCENARIO-TABLE.md:42` ("The durable copy is the `## Testing decisions` section of ticket #42 and the description of PR #92") and `:69` ("Read the table beside `tests/poteto-mode/overlap.sh`").
   Result: a project agent that follows the pointer runs `gh issue view 42` on its own repository and silently reads an unrelated issue. The test file it is told to read is absent.
   spec: criterion 6

## Fails open

## Not asked for

3. **A ledger line about a lane dying at turn end.** `docs/agents/ledger.md` adds 2026-09-22: the orchestrator ended its turn with explorer lanes still running. AGENTS.md sends surprises to the ledger, but this one is about lane handling, not the scenario table.
   ```
   2026-09-22 | fable | ended its turn while two explorer lanes were still reading ...
   ```
4. **An M0 finding that `sync` bumps no VERSION, against SOURCES.md line 3.** The finding records a discrepancy the ticket did not ask about. It leaves SOURCES.md line 3 as it was.
   ```
   factory918.sh sync (0.3.0) bumps no VERSION and touches no network, against what SOURCES.md line 3 says; the code is the truth (#89).
   ```

hard findings: 2
