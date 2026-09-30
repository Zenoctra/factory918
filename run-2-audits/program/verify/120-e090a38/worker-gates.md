# Verifier report, slice `gates` — PR #120 (ticket #105) at e090a3880f1914fc327822c1618492dbad59ccf8

verdict: PASS

Setup: `git fetch origin feat/speed-lessons main`; `git checkout --detach e090a388…` → `git rev-parse HEAD` =
`e090a3880f1914fc327822c1618492dbad59ccf8`; `git merge-base --is-ancestor 86d156a HEAD` → exit 0. Diff
`86d156a..e090a38` = 54 files, 301 insertions, 83 deletions. Own worktree
`/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.claude/worktrees/agent-a4fa463b286f50d3b`,
private `TMPDIR` under the session scratchpad. No writes under version control; nothing posted to GitHub.

## 1. AGENTS.md "Verifying", every line

- `shellcheck --version` → `0.11.0` (the pin), exit 0.
- `bash .github/shellcheck.sh factory918.sh template/.github/shellcheck.sh 'template/.claude/hooks/*.sh' 'template/.agents/skills/*/scripts/*.sh' 'tests/*/*.sh'` → `ShellCheck 0.11.0, files checked: 20`, exit 0.
- `bash tests/shellcheck/gate.sh` → `ok 17 assertions`, exit 0.
- `bash tests/hooks/delegation.sh` → `ok 55 assertions`, exit 0.
- `bash tests/spec-review/review-comment.sh` → `ok 192 assertions`, exit 0.
- `bash tests/spec-review/review-brief.sh` → `ok 648 assertions`, exit 0.
- `bash tests/poteto-mode/overlap.sh` → `ok 57 assertions`, exit 0.
- `bash tests/spec-review/no-stale-wording.sh` → `ok: no stale wording`, exit 0. This bullet is the one the PR adds
  to `AGENTS.md` (`AGENTS.md:44`); the script itself predates the PR.
- `python3 tools/check_knowledge.py` → `knowledge ok: 119 files`, exit 0.
- `python3 tools/build_knowledge.py` → `knowledge files: 119 → docs/knowledge`, exit 0; `git status --porcelain`
  printed nothing.
- `./factory918.sh sync` → `vendored: 72 skills`, all 31 patches `applied`, including the 11 new ones;
  `git status --porcelain | wc -l` → `0`.
- `docs/M0-findings.md` gains three dated lines (2026-09-22: lane notifications routing to the root, the poll-path
  rule; no `pull_request` run for a conflicting PR), so the last "Verifying" bullet is honoured.
- Fixture flow, run with a relative `--directory fx` from a private parent
  (`…/scratchpad/fxroot`), per #123 and `.github/workflows/factory-ci.yml:51`:
  - `vp create vite:monorepo --directory fx --no-interactive --git --hooks --no-agent` → `Scaffolded fx`, `.git`
    present, exit 0; `git add -A && git commit -qm "chore: initial commit"` → `5c4332c`.
  - `./factory918.sh apply <fx> --scaffold --profile python --name demo` → every doctor check PASS except
    `labels present` and `slots filled (/factory-start)`, both of which need a GitHub remote and the Day-0
    interview and are equally absent in CI's fixture job (which pipes the command to `tail -30`). Not a finding.
  - In the fixture: `bash .github/shellcheck.sh` → `ShellCheck 0.11.0, files checked: 11`, exit 0.
  - `vp check` → `All 63 files are correctly formatted`, `Found no warnings, lint errors, or type errors in 9 files`.
  - `vp test run` → `Test Files 2 passed (2) / Tests 10 passed (10)`.
  - `pnpm sg:test` → `test result: ok. 2 passed; 0 failed;`.
  - `.github/workflows/python.yml` steps inside `python/demo`: `uv sync --frozen` ok; `uv run ruff format --check .`
    → `2 files already formatted`, exit 0; `uv run ruff check .` → `All checks passed!`, exit 0; `uv run pyright` →
    `0 errors, 0 warnings, 0 informations`, exit 0; `uv run pytest` → `1 passed`; `uv audit` → `Found no known
    vulnerabilities and no adverse project statuses in 10 packages`.

## 2. Every file under `tests/`

`find tests -type f` → 8 files. `fake-gh.sh` and `layout.sh` are skipped: `layout.sh` has no shebang and its header
says "Sourced by the spec-review tests" (`tests/spec-review/layout.sh:1`), and it is sourced at
`tests/spec-review/review-brief.sh:38` and `tests/spec-review/review-comment.sh:23`. The remaining six all pass at
the head (counts above).

Baseline: `git archive 86d156a` extracted to the scratchpad and the same six run there —
`gate.sh` 17, `delegation.sh` 55, `overlap.sh` 57, `review-comment.sh` 192, `review-brief.sh` 648,
`no-stale-wording.sh` `ok: no stale wording`. Identical to the head. The PR adds no assertions; its only test-file
change is one more `grep -F` needle in `no-stale-wording.sh` (see check 8).

