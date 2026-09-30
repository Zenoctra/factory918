## Walk

1. Criterion 1 (definition): `spec-review/SKILL.md` step 5 and `docs/agents/review-ladder.md` rung 1 both carry the design-hole definition (three artifacts, intent outranks a criterion, a could-not-run refusal is not a hole), word for word matching each other and the ticket text.
2. Criterion 2 (`spec:` line): `review-brief.sh` writes `spec_rule` into both briefs only when a spec is in hand (`spec-brief.md` written); `review-comment.sh`'s `report()` calls `stepless "$f" "^spec: $ref\$"` only when `has_spec` is set, and a review with no spec counts an item with no `spec:` line instead of refusing it (table B row 7, tested).
3. Criterion 3 (`hole:` mark): `holed()` extracts a trailing `hole:` field the same way `ending` excludes a trailing `fixed:`/`ticket:`; `review-comment.sh` checks no-spec first, then heading (G), then form (E), then the `spec:` match (F), in that order, and prints `restart` and subtracts `holes` from the count.
4. Criterion 4 (restart): the Ticket playbook's new **Design hole** section scopes the redesign to the reference and amends the ticket with a dated line; `review-brief.sh`'s restart-slicing awk drops every comment at or before the last `restart` line and prints `restart:`; babysit's stop condition and `MANUAL.md` both gain the same clause.
5. Criterion 5 (`cites:`): the fourth alternative `#[0-9]+ $ref` is appended to `review-brief.sh`'s `cites=` regex, sharing `$ref` with `review-comment.sh` (`fragment()` in the test pins both `fenced=` and `ref=` identical).
6. Criterion 6 (tests): `tests/spec-review/review-brief.sh` and `review-comment.sh` add the rows the ticket's tables enumerate (5–17 for briefs; 1D–G, 2–7 for comments), each pinning exact stdout or the exact refusal text.
7. Criterion 7 (babysit unchanged): the new paragraph in `babysit.md`/`babysit/SKILL.md` is additive text after the existing stop condition; a PR with no `restart` comment reads exactly as before.

## Would break

## Fails open

## Not asked for

hard findings: 0
