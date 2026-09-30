# Slice: gates
1. Every line of `AGENTS.md` "Verifying" at the SHA, including the fixture flow (relative `--directory`).
2. Every test under `tests/`; assertion counts at the head and at 0edf8c8 (owner: review-brief.sh 1294).
3. `check_knowledge.py`; `build_knowledge.py` then empty status; `./factory918.sh sync` then empty status; the changed
   spec-review SKILL.md patch reproduces byte for byte (pstack upstream path
   `research/3-pstack/open-pstack-claude-code-port/plugins/pstack/skills/<path>`; mattpocock under `research/`: find it).
4. ShellCheck 0.11.0 on every `*.sh` the diff touched, and the AGENTS.md ShellCheck line with its count.
5. CI run 35858370668 at this head (`gh run view --json headSha,conclusion,jobs`), every job success. Run 35857124541
   at e0e1130 failed on SIGPIPE under pipefail: confirm 3fbc71b fixes the cause, not the symptom, and search the new
   test helpers and `reading-pack.sh` for any other pipeline that exits before reading its input under `pipefail`.
6. DECISIONS: `P107` unique; P20, P103, P105, P106, P110 untouched. Tests before the script (`8a40823` before `3b8c81b`):
   check out 8a40823 and show the new test fails at its first new cell.
7. The script is in the apply/sync `keep_files` list and lands in a fixture project (`find` it after apply).
Report: `/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.scratch/program/verify/126-f58308b/worker-gates.md`.
