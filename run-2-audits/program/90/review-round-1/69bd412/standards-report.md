## Would break

1. **A judgment reason that says "hole:" is read as a `hole:` field.** `fixed:` and `ticket:` are detected `$`-anchored, so those words are safe in prose; `holed()` instead greps `hole:` anywhere on the line, then refuses every match that does not end in a reference. An unmarked item whose one-line reason uses the term this change introduces ("Not a design hole: the table stands.") is refused as a malformed mark under Act on, and as a misplaced mark under Ask, Consider, Noted or Dismissed. The refusal names a field the item does not carry, so it does not say how to correct it.
Documented step: ticket #90, table B, row 1 column A, "as today; counted / 0 / fix on the PR, unchanged"; the contract reads "the judgment field on an Act on item's own line, `$`-anchored like `fixed:` and `ticket:`".
Result: `review-comment.sh` exits 1 with "has a 'hole:' field that fits no form" (or "carries a 'hole:' field under '## Noted'"), clears nothing, and the round's comment cannot be built until the reason is reworded.
spec: table 1/A

```sh
ending='(fixed: [0-9a-f]{7,40}|ticket: #[0-9]+)$'
# holed <heading>: the judgment items under the heading whose line carries a `hole:` field.
holed() { items "$dir/judgment.md" "$1" | grep -vE "$ending" | grep 'hole:' || true; }
```

## Fails open

## Standards breaches

## Fix alongside

2. **Three globals reused inside the hole loop.** `want` held the expected `[S<n>]`/`[P<n>]` set twenty lines up, and `f` and `at` are new globals in a file whose other helpers declare `local`. Names of their own would keep the reader from carrying two meanings of `want`.

```sh
  rests="$(specs "$f" | sed -n "${ref_id#[SP]}p")"
  at="${rests%%$'\t'*}"; want="${rests#*$'\t'}"
```

3. **The human's merge checklist still reads the count alone.** `docs/knowledge/core/MANUAL.md:103` says a PR is ready when "`spec-review`'s last line on the latest commit reads `act-on items: 0`"; a comment whose only Act on items are holes prints `restart` and `act-on items: 0`. The ticket's Files touched leaves `MANUAL.md` to the owner, so this is noted, not asked for.

hard findings: 1
