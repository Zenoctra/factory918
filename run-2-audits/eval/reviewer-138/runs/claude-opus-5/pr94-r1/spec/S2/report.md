## Walk

1. `ticket.md:9` (step 5) selects Feature, Bug fix, Refactoring or Perf issue and runs that playbook from its step 1.
2. That playbook's architect step runs `architect`; the skip clause now refuses a skip for a cross-cutting diff (`feature.md:6`, `bug-fix.md:9`, `refactoring.md:9`, `perf-issue.md:16`).
3. `architect/SKILL.md:32` (Phase B) runs `arena` and passes `references/runner-prompt.md` as each runner's prompt.
4. `runner-prompt.md:5` tells the runner to read the architect skill in full, then makes the first deliverable conditional; `:7` gives the stateful branch (table, then contract, then test list, with the situations/input-shape/cell shape and the legend) and `:8` the stateless-crossing-a-boundary branch (usage and signature sketch). Criterion 1 met.
5. `runner-prompt.md:7` also carries both refusal-cell sentences: the cell reads "refused with the tool's own message" and costs no code, and is cut only after the refusal was run and seen. Criterion 2 met.
6. `arena/SKILL.md:44`–`:60` picks a base and grafts; `architect/SKILL.md:38` returns one synthesized package.
7. `ticket.md:10` (step 6) appends the synthesized table to the ticket body under `## Testing decisions` with `gh issue edit N --body-file`, first line `Posted by the agent <date>` or `Approved by <name> <date>`, before implementation; the sketch goes under `## Design`; a prose change has only its criteria; the human edits the ticket if it is wrong; a stop needs `/architect with checkpoint`; and it names `review-brief.sh` pasting the body. Criterion 3 met.
8. `docs/agents/issue-tracker.md:26` and its template copy admit the two sections into the documented ticket shape.
9. The delegation step of each playbook carries the artifact in the writer's brief and orders the test from the table first, one assertion per cell in the table's order, with the stop-and-report rule (`feature.md:12`, `bug-fix.md:9`, `refactoring.md:11`, `perf-issue.md:16`). Criterion 4 met.
10. `to-spec/SKILL.md:66`, through `patches/mattpocock/to-spec/SKILL.md.patch`, names the table as the Testing Decisions shape for stateful work. Criterion 5 met.
11. `review-brief.sh:222` fetches the whole ticket body and `:333` pastes it under `## The ticket (#N)`, so whatever is under `## Testing decisions` reaches the Spec reviewer. (`spec-review/SKILL.md:99` still describes that paste as "What to build and Acceptance criteria, verbatim"; the script's behaviour is right, the enumeration is one artifact short.)
12. `/knowledge scenario table` reaches the page: `docs/knowledge/INDEX.md:12` lists `core/SCENARIO-TABLE.md` at 88 lines, `core/GLOSSARY.md` defines the term, and `build_knowledge.py:42` adds the one CORE_DOCS tuple; `build_core` writes the 79-line slim copy to `template/docs/factory918/`, which `factory918.sh:131` copies into a project. I ran `python3 tools/build_knowledge.py` on the reviewed tree: 119 files, output byte-identical, `check_knowledge.py` ok. Criterion 6 met.
13. `patches/series` lists both new patches and `SOURCES.md` 14 and 15 describe them. I re-ran `sync`'s vendoring and patch loop against the pinned upstreams: all 19 patches applied, and the six touched skill files match the committed `template/` copies byte for byte.

## Would break

1. **The architect package the runner prompt now asks for has no place to put the scenario table, and two lines of the same skill still order the usage sketch first.** `runner-prompt.md:5` sends the runner to read the architect skill in full before producing anything. There it finds `SKILL.md:32`: each candidate produces a package "shaped per `references/rationale-template.md`: the caller's usage written first, then the type sketch...", and `SKILL.md:84` repeats it as the skill's Outputs. `rationale-template.md` is unchanged by this diff: its headings are Problem, Usage, Shape, Synthesis decision, Tradeoffs, Alternatives, Open questions, Next step, and `:11` instructs "Write this first, before the type sketch." There is no heading for a scenario table, a contract, or a test list, and no exception for a stateful design. So for exactly the designs this ticket is about, the runner is given two contradictory orders about what comes first, and the shape it is told to fill has nowhere for the first deliverable to live. Arena then picks a base and grafts against that shape, and the synthesized package Ticket step 6 is told to post can legitimately contain no table at all — the pre-#89 outcome, reached silently. Fixing it is one clause in `SKILL.md:32` and `:84` and one heading in `rationale-template.md`; `architect/SKILL.md` has no patch in `patches/series`, so a new patch is needed.

   ```
   - [ ] `architect`'s runner prompt (through its patch) makes the first deliverable, for any design with a file it reads or writes, exit codes, or more than one actor, the scenario table in the shape above, then the contract derived from it, then the test list
   ```

   Documented step: `template/.agents/skills/architect/SKILL.md:32` ("Each candidate produces a design package shaped per `references/rationale-template.md`: the caller's usage written first, then the type sketch, function signatures, module map, and prose rationale derived from it."), `template/.agents/skills/architect/SKILL.md:84`, and `template/.agents/skills/architect/references/rationale-template.md:11` ("Write this first, before the type sketch.")
   Result: for a stateful design the runner is told both that the table is the first deliverable and that the caller's usage is written first, and the package template it must fill has no section for the table, the contract or the test list; the synthesized package can carry no table, leaving Ticket step 6 nothing to post and the writer and reviewer back on prose.
   spec: criterion 1

## Fails open

## Not asked for

hard findings: 1
