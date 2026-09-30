# Spec review brief

Read nothing beyond this brief unless a finding needs the code around a hunk, and then read that one function or section, not the file. Run nothing.

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

Write your report to `.scratch/review/ab47eb9/spec-report.md` and reply with only that path.
End the report with exactly one line `hard findings: N`, where N is the number of items under `## Would break` and `## Fails open` and nothing else.
