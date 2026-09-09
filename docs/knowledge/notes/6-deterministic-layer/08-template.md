<!-- lines: 97 | source: notes/6-deterministic-layer.md | part 8/10 | title: Research note: deterministic layer (verbatim config) — Template -->

## Contents (line numbers are for the Read tool's offset)
- L11: Template
- L34: D.5 Pre-commit, git guardrails, dependency-cruiser
- L66: D.6 `retro`: seven categories
- L70: D.7 `improve-codebase-architecture`: deletion test and badges
- L74: D.8 Labels
- L80: D.9 `diagnosing-bugs`: the feedback-loop ladder

## Template

```md
# {Short title of the decision}

{1-3 sentences: what's the context, what did we decide, and why.}
```

That's it. An ADR can be a single paragraph. The value is in recording *that* a decision was made and *why*, not in filling out sections.
```

Optional sections: Status frontmatter, Considered Options, Consequences. "When to offer an ADR — All three of these must be true: 1. **Hard to reverse** 2. **Surprising without context** 3. **The result of a real trade-off**".

Real example, `.agents/adr/0001-explicit-setup-pointer-only-for-hard-dependencies.md` (the repo's own ADRs live in `.agents/adr/`, not `docs/adr/`):

> # Explicit `/setup-matt-pocock-skills` pointer only for hard dependencies
>
> Engineering skills depend on per-repo config (issue tracker, triage label vocabulary, domain doc layout) seeded by `/setup-matt-pocock-skills`. Some skills cannot meaningfully function without that config… Others only use it to sharpen output… and degrade gracefully without it.
>
> We split these into **hard-dependency** and **soft-dependency** skills: … **Hard dependency** (`to-tickets`, `to-spec`, `triage`): include an explicit one-liner… **Soft dependency** (`diagnose`, `tdd`, `improve-codebase-architecture`): reference "the project's domain glossary" and "ADRs in the area you're touching" in vague prose only.

`0002-ship-as-a-claude-code-plugin.md` is longer and records a rejected alternative: Codex's `.codex-plugin/plugin.json` "accepts `skills` only as a **single path string**", symlinks "do not survive install", so "Defer the native Codex plugin". Its "Update, 2026-08-05" notes acceptance into `claude-plugins-official` and that the listing's sha "is pinned, so a release reaches installed users when that pin moves, not the moment we tag."

### D.5 Pre-commit, git guardrails, dependency-cruiser

`skills/misc/setup-pre-commit/SKILL.md` installs Husky + lint-staged + Prettier. Exact hook file (step 4, `.husky/pre-commit`):
```
npx lint-staged
npm run typecheck
npm run test
```
"**Adapt**: Replace `npm` with detected package manager. If repo has no `typecheck` or `test` script in package.json, omit those lines and tell the user." `.lintstagedrc`: `{ "*": "prettier --ignore-unknown --write" }`. Prettier defaults: `tabWidth 2`, `printWidth 80`, `singleQuote false`, `trailingComma "es5"`, `semi true`, `arrowParens "always"`. Verify list includes "Run `npx lint-staged` to verify it works"; step 8 commits with message `Add pre-commit hooks (husky + lint-staged + prettier)` — "This will run through the new pre-commit hooks: a good smoke test that everything works." Note: "The pre-commit runs lint-staged first (fast, staged-only), then full typecheck and tests". (Contrast with Theo: Theo's hook is formatter-only; Matt's runs typecheck and the full test suite on every commit.)

`skills/misc/git-guardrails-claude-code/SKILL.md`. Hook JSON shape (project scope):
```
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/block-dangerous-git.sh"
          }
        ]
      }
    ]
  }
}
```
Global variant uses `~/.claude/settings.json` and `~/.claude/hooks/block-dangerous-git.sh`. Deny mechanism (step 5): "Should exit with code 2 and print a BLOCKED message to stderr." `scripts/block-dangerous-git.sh` reads stdin JSON, extracts `.tool_input.command` with `jq`, and greps it against `DANGEROUS_PATTERNS=( "git push" "git reset --hard" "git clean -fd" "git clean -f" "git branch -D" "git checkout \." "git restore \." "push --force" "reset --hard" )`; on match: `echo "BLOCKED: '$COMMAND' matches dangerous pattern '$pattern'. The user has prevented you from doing this." >&2; exit 2`, else `exit 0`. SKILL.md: "When blocked, Claude sees a message telling it that it does not have authority to access these commands."

`skills/in-progress/setup-ts-deep-modules/SKILL.md` + `dependency-cruiser.config.cjs`. Boundary rule enforced: "A package's public surface is its **entry points** (the files at the package root), and everything in its subfolders is hidden." Four rules "all `error`": entry-point boundary; intra-package freedom; tests through the entry points; no cycles. Config rule names: `entrypoint-boundary-from-app`, `entrypoint-boundary-across-packages` (uses `pathNot: `^${R}/$1/`` so a package may reach its own internals), `tests-through-entrypoints`, `tests-folder-is-private`, `no-circular`; `PACKAGE_INTERNALS = `^${R}/[^/]+/[^/]+/``. Wiring: "Add a `lint:boundaries` script: `depcruise <packages-root>`… Fold it into the repo's umbrella check command, the one that already runs typecheck". The completion criterion, verbatim: "This is the completion criterion for the whole skill: a config that doesn't fail on a violation is worthless." with the pass → fail (`tests-through-entrypoints`) → pass sequence: "If step 2 does not fail, the rules are not wired correctly, so fix before finishing."

### D.6 `retro`: seven categories

`skills/in-progress/retro/SKILL.md` categories (bold names verbatim): **Navigation**, **Automated checks** ("are there automated checks that could catch errors the agent made? Linting, typing, tests, filesystem linters? _Use when_ the agent made a mistake that could have been caught by an automated check."), **Coding standards** ("should the **reviewer agent** be given a new rule to enforce?"), **Global AGENTS.md** ("are there any steering instructions that should be moved to coding standards (or automated checks) instead?"), **Tool economy**, **No-ops**, **Information access**. The review-agent line, verbatim: "This means that the review agent should be responsible for imposing coding standards, not the implementation agent." Files: "`CODING_STANDARDS.md`: this file is read during review, not implementation."

### D.7 `improve-codebase-architecture`: deletion test and badges

`skills/engineering/improve-codebase-architecture/SKILL.md`: "Apply the **deletion test** to anything you suspect is shallow: would deleting it concentrate complexity, or just move it? A "yes, concentrates" is the signal you want." Report card field: "**Recommendation strength**: one of `Strong`, `Worth exploring`, `Speculative`, rendered as a badge". Report is a self-contained HTML file written to the OS temp directory ("so nothing lands in the repo"). ADR conflicts: "only surface it when the friction is real enough to warrant revisiting the ADR."

### D.8 Labels

`skills/engineering/setup-matt-pocock-skills/triage-labels.md`: five state labels `needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix` (table maps canonical role → tracker label, "Edit the right-hand column to match whatever vocabulary you actually use."). `triage/SKILL.md` adds two category roles `bug` and `enhancement`; "Every triaged issue should carry exactly one category role and one state role." `issue-tracker-github.md` uses `gh issue edit <number> --add-label "..."` and, for wayfinder, `gh issue create --label wayfinder:map` and `wayfinder:<type>` (`research`/`prototype`/`grilling`/`task`).

Labels must be created by hand — `docs/engineering/triage.md` lines 73-74: "**The agent tried to apply `ready-for-agent` and `gh` said the label doesn't exist.** Known open bug (#616). `setup-matt-pocock-skills` writes the label vocabulary into `docs/agents/triage-labels.md`, but does not create the labels in your tracker. Create the five state labels and two category labels yourself, once, with `gh label create` or the tracker's UI, and it stops." And `docs/engineering/setup-matt-pocock-skills.md`: "It does not run `gh label create`… `gh issue create --label <missing>` fails outright rather than creating the label. Create them by hand before the first wayfinder run on a GitHub repo." No full `gh label create <name> …` command form appears anywhere in the repo; only the bare command name.

### D.9 `diagnosing-bugs`: the feedback-loop ladder

`skills/engineering/diagnosing-bugs/SKILL.md`, "Phase 1: Build a feedback loop": "**This is the skill.** Everything else is mechanical. If you have a **tight** pass/fail signal for the bug (one that goes red on _this_ bug), you will find the cause". The ten rungs, verbatim ("Ways to construct one, in roughly this order"):

> 1. **Failing test** at whatever seam reaches the bug: unit, integration, e2e.
> 2. **Curl / HTTP script** against a running dev server.
> 3. **CLI invocation** with a fixture input, diffing stdout against a known-good snapshot.
> 4. **Headless browser script** (Playwright / Puppeteer) that drives the UI and asserts on DOM/console/network.
> 5. **Replay a captured trace.** Save a real network request / payload / event log to disk; replay it through the code path in isolation.
> 6. **Throwaway harness.** Spin up a minimal subset of the system (one service, mocked deps) that exercises the bug code path with a single function call.
> 7. **Property / fuzz loop.** If the bug is "sometimes wrong output", run 1000 random inputs and look for the failure mode.
> 8. **Bisection harness.** If the bug appeared between two known states (commit, dataset, version), automate "boot at state X, check, repeat" so you can `git bisect run` it.
> 9. **Differential loop.** Run the same input through old-version vs new-version (or two configs) and diff outputs.
> 10. **HITL bash script.** Last resort. If a human must click, drive _them_ with `scripts/hitl-loop.template.sh` so the loop is still structured. Captured output feeds back to you.

Then: "Build the right feedback loop, and the bug is 90% fixed." "A 30-second flaky loop is barely better than no loop; a 2-second deterministic one is tight". Completion criterion: "you can name **one command** … that you have **already run at least once** (show the invocation and its output, redacted)".

---
