## Would break

## Fails open

## Standards breaches

## Fix alongside

1. **Step 6 says "carries `hole:`" where the grammar says the field ends the line.** `SKILL.md` step 5 defines `hole:` as a trailing field ("it repeats the judged report item's `spec:` line word for word"), and `review-comment.sh` counts only the field that ends the line: `holed()` drops any line matching `(fixed: ...|ticket: #N)$` before grepping for `hole:`, and the test "a hole before a trailing fixed field counts as fixed" pins that. Step 6's sentence reads as though a `hole:` anywhere on the line prints `restart`. Tighten it to "when an Act on item ends with `hole:`" so two paragraphs of the same file cannot be read against each other.

```
Run `scripts/review-comment.sh`. It prints the two reports under `## Standards` and `## Spec` ..., a one-line summary, the line `restart` on its own when any Act on item carries `hole:`, the line `round: N of 3` from `<dir>/round` ...
```

hard findings: 0
