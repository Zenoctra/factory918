## Walk

1. Criterion 1 (design-hole definition): `SKILL.md` step 5 and `review-ladder.md` rung 1 both state the three-artifact definition (table cell/term, `## Design` signature, acceptance criterion), the intent-outranks-criterion clause, the could-not-run exclusion, and the sharpest-to-softest detection note, word for word between the two.
2. Criterion 2 (`spec:` line): `spec_rule` is defined once in `review-brief.sh`, echoed one blank line after `step_rule` in both briefs only when `$spec` is set, and `report()` in `review-comment.sh` calls `stepless "$f" "^spec: $ref\$"` only when `has_spec` is set, refusing an uncited counted item with the exact message from the ticket.
3. Criterion 3 (`hole:` field and count): `holed()` excludes a line ending in `fixed:`/`ticket:`, then greps for `hole:`; refusals fire in the order no-spec, outside-Act-on, malformed, mismatched; `holes` is subtracted from `act-on items:` and `restart` is printed between the summary and `round:`.
4. Criterion 4 (restart returns to architect): the Ticket playbook's new **Design hole** section runs before step 9; `review-brief.sh` slices `bodies` to everything after the last exact `restart` line (CR/trailing-blank stripped the same way `split` strips them, so the strip runs before the exact-match check), prints `restart:`, and resets `top` to count only the sliced comments; babysit and its two vendored copies gain the byte-identical stop clause.
5. Criterion 5 (`cites:` fourth form): `cites=` in `review-brief.sh` gains the `#[0-9]+ $ref` alternative inside the existing anchored group; `review-comment.sh` never reads `cites:` and `review-brief.sh` never reads `hole:`.
6. Criterion 6 (tests): `tests/spec-review/review-comment.sh` and `review-brief.sh` add fixtures for every table B column and table A restart row (5–8, 11–17), plus the `fragment()` twin check now covering the shared `ref=` line.
7. Criterion 7 (babysit unaffected): table B columns A–C keep the pre-existing stdout for a PR with no hole; the added babysit paragraph fires only on a `restart` line.

## Would break

## Fails open

## Not asked for

hard findings: 0
