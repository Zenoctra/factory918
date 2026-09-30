The commit makes one rule explicit in four places and proves it with one test: a design artifact posted on a ticket stays inside its single `## ` section, its parts under `###`, because the overlap check's skip ends at the next `## ` heading. The code is unchanged; the documentation now matches what the code already did, and one fixture demonstrates it.

## Walk

1. Ticket playbook step 6 tells the architect to append the artifact under `## Testing decisions` or `## Design` and now adds that the whole artifact (legend, table, contract, test list, or usage and signatures) stays in that one section with `###` parts. The stated reason is the skip's end condition.
2. `docs/agents/issue-tracker.md` and its template copy carry the same rule in the section-shape list; both files are byte-identical, as the copy rule requires.
3. `SCENARIO-TABLE.md` (core) and its generated copy under `template/docs/factory918/` carry the rule and disclose that #42's own record predates it and uses `## ` headings; both copies are in sync, and no other file holds this text.
4. `overlap.sh:49` sets `skip` only on lines matching `^## `, and true only for `## Diff`, `## Testing decisions`, `## Design`. A `### ` line does not match `^## `, so the skip continues through the parts: the code does what the four documents now claim.
5. `tests/poteto-mode/overlap.sh` case 17 puts `src/x/y.txt` under a `### Contract` inside `## Testing decisions` and expects `paths: none`, exit 0. Cases 15, 16 and 18 show those same tokens do produce PR lines when not skipped, so the assertion is falsifiable.
6. The script's header comment is amended to "skipped up to the next `## ` heading", which is the behaviour at line 49 and the rule the playbook cites.

## Would break

None.

## Fails open

1. **A `## ` line inside the artifact silently ends the skip.** The new rule tells the author to use `###` for parts, but nothing refuses a section whose body has a line starting with `## ` — a fenced example ticket body, or a quoted heading at line start, both natural in an artifact for a tool that parses headings. `overlap.sh:49` resumes counting there, so backticked tokens from inside the artifact become ticket-named paths: a wrong base or a spurious exit 1, with no message.

Documented step: `template/.agents/skills/poteto-mode/playbooks/ticket.md:6` — "The whole artifact ... stays inside that one section, its parts under `###` headings, because the skip ends at the next `## ` heading."

Result: a section that violates the rule is parsed as if the artifact had ended, silently, instead of being refused with a message naming the offending line.

hard findings: 1
