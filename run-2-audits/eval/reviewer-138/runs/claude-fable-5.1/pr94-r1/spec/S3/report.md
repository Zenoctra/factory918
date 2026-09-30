## Walk

1. Criterion 1: `template/.agents/skills/architect/references/runner-prompt.md:7-10` (and its patch) makes the first deliverable a scenario table, then the contract, then the test list for a design with state, and the usage and signature sketch for stateless code across a function boundary; line 10 says the orchestrator appends the synthesized one to the ticket under `## Testing decisions` or `## Design`.
2. Criterion 2: `runner-prompt.md:7` carries the "refused with the tool's own message" cell, "costs no code", and the cut-only-after-seen rule.
3. Criterion 3: `template/.agents/skills/poteto-mode/playbooks/ticket.md:10` (step 6) names the append with `gh issue edit N --body-file`, both first lines, the human editing the ticket, `/architect with checkpoint` (a mode `architect/SKILL.md:48` has), and that `review-brief.sh` pastes the body; `review-brief.sh:222` fetches the body whole and pastes it under `## The ticket`.
4. Criterion 4: the delegation sentence is identical in `bug-fix.md:8`, `feature.md:10`, `perf-issue.md:16`, `refactoring.md:11` and in each patch; `./factory918.sh sync` in a scratch clone applied all 19 patches and left the tree clean.
5. Criterion 5: `template/.agents/skills/to-spec/SKILL.md:66` and `patches/mattpocock/to-spec/SKILL.md.patch` add the table to Testing Decisions; `patches/series` lists it.
6. Criterion 6: `docs/knowledge/core/SCENARIO-TABLE.md` (what, shape, where, #42 example, why), listed in `INDEX.md:13`, the `knowledge` skill greps `$KB`; `build_knowledge.py` and `check_knowledge.py` run clean, the slim copy lands in `template/docs/factory918/`, and `knowledge/SKILL.md:13` names it.
7. Ticket body shape: `docs/agents/issue-tracker.md:26` and the template copy admit the two sections after `## Blocked by`; P25, the glossary entry, SOURCES 13-15 and the M0 line record the choices.
8. Tests run in the scratch clone: `no-stale-wording`, `hooks/delegation` (55), `spec-review/review-brief` (334), `poteto-mode/overlap` (56), all ok.

## Would break

1. **The posted table feeds Ticket step 1's tokenizer, and a cell that quotes an absolute or dot-dot path refuses the ticket on any later run.** Step 6 appends the table to the body; `overlap.sh:48-50` reads every backticked whitespace-free token outside `## Diff` as a pathspec, and `SCENARIO-TABLE.md` tells the writer to backtick the cell vocabulary and quote what is printed. A table for a tool that reads or writes `~/`, `/tmp` or a parent directory carries such a token, so the next step-1 run on that ticket (a restart after a design hole per #90, a crashed lane, a second session) exits 2 with git's `outside repository` (`tests/poteto-mode/overlap.sh:124`), and nothing in the diff says the table's tokens are pathspecs or exempts the section. The #42 example already worked around it by hand: row 14 reads "unbackticked here so this ticket's own check does not trip on it".
   ```
   The Ticket playbook's architect step says that when a design adds state, the table is appended to the ticket's body under `## Testing decisions`
   ```
   Documented step: `template/.agents/skills/poteto-mode/playbooks/ticket.md:10`, "appended to the ticket's body under `## Testing decisions`"; `ticket.md:5`, "one line per open PR whose own commits ... touch a path the ticket names in backticks"; `docs/knowledge/core/SCENARIO-TABLE.md:31`, "so a cell can say `G`, `L(k)` or `B(x)`".
   Result: a well-formed table makes step 1 stop with a git fatal that names the path, not the rule; the human has to find that a design cell is being read as a pathspec and unbacktick it, as #42's row 14 did.
   spec: criterion 3

## Fails open

## Not asked for

hard findings: 1
