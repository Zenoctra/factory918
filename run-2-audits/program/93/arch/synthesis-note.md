# Arena synthesis note for #93 (written after reading both candidates end to end)

## Convergence

Both candidates, and the orchestrator's prior, land on the same shape: one conditional line in the comment carrying "a Would-break item was fixed" and the commit the round reviewed; `<dir>/reviewed` written by `review-brief.sh` beside `<dir>/round` (the only moment HEAD is knowable); the kind read in `review-comment.sh` through `specs()` (the two lines the `hole:` path already runs); the brief gating rounds four and five on the deciding comment's line and refusing a fixed point that is not the recorded commit; a fix-only paragraph in both briefs; restart wins over the line; `at most three rounds` retired through `no-stale-wording.sh`. That is structural convergence, so no cross-judge was dispatched (the frame's rule: a judge only on a structural divergence). The divergences below are point choices inside the one shape, each settled by a principle.

## Pick

Base: the fable candidate. Rubric: (1) both complete; (2) fable names all three moved assertions (`:367-381`, `:685-690`, `:719-724`) with their cells, opus misses the third; (3) both read kind and sha from the comment with exact refusals, fable adds `FR`, `FP`, `FT`, opus adds `D5` and a precise `--round` rule; (4) both; (5) opus is smaller on the cap (by round only) and on the ticket warning, fable larger on `3 of 5` and `FT`; (6) both in #90's shape, fable's table B columns for `<dir>/reviewed` states are the right axis, opus's no-spec column is worth keeping.

## Grafts from opus

- The cap depends on the round only: `cap=3; [ "$round" -le 3 ] || cap=5`, the same line in both scripts, pinned together by `fragment()`. Rejected fable's `3 of 5` at a round-three comment with a Would-break fix: it makes the digit depend on the judgment and gives the two scripts two derivations, while babysit needs the line-based clause anyway for a Would-break fix at round one or two (single source of truth; laziness).
- The line is never printed beside `restart`: a comment carries one or the other. Rejected fable's row 5 (both lines): the slice drops the comment anyway, and a comment telling a human two things is a worse artifact than one condition.
- The `<dir>/reviewed` refusal fires before any output, where every other refusal fires.
- A malformed line (the prefix with anything but a 40-hex id after it) is refused by the brief with the value shown (`FM`), not treated as "no line" and sent down the fourth-round refusal: that path would be the bug this ticket removes, one round later.
- The `--round` rule is precise: a round past three runs only as the round after a comment carrying the line (`round == top + 1`); `--round 5` after a round-three line is refused.
- The fix-only paragraph tells the reviewer to walk only the steps the fix commits touch (otherwise the Spec walk reports every criterion missing against a two-commit diff).

## Kept from fable over opus

- One line form, `would-break fixed after <sha>`, at every round; the round number is the discriminator and the babysit sentence says what `round: 5 of 5` with the line means. Rejected opus's second "stop form": a second string and a second branch for a fact the round number already carries.
- `FT`: a fix-only round with no ticket while the previous round had a spec is refused, not warned; the fix commits rarely name the ticket, and a hard-bug fix reviewed on the Standards axis alone is the silent path (direction of failure). `had_spec` is one awk match on the deciding comment.
- `## The fix under review` carries the deciding comment's fixed Act on lines verbatim, so the fix-only reviewer reads each fix against its item; opus's paragraph alone leaves the reviewer with commit messages.
- `<dir>/reviewed` is validated (40 lowercase hex), one refusal covering missing and malformed, with the content shown.
- The sweep form after a Would-break line is refused by the existing fixed-point check (`paths` is not the commit), zero code.
- At `round: 5 of 5` the orchestrator marks the PR unfinished with `gh pr ready --undo` (a draft) and posts the report as its own comment; the line is the machine block, the draft the human-visible one. Recorded as a Provisional decision; if the guard hook blocks the command, the line alone is the block.

## Rejected from both

- Fable's `RB` as a separate message: merged into one refusal.
- Opus's warning-and-continue on a missing ticket (see `FT`).
- Fable's `round: 3 of 5`.
- Opus's two line forms.

## Verification

(filled after the writer's tests run)
