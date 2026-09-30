## Would break

## Fails open

## Standards breaches

## Fix alongside

1. **Duplicated Code: the `[S<n>]` extraction is written twice in review-comment.sh.** The same `sed -nE` pulls the reference id in the naming loop and again in the hole loop. The change already added a `title()` helper for the same reason, so a one-line `ref_of()` next to it would fit.

```sh
  ref_id="$(printf '%s' "$line" | sed -nE 's/^[0-9]+\. \[([SP][0-9]+)\].*/\1/p')"
...
+  ref_id="$(printf '%s' "$line" | sed -nE 's/^[0-9]+\. \[([SP][0-9]+)\].*/\1/p')"
```

2. **Judgement call: the spec rule also binds the Standards axis when no ticket exists.** Every Would-break or Fails-open item must carry `spec:` as a ticket cell, signature or criterion, and `review-comment.sh` refuses the report otherwise. A Standards reviewer on a no-spec run ("no spec: Standards axis only") has no table, `## Design` or criteria to name. A real Would-break breach of `CODING_STANDARDS.md` then has two outcomes: a made-up reference, or a refusal the reviewer cannot fix. This rests on the ticket's intent, not on a documented coding standard, so it is listed here for the judge to weigh.

```sh
+  line="$(stepless "$f" "^spec: $ref\$")"
+  [ -z "$line" ] || fail "$f item '$(title "${line#*: }")' under '## ${line%%: *}' has no 'spec:' line; ...
```

3. **Judgement call: `hole:` in an item's prose is read as a field outside Act on.** `holed` greps for `hole:` anywhere on the line. A Noted item whose reason says "a design hole: ..." gets refused with "carries a 'hole:' field under '## Noted'", but the item carries no field. The refusal names a way to correct it, so this is not a hard finding. Anchoring the match to the end of the line, the way `fixed:` and `ticket:` are matched, would make the three fields read the same way.

```sh
+holed() { items "$dir/judgment.md" "$1" | grep -vE "$ending" | grep 'hole:' || true; }
```

4. **Judgement call: the ordering test in tests/spec-review/review-brief.sh assumes each rule appears on exactly one line.** If the step rule or the spec rule appears twice in a brief, `grep -n | cut` returns two numbers. `[ -ne ]` then fails with a shell error instead of the FAIL message.

```sh
+  if [ "$(grep -nF -- "$spec_rule" "$f" | cut -d: -f1)" -ne "$(($(grep -nF -- "$step_rule" "$f" | cut -d: -f1) + 2))" ]; then
```

hard findings: 0
