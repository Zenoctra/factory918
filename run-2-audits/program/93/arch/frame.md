# Arena frame for #93 (architect Phase B), written 2026-09-22 before any candidate was read

Artifact: the design package for ticket #93, whose first deliverable is the scenario table(s) and Contract to be posted under `## Testing decisions`, then the rationale per `rationale-template.md`.

Runners: `claude:fable@high` and `claude:opus@high` from the sheet (`architect runners`), both read-only, each to its own file under the worktree's `.scratch/program/93/arch/`: `candidate-fable.md`, `candidate-opus.md`. Effort cannot be set per Agent call; high is the requested effort on record. Judge: from the cross-judge pool (`claude:opus@xhigh`, `claude:fable@high`), one read-only lane, only if the two candidates diverge on a structural choice; convergence needs no judge.

Rubric, graded per candidate:

1. Criteria map complete: each of the six criteria names the cell, contract line or prose change that proves it.
2. A PR that ends at round three prints byte-identical comment lines to today, and every existing test assertion stays green (or the candidate names which assertion moves and why a cell requires it).
3. `review-brief.sh` reads the kind of the fixed items and the fix-only fixed point from the previous round's comment, not from the orchestrator's memory, with exact refusal messages for round four after a round with no Would-break fix, for round six, and for a fixed point at round four or five that is not the recorded commit (or a stated reason not to enforce it).
4. No rule compares counts between rounds; step 5's prose is judgment prose with two stops (three: look for the cause; five: stop and report), and the round-five stop is readable by babysit as a wait for the human, not a blocker to fix.
5. Smallest diff: each new machine line justified, no new script, vendored files through their patches, one retired phrase for `no-stale-wording.sh`, the reviewed commit recorded once and derived, not synced.
6. Table shape per #90 (comment history down, input shape across; a second table for the comment script if it changes), every cell as prints / exit / caller, tests one assertion per cell naming their fixture state.

Orchestrator's prior, on record so the pick is honest: one new line in the comment, printed only when a fixed Act on item rests on a `## Would break` report item, carrying the HEAD the round reviewed (written by `review-brief.sh` at brief time into the review dir, printed by `review-comment.sh`) so the next round's fixed point is in the record; the `round:` line reads `of 3` through round three and `of 5` at rounds four and five; the brief refuses round four or five unless the last comment carries that line, refuses round six always, and refuses a fixed point at round four or five that does not resolve to the recorded commit; babysit gains one sentence: a comment carrying that line is not review-ready whatever its count, and a `round: 5 of 5` comment with a nonzero count waits for the human.

## Pick

(filled after reading both)

## Grafts and rejections

(filled after reading both)

## Verification

(filled after the writer's tests run)
