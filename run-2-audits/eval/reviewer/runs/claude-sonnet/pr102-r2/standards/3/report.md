## Would break

## Fails open

## Standards breaches

## Fix alongside

1. **Duplicated Code: the ref-to-report lookup is copied a second time.** `template/.agents/skills/spec-review/scripts/review-comment.sh` already had one block (existing, pre-diff) that turns a judgment line's `[S<n>]`/`[P<n>]` reference into the report file and its `specs` row; this change adds a second, identical instance for the new `would-break fixed after` check instead of factoring the lookup into a helper both call.

```
while IFS= read -r line; do
  [ -n "$line" ] || continue
  mark="$(printf '%s' "$line" | sed -E "s#.*hole: ($ref)\$#\1#")"
  ref_id="$(printf '%s' "$line" | sed -nE 's/^[0-9]+\. \[([SP][0-9]+)\].*/\1/p')"
  case "$ref_id" in S*) f="$dir/standards-report.md" ;; *) f="$dir/spec-report.md" ;; esac
  rests="$(specs "$f" | sed -n "${ref_id#[SP]}p")"
  at="${rests%%$'\t'*}"; want="${rests#*$'\t'}"
  ...
done < <(holed "Act on")
...
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
