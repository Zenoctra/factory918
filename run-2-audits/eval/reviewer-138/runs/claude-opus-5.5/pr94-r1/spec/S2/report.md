## Walk

1. Criterion 1: the runner-prompt patch (`patches/pstack/architect/references/runner-prompt.md.patch`, listed in `series`) makes the first deliverable for a design with state (a file, exit codes, rounds, more than one actor) the scenario table in the ticket's shape (situations down the side, input shape across the top, cell = printed / exit / caller's next step, a legend), then the contract, then a test list with one assertion per cell in cell order. For stateless code that crosses a function boundary it is the usage and signature sketch, and the orchestrator posts it under `## Design` (the Ticket playbook, step 6). A scratch run of `./factory918.sh sync` applied every patch and left `git status` clean, so the template copy is exactly the patched upstream.
2. Criterion 2: the runner prompt says a cell outside the intended path reads "refused with the tool's own message", costs no code, and is cut only after the refusal was run and seen.
3. Criterion 3: Ticket step 6 (ours, kept by `keep_files`) says that when the design adds state, the synthesized table is appended under `## Testing decisions` with `gh issue edit N --body-file` before implementation, with first line `Posted by the agent <date>` or `Approved by <name> <date>`. It says the human edits the ticket, that a stop needs `/architect with checkpoint` (architect SKILL.md:48 honours that phrase), and that the Spec brief carries the table because `review-brief.sh` pastes the body. review-brief.sh:222 and 333-335 paste the body whole. The two `docs/agents/issue-tracker.md` copies list the two new sections.
4. Criterion 4: Feature step 4, Bug fix step 3, Refactoring step 5 and Perf issue step 3 each say, through their patches, that the brief carries the design artifact, that the writer writes the test from the table first with one assertion per cell and the commit order showing it, and that a writer who cannot implement a cell stops, reports it and never fills it in. Sync reproduced all four template files byte for byte.
5. Criterion 5: the new `patches/mattpocock/to-spec/SKILL.md.patch` (in `series`, applied by sync) and the template's `to-spec/SKILL.md` name the scenario table as the Testing Decisions shape for stateful work. They also exempt it from the no-code-snippets rule.
6. Criterion 6: `docs/knowledge/core/SCENARIO-TABLE.md` covers what the table is, its shape and the #42 example; the table rows match issue #42's current body line for line. `tools/build_knowledge.py` gained a CORE_DOCS tuple, INDEX.md lists the page, and `build_knowledge.py` plus `check_knowledge.py` ran clean with no diff (119 files). `rg -i "scenario table"` hits the page, the glossary and P25 in both the factory KB and the project's `docs/factory918` copy, which the knowledge skill's slim-corpus line now names.
7. Run-under rules 6 to 8: no changed path is cross-cutting (no `.claude/hooks/`, `settings.json` or `factory918` skill file), so there is no blast-radius grounding to walk. No shell file changed, so there is nothing for shellcheck.

## Would break

1. **A posted table feeds its backticked tokens to Ticket step 1's overlap check.** Step 6 appends the table under `## Testing decisions` in the ticket body. `overlap.sh` (lines 47-50) takes every backticked token outside `## Diff` as a pathspec. A table's cells are full of backticked terms, and #42's table includes `.claude/state/program`, whose own row 14 says an out-of-repo token exits 2. When the same ticket runs again from step 1 (a resumed lane, or a second run like #42's), the check therefore counts paths the ticket never asked to touch. The result is a spurious exit 1 against an unrelated open PR, or an exit 2 that blocks the start. Neither the playbook nor the page warns the agent writing the table. Issue #42's live body now carries an "Amended 2026-09-22 by #89" line saying the check skips `## Testing decisions` and `## Design` like `## Diff`, but no such change is in this diff: overlap.sh still skips only `## Diff`.
   ```
   - [ ] The Ticket playbook's architect step says that when a design adds state, the table is appended to the ticket's body under `## Testing decisions`, first line "Posted by the agent <date>" or "Approved by <name> <date>", before implementation
   ```
   Documented step: `template/.agents/skills/poteto-mode/playbooks/ticket.md:10` (step 6, "appended to the ticket's body under `## Testing decisions`") together with `ticket.md:5` (step 1, "one line per open PR whose own commits ... touch a path the ticket names in backticks").
   Result: on a rerun of the ticket, the table's backticked tokens become named paths. The check reports overlaps the ticket does not have (exit 1, stop), or exits 2 on an absolute or dot-dot token in a cell.
   spec: criterion 3

2. **A stateful design gets no table when the playbook skips `architect`.** Step 6 ties the table to "the selected playbook's architect step". Feature step 2 still accepts `architect skipped: <reason>` for any design that is not cross-cutting. Bug fix and Perf issue step 3, and Refactoring step 3, run `architect` only when the change crosses a function boundary. A stateful change that skips architect (an exit-code fix inside one script function, or a Feature skipped with a reason) therefore reaches implementation with no `## Testing decisions`, and nothing flags the missing table. That is the gap the ticket's Problem names: "nothing sent it back for them when the design added state". Its artifacts section also says "every ticket has at least one" and "for anything with state, the scenario table".
   ```
   The ticket had no Testing decisions because it was planned as prose, and nothing sent it back for them when the design added state.
   ```
   Documented step: `template/.agents/skills/poteto-mode/playbooks/ticket.md:10` ("The selected playbook's architect step adds the ticket's own: when the design adds state ...") together with `template/.agents/skills/poteto-mode/playbooks/feature.md:6` ("Skipping stays as `architect skipped: <reason>`, not accepted for a cross-cutting diff").
   Result: a stateful change whose playbook skips architect is written from prose with no table and no stop. The same path that produced PR #87's three redesign rounds stays open.
   spec: criterion 3

## Fails open

## Not asked for

3. **An unrelated ledger line.** `docs/agents/ledger.md` gains a 2026-09-22 entry about a lane that ended its turn with explorer lanes still running. It records a process surprise from this run and changes nothing the ticket asked for.
   ```
   2026-09-22 | fable | ended its turn while two explorer lanes were still reading, the harness removed its worktree, and both lanes died without a report
   ```

hard findings: 2
