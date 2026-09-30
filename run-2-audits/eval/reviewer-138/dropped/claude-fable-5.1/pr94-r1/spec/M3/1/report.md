## Walk

1. Criterion 1: `patches/pstack/architect/references/runner-prompt.md.patch` (in `patches/series`) rewrites the runner's opening so the first deliverable is the scenario table, then the contract, then the test list for a design with state, else the usage and signature sketch; the last new paragraph tells the orchestrator to append the synthesized deliverable to the ticket under `## Testing decisions` or `## Design` (Ticket step 6). `./factory918.sh sync` on a copy of the reviewed tree applies the patch and reproduces `template/.agents/skills/architect/references/runner-prompt.md` byte for byte.
2. Criterion 2: the same patch carries the refusal-cell sentence and the "cut only after the refusal was run and seen" rule, wording matching the ticket.
3. Criterion 3: `template/.agents/skills/poteto-mode/playbooks/ticket.md` step 6 (a `keep_files` entry of `sync`, so edited directly) says when the table is written, that it is appended with `gh issue edit N --body-file`, the `Posted by the agent <date>` / `Approved by <name> <date>` first line, the human edits, the `/architect with checkpoint` opt-in, and that the Spec brief carries it because `review-brief.sh` pastes the body. `review-brief.sh` lines 222-223 fetch `gh issue view N --json body` whole, so the table reaches the Spec reviewer with no further change; this brief's own `## The ticket (#89)` section is that paste. `docs/agents/issue-tracker.md` and its template copy (identical) name the two optional sections.
4. Criterion 4: the four playbook patches each add the same sentence to the delegation step (Feature 4, Bug fix 3, Refactoring 5, Perf issue 3): test from the table before the implementation, one assertion per cell in the table's order, commit order shows it, a writer that cannot implement a cell stops and reports it and never fills it. `sync` applies all four and the template copies match.
5. Criterion 5: `patches/mattpocock/to-spec/SKILL.md.patch` adds the scenario-table bullet to Testing Decisions, with the sentence that it is a decision, not a code snippet; `sync` applies it (`git apply` from `template/.agents/skills`, path `to-spec/SKILL.md`) and the template copy matches. `SOURCES.md` lists it as 15 and the runner-prompt patch as 14.
6. Criterion 6: `docs/knowledge/core/SCENARIO-TABLE.md` (what it is, the shape, where it goes, the #42 legend, table and contract, why) is a sixth `CORE_DOCS` tuple in `tools/build_knowledge.py`; `INDEX.md` lists it with "Designing or reviewing anything with state", so the knowledge skill's index-then-grep finds it for "scenario table"; `check_knowledge.py` passes (119 files). The header-stripped copy lands in `template/docs/factory918/SCENARIO-TABLE.md`, the `knowledge` skill's slim-corpus line and the manual's "Where to read more" name it. The page tells a reader to open `tests/poteto-mode/overlap.sh` and ticket #42 / PR #92, which exist in the factory and not in a project that carries the copy.
7. `DECISIONS.md` P25 records the choices; its justification says "Ticket step 5" is quoted in four patches and `review-brief.sh`, but `review-brief.sh` quotes no step number (it says "the Ticket playbook says it in words"); the four patches do quote it.
8. Step 8 of the Ticket playbook is unchanged: under `--diff`, `overlap.sh` replaces the body's tokens with the branch's own changed files (line 84), so a posted table's backticked tokens do not enter the record step; they enter only a later step-1 run on the same ticket, as pathspecs, where a non-path token matches nothing (#42 row 13) and a real path is a named path by P24's rule.
9. `tests/spec-review/no-stale-wording.sh` passes. `AGENTS.md` and the `knowledge` skill now say six core documents and "the first five" travel.

## Would break

1. **The architect skill's own sentence is edited in the vendored file, not in a patch, and `sync` removes it.** `template/.agents/skills/architect/SKILL.md` line 32 gains "For a design with state the package opens with the scenario table, its contract and its test list, and `references/runner-prompt.md` gives the shape." That file is vendored from `research/3-pstack/open-pstack-claude-code-port/plugins/pstack/skills/architect/SKILL.md` (identical to it before this change), is not in `sync`'s `keep_files`, and no patch in `patches/series` touches it. Running `./factory918.sh sync` on a copy of the reviewed tree rewrote exactly one file, this one, back to the upstream text; every other change in the diff survived because it went through a patch.

```
- [ ] `architect`'s runner prompt (through its patch) makes the first deliverable, for any design with a file it reads or writes, exit codes, or more than one actor, the scenario table in the shape above, then the contract derived from it, then the test list; ...
```

Documented step: `AGENTS.md`, "The ways to hurt yourself" 3: "Vendored skills. Change one only through a patch in `patches/`, listed in `series` and described in `SOURCES.md`, so `factory918 sync` can re-apply it." and "Verifying": "`./factory918.sh sync` leaves `git status` clean."
Result: `sync` leaves `git status` dirty on `template/.agents/skills/architect/SKILL.md`, and the next sync that is committed silently drops the sentence that points Phase B at the table; the runner prompt keeps the rule, so the skill's own description of the package no longer matches what its runners are told to produce.
spec: criterion 1

2. **`INDEX.md` was committed one line stale for `MANUAL.md`; the build is not clean at the reviewed commit.** The diff changes `core/MANUAL.md`'s header from `lines: 174` to `lines: 175` (it gains the `SCENARIO-TABLE.md` bullet) but leaves the `INDEX.md` row `core/MANUAL.md | ... | 174` untouched (the row appears as unchanged context in the diff and in this brief's reading pack). Running `python3 tools/build_knowledge.py` on the reviewed tree rewrote that row to 175.

```
- [ ] The knowledge base has one page on the table (what it is, the shape, the #42 example), reachable through `/knowledge scenario table`.
```

Documented step: `AGENTS.md`, "Verifying": "`python3 tools/build_knowledge.py` leaves `git status` clean, and `python3 tools/check_knowledge.py` passes."
Result: the build modifies `docs/knowledge/INDEX.md`, so the verify step fails on this branch and the index the `knowledge` skill reads first carries a wrong line count until someone else rebuilds.
spec: criterion 6

## Fails open

## Not asked for

hard findings: 2
