## Would break

## Fails open

## Standards breaches

## Fix alongside

1. **Duplicated Code: two regexes for the same `fixed: <sha>` field.** `review-comment.sh` recognizes a fixed Act on item with `fixed: [0-9a-f]{7,40}$`, and `review-brief.sh` picks the fixed items for `## The fix under review` with `fixed: [0-9a-f]+$`. The two scripts read the same field with different grammars. Today the difference changes nothing, because the comment script is the only writer, but the next edit to one pattern can leave the other behind. The `cap=` line is shared the same way, and a test holds it together; this pattern has no such test.

```
+  j && h == "Act on" && /^[0-9]+\. / && /fixed: [0-9a-f]+$/
...
+done < <(items "$dir/judgment.md" "Act on" | grep -E 'fixed: [0-9a-f]{7,40}$' || true)
```

2. **Mysterious Name: "the first commit in $dir/log".** The refusal tells the orchestrator to write `git rev-parse` of "the first commit in $dir/log". That file comes from `git log --oneline`, newest first, so the first line is `HEAD`, which is correct. A reader could still take "first commit" to mean the oldest one, and writing that commit's id would make the next round's diff too wide. Name it plainly, for example "the top line of $dir/log (the reviewed tip)".

```
+  printf '%s' "$reviewed" | grep -qE '^[0-9a-f]{40}$' || fail "... write its 40-character id to $dir/reviewed (git rev-parse of the first commit in $dir/log) and rerun"
```

hard findings: 0
