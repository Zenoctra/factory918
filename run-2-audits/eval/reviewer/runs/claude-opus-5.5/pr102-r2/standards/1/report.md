## Would break

## Fails open

## Standards breaches

## Fix alongside

1. **Duplicated Code: the report-item lookup is written twice in `review-comment.sh`.** The new Would-break loop repeats the hole check's three lines that go from a judgment line to its report item's heading and reference (`review-comment.sh` lines 189-191 and 216-218). A helper such as `rests_of <judgment line>` would give both loops one lookup, so a later change to how `[S<n>]`/`[P<n>]` is resolved happens in one place.

```bash
+  ref_id="$(printf '%s' "$line" | sed -nE 's/^[0-9]+\. \[([SP][0-9]+)\].*/\1/p')"
+  case "$ref_id" in S*) f="$dir/standards-report.md" ;; *) f="$dir/spec-report.md" ;; esac
+  rests="$(specs "$f" | sed -n "${ref_id#[SP]}p")"
+  [ "${rests%%$'\t'*}" = "Would break" ] || continue
```

2. **Duplicated Code: the cap line is copied across the two scripts.** Both scripts carry `cap=3; [ "$round" -le 3 ] || cap=5`. The comment says a test holds the copies together, which matches how the repo already treats `ref`. This is a judgement call and does not need to change.

```bash
+cap=3; [ "$round" -le 3 ] || cap=5
+echo "round: $round of $cap"
```

hard findings: 0
