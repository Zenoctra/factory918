## Would break

## Fails open

## Standards breaches

## Fix alongside

1. **`hole:` followed by a trailing `fixed:` or `ticket:` is absorbed silently.** `holed()` drops any judgment line matching `$ending` before looking for `hole:`, so `... hole: table 2/D fixed: abc1234` is counted as a fix, no `restart` is printed, and the design hole never reaches `architect`. This is the documented design (SKILL.md step 5, "the field that ends the line is the field"; DECISIONS P26) and the script's own comment argues the asymmetry deliberately, so it is not a breach — but it is the one place where a mis-written mark is swallowed rather than shown, which the same comment says was the thing to avoid for every other malformed `hole:`. A cheap hardening, if a would-break fix ever touches this block, is to refuse a line that carries `hole:` *and* ends in `fixed:`/`ticket:` with both values shown.

```sh
ending='(fixed: [0-9a-f]{7,40}|ticket: #[0-9]+)$'
holed() { items "$dir/judgment.md" "${1:-}" | grep -vE "$ending" | grep 'hole:' || true; }
```

2. **The summary line does not name the holes it subtracted.** `review-comment.sh` prints `act on N ($fixed_here fixed, $ticketed with a ticket)` and then subtracts `holes` from the count as well, so a reader comparing the summary to `act-on items:` sees an unexplained gap; the bare `restart` line is the only signal. Naming holes in the same parenthesis would cost one word and keep the three exclusions visible together.

```sh
echo "Standards: ... judged: act on $act ($fixed_here fixed, $ticketed with a ticket), ask $ask, ..."
[ "$holes" -eq 0 ] || echo restart
echo "round: $round of 3"
echo "act-on items: $((act - fixed_here - ticketed - holes + ask))"
```

Checked and clean: the `ref=` grammar is identical in both scripts and pinned by a test; `\$` inside the double-quoted awk `-v` assignments reaches awk as a literal anchor; `specs()` indexes items the same way `items()` numbers them (Walk excluded), so `${ref_id#[SP]}` addresses the right row; `has_spec` is set before the first `report()` call; the restart-slicing awk normalizes CR and trailing whitespace through `$split` before testing `$0 == "restart"` and re-derives separator positions from `raw`, so a fenced or suffixed `restart` is inert; every new path quotes its paths and the one new `disable=` directive carries its reason; the `lines:` counts in `INDEX.md` and `DECISIONS.md` both move 93 to 94 with the one added row.

hard findings: 0
