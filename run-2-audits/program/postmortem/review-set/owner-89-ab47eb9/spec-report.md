## Walk

1. Runner prompt, patch and template: first deliverable is the table, contract and test list with state, else the sketch.
2. Same lines: the refusal cell, cut only after the refusal was run and seen.
3. Ticket step 6 appends the table under `## Testing decisions`, first line `Posted by the agent <date>`.
4. `docs/agents/issue-tracker.md`, both copies, adds the two sections to the ticket shape.
5. Feature 4, Bug fix 3, Refactoring 5, Perf issue 3: test from the table, one assertion per cell, writer stops on a cell it cannot implement.
6. `to-spec` names the table for stateful Testing decisions.
7. Sixth core document; `CORE_DOCS`, the INDEX row and the slim copy match `build_knowledge.py`.
8. `review-brief.sh:222` writes the whole body to the brief, so the table reaches the reviewer.
9. Every patch re-applies to the pins and reproduces the vendored file exactly.

## Would break

1. **The posted table becomes overlap.sh's pathspecs.** The check reads backticked tokens from every section but `## Diff`, and a table carries real paths: the #42 one has `.claude/state/program` and `tests/poteto-mode/overlap.sh`. Its row 14 unbackticks paths "so this ticket's own check does not trip on it"; nothing generalises it.
```
- [ ] The Ticket playbook's architect step says that when a design adds state, the table is appended to the ticket's body under `## Testing decisions`
```
Documented step: `playbooks/ticket.md:6` with `overlap.sh:5`, "tokens without whitespace, those under `## Diff` skipped".
Result: a later check on that ticket (#42 ran twice) matches unrelated PRs and exits 1, or exits 2 on a dot-dot token; both look normal.

2. **architect's own skill still says usage first.** Only the runner prompt was patched, and it sends each runner to read the skill in full, where Phase B and Output shape define a candidate as usage, sketch and module map per `rationale-template.md`, which has no table slot.
```
- [ ] `architect`'s runner prompt (through its patch) makes the first deliverable ... the scenario table
```
Documented step: `architect/SKILL.md:32` and `:84`.
Result: a candidate or the synthesis returns no table, and step 6 has nothing to post.

3. **The map still says four project documents.** `build_core` copies five now, and `knowledge/SKILL.md` was updated; the reader's list was not, nor `build_knowledge.py:8`.
```
- [ ] The knowledge base has one page on the table ... reachable through `/knowledge scenario table`.
```
Documented step: `docs/knowledge/core/MANUAL.md:165`, "a project carries only the first four".
Result: the map a person reads omits the page.

## Fails open

4. **A failed post does not stop the work.** Step 8 stops when its check cannot run, "Exit 2: stop and report stderr"; step 6 has no clause for `gh issue edit` failing.
```
- [ ] ... the table is appended to the ticket's body ... before implementation
```
Documented step: `playbooks/ticket.md:6`.
Result: implementation and review go on with no artifact on the ticket, silently.

## Not asked for

hard findings: 4
