# Spec review brief

Read nothing beyond this brief unless a finding needs the code around a hunk, and then read that one function or section, not the file. Run nothing.

## Commits

715100c Keep the whole design artifact inside its one ticket section

## Changed files

 docs/agents/issue-tracker.md                           |  2 +-
 docs/knowledge/core/SCENARIO-TABLE.md                  |  4 ++--
 .../.agents/skills/poteto-mode/playbooks/ticket.md     |  2 +-
 template/.agents/skills/poteto-mode/scripts/overlap.sh | 11 ++++++-----
 template/docs/agents/issue-tracker.md                  |  2 +-
 template/docs/factory918/SCENARIO-TABLE.md             |  4 ++--
 tests/poteto-mode/overlap.sh                           | 18 +++++++++++-------
 7 files changed, 24 insertions(+), 19 deletions(-)

## Diff

```diff
diff --git a/docs/agents/issue-tracker.md b/docs/agents/issue-tracker.md
index da048e5..442b903 100644
--- a/docs/agents/issue-tracker.md
+++ b/docs/agents/issue-tracker.md
@@ -23,7 +23,7 @@ Every ticket has this shape, in this order. The Ticket playbook, `spec-review`,
 - **`## Parent`**: the spec issue, for planned tickets. A quick ticket has none.
 - **`## Blocked by`**: issue numbers that must be closed first, or `None`. GitHub's native issue dependencies are the canonical form where available (Wayfinding operations below says how); the line is the fallback.
 
-The architect step may append two more sections before implementation, after these: `## Testing decisions`, the scenario table, when the design has state; `## Design`, the usage and signature sketch, when it is code with no state that crosses a function boundary. Their first line is `Posted by the agent <date>` or `Approved by <name> <date>` (the Ticket playbook, step 6). The human edits them in place; `spec-review` reads them as spec because the body is pasted whole.
+The architect step may append two more sections before implementation, after these: `## Testing decisions`, the scenario table, when the design has state; `## Design`, the usage and signature sketch, when it is code with no state that crosses a function boundary. Their first line is `Posted by the agent <date>` or `Approved by <name> <date>` (the Ticket playbook, step 6). The human edits them in place; `spec-review` reads them as spec because the body is pasted whole. Each section holds the whole artifact, with `###` headings for its parts, since the overlap check skips a section up to the next `## ` heading.
 
 Anything an agent may pick up carries the label `ready-for-agent`.
 
diff --git a/docs/knowledge/core/SCENARIO-TABLE.md b/docs/knowledge/core/SCENARIO-TABLE.md
index ca1afed..24fabea 100644
--- a/docs/knowledge/core/SCENARIO-TABLE.md
+++ b/docs/knowledge/core/SCENARIO-TABLE.md
@@ -42,13 +42,13 @@ Two rules cover the inputs the tool is not for. A cell for an input outside the
 
 On the ticket, before implementation. The Ticket playbook's step 6 reads the current body into a file, adds the table at the end under `## Testing decisions`, and writes the whole file back with `gh issue edit N --body-file`, because that command replaces the body and never merges. The section's first line is `Posted by the agent <date>`, or `Approved by <name> <date>` when the human approved it first. If the write fails, the agent stops and reports the error, and implementation does not start. Posting is the record. The human edits the ticket if the table is wrong, and a stop before implementation is asked for only with `/architect with checkpoint`.
 
