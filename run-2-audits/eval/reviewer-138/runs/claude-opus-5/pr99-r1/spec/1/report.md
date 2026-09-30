## Walk

1. Step 1, the reset: one awk keeps only the comments after the last one holding a line that is exactly `restart` outside fenced text. `$split` strips CR and trailing blanks before the test, so a body posted from the web UI resets too (checked with a CRLF fixture).
2. Step 1, the round: the slice feeds both the `top` awk and the carry, so a restart gives round 1 with no `settled:` line, and the fourth-round refusal counts the new series alone. `--round N` still overrides, and the `restart:` line prints either way, after `ticket:` and before `round:`.
3. Step 1, the carry: `cites:` gains `#N <reference>`, sharing the one `ref=` line with `review-comment.sh`; `fragment()` holds the two copies identical.
4. Step 4: `spec_rule` is echoed one blank line after `step_rule` at both call sites, and `SKILL.md` carries it word for word (this brief shows it).
5. Step 5: the list reads "Four trailing fields"; the design-hole paragraph and the `hole:` bullet define the mark, and `no-stale-wording.sh` now fails on the old count.
6. Step 6: `report()` runs `stepless` twice, step first then spec, so a counted item with no well-formed `spec:` line of its own is refused before the judgment is read.
7. Step 6, the marks: after the reference-set check, a `hole:` outside Act on, then one fitting no form, then one differing from the judged item's `spec:`, in that order. `specs()` indexes items as `[S<n>]`/`[P<n>]` count them, Walk lines excluded (checked with a `criterion` hole on a `[P1]` under a Walk).
8. Step 6, the tail: summary unchanged, one `restart` line however many holes, then the round, then `act-on items:` less the holes. `holed()` drops lines ending in `fixed:`/`ticket:`, so the count cannot double-subtract.
9. Rung 1 carries the definition; Ticket step 8 routes a `restart` comment to the new `### Design hole` section, whose "step 6" and "step 9" are the right ones; the babysit paragraph and bullet carry the same sentence, so a no-hole PR reads as today.
10. All three patches re-apply to the pinned upstreams and reproduce the template copies byte for byte; `SOURCES.md` items 4, 6 and 12 name the new behavior.

## Would break

## Fails open

## Not asked for

hard findings: 0
