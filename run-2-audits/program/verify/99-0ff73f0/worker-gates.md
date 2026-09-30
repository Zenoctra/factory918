verdict: PASS+NOTES

Every gate named in `AGENTS.md` "Verifying" at 0ff73f0 runs green from a detached checkout of that SHA,
including the full fixture flow run locally. The only findings are in the PR body's prose: it names the new
decision P26 when the committed tables say P27, and four of its "run at the head commit" numbers are stale
after the rebase onto 070c1fa.

## Setup

- `git fetch origin feat/design-hole-restart feat/shellcheck main` → ok (`+ 384bb43...0ff73f0 feat/design-hole-restart` forced update). exit 0.
- `git checkout --detach 0ff73f0b6c11bb54909c1b54ddc1fe1428ff0f93` → `HEAD is now at 0ff73f0 Record the design-hole decision and the merge read's restart clause`. exit 0.
- `git rev-parse HEAD` → `0ff73f0b6c11bb54909c1b54ddc1fe1428ff0f93`, matches the brief. exit 0.
- `git merge-base --is-ancestor 070c1fa9a1d9da9bcaa0fa4da1d6036f5c11da42 HEAD` → exit 0; the patch base is an ancestor.
- Worktree: `/Users/manuel/.../factory918/.claude/worktrees/agent-a5db7d927fb2cfd65`, `git status --porcelain` empty at start and at end.
- Private `TMPDIR`: `<scratchpad>/tmp`. `shellcheck --version` → `version: 0.11.0` at `/opt/homebrew/bin/shellcheck`.

## 1. Every line of AGENTS.md "Verifying" at the SHA

