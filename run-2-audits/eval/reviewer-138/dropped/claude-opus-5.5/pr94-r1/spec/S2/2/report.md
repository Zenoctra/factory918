## Walk

1. Criterion 1, runner prompt through its patch. `patches/pstack/architect/references/runner-prompt.md.patch` is listed in `series`. It makes the first deliverable depend on the design. With state (a file, exit codes, rounds, more than one actor), the order is the scenario table, the contract, then the test list, with the ticket's shape: situations down the side, input shape across the top, and each cell holds what is printed, the exit code and what the caller does next, plus a legend. Without state, crossing a function boundary, the deliverable is the usage and signature sketch. The orchestrator appends the table under `## Testing decisions` and the sketch under `## Design` (Ticket step 6). `./factory918.sh sync` on a copy applied it and left the template unchanged.
2. Criterion 2. The same paragraph says a cell outside the intended path reads "refused with the tool's own message", costs no code, and is cut only after the refusal was run and seen.
3. Criterion 3. Ticket step 6 (`template/.agents/skills/poteto-mode/playbooks/ticket.md:10`) covers the following. When the design adds state, the synthesized table goes on the ticket body under `## Testing decisions` before implementation, via `gh issue edit N --body-file`. Its first line is `Posted by the agent <date>`, or `Approved by <name> <date>`. The human edits the ticket when the table is wrong. A stop is asked for only with `/architect with checkpoint`. The Spec brief carries the table because `review-brief.sh` pastes the ticket body. `review-brief.sh:222` fetches `.body` whole with no section filter, and `architect/SKILL.md:48` already knows the phrase "/architect with checkpoint". The step conditions on "the selected playbook's architect step". Where that step is skipped (a Feature `architect skipped: <reason>`, or a Bug fix that crosses no function boundary), no table is produced. The criteria do not ask for more.
4. Criterion 4. Delegation steps in Feature 4, Bug fix 3, Refactoring 5 and Perf issue 3 all carry the same text, both in the template and through the four patches. The text says the following. The brief carries the ticket's design artifact. With a table, the test is written first, one assertion per cell in table order, and the commit order shows it. A writer that cannot implement a cell stops and reports it, and never fills it in. Sync reproduces all four files unchanged. `SOURCES.md` item 13 gains the sentence.
5. Criterion 5. The new `patches/mattpocock/to-spec/SKILL.md.patch` is listed in `series` and applies cleanly. It adds a Testing Decisions bullet that names the scenario table as the shape for stateful work and says the table is exempt from the no-snippet rule. `SOURCES.md` item 15 covers it.
6. Criterion 6. The new core document `docs/knowledge/core/SCENARIO-TABLE.md` has five sections: what it is, the shape, where it goes, the #42 example, and why. It is registered in `CORE_DOCS`. Its INDEX row reads "Designing or reviewing anything with state". `build_core` copies it to `template/docs/factory918/SCENARIO-TABLE.md`, so projects get it. In a project, `rg -i "scenario table"` over `docs/factory918` finds it, and the `knowledge` skill's slim list now names it. The #42 legend and table match `gh issue view 42` byte for byte, and `tests/poteto-mode/overlap.sh` passes (56 assertions). `python3 tools/build_knowledge.py` leaves a copy unchanged, and `check_knowledge.py` reports "knowledge ok: 119 files".
7. `docs/agents/issue-tracker.md` and its template copy: the ticket-body shape now names the two optional appended sections and their first-line forms.
8. `DECISIONS.md` P25 (core and template), GLOSSARY "Scenario table" (core and template), and AGENTS.md now reads "six core documents". All three agree with the playbook text.
9. Rule 6 of Run under (one walk line per blast-radius risk): the diff touches no `.claude/hooks/`, `.claude/settings.json` or `factory918` skill path, so it is not cross-cutting and there is no grounding to walk.
10. Other checks. `tests/spec-review/review-brief.sh` passes (334 assertions) and `no-stale-wording.sh` passes. There is no changed shell file for rule 8.

## Would break

## Fails open

## Not asked for

1. **Ledger line unrelated to the ticket.** The ledger line records the orchestrator ending its turn while lanes were still reading. That is a surprise from running this ticket, not part of it. AGENTS.md sends surprises to the ledger, so it belongs somewhere, but it rides on this PR.
   ```
   +2026-09-22 | fable | ended its turn while two explorer lanes were still reading, the harness removed its worktree, and both lanes died without a report | drain every lane before the turn ends; a lane with no worktree cannot report
   ```
2. **An out-of-scope observation in M0-findings.** The dated line also records that `factory918.sh sync` bumps no VERSION and touches no network, "against what SOURCES.md line 3 says". AGENTS.md says a finding outside the PR's scope becomes a ticket. `SOURCES.md:3` is left stating the opposite, and `tools/build_knowledge.py:8` still says it copies four documents.
   ```
   factory918.sh sync (0.3.0) bumps no VERSION and touches no network, against what SOURCES.md line 3 says; the code is the truth (#89).
   ```

hard findings: 0
