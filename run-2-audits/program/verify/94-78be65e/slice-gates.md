# Slice: gates

Re-run every repository gate at the SHA and record each outcome. Do not trust the PR body's claims.
1. `bash -n factory918.sh`.
2. `bash tests/hooks/delegation.sh`, `bash tests/spec-review/review-comment.sh`, `bash tests/spec-review/review-brief.sh`,
   `bash tests/poteto-mode/overlap.sh`, and any other file under `tests/` the diff added or touched.
3. `python3 tools/check_knowledge.py`; `python3 tools/build_knowledge.py` then `git status --porcelain` must be empty.
4. `./factory918.sh sync` then `git status --porcelain` must be empty (a non-empty status means a patch
   does not reproduce the vendored tree; report the files).
5. Every patch under `patches/` that the diff added or changed reproduces byte for byte by the command in
   `patches/README.md`.
6. `shellcheck` on every shell file the diff touched (`git diff --name-only ab47eb9...78be65e -- '*.sh'`),
   and its version.
7. The CI runs the report names (35745145787, 35747733851, 35748776685) exist, belong to this PR's head
   SHAs, and concluded success: `gh run view <id> --repo Zenoctra/factory918 --json headSha,conclusion,event`.
Report file: `/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.scratch/program/verify/94-78be65e/worker-gates.md`.
