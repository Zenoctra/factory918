## Would break

## Fails open

## Standards breaches

## Fix alongside

1. **Duplicated Code: the `[S<n>]`/`[P<n>]` extraction is written twice.** The new hole loop repeats the reference-check loop's sed word for word; a change to the reference form has to hit both. One small function (`ref_of <line>`) called from both loops removes the copy.

```sh
  ref_id="$(printf '%s' "$line" | sed -nE 's/^[0-9]+\. \[([SP][0-9]+)\].*/\1/p')"
```

2. **Duplicated Code: `ending` restates the `fixed:` and `ticket:` field grammar.** The same two patterns appear again a few lines below as `fixed_here` and `ticketed`, so the file now holds two copies of the field grammar that decide the count. If they drift, a line could be excluded from `holed` but still not counted as fixed, or the reverse. Name the two patterns once and build `ending` from them.

```sh
ending='(fixed: [0-9a-f]{7,40}|ticket: #[0-9]+)$'
...
fixed_here="$(items "$dir/judgment.md" "Act on" | grep -cE 'fixed: [0-9a-f]{7,40}$' || true)"
ticketed="$(items "$dir/judgment.md" "Act on" | grep -cE 'ticket: #[0-9]+$' || true)"
```

3. **Mysterious Name: `want` holds two different things in one scope.** In `review-comment.sh`, `want` first holds the expected reference set (`S1..Sn P1..Pn`). The hole loop then reuses it for the judged item's `spec:` value, and `at` and `f` are reused as globals in the same way. Nothing reads the old value afterwards, so behavior is unchanged, but the reader has to track which meaning is live. `spec_value` and `spec_heading` would make the loop clear on its own.

```sh
  at="${rests%%$'\t'*}"; want="${rests#*$'\t'}"
  [ -n "$want" ] || fail "... carries no 'spec:' line: it is under '## $at' in $f, not a counted item"
```

4. **The header comment's "such comment" now points at the restart comment.** In `review-brief.sh`'s header, the new restart sentence comes right before "From every such comment", so "such comment" now reads as the restart comment. The code does the opposite and drops the restart comment's items. A reader of the header gets the carry rule backwards. Write "From every review comment after the last restart, in order, …" as the new comment above `cites=` already does.

```sh
# so. From every such comment, in order, the judgment's Noted and Dismissed items that cite a
# decision are carried into both briefs as settled, each line once; --previous FILE supplies the
```

Checked: ShellCheck 0.11.0 is clean on the five changed shell files. `tests/spec-review/review-comment.sh` passes (134 assertions), `review-brief.sh` passes (414) and `no-stale-wording.sh` passes. `./factory918.sh sync` on a scratch copy leaves no drift, so the patches reproduce the template. The one new `shellcheck disable` carries its reason on the same line and applies to only one statement.

hard findings: 0
