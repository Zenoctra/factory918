## Would break

## Fails open

## Standards breaches

## Fix alongside

1. **Duplicated Code: the `[S<n>]`/`[P<n>]` extraction is written twice in `review-comment.sh`.** The reference check and the new hole loop each carry the same `sed` that pulls the judged item's id; a change to the reference form has to find both. A `ref_of <line>` helper next to `title()` would hold it once.

```sh
  ref_id="$(printf '%s' "$line" | sed -nE 's/^[0-9]+\. \[([SP][0-9]+)\].*/\1/p')"
...
  ref_id="$(printf '%s' "$line" | sed -nE 's/^[0-9]+\. \[([SP][0-9]+)\].*/\1/p')"
```

2. **Duplicated Code: the `ref=` grammar is copied between the two scripts.** It follows the existing `fenced=` pattern and a test holds the copies identical, so this is noted only as the same smell the fence fragment already carries, not as a new one.

```sh
+ref='(table [^[:space:]/]+/[^[:space:]/]+|design [^[:space:]].*|criterion [1-9][0-9]*)'
```

hard findings: 0
