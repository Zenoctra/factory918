## Walk

1. Criterion 1, runner prompt: `patches/pstack/architect/references/runner-prompt.md.patch` applies under `sync` and its output equals `template/.agents/skills/architect/references/runner-prompt.md`; the first deliverable is the table, contract, test list for a design with state, else the usage and signature sketch, and the sketch goes under `## Design` by the same rule.
2. Criterion 2: the runner prompt carries "refused with the tool's own message" and "costs no code", and cuts such a cell only after the refusal was run and seen.
3. Criterion 3: Ticket step 6 names `## Testing decisions`, `gh issue edit N --body-file`, the `Posted by the agent <date>` / `Approved by <name> <date>` first line, the human editing, `/architect with checkpoint`, and that `review-brief.sh` pastes the body; `review-brief.sh:222` writes the whole body to `ticket.md`.
4. Criterion 4: the four playbook patches apply and their output equals the template copies; each delegation step says test from the table first, one assertion per cell, and the writer stops on a cell it cannot implement.
5. Criterion 5: `patches/mattpocock/to-spec/SKILL.md.patch` applies and matches the template copy; `series` lists it.
6. Criterion 6: `SCENARIO-TABLE.md` is a CORE_DOCS tuple, listed in `INDEX.md`, copied header-stripped to `template/docs/factory918/`, named by the `knowledge` skill and the manual; `rg scenario table` over `$KB` finds it. The INDEX row for `MANUAL.md` is stale (item 1).
7. DECISIONS P25 says "Ticket step 5" is quoted in four patches and `review-brief.sh`: it is quoted in five patches (also `opening-a-pr.md.patch`) and `review-brief.sh` says "the Ticket playbook" without a step number. The rationale is off; the choice it defends stands.
8. `template/.agents/skills/architect/SKILL.md` Phase B gains a sentence pointing at the runner prompt; it was edited in place, not through a patch (item 2).

## Would break

1. **`INDEX.md` is stale, so `check_knowledge.py` fails and `build_knowledge.py` leaves a dirty tree.** `docs/knowledge/INDEX.md:9` says `core/MANUAL.md` has 174 lines; the file and its own header say 175. At this commit `python3 tools/check_knowledge.py` exits 1 with `core/MANUAL.md: INDEX says 174 lines, file has 175`, and `python3 tools/build_knowledge.py` rewrites that row (verified on a copy: one-line diff). The INDEX is the file the `knowledge` skill reads first.
   ```
   - [ ] The knowledge base has one page on the table (what it is, the shape, the #42 example), reachable through `/knowledge scenario table`.
   ```
   Documented step: `AGENTS.md:43`, "`python3 tools/build_knowledge.py` leaves `git status` clean, and `python3 tools/check_knowledge.py` passes."
   Result: the check fails and the build is not clean; the manual's line count in the map is wrong.
   spec: criterion 6

2. **The architect skill's pointer to the table is lost on `sync`.** `template/.agents/skills/architect/SKILL.md:32` adds "For a design with state the package opens with the scenario table, its contract and its test list, and `references/runner-prompt.md` gives the shape." `architect` is vendored from pstack and no patch in `patches/` carries this sentence. Running `./factory918.sh sync` on a copy of this commit prints `applied` for every patch and reverts that one line with no message; every other template change survives.
   ```
   - [ ] `architect`'s runner prompt (through its patch) makes the first deliverable, for any design with a file it reads or writes, exit codes, or more than one actor, the scenario table in the shape above
   ```
   Documented step: `AGENTS.md:32`, "Change one only through a patch in `patches/`, listed in `series` and described in `SOURCES.md`, so `factory918 sync` can re-apply it"; `AGENTS.md:44`, "`./factory918.sh sync` leaves `git status` clean."
   Result: the next `sync` silently drops the sentence, and the orchestrator reading Phase B is no longer told the package opens with the table.
   spec: criterion 1

## Fails open

## Not asked for

3. **A ledger line about explorer lanes.** `docs/agents/ledger.md` gains `2026-09-22 | fable | ended its turn while two explorer lanes were still reading ...`. `AGENTS.md` sends a surprise to the ledger, so it is allowed; it is not part of this ticket's concern and could ride its own commit.
   ```
   - [ ] The knowledge base has one page on the table (what it is, the shape, the #42 example), reachable through `/knowledge scenario table`.
   ```

hard findings: 2
