# Slice: gates
1. Every line of `AGENTS.md` "Verifying" at the SHA, including the fixture flow (relative `--directory`).
2. Every test under `tests/` (skip stubs and sourced helpers); assertion counts at the head and at 01a1e5f. Owner
   claims review-brief.sh 1104, review-comment.sh 298.
3. `check_knowledge.py`; `build_knowledge.py` then empty status; `./factory918.sh sync` then empty status; the changed
   `spec-review/SKILL.md` patch and the babysit patch reproduce byte for byte with the `patches/README.md` command
   (the pstack upstream path is `research/3-pstack/open-pstack-claude-code-port/plugins/pstack/skills/<path>`).
4. ShellCheck 0.11.0 on every `*.sh` the diff touched; the AGENTS.md ShellCheck line.
5. CI run 35849516283 via `gh run view --json headSha,conclusion,event,jobs`: at this head, success on every job.
6. DECISIONS at the SHA: P20's retitle and dated amendment; `P106` unique; P103, P105, P110 untouched.
7. Tests before scripts: `git log --reverse --format='%h %s' 01a1e5f..0edf8c8`; check out each tests commit (7b7d1fb, 8fd83e1)
   with the old scripts and show the new test fails at its first new cell.
Report: `/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.scratch/program/verify/125-0edf8c8/worker-gates.md`.
