## Would break

1. **A stateful change can reach implementation without a scenario table.** `docs/knowledge/core/DECISIONS.md` P25 requires the table before implementation for any design with state. Ticket step 6 relies on the selected playbook's `architect` step, but Feature step 2 still permits skipping `architect` for a non-cross-cutting stateful change. Bug fix step 3, Perf issue step 3, and Refactoring step 3 invoke it only for a function boundary or a cross-cutting diff.

   Documented step: `template/.agents/skills/poteto-mode/playbooks/ticket.md:10` says that "when the design adds state ... before implementation the synthesized table is appended to the ticket's body."

   Result: The writer receives no table, so the new conditional instruction to write one assertion per cell never applies. Implementation starts without the ticket's required design artifact.

   spec: criterion 3

   ```diff
   +2. `architect` for parallel design exploration. Skipping stays as `architect skipped: <reason>`, not accepted for a cross-cutting diff (Ticket step 5); do not fold the design decision silently into implementation.
   +6. The spec's **Testing decisions** are the pre-agreed seams. `tdd` there, and nowhere the spec did not agree unless a criterion needs it. The selected playbook's architect step adds the ticket's own: when the design adds state (a file it reads or writes, exit codes, rounds, or more than one actor), `architect`'s first deliverable is the scenario table (its runner prompt gives the shape), and before implementation the synthesized table is appended to the ticket's body under `## Testing decisions` with `gh issue edit N --body-file`, first line `Posted by the agent <date>`, or `Approved by <name> <date>` when the human approved it first.
   ```

2. **The project-only knowledge path cannot reach the new page.** `template/.agents/skills/knowledge/SKILL.md`, "Where the corpus is" and Procedure step 1, documents `docs/factory918` as the fallback and then requires `$KB/INDEX.md`. The changed fallback now promises the scenario table, but `template/docs/factory918/` contains only the five slim documents and has no `INDEX.md`.

   Documented step: `template/.agents/skills/knowledge/SKILL.md:13-17` says to choose this project's `docs/factory918` if neither factory home exists, then read `$KB/INDEX.md` whole.

   Result: In that documented fallback, `/knowledge scenario table` stops at the missing index instead of finding `SCENARIO-TABLE.md`.

   spec: criterion 6

   ```diff
   +`$FACTORY918_HOME/docs/knowledge` if that variable is set; else `~/.factory918/docs/knowledge`; else this project's `docs/factory918` (slim: philosophy, manual, decisions, glossary and the scenario table only, with no header or mini-TOC, so take line numbers from grep and `wc -l`). Call it `$KB`.
   ```

## Fails open

## Standards breaches

## Fix alongside

hard findings: 2
