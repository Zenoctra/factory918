Below are several outputs of the same piece of delegated work, each under an id. They were produced by separate runs; you are not told which run produced which, and the order is random.

For each output and each numbered item in the KEY, say whether the output contains it: "yes" if it states it plainly, "partly" if it touches it without the substance, "no" if absent. Paraphrase counts; the item has to be the same issue, not a neighbour of it.

KEY
1. The posting step names `gh issue edit N --body-file`, which replaces the ticket body rather than appending to it; an agent following the step as written wipes What to build and the acceptance criteria. (The original's hard finding; round 1's Act-on item S1.)
2. The posted table carries example paths in backticks, and the overlap check (`overlap.sh`) reads every backticked token in a ticket body as a path, so later tickets would show phantom overlaps. (The original's item 5, a Fix-alongside; the Spec reviewer's hard finding P1.)
3. Documents still count four core or project documents after the scenario table became an added core document, so a stated count is false at the commit. (Found by the Spec reviewer, P3, not by the original.)
4. A failed post of the table has no stop clause: nothing says to stop the work when `gh issue edit` fails. (Found by the Spec reviewer, P4, not by the original.)

For each output, also list in "other_findings" any substantive finding or decision it contains that the items above do not cover, one short line each (empty if none).

Judge only from what each output says. Quote or point at the place in the output that supports each answer.

===== OUTPUT R01 =====
## Final message

{BOX}/factory918/.claude/worktrees/owner-89/.scratch/review/ab47eb9/standards-report.md

## File written: {BOX}/factory918/.claude/worktrees/owner-89/.scratch/review/ab47eb9/standards-report.md

```
# Standards report

## Would break

1. **`gh issue edit --body-file` replaces the body; nothing says to write the old body back.** The new rule is the system's first body-rewriting operation, and neither Ticket step 6, `SCENARIO-TABLE.md` "Where it goes", nor `docs/agents/issue-tracker.md` (which documents create, comment, label and assignee, but no body edit) says to fetch the body first and write body-plus-section to the file. An agent that types the named command with only the synthesized table in the file drops What to build, Acceptance criteria, Parent and Blocked by. `review-brief.sh:222` then pastes the truncated body as the spec, so the Spec axis reviews a ticket with no criteria and says nothing. Standard: `CODING_STANDARDS.md`, Bash — "Test a command the way a user types it"; and the ledger's own 2026-09-21 line, "a path an agent will type is tested the way it is typed".

Documented step: `template/.agents/skills/poteto-mode/playbooks/ticket.md:10` — "before implementation the synthesized table is appended to the ticket's body under `## Testing decisions` with `gh issue edit N --body-file`".

Result: the ticket body becomes the table alone; the spec sections are lost silently and the next Spec review has no criteria to check.

```
6. ... and before implementation the synthesized table is appended to the ticket's body under `## Testing decisions` with `gh issue edit N --body-file`, first line `Posted by the agent <date>`, ...
```

## Fails open

## Standards breaches

2. **The to-spec exemption covers half the rule it points at.** The rule above is "Do NOT include specific file paths or code snippets". The new bullet exempts only the snippet half, while the table it mandates names paths in every worked example (`.claude/state/program`, `tests/poteto-mode/overlap.sh`). An agent gets two instructions that disagree. Standard: `CODING_STANDARDS.md`, Markdown — written with `/writing-for-agents` when an agent reads it.

```
- For stateful work ... It is a decision, not a code snippet, so the rule above does not exclude it.
```

3. **`SOURCES.md` line 3 is left saying what this commit records as false.** The same commit adds `docs/M0-findings.md` "factory918.sh sync (0.3.0) bumps no VERSION and touches no network, against what SOURCES.md line 3 says", and edits `SOURCES.md` below that line without correcting it. Standard: `CODING_STANDARDS.md`, Markdown — "A count or a version in prose is true at the commit that lands it".

```
`factory918 sync` will re-fetch these pins, re-apply the patches, and bump VERSION.
```

## Fix alongside

4. **Duplicated Code / Shotgun Surgery.** The same 45-word writer sentence is pasted verbatim into four playbooks and their four patches, and the same rule is restated in Ticket step 6, `issue-tracker.md`, the runner prompt, P25, the glossary and `SCENARIO-TABLE.md`. The next wording change is an eight-file edit.

```
The brief carries the ticket's design artifact (Ticket step 6). When it is a scenario table, the writer writes the test from the table before the implementation, one assertion per cell in the table's order, ...
```

5. **The posted table feeds tokens back into `overlap.sh`.** Step 6 appends backticked tokens to the ticket body; a later step-1 check reads every backticked token outside `## Diff` as a pathspec, so a table cell quoting an unrelated path can print an overlap and stop the run.

hard findings: 1
```


===== OUTPUT R02 =====
## Final message

{BOX}/factory918/.scratch/review/ab47eb9/standards-report.md

## File written: factory918/.scratch/review/ab47eb9/standards-report.md

```
# Standards report

Two hard findings, both in the new "post the design artifact on the ticket" rule: the command it names replaces the ticket body instead of appending to it, and the text it posts is the same text `overlap.sh` parses as pathspecs. The rest are stale enumerations the change left behind.

## Would break

1. **`gh issue edit N --body-file` replaces the body; nothing says to read it first.** The step is written as an append, but the named command sets the body whole. An agent that writes the table to a file and runs the command as typed loses `## What to build`, `## Acceptance criteria`, `## Parent` and `## Blocked by`; `gh` exits 0 and prints the issue URL, and `review-brief.sh` then briefs the Spec axis with a body that is only the table. Standard: `CODING_STANDARDS.md`, Bash, "Test a command the way a user types it"; `docs/agents/ledger.md` 2026-09-21, "a path an agent will type is tested the way it is typed".

```
6. ... before implementation the synthesized table is appended to the ticket's body under `## Testing decisions` with `gh issue edit N --body-file`, first line `Posted by the agent <date>` ...
```

Documented step: `template/.agents/skills/poteto-mode/playbooks/ticket.md:6` (also `docs/knowledge/core/SCENARIO-TABLE.md:43`, `docs/agents/issue-tracker.md:26`).
Result: the ticket body is overwritten by the table alone, silently; the spec the reviewer and the writer read is gone and only the human notices.

2. **The posted table's backticked tokens become `overlap.sh` pathspecs.** The check at Ticket step 1 takes every backticked whitespace-free token in the ticket body as a pathspec and skips only a `## Diff` section. The new rule writes a design artifact full of backticked tokens into that same body, and the first line of the rule allows the human to post it *before* work starts (`Approved by <name> <date>`). Nothing excludes `## Testing decisions` or `## Design`, and nothing warns the table's author. Standard: `template/.agents/skills/poteto-mode/scripts/overlap.sh:5`, "tokens without whitespace, those under `## Diff` skipped, passed together as pathspecs"; `docs/knowledge/core/DECISIONS.md` P24, same rule.

```
The architect step may append two more sections before implementation, after these: `## Testing decisions`, the scenario table, when the design has state; `## Design`, the usage and signature sketch ...
```

Documented step: `template/.agents/skills/poteto-mode/playbooks/ticket.md:5` ("its step 1 runs `.claude/skills/poteto-mode/scripts/overlap.sh N`") run on a ticket that already carries the artifact.
Result: paths quoted as examples inside the table (the #42 table on this PR names `.claude/state/program` and `tests/poteto-mode/overlap.sh`) are matched against every open PR, so the check reports an overlap the ticket does not have and stops the work naming an unrelated PR to merge first; a backticked dot-dot or absolute path in a cell exits 2 instead (row 14 of the table itself). The table's own note "unbackticked here so this ticket's own check does not trip on it" shows the hazard was known and was not carried into the rule.

## Fails open

None.

## Standards breaches

3. **The knowledge base's own indexes still say four.** `MANUAL.md` "Where to read more" counts the project's copies and lists them; `PHILOSOPHY.md:64` names the siblings. Both ship to projects and neither mentions the new page, while `AGENTS.md` was updated five → six. Standard: `CODING_STANDARDS.md`, Markdown, "A count or a version in prose is true at the commit that lands it".

```
Everything below lives in the factory clone (`~/.factory918`); a project carries only the first four, under `docs/factory918/`.
```

4. **`build_knowledge.py`'s docstring lists the documents it copies, and the list is now short one.** The tuple was added to `CORE_DOCS`; the prose eight lines above it was not. Standard: same rule as item 3.

```
                                           then copies PHILOSOPHY, MANUAL, DECISIONS and GLOSSARY (headers
                                           stripped) into template/docs/factory918/ for projects.
