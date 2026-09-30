verdict: PASS

# Slice: gates — PR #94 (ticket #89) at 78be65edc94f22b257d3c220b74482c7e884806b

Every repository gate was re-run at the SHA in an isolated worktree
(`.claude/worktrees/agent-a24834db699d6a270`), detached at the head SHA. Nothing under version
control was changed; `git status --porcelain` was empty at the start and at the end.

## Setup

- `git fetch origin feat/design-artifact-on-ticket main` → ok, exit 0.
- `git checkout --detach 78be65edc94f22b257d3c220b74482c7e884806b` → `HEAD is now at 78be65e Record the drained-lanes lesson again and what gh issue edit does`, exit 0.
- `git rev-parse HEAD` → `78be65edc94f22b257d3c220b74482c7e884806b`. Matches the brief.
- Diff scope, `git diff --name-status ab47eb9...78be65e` → 35 files, 298 insertions, 39 deletions. Shell files touched: `template/.agents/skills/poteto-mode/scripts/overlap.sh`, `tests/poteto-mode/overlap.sh`. Tests touched: `tests/poteto-mode/overlap.sh`. Patches added or changed: 7 files plus `patches/series`.

## 1. Shell syntax

- `bash -n factory918.sh` → no output, exit 0.
- CI's wider syntax loop, mirrored (`template/.claude/hooks/*.sh`, `template/.agents/skills/spec-review/scripts/*.sh`, `template/.agents/skills/poteto-mode/scripts/*.sh`, `tests/*/*.sh`) → `checked: 16 files, rc=0`, exit 0.

## 2. Tests

- `bash tests/hooks/delegation.sh` → `ok 55 assertions`, exit 0.
- `bash tests/spec-review/review-comment.sh` → `ok 82 assertions`, exit 0.
- `bash tests/spec-review/review-brief.sh` → `ok 334 assertions`, exit 0.
- `bash tests/poteto-mode/overlap.sh` → `ok 57 assertions`, exit 0. This is the one test file the diff touched (+23/−6 lines).
- The two test files the "Verifying" list omits but `tests/` holds were run as well: `bash tests/spec-review/layout.sh` → exit 0 (silent); `bash tests/spec-review/no-stale-wording.sh` → `ok: no stale wording`, exit 0.
- `find tests -type f` lists seven files; `tests/spec-review/fake-gh.sh` is a helper, not a runnable test. No test file was added by the diff.

## 3. Knowledge base

- `python3 tools/check_knowledge.py` → `knowledge ok: 119 files`, exit 0.
- `python3 tools/build_knowledge.py` → `knowledge files: 119 → docs/knowledge`, exit 0.
- `git status --porcelain` immediately after → empty output, exit 0. The build is reproducible at this SHA.
- The docstring change in `tools/build_knowledge.py:8` ("copies every core document except CONVERSATION-DIGEST") matches the code: the exclusion at `tools/build_knowledge.py:136` is `if p.name != "CONVERSATION-DIGEST.md":`, generic rather than an enumeration, and the new `("core/SCENARIO-TABLE.md", ...)` tuple at line 42 is the only other change. `template/docs/factory918/SCENARIO-TABLE.md` is present in the tree and in the diff, consistent with that.

## 4. Vendored tree reproduces

- `./factory918.sh sync` → exit 0; 20 lines `applied  <patch>`, zero lines matching `FAILED`, then `vendored: 72 skills.`
- `git status --porcelain` immediately after → empty output, exit 0. Every patch in `series` applies and the result equals `template/.agents/skills` byte for byte.
- `template/.agents/skills/poteto-mode/scripts/overlap.sh` is changed by the diff with no patch behind it; that is correct and not a gap. It is in `sync`'s `keep_files` (`factory918.sh:381`) and `SOURCES.md:21` records "`poteto-mode/scripts/overlap.sh` is ours, not a patch". The clean status after sync confirms sync preserves it.

## 5. Patches reproduce byte for byte

Regenerated with the command in `patches/README.md`, `diff -u --label a/<path> --label b/<path> research/<upstream>/<path> template/.agents/skills/<path>`, and compared with `cmp -s`. Upstream roots taken from `factory918.sh:378-379`: pstack `research/3-pstack/open-pstack-claude-code-port/plugins/pstack/skills`, Pocock `research/1-matt-pocock/skills-repo/skills` (`to-spec` resolves to `.../skills/engineering/to-spec`).

- `patches/pstack/architect/SKILL.md.patch` (added) → IDENTICAL.
- `patches/pstack/architect/references/runner-prompt.md.patch` (added) → IDENTICAL.
- `patches/pstack/poteto-mode/playbooks/bug-fix.md.patch` (changed) → IDENTICAL.
- `patches/pstack/poteto-mode/playbooks/feature.md.patch` (changed) → IDENTICAL.
- `patches/pstack/poteto-mode/playbooks/perf-issue.md.patch` (changed) → IDENTICAL.
- `patches/pstack/poteto-mode/playbooks/refactoring.md.patch` (changed) → IDENTICAL.
- `patches/mattpocock/to-spec/SKILL.md.patch` (added) → IDENTICAL.
- All seven, exit 0 on `cmp`. `patches/series` gains exactly the two `pstack/architect/*` lines and the one `mattpocock/to-spec/SKILL.md.patch` line; `SOURCES.md` gains items 14 and 15 describing them and extends item 13. AGENTS.md rule 3 (patch + `series` + `SOURCES.md`) is satisfied for every added patch.

