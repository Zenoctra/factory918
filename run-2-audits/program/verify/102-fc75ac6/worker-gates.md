verdict: PASS

For a person: every gate this slice names passes at PR #102's head, run from a detached worktree at fc75ac6 — the shell gate, all six test files, the knowledge build, the vendor sync with byte-for-byte patch regeneration, ShellCheck on every touched script, both CI runs, and the full fixture flow including the Python profile. The two CI runs are green on both jobs and the second is at this exact head; `DECISIONS.md` carries a unique new P30 and P20's 2026-09-22 (#93) amendment, with P25 to P29 untouched by this PR.

## Setup

- `git fetch origin feat/would-break-extra-rounds feat/spec-walk-risks main` then `git checkout --detach fc75ac69712119bb0e921e348a54b4d857c41b07`. `git rev-parse HEAD` → `fc75ac69712119bb0e921e348a54b4d857c41b07`. exit 0.
- `git merge-base --is-ancestor d8e382ca37233bce98724c785ecdbb677abc4e2a HEAD` → exit 0. The base is an ancestor.
- Worktree: `/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.claude/worktrees/agent-a4fb37c2c02b42db6`, private `TMPDIR` under the session scratchpad. `git status --porcelain` empty at the start and at the end of the run (0 lines).
- Commits in the PR: `41ce420`, `27c43af`, `1998c69`, `7b01fd6`, `fc75ac6` (5 commits, 20 files, +629/-63).

## 1. Every line of `AGENTS.md` "Verifying" at the SHA

- `bash .github/shellcheck.sh factory918.sh template/.github/shellcheck.sh 'template/.claude/hooks/*.sh' 'template/.agents/skills/*/scripts/*.sh' 'tests/*/*.sh'` → `ShellCheck 0.11.0, files checked: 20`. exit 0. The local `shellcheck --version` is 0.11.0, the pin, so the download path was not taken.
- `bash tests/shellcheck/gate.sh` → `ok 17 assertions`. exit 0.
- `bash tests/hooks/delegation.sh` → `ok 55 assertions`. exit 0.
- `bash tests/spec-review/review-comment.sh` → `ok 192 assertions`. exit 0.
- `bash tests/spec-review/review-brief.sh` → `ok 648 assertions`. exit 0.
- `bash tests/poteto-mode/overlap.sh` → `ok 57 assertions`. exit 0.
- `python3 tools/build_knowledge.py` → `knowledge files: 119 → docs/knowledge`, exit 0; `git status --porcelain` → 0 lines. `python3 tools/check_knowledge.py` → `knowledge ok: 119 files`, exit 0.
- `./factory918.sh sync` → `vendored: 72 skills`, exit 0; `git status --porcelain` → 0 lines.
- The fixture flow, run under the session scratchpad rather than the literal `/tmp/fx` so that concurrent verifiers cannot collide (same commands, different root):
  - `vp create vite:monorepo --directory fx --no-interactive --git --hooks --no-agent` (vp v0.3.1, the ADR pin; Node 24.21.0, pnpm 12.5.1) → exit 0; initial commit `86dd5f6`.
  - `./factory918.sh apply <fx> --scaffold --profile python --name demo` → exit 0 for the copy; the trailing `doctor` reports two FAILs expected on a local fixture, `labels present` (no GitHub remote) and `slots filled (/factory-start)` (no Day-0 interview). CI's own step pipes through `tail` and tolerates the same two.
  - In the fixture: `bash .github/shellcheck.sh` → `ShellCheck 0.11.0, files checked: 11`, exit 0.
  - In the fixture, CI's in-project brief step with `fake-gh.sh` on `PATH` and a blast-radius file: `review-brief.sh HEAD~1 --ticket 1 --blast-radius ...` → `ticket: #1`, `round: 1 of 3`, both briefs written; then every CI assertion on the two briefs (the hard-finding paragraph, `` `## Fails open` ``, no `## Latent`, `` `## Walk` `` in the Spec brief only, the cross-cutting risk sentence in the Spec brief only) → `ALL BRIEF ASSERTIONS OK`, exit 0.
  - `vp check` → `All 63 files are correctly formatted`, `Found no warnings, lint errors, or type errors in 9 files`. exit 0.
  - `vp test run` → `Test Files 2 passed (2)`, `Tests 10 passed (10)`. exit 0.
  - `pnpm sg:test` → `test result: ok. 2 passed; 0 failed;`. exit 0. `pnpm sg` → no output, exit 0.
  - The steps of `.github/workflows/python.yml` inside `python/demo`: `uv sync --frozen` exit 0; `uv run ruff format --check .` → `2 files already formatted`, exit 0; `uv run ruff check .` → `All checks passed!`, exit 0; `uv run pyright` → `0 errors, 0 warnings, 0 informations`, exit 0; `uv run pytest` → `1 passed`, exit 0; `uv audit` → `Found no known vulnerabilities and no adverse project statuses in 10 packages`, exit 0 (ruff 0.16.8, pyright 1.1.414, pytest 9.1.1).
  - Also ran CI's "The rules fire" step (not an `AGENTS.md` line, but part of the same fixture job): `no-todo-without-issue` and the ast-grep `no-console-log-ts` rule both fire → `RULES FIRE OK`, exit 0.
- "Anything verified against a tool version gets a dated line in `docs/M0-findings.md`": the diff introduces no new tool or version pin (no change to `.github/shellcheck.sh`, to the `SOURCES.md` pins, or to any workflow), so no new dated line is owed, and `docs/M0-findings.md` is untouched, consistently.

## 2. Every file under `tests/`

Six files; `fake-gh.sh` and `layout.sh` are the sourced helpers the slice excludes.

