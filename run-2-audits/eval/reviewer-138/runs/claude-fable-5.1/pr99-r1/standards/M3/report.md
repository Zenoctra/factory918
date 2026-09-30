## Would break

## Fails open

## Standards breaches

## Fix alongside

1. **Duplicated Code: the `[S<n>]`/`[P<n>]` extraction is written twice.** The same `sed -nE` that pulls a judgment item's reference now appears in the reference-set loop and again in the `hole:` loop; one `ref_of <line>` helper beside `title()` would serve both. Judgement call; it changes no behavior.

```sh
  ref_id="$(printf '%s' "$line" | sed -nE 's/^[0-9]+\. \[([SP][0-9]+)\].*/\1/p')"
  [ -n "$ref_id" ] || fail "$dir/judgment.md item '$line' does not open with [S<n>] or [P<n>], the report item it judges"
...
  mark="$(printf '%s' "$line" | sed -E "s#.*hole: ($ref)\$#\1#")"
  ref_id="$(printf '%s' "$line" | sed -nE 's/^[0-9]+\. \[([SP][0-9]+)\].*/\1/p')"
```

2. **Mysterious Name / hidden input: `holed` reads the global `$dir` while its siblings take the file.** `items`, `count`, `specs` and `stepless` all take `<file>` as their first argument; `holed <heading>` alone reaches for `$dir/judgment.md` itself, so its shape differs from the helpers it sits among. Passing the file, or naming it `holed_judgment`, would make the difference visible. Judgement call.

```sh
# holed <heading>: the judgment items under the heading whose line carries a `hole:` field.
holed() { items "$dir/judgment.md" "$1" | grep -vE "$ending" | grep 'hole:' || true; }
```

What was checked and held: `set -euo pipefail` in both scripts and all three tests; every path quoted; the new `sed -E`, `grep -E`, `awk -v` and `head -1` forms run the same on BSD and GNU (both test suites pass on this macOS host, 134 and 414 assertions); every new `|| true` guards a `grep` no-match, not a failure; the one new `# shellcheck disable=SC2016` in `tests/spec-review/review-comment.sh` carries its reason on the same line and sits above the one `printf` that needs it; ShellCheck at the pin is clean; `tests/spec-review/no-stale-wording.sh` passes; the three patches apply with `git apply --check` to the pinned upstreams under `research/` and reproduce the three template files byte for byte; the babysit sentence in `babysit/SKILL.md` and `poteto-mode/playbooks/babysit.md` is byte-identical; the `ref=` line is identical in both scripts; the counts in prose ("Four trailing fields", "three forms", "three artifacts") match the text they describe; `SOURCES.md` items 4, 6 and 12 describe the patches as they now stand.

hard findings: 0
