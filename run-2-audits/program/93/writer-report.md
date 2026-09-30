# Writer report, ticket #93

Branch `wt/93-writer` from `d8e382ca37233bce98724c785ecdbb677abc4e2a`, three commits, tree clean. The test was written from the two tables first (commit 1, failing at the base), the scripts second (commit 2), the prose, the patches, `SOURCES.md` and the generated copy third (commit 3). No cell was left unimplemented; the cells without a dedicated assertion are named under Cells.

## Commits

1. `41ce42075cbcb3f1b23ac4119e37ac0a2899fc2d` Write the tests for a Would-break fix's extra rounds from the #93 tables
2. `27c43afe5a81cbed432702129014045f91edfa30` Review a Would-break fix once more, in a fourth or fifth round
3. `1998c6965629ecc333354e084c2088f5b56006f8` Say in the prose that a Would-break fix earns another round

Head: `1998c6965629ecc333354e084c2088f5b56006f8`.

Commit 1 was amended once before commit 2 was made (a fixture fix, see Deviations 6). The Contract puts `SOURCES.md` item 6 in the same commit as the SKILL.md patch and lists `no-stale-wording.sh` under Tests, so there is no fourth commit: the stale-wording guard is in commit 1 and `SOURCES.md` in commit 3.

## Cells

Labels are the test's own; "(shares X)" means the cell's outcome is the same code path as cell X and has no assertion of its own beyond X's, as the ticket's test list prescribed.

### Table A (`tests/spec-review/review-brief.sh`)

