## Walk

1. Ticket step 1 (`ticket.md:5`): `overlap.sh N` reads every backticked token of the ticket body outside a `## Diff` section as a named path (`overlap.sh:48-50`) and matches it against every open PR's own commits.
2. Ticket step 5 (`ticket.md:9`): selects Feature, Bug fix, Refactoring or Perf issue; a cross-cutting diff never skips `architect`. Unchanged; the four playbooks still cite it as "Ticket step 5".
3. Ticket step 6 (`ticket.md:10`): for a design with state, `architect`'s first deliverable is the scenario table; before implementation the synthesized table is appended under `## Testing decisions` with `gh issue edit N --body-file`, first line `Posted by the agent <date>` or `Approved by <name> <date>`; a stateless sketch goes under `## Design`; prose has only its criteria; posting is the record, the human edits, a stop only with `/architect with checkpoint`; the Spec brief carries it because `review-brief.sh` pastes the body. `review-brief.sh:222` fetches `--json body` whole, so that claim holds. `architect/SKILL.md:44-48` already makes the checkpoint opt-in with that phrase, so step 6 and the vendored skill agree.
4. `runner-prompt.md:4-10` (and its patch): with state, table then contract then test list; situations down the side, input shape across the top, cell = printed / exit / next; legend; contract defines every term; one assertion per cell in cell order naming its fixture; a refused cell "costs no code" and is cut "only after the refusal was run and seen"; without state, the usage and signature sketch; the orchestrator appends the synthesized deliverable to the ticket. Criteria 1 and 2 met.
5. Feature step 4 (`feature.md:12`), Bug fix step 3 (`bug-fix.md:9`), Refactoring step 5 (`refactoring.md:11`), Perf issue step 3 (`perf-issue.md:16`), each through its patch: the brief carries the artifact; the test is written from the table first, one assertion per cell in the table's order, the commit order shows it; a writer that cannot implement a cell stops and reports it and never fills it. Criterion 4 met. `./factory918.sh sync` on a scratch git copy applied all 19 patches of `series` and left `git status` empty.
6. `to-spec/SKILL.md:66` and its new patch: the table is the shape for stateful work under Testing Decisions. Criterion 5 met.
7. `core/SCENARIO-TABLE.md`: what it is, the shape, where it goes, the #42 example, why; `INDEX.md` row; `GLOSSARY.md` entry; one `CORE_DOCS` tuple. `python3 tools/build_knowledge.py` in a scratch copy reproduces `docs/knowledge/` and `template/docs/factory918/` byte for byte; `check_knowledge.py` reports 119 files ok. The page's legend and 14 rows are identical to ticket #42's `## Testing decisions` (`gh issue view 42`). Criterion 6 met.
8. `issue-tracker.md:26`, both copies: the two optional sections, their first line, and that `spec-review` reads them because the body is pasted whole.
9. Records: P25 in `DECISIONS.md`, `AGENTS.md` "six core documents", the knowledge skill's slim list (`knowledge/SKILL.md:12`), `SOURCES.md` 13 to 15, the M0 line, the ledger line.
10. `tests/spec-review/no-stale-wording.sh` and `tests/spec-review/review-brief.sh` (334 assertions) pass on the scratch copy. No shell file changed, so rule 8 has nothing to run.

## Would break

1. **A posted table's backticked tokens become the ticket's named paths, and the #42 record amended under this ticket says the check skips them when it does not.** Step 6 tells the agent to append the table to the ticket body; step 1 reads every backticked token outside `## Diff` as a path the ticket names. A table and its contract quote paths and tools by nature (the page's own example quotes `.claude/state/program`, `tests/poteto-mode/overlap.sh`, `gh`). Ticket #42's body now carries a line dated today, in this ticket's name, that describes the fix as done.

```
- [ ] The Ticket playbook's architect step says that when a design adds state, the table is appended to the ticket's body under `## Testing decisions`, first line "Posted by the agent <date>" or "Approved by <name> <date>", before implementation;
```

```
Amended 2026-09-22 by #89: the check skips a `## Testing decisions` or `## Design` section as it skips `## Diff`, up to the next `## ` heading (row 7 and the contract's "Named paths"), so a table posted inside that one section, its parts under `###`, adds no paths the ticket names; no assertion changed, one added.
```

Documented step: `template/.agents/skills/poteto-mode/playbooks/ticket.md:10` (step 6) with `ticket.md:5` (step 1) and `template/.agents/skills/poteto-mode/scripts/overlap.sh:5,48`; ticket #42, `## Testing decisions`, the 2026-09-22 amendment quoted above.
Result: `overlap.sh:48` skips only `## Diff`; `tests/poteto-mode/overlap.sh` has no case for the two sections; neither file is in the diff, so the amendment records a rule the script does not have. The next step-1 run on a ticket that carries a table (a second run after a closed PR, as #42 had; the re-run after `stack #N on #M`; a run after the human edits the table) matches the table's quoted paths against every open PR and either stops with exit 1 naming a PR the work never touches, or picks that PR's head as the base. Step 8's `--diff` run is unaffected (`overlap.sh:82-84` uses the branch's own paths). A second gap sits in the page itself: its example shows the contract under its own `## Contract` heading, which the amendment's own rule would not skip either.
spec: criterion 3

2. **The builder's header still names four copied documents.** `tools/build_knowledge.py:8` says the script copies "PHILOSOPHY, MANUAL, DECISIONS and GLOSSARY" into `template/docs/factory918/`; `build_core` (line 136) copies every core document except `CONVERSATION-DIGEST.md`, so `SCENARIO-TABLE.md` now lands too, as `knowledge/SKILL.md:12` and the M0 line say.

```
- [ ] The knowledge base has one page on the table (what it is, the shape, the #42 example), reachable through `/knowledge scenario table`.
```

Documented step: `tools/build_knowledge.py:8`.
Result: the one comment that says what a project receives is a document short of what `apply` ships.
spec: criterion 6

## Fails open

## Not asked for

3. **Two record lines outside the criteria.** `docs/agents/ledger.md:25` (two explorer lanes died when the turn ended) and `docs/M0-findings.md:179` (sync bumps no VERSION and touches no network). Both are what `AGENTS.md` requires of a surprise and of a fact verified against a tool; listed so the judgment sees them, no action needed.

```
This ticket changes prose and patches only, so rule 2 yields no table; rules 6 to 8 apply to its review.
```

hard findings: 2
