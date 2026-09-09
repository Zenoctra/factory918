<!-- lines: 24 | source: spec/FACTORY-SPEC-v1.md | part 12/14 | title: The Factory spec, v1 (superseded) — 9. Milestones for the implementing model -->

## Contents (line numbers are for the Read tool's offset)
- L6: 9. Milestones for the implementing model

## 9. Milestones for the implementing model

Each milestone ends with its acceptance checks run and their output pasted into the PR that lands it (the factory repo uses its own PR contract from day one).

**M0 — Ground truth (½ day).** Read this spec and `notes/6-deterministic-layer.md`. Record tool versions. Confirm `vp create --no-interactive` flags, `vp hooks enable`, `setup-vp@v1` inputs, `@oxlint/plugins` exports (`defineRule`, `definePlugin`), Claude Code hook events used (`SessionStart` with `fork`, `UserPromptSubmit`, `PreToolUse`, `PostToolUse`), and `disable-model-invocation` semantics. Acceptance: a `M0-findings.md` with a line per fact and its source URL; any deviation from this spec listed.

**M1 — Template files (1 day).** Build `template/` per §4 and §7 (no skills yet). Acceptance: on a fresh `vp create vite:application --no-interactive` project, `factory apply` then `factory doctor` passes every check except the skill and label checks; a deliberately unformatted file lands formatted after `git commit`; a `// TODO later` comment fails `vp lint`; a stale `// oxlint-disable` line fails `vp lint`; CI on a throwaway GitHub repo goes green, then red when a test is broken on purpose.

**M2 — Skills (1 day).** Vendor per §5, apply patches per §5.4, write `ticket`, `mode-plan`, `mode-build`, `factory-doctor`, `review-ladder.md`, `evidence.md`, `feedback-loops.md`. Acceptance: in Claude Code inside the project, `/` lists the planning skills and pstack's action skills, not the principles; `/grill-with-docs` loads both `grilling` and `domain-modeling` (the transcript shows two Skill-tool calls); `/poteto-mode "#1"` on a seeded ticket reads the issue, checks blockers, runs the Feature playbook and reaches Opening a PR with `Closes #1` in the body, never blocked by "skill cannot be invoked"; `/unslop` fires on its own when the agent drafts a PR body.

**M3 — Hooks (½ day).** §7.4. Acceptance: typing `/grill-with-docs` sets `.claude/state/mode` to `planning` and the next prompt's context shows the planning line; `/mode-build` flips it; a file written by the agent is formatted before the next tool call; `git push origin main` and `git reset --hard` from the agent are refused with a visible BLOCKED message; `git push origin feat/x` is allowed; the session mandate appears after `/clear`.

**M4 — GitHub layer (½ day).** §7.8 plus the branch-protection wizard. Acceptance: labels exist; a PR gets a `size:*` label; `main` refuses a merge while `Check` is red; the PR template renders.

**M5 — `update` and `sync` (1 day).** §8.2. Acceptance: on a project at template v1, edit `AGENTS.md` locally, delete `docs/agents/feedback-loops.md`, bump the template to v2 (which changes `AGENTS.md` elsewhere and adds a file); `factory update` keeps the local edit, applies the template change, adds the new file, does not resurrect the deleted one, and produces a `.factory-merge` file only where lines actually collide. `factory sync` against a newer open-pstack tag re-applies all §5.4 patches with no manual edits.

**M6 — First real project and a retro (ongoing).** Apply to one real project. After two weeks, run `/reflect` and read the ledger; the first recurring correction becomes either a lint rule (with a debt ceiling if old code violates it) or one line in `AGENTS.md`. That is when the factory stops being copied opinions and starts being yours.

---
