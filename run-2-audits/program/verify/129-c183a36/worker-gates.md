verdict: PASS

# Slice: gates, PR #129 (ticket #111) at c183a362e73b88758bdf468a4169619158b47c1d

Setup: own worktree `/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.claude/worktrees/agent-ae3a45d2b2ebabf31`, detached at the SHA; `git rev-parse HEAD` = `c183a362e73b88758bdf468a4169619158b47c1d`; `git merge-base --is-ancestor f58308b5eae3f6617cf3a5200e7679e5737a5702 HEAD` exit 0. Tree clean before and after every run.

## 1. Every line of AGENTS.md "Verifying" at the SHA

- `bash .github/shellcheck.sh factory918.sh template/.github/shellcheck.sh 'template/.claude/hooks/*.sh' 'template/.agents/skills/*/scripts/*.sh' 'tests/*/*.sh' 'tests/*/*/*.sh'` → `ShellCheck 0.11.0, files checked: 26`, exit 0. The line says "over 26 files"; it matches.
- `bash tests/shellcheck/gate.sh` → `ok 17 assertions`, exit 0.
- `bash tests/hooks/delegation.sh` → `ok 55 assertions`, exit 0.
- `bash tests/spec-review/review-comment.sh` → `ok 298 assertions`, exit 0.
- `bash tests/spec-review/review-brief.sh` → `ok 1294 assertions`, exit 0.
- `bash tests/poteto-mode/overlap.sh` → `ok 57 assertions`, exit 0.
- `bash tests/show-me-your-work/check-trail.sh` → `ok 66 assertions`, exit 0. Matches the owner's stated 66.
- `bash tests/spec-review/no-stale-wording.sh` → `ok: no stale wording`, exit 0.
- `bash tests/knowledge/provisional-ids.sh` → `provisional-ids: 26 assertions passed`, exit 0.
- `bash tests/eval/reviewer/refusals.sh` → `all 230 checks passed`, exit 0.
- `python3 tools/check_knowledge.py` → `knowledge ok: 119 files`, exit 0. `python3 tools/build_knowledge.py` → `knowledge files: 119 → docs/knowledge`, then `git status --porcelain` empty.
- `./factory918.sh sync` → `vendored: 72 skills`, last applied patch `pstack/show-me-your-work/SKILL.md.patch`; `git status --porcelain` empty afterwards.
- Fixture flow, run with the relative `--directory` form (#123) from a private parent `/private/var/folders/.../tmp.iXeWvBQoIy/fixture`:
  - `vp create vite:monorepo --directory fx --no-interactive --git --hooks --no-agent` → `Scaffolded fx with Vite+ monorepo`, vp v0.3.1, Node 24.21.0, pnpm 12.5.1, exit 0.
  - `git -C fx add -A && git commit -qm "chore: initial commit"` → exit 0.
  - `./factory918.sh apply <fx> --scaffold --profile python --name demo` → exit 0 with the two expected environment FAILs only: `labels present` (no GitHub remote) and `slots filled (/factory-start)`. Every other doctor line PASS, `shellcheck 0.11.0` and `ast-grep rules test` included. CI's fixture job pipes this step to `tail -30`, so those two are the same non-blocking result CI gets.
  - In `fx`: `vp check` → `All 63 files are correctly formatted`, `Found no warnings, lint errors, or type errors in 9 files`, exit 0. `vp test run` → `Test Files 2 passed (2) / Tests 10 passed (10)`, exit 0. `pnpm sg:test` → `test result: ok. 2 passed; 0 failed;`, exit 0.
  - `.github/workflows/python.yml` steps inside `fx/python/demo`: `uv sync --frozen` exit 0; `uv run ruff format --check .` → `2 files already formatted`; `uv run ruff check .` → `All checks passed!`; `uv run pyright` → `0 errors, 0 warnings, 0 informations`; `uv run pytest` → `1 passed`; `uv audit` → `Found no known vulnerabilities ... in 10 packages`. All exit 0.

## 2. Tests under `tests/`, counts at head vs f58308b, listing in AGENTS.md and CI

- Every `*.sh` under `tests/` run at the head (12 files; `fake-gh.sh` and `eval/reviewer/rebuild.sh` are helpers, `spec-review/layout.sh` prints nothing and is in neither AGENTS.md nor CI — all three pre-existing, untouched by the diff).
- Same tests at `f58308b`: gate.sh 17, delegation.sh 55, review-comment.sh 298, review-brief.sh 1294, overlap.sh 57, provisional-ids.sh 26, refusals.sh 230. Identical to the head. `git diff --stat f58308b..c183a36 -- tests/` shows one file, `tests/show-me-your-work/check-trail.sh | 207 +`, pure addition: no existing test was weakened or removed.
- `bash .github/shellcheck.sh ...` at `f58308b` → `files checked: 24`; at the head 26. The +2 are exactly the two new `.sh` files, and AGENTS.md's stated count moves 24 → 26 in the same diff.
- The new test is in AGENTS.md "Verifying" (`- \`bash tests/show-me-your-work/check-trail.sh\`.`, added between `overlap.sh` and `no-stale-wording.sh`, matching CI's order) and in CI: `.github/workflows/factory-ci.yml`, step `check-trail.sh passes and refuses the trails the test says` → `run: bash tests/show-me-your-work/check-trail.sh`, in the `factory` job in the same position.

## 3. Knowledge, sync, patch, series, SOURCES

- `python3 tools/check_knowledge.py` exit 0; `build_knowledge.py` then empty `git status --porcelain`; `./factory918.sh sync` then empty `git status --porcelain`. All three above.
- Patch reproduces byte for byte: copied the pin `research/3-pstack/open-pstack-claude-code-port/plugins/pstack/skills/show-me-your-work/SKILL.md` to a private dir, `git apply --unsafe-paths -p1 --directory=<dir> patches/pstack/show-me-your-work/SKILL.md.patch` exit 0, then `diff <dir>/show-me-your-work/SKILL.md template/.agents/skills/show-me-your-work/SKILL.md` exit 0, no output.
- `patches/series`: 33 entries, `pstack/show-me-your-work/SKILL.md.patch` is the last line.
- `SOURCES.md`: item `18.` present exactly once (`grep -c '^18\. '` = 1); `grep -o '^[0-9]\+\.' SOURCES.md | sort | uniq -d` empty, so no duplicate number anywhere; 18 is the highest.

## 4. ShellCheck on the `.sh` files the diff touched

- The diff touches three shell files: `factory918.sh`, `template/.agents/skills/show-me-your-work/scripts/check-trail.sh`, `tests/show-me-your-work/check-trail.sh`. All three are inside the 26-file gate run above.
- Explicitly: `shellcheck --version` → `0.11.0`; `shellcheck -s bash template/.agents/skills/show-me-your-work/scripts/check-trail.sh tests/show-me-your-work/check-trail.sh factory918.sh` → no output, exit 0.
- AGENTS.md's ShellCheck line is unchanged apart from 24 → 26, and the glob set (`template/.agents/skills/*/scripts/*.sh`, `tests/*/*/*.sh`) already covers both new files without a glob change.

## 5. CI

- `gh run view 35866744150 --repo Zenoctra/factory918 --json headSha,status,conclusion,jobs` → headSha `c183a362e73b88758bdf468a4169619158b47c1d`, status `completed`, conclusion `success`; jobs `Factory success`, `Fixture success`. Both jobs at this exact head.

## 6. DECISIONS and commit order

- `P111` appears once in `docs/knowledge/core/DECISIONS.md` (`grep -c 'P111'` = 1). `grep -o '^| P[0-9]*' | sort | uniq -d` empty: no duplicate Provisional id.
- `git diff f58308b..c183a36 -- docs/knowledge/core/DECISIONS.md` is one appended row after `P107` plus the header line-count comment `105` → `106`; no existing row changed, and nothing sits below P111. `docs/knowledge/INDEX.md` moves the same `105` → `106`. `template/docs/factory918/DECISIONS.md` gets the same appended row (generated; `build_knowledge.py` left the tree clean, so it is in sync with the source).
- `docs/M0-findings.md` is one appended dated 2026-09-23 line; nothing above it changed.
- Commit order: `54c65ac` "Test the trail clock check cell by cell" precedes `27bb48e` "Add check-trail.sh". Tests before the script.
- The tests commit fails against the parent's scripts: detached at `54c65ac`, `bash tests/show-me-your-work/check-trail.sh` → `FAIL 1 no transcript / got: exit 127, stdout [], stderr [tests/show-me-your-work/check-trail.sh: line 47: .claude/skills/show-me-your-work/scripts/check-trail.sh: No such file or directory] / wanted: exit 64 ...`, non-zero. The test really exercises the new script.

## 7. `check-trail.sh` in an applied fixture project

- `keep_files` in `factory918.sh:385` gains `show-me-your-work/scripts/check-trail.sh`; that is the only `factory918.sh` change, and the clean `sync` above proves the kept file survives the re-vendor.
- In the applied fixture: `ls -l fx/.agents/skills/show-me-your-work/scripts/` → `check-trail.sh` (2184 bytes, mode `-rwxr-xr-x`) beside `log.sh`.
- It runs there: `./.agents/skills/show-me-your-work/scripts/check-trail.sh` from `fx` → `usage: check-trail.sh <trail.tsv> <transcript.jsonl>...` on stderr, exit 64 — the documented usage exit, not a missing-file or interpreter error.
- The project's own gate covers it: `bash .github/shellcheck.sh` from `fx` → `ShellCheck 0.11.0, files checked: 13`, exit 0 (the project glob set includes `.agents/skills/*/scripts/*.sh`).

## Issues

None.

## Notes

- `tests/knowledge/provisional-ids.sh` reports 26 assertions at both `f58308b` and the head, so it does not assert per-row; the new `P111` row adds no assertion there. Not a regression, and `check_knowledge.py` passes, but the id's uniqueness is covered by the generic check rather than a cell of its own.
- `tests/spec-review/layout.sh` prints nothing and appears in neither AGENTS.md "Verifying" nor `factory-ci.yml`. Pre-existing and outside this diff; flagged only because the slice asked for every test under `tests/`.
- `factory918.sh apply` on the fixture ends with two FAILs (`labels present`, `slots filled`) that are environment, not code: no GitHub remote and no `/factory-start` interview. CI's fixture job pipes that step through `tail -30` and does not gate on it, so this matches CI's own behaviour.
- The fixture flow was run on macOS 15 (arm64) with vp 0.3.1, Node 24.21.0, pnpm 12.5.1, uv/ruff 0.16.8, pytest 9.1.1; CI runs it on ubuntu-latest. Both are green at this head.
