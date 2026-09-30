## Walk

1. Round one to three brief: `review-brief.sh` computes `top` from `round: N of [35]` lines, prints `round: N of 3`, writes `<dir>/round` and `<dir>/reviewed` (= `git rev-parse HEAD`) in both forms; a history without the WB line behaves as before, `F4` byte-identical.
2. Round-three comment with a Would-break fix: `review-comment.sh` resolves each `fixed:` Act on item's `[S/P<n>]` through `specs()`, finds the heading `Would break`, reads `<dir>/reviewed` (refusing `RM` when missing or not 40 hex), prints `would-break fixed after <sha>` between the summary and `round:`; a hole outranks it and prints `restart`.
3. Round-three comment whose fixes are only Fails-open, breaches or prose: no line, `round: 3 of 3`; babysit reads it as today.
4. Round four: the gate cuts the deciding comment, checks the line's form (`FM`), the cap (`F6`), `top + 1` (`F4`/`F5`), resolution (`FR`), fixed point equal to the sha (`FP`), and `--ticket` when the prior round had a spec (`FT`), all before `mkdir`; prints `round: 4 of 5` and puts `## The fix under review` with `fix_rule` and the deciding comment's fixed Act on lines before the diff.
5. Round five: same gate from round four's line; `round: 5 of 5`.
6. Sixth round: `F6` in every case, including a round-five comment carrying the line.
7. Round-five stop: `spec-review` step 5 paragraph, `ticket.md` Would-break fix section and P30 describe the report comment, `gh pr ready --undo`, continuing independent work and waiting; no rule compares counts, and the summary line prints no would-break count.
8. Babysit: both copies carry the byte-identical replacement sentence, pinned by the brief test; a PR ending at `round: 3 of 3` without the line reads as before.
9. Docs: `review-ladder.md` rung 1 sentence, `MANUAL.md` merge item, `SOURCES.md` items 4, 6, 12, P20 amended, patches regenerated, `no-stale-wording.sh` blacklists `at most three rounds`.
10. Tests: table A rows 1-20 and table B rows 1-9 each have a named assertion, including round four fix-only (3A, only the fix commit listed) and the round-five stop (3D, 9A, 11A).

## Would break

## Fails open

## Not asked for

1. **Ledger line for a killed lane.** `docs/agents/ledger.md` gains a line about the #93 owner lane resuming a rate-limited lane's scratch; process record, not in the ticket's files touched.

```
`docs/knowledge/core/DECISIONS.md` (P20 and a Provisional row) is the owner's, in its own commit. No new script, no new file under `template/`
```

hard findings: 0