| Cell | Assertion |
|---|---|
| 1A | existing "first round, no PR" and "a PR without comments is round 1"; "the reviewed file does not hold HEAD (20)" right after the first-round run |
| 1B | existing "fourth round" (`--round 4`, kept); "no comment, --round 5 (1B)"; "no comment, --round 6 (1B)" |
| 1C | shares 1A (an empty `--previous` file has no dedicated assertion) |
| 2A | existing "fourth round from the PR's comments" (F4, kept) |
| 2B | existing "--round overrides the round the comments give" (`--round 3`); "three plain comments, --round 5 (2B)"; `--round 4` shares 1B's F4 |
| 2C | shares 2A |
| 3A | "round four from the reviewed commit (3A)" (printed lines, round file = 4), `fixed_section` on both briefs, "carries the settled items at round four (3A)", `only_commit` and "the commit before s is not listed (3A)" |
| 3B | "--round 4 after (3W) is round four (3B)"; "--round 3 after (3W) rebuilds round three (3B)" with "no fix section (3B)"; "--round 5 after (3W) (3B)" |
| 3C | "round four from a --previous file holding (3W) (3C)" with `fixed_section` |
| 4A | "the original fixed point at round four (4A)" (HEAD~2); "HEAD as the fixed point at round four (4A)" |
| 4B, 4C | share 4A |
| 5A | "the reviewed commit does not resolve (5A)" |
| 5B, 5C | share 5A |
| 6A | "a fix commit naming no ticket after a round with a spec (6A)" |
| 6B, 6C | share 6A |
| 7A | "round four with no spec (7A)" with `fixed_section` on the Standards brief |
| 7B, 7C | share 7A |
| 8A | "a plain round four, the fifth (8A)" |
| 8B | "a plain round four, --round 4 (8B)"; `--round 5` shares 8A |
| 8C | shares 8A |
| 9A | "round five from the commit round four reviewed (9A)", `fixed_section` on both briefs with round four's item and "round three's fixed item is not in round five's section (9A)", `only_commit` |
| 9B, 9C | share 9A |
| 10A | "round five from round three's commit (10A)" |
| 10B, 10C | share 10A |
| 11A | "a plain round five, the sixth (11A)"; "a round five with the line, the sixth (11A)" |
| 11B | "--round 6 (11B)"; `--round 9` shares it |
| 11C | shares 11A |
| 12A | "a Would-break fix at round one: round two from the original fixed point (12A)"; "round two: no fix section (12A)" |
| 12B, 12C | share 12A |
| 13A | "a restart comment after (3W) is round one (13A)"; "round one after a restart: no fix section (13A)" |
| 13B | shares 13A (the `--round N` form after a restart is #90's 5B, kept) |
| 13C | "a --previous comment carrying restart and the line is a restart (13C)" |
| 14A | "a hand-written line reading '<rest>' (14A)", four times: a short sha, uppercase, trailing text, nothing |
| 14B, 14C | share 14A |
| 15A | "the line inside a fenced hunk (15A)"; "the line in a stranger's comment (15A)"; "the line in round two with a plain round three after it (15A)" |
| 15B, 15C | share 15A |
| 16A, 16B | share 3A (the CRLF strip is one line in `split`, #90's assertion "CRLF previous comment carries the same items" kept) |
| 16C | "round four from a CRLF --previous file (16C)" with `fixed_section` |
| 17A | "the sweep form after (3W) (17A)" |
| 17B, 17C | share 17A |
| 18A | "round four with no fix commit (18A)" |
| 18B, 18C | share 18A |
| 19A | "(3) then (3W): round four (19A)" with `fixed_section`; "(3W) then (3): the fourth round refused (19A)" |
| 19B, 19C | share 19A |
| 20 | "the reviewed file does not hold HEAD (20)" after the first-round run; "the sweep form does not record HEAD in the reviewed file (20)"; every refusal assertion checks `.scratch/review` absent |

Anti-drift pins: `fragment()` now holds the `cap=3;` line with `fenced` and `ref` (the copies are compared, and "review-brief.sh has no cap=3; line" guards the grep); "SKILL.md step 4 carries the fix paragraph"; "the babysit playbook carries the merge-ready sentence" and "the babysit skill carries the merge-ready sentence", both from `$here`.

### Table B (`tests/spec-review/review-comment.sh`)

| Cell | Assertion |
|---|---|
| 1A | existing accepts without a fixed item, unchanged (e.g. "two Act on and one Ask, round 2") |
| 1B | existing "an Act on item filed as a ticket is not counted, round 3", unchanged |
| 1C | "no fixed item at round 4 (1C)" |
| 1D | "no fixed item at round 5 (1D)" |
| 1E | `rearm` writes the file for every run; a run without it and without a Would-break fix has no dedicated assertion for row 1 (5E covers "the file is not read" for the hole case) |
| 1F | existing no-spec accepts, unchanged |
| 2A | shares 2B (the line is decided by the heading, the cap by the round) |
| 2B | "a Fails-open item fixed at round 3: no line (2B)"; "a Standards-breaches item fixed at round 3: no line (2B)" |
| 2C | "a Fails-open item fixed at round 4: no line (2C)" |
| 2D, 2E, 2F | share 2B/2C |
| 3A | moved: "a counted item with a spec line, fixed (1B; #93 3A: S1 is a Would-break item)" |
| 3B | moved: "an Act on item fixed on this PR is not counted, round 3"; "a Standards Would-break item fixed at round 3 (3B)"; "the same comment rebuilt from the dir, the line included (3B)"; "a Spec Would-break item fixed at round 3 (3B)" |
| 3C | "a Would-break item fixed at round 4 (3C)" |
| 3D | "a Would-break item fixed at round 5 (3D)" |
| 3E | "a Would-break fix with no reviewed file (3E)"; "... holding 'abc1234' (3E)"; "... holding 'three' (3E)"; "a Would-break fix with an empty reviewed file (3E)" |
| 3F | "a Would-break item fixed in a review with no spec carries the line (3F)", in the no-spec block |
| 4A | moved: "a hole before a trailing fixed field counts as fixed" |
| 4B–4F | share 4A and row 3 (`ending` makes the line a fixed item before either loop reads it) |
| 5A | shares 5B |
| 5B | "a hole and a Would-break fix: restart, no line (5B)" |
| 5C, 5D | share 5B |
| 5E | "a hole and a Would-break fix with no reviewed file: the file is not read (5E)" |
| 5F | existing "an Act on item marked '<mark>' in a review with no spec (7D)", unchanged |
| 6A | existing "a counted item with a spec line, ticketed (1C)", unchanged |
| 6B | "a Would-break item ticketed at round 3: no line (6B)" |
| 6C–6F | share 6B |
| 7 | "two Would-break fixes print one line (7B)" (one Standards, one Spec) |
| 8 | "a walk line carrying fixed: is invisible (8)" |
| 9 | "a Would-break fix in the sweep form (9)" |

## Moved assertions

- `tests/spec-review/review-comment.sh` "an Act on item fixed on this PR is not counted, round 3": gains `would-break fixed after 0123456789abcdef0123456789abcdef01234567` between the summary line and `round: 3 of 3`. Required by table B 3B (S1 is under `## Would break`).
- `tests/spec-review/review-comment.sh` "a counted item with a spec line, fixed (1B)": gains the line before `round: 1 of 3`; label now reads "(1B; #93 3A: S1 is a Would-break item)". Required by table B 3A.
- `tests/spec-review/review-comment.sh` "a hole before a trailing fixed field counts as fixed": gains the line. Required by table B 4A.
- `tests/spec-review/review-comment.sh` `rearm()` writes `<dir>/reviewed`, so `reset` does too; no existing expectation changed by it.
- `tests/spec-review/review-brief.sh` `fragment()`: now also holds the `cap=3;` line. Every other existing assertion in both files passes unchanged; the three `F4` assertions pass byte for byte.

## Verification

Run from the worktree root at the head commit, last output line of each:

- `bash tests/spec-review/review-brief.sh`: `ok 648 assertions` (base 476)
- `bash tests/spec-review/review-comment.sh`: `ok 192 assertions` (base 150)
- `bash tests/spec-review/no-stale-wording.sh`: `ok: no stale wording`
- `bash tests/hooks/delegation.sh`: `ok 55 assertions`
- `bash tests/poteto-mode/overlap.sh`: `ok 57 assertions`
- `bash tests/shellcheck/gate.sh`: `ok 17 assertions`
- `bash .github/shellcheck.sh factory918.sh template/.github/shellcheck.sh 'template/.claude/hooks/*.sh' 'template/.agents/skills/*/scripts/*.sh' 'tests/*/*.sh'`: `ShellCheck 0.11.0, files checked: 20` (exit 0)
- `shellcheck -x` on the five changed shell files (`review-brief.sh`, `review-comment.sh`, the two tests, `no-stale-wording.sh`): no output, exit 0
- `python3 tools/build_knowledge.py`: `knowledge files: 119 → docs/knowledge`; then `git status --porcelain`: nothing
- `python3 tools/check_knowledge.py`: `knowledge ok: 119 files`
- `./factory918.sh sync`: `vendored: 72 skills. Review with git status, bump VERSION, commit.`; then `git status --porcelain`: nothing
- The three patches were checked to regenerate byte for byte at the base before any edit (`cmp` clean for all three), then regenerated with the `diff -u --label` command from how.md Answer 5.
- `/deslop` pass over the diff: two comment tweaks (a rewrapped header paragraph in `review-brief.sh`, a shorter block comment in `review-comment.sh`), in commit 3; no code change.

At commit 2 alone, `tests/spec-review/review-comment.sh` passes (192) and every script assertion of `tests/spec-review/review-brief.sh` passes; its three prose pins (the fix paragraph in SKILL.md, the babysit sentence in both copies) pass only from commit 3 (a scratch copy of the test minus those three lines printed `ok 642 assertions` at commit 2 and was not committed).

## End to end

A throwaway repo laid out as a project (`tests/spec-review/layout.sh`), the fake `gh` on PATH, the script at `.scratch/program/93/e2e.sh` in the worktree. Printed lines, verbatim:

```
### round three: review-brief.sh HEAD~1 --ticket 7 --round 3
ticket: #7
round: 3 of 3
.scratch/review/HEAD_1/standards-brief.md
.scratch/review/HEAD_1/spec-brief.md
.scratch/review/HEAD_1/reviewed = ad07bd6a5969eee1a2abc65e8c93534fbfb064c2; HEAD = ad07bd6a5969eee1a2abc65e8c93534fbfb064c2
### round three: review-comment.sh (after the fix lane committed 310a73e)
would-break fixed after ad07bd6a5969eee1a2abc65e8c93534fbfb064c2
round: 3 of 3
act-on items: 0
### round four: review-brief.sh ad07bd6a5969eee1a2abc65e8c93534fbfb064c2 --ticket 7
ticket: #7
round: 4 of 5
settled: carried 0, dropped 0 without a citation
.scratch/review/ad07bd6a5969eee1a2abc65e8c93534fbfb064c2/standards-brief.md
.scratch/review/ad07bd6a5969eee1a2abc65e8c93534fbfb064c2/spec-brief.md
--- .scratch/review/ad07bd6a5969eee1a2abc65e8c93534fbfb064c2/standards-brief.md, ## Commits and ## The fix under review:
## Commits
310a73e fix the hook
## Changed files
## The fix under review
The round before this one fixed these Act on items on this PR after the commit it reviewed; this round's diff is those fix commits and nothing else. Read each fix against its item, walk only the steps these commits touch, and report only what these commits get wrong. Nothing in this section says what you should find or confirm.
1. [S1] **Hook exits 0 on a miss.** The test proves it. fixed: 310a73e
## Diff
### round four: the original fixed point is refused
review-brief: round 4 reviews only the fix from ad07bd6a5969eee1a2abc65e8c93534fbfb064c2, the commit round 3 reviewed (the `would-break fixed after` line of the last review comment); HEAD~2 is not that commit
(exit 1)
### round four: review-comment.sh
would-break fixed after 310a73ee23400af3d93fe458c2bded1dea7f9bc2
round: 4 of 5
act-on items: 0
### round five: review-brief.sh 310a73ee23400af3d93fe458c2bded1dea7f9bc2 --ticket 7
ticket: #7
round: 5 of 5
settled: carried 0, dropped 0 without a citation
.scratch/review/310a73ee23400af3d93fe458c2bded1dea7f9bc2/standards-brief.md
.scratch/review/310a73ee23400af3d93fe458c2bded1dea7f9bc2/spec-brief.md
--- .scratch/review/310a73ee23400af3d93fe458c2bded1dea7f9bc2/spec-brief.md, ## Commits and ## The fix under review:
## Commits
94d37ba fix the hook again
## Changed files
## The fix under review
The round before this one fixed these Act on items on this PR after the commit it reviewed; this round's diff is those fix commits and nothing else. Read each fix against its item, walk only the steps these commits touch, and report only what these commits get wrong. Nothing in this section says what you should find or confirm.
1. [S1] **Hook exits 0 on a miss.** The test proves it. fixed: 94d37ba
## Diff
### round five: review-comment.sh
would-break fixed after 94d37ba2b1ad12cccd5f7424becf6d7958373a29
round: 5 of 5
act-on items: 0
### round six: review-brief.sh 94d37ba2b1ad12cccd5f7424becf6d7958373a29 --ticket 7 (the stop)
review-brief: five rounds were run on this PR; round five's Would-break fixes are the human's to review (spec-review step 5), not reviewed in a sixth round
(exit 1)
state after the refusal: no .claude/state/review
```

## Deviations

1. **`previous-3w.md` carries a Spec report where `previous-3.md` has `no spec: Standards axis only`.** The test list derives (3W) from `previous-3.md`, whose `## Spec` holds the no-spec line, but row 6 needs a (3W) that had a spec and row 7 one that did not. I made the spec'd form the default (`previous-3-spec.md` replaces the line with a minimal Spec report shape) and `previous-3w-nospec.md` the row-7 variant. Also, (3W)'s Noted S1 item is removed when S1 moves to Act on as fixed, so `[S1]` appears once; the settled count over (1), (2), (3W) is still `carried 2, dropped 1`, and over (3W) alone (3C, 16C) it is `carried 1, dropped 1`, which is what those cells pin.
2. **The fix commit is `fix the hook`, not `fix the hook, #7`.** With `#7` in the message, row 6 (`review-brief.sh "$s"` with no `--ticket` refused for `FT`) cannot fire from the same commit. 3A, 3C, 9A, 16C and 19A pass `--ticket 7`, which is the Contract's own round-four call.
3. **18A is run after the fix commits, not before.** The test list says "run before the fix commit is made"; the table's order puts row 18 after 17, and with a spec'd (3W) and no `--ticket`, `FT` fires before the empty-diff refusal. The assertion builds `previous-3w-head.md` whose line names HEAD and runs `review-brief.sh <HEAD sha> --ticket 7`: the diff `HEAD...HEAD` is empty and the existing refusal fires, with no state.
4. **`wb_first` instead of `wb_fixed` in `review-comment.sh`.** The Contract's count was only ever tested for nonzero and the refusal needs the first Would-break fix's title, so the loop keeps that line and stops; behavior is identical.
5. **`wb_line` beside `wb` in `review-brief.sh`.** The Contract's `case "$wb" in "") ;;` cannot tell "no line" from row 14's "the words followed by nothing" (after the trailing-blank strip the line is `would-break fixed after`, so the text after the words is empty either way). The script keeps the whole matched line and tests its presence for `FM`; the gate's `[ -z "$wb" ]` is unchanged in effect because `FM` has already refused any non-empty line that is not 40 hex.
6. **Commit 1 was amended once before commit 2.** My first `previous-1w.md` moved S1 to Act on as well as adding the line, so row 12 carried one item instead of two; the ticket says "previous.md with the line", which is what the committed fixture is. The amend happened before any later commit existed.
7. **Two script comment tweaks are in commit 3, not 2.** The deslop pass reflowed the header paragraph of `review-brief.sh` and shortened the block comment above the Would-break loop in `review-comment.sh`; comments only, no code.
8. **`F5` with no comment prints "the last review comment is round 0".** That is the Contract's template with `top` = 0 (1B); pinned as such. The owner may prefer other words for the no-comment case.
9. **No dedicated assertions for the "same" and "as A" cells** in columns B and C of table A and columns C to F of rows 2, 4 and 6 of table B, beyond what the ticket's test list named. They are the same code path as their A-column cell; the Cells section marks each. Cheap to add (1C is an empty `--previous` file, for one) if the owner wants one assertion per cell literally.

## Surprises

- The worktree-isolation guard refused two compound commands (a `cmp` chain over three `diff` calls, and a script run from the scratchpad with `$PWD` as an argument); both were split into plain commands and rerun. No content changed because of it.
- BSD awk on this Mac handled every fragment as written (the `/re/ || $0 == "..."` pattern, the `keep()` function, the bracket-free CR strip); nothing needed a GNU-only form.
- The `review-brief.sh` Fixture step in CI (`.github/workflows/factory-ci.yml`) runs `HEAD~1 --ticket 1` with no PR, round 1, so the new gate is invisible to it; `.scratch/review/HEAD_1/reviewed` is written there too and nothing reads it.
