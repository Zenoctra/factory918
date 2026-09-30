## Would break

## Fails open

## Standards breaches

## Fix alongside

1. **Duplicated Code: the judgment-reference extraction is written twice.** `review-comment.sh` now pulls `[S<n>]`/`[P<n>]` out of a judgment line with the same `sed` in the reference loop and again in the hole loop. A small `ref_of <line>` helper beside `title()` would serve both sites.

```sh
  ref_id="$(printf '%s' "$line" | sed -nE 's/^[0-9]+\. \[([SP][0-9]+)\].*/\1/p')"
...
  ref_id="$(printf '%s' "$line" | sed -nE 's/^[0-9]+\. \[([SP][0-9]+)\].*/\1/p')"
```

2. **Summary line does not count holes.** The summary names fixed and ticketed Act on items but not holes. So with a hole it reads `act on 2 (0 fixed, 0 with a ticket)` above `act-on items: 1`, and the reader has to work out the missing one from the `restart` line. Adding `, N holes` inside the parenthesis would keep the summary and the count in step.

```sh
echo "Standards: ... judged: act on $act ($fixed_here fixed, $ticketed with a ticket), ask $ask, ..."
+[ "$holes" -eq 0 ] || echo restart
```

3. **Line-position assertion assumes a single match.** The new brief-order check in `tests/spec-review/review-brief.sh` feeds `grep -nF ... | cut -d: -f1` into `-ne`. If the rule text ever appears twice in a brief, this breaks with a `test` syntax error instead of the FAIL message. `grep -m1` would pin it to the first match.

```sh
  if [ "$(grep -nF -- "$spec_rule" "$f" | cut -d: -f1)" -ne "$(($(grep -nF -- "$step_rule" "$f" | cut -d: -f1) + 2))" ]; then
```

hard findings: 0
