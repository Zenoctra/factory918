## Would break

## Fails open

## Standards breaches

## Fix alongside

1. **Duplicated Code: the refusal check is written out by hand next to the helper that now does it.** The new `refused_risks` helper wraps the pattern: `set +e`, capture, compare exit code and output, check no state, fail. The 9A block right after it, and the new block 10 (`--blast-radius missing.md`), still repeat the whole pattern inline with only the expected message changed. A helper that takes the expected output would cover all three.

```sh
+# 10: --blast-radius naming no file is the usage block, before anything runs.
+rm -rf .scratch .claude/state
+set +e
+out="$(bash "$skill/scripts/review-brief.sh" HEAD~1 --blast-radius missing.md 2>&1)"
+code=$?
+set -e
+if [ "$code" != 1 ] || [ "$out" != "usage: review-brief.sh ...
```

hard findings: 0
