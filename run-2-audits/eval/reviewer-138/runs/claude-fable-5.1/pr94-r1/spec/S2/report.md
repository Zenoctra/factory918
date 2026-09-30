# Spec report, ab47eb9 (#89)

## Walk

1. Criterion 1, the runner prompt: `template/.agents/skills/architect/references/runner-prompt.md:5-10` makes the first deliverable depend on state: with state, table, then contract, then test list, with the situations, input shapes, cell contents, legend, contract terms and per-cell assertion order spelled out; without state but across a function boundary, the usage and signature sketch. Line 10 says the orchestrator appends the synthesized first deliverable to the ticket, table under `## Testing decisions`, sketch under `## Design`, naming Ticket step 6. `patches/pstack/architect/references/runner-prompt.md.patch` produces this text; it is in `patches/series` and `./factory918.sh sync` on a copy of the checkout applied every patch and left `template/` byte-identical.
2. Criterion 2: `runner-prompt.md:7` carries both sentences, "refused with the tool's own message" costing no code, and a cut only after the refusal was run and seen.
3. Criterion 3, the Ticket playbook: `ticket.md:10` (step 6) says when the design adds state the table is appended with `gh issue edit N --body-file`, first line `Posted by the agent <date>` or `Approved by <name> <date>`, before implementation; the sketch goes under `## Design` the same way; prose has no artifact; the human edits the ticket; a stop only with `/architect with checkpoint`; the Spec brief carries the table because `review-brief.sh` pastes the ticket body. `review-brief.sh:222-223` fetches `gh issue view N --json body -q .body` whole and pastes it under `## The ticket (#N)`, so an appended section reaches the reviewer with no other change. `architect/SKILL.md:48` already recognizes the phrase "/architect with checkpoint". `ticket.md` is in sync's `keep_files`, so it needs no patch.
4. Criterion 4, the four delegation steps: `feature.md:8` (step 4), `bug-fix.md:8` (step 3), `perf-issue.md:16` (step 3), `refactoring.md:11` (step 5) each carry "The brief carries the ticket's design artifact (Ticket step 6). When it is a scenario table, the writer writes the test from the table before the implementation, one assertion per cell in the table's order, and the commit order shows it; a writer that cannot implement a cell as written stops and reports the cell, and never fills it in." The four patches reproduce them under sync.
5. Criterion 5: `to-spec/SKILL.md:66` adds the scenario table as the Testing Decisions shape for stateful work, with the note that it is a decision, not a snippet; `patches/mattpocock/to-spec/SKILL.md.patch` follows the `patches/README.md` path form and applies under sync.
6. Criterion 6: `docs/knowledge/core/SCENARIO-TABLE.md` (88 lines: what it is, the shape, where it goes, the #42 legend, table and contract opening, why) is a `CORE_DOCS` tuple in `tools/build_knowledge.py:42`; `INDEX.md:15` lists it with "Designing or reviewing anything with state"; `python3 tools/build_knowledge.py` on a copy reproduced `docs/knowledge/` and `template/docs/factory918/` byte-identical and `check_knowledge.py` reports 119 files ok. `build_core` copies it to the slim set, and `knowledge/SKILL.md:13` now names the slim set as five documents. The docstring at `build_knowledge.py:8` still lists four.
7. Records: `DECISIONS.md` P25, the glossary entry, `issue-tracker.md` (both copies identical) naming the two optional sections, `SOURCES.md` items 13 to 15, the M0 line and the ledger line. `tests/spec-review/no-stale-wording.sh` and `tests/spec-review/review-brief.sh` (334 assertions) pass; `tests/knowledge/provisional-ids.sh` named in AGENTS.md does not exist in this checkout.

## Would break

1. **The gate to the table is "has state", but the gate to architect is "crosses a function boundary", and nothing joins them.** Ticket step 6 hangs the table on architect's first deliverable, but architect runs only when the selected playbook sends the work there: `bug-fix.md:8` "If it crosses a function boundary, `architect` first", the same in `perf-issue.md:16` and `refactoring.md:11`, and `feature.md:6` still accepts `architect skipped: <reason>` for any non-cross-cutting diff. A stateful change inside one function (a script gaining an exit code, a file written by one existing function, one more review round) never reaches architect, no table is written, and the delegation sentence is conditional ("When it is a scenario table"), so the writer proceeds with none. The only skip the diff closed is the cross-cutting one.
   ```
   - [ ] The Ticket playbook's architect step says that when a design adds state, the table is appended to the ticket's body under `## Testing decisions`, first line "Posted by the agent <date>" or "Approved by <name> <date>", before implementation
   ```
   Documented step: `template/.agents/skills/poteto-mode/playbooks/ticket.md:10`, "when the design adds state ... `architect`'s first deliverable is the scenario table"; `template/.agents/skills/poteto-mode/playbooks/bug-fix.md:8`, "If it crosses a function boundary, `architect` first"; `feature.md:6`, "Skipping stays as `architect skipped: <reason>`, not accepted for a cross-cutting diff".
   Result: a design that adds state without crossing a function boundary, or one the orchestrator skips architect on with a reason, reaches implementation and review with no table and no refusal; the ticket's "for anything with state, the scenario table" holds only when the function-boundary test happens to be met.
   spec: criterion 3

2. **The manual's map of the project copy says four documents and omits the page.** `build_core` now writes `SCENARIO-TABLE.md` into `template/docs/factory918/`, and `knowledge/SKILL.md:13` was updated to say so, but `docs/knowledge/core/MANUAL.md:164` still reads "a project carries only the first four, under `docs/factory918/`" and the list under it names MANUAL, PHILOSOPHY, DECISIONS and GLOSSARY only. A person who opens a ticket, finds a table under `## Testing decisions` (the reader the page's first paragraph names) and goes to the manual's "Where to read more" is told the project carries no such page.
   ```
   - [ ] The knowledge base has one page on the table (what it is, the shape, the #42 example), reachable through `/knowledge scenario table`.
   ```
   Documented step: `docs/knowledge/core/MANUAL.md:164-170`, "a project carries only the first four" and the four-item list.
   Result: the count is wrong (five are copied) and the one place the manual sends a human for more reading does not name the page; `/knowledge` finds it through `INDEX.md`, the human's own map does not.
   spec: criterion 6

## Fails open

## Not asked for

3. **Two records beyond the criteria.** `docs/agents/ledger.md:25` (a turn ended with two explorer lanes still reading) and the second sentence of the `docs/M0-findings.md` 2026-09-22 line (`sync` bumps no VERSION and touches no network, against `SOURCES.md` line 3) record things the run met, not things the ticket asked for. Both follow `AGENTS.md` "Pull requests" (a surprise goes to the ledger; a verified fact gets a dated M0 line), so nothing to act on; `SOURCES.md` line 3 itself is left saying what the finding contradicts.
   ```
   - [ ] `to-spec`'s Testing decisions section (through its patch or the factory's copy) names the table as the shape for stateful work.
   ```
   spec: criterion 5

hard findings: 2
