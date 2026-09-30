## Would break

## Fails open

## Standards breaches

## Fix alongside

1. **Duplicated Code: the reference-id extraction and the trailing-field patterns are written twice in `review-comment.sh`.** The hole loop repeats the `[S<n>]`/`[P<n>]` sed from the refs loop above it, and `ending` restates the two patterns the count greps use further down, so a change to either field's grammar has two places to edit.

```sh
  ref_id="$(printf '%s' "$line" | sed -nE 's/^[0-9]+\. \[([SP][0-9]+)\].*/\1/p')"
...
ending='(fixed: [0-9a-f]{7,40}|ticket: #[0-9]+)$'
...
fixed_here="$(items "$dir/judgment.md" "Act on" | grep -cE 'fixed: [0-9a-f]{7,40}$' || true)"
ticketed="$(items "$dir/judgment.md" "Act on" | grep -cE 'ticket: #[0-9]+$' || true)"
```

2. **Mysterious Name: `stepless` now checks for any required line.** It takes the required line's regex as a parameter and also runs the `spec:` check, but its name still says it finds items with no `Documented step:`. A name like `missing_line` would say what it returns.

```sh
# stepless <file> <regex>: the heading and opening line of the first Would-break or Fails-open item
# with no line matching the regex before the next item or heading; fenced text does not count.
stepless() {
  awk -v want="$2" "$fenced"'
```

3. **Duplicated Code: the restart slicer in `review-brief.sh` copies `split`'s line stripping.** It keeps `raw[NR]` and then applies the CR and trailing-blank `sub`s again by hand to find separators. Every later awk re-strips through `$split` anyway, so the slicer could print the lines `$split` has already stripped and drop both the second copy and the `raw` array.

```sh
  sliced="$(printf '%s\n' "$bodies" | awk -v sep="$rs" '{ raw[NR] = $0 }'"$split$fenced"'
    $0 == "restart" { hit[NR] = 1 }
    END {
      c = 0; last = -1
      for (i = 1; i <= NR; i++) { t = raw[i]; sub(/\r$/, "", t); sub(/[ \t]+$/, "", t); at[i] = c; if (t == sep) c++; else if (hit[i]) last = c }
```

Checked and clean. ShellCheck 0.11.0 passes on the five changed shell files. `tests/spec-review/review-comment.sh` passes 134 assertions, `review-brief.sh` passes 414, and `no-stale-wording.sh` reports ok. Running `./factory918.sh sync` on a copy of the snapshot leaves `git status` clean, so the three patches match the template. Every changed script sets `set -euo pipefail`, and the one new `# shellcheck disable=` carries its reason and applies to a single statement.

hard findings: 0
