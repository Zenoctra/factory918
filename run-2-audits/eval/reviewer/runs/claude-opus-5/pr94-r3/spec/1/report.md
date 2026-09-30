# Spec report

The change says one thing in five places: a design artifact posted on a ticket stays inside its single `## ` section, with `###` for its parts, because the overlap check's skip ends at the next `## ` heading. I checked that claim against the awk that implements the skip and against the fixture that now exercises it; both hold.

## Walk

1. `docs/agents/issue-tracker.md` and its `template/` copy describe the ticket shape and now add the rule to the `## Testing decisions` / `## Design` paragraph: each section holds the whole artifact, `###` for the parts, "since the overlap check skips a section up to the next `## ` heading". The two files stay identical, as AGENTS.md requires.
2. `docs/knowledge/core/SCENARIO-TABLE.md` states the posting rule and now names the parts that stay inside the one section: legend, table, contract, test list.
3. `template/docs/factory918/SCENARIO-TABLE.md`, the generated copy, carries the same two edits verbatim, so a rebuild is consistent. No `docs/knowledge/pages/` or `notes/` file quotes these paragraphs, so nothing else needed regenerating.
4. `SCENARIO-TABLE.md`'s #42 example now says #42's own record predates the rule and keeps its table and contract under separate `## ` headings, and that tables posted from now on use `###`.
5. Ticket playbook step 6 states the rule where the agent that posts the artifact reads it, naming both artifact shapes.
6. `overlap.sh`'s header comment now says the three sections are skipped "up to the next `## ` heading". `overlap.sh:49` is `awk '/^## /{skip=(...)} !skip'`: the state flips only on a line matching `^## `, and `### Contract` does not match, so the comment is accurate and the code is unchanged.
7. `tests/poteto-mode/overlap.sh` adds a `### Contract` holding `src/x/y.txt` inside the `## Testing decisions` fixture and still expects `paths: none`. Check 18 shows PR 2 touches `src/x/y.txt`, so the assertion would fail if the skip ended at `###`; the header comment records the new coverage.

## Would break

## Fails open

## Not asked for

hard findings: 0
