## Walk

1. Ticket playbook step 6 (`template/.agents/skills/poteto-mode/playbooks/ticket.md`): the table goes under `## Testing decisions`, the sketch under `## Design`, and each is appended to the ticket body with a dated first line. The diff adds that the whole artifact (the legend, the table, the contract and the test list, or the usage and the signatures) stays in that one section, with its parts under `###` headings.
2. Overlap check, step 1 (`overlap.sh:49`): awk resets `skip` only on lines that match `/^## /`. A `### ` line does not match that pattern, so `### Contract` inside `## Testing decisions` stays skipped. The header comment now says "up to the next `## ` heading", which matches the code.
3. Test 17 (`tests/poteto-mode/overlap.sh`): adds a `### Contract` part that quotes `src/x/y.txt` inside `## Testing decisions` and expects `paths: none`. This exercises step 2.
4. `issue-tracker.md` (the root copy and the template copy are identical) and `SCENARIO-TABLE.md` (the core document and the generated template copy): both state the same one-section rule and give the same reason.
5. The #42 example: the page now says that #42's record came before this rule and uses separate `## ` headings. That tells a reader not to copy its heading layout.
6. Spec brief: `review-brief.sh` pastes the whole body, so the `###` parts still reach the reviewer. Nothing changed here.

## Would break

## Fails open

## Not asked for

1. **A heading rule beyond #89's criteria.** No criterion in #89 covers how the artifact is laid out inside its section. The rule protects the step-1 overlap skip that the playbook already documents, so it is a consistency fix within the same concern, not new behaviour.

```
The step-1 check skips both sections, so a path a cell quotes does not count as a path the ticket names.
```

hard findings: 0
