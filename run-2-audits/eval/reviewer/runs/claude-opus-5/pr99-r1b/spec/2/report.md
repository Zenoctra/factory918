## Walk

1. Criterion 1, the definition. `SKILL.md` step 5 gains the design-hole paragraph and `docs/agents/review-ladder.md` rung 1 the matching sentence; both name the three artifacts, the intent outranking a criterion, the could-not-run exemption and the sharpness ordering.
2. Criterion 2, the `spec:` line. `review-brief.sh` sets `spec_rule` beside `step_rule` and echoes it one blank line after it in the Standards brief only when `$spec` is non-empty and always in the Spec brief; `review-comment.sh` sets `has_spec` from `spec-brief.md`, and `report()` reuses `stepless()` with `^spec: $ref$` after the `Documented step:` scan, skipping it with no spec.
3. Criterion 3, the mark. `holed()` selects judgment lines carrying `hole:` that do not end in a well-formed `fixed:`/`ticket:` field; the checks run no-spec, then placement, then form, then value against `specs()`; `holes` is subtracted in the count and `restart` is echoed after the summary and before `round:`.
4. Criterion 4, the restart. `review-brief.sh` slices `bodies` to the comments after the last comment holding a line exactly `restart` outside fences, prints `restart: …` between `ticket:` and `round:`, and derives `top`, `settled:` and the fourth-round refusal from the slice alone; with no restart the slice returns every raw line, so the old refusals fire unchanged. The Ticket playbook gains the step-8 pointer and the `### Design hole` section; babysit's SKILL and playbook gain the not-merge-ready sentence.
5. Criterion 5, the cite. `review-brief.sh`'s `cites` regex gains `#[0-9]+ $ref` as a fourth `$`-anchored alternative, sharing the `ref=` line the test pins against `review-comment.sh`'s copy.
6. Criterion 6, the tests. `review-comment.sh` covers rows 1A–1G, 2, 3, 4, 5A/5D–5G, 6, 7A/7D and the two-holes, last-field and rerun notes; `review-brief.sh` covers A5–A8, A11, A12, A13, A14–A16, A17, the `spec_rule` anti-drift and layout pins with and without a spec, and the `--round 4` refusal.
7. Criterion 7, babysit. Columns A to C print exactly as before; the merge-ready condition gains only the restart clause, and `no-stale-wording.sh` blacklists `Three trailing fields`.

## Would break

## Fails open

## Not asked for

hard findings: 0
