## Would break

## Fails open

## Standards breaches

## Fix alongside

1. **`want` holds two unrelated things in one scope.** `review-comment.sh` line 150 sets `want` to the expected `[S<n>]`/`[P<n>]` set; the hole loop at line 188 reassigns it to a report item's `spec:` value. It is not read after line 154, so nothing breaks, but the same file renames the loop variable `ref` to `ref_id` in this diff to avoid exactly this collision with the new `ref=` grammar, and leaves `want` doubled. Mysterious Name: a second name (`rests_spec`, `on`) would keep each reading honest.

```
want="$(awk -v s="$s_total" -v p="$p_total" 'BEGIN { ... }' | sort)"
...
  at="${rests%%$'\t'*}"; want="${rests#*$'\t'}"
```

2. **The reference grammar is a third verbatim copy across the two scripts.** `ref=` is byte-identical in `review-brief.sh:134` and `review-comment.sh:57`, joining `fenced=` as a fragment kept in step by `tests/spec-review/review-brief.sh`'s `fragment()`. Duplicated Code, and deliberate: both scripts ship standalone into a project, so a shared file would be a third vendored artifact. The test was extended to cover the new line, which is the right guard; noting it only so the next copied fragment gets the same treatment rather than a fourth one-off.

```
ref='(table [^[:space:]/]+/[^[:space:]/]+|design [^[:space:]].*|criterion [1-9][0-9]*)'
```

3. **The new brief-ordering checks pass when their `grep` finds nothing or finds two lines.** `grep -nF ... | cut -d: -f1` yields an empty string or two lines, `[ "" -ne N ]` and `[ $'1\n7' -ne N ]` both error out of `[`, and inside an `if` condition under `set -e` that is taken as false, so the check reports success. Each is guarded by a `has` assertion one line above, so the suite still fails on a missing rule; the position check alone is what can pass for the wrong reason.

```
  if [ "$(grep -nF -- "$spec_rule" "$f" | cut -d: -f1)" -ne "$(($(grep -nF -- "$step_rule" "$f" | cut -d: -f1) + 2))" ]; then
    echo "FAIL $f: the spec rule does not follow the step rule"; exit 1
  fi
```

hard findings: 0
