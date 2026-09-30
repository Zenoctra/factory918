# Slice: gates
1. Every line of `AGENTS.md` "Verifying" at the SHA, including `bash .github/shellcheck.sh` and `bash tests/shellcheck/gate.sh`.
2. Every file under `tests/` (skip `fake-gh.sh`); record assertion counts. `tests/spec-review/review-brief.sh` is the
   test this PR extends: report its count at the SHA and at the patch base 52ccd8e (check out the base in a second
   detached step, or use `git worktree`-free `git show` into a temp dir), so the added cells are visible.
3. `python3 tools/check_knowledge.py`; `python3 tools/build_knowledge.py` then empty `git status --porcelain`.
4. `./factory918.sh sync` then empty status; every patch the diff added or changed reproduces byte for byte with the
   `patches/README.md` command.
5. `shellcheck` 0.11.0 on every `*.sh` the diff touched.
6. CI: `gh run list --repo Zenoctra/factory918 --branch feat/spec-walk-risks --json databaseId,headSha,status,conclusion,event`;
   the run at 7956c69 must be success; the report names 35761775682. Note that the PR's base is `feat/design-hole-restart`,
   so the run's merge ref is against #99's head at run time; say which #99 head that run used if the API shows it.
7. The fixture job's new step (the report says CI's Fixture job greps the walk sentence in a Spec brief on a real
   `factory918 apply` diff): mirror it locally if `vp` is available, else say so.
Report: `/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.scratch/program/verify/101-7956c69/worker-gates.md`.
