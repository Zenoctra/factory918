# Spec review: #89 at ab47eb9

## Walk

1. Criterion 1, runner prompt: `patches/pstack/architect/references/runner-prompt.md.patch` makes the first deliverable a scenario table, then the contract, then the test list, for a design with state (a file read or written, exit codes, rounds, more than one actor). It gives the table's shape: situations down the side, input shape across the top, each cell printed/exit/next, a legend, and a contract that defines every term. Without state, crossing a function boundary, the first deliverable is the usage and signature sketch. The orchestrator posts it under `## Design` by the same rule, per Ticket step 6. The template copy matches. `factory918.sh sync` on a scratch git copy applied all 19 patches and left `git status` clean.
2. Criterion 2: the same patch says an off-path cell reads "refused with the tool's own message" and costs no code. It also says the cell is cut only after the refusal was run and seen, and that an assumed failure mode is a claim until then. The ledger line from 2026-09-21 is the source, and the new page quotes it.
3. Criterion 3, the Ticket playbook: `template/.agents/skills/poteto-mode/playbooks/ticket.md` step 6 says that when the design adds state, the synthesized table is appended to the ticket body under `## Testing decisions` with `gh issue edit N --body-file` before implementation. Its first line is `Posted by the agent <date>` or `Approved by <name> <date>`. The human edits the ticket if the table is wrong. A stop is asked for only with `/architect with checkpoint`, and `architect/SKILL.md:48` already honours that phrase. The step says the Spec brief carries the table because `review-brief.sh` pastes the ticket body, and `review-brief.sh:222` pastes the whole body (`gh issue view --json body`). The rule sits in step 6 while the selected playbook runs inside step 5. Three pointers reach it: each delegation step's "(Ticket step 6)", the runner prompt's closing paragraph, and P25, which records this placement as a choice.
4. Criterion 4, the four playbooks: the patches for Feature step 4, Bug fix step 3, Refactoring step 5 and Perf issue step 3 each add the same text. The brief carries the ticket's design artifact. For a table, the writer writes the test from it before the implementation, one assertion per cell in the table's order, and the commit order shows it. A writer that cannot implement a cell stops, reports it and never fills it in. The patches apply cleanly under sync.
5. Criterion 5, to-spec: the new `patches/mattpocock/to-spec/SKILL.md.patch` is listed in `series` and applied by sync. It adds the scenario table to Testing Decisions as the shape for stateful work, one assertion per cell. It says the table is exempt from the no-snippets rule.
6. Criterion 6, the knowledge page: `docs/knowledge/core/SCENARIO-TABLE.md` covers what the table is, its shape, where it goes, the #42 example (legend, table, contract excerpt, verbatim) and why. It is a `CORE_DOCS` entry and is listed in `INDEX.md`. `build_knowledge.py` copies it to `template/docs/factory918/SCENARIO-TABLE.md`, and the knowledge skill's slim-corpus line now names it. `rg -i "scenario table"` finds it in both corpora. `build_knowledge.py` left `git status` clean on the scratch copy, and `check_knowledge.py` printed `knowledge ok: 119 files`.
7. Supporting documentation: `docs/agents/issue-tracker.md` and its template copy describe the two appended sections. The glossary has a new "Scenario table" entry. P25 records the decision, AGENTS.md now says "six core documents", and SOURCES items 13 to 15 describe the new patches. Not covered by the diff: the `build_knowledge.py` docstring (line 8) still says it copies PHILOSOPHY, MANUAL, DECISIONS and GLOSSARY. The project copy of the page points at `tests/poteto-mode/overlap.sh`, which exists only in the factory. Both are wording issues and neither changes a documented step's result.
8. The Run under rules for this review: this ticket changes prose and patches only, so it has no scenario table. No changed path is cross-cutting (under `.claude/hooks/`, a `.claude/settings.json` or `.agents/skills/factory918/`), so there is no blast-radius grounding to walk. Tests run on the scratch copy: `no-stale-wording.sh` ok, `review-brief.sh` ok with 334 assertions, `overlap.sh` ok with 56 assertions.

## Would break

## Fails open

## Not asked for

1. **An unrelated ledger line.** `docs/agents/ledger.md` gains a 2026-09-22 line about a turn that ended while explorer lanes were still reading. That is a surprise about how the run went, not about the scenario table. AGENTS.md routes surprises to the ledger, so the line is allowed there, but no criterion asks for it and it does not belong to this ticket's single concern.
   ```
   - [ ] The knowledge base has one page on the table (what it is, the shape, the #42 example), reachable through `/knowledge scenario table`.
   ```
2. **An M0 finding about sync and VERSION.** The new `docs/M0-findings.md` line has two sentences. The first verifies the cost of a sixth core document, which this ticket needs. The second says that `factory918.sh sync` bumps no VERSION and touches no network, contradicting SOURCES.md line 3. That finding concerns sync and belongs outside this ticket.
   ```
   - [ ] The knowledge base has one page on the table (what it is, the shape, the #42 example), reachable through `/knowledge scenario table`.
   ```

hard findings: 0
