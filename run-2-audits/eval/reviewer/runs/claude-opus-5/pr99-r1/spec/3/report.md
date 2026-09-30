## Walk

1. `review-brief.sh` fetches the PR author's comments carrying `act-on items:` (`:96`), unchanged, so a hand-written `restart` body is never fetched (table A row 12).
2. A new awk between the fetch and the round awk (`:141-155`) keeps only the lines after the last comment holding a line that is exactly `restart` outside fenced text, and reports the cut count; `raw[NR]` is captured before `$split` strips CR and trailing blanks, so the kept lines are verbatim.
3. When anything was cut the script prints `restart: the round and the settled items count from the last restart comment` after `ticket:` and before `round:` (`:175`), after the fourth-round refusal, which now counts the post-restart series alone.
4. `ref=` (`:134`) holds the one reference grammar; `cites:` gains a fourth alternative `#N <reference>` (`:183`), still `$`-anchored, so a malformed cite is dropped as an uncited item.
5. `spec_rule` (`:274`) is echoed one blank line after `$step_rule` at both call sites (`:360`, `:390`), before the report-path line; `SKILL.md` step 4 carries it word for word.
6. `review-comment.sh` parameterises `stepless()` and calls it twice, step first then `^spec: $ref$`, so a counted item without a well-formed, unfenced `spec:` line is refused before the judgment is read.
7. `specs()` lists one `<heading>\t<reference>` line per report item in the same document order `items()` uses, so `[S<n>]`/`[P<n>]` indexes it directly.
8. After the reference-set check, `holed()` selects judgment items carrying `hole:`; three refusals follow in order: placement outside Act on, a value fitting no form, a value differing from the judged item's `spec:`.
9. `holes` is counted beside `fixed_here` and `ticketed`, `restart` is printed on its own line after the summary and before `round:`, and the count subtracts the holes.
10. `ticket.md` step 8 routes a `restart` comment to the new **Design hole** section; `babysit.md` and `babysit/SKILL.md` gain the same sentence; `review-ladder.md` rung 1 and `SOURCES.md` items 4, 6, 12 record it.

## Would break

1. **`hole:` is matched anywhere on the line, not only as the trailing field.** `holed()` (`review-comment.sh:159`) filters out lines ending in `fixed:`/`ticket:` and then runs a bare `grep 'hole:'`, unanchored. A judgment item that merely writes the characters `hole:` in its prose or title is treated as marked: under Noted or Dismissed it hits the placement refusal, under Act on the "fits no form" refusal. In this repository, where findings about design holes are the subject matter, a Noted item such as `3. [S2] **The term.** The hole: the table's word. cites: DECISIONS.md P17` is a well-formed, cited judgment item on the documented path and is refused, with a message that names a field the item does not carry. `fixed:` and `ticket:` are `$`-anchored and have no such behaviour.

```
A `hole:` beside `fixed:` or `ticket:` on one line: only the field that ends the line is a field
```

Documented step: `## Testing decisions`, notes under table B: "only the field that ends the line is a field"; `review-comment.sh:158`, "The field that ends the line is the field".
Result: a judgment carrying no `hole:` field is refused, exit 1, and the round cannot be closed until the prose is reworded.
spec: table 1/A

## Fails open

## Not asked for

hard findings: 1
