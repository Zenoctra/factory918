The first run of #42 (PR #87) designed a script with state in prose sketches, and three review rounds found the empty cells one at a time and redesigned the core each time. The second run (PR #92) wrote a scenario table first, and its three rounds changed no cell. Nothing in the factory asked for the table, so this PR makes it the first design deliverable for anything with state and puts it on the ticket before implementation, where the writer, the reviewer and the human read it.

## Why

`architect`'s runner prompt asked for a type sketch first, the design package stayed in the arena working directory, and the four delegation steps never named it. `review-brief.sh` already pastes the whole ticket body into the Spec brief, so a table appended to the ticket reaches the reviewer with no script change. The ticket's Decision quotes settled the rest: posting is the record, a stop before implementation is opt-in, and a cell outside the intended path costs no code.

## Scope

- `template/.agents/skills/architect/references/runner-prompt.md` (new patch `patches/pstack/architect/references/runner-prompt.md.patch`, `SOURCES.md` item 14). The first deliverable for a design with state is the scenario table, then the contract, then the test list with one assertion per cell; for stateless code that crosses a function boundary it is the usage and signature sketch the prompt already asked for. A cell for an input outside the intended path reads "refused with the tool's own message" and is cut only after the refusal was run and seen. The prompt says the orchestrator posts the synthesized deliverable on the ticket.
- `template/.agents/skills/poteto-mode/playbooks/ticket.md` step 6 (ours). When the design adds state, the table is appended to the ticket body under `## Testing decisions` with `gh issue edit N --body-file`, first line `Posted by the agent <date>` or `Approved by <name> <date>`, before implementation; the sketch goes under `## Design` the same way; a prose change has no artifact beyond its criteria. The human edits the ticket if the table is wrong; a stop is asked for only with `/architect with checkpoint`. `template/docs/agents/issue-tracker.md` and its copy `docs/agents/issue-tracker.md` name the two sections in the ticket body shape.
- The delegation steps of `feature.md` (step 4), `bug-fix.md` (step 3), `refactoring.md` (step 5) and `perf-issue.md` (step 3), through their existing patches (`SOURCES.md` item 13 amended). The test is written from the table before the implementation, one assertion per cell in the table's order, and a writer that cannot implement a cell as written stops and reports the cell.
- `template/.agents/skills/to-spec/SKILL.md`, Testing Decisions (new patch `patches/mattpocock/to-spec/SKILL.md.patch`, item 15). A fourth bullet names the table as the shape for stateful work.
- `docs/knowledge/core/SCENARIO-TABLE.md`, a sixth core document (one `CORE_DOCS` tuple in `tools/build_knowledge.py`), with the #42 table verbatim; a `Scenario table` glossary entry; `AGENTS.md` and the `knowledge` skill's slim list count it. The build regenerates `docs/knowledge/INDEX.md` and `template/docs/factory918/SCENARIO-TABLE.md`.
- Records in the last commit: `DECISIONS.md` P25, one ledger line, one dated paragraph in `docs/M0-findings.md`.
- After round 1 of the review (four fix commits): Ticket step 6 reads the body, appends the section and writes the whole file back, and stops on a failed write, since `gh issue edit --body-file` replaces the body; `overlap.sh` skips `## Testing decisions` and `## Design` as it skips `## Diff`, with one new test cell (57 assertions) and a dated amendment on P24 and on #42's design record, so a posted table's example paths do not count as paths the ticket names; `MANUAL.md` and the `build_knowledge.py` docstring count five project documents; `architect/SKILL.md` Phase B (new patch) and the to-spec bullet agree with the runner prompt.
- After the root's verification (one commit): Ticket step 6, the ticket body shape and `SCENARIO-TABLE.md` say the whole artifact stays inside its one section with `###` headings for its parts, because the overlap skip ends at the next `## ` heading; the overlap test's check 17 gains a `### Contract` part quoting a path an open PR touches, so a skip that ends early fails; #42's record predates the rule and its amendment says so. The awk line is unchanged.

