## Walk

1. Criterion 3, table on the ticket: `playbooks/ticket.md` step 6 still appends the table under `## Testing decisions`, with the first line and the `gh issue edit N --body-file` write. It now adds that the whole artifact (legend, table, contract, test list, or usage and signatures) stays in that one section, with its parts under `###` headings.
2. `## Design` for code with no state: the same step 6 sentence covers the sketch's parts (usage, signatures). `SCENARIO-TABLE.md` (core and template copy, identical hunks) says the same.
3. Step-1 overlap skip: `overlap.sh:49` runs awk, where `/^## /` resets `skip` only on a line starting `## ` followed by a space. A `### Contract` line does not match, so the skip holds until the next true `## ` heading. The header comment now says "skipped up to the next `## ` heading", which matches the code. The code did not change.
4. Test 17 in `tests/poteto-mode/overlap.sh` adds `### Contract` with the named path `src/x/y.txt` inside `## Testing decisions` and expects `paths: none`. That makes the in-section `###` part a tested case. The header comment lists it.
5. `issue-tracker.md` (the root copy and the template copy, identical) adds the containment rule to the ticket-shape description and gives the overlap skip as the reason.
6. Criterion 6, the knowledge page's #42 example: the page now says #42's record has its table and contract under separate `## ` headings, which predate the rule, and that new tables use `###`. The verbatim legend and table are unchanged.

## Would break

## Fails open

## Not asked for

hard findings: 0
