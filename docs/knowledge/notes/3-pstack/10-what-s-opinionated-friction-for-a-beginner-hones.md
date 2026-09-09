<!-- lines: 19 | source: notes/3-pstack.md | part 10/11 | title: Research note: pstack — What's opinionated / friction for a beginner (honest) -->

## Contents (line numbers are for the Read tool's offset)
- L6: What's opinionated / friction for a beginner (honest)

## What's opinionated / friction for a beginner (honest)

- **It is one senior engineer's private style, published.** poteto-mode's own frontmatter says "poteto's agent style"; the README says "`poteto-mode` is my style. you may not want exactly that." Leslie Li's read: "pstack itself looks like Lauren's private style dumped into a plugin". Everything from em-dash bans to "never open a draft PR" is her taste.
- **Assumes Cursor and, increasingly, the SpaceXAI/Grok stack.** Defaults name Grok and Fable/Sol/Opus slugs; `make-bot-ui` is Grok-Bot-only; Benny needs Cursor Automations. In Claude Code you depend on a volunteer port that lags upstream by days to weeks and rewrites skill bodies.
- **Token and subscription cost.** Panels are four frontier models; `arena` adds a judge and grafting; Autopilots add swarms of verifiers per PR. Lauren herself flagged that frontier fan-out "burn[s] expensive tokens" (via leslieli.dev); Copes: "The machinery has a cost"; Theo: "token burners". A beginner on one Claude plan should set most roles to `inherit-parent` and use the single-agent skills.
- **Vocabulary load.** 45 skills, 22 playbooks, 21 named principles, plus terms like "throughput checkpoint", "merge frontier", "patch-id", "forge", "gauntlet lanes", "stack". The guide says "Don't memorize the list", but the router expects you to phrase goals with checkable finish conditions, which is itself a skill.
- **"Never block on the human" cuts both ways.** By default it proceeds on anything reversible, uses any MCP tool, posts to team chat and tickets without asking, and prototypes instead of asking design questions. For someone who cannot yet judge a diff, review-after-the-fact is riskier than it is for her. Pair it with a small scope, worktrees, and no merge rights at first. open-pstack's README says as much: "Start with supervised work. Let it run more work in parallel only after its checks have earned that trust in your own repositories."
- **Anti-comment and anti-planning stances.** `/no-comments` deletes explanatory comments a learner might want, and "i don't believe in planning. the best spec is code" removes a step many beginners lean on. You can simply not run those skills.
- **Git-heavy assumptions.** Worktrees per agent, stacked PRs, Conventional Commits, `gh`, rebases, `git patch-id`, merge queues. Manageable for a solo repo, but the shipping half assumes GitHub PR flow with CI and review bots.
- **Verification needs plumbing you must build.** "Prove it works" only bites if the agent can drive your app; that means running `/create-verification-skill` early and keeping the feature map honest.
- **Volatility.** Model defaults changed six times in three months; playbook count went 7 → 22; the router file is 141 dense lines. Expect churn.
- **What is genuinely beginner-friendly:** `/teach`, `/how`, `/why`, `/bro`, `/unslop`, `/blast-radius`, and `/tdd`, each usable standalone, plus the ten-chapter `docs/guide/` (read upstream; not ported). Leslie Li's advice fits: take "the sequence, not the slash-command catalog": understand, require a real artifact of the problem, verify on the real thing, only then parallelize.

---
