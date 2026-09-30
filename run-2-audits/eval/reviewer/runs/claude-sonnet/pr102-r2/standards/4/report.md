## Would break

## Fails open

## Standards breaches

## Fix alongside

1. **Duplicated Code: the Would-break lookup loop repeats the hole-check loop's shape.** `template/.agents/skills/spec-review/scripts/review-comment.sh` adds a second loop that extracts a judgment line's `[S<n>]`/`[P<n>]` ref, picks the report file by the `S`/`P` prefix, and looks up its heading via `specs "$f" | sed -n "${ref_id#[SP]}p"` — the same three steps the existing hole-check loop a few lines above performs on `holed "Act on"`. The two loops differ only in what they do with the looked-up heading (compare to a `hole:` value vs. test for `"Would break"`), so the ref-to-heading lookup itself is duplicated rather than shared. Fixed only if a would-break fix already touches this code.

```
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
