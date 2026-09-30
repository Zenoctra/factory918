# Slice: the fixes to the first verification's issues
1. Reproducibility (was the runtime Issue): for all twelve rounds, `bash tests/eval/reviewer/rebuild.sh <round>` with
   no network (use a `gh` shim on PATH that exits 1 and logs any call; prove no call happened) reproduces the frozen
   briefs and diff byte for byte. Change one byte of one input in a scratch copy: it fails, naming the file. Read the
   method note: can a stranger with a fresh clone and `refs/keep/103/*` do this from the note alone?
2. Were the inputs committed faithfully? For two regenerated rounds, compare `inputs/` ticket bodies against the
   ticket's edit history if `gh api repos/Zenoctra/factory918/issues/<n>/timeline` or the issue's
   `userContentEdits` (GraphQL) exposes it; otherwise say what could not be checked.
3. PR body (`gh pr view 124 --json body`): the gpt-6-astra matrix row now waits on Manuel's answer to round 3's Ask and
   names no nonexistent ticket; the Spec proposal is phrased in tiers ("the lower tier (Claude Opus 5)" to "the upper
   tier (Claude Opus 5.5)") and nowhere proposes launching Fable; `Closes #103` last before the attribution, then the
   model-and-harness line; the Verification section names `rebuild.sh` and says what CI does not run and why.
4. The owner's report `.../103/report.md`: Reviews records round 2's [S1] disposition; criterion 4 says which table is
   generated and which column is hand-edited. Check the M0 section says the same.
5. The new code: read `rebuild.sh` and the `ae4bc6d`/`9f16641` diffs for defects (quoting, a path that escapes the
   round directory, a silent pass on a missing input). ShellCheck is in the other slice.
Report: `/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.scratch/program/verify/124-01a1e5f/worker-fixes.md`.
