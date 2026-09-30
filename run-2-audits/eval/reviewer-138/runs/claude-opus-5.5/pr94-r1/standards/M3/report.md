# Standards review, ab47eb9

Checks run on a copy of the tree taken at this commit: `./factory918.sh sync` applied all 19 patches in `series`, including the two new ones, and left `template/` byte-identical to the original (`diff -rq` empty). `python3 tools/build_knowledge.py` left `docs/` and `template/` byte-identical (119 files), and `python3 tools/check_knowledge.py` passed. These tests also passed: `tests/spec-review/review-brief.sh` (334 assertions), `tests/spec-review/review-comment.sh` (82), `tests/hooks/delegation.sh` (55), `tests/poteto-mode/overlap.sh` (56) and `tests/spec-review/no-stale-wording.sh`. The diff changes no shell files.

## Would break

## Fails open

## Standards breaches

1. **P25 gives the wrong count for the files that quote "Ticket step 5".** CODING_STANDARDS.md, Markdown: "A count or a version in prose is true at the commit that lands it". P25 says the step number is quoted in four patches and in `review-brief.sh`. At this commit, six patches quote it: the four playbook patches, `opening-a-pr.md.patch` ("For a cross-cutting diff (Ticket step 5)") and `mattpocock/spec-review.SKILL.md.patch` ("(the Ticket playbook, step 5)"). `review-brief.sh` names the Ticket playbook only in a comment at line 183, with no step number. The reason not to renumber still holds and is stronger. Only the count is wrong, and the template copy has the same row.
   ```
   +| P25 | The design artifact on the ticket | ... Choices made in #89: the rule lives in Ticket step 6 (no renumbering, since "Ticket step 5" is quoted in four patches and `review-brief.sh`); ...
   ```

2. **The manual still says a project carries four core documents.** CODING_STANDARDS.md, Markdown: "A count or a version in prose is true at the commit that lands it". The diff adds a fifth slim document: `build_core` copies every core document except the digest, and the diff adds `template/docs/factory918/SCENARIO-TABLE.md`. `docs/knowledge/core/MANUAL.md:165` still says "a project carries only the first four, under `docs/factory918/`". Its list under "Where to read more" has no entry for `SCENARIO-TABLE.md`. The generated `template/docs/factory918/MANUAL.md:146` has the same text. The diff does not touch these lines, but it makes them false.
   ```
   Everything below lives in the factory clone (`~/.factory918`); a project carries only the first four, under `docs/factory918/`.
   ```

3. **The `build_knowledge.py` docstring still lists four copied documents.** CODING_STANDARDS.md, Markdown: "A count or a version in prose is true at the commit that lands it". The diff adds the `CORE_DOCS` tuple in this file, and `build_core` now copies `SCENARIO-TABLE.md` too. The module docstring at lines 7-8 still names only the four original documents.
   ```
                                              then copies PHILOSOPHY, MANUAL, DECISIONS and GLOSSARY (headers
                                              stripped) into template/docs/factory918/ for projects.
   ```

## Fix alongside

4. **The project copy of the page points at factory-only paths and issue numbers.** This is a judgement call under the nesting rule in AGENTS.md, which says files under `template/` are content for agents in a future project. `template/docs/factory918/SCENARIO-TABLE.md` goes to every project. In a project, `tests/poteto-mode/overlap.sh` does not exist. There, "ticket #42" and "PR #92" resolve to the project's own #42 and #92, and `gh issue view 42` returns an unrelated issue without any error. The page already carries the table verbatim, so the risk is small. The ticket also asks for the #42 example. A qualifier such as "Factory918's ticket #42" and a note that the test lives in the factory repository would make the references unambiguous.
   ```
   +The durable copy is the `## Testing decisions` section of ticket #42 and the description of PR #92. The legend and the table, verbatim:
   ...
   +Read the table beside `tests/poteto-mode/overlap.sh`: its header says the cases run in the order of the table, and each case asserts the exit code and the output of one call.
   ```

hard findings: 0
