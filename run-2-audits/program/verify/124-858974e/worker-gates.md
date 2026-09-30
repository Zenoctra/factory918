verdict: PASS+NOTES

Slice: gates. PR #124 (ticket #103) at `858974ef18623c6db02d338adb9e0dd9978d6d36`, verified in the isolated worktree
`/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.claude/worktrees/agent-aca777c6525ce91a9`.
Setup: `git checkout --detach 858974e` → `git rev-parse HEAD` prints `858974ef18623c6db02d338adb9e0dd9978d6d36`;
`git merge-base --is-ancestor 86d156a HEAD` exit 0. No model run was launched; no GitHub write.

## 1. Every line of AGENTS.md "Verifying" at the SHA

- `shellcheck --version` → `version: 0.11.0`, exit 0. Matches the pin in `.github/shellcheck.sh:16`.
- `bash .github/shellcheck.sh factory918.sh template/.github/shellcheck.sh 'template/.claude/hooks/*.sh' 'template/.agents/skills/*/scripts/*.sh' 'tests/*/*.sh' 'tests/*/*/*.sh'` → `ShellCheck 0.11.0, files checked: 21`, exit 0. The AGENTS.md line says 21; the count matches.
- `bash tests/shellcheck/gate.sh` → `ok 17 assertions`, exit 0.
- `bash tests/hooks/delegation.sh` → `ok 55 assertions`, exit 0.
- `bash tests/spec-review/review-comment.sh` → `ok 192 assertions`, exit 0.
- `bash tests/spec-review/review-brief.sh` → `ok 648 assertions`, exit 0.
- `bash tests/poteto-mode/overlap.sh` → `ok 57 assertions`, exit 0.
- `bash tests/eval/reviewer/refusals.sh` (the new line) → `all 230 checks passed`, exit 0.
- `python3 tools/check_knowledge.py` → `knowledge ok: 119 files`, exit 0.
- `python3 tools/build_knowledge.py` → `knowledge files: 119 → docs/knowledge`, exit 0; `git status --porcelain` empty afterwards.
- `./factory918.sh sync` → 21 patches applied, `vendored: 72 skills`, exit 0; `git status --porcelain` empty afterwards.
- Fixture flow, run with a relative `--directory` from a private parent under the session scratchpad (per common, #123):
  - `vp create vite:monorepo --directory fx --no-interactive --git --hooks --no-agent` (vp v0.3.1, the ADR pin) → exit 0; then `git add -A && git commit -qm "chore: initial commit"` → exit 0.
  - `./factory918.sh apply <fx> --scaffold --profile python --name demo` → exit 0. Two expected FAILs in its own doctor output for a throwaway fixture with no GitHub remote and no Day-0 interview: `labels present` and `slots filled (/factory-start)`. Everything else PASS, including `shellcheck 0.11.0`, `ast-grep rules test`, `vp check`, `tests`. CI's fixture job pipes the same output through `tail -30` and does not gate on it (`.github/workflows/factory-ci.yml:53`), so this matches CI.
  - In the fixture: `bash .github/shellcheck.sh` → `files checked: 11`, exit 0. `vp check` → `All 63 files are correctly formatted`, `Found no warnings, lint errors, or type errors in 9 files`. `vp test run` → `Test Files 2 passed (2) / Tests 10 passed (10)`, exit 0. `pnpm sg:test` → `test result: ok. 2 passed; 0 failed;`, exit 0.
  - The steps of `.github/workflows/python.yml` inside `python/demo`: `uv sync --frozen && uv run ruff format --check . && uv run ruff check . && uv run pyright && uv run pytest && uv audit` → exit 0 (`2 files already formatted`, `All checks passed!`, `0 errors, 0 warnings, 0 informations`, `1 passed`, `Found no known vulnerabilities`).
- `docs/M0-findings.md` gets the dated line: `## Which reviewer model finds the hard bugs (2026-09-23)`, naming Claude Code 2.1.280 and Codex CLI 0.154.0 (`git diff 86d156a..HEAD -- docs/M0-findings.md`, +27 lines).

## 2. Every file under tests/, and the counts at both ends

- `git diff --name-status 86d156a..HEAD -- tests/` (rounds fixtures excluded) shows exactly three additions and no modification: `A tests/eval/reviewer/labels`, `A tests/eval/reviewer/refusals.sh`, `A tests/eval/reviewer/reviewer.py`. No pre-existing test file is touched, so the five pre-existing counts (17, 55, 192, 648, 57) are unchanged from 86d156a by construction.
- Non-listed but standalone: `bash tests/spec-review/no-stale-wording.sh` → `ok: no stale wording`, exit 0 (CI runs it; AGENTS.md does not list it, which is pre-existing).
- Skipped as instructed: `tests/spec-review/layout.sh` (sourced helper, no shebang, `# shellcheck shell=bash`) and `tests/spec-review/fake-gh.sh` (the `gh` stub).
- The owner's two claims hold: `refusals.sh` prints `all 230 checks passed` (230 numbered `ok` lines), and `python3 tests/eval/reviewer/reviewer.py check` prints exactly 13 `ok` lines (`pr94-r1` 1 standards + 4 spec, `pr96-r1` 2, `pr96-r2` 3, `pr99-r1` 2, `pr99-r1b` 1), exit 0.

## 3. Knowledge build

- Covered in check 1: `check_knowledge.py` exit 0, `build_knowledge.py` exit 0, `git status --porcelain` empty.

## 4. sync and the provider-dispatch patch

- `./factory918.sh sync` exit 0, `git status --porcelain` empty (check 1).
- Byte-for-byte reproduction, with the `patches/README.md` command against the real upstream path:
  `diff -u --label a/poteto-mode/references/provider-dispatch.md --label b/poteto-mode/references/provider-dispatch.md research/3-pstack/open-pstack-claude-code-port/plugins/pstack/skills/poteto-mode/references/provider-dispatch.md template/.agents/skills/poteto-mode/references/provider-dispatch.md > regen.patch` (exit 1, i.e. differences found, as expected), then
  `diff regen.patch patches/pstack/poteto-mode/references/provider-dispatch.md.patch` → no output, exit 0. Identical.
- Listed: `patches/series:15` → `pstack/poteto-mode/references/provider-dispatch.md.patch`.
- Described: `SOURCES.md:28`, item 16, naming the two probe notes, the `opus` alias resolving to Opus 5.5, Codex 0.154.0 refusing `gpt-6-terra` and `gpt-6-sol`, and `(#103)`.

## 5. ShellCheck on every `*.sh` the diff touched

- `git diff --stat 86d156a..HEAD` lists exactly one `.sh` file: `tests/eval/reviewer/refusals.sh` (+750).
- `ls tests/*/*/*.sh` → `tests/eval/reviewer/refusals.sh` only, so the new glob adds exactly that file and the gate went 20 → 21 files. At 86d156a the AGENTS.md line read `'tests/*/*.sh'` and "over 20 files" (`git show 86d156a:AGENTS.md`, line 38).
- The gate run in check 1 covers it, exit 0, zero findings at the default severity. `.github/shellcheck.sh` refuses a glob matching nothing, so the added glob is itself proof the file is in the set.

## 6. CI run 35835731395

- `gh run view 35835731395 --repo Zenoctra/factory918 --json headSha,conclusion,event,status,workflowName,jobs` → `Factory CI pull_request completed success 858974ef18623c6db02d338adb9e0dd9978d6d36`; jobs `Factory success` and `Fixture success`. Head SHA equals the reviewed head; both jobs green.
- The new step is present: `.github/workflows/factory-ci.yml:30-31`, `- name: reviewer.py prints, collects, scores and refuses what the test says` / `run: bash tests/eval/reviewer/refusals.sh`, placed after the overlap step and before `no-stale-wording.sh`.
- The workflow's ShellCheck step gained the same `'tests/*/*/*.sh'` glob as AGENTS.md (`.github/workflows/factory-ci.yml:19`), so CI and a lane run the same 21 files.

## 7. DECISIONS.md

- `git diff 86d156a..HEAD -- docs/knowledge/core/DECISIONS.md` is a pure append plus the generated header count (`<!-- lines: 98 -->` → `<!-- lines: 99 -->`). No P1–P30 row is added, removed or reworded.
- The new row is `P103 | Which model runs each review axis` at `docs/knowledge/core/DECISIONS.md:99`.
- Unique: `grep -o '^| P[0-9]*' docs/knowledge/core/DECISIONS.md | sort | uniq -d` prints nothing; 31 `| P` rows total.
- `template/docs/factory918/DECISIONS.md` gets the identical row, and `docs/knowledge/INDEX.md` its 98 → 99 line count, both consistent with the clean `build_knowledge.py` run.

## 8. The 15 keep refs

- `git ls-remote origin 'refs/keep/103/*'` returns exactly 15 refs, each named after the short SHA it points at.
- `git fetch origin 'refs/keep/103/*:refs/keep/103/*'` exit 0; `git for-each-ref 'refs/keep/103/*'` shows all 15 resolving to `commit` objects at the SHAs origin advertises. None is missing or dangling.
- One-to-one with the fixtures: `grep -h -E '^(head|fixed_point)=' tests/eval/reviewer/rounds/*/round | cut -d= -f2 | sort -u` yields exactly 15 SHAs, and the set is identical to the 15 keep-ref targets. Every kept ref is a head or fixed point a round says it reviewed, and every head and fixed point a round names is kept.

## Issues

(none)

## Notes

- `patches/README.md` documents regeneration as `diff -u ... research/<upstream>/<path> template/.agents/skills/<path>`, but the pstack upstream actually lives at `research/3-pstack/open-pstack-claude-code-port/plugins/pstack/skills/<path>`; the literal `research/3-pstack/<path>` does not exist. The patch reproduces exactly once the real path is used. Pre-existing on `main`, not introduced by this PR.
- P103's Why cites "the scheme #121 introduces in the same stack" for the ticket-number id. This PR's base is `86d156a` (main), where that scheme is not yet documented, so the forward reference only resolves once PR #121 is below it in the stack. Ordering matter for the root, not a defect here.
- Verifying check 8 fetched `refs/keep/103/*` into the shared repository's ref store (the worktree's `.git` is shared with the main checkout). The refs are byte-identical to origin's and no working tree or tracked file changed; `git status --porcelain` is empty at the end and HEAD is still `858974e`. I left them in place rather than deleting refs another lane may also have fetched.
- AGENTS.md's fixture line is a subset of what CI's Fixture job runs: CI also runs `pnpm sg`, the `review-brief.sh`-inside-the-project step and the "rules fire" probes. I ran the AGENTS.md line exactly; CI run 35835731395's Fixture job covers the rest, green. Pre-existing gap between the doc and CI.
- The `apply` doctor's two FAILs (`labels present`, `slots filled`) are inherent to a fixture with no GitHub remote and no Day-0 interview, and `apply` still exits 0, so they are not a regression.
