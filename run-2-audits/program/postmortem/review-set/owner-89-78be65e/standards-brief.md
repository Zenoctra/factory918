# Standards review brief

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

Write your report to `.scratch/review/78be65e/standards-report.md` and reply with only that path.
End the report with exactly one line `hard findings: N`, where N is the number of items under `## Would break` and `## Fails open` and nothing else.
