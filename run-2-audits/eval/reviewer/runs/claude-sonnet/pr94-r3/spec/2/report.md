## Walk

1. `docs/agents/issue-tracker.md` (and its template copy) adds a sentence: each of `## Testing decisions` and `## Design` holds the whole artifact, with `###` headings for its parts, because the overlap check's skip runs up to the next `## ` heading.
2. `docs/knowledge/core/SCENARIO-TABLE.md` (and its generated `template/docs/factory918/` copy) adds the same rule after the `## Design` description: the legend, table, contract and test list stay under `###` inside the one `## ` section.
3. The same file's `#42 example` section notes that #42 predates the rule, so its table and contract sit under their own `## ` headings there, while a table posted from now on nests them under `###`.
4. `template/.agents/skills/poteto-mode/playbooks/ticket.md` step 6 adds the identical instruction for the artifact posted at ticket time, still citing that the step-1 overlap check skips to the next `## ` heading.
5. `overlap.sh`'s header comment is reworded to say the skip over `## Testing decisions` and `## Design` runs "up to the next `## ` heading," documenting existing skip behavior rather than changing it (no code in the shown diff changes).
6. `tests/poteto-mode/overlap.sh` test 17's fixture gains a `### Contract` subsection (with a backticked path, `src/x/y.txt`) inside `## Testing decisions`, and the check name is updated to `"...with ### parts) and ## Design ignored"`, still expecting `go: none`.

## Would break

None.

## Fails open

None.

## Not asked for

None. The five documentation edits and the one test-fixture edit are all consistent restatements of a single rule (design-artifact parts nest under `###` inside their one `## ` section), and the source/generated doc pairs (`docs/agents/issue-tracker.md` ↔ `template/docs/agents/issue-tracker.md`; `docs/knowledge/core/SCENARIO-TABLE.md` ↔ `template/docs/factory918/SCENARIO-TABLE.md`) carry identical wording, so nothing drifted between source and copy.

hard findings: 0
