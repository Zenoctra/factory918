# Standards review report

## Would break

## Fails open

## Standards breaches

1. **The new step-4 bullet sits out of emission order.** `CODING_STANDARDS.md`, Markdown: "Written with `/writing-for-agents` when an agent reads it." Step 4's bullet list has until now run in the order the brief prints its sections (commits, changed files, blast radius, diff, settled). The new bullet is listed after `## Settled in earlier rounds`, but `common()` prints the section between the `--stat` list and `## Blast radius`. The bullet's own words carry the truth ("before the diff"), so nothing breaks; the list no longer reads as the file it describes. Move the bullet above the blast-radius one.

```
+- `## The fix under review`, from round four on, before the diff: the Act on items the last review comment marks `fixed: <sha>`, verbatim, under exactly this paragraph: ...
```

## Fix alongside

2. **Duplicated Code: the report-item heading lookup is written twice.** `review-comment.sh` already resolves a judgment line to its report item's heading in the `hole:` loop (lines 186-195); the new Would-break-fix loop repeats the same four steps (`ref_id` by sed, the `case` picking the file, `specs | sed -n Np`, the `at`/`want` split). → one helper, `rests <judgment line>`, called from both.

```
+  ref_id="$(printf '%s' "$line" | sed -nE 's/^[0-9]+\. \[([SP][0-9]+)\].*/\1/p')"
+  case "$ref_id" in S*) f="$dir/standards-report.md" ;; *) f="$dir/spec-report.md" ;; esac
+  rests="$(specs "$f" | sed -n "${ref_id#[SP]}p")"
```

3. **The header comment rewraps ragged.** `review-comment.sh` lines 6-8 leave a four-word line mid-sentence where the rest of the header fills to the margin. → rewrap the paragraph when the next edit touches it.

```
+# reviewed; the next round's fixed point), the round (`of 5` from round four), then act-on items
+# counted from the judgment's Act on items
 # neither fixed on this PR (`fixed: <sha>`), filed as a ticket (`ticket: #N`) nor marked a hole,
```

hard findings: 0
