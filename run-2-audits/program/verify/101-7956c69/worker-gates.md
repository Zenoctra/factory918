verdict: PASS

# Slice: gates — PR #101 (ticket #91) at 7956c6964cea8088e02ae8798102ce36b3c15cad

Environment: detached worktree `.claude/worktrees/agent-a18c2e5b3aab35b4a`, private `TMPDIR` under the session
scratchpad, ShellCheck 0.11.0 (`/opt/homebrew/bin/shellcheck`), macOS arm64, `vp` on PATH.

Setup

- `git fetch origin feat/spec-walk-risks feat/design-hole-restart main` → ok, exit 0.
- `git checkout --detach 7956c696...` → `HEAD is now at 7956c69 Give the CI fixture's grounding the Risks heading the brief now needs`; `git rev-parse HEAD` = `7956c6964cea8088e02ae8798102ce36b3c15cad`, exit 0.
- `git merge-base --is-ancestor 52ccd8eb509a2871260827a8514c3a1fcaac4d5d HEAD` → exit 0.
- `git diff --stat 52ccd8e..7956c69` → 15 files, +185 −43.

## 1. Every line of `AGENTS.md` "Verifying" at the SHA

- `bash .github/shellcheck.sh factory918.sh template/.github/shellcheck.sh 'template/.claude/hooks/*.sh' 'template/.agents/skills/*/scripts/*.sh' 'tests/*/*.sh'` → `ShellCheck 0.11.0, files checked: 20`, exit 0. (At this SHA this line replaces `bash -n`; no `bash -n` bullet remains.)
- `bash tests/shellcheck/gate.sh` → `ok 10 assertions`, exit 0.
- `bash tests/hooks/delegation.sh` → `ok 55 assertions`, exit 0.
- `bash tests/spec-review/review-comment.sh` → `ok 136 assertions`, exit 0.
- `bash tests/spec-review/review-brief.sh` → `ok 468 assertions`, exit 0.
- `bash tests/poteto-mode/overlap.sh` → `ok 56 assertions`, exit 0.
- `python3 tools/check_knowledge.py` → `knowledge ok: 118 files`, exit 0.
- `python3 tools/build_knowledge.py` → `knowledge files: 118 → docs/knowledge`, exit 0; `git status --porcelain` → 0 lines.
- `./factory918.sh sync` → `vendored: 72 skills.`, 17 patches applied, exit 0; `git status --porcelain` → 0 lines.
- The fixture flow: item 7 below.
- "Anything verified against a tool version gets a dated line in `docs/M0-findings.md`": the diff adds a dated `2026-09-22.` paragraph at `docs/M0-findings.md:183` (gh 2.x on GitHub.com, the closing-issue link rule) and two dated rows at `docs/agents/ledger.md:26-27`. Present.

## 2. Every file under `tests/` (skipping `fake-gh.sh`), with assertion counts

At 7956c69:

- `tests/hooks/delegation.sh` → `ok 55 assertions`, exit 0.
- `tests/poteto-mode/overlap.sh` → `ok 56 assertions`, exit 0.
- `tests/shellcheck/gate.sh` → `ok 10 assertions`, exit 0.
- `tests/spec-review/review-brief.sh` → `ok 468 assertions`, exit 0.
- `tests/spec-review/review-comment.sh` → `ok 136 assertions`, exit 0.
- `tests/spec-review/no-stale-wording.sh` → `ok: no stale wording`, exit 0 (prints no count).
- `tests/spec-review/layout.sh` → exit 0, no output. It is not a standalone test but a sourced helper defining `layout()` (`tests/spec-review/layout.sh:1-27`); nothing is asserted when it runs directly.

The extended test, at the SHA and at the patch base (second detached step: check out 52ccd8e, run, return to 7956c69; `git status --porcelain` 0 lines after returning, `git rev-parse HEAD` back to 7956c696...):

