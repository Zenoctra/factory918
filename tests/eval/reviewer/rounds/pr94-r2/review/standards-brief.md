# Standards review brief

Read nothing beyond this brief unless a finding needs the code around a hunk, and then read that one function or section, not the file. Run nothing.

## Commits

0c63fa6 Make the architect skill and the to-spec bullet agree with the runner prompt
ca2c106 Count five project documents in the manual and the build script
3f5033f Skip the two artifact sections in the overlap check
b368116 Write the whole ticket body back when posting the design artifact

## Changed files

 SOURCES.md                                         |  2 +-
 docs/knowledge/INDEX.md                            |  2 +-
 docs/knowledge/core/DECISIONS.md                   |  2 +-
 docs/knowledge/core/MANUAL.md                      |  5 +++--
 docs/knowledge/core/SCENARIO-TABLE.md              |  4 ++--
 patches/mattpocock/to-spec/SKILL.md.patch          |  2 +-
 patches/pstack/architect/SKILL.md.patch            | 11 +++++++++++
 patches/series                                     |  1 +
 template/.agents/skills/architect/SKILL.md         |  2 +-
 .../.agents/skills/poteto-mode/playbooks/ticket.md |  2 +-
 .../.agents/skills/poteto-mode/scripts/overlap.sh  | 14 ++++++-------
 template/.agents/skills/to-spec/SKILL.md           |  2 +-
 template/docs/factory918/DECISIONS.md              |  2 +-
 template/docs/factory918/MANUAL.md                 |  3 ++-
 template/docs/factory918/SCENARIO-TABLE.md         |  4 ++--
 tests/poteto-mode/overlap.sh                       | 23 +++++++++++++++++-----
 tools/build_knowledge.py                           |  2 +-
 17 files changed, 55 insertions(+), 28 deletions(-)

## Diff

