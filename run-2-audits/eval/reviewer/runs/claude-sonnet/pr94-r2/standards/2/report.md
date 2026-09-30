## Would break

## Fails open

## Standards breaches

## Fix alongside

1. **Duplicate test number "17".** The new scenario-table case is labeled the same number as the existing `## Diff`-skip case right above it, instead of being numbered "17" with the rest shifted or given its own distinct label. Sequential, unique test numbers are how this suite's own header comments (and reviewers) refer to a case; two cases sharing "17" makes that reference ambiguous.
```
 check "17 a token under ## Diff ignored" 0 $'go: none\nbase: origin/main' 9
+export FAKE_BODY='## Testing decisions
+...
+`src/z.txt`'
+check "17 tokens under ## Testing decisions and ## Design ignored" 0 $'go: none\npaths: none\nbase: origin/main' 9
```

hard findings: 0
