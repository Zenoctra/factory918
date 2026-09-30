## Walk

1. Ticket playbook step 6 (`template/.agents/skills/poteto-mode/playbooks/ticket.md`) now reads the current ticket body with `gh issue view N --json body -q .body`, appends the `## Testing decisions` or `## Design` section, and writes the whole file back with `gh issue edit N --body-file`, stopping and reporting if the write fails.
2. `docs/knowledge/core/SCENARIO-TABLE.md` and its `template/docs/factory918/SCENARIO-TABLE.md` mirror describe the same read-modify-write-whole-file procedure and add the sentence that the step-1 overlap check skips both sections.
3. `overlap.sh`'s ticket-body branch (`if [ -z "$diff" ]`) extends the awk skip regex from `## Diff` alone to `## (Diff|Testing decisions|Design)`, so backticked tokens under the two new headings are dropped before the path match runs.
4. `tests/poteto-mode/overlap.sh` gains a fixture with tokens under both new headings and asserts `paths: none`, and its header comment is reworded to list all three skipped headings.
5. `template/.agents/skills/architect/SKILL.md` Phase B and the new `patches/pstack/architect/SKILL.md.patch` both gain the identical sentence routing a design-with-state's package through the scenario table, contract, and test list; `patches/series` gains the corresponding new line.
6. `to-spec/SKILL.md` and its `patches/mattpocock/to-spec/SKILL.md.patch` mirror reword the Testing Decisions bullet so the table is excluded from the "no snippet" rule as a decision, matching the vendored `architect` runner prompt's phrasing (per `SOURCES.md` decision 14, unchanged here).
7. `docs/knowledge/core/MANUAL.md` and its template mirror bump "first four" to "first five" project documents, add a `SCENARIO-TABLE.md` bullet, and the core copy's header line count goes 174 to 175.
8. `tools/build_knowledge.py`'s comment is reworded from naming four core docs to "every core document except CONVERSATION-DIGEST", matching the five-document count above.

## Would break

## Fails open

## Not asked for

hard findings: 0