- `bash .github/shellcheck.sh factory918.sh template/.github/shellcheck.sh 'template/.claude/hooks/*.sh' 'template/.agents/skills/*/scripts/*.sh' 'tests/*/*.sh'` → `ShellCheck 0.11.0, files checked: 20`, no findings. exit 0. (Matches the bullet's "over 20 files".)
- `bash tests/shellcheck/gate.sh` → `ok 17 assertions`. exit 0.
- `bash tests/hooks/delegation.sh` → `ok 55 assertions`. exit 0.
- `bash tests/spec-review/review-comment.sh` → `ok 148 assertions`. exit 0.
- `bash tests/spec-review/review-brief.sh` → `ok 422 assertions`. exit 0.
- `bash tests/poteto-mode/overlap.sh` → `ok 57 assertions`. exit 0.
- `python3 tools/build_knowledge.py` → `knowledge files: 119 → docs/knowledge`, exit 0; `git status --porcelain` afterwards printed nothing.
- `python3 tools/check_knowledge.py` → `knowledge ok: 119 files`. exit 0.
- `./factory918.sh sync` → 20 `applied` lines, `vendored: 72 skills.`, exit 0; `git status --porcelain` afterwards printed nothing.
- Fixture flow, run locally under the private TMPDIR (not `/tmp/fx`, to stay inside the allowed write area):
  - `vp create vite:monorepo --directory fx --no-interactive --git --hooks --no-agent` → `Scaffolded fx with Vite+ monorepo`, Node 24.21.0 / pnpm 12.5.1. exit 0.
  - `./factory918.sh apply <fx> --scaffold --profile python --name demo` → exit 0; the trailing doctor reports PASS on all but two checks that cannot pass on a local fixture: `FAIL labels present` (no GitHub remote) and `FAIL slots filled (/factory-start)` (Day-0 interview not run). CI's step ends in `| tail -30` and does not gate on these either.
  - In the fixture: `bash .github/shellcheck.sh` → `ShellCheck 0.11.0, files checked: 11`, exit 0.
  - `PATH=<fake-gh>:$PATH .agents/skills/spec-review/scripts/review-brief.sh HEAD~1 --ticket 1 --blast-radius <blast.md>` → `ticket: #1`, `round: 1 of 3`, both brief paths; exit 0. Both briefs are non-empty and both carry the new `spec:` rule (`grep -c 'The same item carries a line'` → 1 in `standards-brief.md` and 1 in `spec-brief.md`), so the rule reaches a real applied project, not only the test harness.
  - `vp check` → `All 63 files are correctly formatted`, `Found no warnings, lint errors, or type errors in 9 files`. exit 0.
  - `vp test run` → `Test Files 2 passed (2)`, `Tests 10 passed (10)`. exit 0.
  - `pnpm sg:test` → `test result: ok. 2 passed; 0 failed;`. exit 0.
  - The steps of `<fx>/.github/workflows/python.yml` inside `python/demo` (`uv sync --frozen`, `uv run ruff format --check .`, `uv run ruff check .`, `uv run pyright`, `uv run pytest`, `uv audit`) → `2 files already formatted`, `All checks passed!`, `0 errors, 0 warnings, 0 informations`, `1 passed in 0.00s`, `Found no known vulnerabilities ... in 10 packages`. exit 0.
- "Anything verified against a tool version gets a dated line in `docs/M0-findings.md`": the diff changes no tool version or pin (the ShellCheck pin and its checksums come from PR #96, already in the base), so no new finding line is owed. `git diff 070c1fa..0ff73f0 -- docs/M0-findings.md` is empty.

## 2. Every file under tests/, assertion counts

At 0ff73f0 (`fake-gh.sh` skipped; `layout.sh` is a sourced helper, not run on its own):

| file | at 070c1fa | at 0ff73f0 |
|---|---|---|
| `tests/hooks/delegation.sh` | 55 | 55 |
| `tests/poteto-mode/overlap.sh` | 57 | 57 |
| `tests/shellcheck/gate.sh` | 17 | 17 |
| `tests/spec-review/review-brief.sh` | **334** | **422** (+88) |
| `tests/spec-review/review-comment.sh` | **82** | **148** (+66) |
| `tests/spec-review/no-stale-wording.sh` | `ok: no stale wording` (2 blacklisted strings) | `ok: no stale wording` (3 blacklisted strings) |

- Base counts measured by `git checkout --detach 070c1fa` in this same worktree, running the same commands, then returning to 0ff73f0 (`git rev-parse HEAD` re-confirmed, `git status --porcelain` empty).
- `no-stale-wording.sh` prints no count; it is one `grep -rnF` over `template` and `docs/knowledge/core` with three `-e` patterns at HEAD (`## Latent`, `A hard finding is wrong behavior in normal use`, and this PR's addition `Three trailing fields`), exit 1 on any hit. `tests/spec-review/no-stale-wording.sh:9`.
- Every test file above passes at both SHAs, so the added cells are additive: no pre-existing assertion was removed or relaxed.

## 3. Knowledge

- `python3 tools/check_knowledge.py` → `knowledge ok: 119 files`, exit 0.
- `python3 tools/build_knowledge.py` → `knowledge files: 119 → docs/knowledge`, exit 0, then `git status --porcelain` empty. The committed generated tree matches its sources.

## 4. Sync and patch reproduction

- `./factory918.sh sync` → exit 0, all 20 series patches `applied`, none `FAILED`; `git status --porcelain` empty afterwards. The vendored tree equals the pins plus the patches.
- The diff touches exactly three patches (`git diff --name-only 070c1fa..0ff73f0 -- patches/`), all three listed in `patches/series`. Each regenerated with the `patches/README.md` command and compared with `cmp`:
  - `patches/mattpocock/spec-review.SKILL.md.patch` from `research/1-matt-pocock/skills-repo/skills/engineering/code-review/SKILL.md` vs `template/.agents/skills/spec-review/SKILL.md` → `cmp` exit 0.
  - `patches/pstack/babysit/SKILL.md.patch` from `research/3-pstack/open-pstack-claude-code-port/plugins/pstack/skills/babysit/SKILL.md` vs `template/.agents/skills/babysit/SKILL.md` → `cmp` exit 0.
  - `patches/pstack/poteto-mode/playbooks/babysit.md.patch` from the same pstack tree's `skills/poteto-mode/playbooks/babysit.md` vs its template copy → `cmp` exit 0.
  - (The upstream paths are the ones `factory918.sh:382-383,392` uses; note the README's `research/<upstream>/<path>` shorthand does not spell out that the Pocock source for `spec-review` is `engineering/code-review`.)
- All three are described in `SOURCES.md`, items 4, 6 and 12, each amended by this diff.

## 5. ShellCheck on every *.sh the diff touched

Five files: `template/.agents/skills/spec-review/scripts/review-brief.sh`, `.../review-comment.sh`, `tests/spec-review/no-stale-wording.sh`, `tests/spec-review/review-brief.sh`, `tests/spec-review/review-comment.sh`.

- `shellcheck --external-sources <the five>` with ShellCheck 0.11.0 → no output, exit 0. All five are also inside the gate's globs, so the 20-file gate run covers them.

## 6. CI

- `gh run list --repo Zenoctra/factory918 --branch feat/design-hole-restart --json databaseId,headSha,status,conclusion,event` → two runs, both `completed`/`success`, both `pull_request`. No polling was needed; the head run had already finished.
- Run **35764499282** at headSha `0ff73f0b6c11bb54909c1b54ddc1fe1428ff0f93`, created 2026-09-22T18:01:54Z, conclusion `success`. Job `Factory` success, every step success: ShellCheck; `shellcheck.sh passes, refuses and counts what the test says`; `The delegation hook blocks and passes what the test says`; `review-comment.sh prints and refuses what the test says`; `review-brief.sh writes the report shape into both briefs`; `overlap.sh prints, stops and refuses what the test says`; `No retired review wording under template/ or the core knowledge`; `Knowledge base is consistent and built from its sources`; `Vendored skills equal the pins plus the patches`. Job `Fixture` success, every step success: `Day 0 on a fresh monorepo`; `The shell gate a project runs`; `review-brief.sh briefs the apply diff inside the project`; `The gates a project runs`; `The Python profile's job`; `The rules fire`.
- Earlier run **35756050493** at headSha `52ccd8eb509a2871260827a8514c3a1fcaac4d5d`, created 2026-09-22T16:43:57Z, conclusion `success`; jobs `Factory` and `Fixture` both success.
- The workflow's step list (`.github/workflows/factory-ci.yml`) covers every `AGENTS.md` "Verifying" bullet, and its knowledge and sync steps assert cleanliness with `git diff --exit-code`, the same property I checked with `git status --porcelain`.

## 7. DECISIONS.md at the SHA

- `docs/knowledge/core/DECISIONS.md:93` is `P25 | The design artifact on the ticket`, sourced to "Ticket #89" (= PR #94). Present.
- `:94` is `P26 | One shell gate, carried by the template`, sourced to "Ticket #88, 2026-09-22" (= PR #96). Present.
- `:95` is `P27 | A design hole restarts the review`, sourced to "Ticket #90". Added by this diff. Present.
- No duplicate ids: the 26 provisional rows are `P1 P2 P3 P4 P5 P7 P8 P9 P10 P11 P12 P13 P14 P15 P16 P17 P18 P19 P20 P21 P22 P23 P24 P25 P26 P27`; `sort | uniq -d` over the whole table's id column printed nothing. `P6` is absent at the patch base too (`git show 070c1fa:docs/knowledge/core/DECISIONS.md | grep -c "P6 "` → 0), so it is pre-existing and not this PR's doing.
- The cross-reference inside `P20` ("a design hole, P27") and the generated copy `template/docs/factory918/DECISIONS.md` both say P27; `git diff 070c1fa..0ff73f0 | grep -E '^[+-].*P2[4-9]'` shows the four added lines and no `P26` for the new row.
- The two lines the diff adds to `docs/agents/ledger.md` cite no decision id at all (neither P26 nor P27), which matches every existing ledger line's shape — `docs/agents/ledger.md` is `date | model | what it did | what to do instead`, with no decision column. Nothing to correct there.
- **The PR body does not say P27.** `gh pr view 99 --json body` → Scope section: "`docs/knowledge/core/DECISIONS.md` (P26, with P20 and P21 amended inline)". P26 is #96's shell-gate decision, already in the base; this PR adds P27. See Issues.

## Issues

- PR #99 body, Scope, last-but-two bullet: "`docs/knowledge/core/DECISIONS.md` (P26, with P20 and P21 amended inline)" names the wrong decision. The committed row is `P27` (`docs/knowledge/core/DECISIONS.md:95`, and the same row in `template/docs/factory918/DECISIONS.md`), and `P20`'s own amendment text calls it "a design hole, P27". P26 is #96's "One shell gate, carried by the template". Body text only; no committed file is wrong.
- PR #99 body, Scope: "`tests/spec-review/review-comment.sh` (82 to 146 assertions)". The measured count at this head is **148** (`bash tests/spec-review/review-comment.sh` → `ok 148 assertions`). The body's own Verification section says 148 two paragraphs later, so the two bullets disagree with each other; 148 is right.
- PR #99 body, Verification, final paragraph ("Also run from this checkout at the head commit, each exit 0"): three of the five quoted outputs are stale after the rebase onto 070c1fa. Measured at 0ff73f0: `bash tests/shellcheck/gate.sh` → `ok 17 assertions` (body: `ok 10 assertions`); `bash tests/poteto-mode/overlap.sh` → `ok 57 assertions` (body: `ok 56 assertions`); `python3 tools/check_knowledge.py` → `knowledge ok: 119 files` (body: `knowledge ok: 118 files`). All three numbers are already 17/57/119 at the patch base 070c1fa, so the drift came in with PRs #94 and #96 at the rebase, not from this PR's own changes. The commands themselves all pass.

## Notes

- Nothing in the gate slice is broken by the rebase: every base-SHA count I measured at 070c1fa is reproduced at 0ff73f0 except the two spec-review test files this PR is meant to grow, which is the expected shape.
- The 88 and 66 new assertions are additive. Both test files pass unchanged at the patch base, and both pass at the head, so no pre-existing exact-stdout case was loosened to make room for the `restart` line.
- The `## Overlap` section's own text records that `origin/feat/shellcheck` had moved past the branch's base at record time; at this head the base is `070c1fa`, PR #96's verified head, and `git merge-base --is-ancestor` confirms it, so the chain is where the brief says it is.
- The fixture run left its tree under the session scratchpad; nothing was written to `/tmp/fx` or into any checkout. The worktree's `git status --porcelain` is empty at the end and HEAD is still `0ff73f0`.
- `bash -n` was not run separately: the `AGENTS.md` bullet says the ShellCheck gate replaces it and covers its set, and the gate ran clean over 20 files.

Claude Opus 5 (1M context) on Claude Code
