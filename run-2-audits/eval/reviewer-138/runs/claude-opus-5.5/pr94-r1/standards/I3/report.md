# Standards review, ab47eb9

Checked on a copy of the tree: `python3 tools/build_knowledge.py` leaves the tree unchanged and `python3 tools/check_knowledge.py` prints `knowledge ok: 119 files`. `./factory918.sh sync` applies all 19 patches in `series`, including the two new ones, and leaves the tree unchanged. `tests/spec-review/no-stale-wording.sh`, `tests/spec-review/review-brief.sh`, `tests/poteto-mode/overlap.sh` and `tests/hooks/delegation.sh` pass. The P25 id is unique. `docs/agents/issue-tracker.md` matches its template copy.

## Would break

## Fails open

## Standards breaches

1. **P25 gives the wrong count of places that quote "Ticket step 5".** CODING_STANDARDS.md, Markdown: "A count or a version in prose is true at the commit that lands it." At this commit the literal phrase `Ticket step 5` appears in five patches: bug-fix, feature, opening-a-pr, perf-issue and refactoring. `spec-review.SKILL.md.patch` has a sixth reference, worded "the Ticket playbook, step 5". `review-brief.sh` does not quote the step number: line 183 says "the Ticket playbook says it in words". The reason for not renumbering still holds; only the count and the named script are wrong. The same text is in the generated `template/docs/factory918/DECISIONS.md`.
   ```
   Choices made in #89: the rule lives in Ticket step 6 (no renumbering, since "Ticket step 5" is quoted in four patches and `review-brief.sh`)
   ```

2. **The `build_knowledge.py` docstring still lists four slim documents.** CODING_STANDARDS.md, Markdown: "A count or a version in prose is true at the commit that lands it." The diff adds the fifth slim document as a `CORE_DOCS` tuple, and `build_core` now copies SCENARIO-TABLE.md too. The module docstring (`tools/build_knowledge.py:7-8`) was not updated. The knowledge skill and the M0 finding in this diff both describe the new set correctly.
   ```
                                              then copies PHILOSOPHY, MANUAL, DECISIONS and GLOSSARY (headers
                                              stripped) into template/docs/factory918/ for projects.
   ```

3. **SCENARIO-TABLE.md mixes Diátaxis modes.** CODING_STANDARDS.md, Markdown: "One Diátaxis mode per file". The page is explanation ("What it is", "Why") plus reference ("The shape", the verbatim #42 legend, table and contract). "Where it goes" is a procedure: which step, which command, which first line. The opening paragraph lists all of these as the page's purpose. This is a judgement call. The page is mostly explanation, but its operational rules restate Ticket step 6 and the runner prompt, which are the sources the agent actually follows.
   ```
   +On the ticket, before implementation. The Ticket playbook's step 6 appends the synthesized table to the ticket body under `## Testing decisions` with `gh issue edit N --body-file`. Its first line is `Posted by the agent <date>`, ...
   ```

## Fix alongside

4. **Duplicated Code: the definition of "state" is copied into many places and has already drifted.** One parenthetical is repeated in the runner prompt, Ticket step 6, P25, SCENARIO-TABLE.md, the glossary, issue-tracker.md, to-spec and the INDEX "read when" column. to-spec and the `CORE_DOCS` "read when" text leave out "rounds". The runner prompt, Ticket step 6 and P25 include it. A change with review rounds and no other state is stateful to `architect` but not to `to-spec`. The same 60-word writer sentence is also copied verbatim into four playbook patches. Those copies are forced by the vendoring, but the definition could live in one place, the runner prompt or the core page, and every other copy could point there.
   ```
   +- For stateful work (a file read or written, exit codes, more than one actor), the shape is the scenario table: ...
   ```

5. **Mysterious Name: "the rule above" in the to-spec patch points to another section.** The added bullet is under `## Testing Decisions`. The rule it exempts is at SKILL.md line 55, under `## Implementation Decisions` ("Do NOT include specific file paths or code snippets"). A reader inside the Testing Decisions list can take "the rule above" to mean the "only test external behavior" bullet. Name the rule instead.
   ```
   +... It is a decision, not a code snippet, so the rule above does not exclude it.
   ```

6. **The core page sends a project agent to factory paths and factory ticket numbers.** SCENARIO-TABLE.md is copied into every project's `docs/factory918/`. There, `tests/poteto-mode/overlap.sh` does not exist, and "ticket #42 and PR #92" resolve to the project's own #42 and #92. Other core documents cite factory tickets too, so this is a known pattern. This page, though, tells the reader to go and read those tickets and that test file.
   ```
   +Read the table beside `tests/poteto-mode/overlap.sh`: its header says the cases run in the order of the table, ...
   ```

7. **The new M0 finding records that SOURCES.md line 3 is wrong but does not fix it, although the diff edits SOURCES.md.** SOURCES.md line 3 still says `factory918 sync` "will re-fetch these pins, re-apply the patches, and bump VERSION". The run in this review confirms the opposite: sync ends "Review with git status, bump VERSION, commit." Either the diff corrects the line or a ticket is filed for it.
   ```
   +2026-09-22. ... factory918.sh sync (0.3.0) bumps no VERSION and touches no network, against what SOURCES.md line 3 says; the code is the truth (#89).
   ```

hard findings: 0
