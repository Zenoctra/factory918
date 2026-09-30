# Slice: gates
1. Every line of `AGENTS.md` "Verifying" at the SHA.
2. Every file under `tests/` (skip `fake-gh.sh` and the sourced `layout.sh`); record assertion counts at the head and
   at the patch base d8e382c for `tests/spec-review/review-brief.sh` and `review-comment.sh` (base: 476 and 150 per
   the owner), so the added cells are visible.
3. `python3 tools/check_knowledge.py`; `python3 tools/build_knowledge.py` then empty `git status --porcelain`.
4. `./factory918.sh sync` then empty status; every patch the diff added or changed reproduces byte for byte with the
   `patches/README.md` command.
5. `shellcheck` 0.11.0 on every `*.sh` the diff touched.
6. CI: runs 35779526784 (7b01fd6) and 35781166757 (fc75ac6) via `gh run view --json headSha,conclusion,event,jobs`;
   the second must be at this head with success on both jobs.
7. `docs/knowledge/core/DECISIONS.md` at the SHA: ids P25 to P29 as below the chain, this PR's new row(s) (the
   owner names P30) unique, P20's 2026-09-22 amendment present.
Report: `/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.scratch/program/verify/102-fc75ac6/worker-gates.md`.
