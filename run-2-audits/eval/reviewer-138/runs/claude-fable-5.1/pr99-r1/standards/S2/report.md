## Would break

## Fails open

## Standards breaches

## Fix alongside

1. **Duplicated Code: the judgment reference is parsed twice.** The `[S<n>]`/`[P<n>]` extraction that `title()` was factored beside is repeated verbatim in the reference-set loop and again in the hole loop of `review-comment.sh`. A `ref_of()` helper next to `title()` would hold the one grammar once.

```sh
  ref_id="$(printf '%s' "$line" | sed -nE 's/^[0-9]+\. \[([SP][0-9]+)\].*/\1/p')"
  [ -n "$ref_id" ] || fail "$dir/judgment.md item '$line' does not open with [S<n>] or [P<n>], the report item it judges"
...
  mark="$(printf '%s' "$line" | sed -E "s#.*hole: ($ref)\$#\1#")"
  ref_id="$(printf '%s' "$line" | sed -nE 's/^[0-9]+\. \[([SP][0-9]+)\].*/\1/p')"
```

2. **Primitive Obsession: `hole:` is detected by a bare substring where `fixed:` and `ticket:` are `$`-anchored fields.** `holed()` greps `hole:` anywhere on the line, so a Noted reason such as "a design hole: not here. cites: DECISIONS.md P3" is refused as "carries a 'hole:' field under '## Noted'", and an Act on reason "the hole: is elsewhere" as a field fitting no form (both run against the scratch copy; each is a refusal with a message, so neither counts). The ticket's own note says only the field that ends the line is a field; anchoring the detection as the other two are (`hole: [^ ].*$` for placement, then the grammar) would make the three fields one shape and the refusal text true.

```sh
ending='(fixed: [0-9a-f]{7,40}|ticket: #[0-9]+)$'
# holed <heading>: the judgment items under the heading whose line carries a `hole:` field.
holed() { items "$dir/judgment.md" "$1" | grep -vE "$ending" | grep 'hole:' || true; }
```

3. **Duplicated Code: the line-stripping rule appears twice in the restart awk.** The `split` fragment already strips CR and trailing blanks from `$0`; the END block re-derives the same strip from `raw[NR]` to find separators. Recording `at[NR]` and separator hits in the per-line pass (where `$0` is already stripped) would drop the second copy.

```sh
  sliced="$(printf '%s\n' "$bodies" | awk -v sep="$rs" '{ raw[NR] = $0 }'"$split$fenced"'
    $0 == "restart" { hit[NR] = 1 }
    END {
      c = 0; last = -1
      for (i = 1; i <= NR; i++) { t = raw[i]; sub(/\r$/, "", t); sub(/[ \t]+$/, "", t); at[i] = c; if (t == sep) c++; else if (hit[i]) last = c }
```

Verified: ShellCheck at the pin over the set (20 files, no findings); `tests/spec-review/review-brief.sh` (414), `review-comment.sh` (134), `no-stale-wording.sh`, `tests/shellcheck/gate.sh`, `tests/hooks/delegation.sh` all pass in a git copy of this commit; `./factory918.sh sync` re-applies all 17 patches and leaves the tree clean; the babysit paragraph and bullet are byte-identical; no `docs/knowledge/core/` or generated file is touched.

hard findings: 0
