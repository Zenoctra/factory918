## Would break

## Fails open

## Standards breaches

1. **The build script's docstring still lists four slim copies.** `CODING_STANDARDS.md`, Markdown: "A count or a version in prose is true at the commit that lands it". This diff adds `core/SCENARIO-TABLE.md` to `CORE_DOCS` in `tools/build_knowledge.py`, and `build_core` copies every core document except `CONVERSATION-DIGEST.md` into `template/docs/factory918/`, as the new M0 finding says. The module docstring at lines 6-9 of the same file still names four documents and leaves out the scenario table. The build output is unaffected, but the prose is wrong for anyone who reads the header to find out what reaches a project.
   ```
     docs/knowledge/core/*.md                 HAND-MAINTAINED. Edit these files directly. This script only
                                              refreshes the header line and the mini-TOC of each one in place,
                                              then copies PHILOSOPHY, MANUAL, DECISIONS and GLOSSARY (headers
                                              stripped) into template/docs/factory918/ for projects.
   ```

2. **P25 gets the count of "Ticket step 5" quotes wrong.** `CODING_STANDARDS.md`, Markdown: "A count or a version in prose is true at the commit that lands it". The same wrong count is in `docs/knowledge/core/DECISIONS.md:93` and the generated `template/docs/factory918/DECISIONS.md:85`. At this commit, five patches quote `Ticket step 5`: `bug-fix`, `feature`, `opening-a-pr`, `perf-issue` and `refactoring`. `mattpocock/spec-review.SKILL.md.patch` also quotes "Ticket playbook, step 5". `review-brief.sh` never quotes the step. Its comment at line 183 reads "the Ticket playbook says it in words". The reason still holds, and holds more strongly with six quoting files, but the numbers and the named script are wrong.
   ```
   Choices made in #89: the rule lives in Ticket step 6 (no renumbering, since "Ticket step 5" is quoted in four patches and `review-brief.sh`)
   ```

3. **The new page mixes Diátaxis modes.** `CODING_STANDARDS.md`, Markdown: "One Diátaxis mode per file". The page's opening paragraph lists four modes. "What it is" and "Why" are explanation, "The shape" and "The #42 example" are reference, and "Where it goes" repeats the procedure in Ticket step 6, which is how-to. The other core pages each hold one mode: PHILOSOPHY is explanation, MANUAL is how-to, and DECISIONS and GLOSSARY are reference. This is a judgement call. The acceptance criterion asks for one page with "what it is, the shape, the #42 example", so reference and explanation are both requested. The how-to section is the part a single-mode page would drop in favour of a pointer to Ticket step 6.
   ```
   This page says what the table is, what shape it takes, where it goes, and why two runs of the same ticket made it a rule.
   ```

## Fix alongside

4. **Duplicated code: the writer clause is pasted into eight files.** The same two sentences appear in the delegation step of `feature.md`, `bug-fix.md`, `perf-issue.md` and `refactoring.md`, and again in each of their four patches. The rule is also stated in `SCENARIO-TABLE.md` and in Ticket step 6. Changing the rule later means changing it in eight places. This is Shotgun Surgery, the kind that already forced P25's "no renumbering" choice for `Ticket step 5`. Criterion 4 requires each playbook to state the rule. A single sentence in each playbook that points to Ticket step 6, with the full wording kept there, would meet the criterion and leave one place to edit.
   ```
   The brief carries the ticket's design artifact (Ticket step 6). When it is a scenario table, the writer writes the test from the table before the implementation, one assertion per cell in the table's order, and the commit order shows it; a writer that cannot implement a cell as written stops and reports the cell, and never fills it in.
   ```

5. **The project copy points to factory-only files.** `template/docs/factory918/SCENARIO-TABLE.md` ships into every project. Line 69 sends the reader to `tests/poteto-mode/overlap.sh`, a factory test that `apply` does not copy, so the file does not exist in a project. Line 42 calls "ticket #42" and "PR #92" the durable copy. In a project, `gh issue view 42` returns that project's own issue #42. The table is quoted in full on the page, so neither pointer is needed there. Naming the factory repository, or cutting both pointers from the project copy, would prevent the lookup that goes wrong.
   ```
   Read the table beside `tests/poteto-mode/overlap.sh`: its header says the cases run in the order of the table, and each case asserts the exit code and the output of one call.
   ```

hard findings: 0
