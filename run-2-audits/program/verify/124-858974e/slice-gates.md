# Slice: gates
1. Every line of `AGENTS.md` "Verifying" at the SHA, including the fixture flow (relative `--directory`, see common)
   and the new reviewer test line.
2. Every file under `tests/` (skip stubs and sourced helpers); assertion counts at the head and at 86d156a. The owner
   claims `refusals.sh` 230 checks and `reviewer.py check` 13 `ok`.
3. `python3 tools/check_knowledge.py`; `python3 tools/build_knowledge.py` then empty `git status --porcelain`.
4. `./factory918.sh sync` then empty status; the provider-dispatch patch reproduces byte for byte with the
   `patches/README.md` command, is listed in `patches/series` and described in `SOURCES.md`.
5. `shellcheck` 0.11.0 on every `*.sh` the diff touched; the ShellCheck gate line in AGENTS.md covers the new file.
6. CI: run 35835731395 via `gh run view --json headSha,conclusion,event,jobs`; at this head, success on every job,
   and the new CI step runs `refusals.sh`.
7. `docs/knowledge/core/DECISIONS.md`: P1 to P30 unchanged against 86d156a; the new row is `P103`, unique.
8. The 15 `refs/keep/103/*` refs on origin (`git ls-remote origin 'refs/keep/103/*'`): each resolves, and each is a
   head a fixture round says it reviewed.
Report: `/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.scratch/program/verify/124-858974e/worker-gates.md`.
