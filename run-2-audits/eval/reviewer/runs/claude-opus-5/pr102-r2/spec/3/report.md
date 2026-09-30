## Walk

1. A round whose Act on items include a Would-break fix earns another round past three, to five. `review-comment.sh` resolves each `fixed:` Act on line's `[S<n>]`/`[P<n>]` through `specs()`, prints `would-break fixed after <sha>` when the heading is `Would break` and no hole is marked, and `review-brief.sh`'s gate licenses round `top + 1` only when the deciding comment carries that line; `round > 5` is refused with F6.
2. A round whose fixes are all Fails-open items, standards breaches or prose prints no line, so the round may be the last (table B rows 2, 6, 8; the cap line `cap=3; [ "$round" -le 3 ] || cap=5` is byte-identical in both scripts and pinned by `fragment()`).
3. A round past three reviews the fix only: `FP`/`FR` require the fixed point to be the commit the line names, `FT` requires `--ticket` when the fix commits name none and the previous round had a spec, and `common()` emits `## The fix under review` with `$fix_rule` and the deciding comment's `fixed:` lines from round four on, before `## Diff`. `<dir>/reviewed` is written once, after `<dir>/round`, in both forms.
4. No rule compares hard-finding counts: neither script counts would-break fixes, and the summary line is unchanged. `SKILL.md` step 5 carries the two judgment stops (look at three, report plus `gh pr ready --undo` at five); `ticket.md` gains `### Would-break fix` with no step renumbered.
5. Babysit's merge-ready sentence is replaced byte-identically in `playbooks/babysit.md` and `babysit/SKILL.md`, both pinned by `has` in the brief test; a PR ending at `round: 3 of 3` with no line reads exactly as before.
6. `tests/spec-review/review-brief.sh` adds one assertion per table A cell (rows 1-20) and `review-comment.sh` one per table B cell; `no-stale-wording.sh` blacklists `at most three rounds`, and no hit remains under `template/` or `docs/knowledge/core/`.
7. P20 carries the #93 amendment, P30 is added, `review-ladder.md` rung 1 says it in one sentence, `MANUAL.md`'s merge checklist gains the line, and `INDEX.md`'s count moves 97 to 98.

## Would break

## Fails open

1. **A round-three comment rebuilt after round four silently licenses a fifth round.** `review-brief.sh` allows a round past three when the deciding comment carries the WB line and `round -eq top + 1`, but never checks that the deciding comment is itself the round-`top` comment. `SKILL.md` step 6 documents rerunning `review-comment.sh <dir>` on an earlier round's dir after the human answers an Ask, which reposts that round's comment; with a history `(1) (2) (3W s) (4)`, a rebuilt `(3W s)` posted after `(4)` makes `top` 4, `round` 5 and `wb` round three's commit, so the run is accepted and briefs `s...HEAD`, which is round four's fix commits as well as round three's.

Documented step:

```
| 8. (1), (2), (3W s), (4), any fixed point | `F5` / 1 / nothing to run: the PR was review-ready at (4) |
```

Result: no refusal; the brief prints `round: 5 of 5` and writes state, so a PR that row 8 calls review-ready gets a fifth round from the wrong commit instead of a message naming the correction.

spec: table 8/A

## Not asked for

hard findings: 1
