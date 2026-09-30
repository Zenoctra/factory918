# Spec review, #89 at ab47eb9

## Walk

1. Criterion 1, the runner prompt, through its patch. `patches/pstack/architect/references/runner-prompt.md.patch` is in `series` and gives two cases. With state (a file, exit codes, rounds, more than one actor), the first deliverable is the scenario table, then the contract, then the test list, in the shape the ticket describes: a legend, the contract defining every term, and one assertion per cell in cell order, each naming its fixture. Without state, crossing a function boundary, it is the usage and signature sketch. The orchestrator appends the synthesized deliverable to the ticket, a table under `## Testing decisions` and a sketch under `## Design`. A scratch copy of `./factory918.sh sync` applied all 19 patches, and `git status` stayed clean, so the template copy is exactly upstream plus the patch. Note: `architect/SKILL.md` Phase B, "Outputs" and `rationale-template.md` still describe the package without a table. Only the runner prompt asks for one, and it is the only file criterion 1 names.
2. Criterion 2. The runner prompt says "refused with the tool's own message", that such a cell costs no code, and that it is cut only after the refusal was run and seen. It adds that an assumption about a tool's failure mode is a claim until then.
3. Criterion 3, Ticket step 6 (`ticket.md` is in sync's `keep_files`, so it is edited directly). For a design with state, the synthesized table is appended under `## Testing decisions` with `gh issue edit N --body-file` before implementation. Its first line is `Posted by the agent <date>` or `Approved by <name> <date>`. A `## Design` sketch follows the same rule, and a prose change has only its criteria. The human edits a wrong table. A stop happens only on `/architect with checkpoint`, which matches `architect/SKILL.md` Phase C. The step says the Spec brief carries the table because `review-brief.sh` pastes the body, and `review-brief.sh:222` does paste `gh issue view --json body` whole.
4. Criterion 4. The delegation steps of Feature (step 4), Bug fix (step 3), Perf issue (step 3) and Refactoring (step 5) each say, through their patches: the brief carries the design artifact; the test is written from the table before the implementation, one assertion per cell in table order, and the commit order shows it; a writer that cannot implement a cell stops and reports it, and never fills it in. The refactoring patch hunk grew to `-6,9 +6,9` to carry step 5. It applies cleanly.
5. Criterion 5. The new `patches/mattpocock/to-spec/SKILL.md.patch` is in `series` and adds one bullet under Testing Decisions: for stateful work the shape is the scenario table, and the table is the test list. The template copy matches it after sync.
6. Criterion 6. The page is `docs/knowledge/core/SCENARIO-TABLE.md`, 88 lines: what the table is, its shape, where it goes, the #42 legend and table verbatim, and why. It is a CORE_DOCS tuple in `tools/build_knowledge.py`, and `INDEX.md` lists it as "Designing or reviewing anything with state". `rg -i "scenario table"` over the knowledge base hits it and the GLOSSARY entry. In the scratch copy, `build_knowledge.py` left `git status` clean and `check_knowledge.py` printed `knowledge ok: 119 files`. The build also copies the page to `template/docs/factory918/`, and `knowledge/SKILL.md` names it in the slim set. Two notes on changed files. The docstring at `tools/build_knowledge.py:8` still says only PHILOSOPHY, MANUAL, DECISIONS and GLOSSARY are copied. The project copy points at `tests/poteto-mode/overlap.sh`, which `apply` does not ship (see [P3]).
7. Supporting documentation. `docs/agents/issue-tracker.md` and its template copy describe the two optional sections after `## Blocked by`. DECISIONS P25 is in both copies, and P-numbers are unique. GLOSSARY has a "Scenario table" entry. SOURCES items 13 to 15 record the patches. AGENTS.md says "six core documents".
8. Run under, rules 6 to 8. No changed path is under `.claude/hooks/`, a `settings.json` or `.agents/skills/factory918/`, so there is no blast-radius grounding to walk. No shell file changed, so ShellCheck has nothing to run on. In the scratch copy, `tests/spec-review/review-brief.sh` (334 assertions), `tests/poteto-mode/overlap.sh` (56) and `no-stale-wording.sh` all pass. `tests/knowledge/provisional-ids.sh` does not exist in this snapshot.

## Would break

## Fails open

## Not asked for

1. **A ledger line about a lane that died with its worktree.** The `docs/agents/ledger.md` line dated 2026-09-22 records a turn that ended while explorer lanes were still reading. That incident is about running the lanes, not about the scenario table. AGENTS.md sends surprises to the ledger, so the line has a home, but it is not #89 work.

   ```
   A decision you had to make goes under Provisional in `DECISIONS.md`; a surprise goes to `docs/agents/ledger.md`.
   ```

2. **The M0 finding on sync and VERSION.** The second sentence of the new `docs/M0-findings.md` line says `factory918.sh sync` bumps no VERSION and touches no network, which contradicts `SOURCES.md` line 3. The code agrees with the finding: the comment above `cmd_sync` says VERSION is bumped by hand. But `SOURCES.md` line 3 is left unchanged, so the contradiction is recorded, not fixed, in a PR about something else.

   ```
   Anything verified against a tool version gets a dated line in `docs/M0-findings.md`.
   ```

3. **The page ships to projects with pointers that only resolve in the factory.** The ticket asks for a page in the knowledge base. Copying it into `template/docs/factory918/` is the implementer's choice, recorded in P25. The project copy tells the reader to "Read the table beside `tests/poteto-mode/overlap.sh`", but `template/` has no `tests/`. It also names ticket #42, PR #92 and PR #87 as the durable copies. In a project's own tracker those numbers are unrelated issues. The template DECISIONS already cites factory ticket numbers, so the numbers follow an existing pattern. The test-file pointer is new.

   ```
   - [ ] The knowledge base has one page on the table (what it is, the shape, the #42 example), reachable through `/knowledge scenario table`.
   ```

4. **The ticket-shape paragraph in both `issue-tracker.md` copies.** No criterion names the ticket-shape document. The paragraph supports criterion 3 by documenting the two sections the architect step may append. It is in scope in spirit, but it is an addition the ticket did not list.

   ```
   - [ ] The Ticket playbook's architect step says that when a design adds state, the table is appended to the ticket's body under `## Testing decisions` ...
   ```

hard findings: 0
