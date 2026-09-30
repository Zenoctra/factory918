First action: invoke the poteto-mode skill with the Skill tool, then do the task below.

# Fix lane 4 for ticket #103: the noise band reads a partial replicate

Repository Zenoctra/factory918. In your own worktree: `git fetch origin` then `git switch -c wt/103-fix4 origin/feat/reviewer-model-eval`. Commit there; do not push; no PR. Read `AGENTS.md`. Launch no agents. Code: `tests/eval/reviewer/reviewer.py` (`noise`, and `within` if it needs it) and `tests/eval/reviewer/refusals.sh`. Test first: the test commit before the code commit.

Evidence. A contaminated run is left out of every metric, and the owner tops the brief up with one more replicate (k=4) so the brief keeps three clean runs. `noise` then computes a per-replicate recall for k=4 over the one or two briefs that have it, which is not a replicate of the whole set, and its value (often 0.00 or 1.00) becomes the band's min or max. Today `claude:opus-5` Standards shows `min_k 0.00` from such a k.

Fix: the noise band and sd use only the replicates k whose labeled-brief coverage equals the largest coverage among that model's replicates on that axis (a replicate that did not run on every labeled brief the others ran on is left out of the band). Pooled recall is unchanged: it still counts every complete run. Add assertions: a model with k=1..3 on two labeled briefs plus a k=4 on one of them has a band computed from k=1..3 only, and its pooled recall includes the k=4 run.

Then `bash tests/eval/reviewer/refusals.sh` passes, `python3 tests/eval/reviewer/reviewer.py check` prints 13 `ok`, `bash .github/shellcheck.sh tests/eval/reviewer/refusals.sh` passes. No narrating comments. Write an act-on list result (branch, head SHA, commits, checks, flags) to exactly /Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.scratch/program/103/fix-4-result.md, or if refused, the same relative path under your worktree. Reply with only the path.
