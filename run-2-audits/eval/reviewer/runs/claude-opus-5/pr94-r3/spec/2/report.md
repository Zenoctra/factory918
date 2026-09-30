# Spec report

## Walk

1. `architect`'s runner prompt still asks for the table, then the contract, then the test list as the first deliverable, and says the orchestrator appends the synthesized deliverable under `## Testing decisions` or `## Design` (`template/.agents/skills/architect/references/runner-prompt.md:7,10`). The diff leaves it unchanged; the heading-level rule lands on the poster, not the producer.
2. The Ticket playbook's step 6 is the poster's instruction and now carries the rule: the whole artifact stays in the one section, its parts under `###`, "because the skip ends at the next `## ` heading".
3. The overlap check skips the section by resetting only on a line matching `^## ` and testing `^## (Diff|Testing decisions|Design)[[:space:]]*$` (`template/.agents/skills/poteto-mode/scripts/overlap.sh:49`). `### Contract` has a `#` in column three, so it neither matches nor resets. The prose claim and the code agree.
4. `overlap.sh`'s header comment is reflowed to say "skipped up to the next `## ` heading". Comment only; the `awk` line is untouched, so no behaviour changes and no exit code moves.
5. `docs/agents/issue-tracker.md` and `template/docs/agents/issue-tracker.md` gain the same sentence and remain byte-identical, which is the copy rule in `AGENTS.md`.
6. `docs/knowledge/core/SCENARIO-TABLE.md` and its generated twin `template/docs/factory918/SCENARIO-TABLE.md` change in step, so the knowledge build is reflected; no other generated page under `pages/`, `notes/` or `spec/` quotes the edited sentences.
7. The `#42` example section now marks that record as pre-rule, with its table and contract under their own `## ` headings, and states that a table posted from now on keeps them under `###`.
8. `tests/poteto-mode/overlap.sh` check 17 puts `src/x/y.txt` in a `### Contract` block inside `## Testing decisions` and still expects `paths: none`. That token is the path PR 2 touches in check 18's fixture, so a leak would print a `#2` line and exit 1: the assertion is real, not decorative.
9. The test's header comment is reflowed to name the `###` parts among the cases it covers.

## Would break

## Fails open

## Not asked for

hard findings: 0
