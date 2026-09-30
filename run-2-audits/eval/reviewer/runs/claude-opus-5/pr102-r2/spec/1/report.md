## Walk

1. Criterion 1, the round past three. `review-brief.sh` cuts the deciding comment from the post-restart history, reads its `would-break fixed after <sha>` line, and allows a round past three only when that line is present and `round == top + 1`; `round > 5` is refused first (`F6`), a hand-written line before that (`FM`), and a round four without the line keeps the old `F4` text byte for byte.
2. Criterion 1, the kind of the fixed items. `review-comment.sh` walks the Act on lines ending `fixed: <sha>`, resolves each `[S<n>]`/`[P<n>]` through `specs()`, and prints the line only when one sits under `## Would break` and no hole is marked; a Fails-open, breach, ticketed or holed item prints nothing, so that round may be the last.
3. Criterion 2, the fix-only fixed point. `review-brief.sh` refuses a fixed point that is not the named commit (`FP`), one that does not resolve (`FR`) and a fix-only round with no ticket after a round with a spec (`FT`), all before `mkdir -p "$dir"`; `common()` then prints `## The fix under review` with `$fix_rule` and the deciding comment's fixed items, before the blast radius and the diff.
4. Criterion 2, the record. Every run writes `git rev-parse HEAD` to `<dir>/reviewed` on the line after `<dir>/round`, in both forms; `review-comment.sh` reads it only when the line is needed and refuses it missing or not 40 lowercase hex.
5. Criterion 3, the prose. `spec-review` step 5 gains the paragraph with both stops and no count comparison; the comment's summary line is unchanged and carries no would-break count.
6. Criterion 4, babysit. The same replacement sentence is in `playbooks/babysit.md` and `babysit/SKILL.md`, pinned by the brief test; `round: 3 of 3` with `act-on items: 0` and no line still reads review-ready.
7. Criterion 5, the tests. `tests/spec-review/review-brief.sh` adds rows 1 to 20 of table A and `review-comment.sh` rows 1 to 9 of table B, including round four from `$s` and the round-five cell.
8. Criterion 6, the records. P20 amended, P30 added, `review-ladder.md` rung 1 rewritten in one sentence, `MANUAL.md` and the generated `template/docs/factory918/` copies in step.

## Would break

## Fails open

1. **A rewritten branch resolves the old commit, so round four briefs more than the fix.** Row 5 treats "the branch rewritten" as the case where `<sha>` does not resolve, and `FR` fires on `git rev-parse --verify`. In the clone where the rebase or amend happened the rebased-away commit is still in the object database, so `FR` does not fire; `FP` then compares the passed fixed point with the same sha and passes, and `git diff "$wb...HEAD"` falls back to the merge base, briefing the whole rebased range while `## The fix under review` tells the reviewer "this round's diff is those fix commits and nothing else". An ancestry check (`git merge-base --is-ancestor`) is the refusal the cell assumed.

```
| 5. (1), (2), (3W s), `s` does not resolve in this clone (the branch rewritten, another checkout) | `FR(4,s)` / 1 / fetch the PR's branch, rerun | same | as A |
```

Documented step: `template/.agents/skills/spec-review/scripts/review-brief.sh:230` (the `FR` refusal, the only guard against a `<sha>` that is not this branch's reviewed tip).
Result: round four's briefs carry the original work as well as the fix, and the fix paragraph misstates what the diff is.
spec: table 5/A

## Not asked for

hard findings: 1