- `tests/spec-review/review-brief.sh` at 52ccd8e → `ok 414 assertions`, exit 0.
- `tests/spec-review/review-brief.sh` at 7956c69 → `ok 468 assertions`, exit 0. **+54 assertions.**
- `tests/spec-review/review-comment.sh` at 52ccd8e → `ok 134 assertions`, exit 0; at 7956c69 → `ok 136`, exit 0. **+2.**

The added cells are ticket #91's scenario table, labelled in the diff 1A, 2A, 3A, 5A, 6A, 7A, 8A, 9A
(`tests/spec-review/review-brief.sh`: the `risk_rule` variable and the `blast-risks.md`,
`blast-risks-demoted.md`, `blast-both.md`, `blast-empty-risks.md`, `blast-fenced.md` and `pr-body.md` fixtures).
They cover `## Risks` in a file, `### Risks` in a file, a PR body's demoted `### Risks` with CRLF ends and a
fenced `## ` line inside the section, both heading levels present, a Risks heading with nothing under it, a
grounding with no Risks heading (refused), a Risks heading only inside a fence (refused), and no grounding at
all (refused). Each refusal cell also asserts that no state and no briefs were written.

## 3. Knowledge

- `python3 tools/check_knowledge.py` → `knowledge ok: 118 files`, exit 0.
- `python3 tools/build_knowledge.py` → `knowledge files: 118 → docs/knowledge`, exit 0; `git status --porcelain` → 0 lines.

## 4. Sync, and the changed patches reproduce byte for byte

- `./factory918.sh sync` → exit 0, 72 skills, 17 patches applied; `git status --porcelain` → 0 lines. Run a second time for a clean exit code: exit 0, status still empty.
- `git diff --name-only 52ccd8e..7956c69 -- patches/` → two patches changed, none added or deleted.
  - `patches/mattpocock/spec-review.SKILL.md.patch`, regenerated with the `patches/README.md` command
    `diff -u --label a/spec-review/SKILL.md --label b/spec-review/SKILL.md research/1-matt-pocock/skills-repo/skills/engineering/code-review/SKILL.md template/.agents/skills/spec-review/SKILL.md`
    → `diff -q` against the committed patch printed nothing, exit 0: **identical**.
  - `patches/pstack/poteto-mode/playbooks/opening-a-pr.md.patch`, regenerated against
    `research/3-pstack/open-pstack-claude-code-port/plugins/pstack/skills/poteto-mode/playbooks/opening-a-pr.md`
    (the upstream root `factory918.sh:382` uses) → **identical**, exit 0.
  - `SOURCES.md` entries 3 and 6 were reworded in the same commit to describe the new behaviour; both are in the diff.

## 5. ShellCheck 0.11.0 on every `*.sh` the diff touched

`git diff --name-only 52ccd8e..7956c69 | grep '\.sh$'` → three files:

- `template/.agents/skills/spec-review/scripts/review-brief.sh`
- `tests/spec-review/review-brief.sh`
- `tests/spec-review/review-comment.sh`

`shellcheck --external-sources` (the flag `.github/shellcheck.sh:45` passes) over all three → no output, exit 0.
`shellcheck --version` → `version: 0.11.0`.

## 6. CI

- `gh run list --repo Zenoctra/factory918 --branch feat/spec-walk-risks --json databaseId,headSha,status,conclusion,event` →
  - `35761775682`, headSha `7956c6964cea8088e02ae8798102ce36b3c15cad`, event `pull_request`, status `completed`, conclusion **`success`**. This is the run the owner's report names.
  - `35760574314`, headSha `6add1e35394a079ace7673e82131d04b96ab5f60`, conclusion `failure` — the earlier push, superseded.
