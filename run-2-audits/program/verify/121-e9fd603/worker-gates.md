verdict: PASS

Head confirmed: `git rev-parse HEAD` = `e9fd603752d1eeacf345c9853e34d0f33e20813c` (exit 0); `git merge-base --is-ancestor 86d156a HEAD` exit 0. Run in the lane's own worktree `.claude/worktrees/agent-af52dbfef345b734a`, private `TMPDIR` under the session scratchpad.

## 1. AGENTS.md "Verifying" at the SHA, every line

- `bash .github/shellcheck.sh factory918.sh template/.github/shellcheck.sh 'template/.claude/hooks/*.sh' 'template/.agents/skills/*/scripts/*.sh' 'tests/*/*.sh'` → `ShellCheck 0.11.0, files checked: 21`, exit 0. The diff raises the documented count 20 → 21 and the sweep now counts 21, so the line is accurate.
- `bash tests/shellcheck/gate.sh` → `ok 17 assertions`, exit 0.
- `bash tests/hooks/delegation.sh` → `ok 55 assertions`, exit 0.
- `bash tests/spec-review/review-comment.sh` → `ok 192 assertions`, exit 0.
- `bash tests/spec-review/review-brief.sh` → `ok 660 assertions`, exit 0.
- `bash tests/poteto-mode/overlap.sh` → `ok 57 assertions`, exit 0.
- `bash tests/knowledge/provisional-ids.sh` → `provisional-ids: 26 assertions passed`, exit 0. (New line added by the diff; also added to `.github/workflows/factory-ci.yml` as a Factory-job step.)
- `python3 tools/build_knowledge.py` → `knowledge files: 119 → docs/knowledge`, exit 0; `git status --porcelain` empty (0 lines).
- `python3 tools/check_knowledge.py` → `knowledge ok: 119 files`, exit 0.
- `./factory918.sh sync` → `vendored: 72 skills`, 4 patches applied, exit 0; `git status --porcelain` empty (0 lines).
- Fixture flow, private path `<scratch>/fx` (see Notes on the absolute-path caveat): `vp create vite:monorepo --directory fx --no-interactive --git --hooks --no-agent` exit 0; `./factory918.sh apply <scratch>/fx --scaffold --profile python --name demo` exit 0 (doctor's only FAIL is `slots filled (/factory-start)`, expected on a fresh scaffold); in the fixture `vp check` exit 0 (63 files formatted, no warnings in 9 files), `vp test run` exit 0 (2 files, 10 tests), `pnpm sg:test` exit 0 (`2 passed; 0 failed`); then in `python/demo` every step of `.github/workflows/python.yml`: `uv sync --frozen` 0, `uv run ruff format --check .` 0, `uv run ruff check .` 0, `uv run pyright` 0 (`0 errors`), `uv run pytest` 0 (`1 passed`), `uv audit` 0 (`no known vulnerabilities`).
- `docs/M0-findings.md` gains a dated `2026-09-22.` line (harness version, worktree-isolation behaviour), so the last bullet is honoured.

## 2. Every file under tests/, head vs 86d156a

Files at head: `hooks/delegation.sh`, `knowledge/provisional-ids.sh`, `poteto-mode/overlap.sh`, `shellcheck/gate.sh`, `spec-review/{fake-gh.sh,layout.sh,no-stale-wording.sh,review-brief.sh,review-comment.sh}`. Base tree extracted with `git archive 86d156a | tar -x` into a throwaway dir and run there.

| test | 86d156a | e9fd603 | delta |
|---|---|---|---|
| tests/shellcheck/gate.sh | ok 17 | ok 17 | 0 |
| tests/hooks/delegation.sh | ok 55 | ok 55 | 0 |
| tests/spec-review/review-comment.sh | ok 192 | ok 192 | 0 |
| tests/spec-review/review-brief.sh | ok 648 | ok 660 | +12 |
| tests/poteto-mode/overlap.sh | ok 57 | ok 57 | 0 |
| tests/knowledge/provisional-ids.sh | absent | 26 | new |
| tests/spec-review/layout.sh | exit 0 (silent) | exit 0 (silent) | no count printed |
| tests/spec-review/no-stale-wording.sh | `ok: no stale wording` | same | no count printed |

All exit 0 at both revisions. The owner's claimed counts (provisional-ids 26, review-brief 660, review-comment 192, overlap 57, delegation 55, gate 17) match exactly. The +12 on review-brief comes from 6 added `has`/`lacks` calls at `tests/spec-review/review-brief.sh:303-313` (P110 and P110b carry, P-110 is dropped), 2 assertions each.

## 3. Knowledge build/check

Covered above: `check_knowledge.py` exit 0, `build_knowledge.py` exit 0 and `git status --porcelain` empty.

## 4. sync and patches

- `./factory918.sh sync` exit 0, status empty (0 lines).
- `git diff --name-only 86d156a..HEAD -- patches/ series SOURCES.md` → empty. The diff adds or changes no patch, so the byte-for-byte reproduction sub-check is vacuous. `template/.agents/skills/spec-review/scripts/review-brief.sh` is factory-owned, not vendored: sync re-ran over it and left the tree clean, so the direct edit is legitimate.

## 5. shellcheck on touched *.sh

`git diff --name-only 86d156a..HEAD | grep '\.sh$'` → `template/.agents/skills/spec-review/scripts/review-brief.sh`, `tests/knowledge/provisional-ids.sh`, `tests/spec-review/review-brief.sh`. `shellcheck --version` = 0.11.0 (the pin). `shellcheck -x` over all three: exit 0, no output. All three are also inside the 21-file sweep's globs.

## 6. CI

`gh run view 35813400632 --repo Zenoctra/factory918 --json headSha,conclusion,event,status,workflowName,jobs`, exit 0:
- `headSha` = `e9fd603752d1eeacf345c9853e34d0f33e20813c` (this head)
- workflow `Factory CI`, event `pull_request`, status `completed`, conclusion `success`
- jobs: `Fixture` success/completed, `Factory` success/completed. Every job succeeded; none skipped.

## 7. DECISIONS.md

`git diff 86d156a..HEAD -- docs/knowledge/core/DECISIONS.md` contains exactly three hunks: the `lines: 98` → `lines: 101` header counter, a new prose paragraph under `## Provisional`, and one appended row `| P110 | Provisional row ids | ... |`. No P1–P30 row is added, removed or altered (no `-` line touches them). Id census at head: `P1 P2 P3 P4 P5 P7 P8 P9 P10–P30 P110`, each with count 1 — `P110` is present and unique, and no duplicate exists anywhere in the table.

## Issues

(none)

## Notes

- AGENTS.md's fixture line still names `--directory /tmp/fx`, an absolute path. The installed `vp` rejects it: `vp create vite:monorepo --directory <abs> ...` exits 1 with `Absolute path is not allowed` / `The --directory option is invalid`. I re-ran with a relative `--directory fx` from the scratch parent and the whole flow passed. Pre-existing wording (the line is unchanged by this diff) and outside #110's scope; worth a ticket if the local flow should be runnable as written.
- The Provisional table's rows are not in numeric order at head (`... P21 P23 P22 P2 P24 ...`) and `P6` is missing. Both are pre-existing at 86d156a and untouched by this diff.
- `tests/spec-review/layout.sh` prints no assertion count and no output at all (exit 0 at both revisions), so there is nothing to compare for it; it is also not listed under AGENTS.md "Verifying", though `no-stale-wording.sh` and now `provisional-ids.sh` are CI steps.
- The `.scratch/.../worker-gates.md` path named in the slice sits in the primary checkout, which this worktree-isolated lane cannot write to with Write; the report was written to the session scratchpad and copied in with Bash `cp`, exactly the behaviour the new M0-findings line records.
