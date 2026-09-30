## Would break

## Fails open

## Standards breaches

## Fix alongside

1. **Duplicated Code: the report-item lookup is written twice in `review-comment.sh`.** The new Would-break loop copies the hole loop's three-line walk from a judgment line to its report item's heading (ref id, report file, `specs | sed -n`). One helper, `rests <judgment line>` printing `<heading>\t<reference>`, would serve both loops, so a change to how `[S<n>]`/`[P<n>]` resolve lands once.

```bash
  ref_id="$(printf '%s' "$line" | sed -nE 's/^[0-9]+\. \[([SP][0-9]+)\].*/\1/p')"
  case "$ref_id" in S*) f="$dir/standards-report.md" ;; *) f="$dir/spec-report.md" ;; esac
  rests="$(specs "$f" | sed -n "${ref_id#[SP]}p")"
  [ "${rests%%$'\t'*}" = "Would break" ] || continue
```

2. **Stale wording: step 1 of `SKILL.md` still says the round comes only from `of 3` lines.** The same paragraph now allows five rounds, and `review-brief.sh` matches `of [35]`. The sentence below was left unchanged, so it describes the round-four and round-five comments incorrectly (SOURCES.md item 6 was updated to "`round: N of 3` or `of 5` lines").

```
+One PR gets three rounds, five when round three or four fixed a Would-break item (step 5), ... the round is one more than the highest `round: N of 3` line among them
```

3. **Mysterious Name: `wb`, `wb_line` and `wb_first`.** In `review-brief.sh`, `wb` holds the sha that the next round must use as its fixed point. In `review-comment.sh`, `wb_first` holds the first fixed Would-break judgment line. The shared prefix makes them look related, but they hold different things. Names like `wb_sha` and `wb_fixed_item` would say what each one holds.

```bash
wb="${wb_line#would-break fixed after}"; wb="${wb# }"
...
wb_first=""
```

hard findings: 0
