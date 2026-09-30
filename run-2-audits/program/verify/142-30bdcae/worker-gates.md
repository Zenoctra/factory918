verdict: PASS

Slice: gates and the rebase. PR #142, head `30bdcae4913d0911e3aec2b2902611c2cf89c443`, base `origin/main` = `9846844d838403b8d0c0f9b4686852965dba6a40`.
Ran detached in a private worktree; read-only; no comment, edit, merge or close.

## 1. The rebase

- SHA confirmed: `git rev-parse HEAD` -> `30bdcae4913d0911e3aec2b2902611c2cf89c443`; `git merge-base --is-ancestor origin/main HEAD` -> exit 0. `origin/main` = `9846844`.
- `git diff --stat origin/main 30bdcae` and `git diff --stat e710e99 7505ee5` are identical: 9 files, 57 insertions, 15 deletions, same file list.
- Full diff texts compared. Only differences: blob `index` lines, four hunk-header line numbers, three context lines that main moved (the SOURCES.md patch-11 line and `docs/agents/ledger.md` / `DECISIONS.md` context now carrying #135's `Tier: eco` text and the P109 row), and the generated line counts.
- Changed lines only (`grep -E '^[+-]'`, file headers stripped): 72 lines on each side, identical except the generated counter, which is exactly the drift the root predicted:
  - `docs/knowledge/INDEX.md`: pre-rebase `107 -> 108`, rebased `108 -> 109`.
  - `docs/knowledge/pages/` DECISIONS header comment: the same shift.
  That is the only substantive difference between the two diffs.
- Nothing of main removed. Every `-` line in the PR diff is a line the PR itself rewrites (SOURCES.md patch 6, the SKILL.md step-1 sentence, patch context, four test comment blocks, one test body line) plus the two generated counters. No main-only row is dropped: the `DECISIONS.md` P-row ids at main and at head differ by exactly one addition, `| P139`; the `P108` and `P109` rows hash identically at main and head (`6aa689af...`, `e8cae055...`).
- No conflict markers, in the diff or in the tree.

## 2. Gates at 30bdcae

`AGENTS.md` "Verifying" at the SHA lists 13 bullets plus the fixture flow. Every one ran; counts at head -> at `origin/main`:

- `bash .github/shellcheck.sh factory918.sh template/.github/shellcheck.sh 'template/.claude/hooks/*.sh' 'template/.agents/skills/*/scripts/*.sh' 'tests/*/*.sh' 'tests/*/*/*.sh'` -> `ShellCheck 0.11.0, files checked: 26`, exit 0. Matches the "26 files" the line claims.
- `tests/shellcheck/gate.sh` -> `ok 17 assertions` (main: 17).
- `tests/hooks/delegation.sh` -> `ok 76 assertions` (main: 76).
- `tests/spec-review/review-comment.sh` -> `ok 298 assertions` (main: 298).
- `tests/spec-review/review-brief.sh` -> `ok 1872 assertions` (main: 1836). +36, the only count the PR moves.
- `tests/poteto-mode/overlap.sh` -> `ok 57 assertions` (main: 57).
- `tests/show-me-your-work/check-trail.sh` -> `ok 66 assertions` (main: 66).
- `tests/spec-review/no-stale-wording.sh` -> `ok: no stale wording` (main: the same).
- `tests/knowledge/provisional-ids.sh` -> `provisional-ids: 26 assertions passed` (main: 26).
- `tests/eval/reviewer/refusals.sh` -> `all 230 checks passed` (main: 230).
- `python3 tools/check_knowledge.py` -> `knowledge ok: 119 files`. `python3 tools/build_knowledge.py` -> `knowledge files: 119 -> docs/knowledge`; `git status --porcelain` empty afterwards.
- `./factory918.sh sync` -> `vendored: 72 skills`; `git status --porcelain` empty afterwards. The changed patch reproduces byte for byte: the run prints `applied  mattpocock/spec-review.SKILL.md.patch`, it is line 20 of `patches/series`, and the tree is clean after, so `template/.agents/skills/spec-review/SKILL.md` regenerates exactly.
- Every script under `tests/` is accounted for. The three not in the gate list are not gates: `tests/spec-review/layout.sh` is a sourced helper with no shebang, `tests/eval/reviewer/rebuild.sh` is a manual replay tool taking a round argument, and `tests/spec-review/fake-gh.sh` is the gh stub CI copies. All three are covered by the ShellCheck sweep.

Fixture flow, run the way `.github/workflows/factory-ci.yml:51` does, with a relative `--directory fx` from a private `mktemp -d` parent:

- `vp create vite:monorepo --directory fx --no-interactive --git --hooks --no-agent` (vp v0.3.1, Node 24.21.0, pnpm 12.6.0) -> scaffolded.
- `./factory918.sh apply <parent>/fx --scaffold --profile python --name demo` -> the doctor's two expected local FAILs only, `labels present` (the fixture has no GitHub remote) and `slots filled (/factory-start)`; every other check PASS, including `vp check`, `tests`, `shellcheck 0.11.0` and `ast-grep rules test`.
- In `fx`: `bash .github/shellcheck.sh` -> 13 files, exit 0. `vp check` -> 63 files formatted, no warnings, lint errors or type errors in 9 files. `vp test run` -> 2 files, 10 tests passed. `pnpm sg:test` -> `2 passed; 0 failed`.
- In `fx/python/demo`, the steps of the Python job: `uv sync --frozen`; `uv run ruff format --check .` -> `2 files already formatted`; `uv run ruff check .` -> `All checks passed!`; `uv run pyright` -> `0 errors, 0 warnings, 0 informations`; `uv run pytest` -> `1 passed`; `uv audit` -> no known vulnerabilities in 10 packages.

## 3. CI and PR state

- `gh run list --repo Zenoctra/factory918 --json databaseId,headSha,status,conclusion` -> exactly one run at `30bdcae`: id `35929912376`, workflow `Factory CI`, event `pull_request`, `status: completed`, `conclusion: success`. No cancelled run and no second run at the SHA, so no polling was needed.
- Its jobs: `Factory completed success`, `Fixture completed success`.
- `gh pr view 142 --json mergeable,closingIssuesReferences,baseRefName` -> `mergeable: MERGEABLE`, `baseRefName: main`, `headRefOid: 30bdcae...`, `state: OPEN`, closing `Zenoctra/factory918#139`.

## 4. Commit order and ids

Commit order (oldest first) with the files each touches:

1. `956cba3` Table D cells - `tests/spec-review/review-brief.sh`
2. `d98c3ca` Refuse a brief when a writer flags heading yields no flag - `template/.agents/skills/spec-review/scripts/review-brief.sh`
3. `cf31c9f` Record P139 - records
4. `175a358` test (list marker) -> 5. `731e404` script
6. `0d2b98c` SKILL.md, patch, SOURCES
7. `bb5eb0b` test (code comments, decorated headings) -> 8. `6f17c22` script
9. `c39a4ce` SKILL.md, patch, SOURCES
10. `588bb50` records and ledger
11. `2d4b289` test (possessive or plural) -> 12. `44b4880` script
13. `440d738` SKILL.md, patch, SOURCES, and one test line
14. `44281d8` records; 15. `30bdcae` records and ledger

Four test/script pairs, tests first in every one. No commit changes the script and its test together.

- P139 unique: exactly one `| P139 |` row in `docs/knowledge/core/DECISIONS.md` and one in the generated `template/docs/factory918/DECISIONS.md`.
- P109 and P108 untouched: both rows hash identically at `origin/main` and at head.

## Issues

None.

## Notes

- Commit 13, `440d738`, is the one commit that touches both a prose file and `tests/spec-review/review-brief.sh`. Its test change is a single `has` assertion pinning the SKILL.md sentence that same commit writes; no script line moves in it, so the tests-before-script rule is not touched. Worth knowing only because it is the one mixed commit.
- `apply` on the fixture leaves two doctor FAILs, `labels present` and `slots filled (/factory-start)`. Both are inherent to a local fixture with no GitHub remote and no Day-0 interview; CI pipes that output through `tail -30` and does not gate on it, and the workflow's later steps all pass here. Neither is in the PR's diff.
- `docs/knowledge/INDEX.md` also carries `core/MANUAL.md` at 179 lines at this head against 175 pre-rebase. That is main's content appearing in the diff's context, not a change the PR makes, and `build_knowledge.py` regenerates it clean.
- The rebase drops nothing of #135, #136 or #140: the diff's only `-` lines outside the PR's own rewrites are the two generated counters.
