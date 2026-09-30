## Walk

1. **Criterion 1, the definition.** `spec-review/SKILL.md` step 5 gains the design-hole paragraph and `docs/agents/review-ladder.md` rung 1 the matching sentence; both name the three artifacts, the intent-outranks-a-criterion rule and the could-not-run exemption, word for word as the contract writes them. The patch and the template copy carry the same text, and `SOURCES.md` item 6 records it.
2. **Criterion 2, the `spec:` line.** `review-brief.sh` defines `spec_rule` beside `step_rule` and echoes it one blank line after it at both call sites, before the report-path line, so both briefs carry it (this brief does). `review-comment.sh` checks it through `stepless "$f" "^spec: $ref\$"`, the same scanner that checks `Documented step:`, called second, inside `report()` and so before `judgment.md` is read: table B rows 2 to 4.
3. **Criterion 3, the `hole:` mark.** `holed()` reads Act on items whose line is not ended by `fixed:`/`ticket:` and carries `hole:`; the three refusals run in the contract's order (placement, then form, then a value that is not the judged report item's `spec:` word for word) after the reference-set check and before the round file. `holes` is subtracted in `act - fixed_here - ticketed - holes + ask`, and `echo restart` sits between the unchanged summary line and `round:`.
4. **Criterion 4, never fixed on the PR.** `ticket.md` step 8 routes a `restart` comment to the new `### Design hole` section (architect Phase B scoped to the reference, two runners, a dated amendment, tests rewritten first, review from round one, never merge-ready), no step renumbered. In `review-brief.sh`, one awk between the fetch and the round awk keeps only the lines after the last comment holding a bare `restart` outside fences, prints the `restart:` line whenever it cut anything including under `--round`, and leaves `top`, the `settled:` line and section, and the fourth-round refusal reading the sliced history alone.
5. **Criterion 5, citing a reference.** The shared `ref=` line adds a fourth `cites:` alternative `#[0-9]+ $ref`, still `$`-anchored; `review-comment.sh` still never reads `cites:` and `review-brief.sh` still never reads `hole:`.
6. **Criterion 6, the tests.** `tests/spec-review/review-comment.sh` covers rows 1A to 1G, 2, 3, 4, 5A and 5D to 5G, 6 and the three notes; `review-brief.sh` covers A5 to A8, A11 to A17, the `spec_rule` anti-drift and layout, and `fragment()` now holding both `ref=` copies together.
7. **Criterion 7, babysit.** One bullet in `babysit/SKILL.md` and one paragraph in `playbooks/babysit.md`, same sentence, both patched upstream; the merge-ready condition fires only on a `restart` comment, so a PR without one reads as before.

## Would break

## Fails open

## Not asked for

hard findings: 0
