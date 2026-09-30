# Verifier report, slice `gates`, PR #125 (ticket #106) at `caecbc4`

verdict: PASS

Setup: `git checkout --detach caecbc448983e071d4289d252f515993c4978cbf` → `git rev-parse HEAD` =
`caecbc448983e071d4289d252f515993c4978cbf`; `git merge-base --is-ancestor 01a1e5f HEAD` exit 0. Own worktree
`.claude/worktrees/agent-aa0207569812f9c1b`, private `TMPDIR` under the session scratchpad. Nothing under version
control was written; `git status --porcelain` empty at start and at end.

## 1. AGENTS.md "Verifying", every line at the SHA

- `bash .github/shellcheck.sh factory918.sh template/.github/shellcheck.sh 'template/.claude/hooks/*.sh' 'template/.agents/skills/*/scripts/*.sh' 'tests/*/*.sh' 'tests/*/*/*.sh'` → `ShellCheck 0.11.0, files checked: 23`, exit 0. The line's "over 23 files" is exact.
- `bash tests/shellcheck/gate.sh` → `ok 17 assertions`, exit 0.
- `bash tests/hooks/delegation.sh` → `ok 55 assertions`, exit 0.
- `bash tests/spec-review/review-comment.sh` → `ok 264 assertions`, exit 0.
- `bash tests/spec-review/review-brief.sh` → `ok 986 assertions`, exit 0.
- `bash tests/poteto-mode/overlap.sh` → `ok 57 assertions`, exit 0.
- `bash tests/spec-review/no-stale-wording.sh` → `ok: no stale wording`, exit 0.
- `bash tests/knowledge/provisional-ids.sh` → `provisional-ids: 26 assertions passed`, exit 0.
- `bash tests/eval/reviewer/refusals.sh` → `all 230 checks passed`, exit 0.
- `python3 tools/check_knowledge.py` → `knowledge ok: 119 files`, exit 0.
- `python3 tools/build_knowledge.py` → `knowledge files: 119 → docs/knowledge`, exit 0; `git status --porcelain` empty after.
- `./factory918.sh sync` → `vendored: 72 skills`, exit 0; `git status --porcelain` empty after.
- Fixture flow, run for real with a relative `--directory fx` from a private parent (#123 workaround), vp v0.3.1 / pnpm 12.5.1 / ShellCheck 0.11.0, macOS arm64, 2026-09-23: `vp create vite:monorepo --directory fx --no-interactive --git --hooks --no-agent` rc 0; initial commit rc 0; `./factory918.sh apply <fx> --scaffold --profile python --name demo` rc 0; in fx `bash .github/shellcheck.sh` → `files checked: 11`, rc 0; `vp check` rc 0 (63 files formatted, 9 files no warnings); `vp test run` rc 0 (2 files, 10 tests); `pnpm sg:test` rc 0 (`2 passed; 0 failed`); `pnpm sg` rc 0; in `python/demo` `uv sync --frozen && uv run ruff format --check . && uv run ruff check . && uv run pyright && uv run pytest && uv audit` rc 0 (`0 errors, 0 warnings`, `1 passed`, `no known vulnerabilities`).
- `docs/M0-findings.md` dated line: not part of this slice's checks beyond noting the line exists in AGENTS.md.

## 2. Every test under `tests/`, and assertion counts

- `find tests -type f` lists exactly five non-test shell files besides the eight suites above: `tests/spec-review/layout.sh` (no shebang, header says "Sourced by the spec-review tests", sourced at `tests/spec-review/review-brief.sh:43` and `review-comment.sh:28`), `tests/spec-review/fake-gh.sh` (a `gh` stub), `tests/eval/reviewer/rebuild.sh` (a rebuild tool, not a suite), plus `reviewer.py` and the frozen `rounds/` fixtures. No runnable suite is missing from the AGENTS.md list.
- Counts at `caecbc4`: review-brief.sh 986, review-comment.sh 264 — the owner's claim, confirmed verbatim.
- Counts at the base `01a1e5f` (checked out in this worktree, then returned): review-comment.sh `ok 192 assertions`, review-brief.sh `ok 660 assertions`, both exit 0. Deltas +326 (brief) and +72 (comment).

## 3. Knowledge, sync, patch reproduction

- `check_knowledge.py`, `build_knowledge.py` + empty status, `sync` + empty status: all above, all clean.
- Patch reproduction with the `patches/README.md` command (`diff -u --label a/<path> --label b/<path> <upstream> <template> `), then `cmp` against the committed patch:
  - `patches/pstack/babysit/SKILL.md.patch` from `research/3-pstack/open-pstack-claude-code-port/plugins/pstack/skills/babysit/SKILL.md` → identical (cmp exit 0).
  - `patches/pstack/poteto-mode/playbooks/babysit.md.patch` from the same pstack root → identical (cmp exit 0).
  - `patches/mattpocock/spec-review.SKILL.md.patch` from `research/1-matt-pocock/skills-repo/skills/engineering/code-review/SKILL.md` (the upstream `factory918.sh:391` copies to `spec-review`) → identical (cmp exit 0).
  - All three are listed in `patches/series` and described in `SOURCES.md` (items 4, 6, 12, all three touched by this diff).

## 4. ShellCheck on every `*.sh` the diff touched

`git diff --stat 01a1e5f..caecbc4` touches five shell files. `shellcheck -x -P template/.agents/skills/spec-review/scripts template/.agents/skills/spec-review/scripts/review-brief.sh template/.agents/skills/spec-review/scripts/review-comment.sh tests/spec-review/no-stale-wording.sh tests/spec-review/review-brief.sh tests/spec-review/review-comment.sh` → no output, exit 0, at `version: 0.11.0`.

## 5. CI

`gh run view 35844249945 --repo Zenoctra/factory918 --json headSha,conclusion,event,status,jobs` →
`headSha caecbc448983e071d4289d252f515993c4978cbf`, `conclusion success`, `status completed`, `event pull_request`;
jobs `Fixture success`, `Factory success`. `gh run list --commit caecbc44...` returns that one run only, so no other
workflow at this head is unaccounted for.

## 6. DECISIONS at the SHA

- P20 retitled: `- | P20 | Three review rounds at most |` → `+ | P20 | Review rounds: three, five after a Would-break fix, fix-only from round three |` (`docs/knowledge/core/DECISIONS.md:89`).
- P20 carries a dated amendment for this ticket: "Amended 2026-09-23 (#106): round three reviews only round two's fix commits when round two's comment carries `fix only after <sha>` …", alongside the earlier 2026-09-22 (#90) and (#93) amendments, which are unchanged.
- `grep -c '^| P106 '` = 1; `grep -oE '^\| P[0-9]+ ' | sort | uniq -d` prints nothing, so no id in the table is duplicated.
- P103, P105 and P110 are all present and none appears on a `+`/`-` line of `git diff 01a1e5f..caecbc4 -- docs/knowledge/core/DECISIONS.md` (grep count 0).
- The table's header comment moves `lines: 103` → `104`, consistent with one row added; the generated `template/docs/factory918/DECISIONS.md` copy matches, since `build_knowledge.py` left the tree clean.

## 7. Tests before scripts

- `git log --reverse --format='%h %s' 01a1e5f..caecbc4`: `7b7d1fb` Test the fix-only third round and the three new comment lines → `aa155fc` Review only round two's fix at round three … → `dcb9055` Pick a fix-only round's items with one filter → `5f9a598` Say which rounds review only the fix and when a review is owed → `caecbc4` Record the fix-only third round in P20 …
- `git show --stat 7b7d1fb` touches only `tests/spec-review/review-brief.sh` and `review-comment.sh`; `git diff --stat 01a1e5f 7b7d1fb -- template/.agents/skills/spec-review/scripts/` is empty, so the tests commit carries the old scripts.
- At `7b7d1fb`: `bash tests/spec-review/review-comment.sh` exit 1, first failure `FAIL nothing found, no spec, no round file: exit 0, wanted 0 and the state cleared` (the new `reviewed:` line assertion on the first cell); `bash tests/spec-review/review-brief.sh` exit 1, first failure `FAIL (1R) (2A): .scratch/review/HEAD_2/fix-lines is not the lines r1..HEAD changed`. Both pass at `caecbc4`. The tests fail with the old scripts and pass with the new ones.

## Issues

(none)

## Notes

- The local fixture's `factory918 apply` prints `FAIL labels present` and `FAIL slots filled (/factory-start)` inside the factory-doctor summary while exiting 0. Both are expected on a fixture with no GitHub remote and no `/factory-start` run; CI's step behaves the same and is green. Not caused by this diff.
- The fixture line in AGENTS.md still writes the absolute `--directory /tmp/fx` that `vp` refuses; `.github/workflows/factory-ci.yml:51` already uses the relative form. That is #123, filed, and outside this PR.
- `git checkout --detach` to `01a1e5f` and `7b7d1fb` and back to `caecbc4` was done inside this verifier's own worktree only; HEAD is back at `caecbc4` and the tree is clean.
