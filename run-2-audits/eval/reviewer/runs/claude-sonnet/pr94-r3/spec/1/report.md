## Walk

1. `docs/agents/issue-tracker.md` and its template copy gain one sentence: each of the two architect sections (`## Testing decisions`, `## Design`) holds the whole artifact, with `###` headings for its parts, because the overlap check skips a section only up to the next `## ` heading.
2. `docs/knowledge/core/SCENARIO-TABLE.md` and its template copy, in the paragraph about `## Design` (code with no state), add: "The whole artifact stays inside the one section, its parts (the legend, the table, the contract, the test list) under `###` headings, because the skip ends at the next `## ` heading."
3. The same files' `#42 example` section notes that #42's table and contract predate the rule and sit under their own `## ` headings there, while a table posted from now on keeps its parts under `###` inside the one section.
4. `template/.agents/skills/poteto-mode/playbooks/ticket.md` step 6 adds the matching sentence, enumerating both artifacts' parts: "the legend, the table, the contract and the test list, or the usage and the signatures."
5. `template/.agents/skills/poteto-mode/scripts/overlap.sh`'s header comment is reworded to say the skip runs "up to the next `## ` heading." The boundary check itself, `awk '/^## /{skip=($0 ~ /^## (Diff|Testing decisions|Design)[[:space:]]*$/)} !skip'`, only re-evaluates `skip` on a line matching `^## ` (two hashes, then a space); a `### ` line never matches that pattern, so `skip` stays true through it. No code change was needed for the new convention.
6. `tests/poteto-mode/overlap.sh` adds a `### Contract` block with a path token inside `## Testing decisions`, before `## Design`, and confirms the token is still ignored (exit 0, `paths: none`).

## Would break

1. **The `## Design` paragraph lists the table's parts, not the sketch's.** In `docs/knowledge/core/SCENARIO-TABLE.md` and `template/docs/factory918/SCENARIO-TABLE.md`, the new sentence sits inside the paragraph describing the `## Design` section (the usage-and-signature sketch for code with no state) but names only the scenario table's parts.
   Documented step:
   ```
   The step-1 overlap check skips both sections, so a path a cell quotes does not count as a path the ticket names. The whole artifact stays inside the one section, its parts (the legend, the table, the contract, the test list) under `###` headings, because the skip ends at the next `## ` heading. A prose change has its acceptance criteria and nothing else.
   ```
   Result: a reader following this paragraph for the `## Design` case is told its parts are "the legend, the table, the contract, the test list" — a scenario table's parts, not a sketch's (usage and signatures). The Ticket playbook's own copy of this sentence avoids the error by naming both: "the legend, the table, the contract and the test list, or the usage and the signatures." SCENARIO-TABLE.md's version, appearing in the same commit, gives the wrong list for the section it is attached to.

## Fails open

## Not asked for

hard findings: 1
