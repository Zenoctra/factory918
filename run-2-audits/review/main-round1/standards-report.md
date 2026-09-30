## Would break

## Standards breaches

1. **The doctor still sends the user to step 5 to clear the review state.** The change renumbers Aggregate to step 6, but `factory918.sh:268` keeps the old fix string. CODING_STANDARDS "Every doctor check carries its fix as the third argument" — the fix is there but now names the Judge step, which writes `judgment.md` and clears nothing. The command it names is still right, so nothing breaks; the sentence is false.

```
    note "a review state is left behind: .claude/state/review (...)" "finish the review (spec-review step 5 runs review-comment.sh, which clears it) or rm -rf .claude/state/review"
```

2. **Two new CI gates, no line in AGENTS.md "Verifying".** The workflow gains two steps; the list a contributor runs locally still names only `tests/hooks/delegation.sh`, so the documented verification is no longer what CI runs.

```yaml
+      - name: review-comment.sh prints and refuses what the test says
+        run: bash tests/spec-review/review-comment.sh
+      - name: review-brief.sh writes the report shape into both briefs
+        run: bash tests/spec-review/review-brief.sh
```

## Fix alongside

3. **Mysterious Name: `spec` is both the has-a-Spec-axis flag and the summary prose.** `[ -n "$spec" ]` decides whether to print the Spec report; the same variable is the sentence printed in the summary. The counts it formats are already in `p_wb`/`p_total`, so a plain `has_spec` would read straight.

```sh
+  spec="$p_wb would break of $p_total"
...
 if [ -n "$spec" ]; then cat "$dir/spec-report.md"; else echo "no spec: Standards axis only"; fi
```

4. **Duplicated Code: the definition sentence and the count rule are written out four times** — `review-brief.sh`, `SKILL.md` step 4, the patch, and `tests/spec-review/review-brief.sh`. The test pins the script to `SKILL.md`, which is the mitigation; the fourth copy inside the test is the one that drifts silently.

```sh
+definition="A hard finding is wrong behavior in normal use: ..."
+count_rule='End the report with exactly one line `hard findings: N`, ...'
```

5. **The two new tests land non-executable (100644).** `tests/hooks/delegation.sh` and both skill scripts are 100755. CI invokes them as `bash <path>`, so this costs nothing today; it breaks the moment someone runs `./tests/spec-review/review-comment.sh` the way AGENTS.md writes the other test.

```
100755 tests/hooks/delegation.sh
100644 tests/spec-review/review-brief.sh
100644 tests/spec-review/review-comment.sh
```

hard findings: 0