## 3. Knowledge build

Covered above: `check_knowledge.py` exit 0, `build_knowledge.py` exit 0 and `git status --porcelain` empty.

## 4. Sync, patch reproduction, `series`, `SOURCES.md`

- `./factory918.sh sync` then `git status --porcelain` → empty (0 lines).
- Every patch the diff added or changed (20 `.md.patch` files) regenerated with the `patches/README.md` command
  against `research/3-pstack/open-pstack-claude-code-port/plugins/pstack/skills` (the root `factory918.sh:382`
  uses) and compared with `cmp -s`: 20/20 byte-identical, `fail=0`.
- `git diff --name-status` shows 11 patches added: `autonomous-run`, `eval`, `hillclimb`, `investigation`,
  `orchestrate`, `runtime-forensics`, `session-pickup`, `shipping`, `trace-forensics`, `visual-parity`,
  `worktree-cleanup`. `patches/series` gains exactly those 11 lines. Sorted `find patches -name '*.patch'` and
  sorted `patches/series` `diff` clean, 31 entries each — no orphan patch, no dangling series line.
- `SOURCES.md` item 16 (`SOURCES.md:28`) describes all 11: ten named in "That adds patches for …" plus
  "Investigation 1 in a new `investigation` patch".

## 5. ShellCheck on touched `*.sh`

The diff touches exactly one shell file, `tests/spec-review/no-stale-wording.sh`.
`shellcheck --severity=style tests/spec-review/no-stale-wording.sh` → no output, exit 0. It is also inside the
20-file gate run above.

## 6. CI

`gh run view 35816676418 --repo Zenoctra/factory918 --json headSha,conclusion,event,status,workflowName,jobs` →
`Factory CI pull_request completed success e090a3880f1914fc327822c1618492dbad59ccf8`; jobs `Fixture success`,
`Factory success`. Head SHA matches the SHA under verification exactly; every job succeeded.

## 7. `docs/knowledge/core/DECISIONS.md`

`git diff 86d156a..e090a38 -- docs/knowledge/core/DECISIONS.md` touches exactly three lines: the generated
`<!-- lines: 98 → 99 -->` header, the P29 row, and one appended row. P1–P28 and P30 are byte-identical to
`86d156a`. P29's change is the retitle (`A stacked PR is opened against trunk, then retargeted` →
`A stacked PR's ticket is linked through trunk`) plus one appended amendment sentence in the What column
("Amended 2026-09-22 (#105, P105): …"); its Why column is unchanged. The new row is `P105`
(`docs/knowledge/core/DECISIONS.md:99`), matching PR #121's rule that a Provisional row's id is its ticket number.
31 `| P…` rows; `sort | uniq -d` on the ids prints nothing, so `P105` is unique. The mirror
`template/docs/factory918/DECISIONS.md:91` carries the same row.

## 8. `no-stale-wording.sh` fails on a retired phrase

Scratch-only reproduction (`…/scratchpad/stale`, a minimal tree of the script plus `template/docs` and
`docs/knowledge/core`; nothing under version control was written):

- Baseline in the scratch tree → `ok: no stale wording`, exit 0.
- Appending all five retired phrases to the scratch `docs/knowledge/core/DECISIONS.md` → four `file:line` hits,
  exit 1.
- Restoring that file and appending only the phrase this PR adds
  (`skipped the Spec axis because the table unchanged`) to the scratch `template/docs/factory918/DECISIONS.md` →
  `template/docs/factory918/DECISIONS.md:92`, exit 1. The new needle alone makes the gate fail, so it is live and
  not shadowed by an existing one.

## Issues

None.

## Notes

- `AGENTS.md`'s fixture bullet still names the absolute `--directory /tmp/fx`, which `vp` 0.3.1 refuses. Known and
  already filed as #123 per the common brief; the relative form matched `.github/workflows/factory-ci.yml:51` and
  passed end to end.
- `patches/series` appends `investigation.md.patch` after `worktree-cleanup.md.patch`, breaking the alphabetical
  run of the other ten new entries. `sync` applies them in file order and the result is clean, so this is cosmetic.
- `./factory918.sh apply` on the fixture ends `FAIL labels present` and `FAIL slots filled (/factory-start)`. Both
  need a GitHub remote and the Day-0 interview, neither of which a local fixture has; CI's fixture job does not
  assert on the command's exit status either. Pre-existing, not caused by this PR.
- The PR adds no test assertions (counts identical to `86d156a` across all six runnable tests). Its one
  machine-checkable addition is the `table unchanged` needle, proven to bite in check 8; the rest of the change is
  playbook prose and the patches that carry it, which the sync and patch-reproduction checks cover.
