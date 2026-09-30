## Would break

## Fails open

## Standards breaches

## Fix alongside

1. **Duplicated Code: the report-heading lookup is written twice in `review-comment.sh`.** The new Would-break detection loop repeats, line for line, the `ref_id` / `case` / `specs | sed -n Np` shape of the `hole:` mark loop thirty lines above it. Extract one helper (`at_heading <judgment line>` returning `<heading>\t<spec>`) and call it from both; the two copies can drift on the `[SP]` grammar or the `specs` indexing independently.

```sh
  ref_id="$(printf '%s' "$line" | sed -nE 's/^[0-9]+\. \[([SP][0-9]+)\].*/\1/p')"
  case "$ref_id" in S*) f="$dir/standards-report.md" ;; *) f="$dir/spec-report.md" ;; esac
  rests="$(specs "$f" | sed -n "${ref_id#[SP]}p")"
```

2. **The fourth-round refusal can state a round count that is not true.** In `review-brief.sh` the message branch keys on `round -eq 4`, not on `top -eq 3`, so `--round 4` after one or two comments prints "three rounds were run on this PR". The refusal is loud and its instruction still applies, but the number in it is wrong. Condition the first branch on `[ "$top" -eq 3 ]` and let the second message carry the rest.

```sh
    if [ "$top" -le 3 ] && [ "$round" -eq 4 ]; then
      echo "review-brief: three rounds were run on this PR; the remaining Act on items are fixed here and marked \`fixed: <sha>\`, not reviewed in a fourth round" >&2
```

3. **`review-ladder.md` still says the comment ends with `round: N of 3`.** One sentence earlier in the same bullet that now explains `round: 4 of 5` and `round: 5 of 5`. A reader hitting the first sentence learns a form the script no longer always prints. Say `round: N of 3` (`of 5` past three), as `SKILL.md` does.

```
names the commit it reviewed, and ends with the lines `round: N of 3` and `act-on items: N`. One PR gets three rounds, five when round three or four fixed a Would-break item
```

hard findings: 0
