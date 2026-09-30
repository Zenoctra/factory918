verdict: PASS

# Slice: gates — PR #136 (ticket #108) at 6e5c539f44f90a341495aaf4bb3b44dd7b6e16c8

Setup. `git fetch origin feat/risk-dispositions main`, `git checkout --detach 6e5c539f44…` → `git rev-parse HEAD`
= `6e5c539f44f90a341495aaf4bb3b44dd7b6e16c8`; `git merge-base --is-ancestor a9ebdac HEAD` exit 0. Worktree clean
before and after every run (`git status --porcelain` empty). ShellCheck 0.11.0, vp 0.3.1, node v24.21.0, uv 0.12.12.

## 1. AGENTS.md "Verifying", every line

- `bash .github/shellcheck.sh factory918.sh template/.github/shellcheck.sh 'template/.claude/hooks/*.sh'
  'template/.agents/skills/*/scripts/*.sh' 'tests/*/*.sh' 'tests/*/*/*.sh'` → `ShellCheck 0.11.0, files checked: 26`,
  exit 0. The count matches the line's "over 26 files" at this SHA (`AGENTS.md:71`).
- `bash tests/shellcheck/gate.sh` → `ok 17 assertions`, exit 0.
- `bash tests/hooks/delegation.sh` → `ok 55 assertions`, exit 0.
- `bash tests/spec-review/review-comment.sh` → `ok 298 assertions`, exit 0.
- `bash tests/spec-review/review-brief.sh` → `ok 1720 assertions`, exit 0 (≈4 min).
- `bash tests/poteto-mode/overlap.sh` → `ok 57 assertions`, exit 0.
- `bash tests/show-me-your-work/check-trail.sh` → `ok 66 assertions`, exit 0.
- `bash tests/spec-review/no-stale-wording.sh` → `ok: no stale wording`, exit 0.
- `bash tests/knowledge/provisional-ids.sh` → `provisional-ids: 26 assertions passed`, exit 0.
- `bash tests/eval/reviewer/refusals.sh` → `all 230 checks passed`, exit 0.
- Fixture flow, run the way `.github/workflows/factory-ci.yml:51` runs it (relative `--directory fx` from a private
  parent, #123): `vp create vite:monorepo --directory fx --no-interactive --git --hooks --no-agent` exit 0;
  `./factory918.sh apply <fx> --scaffold --profile python --name demo` exit 0; in the project `bash
  .github/shellcheck.sh` → 13 files, exit 0; the workflow's `review-brief.sh HEAD~1 --ticket 1 --blast-radius
  /tmp/.../blast.md` step with the new `accepted: a fixture` disposition → `ticket: #1` / `round: 1 of 3`, both briefs
  written, the Walk and risk-sentence greps pass, exit 0; `vp check`, `vp test run`, `pnpm sg:test`, `pnpm sg` all exit
  0; `uv sync --frozen && uv run ruff format --check . && uv run ruff check . && uv run pyright && uv run pytest && uv
  audit` in `python/demo` exit 0. Script and full log: `/tmp/v136-gates/fixture.sh`, `FIXTURE_FAIL=0`.
- `docs/M0-findings.md`: untouched by this PR; no new tool-version claim is made, so no dated line is owed.

## 2. Every test under `tests/`; counts at head and at a9ebdac

- `find tests -name '*.sh'` lists 12 files. Nine are the AGENTS.md set, all run above. The other three are not tests:
  `tests/spec-review/layout.sh` is a sourced library with no shebang (`tests/spec-review/layout.sh:7`),
  `tests/spec-review/fake-gh.sh` is the `gh` stub the two spec-review tests and the CI fixture copy onto PATH, and
  `tests/eval/reviewer/rebuild.sh` replays a frozen #103 round from `refs/keep/103/*` and is not in Verifying.
- `tests/spec-review/review-brief.sh` at head: `ok 1720 assertions` — matches the owner's report exactly.
  At `a9ebdac` (tree extracted with `git archive a9ebdac`): `ok 1294 assertions`, exit 0. The suite grew by 426
  assertions; the test file grew 1770 → 1975 lines.

## 3. Knowledge, sync, patches

- `python3 tools/check_knowledge.py` → `knowledge ok: 119 files`, exit 0.
- `python3 tools/build_knowledge.py` → `knowledge files: 119 → docs/knowledge`, exit 0; `git status --porcelain` empty.
- `./factory918.sh sync` → `vendored: 72 skills`, exit 0, applying `pstack/blast-radius/SKILL.md.patch` among the 34;
  `git status --porcelain` empty. That re-vendor from `research/` plus a clean status is the byte-for-byte proof for
  every patch at once.
- Per-patch reproduction of each patch the PR touches, upstream copied fresh and the patch applied with `patch -p1`,
  then `diff` against `template/`: `pstack/blast-radius/SKILL.md.patch`, and the `opening-a-pr`, `bug-fix`, `feature`,
  `perf-issue`, `refactoring` playbook patches — all `identical` (script `/tmp/v136-gates/check-patches.sh`, exit 0).
  `mattpocock/spec-review.SKILL.md.patch` from
  `research/1-matt-pocock/skills-repo/skills/engineering/code-review/SKILL.md` → byte-identical.
- `patches/series`: 34 entries, all unique, every named file exists; `pstack/blast-radius/SKILL.md.patch` appears once,
  appended last (`patches/series:34`).
- `SOURCES.md`: item 19 is the new blast-radius entry (`SOURCES.md:31`), one line, and the numbering runs
  1..19 with no duplicate. Item 3 and item 6 were amended in place, no other item touched.

## 4. ShellCheck on every touched `*.sh`

The PR touches three shell files: `template/.agents/skills/spec-review/scripts/review-brief.sh`,
`tests/spec-review/fake-gh.sh`, `tests/spec-review/no-stale-wording.sh`. All three are inside the 26-file set the
gate command covers, and the gate passed at 0 findings. The AGENTS.md line and its count are correct at this SHA
(26 files checked, "over 26 files" written).

## 5. CI at this head

- `gh run list --repo Zenoctra/factory918 --json databaseId,headSha,conclusion,status,workflowName,event --limit 30`
  filtered to headSha `6e5c539f44…`: one run, `35912356052  Factory CI  pull_request  completed  success`.
- `gh run view 35912356052 --json jobs`: `Factory  completed  success`, `Fixture  completed  success`. Both jobs green,
  none skipped or cancelled.

## 6. Tests before script

- `git merge-base --is-ancestor 7cfdceb 4ad87b9` exit 0. `7cfdceb` ("Test every risk and writer flag…") touches only
  `factory-ci.yml`, `fake-gh.sh`, `no-stale-wording.sh` and `review-brief.sh` (the test, +215); `4ad87b9` ("Refuse a
  brief…") touches only `template/.agents/skills/spec-review/scripts/review-brief.sh` (+97/−16). The test commit
  really does precede the script commit and carries no script change.
- The tests commit's tree fails: `git archive 7cfdceb` extracted, `bash tests/spec-review/review-brief.sh` → exit 1,
  `FAIL SKILL.md step 4 carries the risk sentence`.
- Isolated to the script: HEAD's tree with only `review-brief.sh` reverted to its `a9ebdac` content →
  `bash tests/spec-review/review-brief.sh` exit 1, `FAIL Spec: the Walk bullet continues with the risk sentence (1A)`,
  the missing text being the new disposition clause the script writes. So the new assertions do fail against the old
  script, not merely against the old prose.

## 7. DECISIONS

- `P108` appears once (`docs/knowledge/core/DECISIONS.md:107`); no provisional id in the file is duplicated
  (`grep -oE '^\| P[0-9]+ ' | sort | uniq -d` is empty).
- The row is appended last: the file is 107 lines and P108 is line 107, so there are no rows below it to disturb. The
  only other row the diff touches is `P28` (line 98), amended with the disposition clause and the pointer to P108 —
  the ticket's design asks for exactly that. The header comment's line count moves 106 → 107, which is
  `build_knowledge.py`'s own stamp and rebuilds clean.
- `template/docs/factory918/DECISIONS.md` and `docs/knowledge/INDEX.md` are the generated copies and match the
  rebuild. `docs/agents/ledger.md` gains one dated line about the owner's worktree write refusals.

## Issues

None.

## Notes

- The fixture step in `.github/workflows/factory-ci.yml:68` had to gain `accepted: a fixture` on its blast-radius risk
  line for CI to stay green. That is the change proving itself: without the edit the new refusal would have failed the
  Fixture job. Worth knowing that any project's existing `## Risks` prose is now a hard refusal, not a warning.
- `tests/spec-review/review-brief.sh` is the long pole: ~4 minutes at head, ~3 at a9ebdac, and it prints nothing until
  the final count line.
- `tests/eval/reviewer/rebuild.sh` was not run; it needs `refs/keep/103/*` fetched and is not in AGENTS.md "Verifying".
- Scratch used: `/tmp/v136-gates/` (fixture script and log, patch-reproduction script, the three extracted trees, the
  two comparison runs). Nothing under version control was modified; `git status --porcelain` is empty at
  6e5c539f44f90a341495aaf4bb3b44dd7b6e16c8.
