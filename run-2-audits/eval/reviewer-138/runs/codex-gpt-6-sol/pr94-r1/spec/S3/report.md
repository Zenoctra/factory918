## Walk

1. The Architect runner prompt asks stateful candidates for a scenario table first, followed by its contract and cell-ordered test list; stateless code crossing a function boundary gets a usage and signature sketch.
2. The runner prompt gives outside-path cells the tool-refusal wording and requires an observed refusal before cutting one.
3. Ticket step 6 instructs the agent to append the synthesized artifact to the ticket with the dated first line; `review-brief.sh` reads the whole ticket body into the Spec brief.
4. Feature, Bug fix, Refactoring and Perf issue delegation text tells the writer to test each table cell before implementation and report any cell it cannot implement.
5. The `to-spec` Testing Decisions list names the scenario table as the shape for stateful work, and its pinned-upstream patch matches.
6. The new core scenario-table page is indexed, generated into the project template, and passes `tools/check_knowledge.py`; the Knowledge skill selects a corpus and starts by reading its index.
7. The playbook and documentation changes preserve patch provenance in `patches/series` and `SOURCES.md`; the changed playbook patches match their pinned upstream files.

## Would break

1. **The documented slim Knowledge fallback cannot open the page.** The changed Knowledge skill promises the scenario table in the project's slim corpus, but its first procedure step requires an `INDEX.md` that the slim corpus does not contain. In a project using that documented fallback, `/knowledge scenario table` stops at a missing file before it can locate `SCENARIO-TABLE.md`.

   Documented step: `template/.agents/skills/knowledge/SKILL.md:13` selects “this project's `docs/factory918` (slim: philosophy, manual, decisions, glossary and the scenario table only...)”; line 17 then says “Read `$KB/INDEX.md` whole.”

   Result: `template/docs/factory918/` has `SCENARIO-TABLE.md` but no `INDEX.md`, so the lookup cannot follow its own first step when neither `$FACTORY918_HOME` nor `~/.factory918` supplies the full corpus.

   spec: criterion 6

   ```text
   - [ ] The knowledge base has one page on the table (what it is, the shape, the #42 example), reachable through `/knowledge scenario table`.
   ```

## Fails open

## Not asked for

hard findings: 1
