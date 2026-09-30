## Walk

1. `review-brief.sh` (criterion 4, table A): one awk cuts the history at the last comment with a line exactly `restart` outside fenced text; `restart:` printed after `ticket:`, before `round:`; round, gate and settled set read the slice. Rows 5 to 8, 11 to 13 tested; a CRLF `restart  ` from `--previous` also cuts (probed).
2. `review-brief.sh` (criterion 5): fourth `$`-anchored `cites:` form; rows 14 to 17 tested.
3. `review-brief.sh` (criterion 2): `spec_rule` after `step_rule` at both call sites; SKILL.md step 4 word for word, layout pinned.
4. `review-comment.sh` (criterion 2, rows 2 to 4): `stepless` takes a regex; `Documented step:` first, then `^spec: $ref$`.
5. `review-comment.sh` (criterion 3, columns D to G): `holed()`, refusals G, E, F/5D in the contract's order, `holes` subtracted, `restart` before `round:`; Walk lines invisible.
6. SKILL.md step 5 paragraph, `Four trailing fields`, `hole:` bullet, step 6 count and refusals; `review-ladder.md` rung 1 (criterion 1).
7. `ticket.md` step 8 pointer and `### Design hole`, six steps, nothing renumbered (criterion 4).
8. `babysit.md` and `babysit/SKILL.md` sentences byte-identical (checked); columns A to C unchanged (criterion 7). SOURCES.md 4, 6, 12; `no-stale-wording.sh` gains `Three trailing fields`. Three suites and ShellCheck pass here.

## Would break

1. **`hole:` in a judgment item's prose is read as a field; `fixed:` and `ticket:` are not.** `holed()` is `grep 'hole:'` anywhere on the line, while `fixed_here` and `ticketed` match only a `$`-anchored field. A Noted item `2. [S2] **Design hole: a row is missing.** settled. cites: #90 table 2/D` is refused with "carries a 'hole:' field under '## Noted'", and an Act on reason `not a design hole: the table stands, fix the code` is refused as "fits no form" (both probed); the same words with `fixed:` pass. In a review whose vocabulary is "design hole", a valid judgment is refused with a message naming a field the item does not carry.
Documented step: SKILL.md step 5, "Each item is `1. [S2] **Title.** reason`", and the ticket, "the way `fixed:` and `ticket:` work"
Result: a judgment that follows every documented rule exits 1; the orchestrator rewrites prose to pass a check about a field.
spec: criterion 3

```
- [ ] The judgment can mark an Act on item `hole: <the spec reference>` the way `fixed:` and `ticket:` work; `review-comment.sh` refuses the mark on an item without a `spec:` reference, leaves it out of the count, and prints `restart` on its own line.
```

## Fails open

## Not asked for

hard findings: 1
