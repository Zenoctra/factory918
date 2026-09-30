## Walk

1. Criterion 1, the definition: `spec-review/SKILL.md` step 5 gains the design-hole paragraph and `docs/agents/review-ladder.md` rung 1 the same rule in one sentence; both name the three artifacts, the intent-over-criterion rule and the could-not-run exemption.
2. Criterion 2, the `spec:` rule: `review-brief.sh` sets `spec_rule` beside `step_rule` and echoes it one blank line after the step rule in the Spec brief always and in the Standards brief only under `[ -n "$spec" ]`, the same test that writes `spec-brief.md`, so a no-spec brief runs step rule → report path → count rule.
3. Criterion 2, the refusal: `review-comment.sh` sets `has_spec` from `spec-brief.md` before the first `report`, and `report()` runs `stepless "$f" "^spec: $ref$"` after the `Documented step:` scan only with a spec, so table B rows 2 to 4 refuse in the documented order and row 7 asks for nothing.
4. Criterion 3, the mark: `holed()` is the items not ending in a `fixed:`/`ticket:` field that carry `hole:`; the refusals run no-spec, placement, form, then word-for-word against `specs()`'s Nth line, which walks the report in the same order `items()` numbers it; `holes` is subtracted in the count and `restart` prints between the summary and `round:`, so `act-on items:` stays last.
5. Criterion 4, the restart: one awk between the fetch and the round awk keeps the comments after the last bare `restart` line outside fences, prints the cut count, and the shell turns a non-zero cut into the `restart:` line; `top` then reads the sliced history, so round 1 with no `settled:` section, and the fourth-round refusal counts the new series alone (row 7 exits 1 before any state).
6. Criterion 4, the route: Ticket step 8 sends a restart comment to the new **Design hole** section, which scopes `architect` Phase B to the reference, amends the artifact with a dated line, rewrites the tests, then reviews from round one; `babysit.md` and `babysit/SKILL.md` both say such a comment is never merge-ready.
7. Criterion 5, the cite: a fourth alternative `#[0-9]+ $ref` joins the `cites:` group, still `$`-anchored, and the `ref=` line is byte-identical in both scripts, held together by `fragment()`.
8. Criterion 6: `tests/spec-review/` covers table A rows 5 to 8, 11 to 17 and the no-spec brief layout, and table B rows 1 to 7 with the exact refusal strings.
9. Criterion 7: the merge-ready condition for a PR with no `restart` comment is untouched in both babysit files; table B columns A to C keep their old stdout.

## Would break

## Fails open

## Not asked for

hard findings: 0