-Code with no state that crosses a function boundary gets the other artifact `architect` already produces, the usage and signature sketch (the caller's usage first, then types and signatures), under `## Design` by the same rule. The step-1 overlap check skips both sections, so a path a cell quotes does not count as a path the ticket names. A prose change has its acceptance criteria and nothing else.
+Code with no state that crosses a function boundary gets the other artifact `architect` already produces, the usage and signature sketch (the caller's usage first, then types and signatures), under `## Design` by the same rule. The step-1 overlap check skips both sections, so a path a cell quotes does not count as a path the ticket names. The whole artifact stays inside the one section, its parts (the legend, the table, the contract, the test list) under `###` headings, because the skip ends at the next `## ` heading. A prose change has its acceptance criteria and nothing else.
 
 The reviewer reads the table without any extra step, because `review-brief.sh` pastes the whole ticket body into the Spec brief. Whatever is under `## Testing decisions` is spec from then on. The writer gets the table in its brief and writes the test from it before the implementation, one assertion per cell in the table's order, so the commit order shows the test came first. A writer that cannot implement a cell as written stops and reports the cell, and never fills it in.
 
 ## The #42 example
 
-The durable copy is the `## Testing decisions` section of ticket #42 and the description of PR #92. The legend and the table, verbatim:
+The durable copy is the `## Testing decisions` section of ticket #42 and the description of PR #92. #42's record was written before this rule, so its table and contract sit under their own `## ` headings there. A table posted from now on keeps them under `###` inside the one section. The legend and the table, verbatim:
 
 > Cell = prints / exit / what the agent does. `G` = first line `go: <label>` or `go: none`. `L(k)` = `#k <head>: <paths>`, the named paths k's own commits touch (its diff from `nearest`, the open-PR head under it, else `origin/main`), ascending by PR number. `B(x)` = last line `base: <x>`. Exit 0 always ends with a `base:` line; exit 1 prints `G` and the `L` lines and no base; exit 2 prints the tool's message on stderr and nothing decided. "Covered" = a line of `.claude/state/program` names #N and, for every printed PR, the ticket it closes (`closingIssuesReferences`).
 
diff --git a/template/.agents/skills/poteto-mode/playbooks/ticket.md b/template/.agents/skills/poteto-mode/playbooks/ticket.md
index c70a8ea..7851c40 100644
--- a/template/.agents/skills/poteto-mode/playbooks/ticket.md
+++ b/template/.agents/skills/poteto-mode/playbooks/ticket.md
@@ -7,7 +7,7 @@
 3. Check **Blocked by**. Every listed issue must be closed. If one is open, stop and report which; do not start.
 4. Falsifiability pass. For each criterion name the command or observation that would fail it right now. A criterion that already passes at HEAD, that another ticket owns, or that only restates the request goes back to the human as a note before work starts. A ticket whose criteria span more than one concern goes back to the human to be split before work starts, because one ticket is one PR. Criteria the human confirms become the verification plan.
 5. Select by content and run that playbook's steps verbatim from step 1: new behavior → Feature; a defect → Bug fix; a behavior-preserving change → Refactoring; measured slowness → Perf issue. `how` and `why` over the affected subsystem come first in all of them. A change whose diff will touch a cross-cutting path, one under a `.claude/hooks/` directory, a `.claude/settings.json`, or a file of the `factory918` skill (`.agents/skills/factory918/`), at any depth (`spec-review`'s `review-brief.sh` holds the predicate), reaches every session and skill at once: after `how`, run `blast-radius` over it and write the result to `.scratch/<ticket>/blast-radius.md` in that skill's hand-back shape (what it does; the one fact it is safe because of and how far it was proven; risks; cleared; before you merge), with a risk for every session kind (the interactive session, a subagent, a hook's own invocation, `factory-start` at day zero, a review in progress) and every skill the change reaches, each with a `file:line`. Such a change never skips `architect`. The PR body's `## Blast Radius` section is that file verbatim, and `review-brief.sh` refuses to brief the diff without it.
