## Would break

## Fails open

## Standards breaches

1. **The manual still says a project carries four knowledge files.** `CODING_STANDARDS.md`, Markdown: "A count or a version in prose is true at the commit that lands it". This change makes `build_core` copy `SCENARIO-TABLE.md` into `template/docs/factory918/`, so a project now carries five files there. The manual's list below this line still names four and leaves out the scenario table. The line is in `docs/knowledge/core/MANUAL.md:165` and its generated copy `template/docs/factory918/MANUAL.md:146`. Neither is in the diff, but the diff is what made them false. The knowledge skill's own "slim" list was updated in the same change.

   ```
   Everything below lives in the factory clone (`~/.factory918`); a project carries only the first four, under `docs/factory918/`.
   ```

2. **The build script's docstring still lists four slim copies.** Same rule, `CODING_STANDARDS.md`, Markdown: "A count or a version in prose is true at the commit that lands it". The CORE_DOCS tuple added in `tools/build_knowledge.py` makes `build_core` copy every core document except CONVERSATION-DIGEST.md, which now includes SCENARIO-TABLE.md. The module docstring at lines 6-9 still names only the first four:

   ```
     docs/knowledge/core/*.md                 HAND-MAINTAINED. Edit these files directly. This script only
                                              refreshes the header line and the mini-TOC of each one in place,
                                              then copies PHILOSOPHY, MANUAL, DECISIONS and GLOSSARY (headers
                                              stripped) into template/docs/factory918/ for projects.
   ```

## Fix alongside

3. **Duplicated Code: the writer rule is pasted into four playbooks, and "has state" is defined differently in different places.** The same sentence goes verbatim into four patches, and each copy then needs its own edit in the future: `bug-fix.md.patch`, `feature.md.patch`, `perf-issue.md.patch` and `refactoring.md.patch`. The definition of "state" is also repeated about seven times, and the copies already differ. The runner prompt, Ticket step 6, P25 and the page say "a file it reads or writes, exit codes, rounds, or more than one actor". The to-spec patch drops "rounds", and the INDEX/CORE_DOCS "read when" line drops "rounds" too. Every playbook brief already goes through Ticket step 6, so the writer rule could live there once and each playbook could point to it.

   ```
   +... The brief carries the ticket's design artifact (Ticket step 6). When it is a scenario table, the writer writes the test from the table before the implementation, one assertion per cell in the table's order, and the commit order shows it; a writer that cannot implement a cell as written stops and reports the cell, and never fills it in.
   ```
   ```
   +- For stateful work (a file read or written, exit codes, more than one actor), the shape is the scenario table: ...
   ```

4. **The project copy of the page points at factory-only artifacts.** `template/docs/factory918/SCENARIO-TABLE.md` ships to every project. Several of its pointers exist only in the factory repository: "ticket #42 and the description of PR #92", "Read the table beside `tests/poteto-mode/overlap.sh`", and "The ledger records why" (the quoted line is in the factory's ledger). In a project, `#42` resolves to that project's own issue 42, and `tests/poteto-mode/` does not exist. The example is inlined verbatim, so a writer does not need these pointers. They could be qualified as the factory repository's (for example, `Zenoctra/factory918#42`), or cut from the project copy.

   ```
   +The durable copy is the `## Testing decisions` section of ticket #42 and the description of PR #92. The legend and the table, verbatim:
   ...
   +Read the table beside `tests/poteto-mode/overlap.sh`: its header says the cases run in the order of the table, and each case asserts the exit code and the output of one call.
   ```

5. **A posted table feeds its backticked tokens to `overlap.sh`.** Ticket step 6 appends the table to the ticket body. `overlap.sh` reads every backticked token outside `## Diff` as a pathspec (`template/.agents/skills/poteto-mode/scripts/overlap.sh:48`). Any rerun of Ticket step 1 after step 6 therefore matches the table's tokens, for example when an owner is relaunched. A dot-dot or absolute path in a cell exits 2 (row 14), and a real path widens the overlap. Both results are loud, so this does not fail open. The #42 example already had to unbacktick a path "so this ticket's own check does not trip on it". One sentence in step 6 or on the page would cover it. The other option is for `overlap.sh` to skip `## Testing decisions` and `## Design` along with `## Diff`.

   ```
   +... before implementation the synthesized table is appended to the ticket's body under `## Testing decisions` with `gh issue edit N --body-file`, ...
   ```

6. **The page mixes Diátaxis modes.** `CODING_STANDARDS.md` asks for "One Diátaxis mode per file". `SCENARIO-TABLE.md` combines an explanation ("What it is", "Why"), a reference ("The shape", the verbatim #42 table) and procedure ("Where it goes": `gh issue edit`, the first-line format). The other core documents mix modes too, and the page reads mainly as an explanation, so this is a judgement call rather than a breach.

   ```
   +This page says what the table is, what shape it takes, where it goes, and why two runs of the same ticket made it a rule.
   ```

hard findings: 0
