# Standards report

## Would break

## Fails open

## Standards breaches

## Fix alongside

1. **The fix bullet sits out of order in step 4's list.** Step 4's bullets are the brief's parts in output order (Blast radius "placed before the diff", then the diff, then Settled, then Report). The new bullet is inserted between Settled and Report but says "before the diff", and `common()` emits the section after the stat, ahead of `## Blast radius`, the diff and Settled. The text is right, the position in the list is not; move the bullet above the diff bullet.

```
+- `## The fix under review`, from round four on, before the diff: the Act on items the last review comment marks `fixed: <sha>`, verbatim, under exactly this paragraph: ...
```

2. **One paragraph of `review-ladder.md` says both things about the round line.** The sentence that survives unchanged still tells the reader the comment "ends with the lines `round: N of 3`"; two sentences later the same paragraph offers `round: 4 of 5` and `round: 5 of 5` as merge-ready readings. Rung 1 is prose a person reads straight through, so the first sentence wants `of 3` (`of 5` past three) or the same hedge the amended sentence carries.

```
The report is posted as a comment on the PR, names the commit it reviewed, and ends with the lines `round: N of 3` and `act-on items: N`. One PR gets three rounds, five when round three or four fixed a Would-break item ...
```

3. **The fix section is printed without checking it has items.** The round-past-three gate proves the `would-break fixed after <sha>` line and the fixed point; it never proves `$fixed_items` parsed anything out of the deciding comment. When it comes back empty the brief still prints the heading and the paragraph, so a reviewer is told "this round's diff is those fix commits" under a blank list. The gate already refuses four other shapes loudly before any state is written; an empty `fixed_items` beside a valid line belongs with them.

```
  if [ "$round" -ge 4 ]; then
    echo "## The fix under review"
    echo
    echo "$fix_rule"
    echo
    printf '%s\n' "$fixed_items"
```

hard findings: 0
