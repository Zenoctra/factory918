## Would break

## Fails open

## Standards breaches

## Fix alongside

1. **Duplicated Code: the `[S<n>]`/`[P<n>]` extraction is written twice in `review-comment.sh`.** The reference check loop and the new hole loop each carry the same `sed` expression to pull the report item id from a judgment line. A change to the id shape (say, a third axis letter) has to find both. Extract a one-line `ref_of <line>` helper beside `title()` and call it from both loops.

```sh
  ref_id="$(printf '%s' "$line" | sed -nE 's/^[0-9]+\. \[([SP][0-9]+)\].*/\1/p')"
...
  ref_id="$(printf '%s' "$line" | sed -nE 's/^[0-9]+\. \[([SP][0-9]+)\].*/\1/p')"
```

2. **Mysterious Name: `value` says nothing about what it returns.** It returns the text after the last `hole:` on a judgment line, for a refusal message. Among the script's helpers (`title`, `holed`, `specs`, `stepless`), `value` is the only name that does not say what it reads. `hole_value` would.

```sh
# value <item line>: the field's text after `hole:`, the space after it stripped, for a refusal.
value() { local v="${1##*hole:}"; printf '%s' "${v# }"; }
```

hard findings: 0
