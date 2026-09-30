# Standards report, ab47eb9

The change is prose and patches; no shell or Python logic moved (one tuple in `CORE_DOCS`). The knowledge build, the sync replay and the stale-wording test are CI's, so they are skipped. Both `docs/agents/issue-tracker.md` copies are identical, the ledger line keeps the four-field shape, the M0 finding's three claims (`build_core` copies all but the digest, `doctor` checks only PHILOSOPHY and MANUAL, `cmd_sync` touches no network) hold against `tools/build_knowledge.py:125-138` and `factory918.sh:275,372-399`, and `review-brief.sh:333-335` does paste the ticket body whole, so the "spec from then on" claim is true.

## Would break

## Fails open

## Standards breaches

1. **The writer rule has five sources of truth.** `CODING_STANDARDS.md` "Markdown": agent-read prose is written with `/writing-for-agents`, whose rule at `template/.agents/skills/writing-for-agents/SKILL.md:78` is "Keep each meaning in a single source of truth: one authoritative place, so changing the behaviour is a one-place edit." The same two sentences land verbatim in `feature.md` step 4, `bug-fix.md` step 3, `refactoring.md` step 5, `perf-issue.md` step 3 and `SCENARIO-TABLE.md` "Where it goes"; the state definition "(a file it reads or writes, exit codes, rounds, or more than one actor)" appears in eight files. A change to either is a five- or eight-place edit across four patches, a playbook the sync keeps, two core documents and a template doc. One home (Ticket step 6, which every playbook runs under, or the page) with a pointer from each playbook is the one-place edit.

```
+3. Plan the fix. ... The brief carries the ticket's design artifact (Ticket step 6). When it is a scenario table, the writer writes the test from the table before the implementation, one assertion per cell in the table's order, and the commit order shows it; a writer that cannot implement a cell as written stops and reports the cell, and never fills it in.
```

2. **The architect skill's two files now disagree on what a candidate leads with.** Same standard. The runner prompt says the first deliverable for a design with state is the table, then the contract, then the test list; `template/.agents/skills/architect/SKILL.md:32` still tells the orchestrator "Each candidate produces a design package shaped per `references/rationale-template.md`: the caller's usage written first, then the type sketch...", and line 84 repeats "The caller's usage is written first". The orchestrator reads `SKILL.md`, the runner reads the prompt; the discipline axes the orchestrator compares on (runner prompt, "Apply the following discipline") do not name the table, and `rationale-template.md` has no slot for it. `patches/series` carries no `architect/SKILL.md` patch.

```
+- With state (a file it reads or writes, exit codes, rounds, or more than one actor): a scenario table, then the contract derived from it, then the test list.
```

## Fix alongside

3. **A line the diff records as false is left standing.** `docs/M0-findings.md` gains "sync (0.3.0) bumps no VERSION and touches no network, against what SOURCES.md line 3 says; the code is the truth", and the same diff edits `SOURCES.md` without touching line 3, which still reads "`factory918 sync` will re-fetch these pins, re-apply the patches, and bump VERSION." `AGENTS.md` and `factory918.sh:372-374` say the opposite. Judgement call under "A count or a version in prose is true at the commit that lands it".

```
+2026-09-22. ... factory918.sh sync (0.3.0) bumps no VERSION and touches no network, against what SOURCES.md line 3 says; the code is the truth (#89).
```

4. **A new gh operation outside the conventions list.** `docs/agents/issue-tracker.md` "Conventions" opens "Use the `gh` CLI for all operations" and lists create, read, list, comment, label, close. Ticket step 6 introduces `gh issue edit N --body-file` and the "Ticket body" paragraph describes the edit without naming the command; the list is where an agent looks for it.

```
+... the synthesized table is appended to the ticket's body under `## Testing decisions` with `gh issue edit N --body-file`, first line `Posted by the agent <date>` ...
```

5. **The body's readers list omits `overlap.sh`.** `overlap.sh:47-50` takes every backticked token outside `## Diff` as a pathspec, and `issue-tracker.md:18` names the Ticket playbook, `spec-review`, `interrogate` and the quick-ticket path as the body's readers. A table's legend and a `## Design` sketch are backticked vocabulary and signatures; a second run of the ticket (the documented case, #42, whose row 14 already dodges its own check) or an autopilot-stack owner lane runs step 1 against them. Rows 13 and 14 of the #42 table make the outcome loud or empty, so not a hard finding, but the paragraph should say the new sections feed the overlap check or that step 1 skips them.

```
+The architect step may append two more sections before implementation, after these: `## Testing decisions`, the scenario table, when the design has state; `## Design`, the usage and signature sketch ...
```

6. **The marker names no model.** P22 makes the agent's signature on anything posted from the author's account "the model and harness"; the body sections get `Posted by the agent <date>`, so the ledger's per-model lines and P25's own "PR #92's found 2, 1, 2" have no way to tell which model wrote a table. Judgement call: P22 speaks of comments.

```
+Their first line is `Posted by the agent <date>` or `Approved by <name> <date>` (the Ticket playbook, step 6).
```

hard findings: 0
