reviewed by Claude Opus 5 (1M context)

1. **The green CI never ran on the real base.** Row 18:46 and the PR body present run 35761775682 as proof. That run built `7956c69` against `main` while the PR was temporarily retargeted. Nothing has ever built this branch on top of `feat/design-hole-restart`, which is what it merges into.

2. **PR #101 is CONFLICTING now.** The parent has gained six commits past the fixed point (`096954b`..`384bb43`), three more than the 18:46 row recorded, and they change `review-brief.sh`, its test, `spec-review/SKILL.md` and its patch: the same files this PR rewrites. No run and no reviewer has seen the two together.

3. **Both reviews are against a base that no longer exists.** `review/standards-report.md`, `spec-report.md` and `judgment.md` are from fixed point `52ccd8e`. Read "hard findings: 0" as a verdict on that snapshot, not on the branch's current parent.

4. **Row 16:56 wrote to another lane's PR.** It retargeted #99 to `main` and back to mint a `Closes #90` link. Recorded as P27 and reversible, but it is this lane editing #99's base, and the "head 52ccd8e untouched" evidence was captured before #99 moved twice.

5. **Row 17:12 claims convergence while recording divergence.** The judge skip is backed by `ticket.md:31`, but the same row says the table took "fable's extra rows 4 and 8". Cells 4A (two different refusals) and 8A entered the contract with one runner behind them and no judge.

6. **Row 16:58 branched off the check's answer.** It used #99's head where `overlap.sh` printed `origin/feat/shellcheck`. The deviation is logged; its cost is flag 2.

7. **Ticket #100 is still open** and P27's workaround (open against trunk, retarget) is a manual step every later stacked PR must remember, or its go covers nothing.

8. **`todo.md` is stale as a record.** O4, T8, T9, O6 and O7 are unchecked although the records commit (`469f78d`), `gh pr ready` and the Overlap block all happened. No row logs the final `overlap.sh 91 --diff` run whose output is pasted into the PR body, so that block's provenance is unrecorded.

9. **Row 1's timestamp is `2026-09-22T00:00:00Z`,** a placeholder among real times; the trail's opening is not actually timed.

10. **Writer and fix reports were written inside their worktrees** and copied in (both say so). The copies here are what you read; nothing re-derives their numbers (468/136 assertions) except the CI run in flag 1.
