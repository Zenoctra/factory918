## Would break

## Fails open

## Standards breaches

1. **The new awk filter uses a regex interval, which older mawk does not support.** CODING_STANDARDS.md, Bash: "Prefer commands that behave the same on macOS and Linux." This is the only awk regex in either script that uses an interval (`{7,40}`). Every other interval match runs through `grep -E`, including the same `fixed:` pattern in `review-comment.sh`. mawk older than 1.3.4-20200717, the default awk on Ubuntu 22.04 and Debian 11, does not treat the braces as an interval. On those systems `fixed_items` comes out empty, and the round-four `## The fix under review` section prints its paragraph with no items and no error. BSD awk and current gawk/mawk match correctly, so CI does not catch it. Fix: pipe the awk output through `grep -E 'fixed: [0-9a-f]{7,40}$'`, as `review-comment.sh` does.
```
fixed_items="$(printf '%s\n' "$deciding" | awk "$fenced"'
  /^## / { if (h == "Judgment") j = 1; next }
  j && h == "Act on" && /^[0-9]+\. / && /fixed: [0-9a-f]{7,40}$/
')"
```

## Fix alongside

2. **Duplicated Code: both scripts compute the cap separately.** The comments admit it ("review-comment.sh holds the same line"). A test holds the two copies together, and the scripts share no library. Noted only.
```
cap=3; [ "$round" -le 3 ] || cap=5
echo "round: $round of $cap"
```

3. **Stale ending in review-ladder.md.** In the same paragraph, the text still says the report ends with `round: N of 3`, and a later sentence names `round: 4 of 5` and `round: 5 of 5`. "`round: N of 3` (`of 5` from round four)" would match SKILL.md step 6.
```
+... and ends with the lines `round: N of 3` and `act-on items: N`. One PR gets three rounds, five when round three or four fixed a Would-break item ...
```

hard findings: 0
