## Would break

## Fails open

## Standards breaches

## Fix alongside

1. **Mysterious flag `j` in the fix-items extraction.** In `review-brief.sh`'s `common()`, the awk fragment built to pull the last comment's fixed Act-on items sets a guard flag `j` that never has any effect: the prepended `$fenced` fragment already assigns `h` to the current heading on the same `/^## /` line before this rule's own `/^## /` pattern runs, so checking `h == "Judgment"` only ever fires (and only needs to fire) on the literal `## Judgment` line, and `j` is never reset afterward. The condition works today because `## Act on` cannot appear before `## Judgment`, but the flag reads as if it tracks "currently inside Judgment" when it actually just tracks "have we ever seen Judgment," which will mislead the next person to touch this parser.

```awk
fixed_items="$(printf '%s\n' "$deciding" | awk "$fenced"'
  /^## / { if (h == "Judgment") j = 1; next }
  j && h == "Act on" && /^[0-9]+\. / && /fixed: [0-9a-f]{7,40}$/
')"
```

hard findings: 0
