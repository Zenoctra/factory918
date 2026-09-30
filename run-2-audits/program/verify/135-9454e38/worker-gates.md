verdict: PASS+NOTES

Slice: gates. PR #135 (ticket #109) at `9454e3849fadd5e69c9414b5a555fa316a6b5870`.
`git merge-base --is-ancestor a9ebdac HEAD` exits 0. Worktree clean before and after every check.

## 1. Every line of AGENTS.md "Verifying" at the SHA

All ran in the worktree at the head. Working tree clean throughout.

- `bash .github/shellcheck.sh factory918.sh template/.github/shellcheck.sh 'template/.claude/hooks/*.sh' 'template/.agents/skills/*/scripts/*.sh' 'tests/*/*.sh' 'tests/*/*/*.sh'` → `ShellCheck 0.11.0, files checked: 26`, exit 0. The count matches the number `AGENTS.md:29` states.
- `bash tests/shellcheck/gate.sh` → `ok 17 assertions`, exit 0.
- `bash tests/hooks/delegation.sh` → `ok 76 assertions`, exit 0.
- `bash tests/spec-review/review-comment.sh` → `ok 298 assertions`, exit 0.
- `bash tests/spec-review/review-brief.sh` → `ok 1294 assertions`, exit 0.
- `bash tests/poteto-mode/overlap.sh` → `ok 57 assertions`, exit 0.
- `bash tests/show-me-your-work/check-trail.sh` → `ok 66 assertions`, exit 0.
- `bash tests/spec-review/no-stale-wording.sh` → `ok: no stale wording`, exit 0.
- `bash tests/knowledge/provisional-ids.sh` → `provisional-ids: 26 assertions passed`, exit 0.
- `bash tests/eval/reviewer/refusals.sh` → `all 230 checks passed`, exit 0.
- `python3 tools/check_knowledge.py` → `knowledge ok: 119 files`, exit 0.
- `python3 tools/build_knowledge.py` → `knowledge files: 119 → docs/knowledge`, exit 0; `git status --porcelain` then printed nothing.
- `./factory918.sh sync` → `vendored: 72 skills.`, exit 0; `git status --porcelain` then printed nothing.
- Fixture flow, run with a relative `--directory fx` from a private `mktemp -d` parent as `.github/workflows/factory-ci.yml:55` does: `vp create vite:monorepo --directory fx --no-interactive --git --hooks --no-agent` exit 0; initial commit; `./factory918.sh apply <parent>/fx --scaffold --profile python --name demo` exit 0; in the fixture `bash .github/shellcheck.sh` → `ShellCheck 0.11.0, files checked: 13`, exit 0; `vp check` exit 0; `vp test run` exit 0; `pnpm sg:test` exit 0; `pnpm sg` exit 0; in `python/demo` `uv sync --frozen`, `uv run ruff format --check .` (`2 files already formatted`), `uv run ruff check .` (`All checks passed!`), `uv run pyright` (`0 errors, 0 warnings, 0 informations`), `uv run pytest` (`1 passed`), `uv audit` (`no known vulnerabilities`) all exit 0.
- `docs/M0-findings.md`: nothing owed. The diff pins no new tool version; it is prose, one patch pair and one test file.

## 2. Every test under tests/, counts at head and at a9ebdac

`find tests -name '*.sh'` at the head gives 12 files. Ten are the AGENTS.md list above, all run. The other two are not gate entries: `tests/spec-review/layout.sh` and `tests/spec-review/fake-gh.sh` are sourced/stubbed helpers (no shebang / a `gh` stub), and `tests/eval/reviewer/rebuild.sh` needs `refs/keep/103/*` fetched and is in neither `AGENTS.md` nor `.github/workflows/factory-ci.yml`.

Counts, head vs `a9ebdac` (each test re-run at the base in this worktree):

| test | a9ebdac | 9454e38 |
|---|---|---|
| tests/hooks/delegation.sh | 55 | 76 (+21) |
| tests/shellcheck/gate.sh | 17 | 17 |
| tests/spec-review/review-comment.sh | 298 | 298 |
| tests/spec-review/review-brief.sh | 1294 | 1294 |
| tests/poteto-mode/overlap.sh | 57 | 57 |
| tests/show-me-your-work/check-trail.sh | 66 | 66 |
| tests/knowledge/provisional-ids.sh | 26 | 26 |
| tests/eval/reviewer/refusals.sh | 230 | 230 |

The owner's claim holds: 76 at the head, 21 new. The 21 are a `for tier in none eco junk` loop with seven `expect` calls, `tests/hooks/delegation.sh:128-141`, one per cell of Table B in row order (B1 to B7), with `rm -f .claude/state/tier` at `:142` before `echo planning > .claude/state/mode`, as the ticket's test list item 1 asks. Every test exits 0 at the base too, so no test was made to pass by the change.

## 3. Knowledge, sync, patches

