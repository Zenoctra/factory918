## Walk

1. `review-brief.sh` now writes `<dir>/reviewed` (`git rev-parse HEAD`) beside `<dir>/round`, on one code path shared by the normal and sweep forms (criterion 2, table A row 20).
2. `review-brief.sh` extracts the deciding (last) comment from the fetched/previous history, and from it reads the `would-break fixed after <sha>` line (outside fenced text, last such line wins), whether the round had a spec, and the Act on lines ending `fixed: <sha>` (criterion 1/2, Terms).
3. A malformed `would-break fixed after` line (not exactly 40 lowercase hex) is refused (`FM`) before any other round-gate check, before `mkdir -p "$dir"`, the empty-diff refusal and the blast-radius refusal (contract, table A legend).
4. A round past five is refused (`F6`) before the round-past-three checks (table A row 11).
5. A round past three with no WB line, or whose round number is not `top + 1`, is refused as `F4` (top ≤ 3) or `F5` (otherwise) (table A rows 1, 2, 8).
6. A round past three with a WB line and `round == top + 1` requires the fixed point to resolve (`FR`) and equal the WB sha (`FP`), and requires `--ticket` when the previous round had a spec and the fix commits name none (`FT`), in that order (table A rows 3-6, 10).
7. From round four on, `common()` prints `## The fix under review` (the `fix_rule` paragraph plus the deciding comment's fixed Act on items) before `## Diff`, and the round cap becomes 5 (`cap=3; ... || cap=5`, identical in both scripts).
8. `review-comment.sh` computes the same cap, and — when a fixed Act on item's report heading is `Would break` and no item is a design hole — prints `would-break fixed after <sha>` from `<dir>/reviewed`, refusing (`RM`) when that file is missing or not a full 40-hex id; the reviewed file is read only when the line is needed (table B rows 3-5, 7, 9; contract).
9. `poteto-mode/playbooks/ticket.md` step 8 routes a comment carrying the WB line to a new **Would-break fix** section before babysit, mirroring the Design-hole routing for `restart`.
10. `babysit/SKILL.md`, `poteto-mode/playbooks/babysit.md` (and their patches, and `SOURCES.md` items 4/12) carry one byte-identical merge-ready sentence stating that a WB-line comment is never review-ready below round five and is the human's wait at `round: 5 of 5`; the brief test pins this string in both files.
11. `spec-review/SKILL.md` step 5 states the two-stop prose (look for the cause at round three; report and mark the PR unfinished at round five) with no round-to-round hard-count comparison, per the Decision quotes in the ticket.
12. `DECISIONS.md` P20 is amended and P30 added; `docs/agents/review-ladder.md` rung 1 gains the one sentence; `tools/build_knowledge.py`'s output (`template/docs/factory918/*`) and `docs/knowledge/INDEX.md`'s line count are regenerated consistently.
13. `tests/spec-review/review-brief.sh` and `review-comment.sh` add fixtures and assertions for rounds four and five, one per table cell, plus the `fragment()`/`cap=3;` anti-drift pin and the babysit-sentence pin; `no-stale-wording.sh` blacklists "at most three rounds".

Traced against the contract and scenario tables cell by cell (refusal message text, ordering of `FM`/`F6`/`F4`/`F5`/`FR`/`FP`/`FT`, the `fixed_items`/`j`/`h` awk state machine, the `holes`/`wb_first`/`reviewed` gating in `review-comment.sh`, and the byte-identical `cap=3;` and babysit-sentence pins), the implementation matches the design at every row and column checked, including the edge cases in rows 12-19 (a WB line at round one or two, a restart after a WB comment, a hand-written malformed line, CRLF, the sweep form, and a rebuilt round three).

## Would break

## Fails open

## Not asked for

hard findings: 0
