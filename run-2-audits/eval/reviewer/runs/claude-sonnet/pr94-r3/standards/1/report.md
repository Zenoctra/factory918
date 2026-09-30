# Standards report

## Would break

None.

## Fails open

None.

## Standards breaches

None.

## Fix alongside

1. **Duplicated Code (test numbering).** Two `check` cases in this file are both labeled `17`, and this commit edits the text of the second one without renumbering either. Not introduced by this diff (both were already `17` before this commit), but the commit touches this exact line and leaves the collision in place.

```diff
-check "17 tokens under ## Testing decisions and ## Design ignored" 0 $'go: none\npaths: none\nbase: origin/main' 9
+check "17 tokens under ## Testing decisions (with ### parts) and ## Design ignored" 0 $'go: none\npaths: none\nbase: origin/main' 9
```

hard findings: 0
