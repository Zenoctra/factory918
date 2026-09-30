# Spec review, #89 at ab47eb9

## Walk

1. Criterion 1, runner prompt through its patch: `patches/pstack/architect/references/runner-prompt.md.patch` makes the first deliverable depend on the design. With state (a file, exit codes, rounds, more than one actor) it is the scenario table, then the contract, then the test list. Without state, crossing a function boundary, it is the usage and signature sketch. The orchestrator appends the synthesized deliverable to the ticket: a table under `## Testing decisions`, a sketch under `## Design` (Ticket step 6). The patch is listed in `patches/series` and SOURCES item 14.
2. Criterion 2: the same bullet says a cell for an input outside the intended path reads "refused with the tool's own message", costs no code, and is cut only after the refusal was run and seen.
3. Criterion 3, Ticket playbook: step 6 (`template/.agents/skills/poteto-mode/playbooks/ticket.md:10`) says that when the design adds state, the synthesized table is appended to the body under `## Testing decisions` with `gh issue edit N --body-file` before implementation. Its first line is `Posted by the agent <date>` or `Approved by <name> <date>`. The human edits the ticket if the table is wrong, a stop is asked for only with `/architect with checkpoint`, and the Spec brief carries the table because `review-brief.sh` pastes the body. `review-brief.sh:222` does paste the body whole. `architect/SKILL.md:48` already honours the checkpoint phrase. The rule sits in step 6, after step 5 runs the selected playbook, and P25 records that choice. The four delegation steps point forward to "Ticket step 6", which routes the orchestrator there before the writer is briefed.
4. Criterion 4: the delegation steps of Feature (step 4), Bug fix (step 3), Refactoring (step 5) and Perf issue (step 3) each carry the same added text. The brief carries the ticket's design artifact. The writer writes the test from the table before the implementation, one assertion per cell in the table's order, with the commit order showing it. A writer that cannot implement a cell stops and reports it, and never fills it in. The template copies match the patches: `./factory918.sh sync` in a scratch copy applied all 19 patches and left `template/` byte-identical.
5. Criterion 5: `patches/mattpocock/to-spec/SKILL.md.patch` (in `series`, SOURCES item 15) and the template copy add a Testing Decisions bullet. It names the scenario table as the shape for stateful work, one assertion per cell.
6. Criterion 6: `docs/knowledge/core/SCENARIO-TABLE.md` is a sixth core document with four sections: what it is, the shape, where it goes, and the #42 example. Its table is identical to the `| ` rows of #42's body on GitHub today. `CORE_DOCS` adds it, INDEX lists it, and `build_core` copies it to `template/docs/factory918/`. In a scratch copy, `build_knowledge.py` left `docs/` and `template/` unchanged and `check_knowledge.py` passed (119 files). `rg -i "scenario table"` over either corpus finds the page, so `/knowledge scenario table` reaches it. Two lists of the slim copy were not updated: `docs/knowledge/core/MANUAL.md:165` still says "a project carries only the first four", and the `tools/build_knowledge.py:7` docstring still names only PHILOSOPHY, MANUAL, DECISIONS and GLOSSARY.
7. Run-under rules 6 to 8: no changed file is cross-cutting (no `.claude/hooks/`, `settings.json` or `factory918` skill path), so no blast-radius grounding is due. No shell file changed. `tests/spec-review/no-stale-wording.sh` and `tests/poteto-mode/overlap.sh` exit 0.
8. Supporting edits: `docs/agents/issue-tracker.md` and its template copy (identical) add the two optional sections to the ticket shape, and the glossary gains "Scenario table". P25 records the decision, AGENTS.md says "six core documents", and an M0 line records the sixth-document cost.

## Would break

1. **The posted table becomes overlap.sh's pathspecs on any later Ticket step 1.** Step 6 appends the table and its contract to the ticket body. `overlap.sh` builds its pathspecs from every backticked token in that body and skips only a `## Diff` section (`template/.agents/skills/poteto-mode/scripts/overlap.sh:47-50`). I piped a body with a `## Testing decisions` table through that extraction. It yields the table's `.claude/state/program` and `../x` as well as the ticket's own `src/a.sh`. A second run of the same ticket, which is what #42 itself went through (PR #87 closed, then #92), meets three problems:
   - A path a cell merely quotes makes an unrelated PR overlap. The check then stops with exit 1, or under a covering go silently picks that PR's head as the base.
   - A dot-dot or absolute path quoted in a cell ends in exit 2.
   - A ticket with no backticked paths loses its row-7 `paths: none` fast path.

   The page's own #42 row 14 had to leave such a path unbackticked "so this ticket's own check does not trip on it", but neither the runner prompt nor Ticket step 6 tells the table's author that. Context: #42 on GitHub now carries the line "Amended 2026-09-22 by #89: the check skips a `## Testing decisions` or `## Design` section as it skips `## Diff`". This commit makes no such change to `overlap.sh` or its test.
   ```
   The Ticket playbook's architect step says that when a design adds state, the table is appended to the ticket's body under `## Testing decisions`, first line "Posted by the agent <date>" or "Approved by <name> <date>", before implementation
   ```
   Documented step: `template/.agents/skills/poteto-mode/playbooks/ticket.md:10` (step 6, "the synthesized table is appended to the ticket's body under `## Testing decisions` with `gh issue edit N --body-file`") read with the same file's step 1, which runs `overlap.sh N` over that body.
   Result: after the table is posted, the check matches open PRs against the table's quoted paths as well as the ticket's own. The result is a spurious stop, a wrong base chosen silently under a go, or exit 2.
   spec: criterion 3

## Fails open

## Not asked for

2. **A ledger line about lanes dying at turn end.** `docs/agents/ledger.md` gains the 2026-09-22 line about explorer lanes losing their worktree. That surprise happened while this ticket ran, but it has nothing to do with the scenario table. AGENTS.md sanctions ledger lines, so this is minor.
   ```
   The knowledge base has one page on the table (what it is, the shape, the #42 example), reachable through `/knowledge scenario table`.
   ```
3. **An M0 finding about `sync` and VERSION.** The new M0 line also records that `factory918.sh sync` "bumps no VERSION and touches no network, against what SOURCES.md line 3 says; the code is the truth". This observation is outside the ticket, and SOURCES.md line 3 is left unchanged.
   ```
   The knowledge base has one page on the table (what it is, the shape, the #42 example), reachable through `/knowledge scenario table`.
   ```

hard findings: 1
