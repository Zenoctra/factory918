# Slice: gates
1. Every line of `AGENTS.md` "Verifying" at the SHA (the ShellCheck gate, `tests/shellcheck/gate.sh`, and the rest).
2. Every file under `tests/` (skip `fake-gh.sh`, `layout.sh` is a sourced helper); record assertion counts, and
   the counts of `tests/spec-review/review-brief.sh` and `review-comment.sh` at the patch base 070c1fa too, so the
   added cells are visible.
3. `python3 tools/check_knowledge.py`; `python3 tools/build_knowledge.py` then empty `git status --porcelain`.
4. `./factory918.sh sync` then empty status; every patch the diff added or changed reproduces byte for byte with the
   `patches/README.md` command.
5. `shellcheck` 0.11.0 on every `*.sh` the diff touched.
6. CI: wait for the `pull_request` run at headSha 0ff73f0 (`gh run list --repo Zenoctra/factory918 --branch
   feat/design-hole-restart --json databaseId,headSha,status,conclusion,event`; poll with `sleep 60` inside your
   turn, up to 25 minutes); record conclusion and jobs. Also the earlier run 35756050493 at 52ccd8e.
7. `docs/knowledge/core/DECISIONS.md` at the SHA: P25 (#94), P26 (#96), P27 (this PR), no duplicate ids, and the
   PR body and ledger lines say P27.
Report: `/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.scratch/program/verify/99-0ff73f0/worker-gates.md`.