```diff
diff --git a/SOURCES.md b/SOURCES.md
index ef59d13..a2dfde9 100644
--- a/SOURCES.md
+++ b/SOURCES.md
@@ -23,5 +23,5 @@ Upstream pins for everything vendored into `template/`. Pinned copies of each up
 9. Every remaining `/no-comments` reference removed from `poteto-mode/` (router step list, `playbooks/autopilot-full.md`, `playbooks/autopilot-stack.md`, `playbooks/multi-phase-plan.md`, `references/codex-tools.md`), since the skill is not vendored (decision 4).
 12. `babysit/SKILL.md` step 4: ready also requires the `spec-review` comment on the latest commit to read `act-on items: 0`. The review runs at most three rounds on one PR: a comment reading `round: 3 of 3` and `act-on items: 0` makes the PR review-ready even when the fix commits it names come after the reviewed commit, and an Ask item waits for the human, then is re-sorted and the comment rebuilt with `review-comment.sh <dir>` in the same round.
 13. `playbooks/feature.md` step 2, `playbooks/bug-fix.md` step 3, `playbooks/refactoring.md` step 3 and `playbooks/perf-issue.md` step 3: the `architect` skip clause gains one sentence, that a cross-cutting diff (the Ticket playbook, step 5) never skips it. The delegation step of each (Feature step 4, Bug fix step 3, Refactoring step 5, Perf issue step 3) says the test is written from the scenario table before the implementation, one assertion per cell, and that a writer who cannot implement a cell as written stops and reports it (#89).
-14. `architect/references/runner-prompt.md`: the first deliverable is the scenario table, then the contract, then the test list for a design with state (a file it reads or writes, exit codes, rounds, more than one actor), else the usage and signature sketch; a cell for an input outside the intended path reads "refused with the tool's own message" and is cut only after the refusal was run and seen; the orchestrator posts the synthesized deliverable on the ticket (#89).
+14. `architect/references/runner-prompt.md` and `architect/SKILL.md` Phase B: the first deliverable is the scenario table, then the contract, then the test list for a design with state (a file it reads or writes, exit codes, rounds, more than one actor), else the usage and signature sketch; a cell for an input outside the intended path reads "refused with the tool's own message" and is cut only after the refusal was run and seen; the orchestrator posts the synthesized deliverable on the ticket (#89).
 15. `to-spec/SKILL.md` Testing Decisions: the scenario table is the shape for stateful work (#89).
diff --git a/docs/knowledge/INDEX.md b/docs/knowledge/INDEX.md
index 16690b5..61fd07a 100644
--- a/docs/knowledge/INDEX.md
+++ b/docs/knowledge/INDEX.md
@@ -6,7 +6,7 @@ The literal transcript of the conversation that produced this system is not avai
 | file | what | lines | read when |
 |---|---|---|---|
 | `core/PHILOSOPHY.md` | Factory918: philosophy | 64 | First. Whenever the spec is silent. |
-| `core/MANUAL.md` | Factory918: the manual | 174 | How to run the loop; what the human does at each point. |
+| `core/MANUAL.md` | Factory918: the manual | 175 | How to run the loop; what the human does at each point. |
 | `core/DECISIONS.md` | Factory918: decisions | 93 | Before overriding any vendored skill; these win. |
 | `core/GLOSSARY.md` | Factory918: glossary | 71 | A term in AGENTS.md, a playbook or a ticket is unclear. |
 | `core/SCENARIO-TABLE.md` | Factory918: the scenario table | 88 | Designing or reviewing anything with state: a file, exit codes, more than one actor. |
diff --git a/docs/knowledge/core/DECISIONS.md b/docs/knowledge/core/DECISIONS.md
index cfba5b8..f01b3e6 100644
--- a/docs/knowledge/core/DECISIONS.md
+++ b/docs/knowledge/core/DECISIONS.md
@@ -89,5 +89,5 @@ Travels anywhere without change: the planning skills, the execution playbooks, `
 | P23 | The Spec report opens with a walk | `## Walk` is the Spec report's first heading: one numbered line per documented step of the path the change touches (the ticket's criteria and the documentation the diff changes), each saying what the code does at that step. Its lines are numbered 1..K on their own, are not findings and are not judged; `review-comment.sh` leaves them out of the item count, the numbering check and the `[P<n>]` set, so the findings start at 1 under `## Would break` | A finding starts from a documented step, so the reviewer walks the path before looking for what breaks on it; counted as items, a walk of nine steps would push every finding's number and break the judgment's references (#81). 2026-09-21. |
 | P22 | Who signs a comment | A comment the agent posts on a PR or a ticket ends with the model and harness (`Claude Fable 5.1 on Claude Code`), plus `approved by <name>` when the human approved it before posting; only an approved comment posted from the author's account is the author's words. `review-brief.sh` reads only the PR author's account for rounds and carry-forward | Manuel, 2026-09-18: a comment left by the orchestrator without human involvement is signed by the model on the harness; approved, it is signed by both; strangers' comments never reach a brief (#78 round 1). |
 | P2 | Tool versions in CI | Pin every tool CI runs to an exact version, as a devDependency where the tool publishes one | `dlx` and `npx` resolve the latest version, so a rule engine or formatter can change under a project with no diff to show for it. Spec §0 rule 1 already says to pin what you install; this extends it to what CI fetches. First applied to `@ast-grep/cli` 0.45.3 in M0. |
-| P24 | Overlap is not coupling; a go is a line that covers its own tickets | Two unblocked tickets relate three ways: dependent (`Blocked by`, off the frontier), disjoint in files (parallel branches off `main`), or overlapping in files (sequenced: one to merge-ready, the merge, then the next). Coupled work, a ticket that needs code an open PR introduces, stacks, and only on a go. Ticket step 1 runs `.claude/skills/poteto-mode/scripts/overlap.sh N` before branching: every open PR's head is fetched fresh and its own commits (its diff from the open PR it stacks on, else `origin/main`) are matched with the ticket body's backticked tokens as pathspecs (its `## Diff` section excluded), so a file, a directory, a glob or a file the PR creates all match; exit 0 prints `base: <ref>` to branch from, exit 1 stops and names the PR to merge first, exit 2 means the check could not run and stderr says why. A go is a line `<label>: #a #b ...` that `overlap.sh go "<label>" N...` appends to the gitignored `.claude/state/program`, written by the orchestrator when the human gives it (autopilot-stack step 3 runs it itself). A go covers a stack only when a line names the ticket and, for every overlapping PR, the ticket that PR closes; so a line a dead program left behind covers nothing outside its own tickets' open PRs and needs no removal. Under a cover the base is the overlapping PR's head, the lowest-numbered when siblings overlap, the containing one when one contains the other; step 8's `--diff` run records the shared paths as the PR body's `## Overlap` section | Ticket #42, Manuel: "working a ticket to completion before automatically moving on"; the #16 to #22 stack was built on a seven-re-reviews mis-estimate (ledger 2026-09-17). First run (PR #87, closed): three review rounds redesigned the matcher three times; the second run designed from a scenario table Manuel approved 2026-09-21 as the ticket's Testing decisions. Rejected: a ticket label as the go (outlives the program), a line pasted into each lane's brief (a forgotten paste blocks a lane), a `done` step (a crash skips it), the script under the factory918 skill (every later edit cross-cutting). |
+| P24 | Overlap is not coupling; a go is a line that covers its own tickets | Two unblocked tickets relate three ways: dependent (`Blocked by`, off the frontier), disjoint in files (parallel branches off `main`), or overlapping in files (sequenced: one to merge-ready, the merge, then the next). Coupled work, a ticket that needs code an open PR introduces, stacks, and only on a go. Ticket step 1 runs `.claude/skills/poteto-mode/scripts/overlap.sh N` before branching: every open PR's head is fetched fresh and its own commits (its diff from the open PR it stacks on, else `origin/main`) are matched with the ticket body's backticked tokens as pathspecs (its `## Diff`, `## Testing decisions` and `## Design` sections excluded; amended 2026-09-22 by #89 so a posted table's example paths do not count), so a file, a directory, a glob or a file the PR creates all match; exit 0 prints `base: <ref>` to branch from, exit 1 stops and names the PR to merge first, exit 2 means the check could not run and stderr says why. A go is a line `<label>: #a #b ...` that `overlap.sh go "<label>" N...` appends to the gitignored `.claude/state/program`, written by the orchestrator when the human gives it (autopilot-stack step 3 runs it itself). A go covers a stack only when a line names the ticket and, for every overlapping PR, the ticket that PR closes; so a line a dead program left behind covers nothing outside its own tickets' open PRs and needs no removal. Under a cover the base is the overlapping PR's head, the lowest-numbered when siblings overlap, the containing one when one contains the other; step 8's `--diff` run records the shared paths as the PR body's `## Overlap` section | Ticket #42, Manuel: "working a ticket to completion before automatically moving on"; the #16 to #22 stack was built on a seven-re-reviews mis-estimate (ledger 2026-09-17). First run (PR #87, closed): three review rounds redesigned the matcher three times; the second run designed from a scenario table Manuel approved 2026-09-21 as the ticket's Testing decisions. Rejected: a ticket label as the go (outlives the program), a line pasted into each lane's brief (a forgotten paste blocks a lane), a `done` step (a crash skips it), the script under the factory918 skill (every later edit cross-cutting). |
 | P25 | The design artifact on the ticket | For a design with state (a file it reads or writes, exit codes, rounds, or more than one actor) the architect step's first deliverable is a scenario table, appended to the ticket under `## Testing decisions` before implementation, first line `Posted by the agent <date>` (or `Approved by <name> <date>` when the human approved it first); the usage and signature sketch goes under `## Design` for stateless code that crosses a function boundary; prose has its criteria. Posting is the record: the human edits the ticket if the table is wrong, and a stop is asked for only with `/architect with checkpoint`. The table is the test, one assertion per cell; a cell for an input outside the intended path reads "refused with the tool's own message" and is cut only after the refusal was run and seen. Choices made in #89: the rule lives in Ticket step 6 (no renumbering, since "Ticket step 5" is quoted in four patches and `review-brief.sh`); the page is a sixth core document so projects get it; the to-spec patch follows the README path | Ticket #89: the agent's "It is a general design tool, not a #42 thing" and Manuel's "I agree with your choice completely" on posting as the record. PR #87's three rounds redesigned the core three times; PR #92's found 2, 1, 2 items and no cell changed. 2026-09-22. |
diff --git a/docs/knowledge/core/MANUAL.md b/docs/knowledge/core/MANUAL.md
index 0607df6..a67d886 100644
--- a/docs/knowledge/core/MANUAL.md
+++ b/docs/knowledge/core/MANUAL.md
@@ -1,4 +1,4 @@
-<!-- lines: 174 | source: core/MANUAL.md | part 1/1 | title: Factory918: the manual -->
+<!-- lines: 175 | source: core/MANUAL.md | part 1/1 | title: Factory918: the manual -->
 
 ## Contents (line numbers are for the Read tool's offset)
 - L24: The loop in one screen
@@ -162,12 +162,13 @@ Rough cost order of the skills, highest first: `arena`, autopilot-stack (one own
 
 ## Where to read more
 
-Everything below lives in the factory clone (`~/.factory918`); a project carries only the first four, under `docs/factory918/`.
+Everything below lives in the factory clone (`~/.factory918`); a project carries only the first five, under `docs/factory918/`.
 
 - `MANUAL.md` (this file): how the loop runs and what you do at each point. Read before the first project; return to "Troubleshooting".
 - `PHILOSOPHY.md`: why it is built this way, in twelve ordered beliefs, and how to decide when nothing else answers. Read once whole; read again when a rule fights you.
 - `DECISIONS.md`: every settled choice with its reason, and the provisional ones an agent made. Read before overriding a vendored skill or asking for a change; decisions beat every source.
 - `GLOSSARY.md`: the terms (ticket, spec, map, surface, rung, ledger). Open when a word in `AGENTS.md` or a playbook is unclear.
+- `SCENARIO-TABLE.md`: the design artifact for anything with state (a file, exit codes, rounds, more than one actor), its shape, and why it is a rule. Open when a ticket carries a table under `## Testing decisions` or an agent has to write one.
 - `docs/knowledge/INDEX.md`: the map of the whole corpus, every file with its size and when to read it. `/knowledge <question>` searches it for you without reading files whole; that is the fastest way to learn how any one part works.
 - `docs/knowledge/pages/`: the research behind the four sources (what Matt, Theo, pstack and Ras Mic each do), the deterministic layer explained from zero, and the evidence on planning with agents. Read for background, a section at a time.
 - `docs/FACTORY-SPEC-v2.md` and `docs/M0-findings.md`: the design and what was actually verified against real tools. Only if you are changing the factory itself.
diff --git a/docs/knowledge/core/SCENARIO-TABLE.md b/docs/knowledge/core/SCENARIO-TABLE.md
index 2b98d52..ca1afed 100644
--- a/docs/knowledge/core/SCENARIO-TABLE.md
+++ b/docs/knowledge/core/SCENARIO-TABLE.md
@@ -40,9 +40,9 @@ Two rules cover the inputs the tool is not for. A cell for an input outside the
 
 ## Where it goes
 
-On the ticket, before implementation. The Ticket playbook's step 6 appends the synthesized table to the ticket body under `## Testing decisions` with `gh issue edit N --body-file`. Its first line is `Posted by the agent <date>`, or `Approved by <name> <date>` when the human approved it first. Posting is the record. The human edits the ticket if the table is wrong, and a stop before implementation is asked for only with `/architect with checkpoint`.
+On the ticket, before implementation. The Ticket playbook's step 6 reads the current body into a file, adds the table at the end under `## Testing decisions`, and writes the whole file back with `gh issue edit N --body-file`, because that command replaces the body and never merges. The section's first line is `Posted by the agent <date>`, or `Approved by <name> <date>` when the human approved it first. If the write fails, the agent stops and reports the error, and implementation does not start. Posting is the record. The human edits the ticket if the table is wrong, and a stop before implementation is asked for only with `/architect with checkpoint`.
 
-Code with no state that crosses a function boundary gets the other artifact `architect` already produces, the usage and signature sketch (the caller's usage first, then types and signatures), under `## Design` by the same rule. A prose change has its acceptance criteria and nothing else.
+Code with no state that crosses a function boundary gets the other artifact `architect` already produces, the usage and signature sketch (the caller's usage first, then types and signatures), under `## Design` by the same rule. The step-1 overlap check skips both sections, so a path a cell quotes does not count as a path the ticket names. A prose change has its acceptance criteria and nothing else.
 
 The reviewer reads the table without any extra step, because `review-brief.sh` pastes the whole ticket body into the Spec brief. Whatever is under `## Testing decisions` is spec from then on. The writer gets the table in its brief and writes the test from it before the implementation, one assertion per cell in the table's order, so the commit order shows the test came first. A writer that cannot implement a cell as written stops and reports the cell, and never fills it in.
 
diff --git a/patches/mattpocock/to-spec/SKILL.md.patch b/patches/mattpocock/to-spec/SKILL.md.patch
index 31281f1..6f5d85c 100644
--- a/patches/mattpocock/to-spec/SKILL.md.patch
+++ b/patches/mattpocock/to-spec/SKILL.md.patch
@@ -4,7 +4,7 @@
  - A description of what makes a good test (only test external behavior, not implementation details)
  - Which modules will be tested
  - Prior art for the tests (i.e. similar types of tests in the codebase)
-+- For stateful work (a file read or written, exit codes, more than one actor), the shape is the scenario table: situations down the side, the shape of the input across the top, and in every cell what is printed, the exit code and what the caller does next. The table is the test list, one assertion per cell. It is a decision, not a code snippet, so the rule above does not exclude it.
++- For stateful work (a file read or written, exit codes, more than one actor), the shape is the scenario table: situations down the side, the shape of the input across the top, and in every cell what is printed, the exit code and what the caller does next. The table is the test list, one assertion per cell. It is a decision, so the rule above about paths and snippets does not exclude it.
  
  ## Out of Scope
  
diff --git a/patches/pstack/architect/SKILL.md.patch b/patches/pstack/architect/SKILL.md.patch
new file mode 100644
index 0000000..f1df364
--- /dev/null
+++ b/patches/pstack/architect/SKILL.md.patch
@@ -0,0 +1,11 @@
+--- a/architect/SKILL.md
++++ b/architect/SKILL.md
+@@ -29,7 +29,7 @@
+ 
+ ## Phase B: Sketch
+ 
+-Run the **arena** skill with the design-sketch task and the Phase A grounding artifacts. Pass `references/runner-prompt.md` as each runner's prompt. Each candidate produces a design package shaped per `references/rationale-template.md`: the caller's usage written first, then the type sketch, function signatures, module map, and prose rationale derived from it.
++Run the **arena** skill with the design-sketch task and the Phase A grounding artifacts. Pass `references/runner-prompt.md` as each runner's prompt. Each candidate produces a design package shaped per `references/rationale-template.md`: the caller's usage written first, then the type sketch, function signatures, module map, and prose rationale derived from it. For a design with state the package opens with the scenario table, its contract and its test list, and `references/runner-prompt.md` gives the shape.
+ 
+ Use your configured architect runners (defaults `claude:fable@max`, `codex:gpt-5.6-sol@max`, `grok:grok-4.6@xhigh`, `claude:opus@xhigh`).
+ 
diff --git a/patches/series b/patches/series
index 6f2a29a..9a5bc8f 100644
--- a/patches/series
+++ b/patches/series
@@ -9,6 +9,7 @@ pstack/poteto-mode/playbooks/bug-fix.md.patch
 pstack/poteto-mode/playbooks/feature.md.patch
 pstack/poteto-mode/playbooks/perf-issue.md.patch
 pstack/poteto-mode/playbooks/refactoring.md.patch
+pstack/architect/SKILL.md.patch
 pstack/architect/references/runner-prompt.md.patch
 pstack/poteto-mode/references/codex-tools.md.patch
 pstack/poteto-mode/scripts/runner/model-matrix.test.ts.patch
diff --git a/template/.agents/skills/architect/SKILL.md b/template/.agents/skills/architect/SKILL.md
index e8ac3d1..1fc083b 100644
--- a/template/.agents/skills/architect/SKILL.md
+++ b/template/.agents/skills/architect/SKILL.md
@@ -29,7 +29,7 @@ Skip Phase A only when the work is genuinely greenfield with no surrounding syst
 
 ## Phase B: Sketch
 
-Run the **arena** skill with the design-sketch task and the Phase A grounding artifacts. Pass `references/runner-prompt.md` as each runner's prompt. Each candidate produces a design package shaped per `references/rationale-template.md`: the caller's usage written first, then the type sketch, function signatures, module map, and prose rationale derived from it.
+Run the **arena** skill with the design-sketch task and the Phase A grounding artifacts. Pass `references/runner-prompt.md` as each runner's prompt. Each candidate produces a design package shaped per `references/rationale-template.md`: the caller's usage written first, then the type sketch, function signatures, module map, and prose rationale derived from it. For a design with state the package opens with the scenario table, its contract and its test list, and `references/runner-prompt.md` gives the shape.
 
 Use your configured architect runners (defaults `claude:fable@max`, `codex:gpt-5.6-sol@max`, `grok:grok-4.6@xhigh`, `claude:opus@xhigh`).
 
diff --git a/template/.agents/skills/poteto-mode/playbooks/ticket.md b/template/.agents/skills/poteto-mode/playbooks/ticket.md
index 9ba35a8..c70a8ea 100644
--- a/template/.agents/skills/poteto-mode/playbooks/ticket.md
+++ b/template/.agents/skills/poteto-mode/playbooks/ticket.md
@@ -7,7 +7,7 @@
 3. Check **Blocked by**. Every listed issue must be closed. If one is open, stop and report which; do not start.
 4. Falsifiability pass. For each criterion name the command or observation that would fail it right now. A criterion that already passes at HEAD, that another ticket owns, or that only restates the request goes back to the human as a note before work starts. A ticket whose criteria span more than one concern goes back to the human to be split before work starts, because one ticket is one PR. Criteria the human confirms become the verification plan.
 5. Select by content and run that playbook's steps verbatim from step 1: new behavior → Feature; a defect → Bug fix; a behavior-preserving change → Refactoring; measured slowness → Perf issue. `how` and `why` over the affected subsystem come first in all of them. A change whose diff will touch a cross-cutting path, one under a `.claude/hooks/` directory, a `.claude/settings.json`, or a file of the `factory918` skill (`.agents/skills/factory918/`), at any depth (`spec-review`'s `review-brief.sh` holds the predicate), reaches every session and skill at once: after `how`, run `blast-radius` over it and write the result to `.scratch/<ticket>/blast-radius.md` in that skill's hand-back shape (what it does; the one fact it is safe because of and how far it was proven; risks; cleared; before you merge), with a risk for every session kind (the interactive session, a subagent, a hook's own invocation, `factory-start` at day zero, a review in progress) and every skill the change reaches, each with a `file:line`. Such a change never skips `architect`. The PR body's `## Blast Radius` section is that file verbatim, and `review-brief.sh` refuses to brief the diff without it.
-6. The spec's **Testing decisions** are the pre-agreed seams. `tdd` there, and nowhere the spec did not agree unless a criterion needs it. The selected playbook's architect step adds the ticket's own: when the design adds state (a file it reads or writes, exit codes, rounds, or more than one actor), `architect`'s first deliverable is the scenario table (its runner prompt gives the shape), and before implementation the synthesized table is appended to the ticket's body under `## Testing decisions` with `gh issue edit N --body-file`, first line `Posted by the agent <date>`, or `Approved by <name> <date>` when the human approved it first. When the design is code with no state that crosses a function boundary, the usage and signature sketch goes under `## Design` the same way. A prose change has no artifact beyond its criteria. Posting is the record: the human edits the ticket if the table is wrong, and a stop before implementation is asked for only with `/architect with checkpoint`. The Spec brief carries the table because `review-brief.sh` pastes the ticket body.
+6. The spec's **Testing decisions** are the pre-agreed seams. `tdd` there, and nowhere the spec did not agree unless a criterion needs it. The selected playbook's architect step adds the ticket's own: when the design adds state (a file it reads or writes, exit codes, rounds, or more than one actor), `architect`'s first deliverable is the scenario table (its runner prompt gives the shape), and before implementation the synthesized table goes on the ticket under `## Testing decisions`: read the current body into a file (`gh issue view N --json body -q .body`), add the section at the end with its first line `Posted by the agent <date>` (or `Approved by <name> <date>` when the human approved it first), and write the whole file back with `gh issue edit N --body-file`, since that command replaces the body and never merges. If the write fails, stop and report the error; implementation does not start without the artifact on the ticket. When the design is code with no state that crosses a function boundary, the usage and signature sketch goes under `## Design` the same way. The step-1 check skips both sections, so a path a cell quotes does not count as a path the ticket names. A prose change has no artifact beyond its criteria. Posting is the record: the human edits the ticket if the table is wrong, and a stop before implementation is asked for only with `/architect with checkpoint`. The Spec brief carries the table because `review-brief.sh` pastes the ticket body.
 7. Verify on the matching surface per `docs/agents/evidence.md`; the primary agent runs the project's `verify-<app>` skill once after integrating.
 8. Run `.claude/skills/poteto-mode/scripts/overlap.sh N --diff`; its output, when there is any, is the PR body's `## Overlap` section verbatim, placed before `## Verification`; exit 1 means the reply names the printed PR as the one to merge first. Exit 2: stop and report stderr; do not open the PR until the check runs. Then run **Opening a PR**. The body's Verification section quotes each criterion with its evidence path. The last line before the attribution is `Closes #N`. Never close the issue by hand; the merge closes it.
 9. Babysit to merge-ready per `playbooks/babysit.md`. Never merge.
diff --git a/template/.agents/skills/poteto-mode/scripts/overlap.sh b/template/.agents/skills/poteto-mode/scripts/overlap.sh
index 2ff658b..8d6d45d 100755
--- a/template/.agents/skills/poteto-mode/scripts/overlap.sh
+++ b/template/.agents/skills/poteto-mode/scripts/overlap.sh
@@ -2,12 +2,12 @@
 # Ticket step 1 and step 8. `overlap.sh N` prints `go: <label or none>` (the newest line of
 # .claude/state/program naming #N), then `#<pr> <head>: <paths>` for every open PR whose own
 # commits (its diff from the nearest open-PR head under it, else origin/main) touch a path the
-# ticket's body names in backticks (tokens without whitespace, those under `## Diff` skipped,
-# passed together as pathspecs), ascending by PR number, then on exit 0 the ref to branch from:
-# origin/main when nothing is shared, else the printed head that contains every other, else the
-# lowest PR number's. `overlap.sh N --diff` compares the branch's own paths by the same rule (the
-# own PR skipped, literal pathspecs), prints nothing when none is shared, the go and the PR lines
-# otherwise, and no base. `overlap.sh go
+# ticket's body names in backticks (tokens without whitespace, those under `## Diff`, `## Testing
+# decisions` and `## Design` skipped, passed together as pathspecs), ascending by PR number, then
+# on exit 0 the ref to branch from: origin/main when nothing is shared, else the printed head that
+# contains every other, else the lowest PR number's. `overlap.sh N --diff` compares the branch's
+# own paths by the same rule (the own PR skipped, literal pathspecs), prints nothing when none is
+# shared, the go and the PR lines otherwise, and no base. `overlap.sh go
 # "<label>" N...` appends `<label>: #a #b ...` to the program file, its only writer; a linked
 # worktree reads the main checkout's. Exit 0 decided, 1 a path shared with a PR no go covers (a go
 # covers when some line names #N and some line names the ticket each printed PR closes; a PR that
@@ -45,7 +45,7 @@ fi
 
 if [ -z "$diff" ]; then
   body="$(gh issue view "$n" --json body -q .body)"
-  outside="$(printf '%s\n' "$body" | awk '/^## /{skip=($0 ~ /^## Diff[[:space:]]*$/)} !skip')"
+  outside="$(printf '%s\n' "$body" | awk '/^## /{skip=($0 ~ /^## (Diff|Testing decisions|Design)[[:space:]]*$/)} !skip')"
   # shellcheck disable=SC2016
   paths="$(printf '%s\n' "$outside" | grep -oE '`[^`[:space:]]+`' | tr -d '`' | sort -u || true)"
   if [ -z "$paths" ]; then printf '%s\npaths: none\nbase: origin/main\n' "$go"; exit 0; fi
diff --git a/template/.agents/skills/to-spec/SKILL.md b/template/.agents/skills/to-spec/SKILL.md
index cb511f5..f3bed44 100644
--- a/template/.agents/skills/to-spec/SKILL.md
+++ b/template/.agents/skills/to-spec/SKILL.md
@@ -63,7 +63,7 @@ A list of testing decisions that were made. Include:
 - A description of what makes a good test (only test external behavior, not implementation details)
 - Which modules will be tested
 - Prior art for the tests (i.e. similar types of tests in the codebase)
-- For stateful work (a file read or written, exit codes, more than one actor), the shape is the scenario table: situations down the side, the shape of the input across the top, and in every cell what is printed, the exit code and what the caller does next. The table is the test list, one assertion per cell. It is a decision, not a code snippet, so the rule above does not exclude it.
+- For stateful work (a file read or written, exit codes, more than one actor), the shape is the scenario table: situations down the side, the shape of the input across the top, and in every cell what is printed, the exit code and what the caller does next. The table is the test list, one assertion per cell. It is a decision, so the rule above about paths and snippets does not exclude it.
 
 ## Out of Scope
 
diff --git a/template/docs/factory918/DECISIONS.md b/template/docs/factory918/DECISIONS.md
index 76e2c5c..39cdf3d 100644
--- a/template/docs/factory918/DECISIONS.md
+++ b/template/docs/factory918/DECISIONS.md
@@ -81,5 +81,5 @@ Travels anywhere without change: the planning skills, the execution playbooks, `
 | P23 | The Spec report opens with a walk | `## Walk` is the Spec report's first heading: one numbered line per documented step of the path the change touches (the ticket's criteria and the documentation the diff changes), each saying what the code does at that step. Its lines are numbered 1..K on their own, are not findings and are not judged; `review-comment.sh` leaves them out of the item count, the numbering check and the `[P<n>]` set, so the findings start at 1 under `## Would break` | A finding starts from a documented step, so the reviewer walks the path before looking for what breaks on it; counted as items, a walk of nine steps would push every finding's number and break the judgment's references (#81). 2026-09-21. |
 | P22 | Who signs a comment | A comment the agent posts on a PR or a ticket ends with the model and harness (`Claude Fable 5.1 on Claude Code`), plus `approved by <name>` when the human approved it before posting; only an approved comment posted from the author's account is the author's words. `review-brief.sh` reads only the PR author's account for rounds and carry-forward | Manuel, 2026-09-18: a comment left by the orchestrator without human involvement is signed by the model on the harness; approved, it is signed by both; strangers' comments never reach a brief (#78 round 1). |
 | P2 | Tool versions in CI | Pin every tool CI runs to an exact version, as a devDependency where the tool publishes one | `dlx` and `npx` resolve the latest version, so a rule engine or formatter can change under a project with no diff to show for it. Spec §0 rule 1 already says to pin what you install; this extends it to what CI fetches. First applied to `@ast-grep/cli` 0.45.3 in M0. |
-| P24 | Overlap is not coupling; a go is a line that covers its own tickets | Two unblocked tickets relate three ways: dependent (`Blocked by`, off the frontier), disjoint in files (parallel branches off `main`), or overlapping in files (sequenced: one to merge-ready, the merge, then the next). Coupled work, a ticket that needs code an open PR introduces, stacks, and only on a go. Ticket step 1 runs `.claude/skills/poteto-mode/scripts/overlap.sh N` before branching: every open PR's head is fetched fresh and its own commits (its diff from the open PR it stacks on, else `origin/main`) are matched with the ticket body's backticked tokens as pathspecs (its `## Diff` section excluded), so a file, a directory, a glob or a file the PR creates all match; exit 0 prints `base: <ref>` to branch from, exit 1 stops and names the PR to merge first, exit 2 means the check could not run and stderr says why. A go is a line `<label>: #a #b ...` that `overlap.sh go "<label>" N...` appends to the gitignored `.claude/state/program`, written by the orchestrator when the human gives it (autopilot-stack step 3 runs it itself). A go covers a stack only when a line names the ticket and, for every overlapping PR, the ticket that PR closes; so a line a dead program left behind covers nothing outside its own tickets' open PRs and needs no removal. Under a cover the base is the overlapping PR's head, the lowest-numbered when siblings overlap, the containing one when one contains the other; step 8's `--diff` run records the shared paths as the PR body's `## Overlap` section | Ticket #42, Manuel: "working a ticket to completion before automatically moving on"; the #16 to #22 stack was built on a seven-re-reviews mis-estimate (ledger 2026-09-17). First run (PR #87, closed): three review rounds redesigned the matcher three times; the second run designed from a scenario table Manuel approved 2026-09-21 as the ticket's Testing decisions. Rejected: a ticket label as the go (outlives the program), a line pasted into each lane's brief (a forgotten paste blocks a lane), a `done` step (a crash skips it), the script under the factory918 skill (every later edit cross-cutting). |
+| P24 | Overlap is not coupling; a go is a line that covers its own tickets | Two unblocked tickets relate three ways: dependent (`Blocked by`, off the frontier), disjoint in files (parallel branches off `main`), or overlapping in files (sequenced: one to merge-ready, the merge, then the next). Coupled work, a ticket that needs code an open PR introduces, stacks, and only on a go. Ticket step 1 runs `.claude/skills/poteto-mode/scripts/overlap.sh N` before branching: every open PR's head is fetched fresh and its own commits (its diff from the open PR it stacks on, else `origin/main`) are matched with the ticket body's backticked tokens as pathspecs (its `## Diff`, `## Testing decisions` and `## Design` sections excluded; amended 2026-09-22 by #89 so a posted table's example paths do not count), so a file, a directory, a glob or a file the PR creates all match; exit 0 prints `base: <ref>` to branch from, exit 1 stops and names the PR to merge first, exit 2 means the check could not run and stderr says why. A go is a line `<label>: #a #b ...` that `overlap.sh go "<label>" N...` appends to the gitignored `.claude/state/program`, written by the orchestrator when the human gives it (autopilot-stack step 3 runs it itself). A go covers a stack only when a line names the ticket and, for every overlapping PR, the ticket that PR closes; so a line a dead program left behind covers nothing outside its own tickets' open PRs and needs no removal. Under a cover the base is the overlapping PR's head, the lowest-numbered when siblings overlap, the containing one when one contains the other; step 8's `--diff` run records the shared paths as the PR body's `## Overlap` section | Ticket #42, Manuel: "working a ticket to completion before automatically moving on"; the #16 to #22 stack was built on a seven-re-reviews mis-estimate (ledger 2026-09-17). First run (PR #87, closed): three review rounds redesigned the matcher three times; the second run designed from a scenario table Manuel approved 2026-09-21 as the ticket's Testing decisions. Rejected: a ticket label as the go (outlives the program), a line pasted into each lane's brief (a forgotten paste blocks a lane), a `done` step (a crash skips it), the script under the factory918 skill (every later edit cross-cutting). |
 | P25 | The design artifact on the ticket | For a design with state (a file it reads or writes, exit codes, rounds, or more than one actor) the architect step's first deliverable is a scenario table, appended to the ticket under `## Testing decisions` before implementation, first line `Posted by the agent <date>` (or `Approved by <name> <date>` when the human approved it first); the usage and signature sketch goes under `## Design` for stateless code that crosses a function boundary; prose has its criteria. Posting is the record: the human edits the ticket if the table is wrong, and a stop is asked for only with `/architect with checkpoint`. The table is the test, one assertion per cell; a cell for an input outside the intended path reads "refused with the tool's own message" and is cut only after the refusal was run and seen. Choices made in #89: the rule lives in Ticket step 6 (no renumbering, since "Ticket step 5" is quoted in four patches and `review-brief.sh`); the page is a sixth core document so projects get it; the to-spec patch follows the README path | Ticket #89: the agent's "It is a general design tool, not a #42 thing" and Manuel's "I agree with your choice completely" on posting as the record. PR #87's three rounds redesigned the core three times; PR #92's found 2, 1, 2 items and no cell changed. 2026-09-22. |
diff --git a/template/docs/factory918/MANUAL.md b/template/docs/factory918/MANUAL.md
index 1016979..8f439ce 100644
--- a/template/docs/factory918/MANUAL.md
+++ b/template/docs/factory918/MANUAL.md
@@ -143,12 +143,13 @@ Rough cost order of the skills, highest first: `arena`, autopilot-stack (one own
 
 ## Where to read more
 
-Everything below lives in the factory clone (`~/.factory918`); a project carries only the first four, under `docs/factory918/`.
+Everything below lives in the factory clone (`~/.factory918`); a project carries only the first five, under `docs/factory918/`.
 
 - `MANUAL.md` (this file): how the loop runs and what you do at each point. Read before the first project; return to "Troubleshooting".
 - `PHILOSOPHY.md`: why it is built this way, in twelve ordered beliefs, and how to decide when nothing else answers. Read once whole; read again when a rule fights you.
 - `DECISIONS.md`: every settled choice with its reason, and the provisional ones an agent made. Read before overriding a vendored skill or asking for a change; decisions beat every source.
 - `GLOSSARY.md`: the terms (ticket, spec, map, surface, rung, ledger). Open when a word in `AGENTS.md` or a playbook is unclear.
+- `SCENARIO-TABLE.md`: the design artifact for anything with state (a file, exit codes, rounds, more than one actor), its shape, and why it is a rule. Open when a ticket carries a table under `## Testing decisions` or an agent has to write one.
 - `docs/knowledge/INDEX.md`: the map of the whole corpus, every file with its size and when to read it. `/knowledge <question>` searches it for you without reading files whole; that is the fastest way to learn how any one part works.
 - `docs/knowledge/pages/`: the research behind the four sources (what Matt, Theo, pstack and Ras Mic each do), the deterministic layer explained from zero, and the evidence on planning with agents. Read for background, a section at a time.
 - `docs/FACTORY-SPEC-v2.md` and `docs/M0-findings.md`: the design and what was actually verified against real tools. Only if you are changing the factory itself.
diff --git a/template/docs/factory918/SCENARIO-TABLE.md b/template/docs/factory918/SCENARIO-TABLE.md
index 1fee899..cd6479c 100644
--- a/template/docs/factory918/SCENARIO-TABLE.md
+++ b/template/docs/factory918/SCENARIO-TABLE.md
@@ -31,9 +31,9 @@ Two rules cover the inputs the tool is not for. A cell for an input outside the
 
 ## Where it goes
 
-On the ticket, before implementation. The Ticket playbook's step 6 appends the synthesized table to the ticket body under `## Testing decisions` with `gh issue edit N --body-file`. Its first line is `Posted by the agent <date>`, or `Approved by <name> <date>` when the human approved it first. Posting is the record. The human edits the ticket if the table is wrong, and a stop before implementation is asked for only with `/architect with checkpoint`.
+On the ticket, before implementation. The Ticket playbook's step 6 reads the current body into a file, adds the table at the end under `## Testing decisions`, and writes the whole file back with `gh issue edit N --body-file`, because that command replaces the body and never merges. The section's first line is `Posted by the agent <date>`, or `Approved by <name> <date>` when the human approved it first. If the write fails, the agent stops and reports the error, and implementation does not start. Posting is the record. The human edits the ticket if the table is wrong, and a stop before implementation is asked for only with `/architect with checkpoint`.
 
-Code with no state that crosses a function boundary gets the other artifact `architect` already produces, the usage and signature sketch (the caller's usage first, then types and signatures), under `## Design` by the same rule. A prose change has its acceptance criteria and nothing else.
+Code with no state that crosses a function boundary gets the other artifact `architect` already produces, the usage and signature sketch (the caller's usage first, then types and signatures), under `## Design` by the same rule. The step-1 overlap check skips both sections, so a path a cell quotes does not count as a path the ticket names. A prose change has its acceptance criteria and nothing else.
 
 The reviewer reads the table without any extra step, because `review-brief.sh` pastes the whole ticket body into the Spec brief. Whatever is under `## Testing decisions` is spec from then on. The writer gets the table in its brief and writes the test from it before the implementation, one assertion per cell in the table's order, so the commit order shows the test came first. A writer that cannot implement a cell as written stops and reports the cell, and never fills it in.
 
diff --git a/tests/poteto-mode/overlap.sh b/tests/poteto-mode/overlap.sh
index 196141e..190dab7 100644
--- a/tests/poteto-mode/overlap.sh
+++ b/tests/poteto-mode/overlap.sh
@@ -7,11 +7,12 @@
 # merge base, more open PRs than the list holds, tokens that name no path
 # or lie outside the repository, one PR shared, a deleted and a stale remote ref both fetched, a file
 # a PR creates, a stacked PR reporting only its own commits, a glob and both directory forms,
-# `## Diff` skipped, two PRs in ascending number, gos that cover and gos that do not, the base as the
-# head that contains the others, a one-off go appended under a program's line, a dead program's
-# line, a linked worktree reading the main checkout's file, --diff skipping the own PR and counting
-# only the branch's own commits, a literal token under --diff, and the mode bit. The fixture root
-# has a space, and from the third call on the script runs by the relative path the playbooks name.
+# `## Diff`, `## Testing decisions` and `## Design` skipped, two PRs in ascending number, gos that
+# cover and gos that do not, the base as the head that contains the others, a one-off go appended
+# under a program's line, a dead program's line, a linked worktree reading the main checkout's
+# file, --diff skipping the own PR and counting only the branch's own commits, a literal token
+# under --diff, and the mode bit. The fixture root has a space, and from the third call on the
+# script runs by the relative path the playbooks name.
 # Exits 1 on the first miss. The backticks in the bodies below are the ticket's token delimiters,
 # not command substitutions.
 # shellcheck disable=SC2016
@@ -142,6 +143,18 @@ export FAKE_BODY='## Diff
 
 `README.md`'
 check "17 a token under ## Diff ignored" 0 $'go: none\nbase: origin/main' 9
+export FAKE_BODY='## Testing decisions
+
+Posted by the agent 2026-09-22
+
+| Situation | A |
+|---|---|
+| 1. writes `docs/a.md` | / 0 |
+
+## Design
+
+`src/z.txt`'
+check "17 tokens under ## Testing decisions and ## Design ignored" 0 $'go: none\npaths: none\nbase: origin/main' 9
 export FAKE_BODY='Touches `docs/a.md` and `src/x/y.txt`.'
 # The fake lists PR 2 first; the output is sorted by PR number.
 check "18 two PRs in ascending number" 1 $'go: none\n#1 feat-a: docs/a.md\n#2 feat-b: src/x/y.txt' 9
diff --git a/tools/build_knowledge.py b/tools/build_knowledge.py
index d652c44..e3caaed 100644
--- a/tools/build_knowledge.py
+++ b/tools/build_knowledge.py
@@ -5,7 +5,7 @@ Sources, all inside this repository:
 
   docs/knowledge/core/*.md                 HAND-MAINTAINED. Edit these files directly. This script only
                                            refreshes the header line and the mini-TOC of each one in place,
-                                           then copies PHILOSOPHY, MANUAL, DECISIONS and GLOSSARY (headers
+                                           then copies every core document except CONVERSATION-DIGEST (headers
                                            stripped) into template/docs/factory918/ for projects.
   docs/FACTORY-SPEC-v2.md                  -> docs/knowledge/spec/FACTORY-SPEC-v2/   (chunked by H2)
   research/superseded/FACTORY-SPEC-v1.md   -> docs/knowledge/spec/FACTORY-SPEC-v1/
```

## Standards

### CODING_STANDARDS.md

# Coding standards for the factory itself

Read at review time by `spec-review`'s Standards axis. Skip anything the CI gate (`.github/workflows/factory-ci.yml`) already enforces. The template's `CODING_STANDARDS.md` is for projects; this one is for the bash, Python and markdown this repository is made of.

## Bash (`factory918.sh`, the hooks)

- `set -euo pipefail` at the top; one function per subcommand; the dispatch `case` at the bottom.
- Quote every path. Paths here contain spaces.
- Prefer commands that behave the same on macOS and Linux. Where BSD and GNU differ (`sed -i`, `date -d`, `readlink -f`), either use a form both accept or branch on `command -v`.
- Structured edits to JSON or YAML go through `jq` or a short `python3` heredoc, never `sed`.
- Every doctor check carries its fix as the third argument. A `FAIL` with no fix is a bug.
- A failure a gate depends on is printed before anything continues. `|| true` may stop a failure from aborting the command (the doctor's report at the end of `apply` is one), never hide it.
- Test a command the way a user types it: absolute paths, from another directory, through the installed symlink.
- A `PreToolUse` hook that must let the call through on its own failure runs without `-e`, says so in its header, and exits 2 only on a decided block. `delegation.sh` and `format-on-write.sh` are the two that do.

## Python (`tools/`, heredocs in the CLI)

- Standard library only. One script per job; each exits 1 on any miss and says what missed.

## Markdown (docs, skills, both `AGENTS.md`)

- Written with `/writing-for-agents` when an agent reads it, `/technical-writing` and `/unslop` when a person does. One Diátaxis mode per file, except the vendored copies under `docs/agents/`, which are edited in the template or not at all.
- `docs/knowledge/core/` is the source; everything under `docs/knowledge/spec/`, `pages/`, `notes/` and `template/docs/factory918/` is generated and never edited.
- A count or a version in prose is true at the commit that lands it, with the command that regenerates it nearby.

## Commits and pull requests

The rules are in `AGENTS.md`, "Pull requests"; they are not repeated here. Records: a verified tool fact goes to `docs/M0-findings.md` with its date, a surprise to `docs/agents/ledger.md`, a choice to `docs/knowledge/core/DECISIONS.md` under Provisional.

## Smell baseline

Each smell reads *what it is* -> *how to fix*; match it against the diff. A documented repo standard overrides the baseline; every smell is a judgement call, never a hard violation.

- **Mysterious Name**: a function, variable, or type whose name doesn't reveal what it does or holds. → rename it; if no honest name comes, the design's murky.
- **Duplicated Code**: the same logic shape appears in more than one hunk or file in the change. → extract the shared shape, call it from both.
- **Feature Envy**: a method that reaches into another object's data more than its own. → move the method onto the data it envies.
- **Data Clumps**: the same few fields or params keep travelling together (a type wanting to be born). → bundle them into one type, pass that.
- **Primitive Obsession**: a primitive or string standing in for a domain concept that deserves its own type. → give the concept its own small type.
- **Repeated Switches**: the same `switch`/`if`-cascade on the same type recurs across the change. → replace with polymorphism, or one map both sites share.
- **Shotgun Surgery**: one logical change forces scattered edits across many files in the diff. → gather what changes together into one module.
- **Divergent Change**: one file or module is edited for several unrelated reasons. → split so each module changes for one reason.
- **Speculative Generality**: abstraction, parameters, or hooks added for needs the spec doesn't have. → delete it; inline back until a real need shows.
- **Message Chains**: long `a.b().c().d()` navigation the caller shouldn't depend on. → hide the walk behind one method on the first object.
- **Middle Man**: a class or function that mostly just delegates onward. → cut it, call the real target direct.
- **Refused Bequest**: a subclass or implementer that ignores or overrides most of what it inherits. → drop the inheritance, use composition.

## Report

A hard finding is one of two things: the documented path gives a wrong or silent result, or an input outside it proceeds silently (fails open). An input outside the documented path that is refused with a message saying how to correct it is not a finding; it is the design. Zero items is the expected result for a clean change.

- Manuel: "there are an infinite amount of unhappy paths and only 1 happy one"
- Manuel: "AT MOST hardening to fail fast and loud if we move outside of that"
- Manuel: "we notice the variable is unexpected and flag that without having to diagnose every reason the variable might be wrong for the user"
- Manuel: "An edge case outside the intended path being unsupported is not a flag."
- Manuel: "Primary focus must be the happy path, then unhappy paths that error in a way the user can correct."

Write the report as Markdown with exactly these `## ` headings, in this order, each holding numbered items or nothing:

- `## Would break`: a breach of a documented standard that makes the documented path give a wrong or silent result. Cite the standard (file + the rule) and quote the hunk.
- `## Fails open`: a breach of a documented standard that lets an input outside the documented path proceed silently. Cite the standard (file + the rule) and quote the hunk.
- `## Standards breaches`: documented-standard breaches that do not change behavior. Cite the standard and quote the hunk.
- `## Fix alongside`: baseline smells and other judgement calls. Name the smell and quote the hunk. They are fixed only when a would-break fix already touches that code; they never count.

Each item opens with a line of the form `1. **Title.** body`, with the quoted hunk in a fenced block under it; number the items continuously across the headings, so the judgment can name your third item as [S3]. A documented repo standard overrides the baseline. Skip anything tooling enforces. Read nothing beyond this brief unless a finding needs the code around a hunk, and then read that one function or section, not the file. Under 400 words.

Every item under `## Would break` or `## Fails open` carries a line `Documented step:` quoting the ticket line or the `file:line` of the documentation the user follows, and a line `Result:` saying what happens instead; an item without its `Documented step:` line is sent back.

Write your report to `.scratch/review/c83f166/standards-report.md` and reply with only that path.
End the report with exactly one line `hard findings: N`, where N is the number of items under `## Would break` and `## Fails open` and nothing else.
