## Walk

1. Criterion 1: the design-hole definition is in `spec-review/SKILL.md` step 5 and `template/docs/agents/review-ladder.md:6`, both naming the three artifacts, the intent-outranks-a-criterion clause and the could-not-run exemption.
2. Criterion 2: `spec_rule` is echoed one blank line after `$step_rule`, in the Standards brief only when `$spec` is set and always in the Spec brief; `report()` runs `stepless` twice, the step refusal first, the `spec:` refusal second, and returns before the spec scan when `spec-brief.md` is absent.
3. Criterion 3: `holed()` takes the text from the last `hole:` on an Act on line not ending in a `fixed:` or `ticket:` field; four refusals fire in the amended order (no spec, placement, form, value); `holes` is subtracted from the count and `echo restart` sits between the summary and `round:`.
4. Criterion 4: the slicing awk drops every line up to the last `restart` comment and prints the cut count, so the round, the fourth-round refusal and `settled:` read the new series alone; `restart:` prints after `ticket:`; the Ticket playbook gains `### Design hole` and step 8's pointer.
5. Criterion 5: `cites:` gains `#[0-9]+ $ref` inside the anchored group; `review-comment.sh` still never reads `cites:` and `review-brief.sh` never reads `hole:`.
6. Criterion 6: the tests cover table A rows 5 to 8, 11 to 13 and 14 to 17, the no-spec brief layout, and `fragment()` over the two `ref=` lines; table B rows 1D to 1G, 2, 3, 4, 5A and 5D to 5G, 6, 7 and the three notes.
7. Criterion 7: the babysit sentence is the same in `babysit/SKILL.md:41` and `playbooks/babysit.md:18`, columns A to C keep their assertions, and every other reader of `act-on items:` (MANUAL, review-ladder, P20) gains the restart clause.

## Would break

## Fails open

## Not asked for

1. **A malformed mark's value is printed as written, not blank-stripped.** `value()` is `${1##*hole:}`, so `hole:table 2/D` is refused as `'hole:table 2/D'`; under the amended contract the template is `'hole: <value>'` with the value blank-stripped, which would print `'hole: table 2/D'`. A new assertion pins the as-written form for a spelling column E does not list, and no dated line amends the ticket for it. Every value the table does list renders identically either way.

```
`<value>` is the text after `hole:` with leading blanks stripped
```

hard findings: 0
