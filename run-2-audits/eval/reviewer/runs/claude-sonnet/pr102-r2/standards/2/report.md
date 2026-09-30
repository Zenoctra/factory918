## Would break

## Fails open

## Standards breaches

## Fix alongside

1. **Duplicated Code: ref_id-to-report-file mapping.** `review-comment.sh` already has a loop (existing, unchanged by this diff) that turns a judgment line's `[S<n>]`/`[P<n>]` tag into a report file with `ref_id="$(printf '%s' "$line" | sed -nE 's/^[0-9]+\. \[([SP][0-9]+)\].*/\1/p')"` followed by `case "$ref_id" in S*) f="$dir/standards-report.md" ;; *) f="$dir/spec-report.md" ;; esac`. This diff adds a second, near-identical occurrence of the same shape for the new `wb_first` loop:

```
+while IFS= read -r line; do
+  [ -n "$line" ] || continue
+  ref_id="$(printf '%s' "$line" | sed -nE 's/^[0-9]+\. \[([SP][0-9]+)\].*/\1/p')"
+  case "$ref_id" in S*) f="$dir/standards-report.md" ;; *) f="$dir/spec-report.md" ;; esac
+  rests="$(specs "$f" | sed -n "${ref_id#[SP]}p")"
+  [ "${rests%%$'\t'*}" = "Would break" ] || continue
+  wb_first="$line"
+  break
+done < <(items "$dir/judgment.md" "Act on" | grep -E 'fixed: [0-9a-f]{7,40}$' || true)
```

Both loops resolve a judgment line's report-item reference to its source report file and to the item's `spec:`-derived heading via `specs "$f" | sed -n "${ref_id#[SP]}p"`. A small helper (`rests_for() { ...; }` returning `heading<TAB>reference` for a given line) would remove the second copy.

hard findings: 0