- `gh api repos/Zenoctra/factory918/actions/runs/35761775682/jobs` → `Factory` success, `Fixture` success. `run_attempt: 1`, created 2026-09-22T17:36:10Z.
- The merge ref: `gh api repos/Zenoctra/factory918/actions/runs/35761775682` gives `pull_requests[0].base.sha = 32978fa675e82300bbed01b323011da49d135b0e`. So **the run's #99 head was `32978fa` ("Say what a hole: field is and that a review with no spec marks none")**, not the patch base `52ccd8e`; `git merge-base --is-ancestor 52ccd8e 32978fa` → exit 0, so it is a later #99. #99's head is now `384bb43a872c1bca7b63a27aab2590ac37d46fae`, two commits on (`831f4b4`, `384bb43`).
- `gh pr view 101` → base `feat/design-hole-restart`, state OPEN, mergeable `CONFLICTING`, headRefOid still `7956c6964cea8088e02ae8798102ce36b3c15cad` (unchanged since the green run). `gh pr view 99` → also `CONFLICTING`. This is the state the common brief describes; the root resolves it by rebasing the chain.

## 7. The fixture job's new step, mirrored locally

`vp` is available, so the step was mirrored end to end, matching `.github/workflows/factory-ci.yml:48-75`. The
fixture root is under the session scratchpad rather than `/tmp/fx`, per this brief's write rules; nothing else
differs from the CI step.

- `vp create vite:monorepo --directory fx --no-interactive --git --hooks --no-agent` → scaffolded, exit 0.
- staged and committed the scaffold → `cfe9f20 chore: initial commit`.
- `./factory918.sh apply <fx> --scaffold --profile python --name demo` → applied. The doctor prints two FAILs expected for a bare fixture: `labels present` (no GitHub remote) and `slots filled (/factory-start)` (no Day-0 interview). CI pipes this step through `tail -30` and does not gate on them.
- staged and committed the applied factory → `4364003 factory918 apply`.
- `tests/spec-review/fake-gh.sh` copied to a `gh` on PATH; the grounding written with the workflow's exact new `printf` (`## What it does` / `Applies the factory.` / `## Risks` / ``1. Every hook under `.claude/hooks/` is new here: `.claude/hooks/delegation.sh:1`.``).
- `PATH=<fake-gh>:$PATH .agents/skills/spec-review/scripts/review-brief.sh HEAD~1 --ticket 1 --blast-radius <blast.md>` → `ticket: #1`, `round: 1 of 3`, `.scratch/review/HEAD_1/standards-brief.md`, `.scratch/review/HEAD_1/spec-brief.md`, exit 0.
- Every assertion of the step, run verbatim:
  - both briefs non-empty — ok.
  - the hard-finding sentence present in both briefs — ok, both.
  - `` `## Fails open` `` present in both — ok, both.
  - no `## Latent` in either — ok, both.
  - `` `## Walk` `` in the Spec brief — ok; absent from the Standards brief — ok.
  - **new:** `grep -qF 'The diff is cross-cutting: after the lines per documented step' "$d/spec-brief.md"` → matched at `spec-brief.md:325`, where the Walk bullet continues on its own line with the full risk sentence.
  - **new:** `grep -qF 'The diff is cross-cutting:' "$d/standards-brief.md"` → no match, so the guard does not fire — ok.
  - `rm -rf .claude/state/review` — ok.
- Supporting evidence: the grounding is pasted into the Spec brief under `## Blast radius` at `spec-brief.md:277-287`, `## Risks` heading and numbered risk intact, before `## Diff` at line 289.

## Issues

(none)

## Notes

- `tests/spec-review/layout.sh` is a sourced helper, not a runnable test; running it directly is a silent exit 0. Worth knowing if a future gate walks every file under `tests/` and expects a count line.
- The green run 35761775682 merged this head against #99 at `32978fa`, two commits behind #99's current head `384bb43`. CI green therefore covers this patch on a #99 that has since moved, not the current merge. Both #99 and #101 report `CONFLICTING`, as the common brief said; re-verification after the root's rebase is still owed.
- The local fixture apply prints `FAIL labels present`, `FAIL slots filled (/factory-start)` and `start with the first FAIL`. Expected for a fixture with no remote and no Day-0 interview, and CI does not gate on the apply's exit; recorded so a reader of the local mirror does not read it as a regression.
- The `--git` flag and the fixture's own version-control commands trip this worktree-isolated agent's guard when combined into one compound command; each was run as a plain separate command from the fixture directory. Nothing touched the primary checkout or another worktree.
