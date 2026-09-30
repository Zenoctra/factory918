## Walk

1. `spec-review/SKILL.md` step 5 and `docs/agents/review-ladder.md` rung 1 both carry the design-hole definition word for word: a finding is a hole when its fix changes the scenario table, the `## Design` sketch or an acceptance criterion, rather than the code; a criterion yields to the ticket's intent; a could-not-run refusal is not a hole.
2. `review-brief.sh` and `review-comment.sh` share one `ref=` grammar line (`table <row>/<column>`, `design <signature>`, `criterion <k>`), held together by `tests/spec-review/review-brief.sh`'s `fragment()`.
3. In a review with a spec (`<dir>/spec-brief.md` present), `report()` requires a `spec:` line on every `## Would break`/`## Fails open` item via `stepless "$f" "^spec: $ref\$"`, echoing `spec_rule` in both briefs one blank line after `step_rule`; with no spec, neither the rule nor the check applies.
4. `holed()` finds an Act on item's trailing `hole:` field (text from the last `hole:` to end of line, excluded when the line ends in `fixed:`/`ticket:`); `review-comment.sh` refuses it in a no-spec review, under any heading but Act on, in no form, or differing from the item's own `spec:` line (via `specs()`), in that order.
5. A well-formed `hole:` is subtracted from `act-on items:` alongside `fixed_here`/`ticketed`, and the line `restart` prints before `round:` when any item is holed.
6. `review-brief.sh` slices the fetched comment history at the last exactly-`restart` line (outside fenced text), printing `restart:` and reading the round and settled set only from what follows; the fourth-round refusal counts the new series alone.
7. `cites:` gains a fourth form, `#N <reference>`, carried into `## Settled in earlier rounds` in both briefs like the other three.
8. `poteto-mode/playbooks/ticket.md` gains a **Design hole** section (step 8 routes there on a `restart` line) that scopes `architect` Phase B to the cell/signature/criterion, amends the ticket with a dated line, and restarts review from round one; `babysit.md` and `babysit/SKILL.md` gain a byte-identical paragraph that a `restart` comment is never merge-ready.
9. `tests/spec-review/review-brief.sh` and `review-comment.sh` exercise the scenario table's cells: the no-spec layout, each malformed `spec:`/`hole:` form, the three reference kinds, restart rows 5–8 and 11–17, and the fenced/prose/trailing-text non-restart cases.

## Would break

## Fails open

## Not asked for

hard findings: 0
