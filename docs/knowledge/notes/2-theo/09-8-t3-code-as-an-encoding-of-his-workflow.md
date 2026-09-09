<!-- lines: 24 | source: notes/2-theo.md | part 9/12 | title: Research note: Theo — 8. T3 Code as an encoding of his workflow -->

## Contents (line numbers are for the Read tool's offset)
- L6: 8. T3 Code as an encoding of his workflow

## 8. T3 Code as an encoding of his workflow

Product decisions that reveal the workflow [PRIMARY unless noted]:

- **"Bring your own subscription", zero tools of its own.** README: "We built T3 Code because we wanted the best possible development experience with agents… inspired by… the Codex desktop app, Conductor, Claude Desktop and Cursor Glass, but none met our bar. We wanted something performant, remote-ready, and truly open." Marketing: "The open-source control plane for coding agents… Your agents deserve better than a terminal."
- **Thread = task; worktree = isolation.** `ThreadEnvMode = "local" | "worktree"`; per-project default via `t3.json`; `runOnWorktreeCreate` scripts; `newWorktreesStartFromOrigin`; on desktop `Cmd+Enter` starts a thread in the background and "If New worktree is selected, each background thread creates its own worktree" (`docs/user/composer.md`).
- **Every turn is checkpointed** (hidden git refs) "so the app can diff and restore"; turn diffs and full-thread diffs; checkpoint revert also reverts the provider conversation (`docs/internals/overview.md`). This is the "verify by diff, revert cheaply" loop.
- **Permission modes per thread** — Supervised / Auto-accept edits / Auto / Full access (default). Docs: "Use Full access for work in a worktree or a sandbox you can throw away."
- **Plan mode as a product object** — proposed plan card → Refine / Implement / Implement in a new thread.
- **Git actions in one button** — "Commit, push & create PR" with generated title/body following repo conventions; PR list with readiness sorting, labels, auto-merge, revert; "Proactive panels" open the PR and the completed turn's diff automatically (`docs/user/source-control.md`).
- **Thread settlement** — threads auto-settle when the linked PR merges; inbox-style sidebar sorted by "needs action" [SECONDARY roadmap, July 22].
- **Remote-first** — WebSocket architecture, pairing URLs, Tailscale, T3 Connect (Cloudflare tunnels), iOS/Android apps; "Send a task to a remote box and close your laptop."
- **Usage page** — combines Codex/Claude/Grok usage and subscription windows across machines (`docs/user/usage.md`) — matches his multi-subscription reality.
- **Skills and `$` tokens in the composer**; `/compact`; auto-compact thresholds for Claude; attachments passed to agents as file paths; assistant citations ("Cite in composer") for quoting the model back at itself.
- **Agent-friendly repo tooling** — `npx t3 triage`, `t3 pair`, `t3-sqlite-state.ts`, `.repos` sync, transfer-budget CI.

**[INFERRED]** The product is the workflow: short prompt → plan card → isolated worktree thread → diff/checkpoint → one-button PR → settle. What it does *not* encode is also telling: no built-in "memory", no plan storage in the repo, no orchestration of subagents beyond showing them.

---
