## Would break

## Fails open

## Standards breaches

1. **SOURCES.md item 6 re-lands a false count.** CODING_STANDARDS.md, Markdown: "A count or a version in prose is true at the commit that lands it." This diff rewrites item 6 as one line and keeps its older claim that each report has two axis-specific headings and that `hard findings` counts only Would-break items. At this commit the Standards report has three headings besides Would break, the Spec report has three besides Would break, and the count covers Fails open too. The wording predates this PR, but this diff lands the line again.

```
+6. ... Each report sorts its findings under `## Would break` and two axis-specific headings, and its `hard findings: N` counts only the Would-break items; ...
```

## Fix alongside

2. **Shotgun Surgery: MANUAL.md still gives the old ready rule.** The merge-ready rule now lives in babysit.md, babysit/SKILL.md, their two patches, SOURCES.md items 4 and 12, and review-ladder.md. `docs/knowledge/core/MANUAL.md:103` and its generated copy were not updated. A person following that line reads a restart comment as ready: the comment test's "two holes" case prints `restart` and then `act-on items: 0`. The ticket keeps the writer out of MANUAL.md, so this belongs to the owner.

```
2. It is ready when: CI is green on the latest commit; `spec-review`'s last line on the latest commit reads `act-on items: 0`; ...
```

3. **Duplicated Code: the `[S<n>]` extraction appears twice.** `review-comment.sh` runs the same sed at line 141, in the reference-set loop, and at line 168, in the hole loop. A one-line helper next to the new `title()` would serve both.

```
+  ref_id="$(printf '%s' "$line" | sed -nE 's/^[0-9]+\. \[([SP][0-9]+)\].*/\1/p')"
```

4. **Duplicated Code: the restart awk normalizes lines a second time.** The restart awk's `END` block strips CR and trailing blanks again and counts separators again, although `split` has already done both on every line. Counting comment boundaries in the main pass, before `$split`, would keep one normalization rule.

```
+      for (i = 1; i <= NR; i++) { t = raw[i]; sub(/\r$/, "", t); sub(/[ \t]+$/, "", t); at[i] = c; if (t == sep) c++; else if (hit[i]) last = c }
```

hard findings: 0
