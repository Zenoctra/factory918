## Would break

## Fails open

## Standards breaches

## Fix alongside

1. **Mysterious Name: `stepless` no longer means "without a step".** The helper was generalised to take a regex and now answers "the first counted item with no line matching this", but it keeps the name of its first caller. At the `spec:` call site the code reads as if a spec line were a step. `missing_line` (or `first_item_without`) would say what it does. → rename when a would-break fix touches `report()`.

```sh
# stepless <file> <regex>: the heading and opening line of the first Would-break or Fails-open item
# with no line matching the regex before the next item or heading; fenced text does not count.
stepless() {
  awk -v want="$2" "$fenced"'
...
  line="$(stepless "$f" "^spec: $ref\$")"
```

2. **Mysterious Name: `value` and `ending` in `review-comment.sh`.** `value()` holds one specific thing, the raw text after the last `hole:`, shown as written in a refusal; `ending` holds the two trailing fields that outrank a `hole:`. Both names are generic enough that a reader has to open the definition to know which of the many values or endings in this script is meant. `hole_text` and `closing_field` carry the meaning to the call sites.

```sh
ending='(fixed: [0-9a-f]{7,40}|ticket: #[0-9]+)$'
# value <item line>: the text after the last `hole:`, as written, so a refusal shows a missing space.
value() { printf '%s' "${1##*hole:}"; }
```

3. **Reader load: `want` and `at` are reused at top level with a second meaning.** A few lines above the hole block, `want`/`got` are the expected and actual `[S<n>]`/`[P<n>]` sets; inside the hole loop `want` becomes the report item's `spec:` reference and `at` its heading. Nothing after the loop reads the old values, so this is correct today, but the reader must prove that before trusting either use. Distinct names (`want_ref`, `rests_at`) cost nothing.

```sh
  at="${rests%%$'\t'*}"; want="${rests#*$'\t'}"
```

hard findings: 0
