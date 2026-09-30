## Would break

## Fails open

## Standards breaches

1. **The manual still says a project carries four core documents.** CODING_STANDARDS.md, Markdown: "A count or a version in prose is true at the commit that lands it, with the command that regenerates it nearby." This PR makes `build_core` copy a fifth document, `SCENARIO-TABLE.md`, into `template/docs/factory918/`, but the manual's "Where to read more" still gives the count as four and does not list the new page. `docs/knowledge/core/MANUAL.md:165` (and the generated `template/docs/factory918/MANUAL.md:146`), unchanged by the diff:

   ```
   Everything below lives in the factory clone (`~/.factory918`); a project carries only the first four, under `docs/factory918/`.
   ```

2. **P25's reason for not renumbering gives a wrong count and a wrong file.** Same rule. The phrase "Ticket step 5" appears in six patches: `spec-review.SKILL.md.patch`, `opening-a-pr.md.patch`, `bug-fix`, `feature`, `perf-issue` and `refactoring`. It does not appear in `review-brief.sh`. The script holds the predicate that step 5 cites; it does not quote the step. Checked with `grep -rn "step 5" patches template/.agents/skills/spec-review/scripts/review-brief.sh`. From `docs/knowledge/core/DECISIONS.md` P25 (copied to the template):

   ```
   +... Choices made in #89: the rule lives in Ticket step 6 (no renumbering, since "Ticket step 5" is quoted in four patches and `review-brief.sh`); ...
   ```

3. **The `build_knowledge.py` docstring still names four copied documents.** Same count rule. The rule sits under the Markdown heading, but it covers any count in prose. The diff adds the CORE_DOCS tuple but leaves the module docstring, which describes the knowledge layout, unchanged. `build_core` now copies every core document except `CONVERSATION-DIGEST.md`, and that includes `SCENARIO-TABLE.md`. `tools/build_knowledge.py:6-9`:

   ```
     docs/knowledge/core/*.md                 HAND-MAINTAINED. Edit these files directly. This script only
                                              refreshes the header line and the mini-TOC of each one in place,
                                              then copies PHILOSOPHY, MANUAL, DECISIONS and GLOSSARY (headers
                                              stripped) into template/docs/factory918/ for projects.
   ```

## Fix alongside

4. **Shotgun Surgery: one rule restated in nine places, and the copies already drift.** The same rule appears in Ticket step 6, the runner prompt, four playbooks (verbatim, as criterion 4 asks), P25, `SCENARIO-TABLE.md`, `GLOSSARY.md`, both `issue-tracker.md` copies and `to-spec`. The copies do not define "state" the same way. The runner prompt, Ticket step 6 and P25 include "rounds". The `to-spec` line and the INDEX "read when" entry leave it out. So a design whose only state is rounds gets a table from `architect` but not from `to-spec`. The ledger records this failure mode on 2026-09-17: a record left saying the old thing after a rule changed.

   ```
   +- For stateful work (a file read or written, exit codes, more than one actor), the shape is the scenario table: ...
   ```
   ```
   +- With state (a file it reads or writes, exit codes, rounds, or more than one actor): a scenario table, ...
   ```

5. **The project copy of the page points at factory-only artifacts.** `template/docs/factory918/SCENARIO-TABLE.md` ships into every project. The two lines below send its reader to `tests/poteto-mode/overlap.sh`, which `template/` does not carry. They also send the reader to "ticket #42" and "PR #92", which in a project resolve to that project's own issue and PR. The table is embedded verbatim, so nothing is lost, but both pointers lead nowhere or to the wrong place outside the factory.

   ```
   +The durable copy is the `## Testing decisions` section of ticket #42 and the description of PR #92. The legend and the table, verbatim:
   +Read the table beside `tests/poteto-mode/overlap.sh`: its header says the cases run in the order of the table, ...
   ```

6. **A known-false line in SOURCES.md is recorded and left in place.** The new M0 finding says SOURCES.md line 3 is wrong: sync does not fetch or bump VERSION. This PR edits SOURCES.md and leaves line 3 as it is. The finding is also not a tool fact, and AGENTS.md sends "a finding outside its scope" to a ticket.

   ```
   +2026-09-22. ... factory918.sh sync (0.3.0) bumps no VERSION and touches no network, against what SOURCES.md line 3 says; the code is the truth (#89).
   ```

Verified at this snapshot, in a scratch copy: `./factory918.sh sync` applies all 19 patches and leaves `template/` byte-identical. `python3 tools/build_knowledge.py` leaves `docs/` and `template/` byte-identical. `check_knowledge.py` passes (119 files). `no-stale-wording.sh`, `review-brief.sh` (334), `review-comment.sh` (82), `overlap.sh` (56) and `delegation.sh` (55) pass.

hard findings: 0
