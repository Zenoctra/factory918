# Spec review, #89, commit ab47eb9

The six acceptance criteria are all present in the files the ticket names, and `./factory918.sh sync` re-applies every patch cleanly, so the rule reaches the vendored skills. Four things do not hold: the knowledge build leaves the tree dirty and fails the CI step that runs it, the new core page claims a rule stronger than any step implements, the decision record still describes the old overlap check, and the one code change in the diff makes the overlap check miss a real overlap without saying so.

## Walk

1. `architect`'s runner prompt (`template/.agents/skills/architect/references/runner-prompt.md:5-10`) splits the first deliverable: with state, the scenario table, then the contract, then the test list, with the row/column vocabulary and the legend spelled out; without state and crossing a function boundary, the usage and signature sketch. The type sketch, signatures, module map and rationale follow. `patches/pstack/architect/references/runner-prompt.md.patch` carries the same text and applies (`./factory918.sh sync` prints `applied  pstack/architect/references/runner-prompt.md.patch` and leaves `git status` clean).
2. The same paragraph states both refusal rules: a cell for an input outside the intended path reads "refused with the tool's own message" and costs no code, and such a cell is cut only after the refusal was run and seen.
3. The runner prompt's closing line hands the deliverable on: the orchestrator appends the synthesized artifact to the ticket before implementation, a table under `## Testing decisions`, a sketch under `## Design`, pointing at the Ticket playbook, step 6.
4. Ticket step 6 (`template/.agents/skills/poteto-mode/playbooks/ticket.md:10`) gives the mechanics: read the body with `gh issue view N --json body -q .body`, append the section with the `Posted by the agent <date>` or `Approved by <name> <date>` first line, write it back with `gh issue edit N --body-file`, stop and report if the write fails, and no stop for the human except `/architect with checkpoint`. The step is numbered after step 5, which runs the whole selected playbook including its own "Opening a PR"; the four delegation steps carry the pointer back to step 6, so the artifact is reached at delegation time rather than by the Ticket playbook's own order.
5. `review-brief.sh` writes the whole ticket body to `ticket.md` and pastes it under `## The ticket (#N)` (`template/.agents/skills/spec-review/scripts/review-brief.sh:222,333`), so step 6's closing claim holds: whatever is posted under `## Testing decisions` reaches the Spec reviewer with no extra step. This brief is the proof.
6. Feature step 4, Bug fix step 3, Refactoring step 5 and Perf issue step 3 each gain the same sentence: the brief carries the ticket's design artifact, the test is written from the table before the implementation, one assertion per cell in the table's order, the commit order shows it, and a writer that cannot implement a cell as written stops and reports it and never fills it in. All four patches apply.
7. `to-spec`'s Testing Decisions list gains the scenario-table bullet with the shape and the "one assertion per cell" line, and the note that a table is a decision, not a code snippet, so the no-snippets rule above it does not exclude it. `patches/mattpocock/to-spec/SKILL.md.patch` follows `patches/README.md`'s `patches/<source>/<path>.patch` convention and is listed last in `series`.
8. `docs/knowledge/core/SCENARIO-TABLE.md` is a new core document: what it is, the four parts of the shape, where it goes, #42's legend, table and first two contract paragraphs verbatim, and the two-run comparison. `tools/build_knowledge.py` gains one `CORE_DOCS` tuple, strips the header into `template/docs/factory918/SCENARIO-TABLE.md`, and `factory918 apply` copies every file under `template/`, so a project gets the page. `GLOSSARY.md` gains the term, `MANUAL.md`'s "Where to read more" gains the bullet and counts five slim documents, `DECISIONS.md` gains P25. `python3 tools/check_knowledge.py` reports `knowledge ok: 119 files`.
9. `docs/agents/issue-tracker.md:26` and its template copy add the two appended sections to the ticket-body shape, with the first-line rule and the reason `spec-review` reads them as spec.
10. `template/.agents/skills/poteto-mode/scripts/overlap.sh:49` widens the awk skip from `## Diff` to `## (Diff|Testing decisions|Design)`, so the check no longer reads backticked tokens under the two sections step 6 appends. `shellcheck` is clean on the file; `bash tests/poteto-mode/overlap.sh` passes, and its only heading case is still `17 a token under ## Diff ignored`.
11. `SOURCES.md` records the four playbook edits' second sentence under entry 13 and adds entries 14 and 15 for the runner prompt and `to-spec`. `docs/M0-findings.md` records the one-tuple cost of a sixth core document, and also that `sync` bumps no VERSION and touches no network against what `SOURCES.md` line 3 still says; that sentence is left uncorrected in a file this diff edits. `docs/agents/ledger.md` gains the drained-lanes line.

