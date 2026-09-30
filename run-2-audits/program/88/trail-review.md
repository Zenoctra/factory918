reviewed by Opus 5 (1M context)

1. **The promised PR-body addendum was never written.** The round-3 comment and the `review3` row both say the stale blast-radius grounding "gets a dated addendum in the PR body". The lane ran `gh pr edit 96` once, at 15:33, to mark it ready. The live body still shows risk 1 citing the deleted `[ ! -x "$bin" ]`, risk 3 as open, and the falsified Cleared line "with the hooks deleted, 6". The one Noted item carrying an action was logged as done and wasn't.

2. **The PR body is frozen at `69bd412`.** Scope still says the gate "downloads ... once, checks its sha256" (false since `a64c7e6`), and Verification ends "Review: pending; `spec-review` runs in a fresh lane after CI is green". A reader who skims the body and not the comments gets the pre-review design.

3. **"Test before implementation" does not hold, and the trail claims it does.** `todo.md` marks Run-under rule 3 done, "commit order shows it"; PR Tradeoffs repeats it. Commit `1208407` holds `template/.github/shellcheck.sh` and `tests/shellcheck/gate.sh` together; `writer-report.md:32` says the first gate run "happened before the test file was written", and `:69` that the gate flagged the test's first draft. "Commit 1 is red by design" means the factory's 57 findings, not a failing test.

4. **Fix 2 introduced a wedge no round caught.** `shellcheck.sh:30` is now `[ -f "$tarball" ] || curl ...`, so a truncated download leaves a partial `sc.tar.xz` that is never re-fetched: every later run fails the checksum forever, with no hint to delete it. The Cleared bullet "a half download leaves no binary, so the next run retries" has been untrue since `a64c7e6`.

5. **`tar -xJf` now runs on every invocation** (`:33`) into a shared `${TMPDIR:-/tmp}` path, so two concurrent gates can overwrite the binary another is exec'ing. Silent when it bites; unraised.

6. **Round-3's Noted and Dismissed items are fair.** The S4 dismissal checks out: `a64c7e6` added `>&2`, `1362b48` removed it, so the title describes the net effect. S1 to S3 are correctly Noted; only S1's remedy went undone.

7. **Round 2's "not a design hole" call is the one stretch.** The `## Design` signature says the gate downloads "once, checks its sha256"; the shipped gate verifies and re-extracts every run. Defensible as a code fix, but the Design was never amended, so the ticket no longer describes the script.

8. **Three rows' evidence lives only in a disposable worktree.** `review1`/`review2`/`review3` cite `.scratch/review/ab47eb9/`, which exists only under `.claude/worktrees/owner-88/`, where round 3 overwrote rounds 1 and 2. This run already lost one worktree to auto-removal.

9. **The trail ends open.** The last row's result is "polling CI on 3f3814c"; run 35752369368 is green and nothing records it. `todo.md`'s final item, `report.md`, is unchecked and absent.

10. **Ledger and M0 rows are honest.** Both ledger lines admit real failures, the lost lane and the fix lane proving the wrong branch; M0's count fix, its four cited CI runs and the `implement` row's check list all resolve.
