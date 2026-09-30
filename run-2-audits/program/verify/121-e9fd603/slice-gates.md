# Slice: gates
1. Every line of `AGENTS.md` "Verifying" at the SHA, including the fixture flow (use a private /tmp path, not /tmp/fx if it exists).
2. Every file under `tests/` (skip `fake-gh.sh` and sourced helpers); record assertion counts at the head and at
   86d156a for the files that exist at both, so added assertions are visible. The owner claims provisional-ids.sh 26,
   review-brief.sh 660, review-comment.sh 192, overlap.sh 57, delegation.sh 55, gate.sh 17.
3. `python3 tools/check_knowledge.py`; `python3 tools/build_knowledge.py` then empty `git status --porcelain`.
4. `./factory918.sh sync` then empty status; any patch the diff added or changed reproduces byte for byte with the
   `patches/README.md` command.
5. `shellcheck` 0.11.0 on every `*.sh` the diff touched.
6. CI: run 35813400632 via `gh run view --json headSha,conclusion,event,jobs`; it must be at this head with success
   on every job.
7. `docs/knowledge/core/DECISIONS.md` at the SHA: P1 to P30 unchanged against 86d156a, the new row is `P110`, unique.
Report: `/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.scratch/program/verify/121-e9fd603/worker-gates.md`.
