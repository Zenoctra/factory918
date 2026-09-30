# Slice: gates
1. Every line of `AGENTS.md` "Verifying" at the SHA, including the fixture flow (relative `--directory`, see common).
2. Every file under `tests/` (skip `fake-gh.sh` and sourced helpers); assertion counts at the head and at 86d156a.
3. `python3 tools/check_knowledge.py`; `python3 tools/build_knowledge.py` then empty `git status --porcelain`.
4. `./factory918.sh sync` then empty status; every patch the diff added or changed reproduces byte for byte with the
   `patches/README.md` command; every new patch is listed in `patches/series` and described in `SOURCES.md`.
5. `shellcheck` 0.11.0 on every `*.sh` the diff touched.
6. CI: run 35816676418 via `gh run view --json headSha,conclusion,event,jobs`; at this head, success on every job.
7. `docs/knowledge/core/DECISIONS.md` at the SHA: P1 to P30 unchanged against 86d156a except P29's retitle and
   appended amendment line; the new row is `P105`, unique.
8. `tests/spec-review/no-stale-wording.sh`: prove it fails when a retired phrase is put back (scratch copy only).
Report: `/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.scratch/program/verify/120-e090a38/worker-gates.md`.
