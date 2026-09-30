## What to build

Simplify the fix-only round three that PR #125 (ticket #106) added. Round three reviews only round two's fixes exactly when round two's reports hold no hard item (Would-break or Fails-open, either axis) at all. The "inside the fix" rule and what exists only to serve it go: `fix-lines`, `fix-ranges`, the quoted-hunk location matching, and the `reviewed:` line if nothing else reads it.

> agent (the #106 owner, report, 2026-09-23): "Fix-only could require that round two reports no hard item at all. That would drop the inside rule, `fix-lines`, `fix-ranges` and the `reviewed:` line. It gives the same verdict on every real round two measured."

> agent (the root, 2026-09-23): "On every real round two measured so far, the simpler rule gives the same answer. Being simpler, it can't misjudge where a finding sits, so I'd lean toward it."

> Manuel (2026-09-23): "If you have a lean, then go for it."

Why: the first inside rule failed open (a plain quote of untouched code sharing one line with the fix made round three fix-only; the verifier reproduced it). The redesign closed that hole but kept one contrived false-inside and a lot of matching code. Manuel's bar in #106 is "at least one pass goes with zero new happy path hard bugs found before we commit ourself to diff only reviews". A round two with zero hard items meets that bar directly.

Files: `template/.agents/skills/spec-review/scripts/review-brief.sh`, `template/.agents/skills/spec-review/scripts/review-comment.sh`, `tests/spec-review/review-brief.sh`, `tests/spec-review/review-comment.sh`, `template/.agents/skills/spec-review/SKILL.md` (via `patches/mattpocock/spec-review.SKILL.md.patch`), `template/.agents/skills/babysit/SKILL.md` and `template/.agents/skills/poteto-mode/playbooks/babysit.md` (via their patches), `docs/knowledge/core/DECISIONS.md`.

## Acceptance criteria

- [ ] Round three is fix-only when, and only when, round two's two reports hold no hard item. Rounds one and two, rounds four and five, the three-round cap and the restart route behave as they do at PR #125's head.
- [ ] The inside rule's code, its state files and its tests are deleted. `review-brief.sh` and `review-comment.sh` are shorter than at #126's head, and no test asserts a location match.
- [ ] #106's table cells that the inside rule decided are amended on #106 with a dated line, and each surviving cell has one assertion.
- [ ] P106 is amended, or superseded by P<N>, to say that the inside rule was removed and why.
- [ ] `spec-review/SKILL.md` (through its patch) and babysit say the simpler rule.

## Blocked by

None. This stacks on the run-2 chain (#120, #121, #124, #125, #126, #129).




## Testing decisions

Posted by the agent 2026-09-23

The scenario table for this ticket is #106's `## Testing decisions`, tables A and B as amended on 2026-09-23 by #125. The cells below are the ones this ticket changes; every other cell of #106's tables keeps its outcome, and so does every cell of #93's, #90's and #107's. A review finding that changes a cell below, or a cell this section leaves standing, is a design hole under #90's rule.

### Terms

Deleted: the "RV line" (`reviewed: <sha>`), the "fix lines" (`<dir>/fix-lines`), the fix ranges (`<dir>/fix-ranges`), "quoted lines", "named locations" and "inside the fix". `<dir>/reviewed` and `<dir>/files` stay: the WB and FO lines and the brief read them.

A "hard item" is unchanged: a numbered item under `## Would break` or `## Fails open` in the Standards report, or in the Spec report when the review has a spec, whatever the judgment does with it.

The "FO line" is `fix only after <sha>`, printed by `review-comment.sh` on a round-two comment that marks no hole when `<dir>/reviewed` holds 40 lowercase hex and neither report holds a hard item. `<sha>` is round two's reviewed commit. The brief reads it exactly as before.

An RV line in a comment posted before this ticket is ordinary text: no script reads it.

### Table A, changed cells (`review-brief.sh`)

| Cell | Before | After |
|---|---|---|
| 1A to 1C | ... no ff | the same without "no ff": no file but `<dir>/reviewed` is written |
| 2A to 2C | (1R r1): `R(2)`, S, `= today`; ff `r1` | (1): `R(2)`, S, `= today`; no ff exists. A (1R r1) comment from before this ticket gives the same output as (1) |
| 3A to 3C | (1R+ r1): as row 2, ff `r1` | (1+), round one with fixes and the owed line: as row 2 |
| 4A to 4C | (1R r1),(2): whole diff, no ff | (1),(2): whole diff |
| 5, 6 | row 5: hard items only inside the fix; row 6: no hard item; both (2F r2) | one row: (1),(2F r2), round two with no hard item. Row 6 has no assertion of its own: the brief reads the same line |
| 13 | an FO line on a round-one comment, or an RV line on a round-two comment | an FO line on a round-one comment is not read (unchanged); the RV clause is deleted |
| 20 | (1),(2F r2) with an old round-one comment | merged into row 5, since round one now carries no line |
| 22 | `<dir>/reviewed`; ff in rows 2 and 3 | `<dir>/reviewed` only; `<dir>/fix-lines` and `<dir>/fix-ranges` never exist |

`= today` compares against the same history with every owed and FO line deleted, and every RV line too, so a history written under #125 still compares equal.

### Table B, changed cells (`review-comment.sh`)

Columns: A is round one (`<dir>/round` absent or `1`), B is round two, D is rounds three to five. Column C (round two with no fix lines) is deleted: with no fix lines there is nothing to tell it from B.

| Row | A (round one) | B (round two) |
|---|---|---|
| 1. No hard item, nothing marked `fixed:` | `round: 1 of 3` / 0, no RV (was `RV`) | `FO` (unchanged) |
| 2. Every hard item "inside the fix" | no RV | no `FO` (was `FO`): a hard item exists |
| 3. A hard item outside the fix | no RV | no `FO` (unchanged) |
| 4. A hard item with no fenced block | no RV | no `FO` (unchanged) |
| 5. A Spec hard item quoting its ticket line | no RV | no `FO` (unchanged) |
| 6. A hard item quoting a removed or an added fix line | no RV | no `FO` (the added-line case was `FO`) |
| 7. An Act on item marked `fixed:` | `OW(2)` alone (was `OW(2)`, `RV`) | `OW(3)`, then `FO` only when no hard item |
| 8. A Would-break fix | WB, `OW(2)` (was WB, `OW(2)`, `RV`) | WB, `OW(3)`, no `FO` (was `FO` per rows 1 to 6): a Would-break fix means a hard item |
| 9. A hole | `restart` alone (unchanged) | `restart` alone (unchanged) |
| 10. `<dir>/reviewed` missing or malformed, no Would-break fix | as row 1A: nothing to omit (unchanged output) | no `FO` (unchanged) |
| 12. A `## Walk` line holding a fenced quote | not an item (unchanged) | with no hard item: `FO` |
| 14, 15 | deleted: they decided the location rule | deleted |

New cell, row 16: no spec (`<dir>/spec-brief.md` absent) at round two, no Standards hard item, a stray `spec-report.md` holding a Would-break item: `FO`, since the Spec report is read only with a spec.

Rows 11 and 13 and every column-D cell are unchanged.

### Tests

The writer deletes the tests of the deleted terms (every `fix-lines`, `fix-ranges` and RV assertion, rows 14 and 15, the brief test's `ff` and `no_ff` helpers and the unique-text fixtures) and keeps one assertion per surviving cell above, labelled with the cell, in the test commit before the script commit. Existing round-one accepts drop the `reviewed:` line from their expected output; no other existing expectation moves. `wc -l` of both scripts falls below their line counts at #126's head (563 and 318).
