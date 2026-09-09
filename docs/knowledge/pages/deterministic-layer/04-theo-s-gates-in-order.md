<!-- lines: 72 | source: pages/deterministic-layer.md | part 4/12 | title: The Deterministic Layer (reference page) — Theo's gates, in order -->

## Contents (line numbers are for the Read tool's offset)
- L7: Theo's gates, in order
- L62: The choices inside this

## Theo's gates, in order

What runs at each moment between a keystroke and a merge in T3 Code, and the reasons he gives. The design choice to notice is where things do not run: nothing but the formatter on commit, nothing repo-wide on the agent's machine, and human review only where a bot is forbidden to decide.

**Commit**git pre-commit hook

* `.vite-hooks/pre-commit` is one line: `vp staged`
* which runs `vp fmt` on the staged files
* config comment: "Formatter only for now — no lint or typecheck on commit."

**Agent's own machine**AGENTS.md "Verifying"

* "Smallest proof that the change works. `vp test run <files>` for the tests you touched, targeted lint and typecheck for the scope you changed."
* "**Do not run repo-wide checks.** ... CI owns the full suite."
* "A test that needs a timeout to pass is wrong."
* "Upon request, user-visible frontend changes should get one integrated pass in a real client... Subagents do not launch their own dev servers."

**PR opened**pull\_request\_target workflows

* `pr-size.yml` labels `size:XS..XXL` from changed lines with test files excluded ("a test-only PR is sized by its test lines")
* `pr-vouch.yml` labels `vouch:trusted | unvouched | denounced` from repo permissions and `.github/VOUCHED.td`
* neither fails a PR; both feed later gates

**CI: Check**ci.yml, every PR and push to main, 10-minute job timeout

* "Reject repository-owned PR assets": fails if anything is committed under `.github/pr-assets` ("PR evidence must be uploaded to GitHub, not committed")
* `vp check` (format + lint, custom rules included)
* `vpr typecheck`
* `vp run build:desktop` then a preload-bundle verifier that executes the built artifact against stubs

**CI: Test**ci.yml, parallel jobs

* all packages except the server: `vp run --parallel ... test`
* server: 239 files, one at a time, sharded over three machines, because "Running files in parallel introduces load-sensitive flakes."
* the transfer-budget test asserts `transferBudgetViolations(runs)` is empty and publishes a report to the job summary and a PR comment with ✅/❌ per ceiling against the `main` baseline
* Rust: `cargo fmt --check` and `cargo test`; mobile native lint on macOS only when native files changed, and the detector "fails open"
* `release-smoke.ts` on every PR

**Review bots**Macroscope check-run agents

* run only on `vouch:trusted` PRs, only after Check passes (`requires: [Check]`), budget `maxBudgetPerPR: 25`
* Effect Service Conventions on `claude-opus-5`, effort high: "Review only the lines the PR changed"; "Every new or broadened directive that disables a lint... needs an adjacent comment explaining why"; backend behavior changes "require focused tests that use test layers for external services only, never mocks of core business logic"
* UI Consistency, effort medium: three questions, "If the diff does not make a violation obvious, there is no finding"
* a finding sets the check to `failure`; no finding must be exactly "All clear"

**Babysit**the agent, after filing

* "poll checks and comments newer than the last push, verify each bot finding against the source, fix real ones, dismiss false positives with a written reason. Stay quiet when nothing is new. Stop when the bots are green on the latest commit."

**Human**approvability.md + merge

* never auto-approvable: any change to product defaults; any new or broadened suppression of a lint, type-checker or static-analysis diagnostic
* PR contract: conventional plain-language title, problem then fix, model and harness named, before/after media, one concern
* Theo reads the conversation and the signatures, not every line; merges from T3 Code

### The choices inside this

**Formatter on commit, everything else in CI.** Theo's hook is deliberately thin. Matt's setup-pre-commit is deliberately thick (lint-staged, then `npm run typecheck`, then `npm run test` on every commit). Both are defensible: a thick hook catches mistakes seconds after they are made and needs no CI account; a thin hook keeps commits instant, lets agents commit work-in-progress freely, and relies on CI to be the single place the full suite runs. Theo pairs the thin hook with "Do not run repo-wide checks" in the instruction file, so agents run only the targeted tests for what they touched. For a solo beginner with a small suite, Matt's thick hook is the safer start; the moment tests take more than a few seconds, move the suite to CI and thin the hook.

**Rules as lint, with a debt ceiling.** The most instructive file in the repo is the override table in `vite.config.ts`: fifteen legacy test files each carry a number (`CheckpointReactor.test.ts: 42`, `ProviderCommandReactor.test.ts: 66`) that is the maximum number of times a banned pattern may still appear there. The rule "permits no net-new occurrences in those files, while every other test file must have zero," and the comment says "Lower a ceiling when you migrate a file, and delete its entry at zero." That is how you introduce a new rule into an old codebase without a rewrite: the rule is absolute for new code and a ratchet for old code. It is also a rule no prompt could enforce. primary

**The layer protects itself.** Three separate mechanisms stop an agent from disabling the checks: `reportUnusedDisableDirectives: "error"` (a stale suppression comment fails lint), the review agent's rule that every new suppression "needs an adjacent comment explaining why," and the approvability rule that any new suppression "requires human review." When you write your first lint rule, add the first of these the same day.

**Trust is a label.** Bots and expensive checks run only for trusted authors, and fork PRs are handled "only as passive git data": "Do not add dependency installs, build/test scripts, or cache actions here." You will not need vouch lists until strangers send you PRs, but the shape (a label that other workflows key on) is worth knowing.

**Not gated at all:** nothing runs on the agent's machine except what it chooses; no test runs on commit; no lint rule is type-aware yet ("Revisit once Oxlint's tsgolint path can integrate"); Windows tests exist but "nothing in the suite passes on Windows yet." He documents the gaps as plainly as the gates.
