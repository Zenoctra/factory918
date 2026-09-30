# Slice: gates

Re-run every repository gate at the SHA and record each outcome. Do not trust the PR body's claims.
1. The `AGENTS.md` "Verifying" list as it reads at the SHA, every line, including the new gate command and
   `bash tests/shellcheck/gate.sh`; also `bash -n factory918.sh` even though the list dropped it.
2. Every file under `tests/` (skip `fake-gh.sh`), including any this diff added.
3. `python3 tools/check_knowledge.py`; `python3 tools/build_knowledge.py` then `git status --porcelain` empty.
4. `./factory918.sh sync` then `git status --porcelain` empty.
5. Every patch under `patches/` the diff added or changed reproduces byte for byte by the `patches/README.md` command.
6. The factory CI workflow `.github/workflows/factory-ci.yml` and the template's `template/.github/workflows/ci.yml`
   (and `python.yml` if touched) at the SHA: mirror each step the diff added or changed locally, in order, and
   record its outcome; say which steps you could not mirror and why.
7. The six CI runs the report names (35747640954, 35749314626, 35750682737, 35751339998, 35752369368,
   35753462947): `gh run view <id> --repo Zenoctra/factory918 --json headSha,conclusion,event`; the last must
   be at 2360707 with success; the failure at a64c7e6 must be the one the report describes.
8. The symlink `.github/shellcheck.sh` -> `template/.github/shellcheck.sh` (or whatever the diff made): `ls -l`,
   `git ls-files -s .github/shellcheck.sh` (mode 120000), and that it resolves at the SHA.
Report file: `/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.scratch/program/verify/96-2360707/worker-gates.md`.