```

5. **`SOURCES.md` keeps a claim this PR proves false.** The new finding records that `sync` bumps no VERSION and touches no network; the sentence it contradicts sits in the file this PR edits, four lines above the new entries, unchanged. Standard: `CODING_STANDARDS.md`, Markdown, same rule; `AGENTS.md`, "where the findings disagree with the spec the findings win".

```
2026-09-22. ... factory918.sh sync (0.3.0) bumps no VERSION and touches no network, against what SOURCES.md line 3 says; the code is the truth (#89).
```

6. **The page shipped to projects points at a factory-only path.** `template/` has no `tests/`, so a project agent that follows the line finds nothing; the surrounding ticket numbers (#42, #87, #92) also resolve to the project's own issues. Standard: `CODING_STANDARDS.md`, Markdown, "Written with `/writing-for-agents` when an agent reads it"; `AGENTS.md`, "Files under `template/` are content addressed to agents in a future project".

```
Read the table beside `tests/poteto-mode/overlap.sh`: its header says the cases run in the order of the table, and each case asserts the exit code and the output of one call.
```

7. **`architect`'s two files now disagree on the first deliverable, and the orchestrator's new job is written in the runner's prompt.** `SKILL.md` Phase B is unchanged and still orders the package usage-first; the posting sentence is addressed to a runner that cannot do it. Outside the Ticket flow, `/architect` has no instruction to produce or post the table. Standard: `CODING_STANDARDS.md`, Markdown, "Written with `/writing-for-agents`" (one audience per document).

```
Then the type sketch, function signatures, module map, and prose rationale shaped per [`rationale-template.md`](rationale-template.md). The orchestrator appends the synthesized first deliverable to the ticket before implementation ...
```

## Fix alongside

8. **Shotgun Surgery.** The same three-clause writer paragraph is pasted verbatim into four playbooks and four patches; the next wording change costs eight edits. The playbooks could name the rule once (Ticket step 6 already holds it) and point at it.

```
The brief carries the ticket's design artifact (Ticket step 6). When it is a scenario table, the writer writes the test from the table before the implementation, one assertion per cell in the table's order, and the commit order shows it; a writer that cannot implement a cell as written stops and reports the cell, and never fills it in.
```

9. **Mysterious Name (a reference, not an identifier).** "the rule above" sits two sections away, and it forbids file paths as well as code snippets; the waiver only answers the snippet half, while a real table names paths.

```
+- For stateful work ... It is a decision, not a code snippet, so the rule above does not exclude it.
```

10. **The new instruction is numbered after the step it must run inside.** Ticket step 5 runs the chosen playbook to its end; step 6 then describes something that has to happen in that playbook's architect step. The patches carry the cross-reference, so it holds, but a reader following the numbers posts the artifact after implementation.

```
6. The spec's **Testing decisions** are the pre-agreed seams. ... The selected playbook's architect step adds the ticket's own: ...
```

11. **Duplicated Code.** The core page copies the #42 table and contract verbatim after naming ticket #42 and PR #92 as "the durable copy"; the two will drift and nothing checks them against each other.

```
The durable copy is the `## Testing decisions` section of ticket #42 and the description of PR #92. The legend and the table, verbatim:
```

hard findings: 2
```

## File written: scratchpad/f918copy/.scratch/review/ab47eb9/standards-brief.md

```
# Standards review brief

You may open any file in the repository and run read-only commands, such as grep or the test suite.

## Commits

c83f166 Record the design-artifact decision, a ledger line and a finding
1662392 Add the scenario table as a sixth core document
0cf6b34 Name the scenario table in to-spec's Testing Decisions
02af48c Tell the writer to work from the scenario table
5c0f2bf Post the design artifact on the ticket before implementation
3b48036 Make the scenario table the runner prompt's first deliverable

## Changed files

 AGENTS.md                                          |  2 +-
 SOURCES.md                                         |  4 +-
 docs/M0-findings.md                                |  2 +
 docs/agents/issue-tracker.md                       |  2 +
 docs/agents/ledger.md                              |  1 +
 docs/knowledge/INDEX.md                            |  7 +-
 docs/knowledge/core/DECISIONS.md                   |  3 +-
 docs/knowledge/core/GLOSSARY.md                    |  4 +-
 docs/knowledge/core/SCENARIO-TABLE.md              | 88 ++++++++++++++++++++++
 patches/mattpocock/to-spec/SKILL.md.patch          | 10 +++
 .../architect/references/runner-prompt.md.patch    | 17 +++++
 .../pstack/poteto-mode/playbooks/bug-fix.md.patch  |  2 +-
 .../pstack/poteto-mode/playbooks/feature.md.patch  |  9 ++-
 .../poteto-mode/playbooks/perf-issue.md.patch      |  2 +-
 .../poteto-mode/playbooks/refactoring.md.patch     |  7 +-
 patches/series                                     |  2 +
 .../skills/architect/references/runner-prompt.md   |  7 +-
 template/.agents/skills/knowledge/SKILL.md         |  2 +-
 .../skills/poteto-mode/playbooks/bug-fix.md        |  2 +-
 .../skills/poteto-mode/playbooks/feature.md        |  2 +-
 .../skills/poteto-mode/playbooks/perf-issue.md     |  2 +-
 .../skills/poteto-mode/playbooks/refactoring.md    |  2 +-
 .../.agents/skills/poteto-mode/playbooks/ticket.md |  2 +-
 template/.agents/skills/to-spec/SKILL.md           |  1 +
 template/docs/agents/issue-tracker.md              |  2 +
 template/docs/factory918/DECISIONS.md              |  1 +
 template/docs/factory918/GLOSSARY.md               |  2 +
 template/docs/factory918/SCENARIO-TABLE.md         | 79 +++++++++++++++++++
 tools/build_knowledge.py                           |  1 +
 29 files changed, 248 insertions(+), 19 deletions(-)

## Diff

The diff is 572 lines; read it from `.scratch/review/ab47eb9/diff`.

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

A hard finding is one of two things: the documented path gives a wrong or silent result, or an input outside it proceeds silently (fails open). An input outside the documented path that is refused with a message saying how to correct it is not a finding; it is the design.

- Manuel: "there are an infinite amount of unhappy paths and only 1 happy one"
- Manuel: "AT MOST hardening to fail fast and loud if we move outside of that"
- Manuel: "we notice the variable is unexpected and flag that without having to diagnose every reason the variable might be wrong for the user"
- Manuel: "An edge case outside the intended path being unsupported is not a flag."
- Manuel: "Primary focus must be the happy path, then unhappy paths that error in a way the user can correct."

An edge case that proceeds silently fails open: file it under `## Fails open`.

Write the report as Markdown with exactly these `## ` headings, in this order, each holding numbered items or nothing:

- `## Would break`: a breach of a documented standard that makes the documented path give a wrong or silent result. Cite the standard (file + the rule) and quote the hunk.
- `## Fails open`: a breach of a documented standard that lets an input outside the documented path proceed silently. Cite the standard (file + the rule) and quote the hunk.
- `## Standards breaches`: documented-standard breaches that do not change behavior. Cite the standard and quote the hunk.
- `## Fix alongside`: baseline smells and other judgement calls. Name the smell and quote the hunk. They are fixed only when a would-break fix already touches that code; they never count.

Each item opens with a line of the form `1. **Title.** body`, with the quoted hunk in a fenced block under it; number the items continuously across the headings, so the judgment can name your third item as [S3]. A documented repo standard overrides the baseline. Skip anything tooling enforces.

Every item under `## Would break` or `## Fails open` carries a line `Documented step:` quoting the ticket line or the `file:line` of the documentation the user follows, and a line `Result:` saying what happens instead; an item without its `Documented step:` line is sent back.

Write your report to `.scratch/review/ab47eb9/standards-report.md` and reply with only that path.
End the report with exactly one line `hard findings: N`, where N is the number of items under `## Would break` and `## Fails open` and nothing else.
```

## Other files written (not shown)

scratchpad/f918copy/.claude/settings.json
scratchpad/f918copy/.github/workflows/factory-ci.yml
scratchpad/f918copy/.gitignore
scratchpad/f918copy/.scratch/review/ab47eb9/diff
scratchpad/f918copy/AGENTS.md
scratchpad/f918copy/CLAUDE.md
scratchpad/f918copy/CODING_STANDARDS.md
scratchpad/f918copy/LICENSE
scratchpad/f918copy/README.md
scratchpad/f918copy/SOURCES.md
scratchpad/f918copy/VERSION
scratchpad/f918copy/docs/FACTORY-SPEC-v2.md
scratchpad/f918copy/docs/M0-findings.md
scratchpad/f918copy/docs/agents/domain.md
scratchpad/f918copy/docs/agents/issue-tracker.md
scratchpad/f918copy/docs/agents/ledger.md
scratchpad/f918copy/docs/agents/triage-labels.md
scratchpad/f918copy/docs/knowledge/INDEX.md
scratchpad/f918copy/docs/knowledge/core/CONVERSATION-DIGEST.md
scratchpad/f918copy/docs/knowledge/core/DECISIONS.md
scratchpad/f918copy/docs/knowledge/core/GLOSSARY.md
scratchpad/f918copy/docs/knowledge/core/MANUAL.md
scratchpad/f918copy/docs/knowledge/core/PHILOSOPHY.md
scratchpad/f918copy/docs/knowledge/core/SCENARIO-TABLE.md
scratchpad/f918copy/docs/knowledge/notes/1-matt-pocock/01-preamble.md
scratchpad/f918copy/docs/knowledge/notes/1-matt-pocock/02-who-he-is-brief-relevance-to-manuel.md
scratchpad/f918copy/docs/knowledge/notes/1-matt-pocock/03-philosophy-with-verbatim-quotes-citations.md
scratchpad/f918copy/docs/knowledge/notes/1-matt-pocock/04-the-end-to-end-flow-step-by-step-text-diagram-wh.md
scratchpad/f918copy/docs/knowledge/notes/1-matt-pocock/05-the-six-axes.md
scratchpad/f918copy/docs/knowledge/notes/1-matt-pocock/06-skill-catalog.md
scratchpad/f918copy/docs/knowledge/notes/1-matt-pocock/07-how-the-system-evolved-changelog-releases-what-w.md
scratchpad/f918copy/docs/knowledge/notes/1-matt-pocock/08-setup-install-for-claude-code-exact-commands-fir.md
scratchpad/f918copy/docs/knowledge/notes/1-matt-pocock/09-what-s-opinionated-possible-friction-for-a-begin.md
scratchpad/f918copy/docs/knowledge/notes/1-matt-pocock/10-sources.md
scratchpad/f918copy/docs/knowledge/notes/2-theo/01-preamble.md
scratchpad/f918copy/docs/knowledge/notes/2-theo/02-1-who-he-is-and-why-his-experience-matters-brief.md
scratchpad/f918copy/docs/knowledge/notes/2-theo/03-2-evidence-inventory.md
scratchpad/f918copy/docs/knowledge/notes/2-theo/04-3-his-agents-md-analyzed.md
scratchpad/f918copy/docs/knowledge/notes/2-theo/05-4-his-skills.md
scratchpad/f918copy/docs/knowledge/notes/2-theo/06-5-why-don-t-copy-them.md
scratchpad/f918copy/docs/knowledge/notes/2-theo/07-6-reconstructed-workflow-idea-merge.md
scratchpad/f918copy/docs/knowledge/notes/2-theo/08-7-the-six-axes.md
scratchpad/f918copy/docs/knowledge/notes/2-theo/09-8-t3-code-as-an-encoding-of-his-workflow.md
scratchpad/f918copy/docs/knowledge/notes/2-theo/10-9-timeline-of-how-his-stance-evolved-2024-2026.md
scratchpad/f918copy/docs/knowledge/notes/2-theo/11-10-what-s-reusable-for-a-claude-code-beginner-vs.md
scratchpad/f918copy/docs/knowledge/notes/2-theo/12-11-sources.md
scratchpad/f918copy/docs/knowledge/notes/3-pstack/01-preamble.md
scratchpad/f918copy/docs/knowledge/notes/3-pstack/02-who-she-is-and-why-it-exists-sourced.md
scratchpad/f918copy/docs/knowledge/notes/3-pstack/03-philosophy-the-21-principles.md
scratchpad/f918copy/docs/knowledge/notes/3-pstack/04-the-workflow.md
... and 1028 more


===== OUTPUT R03 =====
## Final message

{BOX}/factory918/.scratch/review/ab47eb9/standards-report.md

## File written: factory918/.scratch/review/ab47eb9/standards-report.md

```
# Standards report

For a person: the vendored patches, the knowledge build and every count in prose all check out. One step tells an agent to append to a ticket body with a command that replaces it.

## Would break

1. **`gh issue edit --body-file` replaces the body; the step says "appended".** `--body-file` sets the whole body. Nothing in the step or in `docs/agents/issue-tracker.md` tells the agent to fetch the body first and concatenate, and no append idiom is documented anywhere else in the template (the only other `gh issue edit` uses are `--add-label` / `--add-assignee`). An agent that writes the table to a file and runs the named command loses **What to build**, **Acceptance criteria**, **Parent** and **Blocked by**; `gh` exits 0 and prints the URL, so nothing says it happened. `review-brief.sh:222` then pastes the remaining body as the whole spec, and the Spec reviewer reviews against a table with no criteria. Standard: `CODING_STANDARDS.md`, Markdown — "Written with `/writing-for-agents` when an agent reads it".

Documented step: `template/.agents/skills/poteto-mode/playbooks/ticket.md:10` — "before implementation the synthesized table is appended to the ticket's body under `## Testing decisions` with `gh issue edit N --body-file`".

Result: the ticket body is overwritten by the table alone, silently, and the ask is gone for every later session and for the Spec brief.

```
+6. ... and before implementation the synthesized table is appended to the ticket's body under `## Testing decisions` with `gh issue edit N --body-file`, first line `Posted by the agent <date>` ...
```

## Fails open

## Standards breaches

## Fix alongside

2. **Duplicated Code: the writer paragraph is copied verbatim into four playbooks.** The same 40-word sentence pair lands in `feature.md`, `bug-fix.md`, `refactoring.md` and `perf-issue.md` (and their four patches). A later wording change costs eight edits kept in sync by hand; the playbooks already point at shared text elsewhere, so one sentence pointing at Ticket step 6 would carry it.

```
+... The brief carries the ticket's design artifact (Ticket step 6). When it is a scenario table, the writer writes the test from the table before the implementation, one assertion per cell in the table's order, and the commit order shows it; a writer that cannot implement a cell as written stops and reports the cell, and never fills it in.
```

3. **The "before implementation" rule sits after the step that implements.** Ticket step 5 runs the selected playbook's steps "verbatim from step 1", implementation included; step 6 is read only afterwards. It is reachable only because each playbook's delegation step points forward to step 6. P25 records the trade (no renumbering, since "Ticket step 5" is quoted in four patches and `review-brief.sh`), so this is a documented choice, not a breach.

hard findings: 1
```


===== OUTPUT R04 =====
## Final message

{BOX}/factory918/.scratch/review/ab47eb9/standards-report.md

## File written: factory918/.scratch/review/ab47eb9/standards-report.md

```
# Standards report

## Would break

1. **`MANUAL.md`'s map of what a project carries still says four and omits the new page.** The change makes `SCENARIO-TABLE.md` a sixth core document and a fifth slim copy (`tools/build_knowledge.py` `build_core` copies every core doc except `CONVERSATION-DIGEST.md`), and `AGENTS.md` and `INDEX.md` were updated for it, but `docs/knowledge/core/MANUAL.md` "Where to read more" was not. Breach of `CODING_STANDARDS.md`, Markdown: "A count or a version in prose is true at the commit that lands it."

```
docs/knowledge/core/MANUAL.md:165
Everything below lives in the factory clone (`~/.factory918`); a project carries only the first four, under `docs/factory918/`.
- `MANUAL.md` ... - `PHILOSOPHY.md` ... - `DECISIONS.md` ... - `GLOSSARY.md` ...
```

Documented step: `docs/knowledge/core/MANUAL.md:165` (and its generated copy `template/docs/factory918/MANUAL.md:146`), the reader's map of the core documents.
Result: a human or agent asking which core documents a project carries is told four and is given no entry for the page that Ticket step 6, the four playbooks and the `architect` runner prompt now all require. Fix is one line plus a bullet in `docs/knowledge/core/MANUAL.md`, then `python3 tools/build_knowledge.py`.

## Fails open

None.

## Standards breaches

2. **`build_knowledge.py`'s own docstring now describes the wrong set of copies.** The file is edited in this diff (the `CORE_DOCS` tuple) but its header still names four documents; `build_core` copies five. Same `CODING_STANDARDS.md` rule as [S1].

```
tools/build_knowledge.py:8
                                           then copies PHILOSOPHY, MANUAL, DECISIONS and GLOSSARY (headers
                                           stripped) into template/docs/factory918/ for projects.
```

## Fix alongside

3. **Ticket step 6 arrives after step 5 has already run the whole playbook (sequencing, not a smell).** Step 5 says to "run that playbook's steps verbatim from step 1", so in reading order the "before implementation" rule lands after implementation. The four playbooks' delegation steps forward-reference "Ticket step 6", which is what saves it; `DECISIONS.md` P25 records the no-renumbering reason. Worth a clause in step 5 pointing forward.

4. **Duplicated Code: the same four-sentence paragraph is pasted into four playbooks and their four patches.**

```
The brief carries the ticket's design artifact (Ticket step 6). When it is a scenario table, the writer
writes the test from the table before the implementation, one assertion per cell in the table's order, ...
```

Matches the precedent set by the `architect` skip clause, so it is the house style here, not a defect.

5. **`PHILOSOPHY.md:64`'s "read more" list omits `SCENARIO-TABLE.md`**, like [S1] but a navigation list rather than a count.

Checked and clean: both new patches reverse-apply on the template and the reversed files are byte-identical to the pinned upstreams, so `sync` stays clean; every existing patch still reverses; `to-spec` and `architect` are both vendored by `cmd_sync`; `cmd_update` rglobs the template, so the new file reaches existing projects; P25 is under Provisional; the `M0-findings` line is dated.

hard findings: 1
```

## Other files written (not shown)

scratchpad/pcheck/architect/SKILL.md
scratchpad/pcheck/architect/references/design-red-flags.md
scratchpad/pcheck/architect/references/rationale-template.md
scratchpad/pcheck/architect/references/runner-prompt.md
scratchpad/pcheck/to-spec/SKILL.md
scratchpad/pcheck/to-spec/agents/openai.yaml


===== OUTPUT R05 =====
## Final message

{BOX}/factory918/.scratch/review/ab47eb9/standards-report.md

## File written: factory918/.scratch/review/ab47eb9/standards-report.md

```
# Standards review

For a person: the change reads clean against the bash/Python standards (nothing but one `CORE_DOCS` tuple), the build and the patch series verify, and the prose is good. The three hard findings are all the same shape: the new rule says a stateful design must produce and post a scenario table, but no step on the documented path makes that happen or notices when it does not.

Verified before reporting: `python3 tools/build_knowledge.py` leaves `git status` clean and `python3 tools/check_knowledge.py` passes (119 files); `bash -n factory918.sh` passes; `./factory918.sh sync` applies all 20 patches, including the two new ones, and leaves `git status` clean (run in a scratch copy, because `mktemp -d` is blocked in this sandbox). `tests/hooks/delegation.sh`, `tests/spec-review/*.sh` and `tests/poteto-mode/overlap.sh` could not run for the same `mktemp -d` restriction; the diff touches none of their subjects. The diff is not cross-cutting under `review-brief.sh`'s predicate (no `.claude/hooks/`, no `.claude/settings.json`, no `.agents/skills/factory918/`), so no blast-radius grounding is owed.

## Would break

1. **The posting step rewrites the ticket body instead of appending to it.** `gh issue edit N --body-file FILE` replaces the issue body with the file's contents; it has no append mode. The step says "appended" and names the destructive flag, and never says to read the current body first (`gh issue view N --json body -q .body`) and write body-plus-section. Every other `gh issue` operation the repo documents is additive (`--add-label`, `--add-assignee`, `gh issue comment`), so there is no house pattern to fall back on; `template/docs/agents/issue-tracker.md:7-12` lists no body-rewrite operation at all. The standard breached is `CODING_STANDARDS.md:22` ("Written with `/writing-for-agents` when an agent reads it"): `template/.agents/skills/writing-for-agents/SKILL.md:47-52` requires a step whose completion is checkable, and this one is followed to completion by a command that silently drops the rest of the body.

   ```
   before implementation the synthesized table is appended to the ticket's body under `## Testing decisions` with `gh issue edit N --body-file`, first line `Posted by the agent <date>`
   ```

   Documented step: `template/.agents/skills/poteto-mode/playbooks/ticket.md:10` (Ticket playbook, step 6).
   Result: an agent that writes the new section to the body file and runs the documented command replaces `## What to build`, `## Acceptance criteria`, `## Parent` and `## Blocked by` with the table alone. Nothing errors. `review-brief.sh:222` then pastes that truncated body as the Spec brief's spec, so the Spec axis reviews the work against the table with the ask deleted, and the shape `template/docs/agents/issue-tracker.md:18` calls canonical ("Every ticket has this shape, in this order") is gone from the record the human reads.

2. **Nothing on the documented path triggers the table for a stateful design that does not cross a function boundary.** Ticket step 6 delegates the trigger to "the selected playbook's architect step", but three of the four playbooks gate that step on a function boundary and the fourth gates the no-skip clause on a cross-cutting diff. State is never a trigger anywhere. The new mandatory case therefore has no entry point: a change to a state file's format, an exit-code change, or a new round counter inside one function runs no `architect`, produces no table, and the delegation step's "When it is a scenario table" simply does not fire. The cross-cutting case shows the shape the fix takes, one clause on the same sentence.

   ```
   3. Plan the fix. If it crosses a function boundary, `architect` first; a cross-cutting diff (Ticket step 5) never skips it.
   ```

   ```
   2. `architect` for parallel design exploration. Skipping stays as `architect skipped: <reason>`, not accepted for a cross-cutting diff (Ticket step 5); do not fold the design decision silently into implementation.
   ```

   Documented step: `template/.agents/skills/poteto-mode/playbooks/ticket.md:10` ("The selected playbook's architect step adds the ticket's own: when the design adds state ... `architect`'s first deliverable is the scenario table"), against `bug-fix.md:9`, `perf-issue.md:16`, `refactoring.md:9` ("If it crosses a function boundary, `architect` first") and `feature.md:6`.
   Result: the rule that `docs/knowledge/core/DECISIONS.md` P25 and `SCENARIO-TABLE.md:11` state unconditionally ("before any code that has state") is unreachable for exactly the stateful-but-local change, and the work proceeds to the writer with no table and no message. That is the PR #87 failure the change exists to prevent.

## Fails open

3. **A candidate package that comes back with no scenario table is accepted silently, and the orchestrator has no named section to post.** The patch puts the state branch only in the runner prompt. `architect/SKILL.md:32` (Phase B) and `:84` (Outputs) still say the package is "the caller's usage written first, then the type sketch", and `references/rationale-template.md:9` still says "Write this first, before the type sketch" under `## Usage (caller's view)`. The template the same sentence points to has no heading for a table. No step in Phase B, C or D checks that the first deliverable the runner prompt asks for exists, and the posting instruction says "the synthesized first deliverable" without naming the section that holds it.

   ```
   Then the type sketch, function signatures, module map, and prose rationale shaped per [`rationale-template.md`](rationale-template.md). The orchestrator appends the synthesized first deliverable to the ticket before implementation, a table under `## Testing decisions`, a sketch under `## Design` (the Ticket playbook, step 6); the writer, the reviewer and the human read it there.
   ```

   Documented step: `template/.agents/skills/architect/references/runner-prompt.md:5-10`, read against `template/.agents/skills/architect/SKILL.md:32` and `template/.agents/skills/architect/references/rationale-template.md:9`.
   Result: a runner told to "Read the **architect** skill in full first" gets usage-first from the skill and table-first from the prompt, and a package with no table satisfies every shape document it was given. The orchestrator then has nothing to extract, posts nothing under `## Testing decisions`, and the writer's "When it is a scenario table" branch stays dark. The absence is never refused and never reported.

## Standards breaches

4. **The writer rule is pasted verbatim into four playbooks, and the trigger list it travels with has already drifted.** `CODING_STANDARDS.md:22` sends agent-facing markdown through `/writing-for-agents`, whose pruning rule is "Keep each meaning in a **single source of truth**: one authoritative place, so changing the behaviour is a one-place edit" (`template/.agents/skills/writing-for-agents/SKILL.md:78`). The same 46-word rule now lives in `feature.md:12`, `bug-fix.md:9`, `refactoring.md:9` and `perf-issue.md:16`, each sentence already carrying its own pointer ("Ticket step 6") that would do the job alone. The cost is not hypothetical: the state trigger is "a file it reads or writes, exit codes, rounds, or more than one actor" in `ticket.md:10`, the runner prompt and P25, but "a file read or written, exit codes, more than one actor" in the `to-spec` patch and "a file, exit codes, more than one actor" in the `CORE_DOCS` tuple that generates `INDEX.md`. Rounds are state in four copies and not state in two.

   ```
   The brief carries the ticket's design artifact (Ticket step 6). When it is a scenario table, the writer writes the test from the table before the implementation, one assertion per cell in the table's order, and the commit order shows it; a writer that cannot implement a cell as written stops and reports the cell, and never fills it in.
   ```

5. **The runner prompt carries a sentence addressed to the orchestrator.** The file's own header says it "is passed through to every parallel candidate runner during Phase B", so a line about what the orchestrator does afterwards is exposition in the runner's context, which `template/.agents/skills/writing-for-agents/SKILL.md:80` prunes ("does it still bear on what the document does? A line loses relevance by never bearing on the task"). It also reads as an instruction a runner could act on, and N runners each editing one ticket body with the body-replacing command of finding 1 is a race with a destructive loser. The orchestrator-side home is `architect/SKILL.md` Phase C/D, which the patch leaves untouched.

   ```
   The orchestrator appends the synthesized first deliverable to the ticket before implementation, a table under `## Testing decisions`, a sketch under `## Design` (the Ticket playbook, step 6); the writer, the reviewer and the human read it there.
   ```

6. **Half the new core document is a factory-internal example that every project receives.** Lines 49 to 78 of `docs/knowledge/core/SCENARIO-TABLE.md` are the #42 legend, the fourteen-row `overlap.sh` table and two paragraphs of its contract, verbatim; `build_core` copies the page to `template/docs/factory918/SCENARIO-TABLE.md`, where that is 45 of 79 lines about `.claude/state/program`, `closingIssuesReferences` and `tests/poteto-mode/overlap.sh`, none of which a project has. `CODING_STANDARDS.md:22` asks for one Diátaxis mode per file, and the page runs explanation ("What it is", "Why") over reference ("The shape", "Where it goes") over a worked example; `writing-for-agents SKILL.md:79` treats a restatement of material the agent can look up as a cache that earns its load only when the lookup is expensive, and the durable copy is named in the page itself (ticket #42 and PR #92). Two or three rows and the legend carry the lesson; the rest is sediment the next `overlap.sh` change has to chase.

   ```
   The durable copy is the `## Testing decisions` section of ticket #42 and the description of PR #92. The legend and the table, verbatim:
   ```

## Fix alongside

7. **Shotgun Surgery.** One rule landed in ten prose homes: `ticket.md`, four playbooks, the runner prompt, `to-spec`, `issue-tracker.md`, `GLOSSARY.md`, `DECISIONS.md` P25 and the new page. The playbooks are separately patched vendored files with no include mechanism, so some spread is forced, but the rule's definition belongs in one of them (the new page) with pointers elsewhere, which would also close finding 4.

   ```
   patches/pstack/poteto-mode/playbooks/{bug-fix,feature,perf-issue,refactoring}.md.patch
   ```

8. **Sprawl in `feature.md` step 4.** The step was already one long paragraph; it is now about 190 words carrying four unrelated rules (data shape, the design artifact, the arena branch, the no-skip clause). `writing-for-agents SKILL.md:43` names sprawl as the failure mode and the ladder as the cure. Worth a split only if a would-break fix lands in that step anyway.

   ```
   ... and success criteria); review its diff yourself. The brief carries the ticket's design artifact (Ticket step 6). When it is a scenario table, ... When the implementation admits multiple valid shapes (error handling, abstraction layer, test structure), delegate via the **arena** skill instead ...
   ```

9. **Two tables can claim `## Testing decisions` with no tie-break.** The `to-spec` patch makes the table the shape for the spec's Testing Decisions, and Ticket step 6 posts "the ticket's own" under a heading of the same name on the ticket. `review-brief.sh` pastes only the ticket body, so the review reads one of them; which one governs when the architect's table disagrees with the spec's is unstated.

   ```
   - For stateful work (a file read or written, exit codes, more than one actor), the shape is the scenario table: situations down the side, the shape of the input across the top, and in every cell what is printed, the exit code and what the caller does next.
   ```

hard findings: 3
```

## File written: scratchpad/syncchk/repo/.scratch/review/ab47eb9/standards-brief.md

```
# Standards review brief

You may open any file in the repository and run read-only commands, such as grep or the test suite.

## Commits

c83f166 Record the design-artifact decision, a ledger line and a finding
1662392 Add the scenario table as a sixth core document
0cf6b34 Name the scenario table in to-spec's Testing Decisions
02af48c Tell the writer to work from the scenario table
5c0f2bf Post the design artifact on the ticket before implementation
3b48036 Make the scenario table the runner prompt's first deliverable

## Changed files

 AGENTS.md                                          |  2 +-
 SOURCES.md                                         |  4 +-
 docs/M0-findings.md                                |  2 +
 docs/agents/issue-tracker.md                       |  2 +
 docs/agents/ledger.md                              |  1 +
 docs/knowledge/INDEX.md                            |  7 +-
 docs/knowledge/core/DECISIONS.md                   |  3 +-
 docs/knowledge/core/GLOSSARY.md                    |  4 +-
 docs/knowledge/core/SCENARIO-TABLE.md              | 88 ++++++++++++++++++++++
 patches/mattpocock/to-spec/SKILL.md.patch          | 10 +++
 .../architect/references/runner-prompt.md.patch    | 17 +++++
 .../pstack/poteto-mode/playbooks/bug-fix.md.patch  |  2 +-
 .../pstack/poteto-mode/playbooks/feature.md.patch  |  9 ++-
 .../poteto-mode/playbooks/perf-issue.md.patch      |  2 +-
 .../poteto-mode/playbooks/refactoring.md.patch     |  7 +-
 patches/series                                     |  2 +
 .../skills/architect/references/runner-prompt.md   |  7 +-
 template/.agents/skills/knowledge/SKILL.md         |  2 +-
 .../skills/poteto-mode/playbooks/bug-fix.md        |  2 +-
 .../skills/poteto-mode/playbooks/feature.md        |  2 +-
 .../skills/poteto-mode/playbooks/perf-issue.md     |  2 +-
 .../skills/poteto-mode/playbooks/refactoring.md    |  2 +-
 .../.agents/skills/poteto-mode/playbooks/ticket.md |  2 +-
 template/.agents/skills/to-spec/SKILL.md           |  1 +
 template/docs/agents/issue-tracker.md              |  2 +
 template/docs/factory918/DECISIONS.md              |  1 +
 template/docs/factory918/GLOSSARY.md               |  2 +
 template/docs/factory918/SCENARIO-TABLE.md         | 79 +++++++++++++++++++
 tools/build_knowledge.py                           |  1 +
 29 files changed, 248 insertions(+), 19 deletions(-)

## Diff

The diff is 572 lines; read it from `.scratch/review/ab47eb9/diff`.

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

A hard finding is one of two things: the documented path gives a wrong or silent result, or an input outside it proceeds silently (fails open). An input outside the documented path that is refused with a message saying how to correct it is not a finding; it is the design.

- Manuel: "there are an infinite amount of unhappy paths and only 1 happy one"
- Manuel: "AT MOST hardening to fail fast and loud if we move outside of that"
- Manuel: "we notice the variable is unexpected and flag that without having to diagnose every reason the variable might be wrong for the user"
- Manuel: "An edge case outside the intended path being unsupported is not a flag."
- Manuel: "Primary focus must be the happy path, then unhappy paths that error in a way the user can correct."

An edge case that proceeds silently fails open: file it under `## Fails open`.

Write the report as Markdown with exactly these `## ` headings, in this order, each holding numbered items or nothing:

- `## Would break`: a breach of a documented standard that makes the documented path give a wrong or silent result. Cite the standard (file + the rule) and quote the hunk.
- `## Fails open`: a breach of a documented standard that lets an input outside the documented path proceed silently. Cite the standard (file + the rule) and quote the hunk.
- `## Standards breaches`: documented-standard breaches that do not change behavior. Cite the standard and quote the hunk.
- `## Fix alongside`: baseline smells and other judgement calls. Name the smell and quote the hunk. They are fixed only when a would-break fix already touches that code; they never count.

Each item opens with a line of the form `1. **Title.** body`, with the quoted hunk in a fenced block under it; number the items continuously across the headings, so the judgment can name your third item as [S3]. A documented repo standard overrides the baseline. Skip anything tooling enforces.

Every item under `## Would break` or `## Fails open` carries a line `Documented step:` quoting the ticket line or the `file:line` of the documentation the user follows, and a line `Result:` saying what happens instead; an item without its `Documented step:` line is sent back.

Write your report to `.scratch/review/ab47eb9/standards-report.md` and reply with only that path.
End the report with exactly one line `hard findings: N`, where N is the number of items under `## Would break` and `## Fails open` and nothing else.
```

## File written: scratchpad/syncchk/repo/factory918.sh

```
#!/usr/bin/env bash
# The Factory918 CLI. Subcommands: install | models [preset] | init | apply [--profile name] [--name n] | doctor | update | sync | sync-repos | labels | knowledge
# Implemented per docs/FACTORY-SPEC-v2.md §8; verified against the tool versions in docs/M0-findings.md.
set -euo pipefail
# Resolve the script's real location: ~/.local/bin/factory918 is a symlink into the clone.
self="${BASH_SOURCE[0]}"
while [ -L "$self" ]; do target="$(readlink "$self")"; case "$target" in /*) self="$target" ;; *) self="$(dirname "$self")/$target" ;; esac; done
F918_DIR="$(cd "$(dirname "$self")" && pwd -P)"
TEMPLATE="$F918_DIR/template"
VERSION="$(cat "$F918_DIR/VERSION" 2>/dev/null || echo 0.1.0)"

usage() { sed -n '2,3p' "$0"; exit 1; }
need() { command -v "$1" >/dev/null || { echo "missing: $1" >&2; exit 1; }; }

sha() { if command -v sha256sum >/dev/null; then sha256sum "$1"; else shasum -a 256 "$1"; fi | cut -d' ' -f1; }

approve_ast_grep() {
  [ -f "$1" ] || return 0
  python3 - "$1" <<'EOF'
import re, sys, pathlib
p = pathlib.Path(sys.argv[1]); t = p.read_text()
if re.search(r'^\s+"?@ast-grep/cli"?:\s*true\s*$', t, re.M):
    sys.exit(0)
line = '  "@ast-grep/cli": true'
if "allowBuilds:" in t:
    t = re.sub(r'^\s+"?@ast-grep/cli"?:.*$', line, t, count=1, flags=re.M)
    if line not in t:
        t = t.replace("allowBuilds:", "allowBuilds:\n" + line, 1)
else:
    t = t.rstrip("\n") + "\nallowBuilds:\n" + line + "\n"
p.write_text(t)
EOF
}

FACTORY_OWNED="AGENTS.md CLAUDE.md vite.config.ts .vite-hooks/pre-commit"

# Python package at python/<name>: pyproject, a package, a smoke test, the CI job, a lockfile,
# and *.py in the commit hook. A profile is additive like apply: nothing that exists is replaced.
apply_python() {
  local dir="$1" name="$2" pkg="$1/python/$2" P="$F918_DIR/profiles/python"
  need uv
  mkdir -p "$pkg/src/$name" "$pkg/tests" "$dir/.github/workflows"
  [ -s "$pkg/pyproject.toml" ] || sed "s/<name>/$name/g" "$P/pyproject.toml" > "$pkg/pyproject.toml"
  [ -s "$pkg/src/$name/__init__.py" ] || printf '"""%s."""\n' "$name" > "$pkg/src/$name/__init__.py"
  [ -s "$pkg/tests/test_smoke.py" ] || printf 'import %s\n\n\ndef test_imports() -> None:\n    assert %s.__doc__\n' "$name" "$name" > "$pkg/tests/test_smoke.py"
  [ -s "$dir/.github/workflows/python.yml" ] || sed "s/<name>/$name/g" "$P/python.yml" > "$dir/.github/workflows/python.yml"
  [ -s "$pkg/uv.lock" ] || (cd "$pkg" && uv lock -q)
  # Same thin hook for Python: the formatter only, on commit.
  if [ -f "$dir/vite.config.ts" ] && ! grep -q '"\*\.py"' "$dir/vite.config.ts"; then
    python3 - "$dir/vite.config.ts" "$name" <<'EOF'
import pathlib, re, sys
p = pathlib.Path(sys.argv[1]); t = p.read_text()
task = f'"*.py": "uv run --project python/{sys.argv[2]} ruff format",'
t = re.sub(r'(\n(\s*)"\*": "vp fmt[^\n]*\n)', lambda m: m.group(1) + m.group(2) + task + "\n", t, count=1)
p.write_text(t)
EOF
  fi
}

# Expo app files and the native-fingerprint signal. The app itself is one command the
# human or the agent runs, printed at the end, because it downloads an Expo SDK.
apply_react_native() {
  local dir="$1" P="$F918_DIR/profiles/react-native"
  mkdir -p "$dir/apps/mobile" "$dir/.github/workflows"
  [ -s "$dir/apps/mobile/eas.json" ] || cp "$P/eas.json.example" "$dir/apps/mobile/eas.json"
  [ -s "$dir/.github/workflows/mobile-fingerprint-check.yml" ] || cp "$P/mobile-fingerprint-check.yml" "$dir/.github/workflows/mobile-fingerprint-check.yml"
  [ -s "$dir/apps/mobile/package.json" ] || echo "Next: (cd $dir && npx create-expo-app@latest apps/mobile --template blank-typescript), then vp install."
}

# Per machine, once: ~/.factory918 points at this clone (the knowledge skill's fallback and
# $FACTORY918_HOME's default), and ~/.local/bin/factory918 puts the CLI on PATH.
cmd_install() {
  local home="$HOME/.factory918" bin="$HOME/.local/bin"
  for tool in git jq python3; do command -v "$tool" >/dev/null || echo "missing: $tool (install it with your package manager; the CLI needs git, jq and python3)"; done
  if [ -e "$home" ] && [ "$(cd "$home" && pwd -P)" != "$(cd "$F918_DIR" && pwd -P)" ]; then
    echo "$home already points elsewhere: $(readlink "$home" || echo "$home"). Move it aside or set FACTORY918_HOME." >&2; exit 1
  fi
  [ -e "$home" ] || ln -s "$F918_DIR" "$home"
  mkdir -p "$bin"; ln -sf "$F918_DIR/factory918.sh" "$bin/factory918"
  echo "installed: $home -> $F918_DIR"
  echo "installed: $bin/factory918"
  case ":$PATH:" in *":$bin:"*) ;; *) echo "add to your shell rc: export PATH=\"\$HOME/.local/bin:\$PATH\"" ;; esac
  # The one user-level write the factory makes (spec §5.5): pstack's role sheet, from machine/.
  if [ ! -f "$HOME/.claude/pstack-models.md" ]; then
    mkdir -p "$HOME/.claude"; cp "$F918_DIR/machine/pstack-models.fable.md" "$HOME/.claude/pstack-models.md"; echo "installed: ~/.claude/pstack-models.md (fable preset)"
  fi
  grep -qx '@~/.claude/pstack-models.md' "$HOME/.claude/CLAUDE.md" 2>/dev/null || { printf '@~/.claude/pstack-models.md\n' >> "$HOME/.claude/CLAUDE.md"; echo "installed: include line in ~/.claude/CLAUDE.md"; }
  command -v vp >/dev/null || echo "next: install Vite+ with  curl -fsSL https://vite.plus -o /tmp/vp.sh && VP_VERSION=0.3.1 VP_NODE_MANAGER=yes bash /tmp/vp.sh"
  command -v gh >/dev/null && gh auth status >/dev/null 2>&1 || echo "next: gh auth login"
}

# Which preset of pstack's role sheet is active on this machine. pstack never falls back on its
# own: when a lane drops out on quota, the human switches. No argument prints the active preset.
presets() { local p; for p in "$F918_DIR"/machine/pstack-models.*.md; do p="${p##*/pstack-models.}"; echo "${p%.md}"; done; }