## Would break

1. **`build_knowledge.py` does not leave the tree clean, and the CI step that runs it fails.** `MANUAL.md` grew a line (the `SCENARIO-TABLE.md` bullet) and is now 175 lines. Its own header comment was updated to 175 and the index rows for `DECISIONS.md` (92 to 93) and `GLOSSARY.md` (69 to 71) were updated by hand, but `docs/knowledge/INDEX.md:9` still says `core/MANUAL.md | Factory918: the manual | 174`. Running the script rewrites that row, so the tree is dirty afterwards. `.github/workflows/factory-ci.yml:31` is `python3 tools/check_knowledge.py && python3 tools/build_knowledge.py && git diff --exit-code`, so this PR is red on that step. Verified: `python3 tools/build_knowledge.py` on a clean checkout of ab47eb9 leaves ` M docs/knowledge/INDEX.md`, whose only hunk is `174` to `175`. `check_knowledge.py` passes, so nothing else catches it.

```
- [ ] The knowledge base has one page on the table (what it is, the shape, the #42 example), reachable through `/knowledge scenario table`.
```

Documented step: `AGENTS.md:43`, "`python3 tools/build_knowledge.py` leaves `git status` clean, and `python3 tools/check_knowledge.py` passes."
Result: the script rewrites `docs/knowledge/INDEX.md:9` from 174 to 175, `git status` is dirty, and `git diff --exit-code` in the CI knowledge step exits 1.
spec: criterion 6

2. **The rule is gated on `architect` running, so a stateful change that skips `architect` posts no artifact and nothing notices.** Criterion 3 conditions the posting on the design adding state. As implemented, Ticket step 6 conditions it on two things: "The selected playbook's architect step adds the ticket's own: when the design adds state ... `architect`'s first deliverable is the scenario table". The architect step is skippable in all four playbooks for work that is not cross-cutting: Bug fix step 3 and Perf issue step 3 run it only "if it crosses a function boundary", Refactoring step 3 only "if the target crosses a function boundary", Feature step 2 allows `architect skipped: <reason>`. A bug fix that changes exit codes or the contents of a state file inside one function therefore adds state, skips `architect`, and reaches the writer with no table, while the delegation sentence added to that same step says "The brief carries the ticket's design artifact (Ticket step 6)" as though one always exists. No step or check detects the absence. The new core page states the stronger rule to both audiences it names, the human and the agent: `docs/knowledge/core/SCENARIO-TABLE.md:12` and `template/docs/factory918/SCENARIO-TABLE.md:3`, "the design artifact Factory918 asks for before any code that has state".

```
- [ ] The Ticket playbook's architect step says that when a design adds state, the table is appended to the ticket's body under `## Testing decisions`, first line "Posted by the agent <date>" or "Approved by <name> <date>", before implementation; the human edits it if it is wrong; a stop before implementation is asked for only with "/architect with checkpoint".
```

Documented step: `template/docs/factory918/SCENARIO-TABLE.md:3`, "The scenario table is the design artifact Factory918 asks for before any code that has state: a file it reads or writes, exit codes, review rounds, or more than one actor."
Result: for a stateful change that does not cross a function boundary, no step asks for a table; the ticket carries its criteria only, the reviewer has no cells to check, and the human who read the page expects a table that never arrives.
spec: criterion 3

3. **P25 is added beside a P24 the same PR makes wrong: the decision record still says only `## Diff` is excluded.** `docs/knowledge/core/DECISIONS.md:92` and `template/docs/factory918/DECISIONS.md:84` describe the check as matching "the ticket body's backticked tokens as pathspecs (its `## Diff` section excluded)". After this diff the script excludes three sections. The script's own header comment was updated (`overlap.sh:5-6`); the decision record, which `AGENTS.md` and the `knowledge` skill both say wins over every other source, was not. The new page repeats the old contract as the durable one: `docs/knowledge/core/SCENARIO-TABLE.md:76` and `template/docs/factory918/SCENARIO-TABLE.md:67` quote "every backticked token without whitespace outside a `## Diff` section", and that page ships to every project as the reference for the artifact and for #42's contract.

