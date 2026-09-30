# Standards report, ab47eb9

Prose and patches only; nothing here runs. Checked in a scratch copy: `python3 tools/build_knowledge.py` leaves the tree unchanged, `tools/check_knowledge.py` reports 119 files (INDEX says 119), `./factory918.sh sync` applies all 19 patches including the two new ones and leaves the tree unchanged, and every test script present at this commit passes (`no-stale-wording`, `review-brief`, `review-comment`, `delegation`). Line counts in INDEX and the three core headers match `wc -l`. The `/architect with checkpoint` phrase Ticket step 6 relies on exists at `template/.agents/skills/architect/SKILL.md:48`. `review-brief.sh:222` pastes the whole ticket body, so the issue-tracker claim holds.

## Would break

## Fails open

## Standards breaches

1. **P25 records a fact about `review-brief.sh` that is not true.** The rationale for not renumbering the Ticket playbook says the string "Ticket step 5" is quoted in `review-brief.sh`. It is not: the script's only reference is a comment, "the Ticket playbook says it in words" (`template/.agents/skills/spec-review/scripts/review-brief.sh:183`), and `grep -n "step 5" review-brief.sh` is empty. The four patches do quote it, so the choice stands on its own; the record just names a witness that does not exist. Standard: `CODING_STANDARDS.md`, Commits and pull requests, "a choice to `docs/knowledge/core/DECISIONS.md`", read with Markdown, "true at the commit that lands it". Fix: drop "and `review-brief.sh`" from P25 in `docs/knowledge/core/DECISIONS.md`, rebuild.

```
| P25 | ... Choices made in #89: the rule lives in Ticket step 6 (no renumbering, since "Ticket step 5" is quoted in four patches and `review-brief.sh`); ...
```

2. **`SOURCES.md` line 3 is left saying what the same diff records as false.** The new M0 finding says `sync` "bumps no VERSION and touches no network, against what SOURCES.md line 3 says; the code is the truth". The diff edits `SOURCES.md` (items 13 to 15) and leaves line 3 as it was: "`factory918 sync` will re-fetch these pins, re-apply the patches, and bump VERSION." `cmd_sync`'s own header (`factory918.sh:373-374`) agrees with the finding. Standard: `CODING_STANDARDS.md`, Markdown, "A count or a version in prose is true at the commit that lands it"; `AGENTS.md`, Pull requests, "a finding outside its scope becomes a ticket". Either the one line changes here or a ticket is named in the PR.

```
+2026-09-22. ... factory918.sh sync (0.3.0) bumps no VERSION and touches no network, against what SOURCES.md line 3 says; the code is the truth (#89).
```

3. **`SCENARIO-TABLE.md` carries three Diátaxis modes.** "What it is" and "Why" are explanation, "The shape" and "The #42 example" are reference, "Where it goes" is a how-to with a command in it (`gh issue edit N --body-file`). The other core documents keep to one mode each (PHILOSOPHY explanation, MANUAL how-to, GLOSSARY reference). Standard: `CODING_STANDARDS.md`, Markdown, "One Diátaxis mode per file". The ticket asked for one page with "what it is, the shape, the #42 example", so the breach is by design; the how-to paragraph is the part that could point at Ticket step 6 instead of restating it.

```
+## What it is
...
+## The shape
...
+## Where it goes
+
+On the ticket, before implementation. The Ticket playbook's step 6 appends the synthesized table to the ticket body under `## Testing decisions` with `gh issue edit N --body-file`. ...
+## The #42 example
...
+## Why
```

## Fix alongside

4. **Duplicated Code: the trigger for "has state" is spelled six ways and one drops "rounds".** Ticket step 6, the runner prompt and P25 say "a file it reads or writes, exit codes, rounds, or more than one actor"; the to-spec patch says "a file read or written, exit codes, more than one actor"; INDEX's read-when says "a file, exit codes, more than one actor"; the page's own intro says "review rounds". A planner at `to-spec` will not ask for a table for a design whose state is rounds, which is the one kind of state `spec-review` itself has. One phrase, and the others say "the page defines state".

```
+- For stateful work (a file read or written, exit codes, more than one actor), the shape is the scenario table: ...
```

5. **A posted table feeds `overlap.sh` as pathspecs, and nothing tells the table writer.** `overlap.sh` takes every backticked whitespace-free token in the ticket body outside `## Diff` (`template/.agents/skills/poteto-mode/scripts/overlap.sh:48`). Ticket step 6 appends the table to that body before step 8 runs `overlap.sh N --diff`, and the runner prompt tells cells to carry a legend in backticks. The #42 table already had to work around this ("unbackticked here so this ticket's own check does not trip on it", row 14). A cell token that is a path another open PR touches gives exit 1 naming the PR; an absolute or dot-dot token gives exit 2; both loud, so not a hard finding. One sentence in Ticket step 6 or the runner prompt would spare the next writer the #42 workaround.

```
+... the synthesized table is appended to the ticket's body under `## Testing decisions` with `gh issue edit N --body-file` ...
```

6. **Duplicated Code: the same two-sentence writer rule pasted into four playbooks.** Feature step 4, Bug fix step 3, Refactoring step 5 and Perf issue step 3 each carry the identical "The brief carries the ticket's design artifact (Ticket step 6). When it is a scenario table, the writer writes the test from the table before the implementation ... never fills it in." The existing skip clause set the precedent, and a patch per playbook is how the vendored set is edited, so this is the cost of the layout; the rule itself lives nowhere the four could cite, since Ticket step 6 stops at posting. If it ever changes, five files change.

```
+... The brief carries the ticket's design artifact (Ticket step 6). When it is a scenario table, the writer writes the test from the table before the implementation, one assertion per cell in the table's order, and the commit order shows it; a writer that cannot implement a cell as written stops and reports the cell, and never fills it in.
```

hard findings: 0
