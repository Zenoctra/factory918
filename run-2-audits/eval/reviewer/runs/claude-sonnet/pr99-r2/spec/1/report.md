## Walk

1. Criterion 1: `SKILL.md` step 5 gains the design-hole definition paragraph (three artifacts, intent outranks a criterion, could-not-run refusal excluded); `review-ladder.md` rung 1 gains the matching sentence, word for word in substance.
2. Criterion 2 (amended by #90 round 1): `spec_rule` is defined once in `review-brief.sh` and echoed into the Standards brief only `if [ -n "$spec" ]`, and unconditionally into the Spec brief (which exists only with a spec); `review-comment.sh` computes `has_spec` from `$dir/spec-brief.md` and `report()` skips the `spec:` scan (`stepless "$f" "^spec: $ref\$"`) when `has_spec` is empty.
3. Criterion 3: `hole: <reference>` is documented as a fourth trailing field; `review-comment.sh` adds `holed()`/`value()`/`specs()` and four refusal checks (no-spec, wrong heading, malformed value, value mismatch) before counting `holes` out of `act-on items:` and printing `restart` when `holes -gt 0`.
4. Criterion 4: `ticket.md` step 8 sends a `restart` comment to a new `### Design hole` section (hole reference, `architect` Phase B, dated amendment, retest, round-one review); `review-brief.sh` slices comment history at the last line-exact `restart` outside fenced text and prints `restart:`; `babysit.md`/`babysit/SKILL.md` gain the byte-identical merge-readiness exception.
5. Criterion 5: `cites:` gains a fourth alternative, `#[0-9]+ '"$ref"'`, sharing the `ref=` grammar with `spec:`/`hole:`, so a cited cell/signature/criterion carries into later briefs as settled.
6. Criterion 6: `tests/spec-review/review-brief.sh` and `review-comment.sh` add fixtures for every table-A and table-B row named in the brief, plus the `fragment()`/`ref=` drift guard and the `no-stale-wording.sh` addition for "Three trailing fields".
7. Criterion 7: the babysit additions are new paragraphs appended after the existing merge-ready sentence; the existing `act-on items: 0` / `round: 3 of 3` condition is untouched, so a PR with no design hole reads exactly as before.

## Would break

## Fails open

## Not asked for

hard findings: 0
