## Walk

1. Criterion 1: `SKILL.md` step 5 and rung 1 of `review-ladder.md` carry the design-hole definition as the contract wrote it, three artifacts, intent over criterion, the could-not-run clause.
2. Criterion 2: `spec_rule` is echoed one blank line after `step_rule` in both briefs; `report()` calls `stepless` twice, step first, then `^spec: $ref$`; a malformed or fenced `spec:` gives the same refusal (test rows 2 to 4 pass).
3. Criterion 3: `holed()` reads the field that ends an Act on line; placement, form and value are refused in that order after the reference check; `holes` is subtracted and `restart` printed before `round:` (table B columns D to G pass).
4. Criterion 4: the slice awk keeps the comments after the last exact `restart` line outside fenced text, prints the `restart:` line after `ticket:`; `top` and `settled` read the slice, so row 6 is round 1 and row 7 refuses the fourth round of the new series; the Ticket playbook's step 8 pointer and Design hole section match the contract text, and `architect` Phase B exists.
5. Criterion 5: the fourth `cites:` alternative `#[0-9]+ $ref` is `$`-anchored; rows 14 to 17 pass; `fragment()` holds the two `ref=` lines together.
6. Criterion 6: both suites pass (414 and 134 assertions), `no-stale-wording.sh` and ShellCheck pass, `factory918.sh sync` leaves the patched files identical, tests were committed before the scripts.
7. Criterion 7: the babysit sentence is the same in `babysit.md:18` and `babysit/SKILL.md:41`; columns A to C print as before.

## Would break

## Fails open

1. **A `hole:` on its own line under an Act on item is counted as an ordinary item.** `holed()` reads only the item line, so a judgment written as `1. [S1] **One.** reason` followed by a line `hole: table 2/D` prints no `restart`, counts the item, exits 0, and the PR goes down the fix path the ticket exists to close. The report side puts `spec:` on its own line, so the mistake is the natural one. A stray `fixed:` line fails the safe way (over-count); this one fails the unsafe way. A refusal of a bare `hole:` line in the judgment costs no cell.
Documented step: `spec-review/SKILL.md:156`, "`hole: <reference>` on an Act on item ... step 6 leaves it out of the count and prints the line `restart`"
Result: the item is counted, no `restart` line, exit 0 (probed against the reviewed script).
spec: table 1/A

```
| 1. Counted (`## Would break` or `## Fails open`) with `Documented step:`, `Result:` and a well-formed `spec:` line | as today; counted / 0 / fix on the PR, unchanged |
```

## Not asked for

hard findings: 1
