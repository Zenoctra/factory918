# Design note for ticket #89 (owner lane; the writer implements this)

The ticket: https://github.com/Zenoctra/factory918/issues/89. Read its body whole first (`gh issue view 89 --repo Zenoctra/factory918 --json body --jq .body`), then `.scratch/program/89/how.md` (how the pieces connect today). The worked example of a scenario table is ticket #42's `## Testing decisions` section (`gh issue view 42 --repo Zenoctra/factory918 --json body --jq .body`).

The change is prose and patches only. Six criteria, seven files or file groups, six commits in this order. Every sentence below is the intended content; polish the wording under `/writing-for-agents` (skills, playbooks, SOURCES) and `/technical-writing` then `/unslop` (the knowledge page, commit messages), but keep every term the ticket names: "scenario table", "cell", "contract", "test list", "one assertion per cell", "refused with the tool's own message", "Posted by the agent <date>", "Approved by <name> <date>", "/architect with checkpoint", "## Testing decisions", "## Design". House style for agent-facing prose: short sentences, no long dash character, no "note that", no narrating comments.

## Settled choices (do not reopen)

1. Criterion 3 lands in Ticket playbook step 6, extended in place. No new step and no renumbering: "Ticket step 5" is quoted in four playbook patches, in `SOURCES.md` and in `review-brief.sh:183`, and `ticket.md` itself names step 8.
2. The knowledge page is a sixth core document, `docs/knowledge/core/SCENARIO-TABLE.md`, so it ships to projects through `template/docs/factory918/` (the build copies every core doc except `CONVERSATION-DIGEST.md`). Only two prose counts change with it: `AGENTS.md:9` ("the five core documents" becomes six) and `template/.agents/skills/knowledge/SKILL.md:13` (the slim list). Do not touch `docs/FACTORY-SPEC-v2.md`, `tools/bootstrap/`, `template/.claude/hooks/*`, `template/.agents/skills/factory918/*` (the last two are cross-cutting paths and would change the review's shape).
3. The to-spec patch follows `patches/README.md`'s path rule: `patches/mattpocock/to-spec/SKILL.md.patch` (labels `a/to-spec/SKILL.md`, `b/to-spec/SKILL.md`). The architect patch: `patches/pstack/architect/references/runner-prompt.md.patch`.
4. Posting on the ticket is the orchestrator's act (Ticket step 6), never the runner's; the runner prompt only names the destination.
5. Nothing about design holes or how a review judges a finding against the artifact: that is ticket #90. Nothing about enforcement in `review-brief.sh`: not asked.

## Commit 1. The runner prompt (criteria 1 and 2)

File: `template/.agents/skills/architect/references/runner-prompt.md` (vendored, unpatched today; byte-identical to `research/3-pstack/open-pstack-claude-code-port/plugins/pstack/skills/architect/references/runner-prompt.md`).

Replace the deliverable sentence in line 5 ("Output a candidate design package: type sketch, function signatures, module map, and prose rationale shaped per ...") with an ordered spine, keeping the rest of line 5 and the whole discipline list (lines 7 to 18, including line 9 "Caller's usage first") as they are. Intended content:

> Output a candidate design package. Its first deliverable depends on what the design has.
>
> - With state (a file it reads or writes, exit codes, rounds, or more than one actor): a scenario table, then the contract derived from it, then the test list. Situations go down the side (the states the world can be in: no record, a stale ref, a failing tool, a body with no token), the shape of the input across the top (none, one, siblings, one containing the other, the caller's own), and every cell says what is printed, the exit code and what the caller does next. A legend defines the cell vocabulary once. The contract defines every term the cells use. The test list has one assertion per cell, in the order the cells are written, each naming the fixture state it needs. A cell for an input outside the intended path reads "refused with the tool's own message" and costs no code. Cut such a cell only after the refusal was run and seen; an assumption about a tool's failure mode is a claim until then.
> - Without state, crossing a function boundary: the usage and signature sketch, the caller's usage first, then the types and signatures (the discipline below).
>
> Then the type sketch, function signatures, module map, and prose rationale shaped per [`rationale-template.md`](rationale-template.md). The orchestrator appends the synthesized first deliverable to the ticket before implementation, a table under `## Testing decisions`, a sketch under `## Design` (the Ticket playbook, step 6); the writer, the reviewer and the human read it there.

Then: regenerate the patch with the README command, add `pstack/architect/references/runner-prompt.md.patch` to `patches/series` (after `pstack/poteto-mode/playbooks/refactoring.md.patch` is fine; position is free), add item 14 to `SOURCES.md`'s Patches list: "`architect/references/runner-prompt.md`: the first deliverable is the scenario table, then the contract, then the test list for a design with state (a file it reads or writes, exit codes, rounds, more than one actor), else the usage and signature sketch; a cell for an input outside the intended path reads "refused with the tool's own message" and is cut only after the refusal was run and seen; the orchestrator posts the synthesized deliverable on the ticket (#89)."

## Commit 2. The ticket carries the artifact (criterion 3)

File: `template/.agents/skills/poteto-mode/playbooks/ticket.md` (ours, `keep_files`; edit directly, no patch). Extend step 6 (line 10). Intended content, replacing the step:

> 6. The spec's **Testing decisions** are the pre-agreed seams. `tdd` there, and nowhere the spec did not agree unless a criterion needs it. The selected playbook's architect step adds the ticket's own: when the design adds state (a file it reads or writes, exit codes, rounds, or more than one actor), `architect`'s first deliverable is the scenario table (its runner prompt gives the shape), and before implementation the synthesized table is appended to the ticket's body under `## Testing decisions` with `gh issue edit N --body-file`, first line `Posted by the agent <date>`, or `Approved by <name> <date>` when the human approved it first. When the design is code with no state that crosses a function boundary, the usage and signature sketch goes under `## Design` the same way. A prose change has no artifact beyond its criteria. Posting is the record: the human edits the ticket if the table is wrong, and a stop before implementation is asked for only with `/architect with checkpoint`. The Spec brief carries the table because `review-brief.sh` pastes the ticket body.

File: `template/docs/agents/issue-tracker.md`, "Ticket body" (line 16 to 26), then copy the file to `docs/agents/issue-tracker.md` (the two are byte-identical today; keep them so). After the bullet list and before "Anything an agent may pick up ...", add a paragraph:

> The architect step may append two more sections before implementation, after these: `## Testing decisions`, the scenario table, when the design has state; `## Design`, the usage and signature sketch, when it is code with no state that crosses a function boundary. Their first line is `Posted by the agent <date>` or `Approved by <name> <date>` (the Ticket playbook, step 6). The human edits them in place; `spec-review` reads them as spec because the body is pasted whole.

## Commit 3. The writer works from the table (criterion 4)

Files (vendored, each already patched by `SOURCES.md` item 13): `template/.agents/skills/poteto-mode/playbooks/feature.md` step 4 (line 12), `bug-fix.md` step 3 (line 9), `refactoring.md` step 5 (line 11), `perf-issue.md` step 3 (line 16). Append one sentence pair to each delegation step, after "review its diff yourself." / "review the diff." (in perf-issue before "Capture a post-fix trace."):

> The brief carries the ticket's design artifact (Ticket step 6). When it is a scenario table, the writer writes the test from the table before the implementation, one assertion per cell in the table's order, and the commit order shows it; a writer that cannot implement a cell as written stops and reports the cell, and never fills it in.

Regenerate the four patches (feature.md.patch gains a second hunk; the other three widen). Amend `SOURCES.md` item 13 with a sentence: "The delegation step of each (Feature step 4, Bug fix step 3, Refactoring step 5, Perf issue step 3) says the test is written from the scenario table before the implementation, one assertion per cell, and that a writer who cannot implement a cell as written stops and reports it (#89)."

## Commit 4. to-spec names the table (criterion 5)

File: `template/.agents/skills/to-spec/SKILL.md`, `## Testing Decisions` (lines 59 to 65; keep the upstream Title Case heading). Add a fourth bullet:

> - For stateful work (a file read or written, exit codes, more than one actor), the shape is the scenario table: situations down the side, the shape of the input across the top, and in every cell what is printed, the exit code and what the caller does next. The table is the test list, one assertion per cell. It is a decision, not a code snippet, so the rule above does not exclude it.

Regenerate the patch to `patches/mattpocock/to-spec/SKILL.md.patch`, append it to `patches/series` (last), add item 15 to `SOURCES.md`: "`to-spec/SKILL.md` Testing Decisions: the scenario table is the shape for stateful work (#89)."

## Commit 5. The knowledge page (criterion 6)

New file `docs/knowledge/core/SCENARIO-TABLE.md`, under 200 body lines, written for a person under `/technical-writing`. Title line `# Factory918: the scenario table`. Sections (H2 so the mini-TOC lists them): `## What it is` (a design tool for anything with state, not a #42 thing; quote the agent's sentence from the ticket's Decision and Manuel's "I agree with your choice completely" on posting being the record); `## The shape` (situations, input shapes, cells, legend, contract, test list; the refused cell and the cut rule with the ledger 2026-09-21 line); `## Where it goes` (the ticket body under `## Testing decisions` with the Posted by / Approved by first line before implementation; the sketch under `## Design` for stateless boundary code; prose has its criteria; `review-brief.sh` pastes the body so the reviewer reads it; `/architect with checkpoint` is the only stop); `## The #42 example` (the legend and the table from #42's `## Testing decisions`, verbatim, and the first two paragraphs of its contract); `## Why` (PR #87's three rounds found 2, 4, 4 hard findings and each fix round redesigned the core; PR #92 wrote the table first, the writer found the one hole at the test, the rounds found 2, 1, 2 items and no cell changed). The literal words "scenario table" must appear in the title and the first paragraph so `rg -i "scenario table"` and the INDEX row find it.

`tools/build_knowledge.py`: add a `CORE_DOCS` tuple after GLOSSARY: `("core/SCENARIO-TABLE.md", "Factory918: the scenario table", "Designing or reviewing anything with state: a file, exit codes, more than one actor.")`.

`docs/knowledge/core/GLOSSARY.md`: entry between **Router** and **Seam**: `**Scenario table.** The design artifact for anything with state: situations down the side, the input's shape across the top, every cell what is printed, the exit code and what the caller does next. Posted on the ticket under ` + "`## Testing decisions`" + ` before implementation; the test is one assertion per cell. The page is ` + "`SCENARIO-TABLE.md`" + `. (Ticket #42, second run)`.

`AGENTS.md:9`: "the six core documents". `template/.agents/skills/knowledge/SKILL.md:13`: the slim list becomes "philosophy, manual, decisions, glossary and the scenario table only".

Then run `python3 tools/build_knowledge.py` and `python3 tools/check_knowledge.py`; commit the regenerated `docs/knowledge/INDEX.md`, the refreshed header of the new file and the generated `template/docs/factory918/SCENARIO-TABLE.md` together with the sources.

## Commit 6. Records

- `docs/knowledge/core/DECISIONS.md`, Provisional table, new last row P25 "The design artifact on the ticket": Choice = for a design with state the architect step's first deliverable is a scenario table appended to the ticket under `## Testing decisions` before implementation, first line `Posted by the agent <date>`; the usage and signature sketch under `## Design` for stateless code that crosses a function boundary; prose has its criteria; posting is the record and a stop is asked only with `/architect with checkpoint`; the table is the test, one assertion per cell; a cell outside the intended path reads "refused with the tool's own message" and is cut only after the refusal was run and seen. Choices made in #89: the rule lives in Ticket step 6 (no renumbering, since "Ticket step 5" is quoted in four patches and `review-brief.sh`); the page is a sixth core document so projects get it; the to-spec patch follows the README path. Reason = Ticket #89: the agent's "It is a general design tool, not a #42 thing" and Manuel's "I agree with your choice completely" on posting as the record; PR #87's three rounds redesigned the core three times, PR #92's found 2, 1, 2 items and no cell changed. 2026-09-22. Then rebuild the knowledge base again (the slim DECISIONS copy changes).
- `docs/agents/ledger.md`, append: `2026-09-22 | fable | ended its turn while two explorer lanes were still reading, the harness removed its worktree, and both lanes died without a report | drain every lane before the turn ends; a lane with no worktree cannot report`.
- `docs/M0-findings.md`, append a dated paragraph: `2026-09-22. A sixth core document costs one CORE_DOCS tuple in tools/build_knowledge.py and no other code: build_core copies every core document except CONVERSATION-DIGEST.md into template/docs/factory918/, apply copies that directory, doctor checks only PHILOSOPHY and MANUAL. factory918.sh sync (0.3.0) bumps no VERSION and touches no network, against what SOURCES.md line 3 says; the code is the truth (#89).`

## Checks (run after every commit; all must pass before you hand back)

- `./factory918.sh sync > /dev/null && git diff --exit-code && test -z "$(git status --porcelain template)"` (sync must print no `FAILED` line; run it once without the redirect to see).
- `python3 tools/check_knowledge.py && python3 tools/build_knowledge.py && git diff --exit-code`.
- `bash tests/spec-review/no-stale-wording.sh`, `bash tests/spec-review/review-brief.sh`, `bash tests/spec-review/review-comment.sh`, `bash tests/hooks/delegation.sh`, `bash tests/poteto-mode/overlap.sh`.
- Each regenerated patch reproduces byte-for-byte with the README command (diff the command's output against the checked-in file).
- The six criterion greps: `grep -n -i "scenario table" template/.agents/skills/architect/references/runner-prompt.md`; `grep -n "refused with the tool's own message" template/.agents/skills/architect/references/runner-prompt.md`; `grep -n "Posted by the agent" template/.agents/skills/poteto-mode/playbooks/ticket.md`; `grep -n -c "one assertion per cell" template/.agents/skills/poteto-mode/playbooks/{feature,bug-fix,refactoring,perf-issue}.md` (1 each); `grep -n -i "scenario table" template/.agents/skills/to-spec/SKILL.md`; `rg -n -i "scenario table" docs/knowledge/INDEX.md docs/knowledge/core/SCENARIO-TABLE.md template/docs/factory918/SCENARIO-TABLE.md`.
