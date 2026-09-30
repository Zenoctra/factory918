# Writer report, ticket #106

For a person: every cell of #106's tables A and B is implemented as the design wrote it, and all tests and checks pass at HEAD. There are four commits on `wt/106-writer`, stacked on PR #124's tip. Nothing was pushed, and DECISIONS.md is untouched.

## Branch

`wt/106-writer`, based on `01a1e5f46891d10b234fe9ee80cbd9e8c67d4438`.

```
5f9a598 Say which rounds review only the fix and when a review is owed, #106
dcb9055 Pick a fix-only round's items with one filter, #106
aa155fc Review only round two's fix at round three when round two found nothing outside it, #106
7b7d1fb Test the fix-only third round and the three new comment lines, #106
```

- `7b7d1fb` holds the tests. Both test files fail at their first new cell (brief: `FAIL (1R) (2A): .../fix-lines is not the lines r1..HEAD changed`; comment: the first round-one accept lacking `reviewed:`). The commit message lists every moved round-one accept by its label.
- `aa155fc` holds the scripts. At this commit brief has 980 assertions and comment has 264, all passing.
- `dcb9055` is the deslop pass over the scripts diff.
- `5f9a598` holds the prose, the regenerated patches, SOURCES.md, the rebuilt knowledge, the anti-drift pins and the stale-wording phrase.

## Cells I could not implement

None.

## Act-on list

1. **accepted: the anti-drift pins and the stale-wording phrase moved to the prose commit.** The two #106 pins in `review-brief.sh` (the step 1 sentence and `babysit_owed` in both copies) and `From round four on both briefs carry` in `no-stale-wording.sh` would fail until the prose lands. The brief says "all tests pass" at the scripts commit, so they sit in the prose commit (the brief also lists `no-stale-wording.sh` under step 3). Every table cell assertion is in the tests commit.
2. **accepted: a fourth commit.** The deslop pass collapsed the two `fixed_items` awk branches into one filter (`all` picks `!/ticket: #N$/` or `/fixed: <hex>$/`). The behavior is unchanged, and the result is 986/264 green. It lands before the prose commit, so the prose commit is still the last one.
3. **accepted: `outside` takes no argument.** The design's call `outside "$mine"` passes an argument the function never reads, so the call is `outside`.
4. **accepted: `wb=` moved.** It now sits at the top of `tests/spec-review/review-comment.sh` beside the new `rv=` (the design says "beside `$wb`"), because the round-one accepts that now print `$rv` come before #93's block.
5. **accepted: #93 3E is relabeled `(3E; #106 11D)`, not 11A.** That refusal runs at round 3, which is column D. A new round-one refusal carries the 11A label.
6. **accepted: table B uses an `ends` helper.** Each new cell asserts exit 0, the fixture files above the summary line byte for byte, the exact tail after the summary line, and the cleared state. The helper does not restate the summary line, which is #93's and unchanged. #93's accepts still pin it.
7. **accepted: 12A asserts the round line and runs `same`, not 4A's exact stdout.** The variant "(2F) then a rebuilt (2)" carries a different settled count than 4A. The byte comparison against the history with the new lines deleted is the stronger proof of criterion 1.
8. **accepted: the row-12 fixture in table B is stronger than the design's.** The walk's fenced quote holds `-  exit 0` and also `+  exit 2 # elsewhere`, a marked line the fix did not touch. If walk lines were read as hard, the FO line would disappear. A walk line carrying `fixed: abc1234` also checks that no owed line prints.
9. **accepted: fixture branches.** Row 9A (a fix commit naming no ticket) and rows 15 to 18 (the commits after a fix-only round three) run on throwaway branches inside the temp fixture repo. The test deletes them afterwards, so r2..HEAD stays one commit for rows 19 to 22. The fixed point `o` is `HEAD~2`, which is r1, as the design's 4A has it.
10. **accepted: the SOURCES.md wording is mine.** The design names items 4, 6 and 12 but gives no text for them. Each gained one sentence (4 and 12) or two clauses (6).
11. **ask: the settled section repeats a renumbered item.** In (2F), S2's Dismissed line is numbered `3.` where (1R) numbered it `2.`. The whole-line dedup carries both, so 5A prints `settled: carried 3`. This behavior predates #106: any renumbered rebuild does it. Should it become a ticket?
12. **accepted: bash 3.2.** macOS bash treats an empty array as unbound under `set -u`, so the #93 13B loop uses `${prev[@]+"${prev[@]}"}`.
13. **accepted, owner's step: DECISIONS.md P20.** The retitle and the dated amendment are not written. The brief reserves them for the owner.
14. **accepted: `docs/agents/review-ladder.md` has no copy.** Only `template/docs/agents/review-ladder.md` exists, so only that file was edited.

