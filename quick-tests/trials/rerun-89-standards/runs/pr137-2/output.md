## Final message

/private/tmp/wsbox/w-20261005-191215-ac4a/factory918/.scratch/review/ab47eb9/standards-report.md

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
