Run on a copy of the reviewed tree (the review directory is not a git checkout): `python3 tools/build_knowledge.py` left the tree unchanged and `python3 tools/check_knowledge.py` printed `knowledge ok: 119 files`; `./factory918.sh sync` applied all 19 patches, both new ones included, and left the tree unchanged; `tests/hooks/delegation.sh` (55), `tests/spec-review/review-comment.sh` (82), `tests/spec-review/review-brief.sh` (334), `tests/poteto-mode/overlap.sh` (56) and `tests/spec-review/no-stale-wording.sh` passed. The M0 finding's three claims (one CORE_DOCS tuple, `build_core` skips only CONVERSATION-DIGEST.md, doctor checks only PHILOSOPHY and MANUAL at `factory918.sh:275`) hold against the code. `ticket.md` is in `sync`'s `keep_files` (`factory918.sh:381`), so editing it directly is correct.

## Would break

## Fails open

## Standards breaches

1. **P25 gets its own count wrong.** CODING_STANDARDS.md, Markdown: "A count or a version in prose is true at the commit that lands it". At this commit, "Ticket step 5" appears in six patches, not four: feature, bug-fix, perf-issue, refactoring, opening-a-pr (`(Ticket step 5)`) and `mattpocock/spec-review.SKILL.md.patch` (`(the Ticket playbook, step 5)`). `review-brief.sh` never quotes the step number. Its comment at line 183 says only "the Ticket playbook says it in words". The reason still holds, but the numbers don't. The same text lands in both `docs/knowledge/core/DECISIONS.md` and the generated `template/docs/factory918/DECISIONS.md`.
   ```
   +| P25 | The design artifact on the ticket | ... Choices made in #89: the rule lives in Ticket step 6 (no renumbering, since "Ticket step 5" is quoted in four patches and `review-brief.sh`); ...
   ```

2. **The manual still says a project carries four knowledge documents.** CODING_STANDARDS.md, Markdown: "A count or a version in prose is true at the commit that lands it". This diff makes `build_core` copy a fifth document, `SCENARIO-TABLE.md`, into `template/docs/factory918/`. It also updated the matching list in `knowledge/SKILL.md`. `docs/knowledge/core/MANUAL.md:165`, "Where to read more", was left unchanged, as was its generated copy at `template/docs/factory918/MANUAL.md:146`. That line still says a project carries "only the first four", and the list under it has no entry for the scenario table page.
   ```
   +    ("core/SCENARIO-TABLE.md", "Factory918: the scenario table", "Designing or reviewing anything with state: a file, exit codes, more than one actor."),
   ```
   Unchanged, now false (MANUAL.md:165):
   ```
   Everything below lives in the factory clone (`~/.factory918`); a project carries only the first four, under `docs/factory918/`.
   ```

## Fix alongside

3. **Duplicated Code / Shotgun Surgery: the definition of "state" is written out in six places, and the copies disagree.** The runner prompt and P25 say "a file it reads or writes, exit codes, rounds, or more than one actor". The to-spec patch, the CORE_DOCS "read when" line and INDEX.md drop "rounds". The scenario table page says "review rounds". A writer or reviewer looking at the to-spec copy would treat a design whose only state is rounds as stateless. The four playbook patches also repeat the same writer sentence word for word. That part may be unavoidable with one patch per playbook, but the definition could live in one place (the page), with the others pointing to it.
   ```
   +- For stateful work (a file read or written, exit codes, more than one actor), the shape is the scenario table: ...
   ```
   ```
   +- With state (a file it reads or writes, exit codes, rounds, or more than one actor): a scenario table, ...
   ```

4. **The template's copy of the page points to a file only the factory has.** `template/docs/factory918/SCENARIO-TABLE.md` goes into every project, and its intro names "the agent that has to write one" as a reader. The #42 section then tells that reader to open a test file that `apply` does not copy. MANUAL.md does warn that its factory paths live "in the factory clone". This page has no such warning, so in a project the reference leads nowhere.
   ```
   +Read the table beside `tests/poteto-mode/overlap.sh`: its header says the cases run in the order of the table, and each case asserts the exit code and the output of one call.
   ```

5. **The appended `## Testing decisions` section is read as pathspecs.** `overlap.sh` treats every backticked token in the ticket body as a pathspec and skips only a `## Diff` section (`overlap.sh:48-50`, P24). A posted scenario table is full of backticked tokens (`G`, `B(x)`, state-file paths, and possibly a glob). If Ticket step 1 runs again after step 6 has posted the table, for example on a restart or a fresh owner, those tokens become pathspecs. A glob or a broad path produces a false exit 1, and an out-of-repo path produces exit 2. Both failures are loud, so this is a judgement call, not a hard finding. The fix would be to add `## Testing decisions` and `## Design` to the skipped sections, or to have the page say that the table's tokens count as ticket tokens.
   ```
   +The architect step may append two more sections before implementation, after these: `## Testing decisions`, the scenario table, when the design has state; `## Design`, the usage and signature sketch, ...
   ```

hard findings: 0
