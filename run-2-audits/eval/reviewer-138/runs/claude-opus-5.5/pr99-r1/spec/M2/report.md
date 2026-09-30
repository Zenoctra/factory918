## Walk

1. Criterion 1: the design-hole paragraph is in `SKILL.md` step 5 and rung 1 of `review-ladder.md`, as the contract words it.
2. Criterion 2: `spec_rule` is written into both briefs one blank line after the step rule. `review-comment.sh` refuses a counted item with no `spec:` line, a malformed one or a fenced one (the tests cover rows B2 to B4).
3. Criterion 3: `hole:` is checked for placement, then grammar, then that it matches the item's `spec:` value. It is left out of the count and prints `restart` before `round:`. Tests cover B1 A to G, B5, B6, two holes, the last-field case and a rerun.
4. Criterion 4: the slicing awk in `review-brief.sh` cuts the history at the last `restart` line outside fenced text and prints the `restart:` line. Tests cover A5 to A8 and A11 to A13, and I read the code for them. The Ticket playbook has the Design hole section and the step 8 pointer.
5. Criterion 5: the fourth `cites:` form carries. A14 to A16 carry and A17 drops.
6. Criterion 7: the babysit sentence is byte-identical in both files. The three patches apply to the pinned upstreams and reproduce `template/`. All three tests pass (134 and 414 assertions, no stale wording). ShellCheck is clean on the five files.

## Would break

1. **The Standards reviewer must name a ticket artifact it is never shown.** The spec rule goes into the Standards brief (`review-brief.sh:360`), but only the Spec brief carries the ticket (`:370`). The Standards brief also says "Read nothing beyond this brief… Run nothing." So a counted Standards finding can only get a `spec:` line by guessing a row, signature or checkbox number. The other outcomes are a refusal the reviewer cannot fix, or the finding moved to an uncounted heading. On a ticketless review ("no spec: Standards axis only") there is no artifact to name at all. A guessed reference then decides whether the item is a hole, and `hole:` must repeat it word for word.
Documented step: `template/.agents/skills/spec-review/SKILL.md:84`, "Then the spec rule, word for word" (said of both briefs)
Result: counted Standards items carry made-up references, or real findings leave the count.
spec: criterion 2

```
Every Would-break and Fails-open item in both reports carries a `spec:` line naming what it rests on
```

2. **A judgment reason that contains `hole:` in its text is read as a mark.** `holed()` (`review-comment.sh:158`) matches the substring anywhere on the item's line. The reason is free text, and step 5 now asks the judge to decide hole or bug for every item. Probed:
- "Not a design hole: the cell stands…" under Act on is refused as "fits no form".
- The same text under Noted is refused as a misplaced field.
- "Fix the whole: guard" is refused.
- "Not a hole: design stands…" is refused as a mismatched mark.

If the text after `hole: ` happens to equal the item's `spec:` value, the item silently drops out of the count and `restart` is printed.
Documented step: `SKILL.md:124`, "Each item is `1. [S2] **Title.** reason`… the reason is one line"
Result: a valid judgment is refused with a message that misdiagnoses it.
spec: table 1/A

```
| 1. Counted … | as today; counted / 0 / fix on the PR, unchanged |
```

## Fails open

## Not asked for

hard findings: 2
