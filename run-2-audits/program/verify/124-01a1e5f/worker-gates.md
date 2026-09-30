verdict: PASS

Re-verification of PR #124 (ticket #103) at `01a1e5f46891d10b234fe9ee80cbd9e8c67d4438`, gates slice. Every gate
AGENTS.md names ran green at the SHA, the rebase carried nothing over from #120 or #121 that the PR then removed,
and CI is green on the same SHA.

## Setup
- `git fetch origin feat/reviewer-model-eval feat/provisional-ticket-ids feat/speed-lessons main` and
  `git fetch origin 'refs/keep/103/*:refs/keep/103/*'`, both exit 0.
- `git checkout --detach 01a1e5f46891d10b234fe9ee80cbd9e8c67d4438`; `git rev-parse HEAD` ->
  `01a1e5f46891d10b234fe9ee80cbd9e8c67d4438`.
- `git merge-base --is-ancestor 85988c7 HEAD` -> exit 0. `git log --oneline 85988c7..HEAD` -> 25 commits, tip
  `01a1e5f Count the rebuild script in the ShellCheck gate`.
- Private `TMPDIR` under the session scratchpad. No model run launched (no `reviewer.py run`, no Agent, no Codex).
  GitHub read-only: only `gh run list`, `gh run view`, `gh pr view`.

## 1. Net diff against the pre-rebase diff
- `git diff --stat 85988c7 01a1e5f` and `git diff --stat 86d156a bd6a9b6` are byte-identical: `126 files changed,
  18291 insertions(+), 5 deletions(-)`, same 127 lines, `diff` exit 0.
- `diff <old.diff> <new.diff>` (the full patches) differs in 106 lines. Every difference is one of the expected
  four, nothing else:
  1. Blob index hashes on eight changed files (`index 8aeb061..f66d754` -> `index 13f688f..c847618`, and so on) and
     the hunk-header offsets that move with them (`@@ -35,12 +35,13 @@` -> `@@ -35,7 +35,7 @@`, `@@ -25,3 +25,4 @@`
     -> `@@ -26,3 +26,4 @@`, `@@ -96,3 +96,4 @@` -> `@@ -100,3 +100,4 @@`, `@@ -88,3 +88,4 @@` -> `@@ -92,3 +92,4 @@`).
  2. Context lines that are #120's and #121's own additions, unchanged by this PR: the CI step name
     `The knowledge check refuses the Provisional ids the test says`, SOURCES.md entry 16 (#105's speed lessons),
     the AGENTS.md bullets `bash tests/spec-review/no-stale-wording.sh` and `bash tests/knowledge/provisional-ids.sh`,
     two ledger lines, and the P105 and P110 DECISIONS rows. All carry a leading space in the new patch, so they are
     context, not additions of this PR.
  3. SOURCES.md: this PR's entry renumbered `16.` -> `17.` (`poteto-mode/references/provider-dispatch.md` ...
     `(#103)`), because #121 took 16. `tail -3 SOURCES.md` confirms 15, 16 (#105), 17 (#103).
  4. AGENTS.md ShellCheck line: the base it edits moved from `over 20 files` to `over 21 files`, and the PR's result
     from `over 22 files` to `over 23 files`; the glob added is the same `'tests/*/*/*.sh'` in both. Generated line
     counts moved from `98` -> `99` to `102` -> `103` in `docs/knowledge/INDEX.md` and
     `docs/knowledge/pages/decisions.md`.
