<!-- lines: 31 | source: notes/2-theo.md | part 11/12 | title: Research note: Theo — 10. What's reusable for a Claude Code beginner vs what's specific to Ping Labs -->

## Contents (line numbers are for the Read tool's offset)
- L8: 10. What's reusable for a Claude Code beginner vs what's specific to Ping Labs
- L10: Reusable now (low risk, high leverage)
- L22: Specific to Ping Labs (adapt, don't copy)

## 10. What's reusable for a Claude Code beginner vs what's specific to Ping Labs

### Reusable now (low risk, high leverage)

1. **Write CLAUDE.md as a short letter with a glossary.** Say who "you/we/user" are, state 3–5 values, name the repo's one recurring defect, list the two or three ways an agent can hurt itself on your machine. Point at docs instead of duplicating them. Keep it under ~150 lines.
2. **Derive rules from your own failure ledger.** After a week, ask Claude Code to scan your sessions for repeated corrections (his prompt: "look through my history… to see what the most common mistakes are") and add one rule per real recurrence. Remove rules that never fire.
3. **Push rules down the hierarchy.** Formatter > lint rule > CI check > test > CLAUDE.md line > skill. If a rule can be a lint rule, make it one (`reportUnusedDisableDirectives`, restricted imports, a byte/perf budget).
4. **One task per thread; new thread when context is contaminated; worktree per parallel task.** Use Claude Code's plan mode to get a short plan, approve it, then let it run; give it a stop point.
5. **Demand proof, not diffs.** Require the smallest targeted test/lint; forbid repo-wide runs locally if CI does it; require before/after screenshots for UI; make it easy to spin up your app ("If it is too hard for you to spin up and test, it is way too hard for your agents").
6. **PR contract:** conventional plain-language title, problem-then-fix body, model+harness attribution line, one concern per PR, "never open a PR unless asked", then "babysit" until bots are green while verifying each bot finding against source.
7. **Don't commit plans/scratch; turn off memory you don't audit.** Ask for HTML when a document is long enough that you'd skim Markdown.
8. **Questions are read-only.** Add that line; it is cheap and fixes a common annoyance.
9. **Pay for direct subscriptions** rather than API keys; route cheap models to triage/summaries and the best model to architecture/taste.

### Specific to Ping Labs (adapt, don't copy)

- The `pkill`/`~/.t3/userdata`/`VITE_*` rules, `vp` commands, port derivation, `VACUUM INTO` — they describe *their* dev environment.
- The fleet (5 Linux boxes, Tailscale, T3 Connect, PostPlan, files.tslop.org, color-coded tmux) and the Provision-A-Box / File Upload / HTML Communication skills.
- Effect conventions and the six oxlint rules — only if you use Effect / React Native Uniwind / their tooltip primitives.
- Macroscope review agents, vouch lists, size labels — for a public repo drowning in AI PRs.
- Multi-subscription juggling ($1k+/month) and the model tier list — his numbers, his tasks; the *method* (token-per-task, vision, reliability) is what to keep.
- His refusal to accept contributions — a maintainer policy, not a workflow rule.

---
