## Would break

## Fails open

## Standards breaches

## Fix alongside

1. **`holed` matches `hole:` anywhere on the line.** The field is defined as the one that *ends* the line, but the detector is a bare substring grep, so an Act on item whose prose says "hole:" (likely wording here, e.g. "the design hole: the cell is wrong") is picked up and then refused as a field that "fits no form". Anchor the second grep the way `fixed_here` and `ticketed` are anchored.

```sh
holed() { items "$dir/judgment.md" "$1" | grep -vE "$ending" | grep 'hole:' || true; }
```

2. **The summary line hides the holes it subtracts.** `$holes` is taken out of `act-on items` but never named, so a person reads `act on 2 (0 fixed, 0 with a ticket)` above `act-on items: 1` and has only the bare `restart` line to reconcile the two. `fixed` and `ticket` both earn a parenthetical; the hole should too.

```sh
echo "Standards: ... judged: act on $act ($fixed_here fixed, $ticketed with a ticket), ask $ask, ..."
[ "$holes" -eq 0 ] || echo restart
echo "round: $round of 3"
echo "act-on items: $((act - fixed_here - ticketed - holes + ask))"
```

3. **"word for word" names the line, the script compares the value.** SKILL.md step 5 and the ladder say `hole:` "repeats the judged report item's `spec:` line word for word", but the report item's line is `spec: table 2/D` and the judgment field is `hole: table 2/D`; only the reference after the prefix is compared (`v = substr($0, 7)` against the `hole:` capture). The refusal text gets this right ("rests on '$want'"); the two prose copies should say the reference, not the line.

```
- `hole: <reference>` on an Act on item ... it repeats the judged report item's `spec:` line word for word
```

hard findings: 0
