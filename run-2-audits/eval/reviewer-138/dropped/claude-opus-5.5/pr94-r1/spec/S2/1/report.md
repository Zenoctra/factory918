# Spec review, #89 at ab47eb9

## Walk

1. Criterion 1: `runner-prompt.md.patch`, now listed in `patches/series`, makes the scenario table the first deliverable for a design with state, followed by the contract and the test list. For stateless code that crosses a function boundary it makes the usage and signature sketch the first deliverable. The orchestrator appends the synthesized deliverable under `## Testing decisions` or `## Design`. `factory918.sh sync` ran in a scratch copy: all 19 patches applied and `git status` stayed clean.
2. Criterion 2: the runner prompt contains the "refused with the tool's own message" rule, which costs no code, and says such a cell is cut only after the refusal was run and seen.
3. Criterion 3: Ticket step 6 appends the synthesized table with `gh issue edit N --body-file` and gives its first line. It says that posting is the record and that a stop is opt-in with `/architect with checkpoint`. It says the Spec brief carries the table because `review-brief.sh` pastes the body. `review-brief.sh:222` confirms the body is pasted whole.
4. Criterion 4: the Feature (step 4), Bug fix (step 3), Refactoring (step 5) and Perf issue (step 3) patches and template copies each carry the same sentence: the test comes from the table, one assertion per cell in the table's order, and the writer stops and reports the cell instead of filling it in.
5. Criterion 5: the new `mattpocock/to-spec/SKILL.md.patch` adds the scenario table to Testing Decisions, and sync applies it.
6. Criterion 6: `core/SCENARIO-TABLE.md` is added to CORE_DOCS and appears in INDEX. build_core copies it to `template/docs/factory918/`, and the knowledge skill's slim list names it. `build_knowledge.py` and `check_knowledge.py` leave a clean tree (119 files). The project copy still points at `tests/poteto-mode/overlap.sh`, ticket #42 and PR #92. Those are factory references, and the page carries the table verbatim anyway.
7. Supporting docs: issue-tracker body shape (factory and template), DECISIONS P25, GLOSSARY entry, SOURCES 13 to 15, AGENTS.md "six core documents".
8. Run under, rule 6: the diff touches no cross-cutting path, so there is no blast-radius grounding and no risk lines. Rule 8: no shell file changed. `review-brief.sh`, `overlap.sh` and `no-stale-wording.sh` tests pass.

## Would break

1. **Stateful work that skips architect gets no table.**
   ```
   The Ticket playbook's architect step says that when a design adds state, the table is appended to the ticket's body under `## Testing decisions`
   ```
   Documented step: `template/.agents/skills/poteto-mode/playbooks/ticket.md:10` ties the table to "`architect`'s first deliverable". Feature step 2 still accepts `architect skipped: <reason>` for any diff that is not cross-cutting. Bug fix and Perf issue step 3 run architect only "if it crosses a function boundary".
   Result: a stateful design whose architect step is skipped or not triggered has no table, and no rule sends it back. The delegation sentence ("When it is a scenario table") passes over the missing table silently. This is the failure the ticket's Problem describes.
   spec: criterion 3

2. **A posted table's backticked tokens become overlap pathspecs.**
   ```
   the table is appended to the ticket's body under `## Testing decisions`
   ```
   Documented step: Ticket step 6 posts the table into the body. Ticket step 1 (`overlap.sh:48-50`) takes every backticked token outside `## Diff` as a pathspec, and at this commit it does not skip `## Testing decisions` or `## Design`.
   Result: when step 1 runs again after posting (a resumed session on the same ticket), cell tokens are treated as named paths. A glob such as `docs/*.md` gives a false exit 1. An absolute or dot-dot path gives exit 2: git refused `/etc/passwd` with "outside repository" (exit 128) in a scratch repo. The page's row 14 leaves such a path unbackticked for this reason, but no rule tells the table writer to do the same.
   spec: criterion 3

3. **The manual still says a project carries four core documents.**
   ```
   The knowledge base has one page on the table (what it is, the shape, the #42 example), reachable through `/knowledge scenario table`.
   ```
   Documented step: `docs/knowledge/core/MANUAL.md:165` (and the template copy, line 146) says a project carries "only the first four", and the list below it omits `SCENARIO-TABLE.md`. The docstring at `tools/build_knowledge.py:8` still names only four copied documents.
   Result: a person reading the manual is told the project carries four documents and never learns the fifth page exists. AGENTS.md and the knowledge skill were updated for the same fact.
   spec: criterion 6

## Fails open

## Not asked for

4. **Unrelated ledger line.**
   ```
   (no criterion; AGENTS.md: "a surprise goes to docs/agents/ledger.md")
   ```
   The 2026-09-22 entry about lanes dying when the turn ended is outside this ticket. The ledger rule allows it.

5. **An out-of-scope finding recorded instead of ticketed.**
   ```
   (no criterion; AGENTS.md: "a finding outside its scope becomes a ticket")
   ```
   The second sentence of M0-findings 2026-09-22 records that `sync` contradicts `SOURCES.md` line 3. No ticket is referenced.

6. **Issue-tracker body shape extended.**
   ```
   (no criterion names docs/agents/issue-tracker.md)
   ```
   The paragraph documenting the two appended sections is supportive and consistent with step 6.

hard findings: 3