-6. The spec's **Testing decisions** are the pre-agreed seams. `tdd` there, and nowhere the spec did not agree unless a criterion needs it. The selected playbook's architect step adds the ticket's own: when the design adds state (a file it reads or writes, exit codes, rounds, or more than one actor), `architect`'s first deliverable is the scenario table (its runner prompt gives the shape), and before implementation the synthesized table goes on the ticket under `## Testing decisions`: read the current body into a file (`gh issue view N --json body -q .body`), add the section at the end with its first line `Posted by the agent <date>` (or `Approved by <name> <date>` when the human approved it first), and write the whole file back with `gh issue edit N --body-file`, since that command replaces the body and never merges. If the write fails, stop and report the error; implementation does not start without the artifact on the ticket. When the design is code with no state that crosses a function boundary, the usage and signature sketch goes under `## Design` the same way. The step-1 check skips both sections, so a path a cell quotes does not count as a path the ticket names. A prose change has no artifact beyond its criteria. Posting is the record: the human edits the ticket if the table is wrong, and a stop before implementation is asked for only with `/architect with checkpoint`. The Spec brief carries the table because `review-brief.sh` pastes the ticket body.
+6. The spec's **Testing decisions** are the pre-agreed seams. `tdd` there, and nowhere the spec did not agree unless a criterion needs it. The selected playbook's architect step adds the ticket's own: when the design adds state (a file it reads or writes, exit codes, rounds, or more than one actor), `architect`'s first deliverable is the scenario table (its runner prompt gives the shape), and before implementation the synthesized table goes on the ticket under `## Testing decisions`: read the current body into a file (`gh issue view N --json body -q .body`), add the section at the end with its first line `Posted by the agent <date>` (or `Approved by <name> <date>` when the human approved it first), and write the whole file back with `gh issue edit N --body-file`, since that command replaces the body and never merges. If the write fails, stop and report the error; implementation does not start without the artifact on the ticket. When the design is code with no state that crosses a function boundary, the usage and signature sketch goes under `## Design` the same way. The step-1 check skips both sections, so a path a cell quotes does not count as a path the ticket names. The whole artifact (the legend, the table, the contract and the test list, or the usage and the signatures) stays inside that one section, its parts under `###` headings, because the skip ends at the next `## ` heading. A prose change has no artifact beyond its criteria. Posting is the record: the human edits the ticket if the table is wrong, and a stop before implementation is asked for only with `/architect with checkpoint`. The Spec brief carries the table because `review-brief.sh` pastes the ticket body.
 7. Verify on the matching surface per `docs/agents/evidence.md`; the primary agent runs the project's `verify-<app>` skill once after integrating.
 8. Run `.claude/skills/poteto-mode/scripts/overlap.sh N --diff`; its output, when there is any, is the PR body's `## Overlap` section verbatim, placed before `## Verification`; exit 1 means the reply names the printed PR as the one to merge first. Exit 2: stop and report stderr; do not open the PR until the check runs. Then run **Opening a PR**. The body's Verification section quotes each criterion with its evidence path. The last line before the attribution is `Closes #N`. Never close the issue by hand; the merge closes it.
 9. Babysit to merge-ready per `playbooks/babysit.md`. Never merge.
diff --git a/template/.agents/skills/poteto-mode/scripts/overlap.sh b/template/.agents/skills/poteto-mode/scripts/overlap.sh
index 8d6d45d..41f30d0 100755
--- a/template/.agents/skills/poteto-mode/scripts/overlap.sh
+++ b/template/.agents/skills/poteto-mode/scripts/overlap.sh
@@ -3,11 +3,12 @@
 # .claude/state/program naming #N), then `#<pr> <head>: <paths>` for every open PR whose own
 # commits (its diff from the nearest open-PR head under it, else origin/main) touch a path the
 # ticket's body names in backticks (tokens without whitespace, those under `## Diff`, `## Testing
-# decisions` and `## Design` skipped, passed together as pathspecs), ascending by PR number, then
-# on exit 0 the ref to branch from: origin/main when nothing is shared, else the printed head that
-# contains every other, else the lowest PR number's. `overlap.sh N --diff` compares the branch's
-# own paths by the same rule (the own PR skipped, literal pathspecs), prints nothing when none is
-# shared, the go and the PR lines otherwise, and no base. `overlap.sh go
+# decisions` and `## Design` skipped up to the next `## ` heading, passed together as pathspecs),
+# ascending by PR number, then on exit 0 the ref to branch from: origin/main when nothing is
+# shared, else the printed head that contains every other, else the lowest PR number's.
+# `overlap.sh N --diff` compares the branch's own paths by the same rule (the own PR skipped,
+# literal pathspecs), prints nothing when none is shared, the go and the PR lines otherwise, and
+# no base. `overlap.sh go
 # "<label>" N...` appends `<label>: #a #b ...` to the program file, its only writer; a linked
 # worktree reads the main checkout's. Exit 0 decided, 1 a path shared with a PR no go covers (a go
 # covers when some line names #N and some line names the ticket each printed PR closes; a PR that
