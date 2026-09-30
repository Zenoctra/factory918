## Would break

## Fails open

## Standards breaches

## Fix alongside

1. **Duplicated Code: the `[S<n>]`/`[P<n>]` extraction is written twice in `review-comment.sh`.** The reference loop and the new hole loop each run the same `sed` to pull the judged item's id. A small `ref_of()` helper beside `title()` would give both loops one copy.

```sh
  ref_id="$(printf '%s' "$line" | sed -nE 's/^[0-9]+\. \[([SP][0-9]+)\].*/\1/p')"
...
  ref_id="$(printf '%s' "$line" | sed -nE 's/^[0-9]+\. \[([SP][0-9]+)\].*/\1/p')"
```

2. **Duplicated Code: `specs()` repeats the item walk in `stepless()`.** Both awk programs flush on `## ` and on `^[0-9]+\. `, track the heading, and look for one line under each Would-break or Fails-open item. One of them walks every heading except Walk, and the other walks only the counted headings. If `specs()` also emitted an empty value for each counted item that has no match, `stepless` could read the first empty value from it, and the item grammar would live in one walk.

```sh
specs() {
  awk -v want="^spec: $ref\$" "$fenced"'
    function flush() { if (item) print at "\t" v; item = 0; v = "" }
    /^## / { flush(); next }
    /^[0-9]+\. / { flush(); if (h != "" && h != "Walk") { item = 1; at = h } next }
```

hard findings: 0
