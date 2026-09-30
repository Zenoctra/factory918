## Walk

1. Criterion 1 (runner prompt): `architect/SKILL.md` Phase B, via the new `patches/pstack/architect/SKILL.md.patch` listed in `series` before the runner-prompt patch, now says a design with state opens with the scenario table, contract and test list, and defers the shape to `references/runner-prompt.md`. SOURCES.md item 14 names both files.
2. Criterion 2 (refusal cells): unchanged by this diff; SOURCES.md item 14 still records the "refused with the tool's own message" rule in the runner prompt.
3. Criterion 3 (Ticket step 6): the step now reads the body with `gh issue view N --json body -q .body`, appends `## Testing decisions` with the `Posted by`/`Approved by` first line, writes the whole file back with `gh issue edit N --body-file`, and stops if the write fails. The stop-only-on-checkpoint rule and the `review-brief.sh` sentence remain.
4. Criterion 4 (delegation playbooks): not touched by this diff.
5. Criterion 5 (to-spec): the bullet now says the table is a decision, so the rule about paths and snippets does not exclude it. The patch and the template copy match.
6. Criterion 6 (knowledge page): `SCENARIO-TABLE.md` "Where it goes" matches the new step 6. MANUAL "Where to read more" lists it and says projects carry five documents. The `build_knowledge.py` docstring says every core document except CONVERSATION-DIGEST is copied. INDEX line count is updated.
7. `overlap.sh` step 1 skips `## Diff`, `## Testing decisions` and `## Design`. The header comment, P24 (with a dated amendment), SCENARIO-TABLE.md and test 17b agree. The `check` helper compares exactly, and `paths: none` is expected because no token remains.

## Would break

## Fails open

## Not asked for

1. **The overlap matcher now skips two more sections.** The ticket's criteria never mention `overlap.sh` or #42's matcher. This diff changes that script's behaviour for every ticket, and every ticket body containing a `## Design` heading is affected, not only one the agent posted. The change is small, tested, and recorded as a dated P24 amendment, so it is coherent. It is still a behaviour change to another ticket's tool.

```
- [ ] The Ticket playbook's architect step says that when a design adds state, the table is appended to the ticket's body under `## Testing decisions` ...
```

hard findings: 0
