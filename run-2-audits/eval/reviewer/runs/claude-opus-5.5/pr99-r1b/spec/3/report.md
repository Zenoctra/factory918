## Walk

1. Criterion 1: `spec-review/SKILL.md` step 5 and review-ladder rung 1 carry the three-artifact definition, the intent-outranks-criterion rule, the could-not-run exclusion and the sharp/soft detection sentence, as the contract words them.
2. Criterion 2 (amended): `spec_rule` is echoed after `step_rule` in the Spec brief and, only when `$spec` is set, in the Standards brief; `review-comment.sh` reads `has_spec` from `spec-brief.md` before checking reports and runs `stepless "$f" "^spec: $ref\$"` only with a spec, after the step refusal.
3. Criterion 3: `holed()` finds Act on lines with `hole:` not ending in `fixed:`/`ticket:`; refusals run in the contract order (no spec, placement, grammar, value against `specs()`); `holes` is subtracted and `restart` is echoed after the summary and before `round:`.
4. Criterion 4: `ticket.md` step 8 points to a new `### Design hole` section after Quick ticket, with the six steps as briefed; `review-brief.sh` slices the comments after the last exact, unfenced `restart` line, prints the `restart:` line between `ticket:` and `round:`, and leaves the three-round refusal to run over what remains.
5. Criterion 5: `cites:` gains `#[0-9]+ $ref` inside the anchored group; `ref=` is spelled the same in both scripts.
6. Criterion 6: the tests cover rows A5–A8, A11–A17, B rows 1–7 with columns D–G, the spec-rule layout, and the fragment anti-drift check.
7. Criterion 7: the babysit sentence is added as one new paragraph and one new bullet, with the same text in each, through both patches; the existing merge-ready text is unchanged.

## Would break

## Fails open

## Not asked for

1. **`title()` helper and `ref` renamed to `ref_id`.** The step refusal's inline sed moved into `title()`, and the judgment loop's `ref` became `ref_id` so that it does not shadow the new grammar variable. The refactor supports the new refusals, and the messages it produces are the same as before.

```
`stepless()` takes the required line's regex as a parameter and is called twice
```

hard findings: 0
