## Walk

1. Criterion 1: `spec-review/SKILL.md` step 5 gains the design-hole paragraph word for word as the contract gives it, and `review-ladder.md` rung 1 gains the rung sentence after "An Ask item waits for the human."
2. Criterion 2: `review-brief.sh` defines `spec_rule` and echoes it one blank line after `$step_rule` in both briefs; `SKILL.md` step 4 quotes it word for word; `review-comment.sh` calls `stepless` a second time with `^spec: $ref$` after the step check. Rows B2 to B4 are asserted, including the malformed and fenced `spec:` lines.
3. Criterion 3: `holed` finds Act on items carrying `hole:`. The script refuses a `hole:` outside Act on (G), then one in no form (E), then one that differs from the item's `spec:` or sits on an item with no `spec:` (F, 5D). It then subtracts `holes` from the count and prints `restart` before `round:`.
4. Criterion 4: the Ticket playbook gains the step 8 pointer and a `### Design hole` section with the six steps the contract gives. `review-brief.sh` cuts the history at the last comment that has a bare `restart` line outside a fence, prints the `restart:` line between `ticket:` and `round:`, and reads the round and the settled items from what follows. Rows A5 to A8 and A11 to A13 are asserted, and the `--round 4` refusal with no restart is unchanged.
5. Criterion 5: `cites` gains `#[0-9]+ $ref` inside the anchored group. Rows A14 to A17 are asserted.
6. Criterion 6: the listed cases are all in `tests/spec-review/`. All three suites pass here (134 and 414 assertions, and no stale wording).
7. Criterion 7: the babysit sentence is byte-identical in both playbooks after their prefixes, and the existing `accept` expectations are unchanged. Applying the three patches to the pinned upstream copies reproduces the template files byte for byte.

## Would break

1. **Any `hole:` substring in a reason is read as a field, so the script refuses valid judgments.** `holed` runs `grep 'hole:'` over the whole item line. A Noted item whose one-line reason reads `Named, a loophole: none. cites: DECISIONS.md P17` is refused as "carries a 'hole:' field under '## Noted'". An Act on reason such as "Not a hole: the code fails the cell." is refused as "a 'hole:' field that fits no form". Both have no mark, so they belong in column A, and step 5 invites exactly the "not a hole" wording. I ran both cases against the script at this commit.
Documented step: `template/.agents/skills/spec-review/SKILL.md` step 5, "Each item is `1. [S2] **Title.** reason` ... the reason is one line"
Result: `review-comment.sh` exits 1, and its message names a `hole:` field the judgment does not carry.
spec: table 5/A

```
| 5. Not counted ... | as today; a `spec:` line here is inert / 0 | ...
```

## Fails open

2. **A `hole:` on its own line under an Act on item is ignored.** `holed` reads only the numbered opening line. When the judgment puts `hole: table 2/D` on the next line, as the reports put `spec:` on its own line, the script prints no `restart`, counts the item under `act-on items: 1` and exits 0. The hole then goes to a fix on the PR, which the ticket forbids.
Documented step: `template/.agents/skills/spec-review/SKILL.md` step 5, "`hole: <reference>` on an Act on item ... step 6 leaves it out of the count and prints the line `restart`"
Result: exit 0 with no `restart` line, and the hole is counted as an ordinary Act on item.
spec: table 1/E

```
E. `hole:` fitting no form (`hole: table 2`, `hole: cell 12A`, `hole: criterion 0`, trailing text) -> refused
```

## Not asked for

hard findings: 2