- `check_knowledge.py`, `build_knowledge.py` + empty status, `./factory918.sh sync` + empty status: all as above.
- Both changed patches reproduce byte for byte against the pinned upstream. `diff -u --label a/architect/SKILL.md --label b/architect/SKILL.md research/3-pstack/open-pstack-claude-code-port/plugins/pstack/skills/architect/SKILL.md template/.agents/skills/architect/SKILL.md` is byte-identical to `patches/pstack/architect/SKILL.md.patch` (`diff` exit 0). The same for `poteto-mode/playbooks/autopilot-stack.md` against `patches/pstack/poteto-mode/playbooks/autopilot-stack.md.patch` (`diff` exit 0).
- Both are in `patches/series` (`series:12` architect, `series:3` autopilot-stack) and both `SOURCES.md` entries were updated to describe the new text: entry 14 gains the one-runner exemption clause, entry 11 gains the `Tier: eco` brief sentence.
- `template/.agents/skills/poteto-mode/playbooks/ticket.md` changed with no patch, which is correct: it is in `sync`'s `keep_files` (`factory918.sh:385`), so it is ours and edited directly. The clean `git status` after `sync` confirms it survives re-vendoring.

## 4. ShellCheck on every touched .sh

The diff touches exactly one shell file, `tests/hooks/delegation.sh`, which the gate's `tests/*/*.sh` glob covers. The gate ran clean at 0.11.0 over 26 files, and the `AGENTS.md` line and its count were not changed by this PR and still match what the script reports.

## 5. CI at this head

`gh run view 35914742211 --repo Zenoctra/factory918` → `headSha 9454e3849fadd5e69c9414b5a555fa316a6b5870`, `status completed`, `conclusion success`; jobs `Factory` success and `Fixture` success. `gh pr checks 135` shows both passing, and no other check.

## 6. Tests before behavior

- `96901b9` ("Assert the delegation hook answers the same under every tier file") is the first commit on the branch and touches `tests/hooks/delegation.sh` only, 17 insertions.
- The hook itself is untouched by the whole PR: `git diff --name-only a9ebdac..9454e38 | grep -i hook` returns only `tests/hooks/delegation.sh`. So the new assertions are green against the unmodified hook, which is exactly the claim Table B makes ("every cell in a row is the same").
- Table B is the only table this PR turns into code. Tables A and C are walks the PR body reports, not committed tests, which matches the ticket's test list items 2 and 3.

## 7. DECISIONS and the ledger

- `grep -c '^| P109 ' docs/knowledge/core/DECISIONS.md` → 1; the generated `template/docs/factory918/DECISIONS.md` → 1. No other row carries the id, and `tests/knowledge/provisional-ids.sh` passes.
- P109 is appended as the last row (`docs/knowledge/core/DECISIONS.md:107`), so there is no row below it to disturb. The only other row touched is P11 (`:80`), amended deliberately, and P109's own text says "Amends P11 for a subagent owner in `eco`" — the two agree.
- The ledger line is present, `docs/agents/ledger.md:38`, dated 2026-09-23, and carries all three numbers ticket criterion 5 asks for: the waiting share ("267 of 506 measured minutes (53%)" plus "another 86 (17%)", "70% together", against "98 minutes of the owners' own reasoning"), the lanes that changed an outcome ("of 77 delegates the nine ... blast radius, the two reviewer axes, the trail review and the arena judge"), and the lanes that found nothing ("the how explorers and explainers, review wrapper lanes, small fix lanes and records lanes"). It cites `.scratch/program/postmortem/waits.md` and `delegates.md`, untracked in the main checkout and so not readable from this detached worktree; the numbers themselves were not re-derived here.

## Issues

None.

## Notes

- The PR body's Checks list quotes a stale ShellCheck invocation. It says `'tests/*/*.sh'` and "24 files", but `AGENTS.md:29` at this head also names `'tests/*/*/*.sh'` and the gate reports 26. The gate passes either way; the body's line just no longer matches the repository's own. The same list omits `check-trail.sh`, `no-stale-wording.sh`, `provisional-ids.sh` and `refusals.sh`, all four of which pass here and in CI.
- The PR body says "The fixture flow was not run locally; CI runs it." It was run locally for this verification, from a private parent with a relative `--directory fx`, and every step exits 0.
- The ticket's contract states the tier read as the one-liner `[ "$(cat "$f" 2>/dev/null)" = eco ]`. Ticket step 0 as shipped instead requires two plain commands (`git rev-parse --git-common-dir`, then `cat "<that dir>/../.claude/state/tier"`) and says why: a worktree-isolated agent's guard refuses `git` nested inside `$(...)` inside `[ ]`. I hit that same guard repeatedly in this session, so the shipped wording is the correct one. It is a deviation from the ticket's literal contract cell, decided in `3b03eb2` and `d9a4227`.
- `tests/eval/reviewer/rebuild.sh` was not run: it needs `refs/keep/103/*` fetched and is not part of any gate.
