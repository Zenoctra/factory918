## Would break

## Fails open

## Standards breaches

1. **SOURCES.md item 6 miscounts the report headings.** The item says each report has `## Would break` plus two axis headings, and that `hard findings` counts only Would-break items. Since #81 each report has three further headings, and the count includes Fails open. This diff rewrites the line but leaves the old claim in place. CODING_STANDARDS.md, Markdown: "A count or a version in prose is true at the commit that lands it." The text is older than this diff.

```
Each report sorts its findings under `## Would break` and two axis-specific headings, and its `hard findings: N` counts only the Would-break items;
```

## Fix alongside

2. **`hole:` matched as a plain substring.** `holed()` finds the field with `grep 'hole:'`, so it also matches `whole:` and prose like "Not a hole: the cell stands." I ran both through `review-comment.sh`. An Act on reason "The whole: guard is wrong." is refused as "a 'hole:' field that fits no form". A Dismissed reason "Not a hole: … cites: #42 table 2/D" is refused as a `hole:` under Dismissed. The script fails closed, but the message names the wrong cause, and "not a hole:" is wording this change invites. A judgment call: anchor on `(^| )hole: `.

```sh
holed() { items "$dir/judgment.md" "$1" | grep -vE "$ending" | grep 'hole:' || true; }
```

3. **Duplicated Code: the `[S<n>]`/`[P<n>]` extraction.** The same sed program appears in the reference-set loop and again in the hole loop. Suggested fix: one `ref_of()` helper beside `title()`.

```sh
  ref_id="$(printf '%s' "$line" | sed -nE 's/^[0-9]+\. \[([SP][0-9]+)\].*/\1/p')"
```

4. **Duplicated Code: the restart slice re-normalises lines.** The `split` fragment already strips CR and trailing blanks, and detects the separator. The restart awk's `END` does both again on `raw[]`, because `split` runs `next` on the separator before any later rule. Suggested fix: record the separator in a rule placed before `$split` (`$0 == sep` after the strip), so the rule lives in one place.

```sh
      for (i = 1; i <= NR; i++) { t = raw[i]; sub(/\r$/, "", t); sub(/[ \t]+$/, "", t); at[i] = c; if (t == sep) c++; else if (hit[i]) last = c }
```

Checked and clean: `tests/spec-review/review-comment.sh` (134), `review-brief.sh` (414) and `no-stale-wording.sh` pass. ShellCheck is clean over the five changed shell files. I replayed `patches/series` onto the pinned upstreams, and the result is byte-identical to the three patched template files. `tools/check_knowledge.py` passes.

hard findings: 0
