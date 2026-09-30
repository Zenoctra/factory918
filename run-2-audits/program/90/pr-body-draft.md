## Why

The review playbook had one route for a finding: fix it on the PR, up to three rounds. A finding whose fix changes the artifact the work was built against, a cell of the ticket's scenario table, a signature in its `## Design` sketch or an acceptance criterion, is a different thing: the rounds so far graded a design that no longer exists. On PR #87 the core of a script was redesigned in each of three fix rounds without returning to `architect`, and each rewrite gave the next round new surface. Manuel's decision on #90: a design hole found in review starts all three reviews over, and the redesign goes through `architect`, not a fix lane.

This PR gives the review that second route. Every counted finding now names what it rests on (`spec: table <row>/<column>`, `spec: design <signature>` or `spec: criterion <k>`); the judgment can mark an Act on item `hole: <reference>`; the comment then carries the line `restart`, which `review-brief.sh` reads on the next run to start the count at round one with nothing carried; the Ticket playbook returns the work to `architect` Phase B scoped to that cell, signature or criterion; and a decision resting on a cell, a signature or a criterion is citable (`cites: #N table <row>/<column>` and its two siblings) so it carries as settled. The mechanism was designed from a scenario table that is the ticket's `## Testing decisions`, and the tests were written from it before the scripts.

## Tradeoffs

- A restart drops every settled item, including one cited to a `user:` quote or a `DECISIONS.md` row the redesign did not touch, in exchange for one rule with no exceptions: the history is what follows the last restart comment. A decision still needed is cited again in the new round one and carries from its round two.
- `hole:` repeats the reviewer's `spec:` reference word for word instead of deriving it, because the criterion fixes the grammar; the equality check keeps the copy honest, and a judge who disagrees with the reference sends the report back, the existing route for an off-shape report.
- A restart comment's `act-on items:` can read 0 (the hole left out of the count, as the ticket asks), so one sentence in the two babysit files says a comment carrying `restart` is never merge-ready; the two existing merge-ready sentences are byte-identical, which is criterion 7.
- `restart` prints between the summary and `round:`, not last, so `act-on items:` stays the last line every reader of the comment depends on.
- The rule "two runners; the judge is skipped when they converge" lives in the Ticket playbook's Design hole section, not in `arena`, which has no patch today and would gain one for a sentence about this transition alone.

## Blast Radius

Not a cross-cutting diff: no path under `.claude/hooks/`, no `settings.json`, nothing under the `factory918` skill (`review-brief.sh:189` is the predicate), so the review brief needs no grounding section. What the change reaches, as read before writing it:

- Every review, in this repository and in every applied project: `review-brief.sh` writes one more rule into both briefs and prints one more line (`restart:`) only after a restart; `review-comment.sh` refuses a counted item without a `spec:` line, which is the one new refusal a clean round can meet, with a message naming the three forms. A reviewer that writes reports today gains one line per hard finding.
- Babysit and the merge read (`babysit.md`, `babysit/SKILL.md`, `review-ladder.md`, the MANUAL's "act-on items: 0"): unchanged for a PR with no hole; a comment carrying `restart` is now named as not merge-ready.
- The Ticket playbook: step 8 gains a pointer and a new section after Quick ticket; no step is renumbered.
- `sync`: `spec-review/SKILL.md`, `babysit.md` and `babysit/SKILL.md` change through their patches; `./factory918.sh sync` leaves the tree clean (verified below).

The one fact it is safe because of: a PR with no `hole:` mark and no `restart` line takes exactly the paths it took before. `review-brief.sh`'s slice is a no-op when no comment carries `restart` (the round awk and the settled awk read the same `bodies` as before), and `review-comment.sh` prints the same tail (`round:` then `act-on items:`) with `holes` equal to 0. Proven by every pre-existing assertion in both test files passing unchanged (the exact-stdout `accept` cases and the round tests), rung 4.

Risks:
1. A reviewer on an older brief writes no `spec:` line and is refused; the message names the three forms. Cost: one rerun of that reviewer in the same round. Likely once per project on the first review after upgrading.
2. `design <signature>` accepts any text after `design `, so a typo in a signature is a well-formed reference; the equality check catches a mismatch between reviewer and judge, not a wrong signature they agree on.

Cleared: the `## Report` layout the brief test pins (definition, blank, first quote; report path then count rule) is unchanged, `spec_rule` prints one blank line after `$step_rule`; `cites:` remains the last field on its line, the new alternative sits inside the existing anchored group; the delegation and mode hooks read `.claude/state/review/` as before, the scripts write and clear the same files.
