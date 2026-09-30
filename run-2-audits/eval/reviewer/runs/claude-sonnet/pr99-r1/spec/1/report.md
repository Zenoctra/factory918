## Walk

1. Criterion 1: the design-hole definition (three artifacts, criterion outranked by intent, could-not-run exemption) is added to `spec-review/SKILL.md` step 5 and to `docs/agents/review-ladder.md` rung 1, word for word in both diff hunks.
2. Criterion 2: `spec_rule` is defined once in `review-brief.sh` and echoed at both brief call sites, with its word-for-word twin added to `SKILL.md` step 4; `report()` in `review-comment.sh` now calls `stepless "$f" "^spec: $ref\$"` after the step check.
3. Criterion 3: `hole: <reference>` is documented as a fourth trailing field in `SKILL.md`; `review-comment.sh` checks it (heading, form, word-for-word match against the item's `spec:`) and prints `restart` and drops it from the count.
4. Criterion 4: the Ticket playbook's new `### Design hole` section and step 8 pointer route a `restart` comment back to `architect`; `review-brief.sh` slices the comment history at the last exact `restart` line and prints `restart:`.
5. Criterion 5: `review-brief.sh`'s `cites` pattern gains the fourth `#N <reference>` alternative.
6. Criterion 6: `tests/spec-review/review-brief.sh` and `review-comment.sh` add cases for each table row and the `hole:` columns.
7. Criterion 7: `babysit.md` and `babysit/SKILL.md` gain the byte-identical `restart` paragraph; columns A-C of table B (no mark, `fixed:`, `ticket:`) are untouched.

## Would break

1. **`holed()` detects a `hole:` field by unanchored substring, not the `$`-anchored field the Contract defines.** `template/.agents/skills/spec-review/scripts/review-comment.sh:158` is `holed() { items "$dir/judgment.md" "$1" | grep -vE "$ending" | grep 'hole:' || true; }` — the second `grep` is a bare, unanchored match for the text `hole:` anywhere in the item's line, not the end-anchored `hole: $ref$` the Contract specifies ("the judgment field on an Act on item's own line, `$`-anchored like `fixed:` and `ticket:`"). Any judgment item whose title or body happens to contain the substring `hole:` — e.g. `**Security loophole:** the guard is skipped`, or a reviewer's prose about this very mechanism, `the design hole: scoped to the cell` — is treated as carrying a `hole:` mark even though it names no reference at all.
Documented step: acceptance criterion 3, "The judgment can mark an Act on item `hole: <the spec reference>` the way `fixed:` and `ticket:` work; `review-comment.sh` refuses the mark on an item without a `spec:` reference, leaves it out of the count, and prints `restart` on its own line."
Result: for an item under Ask/Consider/Noted/Dismissed, this fires the `## $h` refusal in the "for h in Ask Consider Noted Dismissed" loop even though nothing was marked, sending a normal, correctly-sorted judgment back to the writer for no reason; for an Act on item, it forces the malformed-hole refusal (or, if the trailing text after the accidental "hole:" substring happens to satisfy `hole: $ref$`, silently drops the item from the count and prints `restart`, sending an unremarkable finding to `architect` as if it were a design hole). Either way the documented, no-hole judgment gives a wrong result instead of the plain count.
spec: criterion 3

## Fails open

## Not asked for

hard findings: 1
