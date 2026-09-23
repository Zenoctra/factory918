## Would break

## Fails open

## Standards breaches

1. **The Ticket playbook scopes the fix-only round wider than `SKILL.md` step 1 does.** Step 1 licenses a fix-only round only as "the round after it (four, and after a round four carrying it, five)"; the new Ticket playbook section says "Below round five" with no floor, and `review-brief.sh`'s gate runs only at `round > 3`, so at a round-one or round-two comment carrying the line the same instruction would silently narrow the next round's diff to the fix commits. On the documented path the line first appears at round three (step 5: the fix lane runs "from round three on"), so behavior is unchanged; the sentence is what drifts. Standard: `CODING_STANDARDS.md`, Markdown, "Written with `/writing-for-agents` when an agent reads it".

```
1. Below round five: run the next round with `<sha>` as its fixed point and the ticket named, `scripts/review-brief.sh <sha> --ticket N`;
```

2. **`review-ladder.md` still says the comment ends with `round: N of 3`.** Two sentences later the same bullet names `round: 4 of 5`, and `review-comment.sh` now prints `of 5` from round four. Standard: `CODING_STANDARDS.md`, Markdown, "A count or a version in prose is true at the commit that lands it". `tests/spec-review/no-stale-wording.sh` was extended for "at most three rounds" but not for this phrasing.

```
The report is posted as a comment on the PR, names the commit it reviewed, and ends with the lines `round: N of 3` and `act-on items: N`.
```

3. **An awk interval expression, the first in these scripts.** `{7,40}` inside an awk ERE needs mawk 1.3.4 or a BWK awk from 2019 on; every other awk program in `review-brief.sh` and `review-comment.sh` avoids intervals, and the equivalent test elsewhere is `grep -E`. Standard: `CODING_STANDARDS.md`, Bash, "Where BSD and GNU differ ... either use a form both accept or branch on `command -v`". `[0-9a-f][0-9a-f]*` would be safe everywhere.

```
fixed_items="$(printf '%s\n' "$deciding" | awk "$fenced"'
  /^## / { if (h == "Judgment") j = 1; next }
  j && h == "Act on" && /^[0-9]+\. / && /fixed: [0-9a-f]{7,40}$/
')"
```

## Fix alongside

4. **Duplicated Code.** The new Would-break resolver in `review-comment.sh` repeats the hole loop above it line for line: the `[SP]` extraction, the report-file `case`, the `specs | sed -n Np` lookup. Extract one `rests_at <item line>` helper and call it from both.

```
  ref_id="$(printf '%s' "$line" | sed -nE 's/^[0-9]+\. \[([SP][0-9]+)\].*/\1/p')"
  case "$ref_id" in S*) f="$dir/standards-report.md" ;; *) f="$dir/spec-report.md" ;; esac
  rests="$(specs "$f" | sed -n "${ref_id#[SP]}p")"
```

hard findings: 0