diff --git a/template/docs/agents/issue-tracker.md b/template/docs/agents/issue-tracker.md
index da048e5..442b903 100644
--- a/template/docs/agents/issue-tracker.md
+++ b/template/docs/agents/issue-tracker.md
@@ -23,7 +23,7 @@ Every ticket has this shape, in this order. The Ticket playbook, `spec-review`,
 - **`## Parent`**: the spec issue, for planned tickets. A quick ticket has none.
 - **`## Blocked by`**: issue numbers that must be closed first, or `None`. GitHub's native issue dependencies are the canonical form where available (Wayfinding operations below says how); the line is the fallback.
 
-The architect step may append two more sections before implementation, after these: `## Testing decisions`, the scenario table, when the design has state; `## Design`, the usage and signature sketch, when it is code with no state that crosses a function boundary. Their first line is `Posted by the agent <date>` or `Approved by <name> <date>` (the Ticket playbook, step 6). The human edits them in place; `spec-review` reads them as spec because the body is pasted whole.
+The architect step may append two more sections before implementation, after these: `## Testing decisions`, the scenario table, when the design has state; `## Design`, the usage and signature sketch, when it is code with no state that crosses a function boundary. Their first line is `Posted by the agent <date>` or `Approved by <name> <date>` (the Ticket playbook, step 6). The human edits them in place; `spec-review` reads them as spec because the body is pasted whole. Each section holds the whole artifact, with `###` headings for its parts, since the overlap check skips a section up to the next `## ` heading.
 
 Anything an agent may pick up carries the label `ready-for-agent`.
 
diff --git a/template/docs/factory918/SCENARIO-TABLE.md b/template/docs/factory918/SCENARIO-TABLE.md
index cd6479c..8a68484 100644
--- a/template/docs/factory918/SCENARIO-TABLE.md
+++ b/template/docs/factory918/SCENARIO-TABLE.md
@@ -33,13 +33,13 @@ Two rules cover the inputs the tool is not for. A cell for an input outside the
 
 On the ticket, before implementation. The Ticket playbook's step 6 reads the current body into a file, adds the table at the end under `## Testing decisions`, and writes the whole file back with `gh issue edit N --body-file`, because that command replaces the body and never merges. The section's first line is `Posted by the agent <date>`, or `Approved by <name> <date>` when the human approved it first. If the write fails, the agent stops and reports the error, and implementation does not start. Posting is the record. The human edits the ticket if the table is wrong, and a stop before implementation is asked for only with `/architect with checkpoint`.
 
