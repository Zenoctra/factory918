---
name: factory-doctor
description: Check that this repo's factory layer is intact (toolchain pinned, hooks installed, skills resolvable, labels present, CI config present, gates green). Use after applying or updating the factory, or when something feels off.
disable-model-invocation: true
allowed-tools: Bash(./factory.sh doctor) Bash(vp *) Bash(gh label list*) Bash(git *) Bash(jq *)
---
Run `factory doctor` if the CLI is installed; otherwise perform its checks by hand and print the same table:

1. `vp --version` matches the pin in `docs/adr/0001-toolchain.md`.
2. `vp hooks status` shows the dispatcher installed and `core.hooksPath` set.
3. `.claude/skills` resolves to `.agents/skills`; every skill dir has a `SKILL.md` with `name:`; no duplicate names.
4. `gh auth status` succeeds; `gh label list` contains the labels in `.github/labels.json`.
5. `.github/workflows/ci.yml` and `pr-size.yml` exist.
6. `vp check`, `pnpm typecheck`, `vp test run`, `vp build` exit 0.
7. `.claude/settings.json` parses; each hook script is executable.
8. `.artifacts/`, `.scratch/`, `.claude/state/` are git-ignored.
9. `~/.claude/pstack-models.md` exists (run `/setup-pstack` if not).

Report PASS/FAIL per line and stop. Do not fix anything without being asked.
