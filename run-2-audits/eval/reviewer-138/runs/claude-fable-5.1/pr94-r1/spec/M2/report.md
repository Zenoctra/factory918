# Spec report, ab47eb9 (#89)

The six criteria are met in the text they name, and the knowledge build and the patch series reproduce the template. One direct edit to a vendored skill is outside the patch series and `factory918.sh sync` reverts it, and two enumerations of the core documents still say four.

## Walk

1. Criterion 1: `patches/pstack/architect/references/runner-prompt.md.patch` (in `series` after the four playbook patches) rewrites the runner's opening: with state, the scenario table, then the contract, then the test list, with the row and column vocabulary and the one-assertion-per-cell rule; without state but crossing a function boundary, the usage and signature sketch; a closing paragraph says the orchestrator appends the synthesized first deliverable to the ticket, a table under `## Testing decisions`, a sketch under `## Design`, naming Ticket step 6. `sync` in a scratch copy re-applies the patch and the template copy comes out byte-identical.
2. Criterion 2: the same hunk carries "refused with the tool's own message" and costs no code, and "Cut such a cell only after the refusal was run and seen; an assumption about a tool's failure mode is a claim until then."
3. Criterion 3: `template/.agents/skills/poteto-mode/playbooks/ticket.md:10` (step 6, in `sync`'s `keep_files`) says when the design adds state the table is appended with `gh issue edit N --body-file`, first line `Posted by the agent <date>` or `Approved by <name> <date>`, before implementation; the sketch goes under `## Design` the same way; a prose change has only its criteria; posting is the record; a stop only with `/architect with checkpoint` (which `architect/SKILL.md:48` already honours); the Spec brief carries it because `review-brief.sh` pastes the body (`review-brief.sh:222` fetches `--json body` whole). Numbering is kept, so the four "Ticket step 5" quotes and `review-brief.sh` still point right.
4. Criterion 4: the four playbook patches and the four template copies add the same sentence to Feature step 4, Bug fix step 3, Refactoring step 5 and Perf issue step 3: test from the table before the implementation, one assertion per cell in the table's order, commit order shows it, a writer that cannot implement a cell stops and reports it and never fills it in. `sync` reproduces all four.
5. Criterion 5: `patches/mattpocock/to-spec/SKILL.md.patch`, last in `series`, adds the table bullet to Testing Decisions; the template copy matches the patched result.
6. Criterion 6: `docs/knowledge/core/SCENARIO-TABLE.md` (88 lines: what it is, the shape, where it goes, the #42 legend, table and contract opening, why) is a `CORE_DOCS` tuple in `tools/build_knowledge.py`, listed in `INDEX.md` with a read-when line; `rg -i "scenario table" docs/knowledge` hits the page, the glossary entry and P25, so the `knowledge` procedure (index, grep, range) reaches it. `build_knowledge.py` in a scratch copy leaves the tree clean and `check_knowledge.py` reports `knowledge ok: 119 files`. `build_core` copies it into `template/docs/factory918/` (79 lines, header stripped) and `apply` copies every template file, so projects get it; the `knowledge` skill's slim list now names it.
7. `docs/agents/issue-tracker.md` and the template copy (identical) add the two optional sections and their first-line rule after the fixed body shape.
8. `DECISIONS.md` P25 records the rule and the three choices made in #89; `GLOSSARY.md` gets the term; `AGENTS.md` says six core documents; `SOURCES.md` 13 is amended and 14, 15 added; `M0-findings.md` gets the dated 2026-09-22 line on what a sixth core document costs.
9. `template/.agents/skills/architect/SKILL.md:32` gains one sentence pointing Phase B at the runner prompt for a design with state. This file is vendored from `research/3-pstack/upstream-cursor-plugin/skills/architect/SKILL.md` and no patch in `series` carries the sentence (item 1).
10. Run-under rule 6 (one walk line per blast-radius risk): the diff touches no cross-cutting path and the brief carries no grounding, so there is none to walk.

## Would break

1. **The architect skill's Phase B sentence is a direct edit to a vendored file and `sync` reverts it.** `template/.agents/skills/architect/SKILL.md` is re-vendored from `research/` on every `factory918.sh sync`; only `patches/pstack/architect/references/runner-prompt.md.patch` is in `series`, so the sentence "For a design with state the package opens with the scenario table, its contract and its test list, and `references/runner-prompt.md` gives the shape." exists nowhere the sync can re-apply it from. Run in a scratch copy of this commit, `./factory918.sh sync` exits 0 and `git status` shows `M template/.agents/skills/architect/SKILL.md`, the diff being that sentence removed. The AGENTS.md verification line "`./factory918.sh sync` leaves `git status` clean" fails at this commit. Fix: a `patches/pstack/architect/SKILL.md.patch` in `series`, described in `SOURCES.md`; or drop the sentence, since the runner prompt and Ticket step 6 carry the rule.
   ```
   - [ ] `architect`'s runner prompt (through its patch) makes the first deliverable, for any design with a file it reads or writes, exit codes, or more than one actor, the scenario table in the shape above, then the contract derived from it, then the test list
   ```
   Documented step: `AGENTS.md`, "Vendored skills. Change one only through a patch in `patches/`, listed in `series` and described in `SOURCES.md`, so `factory918 sync` can re-apply it." and "Verifying: `./factory918.sh sync` leaves `git status` clean."
   Result: the next sync silently drops the Phase B pointer; the rule survives only in the runner prompt and Ticket step 6.
   spec: criterion 1

2. **Two enumerations of the slim set still say four.** `docs/knowledge/core/MANUAL.md:165` ("Where to read more") says "a project carries only the first four, under `docs/factory918/`" and its list names `MANUAL`, `PHILOSOPHY`, `DECISIONS`, `GLOSSARY` and no `SCENARIO-TABLE.md`; `tools/build_knowledge.py:8` (the docstring) says the script "copies PHILOSOPHY, MANUAL, DECISIONS and GLOSSARY ... into template/docs/factory918/". `build_core` copies five and `apply` ships five. The `knowledge` skill and `AGENTS.md` were updated for the count; these two were not.
   ```
   - [ ] The knowledge base has one page on the table (what it is, the shape, the #42 example), reachable through `/knowledge scenario table`.
   ```
   Documented step: `docs/knowledge/core/MANUAL.md:165` and `tools/build_knowledge.py:8`.
   Result: a person following the manual's reading list is told the project carries four documents and is never pointed at the page; the project carries five.
   spec: criterion 6

## Fails open

3. **A stateful design that never enters `architect` gets no table and nothing says so.** Ticket step 6 ties the table to "`architect`'s first deliverable", and the four delegation sentences begin "When it is a scenario table". But Feature step 2 still allows `architect skipped: <reason>` for any diff that is not cross-cutting, and Bug fix step 3, Refactoring step 3 and Perf issue step 3 run `architect` only "If it crosses a function boundary". A change with state that stays inside one function or one script (a script that reads a state file, the #42 kind) reaches delegation under Bug fix or Perf with no architect step, hence no table, no `## Testing decisions`, and the writer's "When it is a scenario table" clause is simply never triggered; nothing in the diff refuses or names the case. The ticket's rule is unconditional on state, not on the function boundary.
   ```
   Three, and every ticket has at least one. For anything with state, the scenario table below.
   ```
   Documented step: ticket #89, "The artifacts", and `template/.agents/skills/poteto-mode/playbooks/ticket.md:10` ("when the design adds state ... `architect`'s first deliverable is the scenario table").
   Result: the stateful change is implemented from prose, the Spec brief carries no table, and the review is back to the PR #87 shape with no marker that the table was skipped. A one-clause fix: state (as step 6 defines it) is a second trigger for `architect` in the four playbooks, beside the function boundary, or a skip must say `architect skipped` and `no state: <reason>`.
   spec: criterion 3

## Not asked for

4. **A ledger line unrelated to the table.** `docs/agents/ledger.md` gains `2026-09-22 | fable | ended its turn while two explorer lanes were still reading ...`. AGENTS.md sends a surprise to the ledger, so it belongs in the repository, but it is not part of #89's ask and rides on this PR.
   ```
   - [ ] The knowledge base has one page on the table (what it is, the shape, the #42 example), reachable through `/knowledge scenario table`.
   ```

hard findings: 3