Out: how a review judges a finding against the artifact (#90), any gate in `review-brief.sh` (not asked), `to-tickets` (the table is written at architect time, not at ticket time).

## Tradeoffs

- The rule lives in Ticket step 6, not in a new step. "Ticket step 5" is quoted in four playbook patches, in `SOURCES.md` and in `review-brief.sh:183`, so renumbering would touch five more files for no gain.
- The page is a core document rather than a section of `MANUAL.md` or a generated page. A core document ships to projects through `template/docs/factory918/`, a generated page needs a source under the never-edited `research/` and stays in the factory.
- `feature.md.patch` is one widened hunk rather than two: steps 2 and 4 are three lines apart, so `diff -u` merges them. The README command reproduces it byte for byte.

## Blast Radius

Every future `architect` run, every ticket a playbook runs, every spec `/to-spec` writes, and every project that runs `factory918 apply` or `update` (they get `SCENARIO-TABLE.md`). Prose only; no hook, no `settings.json`, no `factory918` skill file, so `review-brief.sh`'s cross-cutting predicate does not fire. The change is safe because `./factory918.sh sync` rebuilds the vendored skills from the pins plus the patches and leaves `git status` clean, and `tools/build_knowledge.py` regenerates the index and the slim copies and leaves it clean. The one runtime effect is that the `knowledge` skill in a project now sees one more file; `factory918 doctor` checks only PHILOSOPHY and MANUAL and is unchanged.

## Overlap

```
go: autopilot-stack
#96 feat/shellcheck: AGENTS.md SOURCES.md docs/M0-findings.md docs/agents/ledger.md docs/knowledge/INDEX.md docs/knowledge/core/DECISIONS.md template/.agents/skills/poteto-mode/scripts/overlap.sh template/docs/factory918/DECISIONS.md tests/poteto-mode/overlap.sh
```

`overlap.sh 89 --diff` at 78be65e (the same nine paths at 715100c). PR #96 is the PR for ticket #88, which the `autopilot-stack` go covers; both branch from `main`, and the root resolves the shared lines at chain time.

## Verification

Run in the branch worktree at 715100c (and at c83f166, 0c63fa6 and 78be65e before).

- `./factory918.sh sync` printed no `FAILED` line and `vendored: 72 skills`; `git diff --exit-code && test -z "$(git status --porcelain template)"` passed.
- `python3 tools/check_knowledge.py && python3 tools/build_knowledge.py && git diff --exit-code` passed (`knowledge ok: 119 files`).
- `bash -n factory918.sh` passed.
- `bash tests/hooks/delegation.sh`, `bash tests/spec-review/review-comment.sh`, `bash tests/spec-review/review-brief.sh`, `bash tests/poteto-mode/overlap.sh`, `bash tests/spec-review/no-stale-wording.sh` all passed.
- Each of the seven patches reproduces byte for byte with the command in `patches/README.md` (`diff -u --label ... | cmp - patches/<file>`).
- `shellcheck` 0.11.0 on the two changed shell files, `template/.agents/skills/poteto-mode/scripts/overlap.sh` and `tests/poteto-mode/overlap.sh`: no warnings. `bash tests/poteto-mode/overlap.sh` prints `ok 57 assertions`.
- `diff docs/agents/issue-tracker.md template/docs/agents/issue-tracker.md` prints nothing.
- The fixture flow runs in CI.

The criteria, each with the observation that failed at `ab47eb9` and passes now:

1. `architect`'s runner prompt makes the table, then the contract, then the test list the first deliverable for a design with state, else the sketch, posted under `## Design`: `grep -c -i "scenario table" template/.agents/skills/architect/references/runner-prompt.md` was 0, is 1 (line 7, with the `## Design` sentence at line 10).
2. The prompt says a cell outside the intended path reads "refused with the tool's own message" and is cut only after the refusal was run and seen: `grep -c "refused with the tool's own message"` on the same file was 0, is 1.
3. Ticket step 6 says the table is appended under `## Testing decisions`, first line `Posted by the agent <date>` or `Approved by <name> <date>`, before implementation, the human edits it, a stop only with `/architect with checkpoint`, and `review-brief.sh` pastes the body: `grep -c "Posted by the agent" template/.agents/skills/poteto-mode/playbooks/ticket.md` was 0, is 1.
4. The four delegation steps say the test comes from the table, one assertion per cell, and a writer that cannot implement a cell stops: `grep -c "one assertion per cell"` on `feature.md`, `bug-fix.md`, `refactoring.md`, `perf-issue.md` was 0 each, is 1 each.
5. `to-spec`'s Testing Decisions names the table for stateful work: `grep -c -i "scenario table" template/.agents/skills/to-spec/SKILL.md` was 0, is 1.
6. One knowledge page reachable through `/knowledge scenario table`: `rg -c -i "scenario table"` found nothing outside `DECISIONS.md`; now `docs/knowledge/INDEX.md` has the row and `docs/knowledge/core/SCENARIO-TABLE.md` (5 hits) and its slim copy `template/docs/factory918/SCENARIO-TABLE.md` (4 hits) exist, so the skill's step 1 (the index) and step 2 (the grep) both reach it.

Closes #89

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Claude Fable 5.1 on Claude Code