- `tests/shellcheck/gate.sh` → `ok 17 assertions`, exit 0.
- `tests/hooks/delegation.sh` → `ok 55 assertions`, exit 0.
- `tests/poteto-mode/overlap.sh` → `ok 57 assertions`, exit 0.
- `tests/spec-review/no-stale-wording.sh` → `ok: no stale wording`, exit 0. Changed by this diff; in CI but not in the `AGENTS.md` list.
- `tests/spec-review/review-brief.sh` → head `ok 648 assertions`; base d8e382c `ok 476 assertions`. **+172 assertions.**
- `tests/spec-review/review-comment.sh` → head `ok 192 assertions`; base d8e382c `ok 150 assertions`. **+42 assertions.**
- The base counts came from extracting d8e382c with `git archive` into the scratchpad and running both files there. Both matched the owner's reported 476 and 150 exactly, so the added cells are visible and attributable to this PR.

## 3. Knowledge

- `python3 tools/check_knowledge.py` → `knowledge ok: 119 files`, exit 0.
- `python3 tools/build_knowledge.py` → exit 0, then `git status --porcelain` → 0 lines. The generated tree matches its sources.

## 4. Vendor sync and patch regeneration

- `./factory918.sh sync` → 72 skills vendored, every patch in `series` reported `applied`, no `FAILED`; exit 0. `git status --porcelain` afterwards → 0 lines.
- The three patches the diff changed, each regenerated with the `patches/README.md` command and compared with `cmp`:
  - `patches/mattpocock/spec-review.SKILL.md.patch`, from `research/1-matt-pocock/skills-repo/skills/engineering/code-review/SKILL.md` to `template/.agents/skills/spec-review/SKILL.md` with labels `a/spec-review/SKILL.md` and `b/spec-review/SKILL.md` → `cmp` exit 0.
  - `patches/pstack/babysit/SKILL.md.patch`, from `research/3-pstack/open-pstack-claude-code-port/plugins/pstack/skills/babysit/SKILL.md` → `cmp` exit 0.
  - `patches/pstack/poteto-mode/playbooks/babysit.md.patch`, from the same pin's `poteto-mode/playbooks/babysit.md` → `cmp` exit 0.
  - The `code-review` → `spec-review` source mapping is the one `cmd_sync` uses (`factory918.sh:391`).
- All three are listed in `patches/series` (lines 4, 5 and 19), and their `SOURCES.md` entries (items 4, 6 and 12) are updated in the same diff, so the vendored-skill rule is honored end to end.

## 5. ShellCheck on every `*.sh` the diff touched

Five files: `template/.agents/skills/spec-review/scripts/review-brief.sh`, `template/.agents/skills/spec-review/scripts/review-comment.sh`, `tests/spec-review/no-stale-wording.sh`, `tests/spec-review/review-brief.sh`, `tests/spec-review/review-comment.sh`.

- `shellcheck --external-sources <the five>` from the repository root → exit 0, no output. `--external-sources` is the flag the gate itself uses (`.github/shellcheck.sh:47`).
- The bare `shellcheck <the five>` exits 1 with six SC1091/SC2154 findings, all of them from the unfollowed `tests/spec-review/layout.sh`. That is the documented design (`AGENTS.md`: the bare form fails in the factory by design), not a finding.

## 6. CI

- `gh run view 35781166757 --repo Zenoctra/factory918 --json headSha,conclusion,event,jobs` → headSha `fc75ac69712119bb0e921e348a54b4d857c41b07` (this head), event `pull_request`, status completed, conclusion success; jobs `Fixture` success and `Factory` success.
- `gh run view 35779526784 --repo Zenoctra/factory918 --json headSha,conclusion,event,jobs` → headSha `7b01fd6480b3e54a78611db4aca23bf55b4726be`, event `pull_request`, conclusion success; jobs `Fixture` success and `Factory` success. `git merge-base --is-ancestor 7b01fd6 HEAD` → exit 0.
- `gh run list --branch feat/would-break-extra-rounds --limit 10` returns exactly these two runs, nothing newer and nothing failing.

## 7. `docs/knowledge/core/DECISIONS.md`

- P25, P26, P27, P28 and P29 are all present at the SHA and byte-identical to the base: `git diff d8e382c..fc75ac6 -- docs/knowledge/core/DECISIONS.md` changes only the header line count (97 → 98) and the P20 row, and appends one row.
- `grep -c '^| P30 '` → 1. P30 is "Round five's stop is a draft and a report", dated 2026-09-22, citing ticket #93. No duplicate ids anywhere: `grep -o '^| P[0-9]* ' | sort | uniq -d` is empty; 29 rows (P1 through P30, P6 never used).
- P20 carries both 2026-09-22 amendments: "Amended 2026-09-22 (#90)" (the `restart` line) from below the chain, and "Amended 2026-09-22 (#93)" with this PR's rule — rounds four and five review only the Would-break fix with `<sha>` as the fixed point, the `round:` line reads `of 5` from round four, a sixth round is refused, and round five's stop points at P30.
- The generated copy `template/docs/factory918/DECISIONS.md` is in sync; the clean status after `build_knowledge.py` proves it.

## Issues

None.

## Notes

- The fixture flow was run under the session scratchpad instead of the literal `/tmp/fx` so that three concurrent verifiers could not share one directory. The commands and their order are otherwise identical to the `AGENTS.md` line and the CI job.
- `./factory918.sh apply` ends with `factory918 doctor`, which reports `FAIL labels present` and `FAIL slots filled (/factory-start)` on a local fixture with no GitHub remote and no Day-0 interview. CI hits the same two and tolerates them by piping the step through `tail`. Neither is a regression from this diff.
- `tests/spec-review/no-stale-wording.sh` is a gate this PR changes and CI runs, but it is not named in the `AGENTS.md` "Verifying" list. Worth a line there, though that is outside this PR's concern.
