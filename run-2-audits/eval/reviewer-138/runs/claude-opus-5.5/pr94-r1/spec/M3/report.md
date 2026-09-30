## Walk

1. Criterion 1: `patches/pstack/architect/references/runner-prompt.md.patch` makes the first deliverable the scenario table, then the contract, then the test list when the design has state, and the usage and signature sketch for stateless code that crosses a function boundary. It also says the orchestrator appends the result to the ticket under `## Testing decisions` or `## Design`. The patch is in `series`. Applied to the pinned upstream with `git apply`, it reproduces `template/.agents/skills/architect/references/runner-prompt.md` byte for byte.
2. Criterion 2: the same runner-prompt paragraph says "refused with the tool's own message", "costs no code", and that such a cell is cut only after the refusal was run and seen.
3. Criterion 3: `ticket.md:10` (step 6) appends the table under `## Testing decisions` before implementation, with the first line `Posted by the agent <date>` or `Approved by <name> <date>`. It says the human edits the table, a stop is asked for only with `/architect with checkpoint` (the phrase `architect/SKILL.md:48` recognises), and `review-brief.sh` pastes the body. The pasting claim holds: `review-brief.sh:222` fetches `gh issue view --json body` whole.
4. Criterion 4: the four playbook patches (Feature step 4, Bug fix step 3, Refactoring step 5, Perf issue step 3) carry the table-first test, one assertion per cell in order, and stop-and-report without filling. Each patch applies to upstream and matches the template copy.
5. Criterion 5: `patches/mattpocock/to-spec/SKILL.md.patch` adds a Testing Decisions bullet naming the table for stateful work. It is in `series`, applies to upstream, and matches the template copy.
6. Criterion 6: `docs/knowledge/core/SCENARIO-TABLE.md` is a sixth `CORE_DOCS` entry. It is in `INDEX.md` and copied (stripped) to `template/docs/factory918/`. The knowledge skill's slim-corpus line names it. `rg -i "scenario table"` finds it. `build_knowledge.py` rebuilt in a copy with no diff, and `check_knowledge.py` reports "knowledge ok: 119 files".
7. `docs/agents/issue-tracker.md` and its template copy describe the two optional sections. `GLOSSARY.md` adds the term. `DECISIONS.md` adds P25. `SOURCES.md` items 13 to 15 describe the patches.

## Would break

1. **A stateful design that skips `architect` gets no table, and nothing notices.**
```
The Ticket playbook's architect step says that when a design adds state, the table is appended to the ticket's body under `## Testing decisions`
```
Documented step: `template/.agents/skills/poteto-mode/playbooks/ticket.md:10`: "The selected playbook's architect step adds the ticket's own: when the design adds state ...". Also `feature.md:6`: "Skipping stays as `architect skipped: <reason>`". Also `bug-fix.md:11` and `perf-issue.md:16`: "If it crosses a function boundary, `architect` first".
Result: the table exists only when `architect` runs. `architect` is still skippable with a reason in Feature. In Bug fix, Perf issue and Refactoring it is required only across a function boundary. A change that adds an exit code or a state file inside one function, or a Feature with `architect skipped: <reason>`, reaches delegation without a table. The "When it is a scenario table" branch is quietly not taken. That is the gap the ticket's Problem names: "nothing sent it back for them when the design added state."
spec: criterion 3

2. **`gh issue edit N --body-file` replaces the ticket body. It does not append.**
```
the table is appended to the ticket's body under `## Testing decisions`, first line "Posted by the agent <date>" ... before implementation
```
Documented step: `ticket.md:10`: "the synthesized table is appended to the ticket's body under `## Testing decisions` with `gh issue edit N --body-file`".
Result: the step names a command that replaces the body and does not say to fetch the current body first. An agent that writes only the new section to the file overwrites the criteria, the Decision quotes and `## Blocked by`, and gets no error. `review-brief.sh` then pastes a spec that holds only the table.
spec: criterion 3

3. **The page that ships to projects points at the factory's #42, #92 and a test projects do not have.**
```
The knowledge base has one page on the table (what it is, the shape, the #42 example), reachable through `/knowledge scenario table`.
```
Documented step: `template/docs/factory918/SCENARIO-TABLE.md:42`: "The durable copy is the `## Testing decisions` section of ticket #42 and the description of PR #92". Also line 69: "Read the table beside `tests/poteto-mode/overlap.sh`".
Result: in a project, #42 and #92 resolve against the project's own tracker, so a reader gets a different issue or none. `template/` has no `tests/`, so the named test file does not exist. The inline example still reads correctly. The pointers for going further are wrong.
spec: criterion 6

## Not asked for

4. **Ledger line about lanes dying at turn end.**
```
2026-09-22 | fable | ended its turn while two explorer lanes were still reading ...
```
This records a surprise from the run and is unrelated to #89. `AGENTS.md` sends surprises to the ledger, so it is process, not scope.

5. **M0 finding on `sync` and VERSION.**
```
factory918.sh sync (0.3.0) bumps no VERSION and touches no network, against what SOURCES.md line 3 says; the code is the truth (#89).
```
This is outside the ticket. `SOURCES.md` line 3 still says `sync` will "re-fetch these pins ... and bump VERSION", which contradicts both this line and the code.

hard findings: 3
