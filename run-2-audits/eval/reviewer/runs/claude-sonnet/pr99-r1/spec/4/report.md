## Walk

1. Design-hole definition (AC1): `spec-review/SKILL.md` step 5 and `review-ladder.md` rung 1 both carry the three-artifact definition, the intent-outranks-criterion clause and the could-not-run exception, word for word in both places.
2. `spec:` line requirement (AC2): `review-comment.sh`'s `report()` calls `stepless "$f" "^spec: $ref\$"` after the step check, refusing any counted item lacking a well-formed `spec:` line; `review-brief.sh` writes `spec_rule` into both briefs after `step_rule`.
3. `hole:` mark (AC3): `review-comment.sh` treats `hole: <ref>` as a fourth trailing field via `holed()`/`ending`, refusing it outside Act on, in no form, or differing word-for-word from the item's `spec:`.
4. Never fixed on the PR / restart (AC4): a hole prints `restart` and is excluded from the count; `review-brief.sh` slices the comment history at the last exact `restart` line (fenced/prose/trailing-text lines excluded) and prints `restart:`; `ticket.md` gains a Design hole section and a step-8 pointer.
5. `cites:` fourth form (AC5): `review-brief.sh`'s `cites=` regex gains `#[0-9]+ $ref` as a fourth alternative, carrying a cell/signature/criterion citation as settled.
6. Tests (AC6): `tests/spec-review/review-brief.sh` and `review-comment.sh` add rows for a missing `spec:`, each reference form, a hole on a non-Act-on/malformed/mismatched item, the restart slicing (rows 5-8, 11-13), and a citation carrying forward (rows 14-17).
7. Babysit unaffected on no-hole PRs (AC7): the new babysit sentences are pure additions after the existing merge-ready text in both the patch and the template copies, and the patches keep byte-identical wording between `babysit.md` and `babysit/SKILL.md`.

## Would break

## Fails open

## Not asked for

hard findings: 0
