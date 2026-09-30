## Would break

## Fails open

## Standards breaches

## Fix alongside

1. **Mysterious Name: `stepless` now checks for any line.** The function took a regex argument and now also finds items that have no `spec:` line. The name still says it looks for a missing step. A name like `lacking <file> <regex>` would describe both calls.

```sh
line="$(stepless "$f" "^spec: $ref\$")"
```

2. **Duplicated Code: the reference-id sed and the trailing-field regexes appear twice.** The `[S<n>]`/`[P<n>]` extraction is now written twice in `review-comment.sh`, once in the refs loop and once in the hole loop. `ending` repeats the `fixed:` and `ticket:` patterns that `fixed_here` and `ticketed` grep for separately a few lines below. Each pair can drift apart.

```sh
  ref_id="$(printf '%s' "$line" | sed -nE 's/^[0-9]+\. \[([SP][0-9]+)\].*/\1/p')"
...
ending='(fixed: [0-9a-f]{7,40}|ticket: #[0-9]+)$'
...
fixed_here="$(items "$dir/judgment.md" "Act on" | grep -cE 'fixed: [0-9a-f]{7,40}$' || true)"
ticketed="$(items "$dir/judgment.md" "Act on" | grep -cE 'ticket: #[0-9]+$' || true)"
```

3. **Judgement call: `holed` matches `hole:` anywhere on the line.** The `fixed:` and `ticket:` fields only count at the end of the line, but `holed` matches `hole:` anywhere. A title or reason like `**Whole: file read.**` or "not a hole: the table stands" gets flagged as a hole field. Under Act on, it is refused with "fits no form". Under Noted or Dismissed, it is refused with "carries a 'hole:' field". The run fails loudly, so this is not a hard finding, but the refusal message points at the wrong cause. Anchoring the second grep (for example, `grep -E ' hole: [^ ]'`, or matching `hole: ` only after the last `**`) would stop ordinary prose from triggering it.

```sh
holed() { items "$dir/judgment.md" "$1" | grep -vE "$ending" | grep 'hole:' || true; }
```

Verified at the reviewed tree: `tests/spec-review/review-comment.sh` (134 assertions), `tests/spec-review/review-brief.sh` (414), `tests/spec-review/no-stale-wording.sh` and ShellCheck 0.11.0 over the five changed shell files all pass. The new `# shellcheck disable=SC2016` directive gives its reason and covers a single statement. Every new path expansion is quoted. The new counts in the prose ("Four trailing fields", "Three artifacts", "the four shapes") are true at this commit.

hard findings: 0
