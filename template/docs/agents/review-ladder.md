# Review ladder

Each rung runs only if its precondition exists. Missing rungs are skipped, never failed.

- **Rung 0 — CI.** `vp check` (format, lint, types), `pnpm sg` (ast-grep rules), `vp run -r build`, `vp test run`. Required to merge: the human checks the PR page for green checks before merging (decision P3 leaves branch protection off).
- **Rung 1 — spec-review.** After CI is green, the agent runs `spec-review` in a fresh context: the Standards axis reads `CODING_STANDARDS.md`; the Spec axis reads the originating ticket and its parent spec. Act-on items get fixed; the rest are recorded in the PR body. The report is posted as a comment on the PR, names the commit it reviewed, and ends with the line `act-on items: N`. Fixes land on the PR that was reviewed, never on a PR above it. On a stack, the chain above the fix is rebased onto it and re-verified. A finding outside the PR's scope becomes a ticket, not a commit here. A long review comment opens with two plain sentences for a person, per `AGENTS.md` "Pull requests". Fallback if the skill is missing: Claude Code's built-in `/code-review`.
- **Rung 2 — external review bot.** Only if listed below. The agent babysits: verify every finding against the source; fix, dismiss with a written reason, or ask, per `.agents/skills/poteto-mode/references/bugbot-triage.md`. Ask by default for security, auth, data, billing, migrations.
- **Rung 3 — interrogate.** When the design is contested, or the diff touches an invariant named in `CONTEXT.md`. Multi-tier review on this account's models.
- **Rung 4 — human.** Reads the conversation, the Verification section and the signatures; merges. The agent never merges.

## External bots configured for this repo

(none)
