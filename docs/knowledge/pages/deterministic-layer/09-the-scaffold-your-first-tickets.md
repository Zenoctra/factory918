<!-- lines: 47 | source: pages/deterministic-layer.md | part 9/12 | title: The Deterministic Layer (reference page) — The scaffold: your first tickets -->

## Contents (line numbers are for the Read tool's offset)
- L6: The scaffold: your first tickets

## The scaffold: your first tickets

Lauren's Foundational Thinking principle says to sequence "scaffold-vs-feature work" and to get scaffold (CI, tests, shared types) in place before features. Theo's `docs/internals/ci.md` is what a mature scaffold looks like. Matt's setup-pre-commit and setup-ts-deep-modules are scaffold skills. Here is the scaffold as an epic of tracer-bullet tickets for a TypeScript web project in 2026, with blocking edges, sized so each is one agent session. It is a proposal; every line is a choice you can revisit, and the point of writing it as tickets is that you run it through the same grill → spec → tickets flow you will use for features, so your agent learns the pipeline on the pipeline. inferred

1. #### Choose the toolchain and write it down Theo pstack

   Decide runtime, package manager, formatter, linter, typechecker, test runner and e2e runner once. Two sane answers: assembled (Node 24 + pnpm + Prettier + ESLint + `tsc --noEmit` + Vitest + Playwright) or bundled (Vite+: `vp fmt`, `vp lint`, `vp check`, `vp test`, one `vite.config.ts`; or Bun's built-ins). Record it as ADR 0001 ("hard to reverse, surprising without context, a real trade-off" all hold). Acceptance: a fresh clone runs one documented command for each of install, format, lint, typecheck, test. Blocked by: nothing.
2. #### Strict types Theo pstack

   `strict: true` in `tsconfig.json`, a lint rule against `any` (`no-explicit-any` as an error), and a line in `CLAUDE.md` that `as` casts need a reason. Acceptance: introducing an `any` fails `lint`; the typecheck command passes on the empty app. Blocked by 1.
3. #### Formatter on commit, and only the formatter Theo Matt

   A pre-commit hook (Husky + lint-staged, or `vp staged`) that formats staged files. Decide now whether to also run typecheck and tests on commit (Matt's thick hook); the recommendation above is thick while the suite is under a few seconds, thin after. Acceptance: a commit with an unformatted file lands formatted; the hook survives a fresh clone (`prepare` script). Blocked by 1.
4. #### Unused-suppression is an error Theo

   Turn on the linter's report-unused-disable-directives (ESLint `--report-unused-disable-directives`, oxlint `reportUnusedDisableDirectives: "error"`) and add the review rule "every new suppression needs an adjacent comment explaining why." Acceptance: a stale `eslint-disable` fails lint. Blocked by 2.
5. #### One test at one seam, and the test runner in place Matt

   Pick the first real seam in your app (a pure function with a real input and a known-good output) and write the first test through it, red then green, with the expected value from an independent source. Acceptance: `test` runs one passing test and fails when the function is broken on purpose. Blocked by 1.
6. #### CI on every PR Theo

   One GitHub Actions workflow with jobs for lint, typecheck, test, and build, triggered on `pull_request` and `push` to main, with a job timeout. Then branch protection on main with those checks required. Acceptance: a PR that breaks a test shows a red check and cannot merge. Blocked by 2, 3, 5.
7. #### The always-loaded file's Verifying section Theo

   In `CLAUDE.md`: the exact commands from ticket 1; "smallest proof that the change works"; whether repo-wide checks are allowed locally; "a test that needs a timeout to pass is wrong"; ask before browsers or computer use. Acceptance: a fresh session can name the test command without a tool call. Blocked by 6.
8. #### Harness guardrails Matt

   Matt's git guardrail hook in `.claude/settings.json`, plus a PostToolUse formatter hook if you did not take the thick git hook. Decide whether `git push` stays blocked (it is, by default, in his script; remove it when agents should open PRs). Acceptance: an agent running `git reset --hard` is refused with a visible message. Blocked by 3.
9. #### Labels and the tracker Matt

   If you move from local markdown to GitHub Issues: create the seven labels by hand (`gh label create`), then run /setup-matt-pocock-skills to point at GitHub. Acceptance: `gh issue create --label ready-for-agent` succeeds. Blocked by 6.
10. #### A review that is not the author Matt pstack

    Start free: Claude Code's built-in `/code-review` or Matt's two-axis review in a fresh session on every PR, with the "ask by default" security list in its brief. Add a bot (Greptile, CodeRabbit, Macroscope) when you have PRs from more than one agent a day. Acceptance: every PR has a review comment from a context that did not write the code. Blocked by 6.
11. #### The verification skill pstack Ras Mic Theo

    Once the app runs: /pstack:create-verification-skill to generate `verify-<app>` with its feature map, executed once end to end; Ras Mic's headless naming in its Evidence section; Theo's "one integrated pass by the primary agent, on request" rule in `CLAUDE.md`. Acceptance: an agent can launch the app, drive one mapped feature, and leave a numbered screenshot and an `assertions.md` where the skill says. Blocked by 7.
12. #### Your first lint rule from your first recurring correction pstack Theo

    Not yet. This ticket opens itself the second time you correct the agent for the same thing. Write it as a lint rule if a program can see it, with a debt ceiling if old code violates it; otherwise as a CLAUDE.md line. Acceptance: the rule fails on a deliberate violation. Blocked by: a real ledger entry.

What this deliberately leaves out, because Theo built them for a public repo with agents as the main contributors and you do not have that problem yet: size and vouch labels, per-PR review-agent budgets, transfer budgets, release smoke tests, fork-safe workflow splits, mobile static analysis. Each one is a ticket you open the day its absence costs you something.