-Code with no state that crosses a function boundary gets the other artifact `architect` already produces, the usage and signature sketch (the caller's usage first, then types and signatures), under `## Design` by the same rule. The step-1 overlap check skips both sections, so a path a cell quotes does not count as a path the ticket names. A prose change has its acceptance criteria and nothing else.
+Code with no state that crosses a function boundary gets the other artifact `architect` already produces, the usage and signature sketch (the caller's usage first, then types and signatures), under `## Design` by the same rule. The step-1 overlap check skips both sections, so a path a cell quotes does not count as a path the ticket names. The whole artifact stays inside the one section, its parts (the legend, the table, the contract, the test list) under `###` headings, because the skip ends at the next `## ` heading. A prose change has its acceptance criteria and nothing else.
 
 The reviewer reads the table without any extra step, because `review-brief.sh` pastes the whole ticket body into the Spec brief. Whatever is under `## Testing decisions` is spec from then on. The writer gets the table in its brief and writes the test from it before the implementation, one assertion per cell in the table's order, so the commit order shows the test came first. A writer that cannot implement a cell as written stops and reports the cell, and never fills it in.
 
 ## The #42 example
 
-The durable copy is the `## Testing decisions` section of ticket #42 and the description of PR #92. The legend and the table, verbatim:
+The durable copy is the `## Testing decisions` section of ticket #42 and the description of PR #92. #42's record was written before this rule, so its table and contract sit under their own `## ` headings there. A table posted from now on keeps them under `###` inside the one section. The legend and the table, verbatim:
 
 > Cell = prints / exit / what the agent does. `G` = first line `go: <label>` or `go: none`. `L(k)` = `#k <head>: <paths>`, the named paths k's own commits touch (its diff from `nearest`, the open-PR head under it, else `origin/main`), ascending by PR number. `B(x)` = last line `base: <x>`. Exit 0 always ends with a `base:` line; exit 1 prints `G` and the `L` lines and no base; exit 2 prints the tool's message on stderr and nothing decided. "Covered" = a line of `.claude/state/program` names #N and, for every printed PR, the ticket it closes (`closingIssuesReferences`).
 
diff --git a/tests/poteto-mode/overlap.sh b/tests/poteto-mode/overlap.sh
index 190dab7..51a4131 100644
--- a/tests/poteto-mode/overlap.sh
+++ b/tests/poteto-mode/overlap.sh
@@ -7,12 +7,12 @@
 # merge base, more open PRs than the list holds, tokens that name no path
 # or lie outside the repository, one PR shared, a deleted and a stale remote ref both fetched, a file
 # a PR creates, a stacked PR reporting only its own commits, a glob and both directory forms,
-# `## Diff`, `## Testing decisions` and `## Design` skipped, two PRs in ascending number, gos that
-# cover and gos that do not, the base as the head that contains the others, a one-off go appended
-# under a program's line, a dead program's line, a linked worktree reading the main checkout's
-# file, --diff skipping the own PR and counting only the branch's own commits, a literal token
-# under --diff, and the mode bit. The fixture root has a space, and from the third call on the
-# script runs by the relative path the playbooks name.
+# `## Diff`, `## Testing decisions` (with its `###` parts) and `## Design` skipped, two PRs in
+# ascending number, gos that cover and gos that do not, the base as the head that contains the
+# others, a one-off go appended under a program's line, a dead program's line, a linked worktree
+# reading the main checkout's file, --diff skipping the own PR and counting only the branch's own
+# commits, a literal token under --diff, and the mode bit. The fixture root has a space, and from
+# the third call on the script runs by the relative path the playbooks name.
 # Exits 1 on the first miss. The backticks in the bodies below are the ticket's token delimiters,
 # not command substitutions.
 # shellcheck disable=SC2016
@@ -151,10 +151,14 @@ Posted by the agent 2026-09-22
 |---|---|
 | 1. writes `docs/a.md` | / 0 |
 
+### Contract
+
+Reads `src/x/y.txt` once.
+
 ## Design
 
 `src/z.txt`'
-check "17 tokens under ## Testing decisions and ## Design ignored" 0 $'go: none\npaths: none\nbase: origin/main' 9
+check "17 tokens under ## Testing decisions (with ### parts) and ## Design ignored" 0 $'go: none\npaths: none\nbase: origin/main' 9
 export FAKE_BODY='Touches `docs/a.md` and `src/x/y.txt`.'
 # The fake lists PR 2 first; the output is sorted by PR number.
 check "18 two PRs in ascending number" 1 $'go: none\n#1 feat-a: docs/a.md\n#2 feat-b: src/x/y.txt' 9
```

## The ticket (#89)

## Problem

Observed (agent): the first design for #42 (PR #87) settled a script, a state file and two exit-code decisions in prose sketches. Nobody wrote out the situations with an expected outcome per cell, so the reviewers found the empty cells one round at a time (2, 4, 4 hard findings) and each fix round redesigned the core. The second run (PR #92) wrote the table first: the writer found the one design hole at the test, before any review, and the three rounds found 2, 1, 2 items, none of which changed a cell. The ticket had no Testing decisions because it was planned as prose, and nothing sent it back for them when the design added state.

## Decision

> user: Then there is your stateful helper with a scenario table. To be completely honest, In dont understand what this is. Is it a solution specific to issue 42, or is it a more fundamental design tool that is meant to help you design or review better?

> agent: It is a general design tool, not a #42 thing. For anything with state, a file, exit codes, or several actors, you write the inputs and states across the top and down the side, and every cell says what must happen. Before code. The table is then the test, row by row.

> user: if you are TRULY saying the only primary issue was that reviewers were making design decisions independently of one another and therefore infinitely expanding the surface area that could break, then THAT is what we need to prove by going back and getting it designed properly and then seeing if it has a better fare in the review process.

> user: (on whether the table stops for the human before implementation, or is posted on the ticket as the record with the human editing after) I agree with your choice completely. (the agent's choice: posting is the record; a stop is opt-in)

> user: (on whether a finding that changes an acceptance criterion also returns to architect) The criterion were designed by an AI to begin with. So long as the architect and the orchestrator knows that the intent of the ticket is more important than any one criterion, I dont see why that shouldnt kick back too.

> user: (on cells for inputs outside the intended path) An edge case outside the intended path being unsupported is not a flag. AT MOST hardening to fail fast and loud if we move outside of that. (quoted from #81; applied to the table's cells 2026-09-21)

## The artifacts

Three, and every ticket has at least one. For anything with state, the scenario table below. For code with no state that crosses a function boundary, the usage and signature sketch architect already produces (the caller's usage first, then types and signatures), posted on the ticket under `## Design`. For prose and everything else, the acceptance criteria, which are already on the ticket. A review finding is judged against whichever of these the work was built against (#90).

### The table's shape

Situations down the side (the states the world can be in: no go, a covering go, a stale ref, a failing tool, a body with no token), the shape of the input across the top (no overlap, one, siblings, one containing the other, the caller's own), and in every cell what is printed, the exit code and what the caller does next. A legend defines the cell's vocabulary once. The contract that follows the table defines every term the cells use (what counts as in flight, a named path, a covering go). The test list has one assertion per cell, in the order they are written, each naming the fixture state it needs. The durable example is the `## Testing decisions` section of #42 and PR #92's description; `.scratch/` files from that run are gone.

## Acceptance criteria

- [ ] `architect`'s runner prompt (through its patch) makes the first deliverable, for any design with a file it reads or writes, exit codes, or more than one actor, the scenario table in the shape above, then the contract derived from it, then the test list; for code with no state that crosses a function boundary, the usage and signature sketch it already asks for, posted on the ticket under `## Design` by the same rule as the table.
- [ ] The runner prompt says: a cell for an input outside the intended path reads "refused with the tool's own message" and costs no code, and such a cell is cut only after the refusal was run and seen (ledger 2026-09-21: a cell cut on the assumption that git fails loudly came back as a finding).
- [ ] The Ticket playbook's architect step says that when a design adds state, the table is appended to the ticket's body under `## Testing decisions`, first line "Posted by the agent <date>" or "Approved by <name> <date>", before implementation; the human edits it if it is wrong; a stop before implementation is asked for only with "/architect with checkpoint". The Spec brief carries it because `review-brief.sh` pastes the ticket body, and the playbook says so.
- [ ] The Feature, Bug fix, Refactoring and Perf issue playbooks' delegation instruction (through their patches) says the test is written from the table before the implementation, one assertion per cell, and that a writer who cannot implement a cell as written stops and reports the cell; it never fills it.
- [ ] `to-spec`'s Testing decisions section (through its patch or the factory's copy) names the table as the shape for stateful work.
- [ ] The knowledge base has one page on the table (what it is, the shape, the #42 example), reachable through `/knowledge scenario table`.

## Run under

Until #89, #90, #91 and #93 merge, the lane that runs this ticket follows their rules by hand; following them is part of the ticket. The worked example of every artifact named here is ticket #42 (its `## Testing decisions` section) and PR #92 (its description and its three review comments); read both first. The rules: (1) `how` and `blast-radius` as the Ticket playbook says. (2) When the change has state (a file it reads or writes, exit codes, rounds, or more than one actor) the architect step writes a scenario table before any code: situations down the side, the shape of the input across the top, and in every cell what is printed, the exit code and what the caller does; a cell for an input outside the intended path reads "refused with the tool's own message" and costs no code, and such a cell is cut only after the refusal was run and seen. When the change is code with no state that crosses a function boundary, the architect step posts the usage and signature sketch (the caller's usage first, then types and signatures) on the ticket under `## Design` instead; a prose change has no artifact beyond its acceptance criteria. The table is appended to this ticket's body under `## Testing decisions`, first line "Posted by the agent <date>"; the human edits it if it is wrong, and a stop before implementation is asked for only with the phrase "/architect with checkpoint". (3) The test is written from the table before the implementation, one assertion per cell, and the commit order shows it. (4) A writer that cannot implement a cell as written stops and reports the cell; it never fills it. (5) In review, a finding is a design hole when its fix changes the artifact the work was built against rather than the code that implements it: a table cell or a term its cells use, a signature or a usage in the sketch, or an acceptance criterion (the ticket's intent, its What to build or Decision quotes, outranks any one criterion, so a criterion that must change goes back to architect, which re-derives it from the intent and amends the ticket with a dated line); a design hole is not fixed on the PR but returns to architect, scoped to that cell, and the review count restarts (on this PR with a comment that says "restart" and why); a refusal added under an existing could-not-run clause is not a hole. (6) The Spec reviewer's walk has one line per risk in the blast-radius grounding. (7) A round that fixed a Would-break item is followed by another round even past three, reviewing only the fix (the previous reviewed commit as the fixed point), up to five; at five with Would-break items still found, stop, write a report for the human, mark the PR unfinished and wait. (8) `shellcheck` on every changed shell file before the PR opens. This ticket changes prose and patches only, so rule 2 yields no table; rules 6 to 8 apply to its review.

## Blocked by

- #42

## Report

A hard finding is one of two things: the documented path gives a wrong or silent result, or an input outside it proceeds silently (fails open). An input outside the documented path that is refused with a message saying how to correct it is not a finding; it is the design. Zero items is the expected result for a clean change.

- Manuel: "there are an infinite amount of unhappy paths and only 1 happy one"
- Manuel: "AT MOST hardening to fail fast and loud if we move outside of that"
- Manuel: "we notice the variable is unexpected and flag that without having to diagnose every reason the variable might be wrong for the user"
- Manuel: "An edge case outside the intended path being unsupported is not a flag."
- Manuel: "Primary focus must be the happy path, then unhappy paths that error in a way the user can correct."

Write the report as Markdown with exactly these `## ` headings, in this order, each holding numbered items or nothing:

- `## Walk`: one numbered line per documented step of the path the change touches (the ticket's criteria and the documentation the diff changes), each saying what the code does at that step. A walk, not findings: its lines are numbered 1..K on their own and count nothing.
- `## Would break`: a requirement missing, partial, or implemented so that the documented path gives a wrong or silent result.
- `## Fails open`: an input outside the documented path that proceeds silently instead of being refused with a message saying how to correct it.
- `## Not asked for`: behaviour in the diff the ticket did not ask for.

Each item opens with a line of the form `1. **Title.** body` and quotes the spec line it rests on in a fenced block (a criterion can carry `## ` or `1. ` lines, and only fenced text is exempt from the report shape); number the items continuously across the headings from `## Would break` on, so the judgment can name your third item as [P3]. Read nothing beyond this brief unless a finding needs the code around a hunk, and then read that one function or section, not the file. Under 400 words.

Every item under `## Would break` or `## Fails open` carries a line `Documented step:` quoting the ticket line or the `file:line` of the documentation the user follows, and a line `Result:` saying what happens instead; an item without its `Documented step:` line is sent back.

Write your report to `.scratch/review/78be65e/spec-report.md` and reply with only that path.
End the report with exactly one line `hard findings: N`, where N is the number of items under `## Would break` and `## Fails open` and nothing else.
