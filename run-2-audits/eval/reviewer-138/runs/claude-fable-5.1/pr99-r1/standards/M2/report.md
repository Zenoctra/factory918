## Would break

## Fails open

## Standards breaches

## Fix alongside

1. **`hole:` is found by substring, so prose that says "hole:" reads as a field.** Judgement call (Primitive Obsession: a field told apart from a word by a bare substring). `fixed:` and `ticket:` are `$`-anchored to their value grammar; `hole:` is not, so a Noted reason such as "not a design hole: the table stands", or a title `**Not a hole: a could-not-run refusal.**`, is refused as a field under Noted or as a field fitting no form. Both refusals are loud and say what to change, so this is the design, not a finding; but a review about design holes will write the word often. If a would-break fix touches `holed()`, look for the field after the title's closing `**` rather than anywhere on the line, keeping table B column E's trailing-text refusal.

```sh
holed() { items "$dir/judgment.md" "$1" | grep -vE "$ending" | grep 'hole:' || true; }
```

2. **The `[S<n>]`/`[P<n>]` extraction is written twice.** Duplicated Code: the same sed appears in the reference-set loop and again in the hole loop. A one-line function (`ref_of()`) beside `title()` would hold it once.

```sh
  ref_id="$(printf '%s' "$line" | sed -nE 's/^[0-9]+\. \[([SP][0-9]+)\].*/\1/p')"
```

3. **`stepless` no longer says what it does.** Mysterious Name: after taking the regex as a parameter it finds the first counted item lacking any required line, and is called for `spec:` as well as the step. `lacking` or `without_line` would read as it is used.

```sh
line="$(stepless "$f" '^Documented step:')"
...
line="$(stepless "$f" "^spec: $ref\$")"
```

Verified: ShellCheck 0.11.0 clean over the five changed shell files; `tests/spec-review/review-brief.sh` (414 assertions), `review-comment.sh` (134) and `no-stale-wording.sh` pass; the three rewritten patches apply with `git apply --check` to the pinned upstreams under `research/` and yield the template copies byte for byte; every `# shellcheck disable=` added carries its reason on the line; "Four trailing fields", "three artifacts" and "three forms" are true counts at this commit; `SOURCES.md` items 4, 6 and 12 describe the patch changes as the vendoring rule asks.

hard findings: 0