## Verification at HEAD (5f9a598)

- `bash tests/spec-review/review-brief.sh`: ok 986 assertions (also rerun after the prose commit, as the brief asks).
- `bash tests/spec-review/review-comment.sh`: ok 264 assertions.
- `bash tests/spec-review/no-stale-wording.sh`: ok: no stale wording.
- `bash .github/shellcheck.sh factory918.sh template/.github/shellcheck.sh 'template/.claude/hooks/*.sh' 'template/.agents/skills/*/scripts/*.sh' 'tests/*/*.sh' 'tests/*/*/*.sh'`: ShellCheck 0.11.0, 23 files checked, no findings.
- `bash tests/shellcheck/gate.sh`: ok 17 assertions.
- `bash tests/hooks/delegation.sh`: ok 55 assertions.
- `bash tests/poteto-mode/overlap.sh`: ok 57 assertions.
- `bash tests/knowledge/provisional-ids.sh`: 26 assertions passed.
- `bash tests/eval/reviewer/refusals.sh`: all 230 checks passed.
- `python3 tools/build_knowledge.py`: `git status` stays clean. `python3 tools/check_knowledge.py`: knowledge ok, 119 files.
- `./factory918.sh sync`: all patches applied, and `git status` stays clean.

## review-comment.sh on a round-two fixture dir

The fixture dir is at round 2, with `<dir>/reviewed` set to `0123…4567` and fix lines `exit 1 # miss` and `exit 0`. Its one Would-break item quotes a hunk with a context line, `-  exit 0` and `+  exit 1 # miss`. The breach S2 is marked `fixed: abc1234`, and the spec report is empty. The tail it printed:

```
Standards: 1 would break, 0 fail open, of 2; Spec: 0 would break, 0 fail open, of 0; judged: act on 2 (1 fixed, 0 with a ticket), ask 0, consider 0, noted 0, dismissed 0; fixed point main.
next round owed: round 3 reviews the fixes marked here
fix only after 0123456789abcdef0123456789abcdef01234567
round: 2 of 3
act-on items: 1
```

## Files

- `template/.agents/skills/spec-review/scripts/review-brief.sh`
- `template/.agents/skills/spec-review/scripts/review-comment.sh`
- `tests/spec-review/review-brief.sh`, `tests/spec-review/review-comment.sh`, `tests/spec-review/no-stale-wording.sh`
- `template/.agents/skills/spec-review/SKILL.md`, `patches/mattpocock/spec-review.SKILL.md.patch`
- `template/.agents/skills/poteto-mode/playbooks/babysit.md`, `patches/pstack/poteto-mode/playbooks/babysit.md.patch`
- `template/.agents/skills/babysit/SKILL.md`, `patches/pstack/babysit/SKILL.md.patch`
- `SOURCES.md`, `template/docs/agents/review-ladder.md`, `docs/knowledge/core/MANUAL.md`, `template/docs/factory918/MANUAL.md` (regenerated)

Opus 5.5, Claude Code (writer lane)
