## Would break

1. **The slim knowledge lookup stops before reaching the new page.** `template/.agents/skills/knowledge/SKILL.md:13-17` documents the project copy as a fallback and requires `$KB/INDEX.md` as the first step. The project copy contains `SCENARIO-TABLE.md` but no `INDEX.md`, so that documented fallback cannot complete `/knowledge scenario table`.

   Documented step: Ticket acceptance criterion 6: "The knowledge base has one page on the table (what it is, the shape, the #42 example), reachable through `/knowledge scenario table`."

   Result: With neither `$FACTORY918_HOME` nor `~/.factory918/docs/knowledge` available, the skill selects `docs/factory918` and its first required read fails on the missing `INDEX.md`.

   spec: criterion 6

   ```diff
   -`$FACTORY918_HOME/docs/knowledge` if that variable is set; else `~/.factory918/docs/knowledge`; else this project's `docs/factory918` (slim: philosophy, manual, decisions and glossary only, with no header or mini-TOC, so take line numbers from grep and `wc -l`). Call it `$KB`.
   +`$FACTORY918_HOME/docs/knowledge` if that variable is set; else `~/.factory918/docs/knowledge`; else this project's `docs/factory918` (slim: philosophy, manual, decisions, glossary and the scenario table only, with no header or mini-TOC, so take line numbers from grep and `wc -l`). Call it `$KB`.
   ```

## Fails open

## Standards breaches

2. **The manual's project document count is stale.** `CODING_STANDARDS.md`, Markdown rule "A count or a version in prose is true at the commit that lands it," applies to `docs/knowledge/core/MANUAL.md:165`. It still says a project carries "only the first four" documents. `build_core()` now copies five, including the scenario table, into `template/docs/factory918/`.

   ```diff
   +    ("core/SCENARIO-TABLE.md", "Factory918: the scenario table", "Designing or reviewing anything with state: a file, exit codes, more than one actor."),
   ```

## Fix alongside

hard findings: 1
