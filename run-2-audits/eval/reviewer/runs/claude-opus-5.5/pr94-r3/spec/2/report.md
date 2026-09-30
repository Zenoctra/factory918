## Walk

1. Ticket playbook step 6 (`template/.agents/skills/poteto-mode/playbooks/ticket.md`): the architect step appends the table under `## Testing decisions` (or the sketch under `## Design`) with the dated first line. It now also says the whole artifact stays in that one section, with its parts under `###` headings, because the step-1 skip ends at the next `## ` heading.
2. Step 1 overlap check (`overlap.sh:49`): awk sets `skip` on every line matching `^## `, and sets it true only for `## Diff`, `## Testing decisions` and `## Design`. A `### Contract` line does not match `^## ` because its third character is `#`. The skip therefore continues through `###` parts and ends at the next real `## ` heading. The header comment now says so, and the behaviour is unchanged.
3. `docs/agents/issue-tracker.md` and its template copy: the paragraph on appended sections gets the same one-section rule. Both copies are identical.
4. `SCENARIO-TABLE.md` (core and the generated template copy): the posting paragraph gets the rule. The #42 example now notes that #42's record predates the rule, so its table and contract sit under separate `## ` headings.
5. `tests/poteto-mode/overlap.sh` case 17: the body now has `### Contract` with `src/x/y.txt` inside `## Testing decisions`. The expected output is still `paths: none`, which proves that a token under a `###` part is skipped.

## Would break

## Fails open

## Not asked for

hard findings: 0
