## Walk

1. Criterion 1, runner prompt through its patch: `patches/pstack/architect/references/runner-prompt.md.patch` is listed in `series`. The template copy puts the scenario table, then the contract, then the test list first for designs with state, and the usage and signature sketch first for stateless code that crosses a function boundary, posted under `## Design`. I ran `./factory918.sh sync` in a scratch git copy: all 19 patches applied and `git status` stayed clean.
2. Criterion 2: the runner prompt has the "refused with the tool's own message" cell, which costs no code, and says such a cell is cut only after the refusal was run and seen.
3. Criterion 3, Ticket step 6 (`ticket.md:10`): the table goes under `## Testing decisions` through `gh issue edit N --body-file` before implementation, with the first line `Posted by the agent <date>` or `Approved by <name> <date>`. The human edits it, and the only way to stop is `/architect with checkpoint`, which is supported at `architect/SKILL.md:48`. The step says that the Spec brief carries the table. `review-brief.sh:218-222` pastes the whole body.
4. Criterion 4: Feature step 4, Bug fix step 3, Refactoring step 5 and Perf issue step 3 each carry the same writer sentence, through their patches, and sync reproduces them. SOURCES item 13 is extended.
5. Criterion 5: the `to-spec` Testing Decisions bullet is added through the new `mattpocock/to-spec/SKILL.md.patch`, and sync applies it.
6. Criterion 6: the new core page is `core/SCENARIO-TABLE.md` (what it is, the shape, the #42 legend and table, why). It has an INDEX row, and `build_knowledge.py` leaves the tree clean with `check_knowledge.py` passing on 119 files. The template copy is under `docs/factory918/`, and the knowledge skill's slim list and the glossary entry both name it. Grepping "scenario table" reaches it.
7. `issue-tracker.md` (both copies) adds the two optional sections to the ticket shape. DECISIONS adds P25.

## Would break

1. **A posted table becomes overlap pathspecs.**
```
before implementation the synthesized table is appended to the ticket's body under `## Testing decisions`
```
Documented step: `template/.agents/skills/poteto-mode/playbooks/ticket.md:10`, together with P24 ("matched with the ticket body's backticked tokens as pathspecs (its `## Diff` section excluded)").
Result: `overlap.sh:48` skips only `## Diff`. When Ticket step 1 runs again on a ticket that already has a table (for example a second run, as #42 had), every backticked path in the table is matched as a pathspec. The check can then stop on false overlaps (exit 1), or on exit 2 when a path is absolute or uses `..`. The live #42 body says "Amended 2026-09-22 by #89: the check skips a `## Testing decisions` or `## Design` section", but no such change is in this diff.
spec: criterion 3

## Fails open

2. **A stateful design whose playbook skips `architect` gets no table, and nothing says so.**
```
The selected playbook's architect step adds the ticket's own: when the design adds state
```
Documented step: `ticket.md:10`. Also `feature.md:6` ("Skipping stays as `architect skipped: <reason>`") and `bug-fix.md` step 3 ("If it crosses a function boundary, `architect` first").
Result: a stateful change that stays inside one function (Bug fix, Perf issue), or a skip that is not cross-cutting (Feature), reaches implementation with no table and no message. That is the gap the ticket's Problem names: "nothing sent it back for them when the design added state".
spec: criterion 3

## Not asked for

3. **An unrelated ledger line.** `docs/agents/ledger.md` adds 2026-09-22, "ended its turn while two explorer lanes were still reading". The line is about draining lanes, not the scenario table.
```
- [ ] The knowledge base has one page on the table
```
4. **A finding about sync outside the ticket's scope.** The second sentence of the new `docs/M0-findings.md` line records that sync bumps no VERSION, which contradicts `SOURCES.md` line 3. That is unrelated to #89, and line 3 is left wrong.
```
- [ ] `to-spec`'s Testing decisions section (through its patch or the factory's copy)
```

hard findings: 2
