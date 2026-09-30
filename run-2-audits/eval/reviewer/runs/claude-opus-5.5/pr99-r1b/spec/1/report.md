## Walk

1. Criterion 1: `SKILL.md` step 5 gains the design-hole paragraph; rung 1 of `review-ladder.md` gains the same definition, including the three artifacts, intent outranking a criterion, and the could-not-run exclusion.
2. Criterion 2: `spec_rule` is written into both briefs one blank line after `step_rule`, only when `$spec` is set. `review-comment.sh` reads `has_spec` before the Standards check, then runs `stepless "$f" "^spec: $ref\$"` after the step check.
3. Criterion 3: `holed()` finds the `hole:` field. The checks run in this order: no-spec refusal, placement (G), form (E), then word-for-word match against `specs()` (F/5D). `holes` is subtracted from the count, and `restart` is echoed before `round:`.
4. Criterion 4: ticket.md step 8 points to the new `### Design hole` section, which covers two runners, the dated amendment, and a round-one review. An awk step in `review-brief.sh` keeps only the comments after the last exact `restart` line outside fences and prints the `restart:` line. Babysit carries the not-merge-ready sentence in both files.
5. Criterion 5: `cites:` gains the `#[0-9]+ $ref` alternative, and the `ref=` line is shared and held by `fragment()`.
6. Criterion 6: tests cover rows B1–B7 and A5–A8 and A11–A17, plus the no-spec layout pin.
7. Criterion 7: columns A–C are unchanged, and the babysit lines match.

## Would break

## Fails open

1. **A stray `restart` line in a report or judgment turns an ordinary comment into a restart comment.** `review-comment.sh` copies both reports and the judgment into the comment verbatim. Nothing refuses a line that is exactly `restart` outside a fence in an item body or in judgment prose. When no item is marked `hole:`, the posted comment still carries such a line. Next round, `review-brief.sh` reads it as a restart: the round drops to 1, the settled items are dropped, and the three-round cap is escaped silently. Babysit also treats the PR as not merge-ready.
```
A "restart comment" is a comment with a line that is exactly `restart` outside fenced text.
```
Documented step: "`review-comment.sh` refuses the mark on an item without a `spec:` reference, leaves it out of the count, and prints `restart` on its own line" (criterion 3). Only a hole should put a `restart` line in the comment.
Result: a comment with no hole resets the round gate, and nothing says so at posting time.
spec: table 5/A

## Not asked for

2. **`title()` helper and the `ref` → `ref_id` rename.** Incidental refactors in `review-comment.sh` that the ticket did not ask for. They are needed so the `ref=` grammar line does not collide with the name `ref`, so they are harmless.

hard findings: 1
