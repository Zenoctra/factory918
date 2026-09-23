## Walk

1. Criterion 1, the definition: `spec-review/SKILL.md` step 5 gains the design-hole paragraph (three artifacts, intent over criterion, the could-not-run carve-out) and `docs/agents/review-ladder.md` rung 1 gains its one-sentence twin; the patch carries both.
2. Criterion 2, the `spec:` rule: `review-brief.sh` gains `spec_rule`, echoed one blank line after `$step_rule` in both briefs but only inside `if [ -n "$spec" ]`, the same test that writes `spec-brief.md`, so a no-spec Standards brief runs step rule -> report path -> count rule.
3. Criterion 2, the refusal: `review-comment.sh` sets `has_spec` from `$dir/spec-brief.md` before the Standards report is read; `stepless()` now takes the required regex and `report()` calls it twice, step first, `^spec: $ref$` second, and returns early with no spec.
4. Criterion 3, the mark: `holed()` takes judgment item lines not ending in a well-formed `fixed:`/`ticket:` field that contain `hole:`; the checks run no-spec, then placement outside Act on, then form (`hole: $ref$`), then word-for-word equality with `specs()`'s value for the named report item. `holes` is subtracted in the count and `echo restart` lands between the summary and `round:`.
5. Criterion 4, the reset: one awk between the `gh` fetch and the round awk keeps only the lines whose comment index exceeds the last comment holding a bare `restart` outside fenced text, prints the cut count, and sets `restarted`; the `restart:` line prints after `ticket:` and before `round:`. `top`, `settled:` and the fourth-round refusal all read the sliced history, so a PR with no restart behaves exactly as before.
6. Criterion 4, the playbooks: `ticket.md` step 8 points at the new `### Design hole` section (six steps, no step renumbered); the babysit sentence is byte-identical in `poteto-mode/playbooks/babysit.md` and `babysit/SKILL.md` after the list prefix, and both patches plus `SOURCES.md` items 4, 6 and 12 match.
7. Criterion 5, the cite: a fourth alternative `#[0-9]+ $ref` joins the `cites:` group, still `$`-anchored; `fragment()` now holds the `ref=` line of both scripts together.
8. Criterion 6, the tests: table A rows 5 to 8, 11 to 17 and the `--round 4` refusal; table B rows 1 (A to G), 2, 3, 4, 5 (A, D, E, F, G), 6, 7 and the three notes; `no-stale-wording.sh` blacklists `Three trailing fields`, which survives nowhere under `template/` or `docs/knowledge/core/`.
9. Criterion 7: table B columns A to C print exactly as today, and `holed()`'s exclusion keeps `holes` disjoint from `fixed_here` and `ticketed`, so the count cannot go negative and a no-hole PR reads as before.

## Would break

## Fails open

## Not asked for

hard findings: 0
