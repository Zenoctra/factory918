## Would break

## Fails open

## Standards breaches

## Fix alongside

1. **Duplicated Code.** `review-comment.sh` computes three near-identical trailing-field counts with the same `items ... "Act on" | grep -cE '...$' || true` shape (fixed, ticketed, holes), differing only in the regex and variable name.
```
 fixed_here="$(items "$dir/judgment.md" "Act on" | grep -cE 'fixed: [0-9a-f]{7,40}$' || true)"
 ticketed="$(items "$dir/judgment.md" "Act on" | grep -cE 'ticket: #[0-9]+$' || true)"
+holes="$(holed "Act on" | grep -c . || true)"
```

hard findings: 0
