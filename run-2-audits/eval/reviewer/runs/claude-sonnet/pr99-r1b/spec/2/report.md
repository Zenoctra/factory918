## Walk

1. Criterion 1 (design-hole definition): `SKILL.md` step 5 gains the paragraph defining a hole as a fix that changes the scenario table, the `## Design` sketch, or an acceptance criterion, with intent outranking a criterion and a could-not-run refusal excluded; `review-ladder.md` rung 1 gets the matching sentence. Both read word for word as the ticket's contract prescribes.
2. Criterion 2 (`spec:` line, spec-conditional): `spec_rule` is defined and echoed in both briefs one blank line after `step_rule`, only when `$spec` is set; `report()` in `review-comment.sh` runs the `spec:` scan (`stepless "$f" "^spec: $ref\$"`) only when `has_spec` is set, after the `Documented step:` scan.
3. Criterion 3 (`hole:` mark and count): `holed()`, `value()`, and the ordered refusal chain (no-spec catch-all, then placement outside Act on, then malformed form, then value mismatch) implement columns D–G of table B; `holes` is subtracted from `act-on items`, and `restart` is printed before `round:` when any hole exists.
4. Criterion 4 (never fixed on the PR, restart plumbing): `poteto-mode/playbooks/ticket.md` adds the `### Design hole` section and the step-8 pointer; `review-brief.sh` slices comment history at the last exact `restart` line via the new awk block, prints `restart:`, and resets the round/settled computation to the sliced history; `babysit.md`/`babysit/SKILL.md` gain the byte-identical merge-readiness carve-out.
5. Criterion 5 (`cites:` fourth form): `review-brief.sh`'s `cites` regex gains the `#[0-9]+ $ref` alternative, reusing the shared `ref=` grammar also used by `review-comment.sh` for `spec:`/`hole:`.
6. Criterion 6 (tests): `tests/spec-review/review-brief.sh` covers rows A5–A8, A11–A17 and the spec-rule layout; `tests/spec-review/review-comment.sh` covers table B rows 1–7 including the two-holes, last-field-wins, and rerun-after-state-cleared cases.
7. Criterion 7 (babysit unaffected on a clean PR): the added sentence is additive; the existing `act-on items: 0` check and columns A–C of table B are untouched by this diff.

Traced the reference grammar, the restart-slicing awk, the `holed`/`value`/`specs` helpers in `review-comment.sh`, and the corresponding fixtures against the scenario tables in the ticket's `## Testing decisions`; the check order in each script (count → step → spec; no-spec → placement → grammar → value) matches the check-order sentence in `SKILL.md` and the contract. `SOURCES.md`, both patches, and their templates carry identical prose.

No discrepancy found between the diff and the ticket's tables, contract, or prose instructions.

hard findings: 0
