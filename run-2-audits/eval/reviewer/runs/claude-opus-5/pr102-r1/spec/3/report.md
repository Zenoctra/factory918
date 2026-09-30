## Walk

1. `review-brief.sh` cuts the deciding comment out of `$bodies` (last chunk, CR and trailing blanks stripped) and reads `wb`, `had_spec` and `fixed_items` from it.
2. The gate fires FM, F6, F4/F5, FR, FP, FT in that order, before `mkdir -p "$dir"`; `$ticket` is already resolved from `$fixed..HEAD`, so FT sees the fix commits' number.
3. `cap=3; [ "$round" -le 3 ] || cap=5`, then `round: $round of $cap`; the round parse is `of [35]`, so older comments still parse.
4. `git rev-parse HEAD > "$dir/reviewed"` on the line after `<dir>/round`, one code path, sweep form included.
5. `common()` prints `## The fix under review`, `$fix_rule` and `$fixed_items` after `## Changed files`, only when `round` is 4 or more.
6. `review-comment.sh` resolves each `fixed:` Act on item through `specs()` and prints `would-break fixed after <reviewed>` when its heading is `Would break` and `holes` is 0; `restart` outranks it.
7. `RM` fires only when that line is needed, naming the file's content and the first Would-break fix.
8. Babysit, the ladder, P20, P30 and MANUAL step 2 read the line as not-review-ready.
9. The Ticket playbook sends a comment carrying the line to **Would-break fix** before step 9.

## Would break

1. **The playbook sends a round-one or round-two Would-break fix down the fix-only path.** `ticket.md`'s new section opens "When a round's review comment carries the line ... 1. Below round five: run the next round with `<sha>` as its fixed point", and `SKILL.md` step 5 says "the next round, up to five, reviews that fix and nothing else". A Would-break item fixed in round one (PR #92's case, quoted in the ticket's Problem) makes round two fix-only, and `review-brief.sh` accepts it silently: the gate is off below round four, so `s` resolves as an ordinary fixed point and round two reviews the fix commits alone, leaving the rest of the diff unreviewed. Only step 1's parenthetical "(four, and after a round four carrying it, five)" says otherwise.

```
12. (1W s): a Would-break fix marked in round one (or two), fixed point o | R(2), S, no FIX, paths / 0 / round two reviews the whole diff from o, as today; the sha is not checked before round four
```

Documented step: table A row 12, the cell quoted above.
Result: round two's diff is `s...HEAD`, the fix commits only.
spec: table 12/A

## Fails open

## Not asked for

hard findings: 1
