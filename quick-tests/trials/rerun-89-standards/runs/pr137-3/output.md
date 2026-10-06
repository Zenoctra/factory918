## Final message

/private/tmp/wsbox/w-20261005-191215-1c3e/factory918/.scratch/review/ab47eb9/standards-report.md

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
