## Would break

## Fails open

## Standards breaches

## Fix alongside

1. **Duplicated Code: the `[S<n>]`/`[P<n>]` extraction is written twice in `review-comment.sh`.** The reference-check loop and the new hole loop parse the judgment item's reference with the same `sed`. A small `ref_of <line>` helper next to `title()` would hold the parse in one place, so the two loops cannot drift apart.

```sh
  ref_id="$(printf '%s' "$line" | sed -nE 's/^[0-9]+\. \[([SP][0-9]+)\].*/\1/p')"
...
  ref_id="$(printf '%s' "$line" | sed -nE 's/^[0-9]+\. \[([SP][0-9]+)\].*/\1/p')"
```

2. **Duplicated Code: the `hole:` line is checked two ways.** `holed` matches `hole:` anywhere with `grep 'hole:'`, then separate filters check the form and extract the reference. The count (`holes`) depends on the form check running first. It does today, so the result is correct, but it relies on the order of statements. One awk pass that emits `<ref_id>\t<mark>` for each Act on item ending in `hole: $ref` would replace `holed`, the no-form `grep -vE` and the `sed` extraction.

```sh
holed() { items "$dir/judgment.md" "$1" | grep -vE "$ending" | grep 'hole:' || true; }
...
line="$(holed "Act on" | grep -vE "hole: $ref\$" | head -1 || true)"
...
  mark="$(printf '%s' "$line" | sed -E "s#.*hole: ($ref)\$#\1#")"
```

hard findings: 0
