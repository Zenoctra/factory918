# Spec report, ab47eb9 (#89)

Two things break the repository's own verification steps: the `architect/SKILL.md` sentence was edited in the vendored copy with no patch, so `factory918 sync` deletes it; and `docs/knowledge/INDEX.md` carries a stale line count for `MANUAL.md`, so `build_knowledge.py` dirties the tree. Everything the six criteria ask for is present in the text.

## Walk

1. Criterion 1, runner prompt: `template/.agents/skills/architect/references/runner-prompt.md:7-12` (and the patch, which applies under `sync`) makes the first deliverable the scenario table, then the contract, then the test list for a design with state; the usage and signature sketch otherwise; the orchestrator appends the table under `## Testing decisions` or the sketch under `## Design` (Ticket step 6).
2. Criterion 2, refused cells: runner-prompt.md:9 says a cell for an input outside the intended path reads "refused with the tool's own message" and costs no code, and is cut only after the refusal was run and seen.
3. Criterion 3, Ticket playbook: `template/.agents/skills/poteto-mode/playbooks/ticket.md:12` (step 6) says the table is appended with `gh issue edit N --body-file`, first line `Posted by the agent <date>` or `Approved by <name> <date>`, before implementation; the human edits it; a stop only with `/architect with checkpoint`; the Spec brief carries it because `review-brief.sh` pastes the body. `review-brief.sh:222-223` does paste `gh issue view N --json body` whole.
4. Criterion 4, delegation steps: Feature step 4, Bug fix step 3, Refactoring step 5, Perf issue step 3 (templates and patches; all four patches apply under `sync`) say the test is written from the table before the implementation, one assertion per cell in the table's order, the commit order shows it, and a writer that cannot implement a cell stops and reports it, never fills it.
5. Criterion 5, to-spec: `template/.agents/skills/to-spec/SKILL.md:66` and `patches/mattpocock/to-spec/SKILL.md.patch` (listed in `series`, described in `SOURCES.md` 15) name the table as the shape for stateful work.
6. Criterion 6, the page: `docs/knowledge/core/SCENARIO-TABLE.md` (what it is, the shape, where it goes, the #42 example verbatim, why), listed in `docs/knowledge/INDEX.md:12`, defined in `GLOSSARY.md`, copied header-stripped to `template/docs/factory918/SCENARIO-TABLE.md` by `build_core` (one `CORE_DOCS` tuple). `/knowledge scenario table` reaches it through the index and grep; `check_knowledge.py` passes (119 files).
7. Records: P25 in `DECISIONS.md`, a dated M0 finding, the ledger line, `AGENTS.md` "six core documents", `MANUAL.md` "the first five", the `knowledge` skill's slim-corpus list, `docs/agents/issue-tracker.md` and its template copy (identical) naming the two optional sections.
8. Verification I ran on a copy of the snapshot (`git init` over it): `python3 tools/build_knowledge.py` (dirties `INDEX.md`, item 1), `python3 tools/check_knowledge.py` (ok), `./factory918.sh sync` (every patch applies, then dirties `architect/SKILL.md`, item 2).

## Would break

1. **The `architect/SKILL.md` sentence has no patch, so `sync` deletes it.** `template/.agents/skills/architect/SKILL.md:33` gains "For a design with state the package opens with the scenario table, its contract and its test list, and `references/runner-prompt.md` gives the shape." The file is vendored from `research/3-pstack/.../skills/architect/SKILL.md`; `cmd_sync` (`factory918.sh:384`) replaces the directory from the pin and re-applies `patches/series`, which carries only `pstack/architect/references/runner-prompt.md.patch`. Running `./factory918.sh sync` on the snapshot leaves `template/.agents/skills/architect/SKILL.md` modified: the sentence is gone and `git status` is not clean. `SOURCES.md` item 14 describes only the runner-prompt patch, so nothing records the SKILL.md edit either.
   ```
   - [ ] `architect`'s runner prompt (through its patch) makes the first deliverable, for any design with a file it reads or writes, exit codes, or more than one actor, the scenario table in the shape above, then the contract derived from it, then the test list; ...
   ```
   Documented step: `AGENTS.md:32` ("Vendored skills. Change one only through a patch in `patches/`, listed in `series` and described in `SOURCES.md`, so `factory918 sync` can re-apply it") and `AGENTS.md:44` ("`./factory918.sh sync` leaves `git status` clean").
   Result: `sync` prints `applied` for every patch and exits 0, then `git status` shows `M template/.agents/skills/architect/SKILL.md`; the next re-vendor silently drops the Phase B sentence that points runners at the table.
   spec: criterion 1

2. **`INDEX.md` records `MANUAL.md` at 174 lines; it is 175.** The commit that added the `SCENARIO-TABLE.md` bullet to `docs/knowledge/core/MANUAL.md` updated its own header (`<!-- lines: 175 -->`) but `docs/knowledge/INDEX.md:9` still says 174 (the other core rows were refreshed). `python3 tools/build_knowledge.py` on the snapshot rewrites that one cell and leaves `INDEX.md` modified.
   ```
   - [ ] The knowledge base has one page on the table (what it is, the shape, the #42 example), reachable through `/knowledge scenario table`.
   ```
   Documented step: `AGENTS.md:43` ("`python3 tools/build_knowledge.py` leaves `git status` clean, and `python3 tools/check_knowledge.py` passes").
   Result: the build leaves `M docs/knowledge/INDEX.md` (174 → 175); `check_knowledge.py` passes, so nothing else flags the stale count.
   spec: criterion 6

## Fails open

## Not asked for

hard findings: 2