```
- [ ] The Ticket playbook's architect step says that when a design adds state, the table is appended to the ticket's body under `## Testing decisions`, first line "Posted by the agent <date>" or "Approved by <name> <date>", before implementation; the human edits it if it is wrong; a stop before implementation is asked for only with "/architect with checkpoint".
```

Documented step: `docs/knowledge/core/DECISIONS.md:92` (P24), "the ticket body's backticked tokens as pathspecs (its `## Diff` section excluded)"; `template/.agents/skills/knowledge/SKILL.md:20` sends every agent to `DECISIONS.md` first and says it wins.
Result: an agent or a human reasoning about Ticket step 1 from the record that wins is told the sketch's and the table's paths are matched, while the code skips them; the two statements of the same contract now disagree and nothing marks which is current.
spec: criterion 3

## Fails open

4. **A ticket whose paths are named in its posted `## Design` sketch passes the overlap check with `base: origin/main` while a PR holds those files.** The sketch is exactly the place where the files the work will touch are named, and the widened skip makes them invisible to the pathspec scan. Ticket step 1 re-runs against a body that already carries the posted sections in the flows the playbooks prescribe: the `stack #N on #M` re-run in step 1 itself, a resumed ticket, and a design hole returned to `architect` and picked up again. Ran against the repository's own fixture (`tests/poteto-mode/overlap.sh`'s setup, open PR #1 on `feat-a` touching `docs/a.md`), three bodies:

```
A. tokens only under `## Design`  -> exit 0: "go: none / paths: none / base: origin/main"
B. the same token under `## What to build` -> exit 1: "go: none / #1 feat-a: docs/a.md"
C. the same token under `## Testing Decisions` (capital D) -> exit 1: "go: none / #1 feat-a: docs/a.md"
```

A is the silent one: nothing is printed about #1, the caller branches from `main`, and the collision surfaces only at step 8's `--diff` run, after the implementation. Before this diff, body A exited 1 and named #1. C shows the skip is case-sensitive, and `to-spec`'s spec heading, which the same PR teaches to hold a scenario table, is `## Testing Decisions` (`template/.agents/skills/to-spec/SKILL.md:59`), so a table copied into a ticket under the spec's own heading is scanned while one under the playbook's heading is not. No assertion covers any of this: `tests/poteto-mode/overlap.sh` still has only case `17 a token under ## Diff ignored`, and its header still claims it runs the cases in the order of the design's scenario table.

```
- [ ] The Ticket playbook's architect step says that when a design adds state, the table is appended to the ticket's body under `## Testing decisions`, first line "Posted by the agent <date>" or "Approved by <name> <date>", before implementation; the human edits it if it is wrong; a stop before implementation is asked for only with "/architect with checkpoint".
```

Documented step: `template/.agents/skills/poteto-mode/playbooks/ticket.md:5` (Ticket step 1), "Exit 1 (paths shared, no go covering them): stop, report the output, and do not start", and "`paths: none` means the ticket names no file; step 8 is its check."
Result: `paths: none` and exit 0 for a ticket that does name files, in a section the same PR tells the agent to add; the check proceeds silently instead of stopping, and `paths: none` is reported for a body that is not tokenless.
spec: criterion 3

## Not asked for

5. **The one code change in the diff is outside every criterion, and it is stateful code shipped without the table or the test this ticket exists to require.** `overlap.sh` reads a file, has four exit codes and more than one actor, which is the diff's own definition of state. The ticket's Run under says the opposite of what shipped, and rules 2 to 4 were therefore not applied to it: no cell was written for a token under `## Testing decisions` or `## Design`, no assertion was added to `tests/poteto-mode/overlap.sh`, and `#42`'s table row 7, quoted verbatim into the new core page as "tokens under `## Diff` ignored", is left describing behaviour the same commit changed. The change is a real consequence of posting the artifact into the body, so the fix is a cell, an assertion and the three documents, not a revert.

```
This ticket changes prose and patches only, so rule 2 yields no table; rules 6 to 8 apply to its review.
```

spec: criterion 3

hard findings: 4