cmd_models() {
  local sheet="$HOME/.claude/pstack-models.md" preset="${1:-}" n
  if [ -z "$preset" ]; then
    [ -f "$sheet" ] || { echo "no sheet at $sheet yet: factory918 install writes the fable preset"; return 0; }
    for n in $(presets); do cmp -s "$F918_DIR/machine/pstack-models.$n.md" "$sheet" && { echo "active: $n"; return 0; }; done
    echo "active: a sheet edited by hand (matches no preset in machine/)"; return 0
  fi
  [ -f "$F918_DIR/machine/pstack-models.$preset.md" ] || { echo "no preset named $preset; have: $(presets | tr '\n' ' ')" >&2; exit 1; }
  mkdir -p "$HOME/.claude"; cp "$F918_DIR/machine/pstack-models.$preset.md" "$sheet"; echo "active: $preset -> $sheet"
}

cmd_apply() {
  local dir="${1:-.}"; need jq; need python3
  shift || true
  local profile="" scaffold="" name=""
  while [ $# -gt 0 ]; do case "$1" in
    --profile) profile="$2"; shift 2 ;;
    --name) name="$2"; shift 2 ;;
    --scaffold) scaffold=1; shift ;;
    *) shift ;;
  esac; done
  mkdir -p "$dir/.factory918"
  local manifest="$dir/.factory918/manifest.json"
  [ -f "$manifest" ] || echo '{"version":"'"$VERSION"'","files":{},"profiles":[]}' > "$manifest"
  printf '{"factory":"%s"}\n' "$(cd "$F918_DIR" && pwd -P)" > "$dir/.factory918/local.json"   # git-ignored; the clone that applied
  tmp="$(mktemp)"; jq 'del(.factory)' "$manifest" > "$tmp" && mv "$tmp" "$manifest"           # older manifests carried the path
  if [ -n "$profile" ]; then
    case "$profile" in
      python) apply_python "$dir" "${name:-$(basename "$(cd "$dir" && pwd)")}" ;;
      react-native) apply_react_native "$dir" ;;
      *) echo "unknown profile: $profile (python | react-native)" >&2; exit 1 ;;
    esac
    tmp="$(mktemp)"; jq --arg p "$profile" '.profiles = ((.profiles // []) + [$p] | unique)' "$manifest" > "$tmp" && mv "$tmp" "$manifest"
  fi
  # Copy every managed file that does not exist locally; record its hash. Never overwrite an existing file here.
  (cd "$TEMPLATE" && find . -type f ! -name '.gitkeep' -print0) | while IFS= read -r -d '' rel; do
    rel="${rel#./}"
    case "$rel" in package.scripts.json|.gitignore.factory) continue ;; esac
    owned=""
    [ -n "$scaffold" ] && case " $FACTORY_OWNED " in *" $rel "*) owned=1 ;; esac
    if [ ! -e "$dir/$rel" ] || [ -n "$owned" ]; then
      mkdir -p "$dir/$(dirname "$rel")"; cp -p "$TEMPLATE/$rel" "$dir/$rel"
    fi
    h="$(sha "$TEMPLATE/$rel")"
    tmp="$(mktemp)"; jq --arg k "$rel" --arg v "$h" '.files[$k]={"template":$v}' "$manifest" > "$tmp" && mv "$tmp" "$manifest"
  done
  # Symlink .claude/skills -> ../.agents/skills (T3 Code's pattern).
  mkdir -p "$dir/.claude"; [ -e "$dir/.claude/skills" ] || ln -s ../.agents/skills "$dir/.claude/skills"
  # Append gitignore entries once.
  grep -q '^\.artifacts/' "$dir/.gitignore" 2>/dev/null || cat "$TEMPLATE/.gitignore.factory" >> "$dir/.gitignore"
  # Merge scripts, engines and devDependencies; the project's own values win.
  if [ -f "$dir/package.json" ]; then
    tmp="$(mktemp)"
    jq -s '.[0] as $t | .[1]
           | .scripts = (($t.scripts // {}) + (.scripts // {}))
           | .engines = (($t.engines // {}) + (.engines // {}))
           | .devDependencies = (($t.devDependencies // {}) + (.devDependencies // {}))' \
      "$TEMPLATE/package.scripts.json" "$dir/package.json" > "$tmp" && mv "$tmp" "$dir/package.json"
  fi
  chmod +x "$dir"/.claude/hooks/*.sh "$dir/.vite-hooks/pre-commit" 2>/dev/null || true
  # pnpm gates the native binary @ast-grep/cli builds; approve it once so nobody is
  # asked at install time. In a workspace the key lives in pnpm-workspace.yaml.
  approve_ast_grep "$dir/pnpm-workspace.yaml"
  # Install first: the lint plugin and the rule engine are devDependencies, and the
  # gates report missing tooling as failure. Then format, because vp check stops at
  # the first stage and an unformatted file would hide every lint and type error.
  # apply just changed package.json, so the lockfile must be regenerated; pnpm would otherwise
  # refuse under CI. A failed install is reported, never hidden: every gate depends on it.
  log="$(mktemp)"
  if ! (cd "$dir" && vp install --no-frozen-lockfile) > "$log" 2>&1; then echo "warning: vp install failed:"; tail -8 "$log"; fi
  rm -f "$log"
  (cd "$dir" && vp fmt >/dev/null 2>&1) || true
  cmd_doctor "$dir" || true
}

cmd_init() {
  local dir="$1"; shift; local template="vite:monorepo" github=1
  while [ $# -gt 0 ]; do case "$1" in --no-github) github=""; shift ;; vite:*) template="$1"; shift ;; *) shift ;; esac; done
  need vp; [ -z "$github" ] || need gh
  # vp create refuses an absolute --directory: run it from the parent and pass the name.
  mkdir -p "$(dirname "$dir")"
  (cd "$(dirname "$dir")" && vp create "$template" --directory "$(basename "$dir")" --no-interactive --git --hooks --no-agent)
  git -C "$dir" branch -M main   # vp create uses the machine default; CI, the guard and protection assume main
  cmd_apply "$dir" --scaffold
  if [ -n "$github" ]; then
    if (cd "$dir" && gh repo create --source=. --private --push); then
      # Owner-mode repository setting: merged branches are deleted so stacked PRs retarget to main.
      (cd "$dir" && gh repo edit --delete-branch-on-merge >/dev/null) || echo "note: could not set delete-branch-on-merge; delete branches after merging"
      cmd_labels "$dir"
    else
      echo "skipped gh repo create; labels and repository settings wait until a remote exists"
    fi
  fi
  echo "Next: open Claude Code in $dir and run /factory-start. Human-only steps such as secrets: /wizard writes the script."
}

# A session inherits whatever branch the last one left, so the doctor says where the checkout is
# before anything else. Offline, the line says it compared against the last fetch; it never
# reports "up to date" as if the fetch had happened.
doctor_branch() {
  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return 0
  local ref="" branch behind plural merged stale=""
  if git remote get-url origin >/dev/null 2>&1; then
    git fetch -q origin main 2>/dev/null || stale=" (fetch failed, compared against the last fetch)"
  fi
  if git rev-parse -q --verify origin/main >/dev/null 2>&1; then ref=origin/main
  elif git rev-parse -q --verify main >/dev/null 2>&1; then ref=main; fi
  branch="$(git branch --show-current)"
  if ! git rev-parse -q --verify HEAD >/dev/null 2>&1; then
    note "branch ${branch:-detached HEAD} has no commits yet" "git add -A && git commit -m 'chore: initial commit'"
  elif [ -z "$ref" ]; then
    note "branch ${branch:-detached HEAD}: no main to compare against" "git remote add origin <url> && git fetch origin"
  elif [ -z "$branch" ]; then
    note "detached HEAD" "git checkout main && git pull"
  else
    behind="$(git rev-list --count "HEAD..$ref" 2>/dev/null || echo unknown)"; plural=s; [ "$behind" = 1 ] && plural=""
    if [ "$behind" = unknown ]; then
      note "branch $branch: could not compare with $ref" "git fetch origin, then git status"
    elif [ "$branch" = main ]; then
      if [ "$behind" -gt 0 ]; then note "branch main is $behind commit$plural behind $ref$stale" "git pull"; else echo "PASS  branch main, up to date$stale"; fi
    elif [ "$behind" -eq 0 ]; then
      echo "PASS  branch $branch, up to date with main$stale"
    elif git merge-base --is-ancestor HEAD "$ref"; then
      note "branch $branch is already in main$stale" "git checkout main && git pull"
    else
      merged="$(gh pr list --head "$branch" --state merged --json number --jq length 2>/dev/null || echo unknown)"
      if [ "$merged" = unknown ] || [ -z "$merged" ]; then stale="$stale (merged state unknown, gh did not answer)"; merged=0; fi
      if [ "$merged" -gt 0 ]; then
        note "branch $branch was merged (squash or rebase, so main does not contain its commits)" "git checkout main && git pull"
      else
        note "branch $branch is $behind commit$plural behind main$stale" "git checkout main && git pull to start a ticket, or git rebase $ref to continue this branch"
      fi
    fi
  fi
}

# Each FAIL line carries its fix, so an agent reading the table can guide a person who has
# never seen this system. PASS needs nothing; NOTE is optional.
STALE_DAYS=14

cmd_doctor() {
  local dir="${1:-.}"; local fail=0
  chk() { if eval "$2" >/dev/null 2>&1; then echo "PASS  $1"; else echo "FAIL  $1"; echo "      fix: $3"; fail=1; fi; }
  note() { echo "NOTE  $1"; echo "      fix: $2"; }
  cd "$dir"
  if [ ! -f .factory918/manifest.json ]; then
    echo "FAIL  this directory is not a Factory918 project"
    echo "      fix: factory918 init <new-dir> to create one, or factory918 apply here to add Factory918 to an existing repo"
    return 1
  fi
  doctor_branch
  chk "factory files reachable"       "[ -d \"$TEMPLATE\" ] && [ -d \"$F918_DIR/profiles\" ]" "the factory918 command does not resolve to a clone (template/ missing beside it); run ./factory918.sh install from the clone"
  chk "factory918 installed"          "command -v factory918 && [ -d \"\${FACTORY918_HOME:-\$HOME/.factory918}/docs/knowledge\" ]" "in the factory918 clone run ./factory918.sh install, add ~/.local/bin to PATH, open a new terminal"
  chk "one factory on this machine"   "[ ! -e \"\$HOME/.factory918\" ] || [ \"\$(cd \"\$HOME/.factory918\" && pwd -P)\" = \"\$(cd \"\$(dirname \"\$(readlink \"\$(command -v factory918)\")\")\" && pwd -P)\" ]" "~/.factory918 and ~/.local/bin/factory918 point at different clones; run ./factory918.sh install from the one you want"
  chk "vp matches the ADR pin"        "[ \"\$(vp --version | head -1 | sed 's/^vp v//')\" = \"\$(sed -n 's/.*vite-plus \\([0-9][0-9.]*\\).*/\\1/p' docs/adr/0001-toolchain.md | head -1)\" ]" "docs/adr/0001-toolchain.md pins a different vite-plus than vp --version reports; update the ADR or run the Vite+ installer with VP_VERSION=<pin>"
  chk "vp on PATH"                    "command -v vp" "curl -fsSL https://vite.plus -o /tmp/vp.sh && VP_VERSION=0.3.1 VP_NODE_MANAGER=yes bash /tmp/vp.sh, then open a new terminal"
  chk "vp env doctor"                 "vp env doctor" "run vp env doctor and follow its output"
  chk "hooks installed"               "vp hooks status | grep -qi 'hooksPath'" "vp hooks enable (no .git means this is not a repository yet: git init first)"
  chk ".claude/skills symlink"        "[ \"\$(readlink .claude/skills)\" = ../.agents/skills ]" "rm -rf .claude/skills && ln -s ../.agents/skills .claude/skills"
  chk "every skill has a name"        "! grep -L '^name:' .agents/skills/*/SKILL.md | grep ." "factory918 update restores the vendored skills; a skill you wrote needs a name: line in its frontmatter"
  chk "no duplicate skill names"      "[ -z \"\$(grep -h '^name:' .agents/skills/*/SKILL.md | sort | uniq -d)\" ]" "rename or remove one of the two skills that share a name (grep -h ^name: .agents/skills/*/SKILL.md | sort | uniq -d)"
  chk "gh authenticated"              "gh auth status" "gh auth login (install gh first: brew, apt, dnf or winget)"
  chk "labels present"                "gh label list --limit 200 | grep -q ready-for-agent" "factory918 labels (needs a GitHub remote; factory918 init creates one, or gh repo create --private --source=. --push)"
  # No remote or no auth prints nothing here; the two lines above already say so.
  local dbm; dbm="$(gh repo view --json deleteBranchOnMerge --jq .deleteBranchOnMerge 2>/dev/null || true)"
  if [ "$dbm" = true ]; then echo "PASS  delete-branch-on-merge"
  elif [ "$dbm" = false ]; then note "delete-branch-on-merge" "gh repo edit --delete-branch-on-merge; without it a stacked PR stays on its merged parent's branch instead of retargeting to main"; fi
  chk "ci workflow present"           "[ -f .github/workflows/ci.yml ]" "factory918 update restores it"
  chk "settings.json parses"          "jq . .claude/settings.json" "fix the JSON in .claude/settings.json, or factory918 update to restore the template copy"
  chk "hooks executable"              "[ -x .claude/hooks/mode.sh ] && [ -x .claude/hooks/block-dangerous-git.sh ] && [ -x .claude/hooks/delegation.sh ]" "chmod +x .claude/hooks/*.sh"
  chk "state dir ignored"             "git check-ignore -q .claude/state/mode" "append the lines from the factory clone's template/.gitignore.factory to .gitignore"
  if [ -f .claude/state/review/files ]; then
    note "a review state is left behind: .claude/state/review ($(cat .claude/state/review/fixed-point 2>/dev/null || echo unknown), $(wc -l < .claude/state/review/files | tr -d ' ') files); reads of those files are blocked" "finish the review (spec-review step 6 runs review-comment.sh, which clears it) or rm -rf .claude/state/review"
  fi
  chk "vp check (format, lint, types)" "vp check" "vp fmt, then vp check, and fix what it reports; it stops at the first failing stage"
  chk "tests"                         "vp test run" "vp test run and read the failing test"
  [ -f "$HOME/.claude/pstack-models.md" ] && echo "PASS  models sheet" || note "models sheet" "factory918 install writes ~/.claude/pstack-models.md"
  chk "AGENTS.md is Factory918's"     "grep -q 'factory918' AGENTS.md" "factory918 apply --scaffold replaces the AGENTS.md that vp create wrote"
  chk "slots filled (/factory-start)" "! grep -q '<[A-Za-z].*slot\|<Project name>\|<One paragraph' AGENTS.md" "open Claude Code here and run /factory-start, the Day-0 interview; it fills every <slot>"
  chk "slim knowledge present"        "[ -f docs/factory918/PHILOSOPHY.md ] && [ -f docs/factory918/MANUAL.md ]" "factory918 update restores docs/factory918/"
  chk "glue skills resolve"           "[ -f .agents/skills/factory918/SKILL.md ] && [ -f .agents/skills/factory-start/SKILL.md ] && [ -f .agents/skills/knowledge/SKILL.md ] && [ -f .agents/skills/factory-retro/SKILL.md ]" "factory918 update restores the factory918, factory-start, knowledge and factory-retro skills"
  chk "ledger exists"                 "[ -f docs/agents/ledger.md ]" "factory918 update restores docs/agents/ledger.md"
  chk "ast-grep rules test"           "pnpm sg:test" "vp install (the rule engine is a devDependency), then pnpm sg:test; a rule without a snapshot needs ast-grep test --update-all"
  # Evidence is never committed and nothing prunes it; say when it is old, delete nothing.
  # A directory's mtime moves only when its direct entries change, so a tas
... (8592 more characters, see written/scratchpad/syncchk/repo/factory918.sh)
```

## Other files written (not shown)

scratchpad/syncchk/repo/.claude/settings.json
scratchpad/syncchk/repo/.github/workflows/factory-ci.yml
scratchpad/syncchk/repo/.gitignore
scratchpad/syncchk/repo/.scratch/review/ab47eb9/diff
scratchpad/syncchk/repo/AGENTS.md
scratchpad/syncchk/repo/CLAUDE.md
scratchpad/syncchk/repo/CODING_STANDARDS.md
scratchpad/syncchk/repo/LICENSE
scratchpad/syncchk/repo/README.md
scratchpad/syncchk/repo/SOURCES.md
scratchpad/syncchk/repo/VERSION
scratchpad/syncchk/repo/docs/FACTORY-SPEC-v2.md
scratchpad/syncchk/repo/docs/M0-findings.md
scratchpad/syncchk/repo/docs/agents/domain.md
scratchpad/syncchk/repo/docs/agents/issue-tracker.md
scratchpad/syncchk/repo/docs/agents/ledger.md
scratchpad/syncchk/repo/docs/agents/triage-labels.md
scratchpad/syncchk/repo/docs/knowledge/INDEX.md
scratchpad/syncchk/repo/docs/knowledge/core/CONVERSATION-DIGEST.md
scratchpad/syncchk/repo/docs/knowledge/core/DECISIONS.md
scratchpad/syncchk/repo/docs/knowledge/core/GLOSSARY.md
scratchpad/syncchk/repo/docs/knowledge/core/MANUAL.md
scratchpad/syncchk/repo/docs/knowledge/core/PHILOSOPHY.md
scratchpad/syncchk/repo/docs/knowledge/core/SCENARIO-TABLE.md
scratchpad/syncchk/repo/docs/knowledge/notes/1-matt-pocock/01-preamble.md
scratchpad/syncchk/repo/docs/knowledge/notes/1-matt-pocock/02-who-he-is-brief-relevance-to-manuel.md
scratchpad/syncchk/repo/docs/knowledge/notes/1-matt-pocock/03-philosophy-with-verbatim-quotes-citations.md
scratchpad/syncchk/repo/docs/knowledge/notes/1-matt-pocock/04-the-end-to-end-flow-step-by-step-text-diagram-wh.md
scratchpad/syncchk/repo/docs/knowledge/notes/1-matt-pocock/05-the-six-axes.md
scratchpad/syncchk/repo/docs/knowledge/notes/1-matt-pocock/06-skill-catalog.md
scratchpad/syncchk/repo/docs/knowledge/notes/1-matt-pocock/07-how-the-system-evolved-changelog-releases-what-w.md
scratchpad/syncchk/repo/docs/knowledge/notes/1-matt-pocock/08-setup-install-for-claude-code-exact-commands-fir.md
scratchpad/syncchk/repo/docs/knowledge/notes/1-matt-pocock/09-what-s-opinionated-possible-friction-for-a-begin.md
scratchpad/syncchk/repo/docs/knowledge/notes/1-matt-pocock/10-sources.md
scratchpad/syncchk/repo/docs/knowledge/notes/2-theo/01-preamble.md
scratchpad/syncchk/repo/docs/knowledge/notes/2-theo/02-1-who-he-is-and-why-his-experience-matters-brief.md
scratchpad/syncchk/repo/docs/knowledge/notes/2-theo/03-2-evidence-inventory.md
scratchpad/syncchk/repo/docs/knowledge/notes/2-theo/04-3-his-agents-md-analyzed.md
scratchpad/syncchk/repo/docs/knowledge/notes/2-theo/05-4-his-skills.md
scratchpad/syncchk/repo/docs/knowledge/notes/2-theo/06-5-why-don-t-copy-them.md
scratchpad/syncchk/repo/docs/knowledge/notes/2-theo/07-6-reconstructed-workflow-idea-merge.md
scratchpad/syncchk/repo/docs/knowledge/notes/2-theo/08-7-the-six-axes.md
scratchpad/syncchk/repo/docs/knowledge/notes/2-theo/09-8-t3-code-as-an-encoding-of-his-workflow.md
scratchpad/syncchk/repo/docs/knowledge/notes/2-theo/10-9-timeline-of-how-his-stance-evolved-2024-2026.md
scratchpad/syncchk/repo/docs/knowledge/notes/2-theo/11-10-what-s-reusable-for-a-claude-code-beginner-vs.md
scratchpad/syncchk/repo/docs/knowledge/notes/2-theo/12-11-sources.md
scratchpad/syncchk/repo/docs/knowledge/notes/3-pstack/01-preamble.md
scratchpad/syncchk/repo/docs/knowledge/notes/3-pstack/02-who-she-is-and-why-it-exists-sourced.md
scratchpad/syncchk/repo/docs/knowledge/notes/3-pstack/03-philosophy-the-21-principles.md
scratchpad/syncchk/repo/docs/knowledge/notes/3-pstack/04-the-workflow.md
... and 1027 more


===== OUTPUT R06 =====
## Final message

{BOX}/factory918/.scratch/review/ab47eb9/standards-report.md

## File written: factory918/.scratch/review/ab47eb9/standards-report.md

```
# Standards report

## Would break

1. **The posted design artifact's backticked tokens become pathspecs for `overlap.sh`.** Step 6 now appends a scenario table to the ticket body, and the step-1 matcher skips only a `## Diff` section (`overlap.sh:48`). Every backticked token in the table (`origin/main`, `tests/poteto-mode/overlap.sh`, `.claude/state/program`, `G`) is then passed to `git diff` as a pathspec whenever step 1 runs again on that ticket: a resumed or re-picked-up ticket, an `autopilot-stack` lane re-entering, or a quick ticket routed back through the playbook ("run that playbook's steps verbatim from step 1"). The #42 table itself shows the hazard was known: row 14 says "unbackticked here so this ticket's own check does not trip on it". Nothing in step 6, `issue-tracker.md` or `SCENARIO-TABLE.md` excludes `## Testing decisions` and `## Design` from the matcher.

```
6. ... before implementation the synthesized table is appended to the ticket's body under `## Testing decisions` with `gh issue edit N --body-file`
```
```
  outside="$(printf '%s\n' "$body" | awk '/^## /{skip=($0 ~ /^## Diff[[:space:]]*$/)} !skip')"
```
Documented step: `template/.agents/skills/poteto-mode/playbooks/ticket.md:5` ("Then run `.claude/skills/poteto-mode/scripts/overlap.sh N` ... one line per open PR whose own commits ... touch a path the ticket names in backticks") and `ticket.md:10`.
Result: on a second run of step 1 the design artifact's own vocabulary is matched as paths, so the check prints a spurious `#k <head>: ...` and exits 1, telling the agent to stop and merge an unrelated PR first; a path-shaped token outside the repo exits 2 and blocks the ticket (table row 14).

2. **`MANUAL.md` still tells a project it carries four core documents.** `AGENTS.md` was corrected five → six, and the slim copy count went four → five (`build_core` copies every core document but `CONVERSATION-DIGEST.md`), but the manual's "Where to read more" was not touched. It is itself one of the files every project carries, so the wrong count and the missing entry ship to every project.

```
Everything below lives in the factory clone (`~/.factory918`); a project carries only the first four, under `docs/factory918/`.
```
Documented step: `docs/knowledge/core/MANUAL.md:165-171`, the list a human follows to learn what is in `docs/factory918/`; the standard is `CODING_STANDARDS.md`, Markdown: "A count or a version in prose is true at the commit that lands it".
Result: the reader is told the project carries four documents and is given four names; `docs/factory918/SCENARIO-TABLE.md`, which this change puts in every project, is absent from the one list that enumerates them.

## Fails open

## Standards breaches

3. **`build_knowledge.py`'s own docstring names the four documents it copies.** The diff adds the fifth tuple to `CORE_DOCS` in this file and leaves the header describing the old set. Standard: `CODING_STANDARDS.md`, Markdown: "A count or a version in prose is true at the commit that lands it".

```
                                           then copies PHILOSOPHY, MANUAL, DECISIONS and GLOSSARY (headers
                                           stripped) into template/docs/factory918/ for projects.
```

4. **P25's rationale miscounts where "Ticket step 5" is quoted.** It is quoted in five patches (`bug-fix`, `feature`, `perf-issue`, `refactoring` and `opening-a-pr`), and `review-brief.sh` does not contain the phrase at all (it holds the cross-cutting predicate that step 5 points at, the other direction). The substance of the choice, not renumbering, stands. Same standard as item 3.

```
the rule lives in Ticket step 6 (no renumbering, since "Ticket step 5" is quoted in four patches and `review-brief.sh`)
```

5. **`SOURCES.md:3` is left saying `sync` re-fetches pins and bumps VERSION.** The new finding records that the code does neither and that "the code is the truth", but `SOURCES.md` is edited in this same diff and its wrong sentence stays. Standard: `AGENTS.md`, "Records"/findings-win, and the prose-truth rule in `CODING_STANDARDS.md`.

```
`factory918 sync` will re-fetch these pins, re-apply the patches, and bump VERSION.
```

## Fix alongside

6. **Duplicated Code.** The 46-word writer instruction is pasted verbatim into four playbooks and again into their four patches, eight copies to keep in step. A pointer ("the writer rule in `SCENARIO-TABLE.md`, Where it goes") would hold it in one place.

```
The brief carries the ticket's design artifact (Ticket step 6). When it is a scenario table, the writer writes the test from the table before the implementation, one assertion per cell in the table's order, and the commit order shows it; a writer that cannot implement a cell as written stops and reports the cell, and never fills it in.
```

7. **Shotgun Surgery, half done.** `runner-prompt.md` is runner-facing, but the new first-deliverable rule and the "orchestrator appends the synthesized first deliverable" sentence are orchestrator work. `architect/SKILL.md` Phase B still describes the candidate package as usage-first, and `rationale-template.md` has no home for a table, so an `/architect` run outside the Ticket playbook can synthesize a package with no table and nothing notices.

```
Each candidate produces a design package shaped per `references/rationale-template.md`: the caller's usage written first, then the type sketch, function signatures, module map, and prose rationale derived from it.
```

8. **"the rule above" is an unresolved referent.** The nearest rule above in the list is "Prior art for the tests"; the intended one is four bullets and a section away, and it bans "specific file paths" as well as code snippets, which the new bullet does not answer. The #42 table is mostly backticked paths.

```
It is a decision, not a code snippet, so the rule above does not exclude it.
```

hard findings: 2
```


===== OUTPUT R07 =====
## Final message

{BOX}/factory918/.scratch/review/ab47eb9/standards-report.md

## File written: factory918/.scratch/review/ab47eb9/standards-report.md

```
# Standards report

## Would break

1. **`--body-file` replaces the body the step says it appends to.** Ticket step 6 names a command that overwrites; nothing tells the agent to read the existing body first. `gh issue edit N --body-file f` sets the body to the file, so a file holding only the table drops What to build, Acceptance criteria, Parent and Blocked by, and `review-brief.sh` then pastes a body with no intent in it into the Spec brief. One clause fixes it: read `gh issue view N --json body`, append, write the whole body back.

```
before implementation the synthesized table is appended to the ticket's body under `## Testing decisions` with `gh issue edit N --body-file`
```

Documented step: `template/.agents/skills/poteto-mode/playbooks/ticket.md:6` (and `docs/knowledge/core/SCENARIO-TABLE.md:43`).
Result: the ticket body becomes the table alone; the spec is gone from the ticket and from every later brief.

2. **MANUAL's count of what a project carries is now false, and the sixth document is in neither map.** `CODING_STANDARDS.md`, Markdown: "A count or a version in prose is true at the commit that lands it." A project now carries five slim documents, and `SCENARIO-TABLE.md` appears in no reading list a person is sent to; `PHILOSOPHY.md:64` names the others and omits it too.

```
Everything below lives in the factory clone (`~/.factory918`); a project carries only the first four, under `docs/factory918/`.
```

Documented step: `docs/knowledge/core/MANUAL.md:165-170`.
Result: the reader is told four and finds five, with no line saying when to open the new page.

## Fails open

## Standards breaches

## Fix alongside

3. **Duplicated Code.** The writer paragraph ("The brief carries the ticket's design artifact (Ticket step 6). When it is a scenario table, ... never fills it in.") is pasted verbatim into four playbooks and their four patches. The repo already duplicates the `architect` skip clause the same way, so this follows precedent rather than breaking one.

4. **Divergent Change in Ticket step 6.** The step now holds the spec's seams and the architect artifact's posting rule, and it sits after step 5's "run that playbook's steps verbatim", so the "before implementation" rule is reached on time only through the delegation steps' forward pointer.

5. **Trigger drift.** The to-spec patch's stateful trigger drops "rounds", which the other four statements of the same trigger keep.

hard findings: 2
```


