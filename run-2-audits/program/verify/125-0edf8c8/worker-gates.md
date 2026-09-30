verdict: PASS

# Slice: gates, PR #125 (ticket #106) at 0edf8c8952e7563ec862e460f71becde4506bd96

Setup, own worktree `.claude/worktrees/agent-a7dda01c78060acb2`, detached at the head.
`git rev-parse HEAD` = `0edf8c8952e7563ec862e460f71becde4506bd96` (exit 0);
`git merge-base --is-ancestor 01a1e5f46891d10b234fe9ee80cbd9e8c67d4438 HEAD` exit 0.
Private `TMPDIR` under the session scratchpad; nothing written under version control
(`git status --porcelain` empty at the start and after every gate).

## 1. Every line of AGENTS.md "Verifying" at the SHA

The list at this SHA is longer than the brief's (the #120/#121/#124 chain added four lines).
All of it ran.

- `bash .github/shellcheck.sh factory918.sh template/.github/shellcheck.sh 'template/.claude/hooks/*.sh' 'template/.agents/skills/*/scripts/*.sh' 'tests/*/*.sh' 'tests/*/*/*.sh'`
  -> `ShellCheck 0.11.0, files checked: 23`, exit 0. The count matches the "over 23 files" the line claims.
- `bash tests/shellcheck/gate.sh` -> `ok 17 assertions`, exit 0.
- `bash tests/hooks/delegation.sh` -> `ok 55 assertions`, exit 0.
- `bash tests/spec-review/review-comment.sh` -> `ok 298 assertions`, exit 0.
- `bash tests/spec-review/review-brief.sh` -> `ok 1104 assertions`, exit 0.
- `bash tests/poteto-mode/overlap.sh` -> `ok 57 assertions`, exit 0.
- `bash tests/spec-review/no-stale-wording.sh` -> `ok: no stale wording`, exit 0.
- `bash tests/knowledge/provisional-ids.sh` -> `provisional-ids: 26 assertions passed`, exit 0.
- `bash tests/eval/reviewer/refusals.sh` -> `all 230 checks passed`, exit 0.
- `python3 tools/check_knowledge.py` -> `knowledge ok: 119 files`, exit 0.
- `python3 tools/build_knowledge.py` -> `knowledge files: 119 -> docs/knowledge`, exit 0; `git status --porcelain` empty after it.
- `./factory918.sh sync` -> `vendored: 72 skills.`, exit 0; `git status --porcelain` empty after it.
- Fixture flow, run with a relative `--directory fx` from a private parent under the scratchpad
  (per #123 and `.github/workflows/factory-ci.yml:51`), `vp v0.3.1`, `pnpm 12.5.1`:
  - `vp create vite:monorepo --directory fx --no-interactive --git --hooks --no-agent` exit 0; initial commit `841f6a4`.
  - `./factory918.sh apply <fx> --scaffold --profile python --name demo` exit 0.
  - in `fx`: `bash .github/shellcheck.sh` -> `files checked: 11`, exit 0; `vp check` exit 0
    (`All 63 files are correctly formatted`, `no warnings, lint errors, or type errors in 9 files`);
    `vp test run` exit 0 (`Tests 10 passed (10)`); `pnpm sg:test` exit 0 (`2 passed; 0 failed`);
    `pnpm sg` exit 0.
  - the steps of `.github/workflows/python.yml` inside `fx/python/demo`: `uv sync --frozen` 0,
    `uv run ruff format --check .` 0 (`2 files already formatted`), `uv run ruff check .` 0,
    `uv run pyright` 0 (`0 errors, 0 warnings`), `uv run pytest` 0 (`1 passed`),
    `uv audit` 0 (`no known vulnerabilities ... in 10 packages`).
- "Anything verified against a tool version gets a dated line in `docs/M0-findings.md`":
  `git diff --stat 01a1e5f..0edf8c8 -- docs/M0-findings.md` is empty, and the diff pins no new tool
  version, so the line asks for nothing here.

## 2. Every test under `tests/`, assertion counts

`find tests -name '*.sh' -o -name '*.py'` lists 12 files. `tests/spec-review/layout.sh` and
`tests/spec-review/fake-gh.sh` are the sourced helper and the `gh` stub (their own headers say so);
`tests/eval/reviewer/reviewer.py` is the subject of `refusals.sh`, not a test. Every other file ran,
above, plus `tests/eval/reviewer/rebuild.sh`, which AGENTS.md does not list: run over all 12 frozen
rounds (`pr94-r1..r3`, `pr96-r1..r3`, `pr99-r1`, `pr99-r1b`, `pr99-r2`, `pr101-r1`, `pr102-r1`,
`pr102-r2`) it printed `identical` and exit 0 for each, overall 0.

Counts, head against base `01a1e5f` (checked out and re-run there):
- `review-brief.sh`: 660 -> 1104 (+444). Owner's claim of 1104 confirmed.
- `review-comment.sh`: 192 -> 298 (+106). Owner's claim of 298 confirmed.
No suite lost assertions.

## 3. Knowledge, sync, patch reproduction

- `check_knowledge.py`, `build_knowledge.py` + empty status, `./factory918.sh sync` + empty status: above.
- The three patches the diff touches reproduce byte for byte with `patches/README.md`'s command
  (`diff -u --label a/<path> --label b/<path> research/<upstream>/<path> template/.agents/skills/<path>`),
  each regenerated into the scratchpad and `diff`ed against the committed patch, all exit 0:
  - `patches/mattpocock/spec-review.SKILL.md.patch` from
    `research/1-matt-pocock/skills-repo/skills/engineering/code-review/SKILL.md` -> identical.
  - `patches/pstack/babysit/SKILL.md.patch` from
    `research/3-pstack/open-pstack-claude-code-port/plugins/pstack/skills/babysit/SKILL.md` -> identical.
  - `patches/pstack/poteto-mode/playbooks/babysit.md.patch` from the same upstream root -> identical.
  All three are listed in `patches/series`, and `SOURCES.md` entry 6 carries the new prose.

## 4. ShellCheck on every `*.sh` the diff touched

The diff touches five shell files (`git diff --stat 01a1e5f..0edf8c8`):
`template/.agents/skills/spec-review/scripts/review-brief.sh`, `.../review-comment.sh`,
`tests/spec-review/no-stale-wording.sh`, `tests/spec-review/review-brief.sh`,
`tests/spec-review/review-comment.sh`.
`shellcheck --external-sources` (version 0.11.0, the pin) over exactly those five: exit 0, no output.
All five are inside the 23 the AGENTS.md line covers.

## 5. CI run 35849516283

`gh run view 35849516283 --repo Zenoctra/factory918 --json headSha,conclusion,event,status,workflowName,jobs`:
`headSha 0edf8c8952e7563ec862e460f71becde4506bd96`, `conclusion success`, `event pull_request`,
`status completed`, workflow `Factory CI`; jobs `Factory` completed success and `Fixture` completed
success. `gh run list --commit 0edf8c8...` returns this run and no other, so it is every check at the head.

## 6. DECISIONS at the SHA

`git diff 01a1e5f..0edf8c8 -- docs/knowledge/core/DECISIONS.md | grep -E '^[+-]\| P'` shows exactly three lines:
- `-| P20 | Three review rounds at most |`
- `+| P20 | Review rounds: three, five after a Would-break fix, fix-only from round three |`
- `+| P106 | Where a round-two finding sits | ...`

P20's row carries the dated amendment `Amended 2026-09-23 (#106): round three reviews only round
two's fix commits when round two's comment carries `fix only after <sha>` ...`, alongside the
earlier 2026-09-22 (#90) and (#93) amendments, which are unchanged.
`grep -c '^| P106 '` is 1 in `docs/knowledge/core/DECISIONS.md` and 1 in
`template/docs/factory918/DECISIONS.md`; `grep -oE '^\| P[0-9]+[b-z]? ' | sort | uniq -d` is empty,
so no id in the table is duplicated. P103, P105 and P110 do not appear in the diff; their rows read
as they do at the base. `docs/knowledge/INDEX.md` and the `<!-- lines: -->` header move 103 -> 104
with the added row, and `check_knowledge.py` accepts the result.

## 7. Tests before scripts

`git log --reverse --format='%h %s' 01a1e5f..0edf8c8` gives, in order:
`7b7d1fb` tests, `aa155fc` scripts, `dcb9055` scripts, `5f9a598` docs/patches (+ test wording),
`caecbc4` DECISIONS, `8fd83e1` tests, `f33a08a` scripts, `8d3496a` skill prose, `0edf8c8` DECISIONS.
Per-commit `--stat` confirms `7b7d1fb` and `8fd83e1` touch only `tests/spec-review/*`, so at each of
them the scripts are still the previous ones (`git diff --stat 01a1e5f..7b7d1fb -- template/` and
`git diff --stat caecbc4..8fd83e1 -- template/` are both empty).

Checked out and run with those old scripts:
- at `7b7d1fb`: `tests/spec-review/review-brief.sh` exit 1, first failure
  `FAIL (1R) (2A): .scratch/review/HEAD_2/fix-lines is not the lines r1..HEAD changed`;
  `tests/spec-review/review-comment.sh` exit 1, first failure
  `FAIL nothing found, no spec, no round file: exit 0, wanted 0 and the state cleared`
  (the wanted output carries the new `reviewed: <sha>` line the old script does not print).
- at `8fd83e1`: `tests/spec-review/review-brief.sh` exit 1, first failure
  `FAIL (1R) (2A): .scratch/review/HEAD_2/fix-lines is not the unique lines r1..HEAD added`;
  `tests/spec-review/review-comment.sh` exit 1, first failure
  `FAIL a hard item quoting a - line whose text is a fix line: a - line never counts (3B): exit 0, wanted 0, the fixture files, the tail and the state cleared`
  — that is a cell of the amended rule, i.e. the first cell the second tests commit adds.

Both tests commits are red before their script commit and the whole suite is green at the head.

## Issues

None.

## Notes

- `factory918 apply` on the fixture ends with the doctor printing two FAILs, `labels present` and
  `slots filled (/factory-start)`. Both are the expected day-0 state of a repository with no GitHub
  remote and no interview run; `apply` itself exits 0 and CI's fixture job reads the same output.
- `tests/eval/reviewer/rebuild.sh` is not in AGENTS.md "Verifying" and not in `.github/workflows/factory-ci.yml`.
  It passed on all 12 rounds here because this worktree already holds `refs/keep/103/*`; a fresh clone
  needs `git fetch origin 'refs/keep/103/*:refs/keep/103/*'` first. Worth a line in "Verifying" if it is
  meant to be a gate, but that is outside this PR.
- The brief's copy of the "Verifying" list predates this chain: at 0edf8c8 the list also carries
  `no-stale-wording.sh`, `provisional-ids.sh`, `eval/reviewer/refusals.sh` and a ShellCheck line over
  23 files with an extra `tests/*/*/*.sh` glob. All ran and passed.
