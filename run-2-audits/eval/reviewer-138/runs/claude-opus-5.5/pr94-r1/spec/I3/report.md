# Spec review: #89 at ab47eb9

## Walk

1. Criterion 1, runner prompt: `patches/pstack/architect/references/runner-prompt.md.patch`, listed in `patches/series` after the four playbook patches, replaces the old "Output a candidate design package: type sketch, ..." line. The first deliverable is a scenario table, then the contract, then the test list for a design with state (a file, exit codes, rounds, more than one actor). For stateless code that crosses a function boundary it is the usage and signature sketch. It then says the orchestrator appends the table under `## Testing decisions` or the sketch under `## Design` (Ticket step 6). The template copy matches the patch. I ran `./factory918.sh sync` in a scratch git copy: all 19 patches applied, including both new ones, and `git status` stayed clean.
2. Criterion 2, the refused cell: the same bullet says the cell reads "refused with the tool's own message", costs no code, and is cut only after the refusal was run and seen. The wording matches the ticket.
3. Criterion 3, Ticket step 6 (`template/.agents/skills/poteto-mode/playbooks/ticket.md`, in `sync`'s `keep_files`, so it is edited directly): step 6 appends the table under `## Testing decisions` with `gh issue edit N --body-file` before implementation. Its first line is `Posted by the agent <date>` or `Approved by <name> <date>`. The human edits it, and a stop happens only with `/architect with checkpoint`, a phrase that exists at `template/.agents/skills/architect/SKILL.md:48`. The step also says the Spec brief carries the table because `review-brief.sh` pastes the ticket body, which it does (`review-brief.sh:222` writes the whole `gh issue view --json body`).
4. Criterion 4, delegation steps: Feature step 4, Bug fix step 3, Refactoring step 5 and Perf issue step 3 each gain the same text through their patches. The brief carries the design artifact. With a table, the writer writes the test from it first, one assertion per cell in the table's order, and the commit order shows it. A writer that cannot implement a cell stops and reports it and never fills it in. The hunk headers were regenerated (`-3,13`, `-6,9`), and the sync run confirms that they apply.
5. Criterion 5, to-spec: `patches/mattpocock/to-spec/SKILL.md.patch` adds one Testing Decisions bullet that names the scenario table as the shape for stateful work. The bullet also says the table is not excluded by the "no code snippets" rule. It applies at sync.
6. Criterion 6, knowledge page: `docs/knowledge/core/SCENARIO-TABLE.md` (88 lines) has What it is, The shape, Where it goes, The #42 example (legend, table and the first two contract paragraphs, verbatim) and Why. One `CORE_DOCS` tuple adds it to `INDEX.md`, and `build_core` copies it into `template/docs/factory918/`. The `knowledge` skill's slim-corpus line now names it. I ran `python3 tools/build_knowledge.py` in the copy: the tree stayed clean, and `check_knowledge.py` printed "knowledge ok: 119 files". A grep for "scenario table" reaches the page from INDEX in the factory and directly in a project. The project copy points to `tests/poteto-mode/overlap.sh`, "ticket #42" and "PR #92", which exist only in the factory repository. The table is inline, so the example still stands.
7. `docs/agents/issue-tracker.md` and its template copy (identical): the ticket body shape gains two optional trailing sections, `## Testing decisions` and `## Design`, with the same first-line rule.
8. `DECISIONS.md` P25 records the rule and the three placement choices (step 6 with no renumbering, a sixth core document, the README patch path). No P-number is duplicated. `SOURCES.md` items 13 to 15 describe the patch changes. `AGENTS.md` says "six core documents".
9. `docs/M0-findings.md`: a dated line says a sixth core document costs one tuple. It also notes that `sync` bumps no VERSION, against SOURCES.md line 3, which reads "re-fetch these pins, re-apply the patches, and bump VERSION". `cmd_sync` confirms the finding: it vendors from `research/` and never touches VERSION.
10. Other checks run in the copy: `tests/spec-review/no-stale-wording.sh` passed, `tests/poteto-mode/overlap.sh` passed 56 assertions, and `tests/spec-review/review-brief.sh` passed 334 assertions. No shell file changed, so rule 8's shellcheck has nothing to cover. No path is cross-cutting (no hooks, no settings.json, no `factory918` skill), so the diff has no blast-radius grounding.

## Would break

1. **A stateful design can still skip `architect` and get no table.** Step 6 ties the table to "the selected playbook's architect step". Feature step 2 still accepts `architect skipped: <reason>` for any diff that is not cross-cutting. Bug fix and Perf issue step 3 run `architect` only when the fix crosses a function boundary. On a skipped path, the design adds state, no table is written, and the delegation step's "When it is a scenario table" branch does not fire. The writer works from the criteria alone, and nothing points out the gap. The ticket's Problem names exactly this path: "The ticket had no Testing decisions because it was planned as prose, and nothing sent it back for them when the design added state." The criterion's text is met literally. The problem it exists to close stays open on the skip path. One sentence in Feature step 2's skip clause would close it, in the same form as the cross-cutting exception: a design that adds state never skips it.

   ```
   The Ticket playbook's architect step says that when a design adds state, the table is appended to the ticket's body under `## Testing decisions`, first line "Posted by the agent <date>" or "Approved by <name> <date>", before implementation
   ```

   Documented step: `template/.agents/skills/poteto-mode/playbooks/feature.md:6`, "Skipping stays as `architect skipped: <reason>`, not accepted for a cross-cutting diff (Ticket step 5)", read together with `ticket.md` step 6, "The selected playbook's architect step adds the ticket's own: when the design adds state ...".
   Result: a stateful feature skips `architect` with a reason, step 6 has no architect deliverable to post, and implementation proceeds with no `## Testing decisions` and no stop.
   spec: criterion 3

## Fails open

## Not asked for

2. **The ticket-shape doc gains two sections.** `docs/agents/issue-tracker.md` and `template/docs/agents/issue-tracker.md` now list `## Testing decisions` and `## Design` as optional trailing sections. No criterion asks for this. It keeps the body-shape doc consistent with step 6, both copies are identical as AGENTS.md requires, and it is benign.

   ```
   The Ticket playbook's architect step says that when a design adds state, the table is appended to the ticket's body under `## Testing decisions`
   ```

3. **A ledger line unrelated to the ticket's content.** `docs/agents/ledger.md` gains the 2026-09-22 entry about ending a turn with explorer lanes still running. AGENTS.md sanctions it ("a surprise goes to `docs/agents/ledger.md`"), but it is outside #89's concern.

   ```
   The knowledge base has one page on the table (what it is, the shape, the #42 example), reachable through `/knowledge scenario table`.
   ```

hard findings: 1
