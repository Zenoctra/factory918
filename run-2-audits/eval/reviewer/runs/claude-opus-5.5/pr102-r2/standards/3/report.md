## Would break

## Fails open

## Standards breaches

## Fix alongside

1. **Duplicated Code: the judgment-reference-to-report-heading walk now appears three times in review-comment.sh.** The new Would-break loop repeats, line for line, the `ref_id` extraction, the S/P file choice and the `specs | sed -n` lookup that the hole checks already carry (lines 189-191 and 216-218). A small function, for example `rests_on <judgment line>` printing `<heading>\t<reference>`, would give all three call sites one definition.

```bash
+  ref_id="$(printf '%s' "$line" | sed -nE 's/^[0-9]+\. \[([SP][0-9]+)\].*/\1/p')"
+  case "$ref_id" in S*) f="$dir/standards-report.md" ;; *) f="$dir/spec-report.md" ;; esac
+  rests="$(specs "$f" | sed -n "${ref_id#[SP]}p")"
+  [ "${rests%%$'\t'*}" = "Would break" ] || continue
```

2. **Duplicated Code / Primitive Obsession: the `fixed:` mark is matched by two different patterns across the scripts.** review-brief.sh takes any hex run when it picks the fixed items for `## The fix under review`, while review-comment.sh counts only 7 to 40 characters. A mark that one script accepts and the other rejects would behave differently in the two places. One shared pattern would fix this. The same goes for the `cap=3; [ "$round" -le 3 ] || cap=5` line, which is copied into both scripts and kept in sync only by a test.

```bash
+  j && h == "Act on" && /^[0-9]+\. / && /fixed: [0-9a-f]+$/
```
```bash
 fixed_here="$(items "$dir/judgment.md" "Act on" | grep -cE 'fixed: [0-9a-f]{7,40}$' || true)"
```

hard findings: 0
