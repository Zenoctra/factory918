## Walk

1. `review-brief.sh` computes `top` from `round: N of [35]` lines, takes the last (deciding) comment of the history, and extracts its `would-break fixed after <sha>` line, whether it had a spec, and its fixed Act on items.
2. It refuses, in order, a malformed WB line (`FM`), a sixth round (`F6`), a fourth/fifth round not licensed by the WB line (`F4`/`F5`), a WB sha that does not resolve (`FR`), a fixed point other than that sha (`FP`), and a fix-only round with no ticket after a spec round (`FT`) — all before `mkdir -p "$dir"`.
3. On success it writes `<dir>/round`, then `git rev-parse HEAD` to `<dir>/reviewed` (both forms, one code path), prints `round: N of $cap` with `cap=3` through round three and `cap=5` after, and, from round four, embeds `## The fix under review` with `$fix_rule` and the fixed items in both briefs before the diff.
4. `review-comment.sh` finds the first Would-break Act on item ending `fixed: <sha>` (via `specs()` against the item's report), and, when no hole is marked, prints `would-break fixed after <sha>` from `<dir>/reviewed`, refusing if that file is missing or not a 40-hex id; it prints `restart` instead when a hole exists, and neither when no Would-break item was fixed.
5. `round: N of $cap` and `act-on items: N` are unchanged in shape; the summary line never counts how many fixes were would-break.
6. `SKILL.md`, `ticket.md`, both `babysit` copies, `review-ladder.md`, `MANUAL.md`, `SOURCES.md` and `DECISIONS.md` (P20, P30) are updated with matching prose; `no-stale-wording.sh` blacklists the old "at most three rounds" phrasing.

## Would break

## Fails open

## Not asked for

hard findings: 0
