# Arena synthesis note for #93 (architect Phase B)

## Frame (written 2026-09-22 before either candidate was read)

Artifact: the scenario table(s) and Contract for ticket #93, to be posted under `## Testing decisions`.

Runners: `claude:fable@high` and `claude:opus@high` from the sheet (`architect runners`), both read-only, each to its own file under `.scratch/program/93/arch/`. Judge: from the cross-judge pool only if the two diverge on a structural choice.

Rubric, one line each, graded per candidate:

1. Criteria map complete: each of the six criteria names the cell, contract line or prose change that proves it.
2. A PR that ends at round three prints byte-identical comment lines to today, and every existing test assertion stays green.
3. `review-brief.sh` reads the kind of the fixed items and the fix-only fixed point from the previous round's comment (not from the orchestrator's memory), with exact refusal messages for round four after a round with no Would-break fix, for round six, and for a wrong fixed point at round four or five (or a stated reason not to enforce it).
4. No rule compares counts between rounds; step 5's prose is judgment prose with two stops (three: look for the cause; five: stop and report).
5. Smallest diff: each new machine line justified, no new script, vendored files through their patches, one retired phrase for `no-stale-wording.sh`.
6. Table shape per #90 (comment history down, input shape across; one table for the comment script if it changes), every cell as prints / exit / caller, tests one assertion per cell.

Orchestrator's prior, on record so the pick is honest: one new bare-or-count line in the comment printed only when a fixed Act on item rests on a `## Would break` report item, carrying the reviewed HEAD so the next round's fixed point is in the record; `round: N of 5` for rounds four and five; the brief refuses round four or five without that line on the last comment of the previous round, refuses round six always, and refuses a fixed point at round four or five that is not the recorded HEAD.

## Pick

(filled after reading both)

## Grafts and rejections

(filled after reading both)

## Verification

(filled after the writer's tests run)
