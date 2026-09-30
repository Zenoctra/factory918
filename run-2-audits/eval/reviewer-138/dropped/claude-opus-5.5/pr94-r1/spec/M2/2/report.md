## Walk

1. Criterion 1: `template/.agents/skills/architect/references/runner-prompt.md` and its new patch (listed in `patches/series`) make the scenario table, then the contract, then the test list the first deliverable for a design with state. Code with no state that crosses a function boundary gets the usage and signature sketch. The orchestrator appends the result to the ticket under `## Testing decisions` or `## Design` (Ticket step 6). `./factory918.sh sync` in a scratch copy applied all 19 patches, and `diff -r` against `template/` came back empty.
2. Criterion 2: the runner prompt carries the "refused with the tool's own message" cell, which costs no code, and the rule that such a cell is cut only after the refusal was run and seen.
3. Criterion 3: Ticket step 6 (`ticket.md:10`) appends the synthesized table with `gh issue edit N --body-file`. Its first line is `Posted by the agent <date>` or `Approved by <name> <date>`. Posting is the record, the stop needs `/architect with checkpoint`, and the step says the Spec brief carries the table. `review-brief.sh:222` pastes the whole body from `gh issue view --json body`, so the step's claim holds.
4. Criterion 4: the delegation steps of Feature (step 4), Bug fix (step 3), Refactoring (step 5) and Perf issue (step 3) now say the test comes from the table first, one assertion per cell, and that a writer who cannot implement a cell stops, reports it and never fills it. They change through patches, and sync reproduces the template copies byte for byte.
5. Criterion 5: the `to-spec` Testing Decisions list names the scenario table as the shape for stateful work, through the new `patches/mattpocock/to-spec/SKILL.md.patch`, which applies under sync.
6. Criterion 6: `core/SCENARIO-TABLE.md` is in `CORE_DOCS`, has an INDEX row, and is copied slim to `template/docs/factory918/`. The `knowledge` skill's fallback line lists it. The page covers what the table is, its shape, and the #42 example. Its table rows match the current body of ticket #42 exactly: I fetched the body and diffed the rows. `build_knowledge.py` in a scratch copy leaves `docs/` and `template/` unchanged, `check_knowledge.py` prints `knowledge ok: 119 files`, and `tests/spec-review/no-stale-wording.sh` passes. The docstring at `tools/build_knowledge.py:8` still says only PHILOSOPHY, MANUAL, DECISIONS and GLOSSARY are copied.
7. `docs/agents/issue-tracker.md` and its template copy add the two optional sections after `## Blocked by`, each with the posted/approved first line.
8. DECISIONS P25, the glossary entry and the AGENTS.md change from "five" to "six core documents" record the choice.
9. Run-under rules 6 to 8: the diff touches no hook, settings file or `factory918` skill file, so the brief has no blast-radius grounding to walk. It changes no shell file.
10. Ticket step 1 (`ticket.md:5`) runs `overlap.sh N`, which reads the ticket body's backticked tokens and skips only a `## Diff` section (`overlap.sh:48`).

## Would break

1. **A posted table's backticked tokens become the ticket's named paths for overlap.sh.**
   ```
   The Ticket playbook's architect step says that when a design adds state, the table is appended to the ticket's body under `## Testing decisions` ... before implementation
   ```
   Documented step: `template/.agents/skills/poteto-mode/playbooks/ticket.md:5`, step 1, "a path the ticket names in backticks", together with step 6 (`ticket.md:10`), which now writes a table into that same body.
   Result: `overlap.sh:48` skips only `## Diff`, so every backticked token in a posted table or sketch counts as a pathspec the next time step 1 runs on that ticket. A re-run is the #87 to #92 pattern this ticket's own Problem describes. I ran the script's awk and grep over a body with a `## Testing decisions` table, and they produced `.claude/state/program` and `/etc/hosts` as named paths next to the real `tools/x.sh`. The first causes a false overlap stop (exit 1) against any PR that touches that file. The second makes git fail, so the check exits 2 (the #42 table's row 14). The #42 table itself had to leave its dot-dot and absolute paths unbackticked for this reason, and ticket #42 now carries a line "Amended 2026-09-22 by #89" saying the check should skip `## Testing decisions` and `## Design`. Neither `overlap.sh` nor `tests/poteto-mode/overlap.sh` does that at this commit.
   spec: criterion 3

2. **The table exists only when architect runs, and a stateful change can skip architect.**
   ```
   The Ticket playbook's architect step says that when a design adds state, the table is appended to the ticket's body under `## Testing decisions` ... before implementation
   ```
   Documented step: `ticket.md:10` ("The selected playbook's architect step adds the ticket's own: when the design adds state ..."). The ticket's "The artifacts" says "For anything with state, the scenario table", and only the stateless sketch is limited to code that crosses a function boundary.
   Result: Bug fix step 3 and Perf issue step 3 run `architect` only "if it crosses a function boundary", and Feature step 2 still accepts `architect skipped: <reason>` for any diff that is not cross-cutting. A stateful fix inside one function, or a stateful feature whose owner skips architect, reaches delegation with no table. Nothing flags the gap. The delegation step's "When it is a scenario table" clause just doesn't fire. That is the failure named in the Problem: "nothing sent it back for them when the design added state".
   spec: criterion 3

## Fails open

## Not asked for

3. **An unrelated ledger line.** The diff adds `docs/agents/ledger.md` line 2026-09-22 about a turn that ended while explorer lanes were still reading. It records a process surprise from this run and changes no behaviour, but no criterion asked for it.
   ```
   The knowledge base has one page on the table (what it is, the shape, the #42 example), reachable through `/knowledge scenario table`.
   ```

hard findings: 2
