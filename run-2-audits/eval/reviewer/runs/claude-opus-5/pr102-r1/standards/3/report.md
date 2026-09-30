# Standards report

## Would break

## Fails open

## Standards breaches

## Fix alongside

1. **Duplicated Code: the report-item lookup is now written twice in `review-comment.sh`.** The new `wb_first` loop repeats, line for line, the `[S<n>]`/`[P<n>]` → report file → `specs | sed -n "<n>p"` walk the `hole:` check does thirty lines above it. Two copies of the same four statements now have to stay in step with `specs`'s `<heading>\t<reference>` output shape; a change to that shape has to land in both. A `rests_for <judgment line>` helper beside `holed()`/`value()` would collapse them, and both callers already only want one of the two tab-separated halves. Not touched by any would-break fix here, so it is a judgement call, not a defect.

```
line="$(holed "Act on" | grep -vE "hole: $ref\$" | head -1 || true)"
...
  ref_id="$(printf '%s' "$line" | sed -nE 's/^[0-9]+\. \[([SP][0-9]+)\].*/\1/p')"
  case "$ref_id" in S*) f="$dir/standards-report.md" ;; *) f="$dir/spec-report.md" ;; esac
  rests="$(specs "$f" | sed -n "${ref_id#[SP]}p")"
  at="${rests%%$'\t'*}"; want="${rests#*$'\t'}"
```

```
wb_first=""
while IFS= read -r line; do
  [ -n "$line" ] || continue
  ref_id="$(printf '%s' "$line" | sed -nE 's/^[0-9]+\. \[([SP][0-9]+)\].*/\1/p')"
  case "$ref_id" in S*) f="$dir/standards-report.md" ;; *) f="$dir/spec-report.md" ;; esac
  rests="$(specs "$f" | sed -n "${ref_id#[SP]}p")"
  [ "${rests%%$'\t'*}" = "Would break" ] || continue
  wb_first="$line"
  break
done < <(items "$dir/judgment.md" "Act on" | grep -E 'fixed: [0-9a-f]{7,40}$' || true)
```

hard findings: 0