- Nothing of #120 or #121 removed. All five deletions in `git diff 85988c7 01a1e5f` are four unique lines: the
  `.github/workflows/factory-ci.yml` ShellCheck `run:` line (extended by this PR), the AGENTS.md ShellCheck bullet
  (same), a `docs/M0-findings.md` line 3 the PR rewrites, and the two generated `102` count lines. Intersecting the
  removed set with `git diff 86d156a e090a38 | grep '^+'` (#120's additions) is empty; intersecting with
  `git diff e090a38 85988c7 | grep '^+'` (#121's) yields only the two generated count lines. `git diff e090a38
  01a1e5f` removes seven unique lines, of which only the two generated `99` count lines are #120 additions.
- No conflict markers: `grep -rn '^<<<<<<< \|^>>>>>>> \|^=======$'` over the tree (minus `.git`, `research/` and the
  frozen `tests/eval/reviewer/rounds/` diffs, which legitimately contain patch text) returns nothing.

## 2. Every line of AGENTS.md "Verifying" at the SHA
- ShellCheck: `bash .github/shellcheck.sh factory918.sh template/.github/shellcheck.sh 'template/.claude/hooks/*.sh'
  'template/.agents/skills/*/scripts/*.sh' 'tests/*/*.sh' 'tests/*/*/*.sh'` -> `ShellCheck 0.11.0, files checked: 23`,
  exit 0. AGENTS.md says 23. The two agree.
- `bash tests/shellcheck/gate.sh` -> `ok 17 assertions`, exit 0.
- `bash tests/hooks/delegation.sh` -> `ok 55 assertions`, exit 0.
- `bash tests/spec-review/review-comment.sh` -> `ok 192 assertions`, exit 0.
- `bash tests/spec-review/review-brief.sh` -> `ok 660 assertions`, exit 0.
- `bash tests/poteto-mode/overlap.sh` -> `ok 57 assertions`, exit 0.
- `bash tests/spec-review/no-stale-wording.sh` -> `ok: no stale wording`, exit 0.
- `bash tests/knowledge/provisional-ids.sh` -> `provisional-ids: 26 assertions passed`, exit 0.
- `bash tests/eval/reviewer/refusals.sh` -> `all 230 checks passed`, exit 0 (scenarios 1-24 plus the rule checks).
- `python3 tools/build_knowledge.py` -> `knowledge files: 119 -> docs/knowledge`, exit 0; `git status --porcelain`
  empty afterwards. `python3 tools/check_knowledge.py` -> `knowledge ok: 119 files`, exit 0.
- `./factory918.sh sync` -> `vendored: 72 skills`, all 14 listed patches applied; `git status --porcelain` empty
  afterwards.
- Beyond the list, the only other script under `tests/` that is a runnable gate is
  `tests/eval/reviewer/rebuild.sh <round>`. Run for all twelve rounds (`pr94-r1/r2/r3`, `pr96-r1/r2/r3`,
  `pr99-r1`, `pr99-r1b`, `pr99-r2`, `pr101-r1`, `pr102-r1`, `pr102-r2`): each printed `rebuild: <round>: identical`,
  exit 0. (`tests/spec-review/fake-gh.sh` and `tests/spec-review/layout.sh` are helpers, not gates.)
- Fixture flow, run the way `.github/workflows/factory-ci.yml:51` does, with a relative `--directory fx` from a
  private parent under the scratchpad:
  - `vp create vite:monorepo --directory fx --no-interactive --git --hooks --no-agent` (vp v0.3.1, the ADR pin) ->
    exit 0; `git add -A && git commit -qm "chore: initial commit"` -> exit 0.
  - `./factory918.sh apply <fx> --scaffold --profile python --name demo` -> exit 0. The doctor inside prints two
    FAILs, `labels present` and `slots filled (/factory-start)`, both of which need a GitHub remote and a Day-0
    interview this throwaway fixture has not had; CI's step pipes through `tail -30` and so is unaffected either way.
  - `bash .github/shellcheck.sh` inside the fixture -> `ShellCheck 0.11.0, files checked: 11`, exit 0.
  - The review-brief step: `review-brief.sh HEAD~1 --ticket 1 --blast-radius ...` behind `tests/spec-review/fake-gh.sh`
    -> `ticket: #1`, `round: 1 of 3`, both briefs written, exit 0; then every `grep -qF` assertion of that CI step
    (hard-finding paragraph, `## Fails open`, no `## Latent`, `## Walk` only in the Spec brief, the cross-cutting
    risk sentence only in the Spec brief) passed -> `ALL_BRIEF_ASSERTIONS_OK`, exit 0.
  - `vp check` exit 0 (63 files formatted, no warnings in 9 files), `vp test run` exit 0 (2 files, 10 tests),
    `pnpm sg:test` exit 0 (`2 passed; 0 failed`), `pnpm sg` exit 0.
  - `python/demo`: `uv sync --frozen` 0, `uv run ruff format --check .` 0, `uv run ruff check .` 0,
    `uv run pyright` 0, `uv run pytest` 0, `uv audit` 0 (uv 0.12.12).
  - The rules step: the TODO probe makes `vp lint` exit non-zero and the `console.log` probe makes `pnpm sg` exit
    non-zero, so both rules fire; exit 0.
- DECISIONS: `grep -c '^| P103 '`, `'^| P105 '`, `'^| P110 '` over `docs/knowledge/core/DECISIONS.md` each return
  `1`. Each id appears once as a row; `P110` also appears once in the section's prose sentence at line 68, which is
  the rule it states, not a second row.

## 3. CI and the PR
- `gh run list --repo Zenoctra/factory918 --json databaseId,headSha,status,conclusion` shows two runs on
  `01a1e5f46891d10b234fe9ee80cbd9e8c67d4438`: `35839059857` cancelled, and `35839060628` the live one.
- `gh run view 35839060628` -> `status: completed`, `conclusion: success`, `headSha:
  01a1e5f46891d10b234fe9ee80cbd9e8c67d4438`; jobs `Fixture` success and `Factory` success. No poll was needed; the
  run had finished by the first check.
- `gh pr view 124 --repo Zenoctra/factory918` -> `baseRefName: feat/provisional-ticket-ids`, `headRefOid:
  01a1e5f46891d10b234fe9ee80cbd9e8c67d4438`, `mergeable: MERGEABLE`, `state: OPEN`,
  `closingIssuesReferences: [#103]`.

## Issues
None.

## Notes
- AGENTS.md's fixture-flow bullet still writes the absolute `vp create ... --directory /tmp/fx`, while
  `.github/workflows/factory-ci.yml:51` runs `(cd /tmp && vp create ... --directory fx ...)`. That gap is #123's
  subject, not this PR's; I ran the flow the workflow's way and it passed.
- `tests/eval/reviewer/rebuild.sh` is counted in the ShellCheck gate (it is what commit `01a1e5f` adds to the count)
  but is not a bullet under AGENTS.md "Verifying". It takes a round argument rather than running a fixed set, so it
  is not a plain gate; CI does not run it either. All twelve rounds rebuild byte-identically here, so nothing is
  broken. Whether the list should name it is a judgment call for the owner.
- The two doctor FAILs during `factory918 apply` (`labels present`, `slots filled`) are the expected shape for a
  fixture with no GitHub remote and no Day-0 interview, and CI would not see them as failures because the step pipes
  the output. Recording them so the next reader does not read them as a regression.
