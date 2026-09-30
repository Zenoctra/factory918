verdict: PASS

PR #121 re-verified at `85988c7fe789202e4b9a880c71248578a139e2d4` in an isolated worktree, detached. `git merge-base --is-ancestor e090a38 HEAD` exited 0, so PR #120's verified head is in this history.

## Checks

- **1. Net diff against the pre-rebase one.** `git diff 86d156a e9fd603` (402 lines) vs `git diff e090a38 85988c7` (403 lines), compared with `diff -u`. Both patches touch the same 14 files (`diff` of the two `+++ b/...` lists: identical, exit 0). With `index ` and `@@ ` lines stripped, the only differing added/removed lines in the whole patch are four, all generated line counts:
  - `docs/knowledge/INDEX.md`: `| core/DECISIONS.md | … | 98 | … |` → `| … | 101 | … |` became `99` → `102`.
  - `docs/knowledge/core/DECISIONS.md`: `<!-- lines: 98 … -->` → `<!-- lines: 101 … -->` became `99` → `102`.
  Every other difference in the `diff -u` output is a blob hash on an `index` line or a shifted hunk header/context line where #120 appended nearby: `AGENTS.md` (`@@ -35,12 +35,13 @@` → `@@ -35,13 +35,14 @@`, new context line `- \`bash tests/spec-review/no-stale-wording.sh\`.`), `docs/M0-findings.md` (`@@ -185,3` → `@@ -189,3`, context now #120's two appended findings), `docs/agents/ledger.md` (`@@ -31,3` → `@@ -32,3`, context now #120's P105 ledger line), `docs/knowledge/core/DECISIONS.md` and `template/docs/factory918/DECISIONS.md` (context now #120's amended P29 and its P105 row), `template/.agents/skills/poteto-mode/playbooks/ticket.md` (`@@ -14,6` → `@@ -19,6`, offset by #120's step 0). #121's own added text is byte-identical in both patches.
- **Nothing of #120 lost.** Extracted all 290 added lines across the 54 files of `git diff 86d156a e090a38` and looked each up in the file at `85988c7` (script, scratchpad). Exactly 2 missing, and they are the two generated line counts above (`INDEX.md` row, `DECISIONS.md` header comment), both superseded by the rebuilt `102`. `git diff e090a38 85988c7` removes 6 lines in total; all 6 are #121's own edits, present as removals in the pre-rebase patch too (the `AGENTS.md` shellcheck count line, the two line-count lines, the `cites=` line and a comment in `review-brief.sh`, one docstring line in `check_knowledge.py`). Spot-checked that #120's and main's appended records survive: `docs/M0-findings.md` still has both the `gh issue edit N --body-file F` and the `The 2026-09-17 finding above` paragraphs (1 each), `docs/agents/ledger.md` still has the #91 `got exit 1, because PR #99` line, and `AGENTS.md` "Verifying" carries both #120's `no-stale-wording.sh` bullet and #121's `provisional-ids.sh` bullet.
- **2. Conflict markers.** `git grep -n '^<<<<<<<\|^>>>>>>>\|^|||||||'` → no output, exit 1. Clean.
- **3. Every line of `AGENTS.md` "Verifying" at this SHA.** All exit 0:
  - `bash .github/shellcheck.sh factory918.sh template/.github/shellcheck.sh 'template/.claude/hooks/*.sh' 'template/.agents/skills/*/scripts/*.sh' 'tests/*/*.sh'` → `ShellCheck 0.11.0, files checked: 21` (matches the "21 files" the line now claims).
  - `bash tests/shellcheck/gate.sh` → `ok 17 assertions`.
  - `bash tests/hooks/delegation.sh` → `ok 55 assertions`.
  - `bash tests/spec-review/review-comment.sh` → `ok 192 assertions`.
  - `bash tests/spec-review/review-brief.sh` → `ok 660 assertions`.
  - `bash tests/poteto-mode/overlap.sh` → `ok 57 assertions`.
  - `bash tests/spec-review/no-stale-wording.sh` → `ok: no stale wording`.
  - `bash tests/knowledge/provisional-ids.sh` → `provisional-ids: 26 assertions passed`.
  - `python3 tools/check_knowledge.py` → `knowledge ok: 119 files`, exit 0. `python3 tools/build_knowledge.py` → `knowledge files: 119 → docs/knowledge`, exit 0, then `git status --porcelain` empty (0 lines).
  - `./factory918.sh sync` → `vendored: 72 skills.`, then `git status --porcelain` empty (0 lines).
  - Fixture flow, with a relative `--directory fx` from a private parent (the scratchpad), as `.github/workflows/factory-ci.yml:51` does (#123): `vp create vite:monorepo --directory fx --no-interactive --git --hooks --no-agent` → `Scaffolded fx`, Node 24.21.0 / pnpm 12.5.1; `git add -A` + `git commit -qm "chore: initial commit"` exit 0; `./factory918.sh apply <fx> --scaffold --profile python --name demo` → doctor prints 21 PASS and the two FAILs a local fixture always has, `labels present` (no GitHub remote) and `slots filled (/factory-start)`; in `fx`: `vp check` exit 0 (63 files formatted, 9 files no errors), `vp test run` exit 0 (2 files, 10 tests), `pnpm sg:test` exit 0 (`2 passed; 0 failed`); in `python/demo` the steps of `.github/workflows/python.yml`: `uv sync --frozen` 0, `uv run ruff format --check .` 0, `uv run ruff check .` 0, `uv run pyright` 0 (`0 errors`), `uv run pytest` 0 (`1 passed`), `uv audit` 0 (`no known vulnerabilities`).
  - The dated-finding line: #121 adds one to `docs/M0-findings.md` for Claude Code desktop 2.2553.13.
- **4. DECISIONS.** `docs/knowledge/core/DECISIONS.md`: `| P105 |` at L101 and `| P110 |` at L102, one each; `| P29 |` at L99 carries #120's amendment. No duplicate ids (`grep -o '^| P[0-9a-z]* ' | sort | uniq -d` empty). One `## Provisional` heading and the id rule line ("A row's id is `P<N>`…") appears exactly once, at L68, under it. `template/docs/factory918/DECISIONS.md` mirrors it: rule line once, P105 and P110 present, no duplicate ids.
- **5. CI and PR state.** `gh run list --repo Zenoctra/factory918` for `85988c7…`: two `pull_request` runs of `Factory CI`, `35836470279` `completed`/`cancelled` (superseded) and **`35836470568` `completed`/`success`** — the non-cancelled run was already green, no polling needed. `gh pr view 121`: `baseRefName: feat/speed-lessons`, `headRefOid: 85988c7fe789202e4b9a880c71248578a139e2d4`, `mergeable: MERGEABLE`, `closingIssuesReferences: [#110]`. Read-only throughout; nothing commented, edited, merged or closed.

## Issues

None.

## Notes

- The root's account holds: the net diff's only content change is the two generated `DECISIONS.md` line counts (98→101 became 99→102), forced by #120's P105 row, and the append collisions were resolved keeping both sides — every #120 record line and every #121 record line is present, in that order, in `AGENTS.md`, `docs/M0-findings.md`, `docs/agents/ledger.md` and both DECISIONS tables. Checked independently, not taken on trust.
- The two doctor FAILs in the fixture flow (`labels present`, `slots filled`) are environmental for a local fixture with no GitHub remote and no `/factory-start` run; CI's own apply step pipes through `tail -30` and so does not gate on them either.
- The `AGENTS.md` shellcheck bullet's file count was bumped 20 → 21 by #121 and the run reports 21, so that line is accurate at this SHA.