## 6. shellcheck

- `shellcheck --version` → `version: 0.11.0`.
- `shellcheck template/.agents/skills/poteto-mode/scripts/overlap.sh tests/poteto-mode/overlap.sh` (the full output of `git diff --name-only ab47eb9...78be65e -- '*.sh'`) → no output, exit 0.

## 7. CI runs

`gh run view <id> --repo Zenoctra/factory918 --json headSha,conclusion,event,status,workflowName,displayTitle`:

- `35745145787` → `conclusion: success`, `event: pull_request`, `status: completed`, `workflowName: Factory CI`, `headSha: c83f166578a35e61d0b686c1ae1ed652b051dba6`.
- `35747733851` → `conclusion: success`, `event: pull_request`, `status: completed`, `headSha: 0c63fa6f239ef930abacabe9086b3455a7313b2e`.
- `35748776685` → `conclusion: success`, `event: pull_request`, `status: completed`, `headSha: 78be65edc94f22b257d3c220b74482c7e884806b`. This one is at the verified SHA.
- All three head SHAs are in `gh pr view 94 --json commits` for this PR (11 commits; `c83f166` is #6, `0c63fa6` is #10, `78be65e` is #11 and last). `headRefOid` is `78be65edc94f22b257d3c220b74482c7e884806b`, `headRefName: feat/design-artifact-on-ticket`, `baseRefName: main`, `state: OPEN`, `mergeable: MERGEABLE`.
- `gh run list --branch feat/design-artifact-on-ticket --limit 20` returns exactly those three runs and no others: no failed or cancelled run is being omitted.
- Jobs of the run at the SHA: `Factory: success`, `Fixture: success`.

## 8. Fixture flow (extra; AGENTS.md calls it "what CI runs")

`vp`, `uv` and `pnpm` are installed locally, so this was re-run rather than taken from CI. Run into a session-scratch directory, not `/tmp/fx`, to avoid colliding with the other verifiers.

- `vp create vite:monorepo --directory fx-94 --no-interactive --git --hooks --no-agent`, initial commit, then `./factory918.sh apply <fx> --scaffold --profile python --name demo` → ok.
- In the fixture: `vp check`, `vp test run`, `pnpm sg:test`, `pnpm sg` → all ok.
- In `<fx>/python/demo`: `uv sync --frozen`, `uv run ruff format --check .`, `uv run ruff check .`, `uv run pyright`, `uv run pytest`, `uv audit` (`Found no known vulnerabilities and no adverse project statuses in 10 packages`) → all ok. Script ended `FIXTURE-FLOW-OK`, exit 0.
- CI's "The rules fire" step re-run against the same fixture (`vp lint` must reject a bare TODO, `pnpm sg` must reject `console.log`) → `RULES-FIRE-OK`, exit 0.
- Not re-run locally: the fixture job's `review-brief.sh` step. It is covered by `tests/spec-review/review-brief.sh` (334 assertions, above) and by the green `Fixture` job at this SHA.
- `git status --porcelain` in the worktree after all of it → empty; `git rev-parse HEAD` still `78be65e`.

## Issues

None.

## Notes

- `VERSION` is `0.3.0` and this PR does not bump it, although it changes the vendored tree, and `sync` prints "bump VERSION, commit." This is not a gate and matches the established practice: `git log --oneline -- VERSION` shows `VERSION` last touched at `78d8bcd`, many vendored-tree changes ago. The PR's own new finding in `docs/M0-findings.md` records the same thing ("sync (0.3.0) bumps no VERSION ... against what SOURCES.md line 3 says; the code is the truth"). Flagging only so a human decides whether a release bump is wanted before the stack lands.
- `SOURCES.md` line 3 is stated by that new finding to disagree with `factory918.sh sync`'s actual behaviour (no VERSION bump, no network). The finding is recorded but `SOURCES.md` line 3 itself is not corrected in this diff. Outside this slice's gates; raised as a candidate ticket, not a blocker.
- The `SOURCES.md` change-list numbering is not sequential (existing entries read 10, 9, 12, 13; the new ones are 14, 15). Pre-existing and cosmetic.
- Only 3 CI runs cover 11 commits, so 8 of the PR's commits were never individually built. Normal for batched pushes; the tip commit is covered, which is what matters for the stack.
- `docs/M0-findings.md` gains two dated 2026-09-22 lines, as AGENTS.md "Verifying" requires for anything verified against a tool version (`gh 2.100.0` is named in the second).
