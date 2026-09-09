<!-- lines: 113 | source: notes/2-theo.md | part 4/12 | title: Research note: Theo — 3. His AGENTS.md, analyzed -->

## Contents (line numbers are for the Read tool's offset)
- L9: 3. His AGENTS.md, analyzed
- L13: 3.1 Structure (in order) and what each section is for
- L33: 3.2 Verbatim excerpts worth studying
- L101: 3.3 What is *absent*, and why that is deliberate

## 3. His AGENTS.md, analyzed

File: `research/2-theo-t3code-excerpts/AGENTS.md` (156 lines). `CLAUDE.md` is literally one line, `@AGENTS.md` [PRIMARY], so Claude Code, Codex, Cursor and OpenCode all read the same text. In the Aug 11 video he walks through this exact file (BigGo calls it "the T3 Code contributor file (CLAUDE.md)") and explains that several sections were "converted from audits" of real agent failures [SECONDARY].

### 3.1 Structure (in order) and what each section is for

| # | Section | Purpose | Notes |
|---|---|---|---|
| 1 | Untitled header: "T3 Code is a minimal GUI for coding agents…" | Orient the agent in two sentences; positions the product | "bring-your-own-subscription alternative to apps like Claude Desktop, Codex App, Cursor Glass and Conductor" |
| 2 | **What makes T3 Code special?** (4 non-negotiables) | Things "we can never compromise on" — doubles as a values list | Open at the core; Performance without compromise; Remote ready; Multi-surface |
| 3 | **A note from Theo** | First-person taste statement; declares the file is "good defaults", not "hard rules" | Also a safety warning that agents often run *inside* T3 Code |
| 4 | **A small glossary** | Pin vocabulary so "user" ≠ "developer" ≠ "agent" | you / we,us,maintainers / user / agent / provider / client / environment / project / thread / turn / T3 home |
| 5 | **The three ways to hurt yourself** | Blast-radius guard, derived from audited failures | Killing by pattern; writing to the live install; baking in origins |
| 6 | **Hit every surface** | Checklist for "the most common defect in this repo" | Entry points, clients, providers, contracts, reverse states, connection modes, docs |
| 7 | **Dev servers** | Operational facts an agent otherwise wastes tool calls discovering | `vp i`, `vp run dev`, ports derive from worktree path, `--share` over tailnet, pairing URLs |
| 8 | **Test data** | How to seed realistic state without touching live data | `VACUUM INTO` snapshot of `~/.t3/userdata`; "Copy in, never symlink" |
| 9 | **Verifying** | What "proof" means; explicit prohibition on repo-wide checks | "CI owns the full suite"; receipts not sleeps; integrated pass via skills only on request |
| 10 | **Pull requests** | The PR contract (titles, body, evidence, scope, babysitting) | "Never make a PR unless the developer explicitly asks" |
| 11 | **Plans and work artifacts** | Where plans/notes live (not in the repo) | Mirrors `docs/internals/work-artifacts.md` |
| 12 | **How it works** | One-paragraph architecture with links | commands → decider → events → projector; reactors; receipts; checkpoints |
| 13 | **Where code lives** | Map of apps/packages + vendored `.repos/` | "read `.repos/effect-smol/LLMS.md` before writing Effect code" |
| 14 | **Taste** | Five aesthetic rules | "`any` is the enemy"; "UI stays dumb"; escalation clause |
| 15 | **Additional tips** | Two calibrations | No browsers unless asked; don't over-index on security in dev mode |

### 3.2 Verbatim excerpts worth studying

**The values list (what an agent must never trade away):**

> "We have over 200,000 users who love T3 Code. It's important we maintain the things they love as we continue to iterate on the product. Here's a brief list of the things we can never compromise on." (line 9)

> "Lots of apps have gotten bogged down with bad tech decisions and 'slope'. We have not, and we're proud of the performance of T3 Code. We regularly audit for performance regressions, often caused by sending too much data over websockets, css animations causing gpu spikes, lists being hard to render, and more. Make sure all changes are considerate of performance impact." (line 17)

**The note from Theo — the closest thing to his philosophy in one paragraph:**

> "I like ambitious ideas, simple systems, and software that feels obvious. Do not preserve complexity just because it already exists. Do not introduce machinery because it looks architecturally impressive. Understand the real constraint, then fight for the smallest model that makes the correct behavior unsurprising." (line 35)

> "Channel both 'measure twice, cut once' and 'yagni'. Fight scope creep. Try to honor the dev's intent in both a minimal and realistic fashion." (line 37)

> "Think of these instructions less as 'hard rules', more as 'good defaults'. The developer's preferences should be able to override anything here." (line 39)

> "Of note: Most T3 Code contributions will come from T3 Code itself, often controlled remotely. This means you should be careful about accessing data, killing dev servers, and other things that may damage the T3 Code instance that the contributor is using." (line 41)

**The glossary (the trick he says fixed a whole class of misreadings):**

> "- **you** means the agent reading this file and changing T3 Code.
> - **we, us, and maintainers** mean Theo, Julius and the people building T3 Code. These are who you are talking to now.
> - **user** means the person using T3 Code to direct coding agents.
> - **agent** means the coding agent a user runs inside T3 Code. Depending on context, that may also include you." (lines 47–50)

**Blast radius (converted from the failure audit — Opus 5 "aggressively killed wrong process, often its own session" [SECONDARY]):**

> "1. **Killing by pattern.** Never `pkill -f`, `pgrep | kill`, or `kill` a PID you found by matching a name, path, or worktree string. Your own agent process has this worktree's path in its argv, and this machine runs several other dev servers at once. Kill only a PID you captured at spawn, or the owner of your port from `ss -H -ltnp` after confirming `/proc/<pid>/cwd` is your worktree." (line 61)

> "2. **Writing to the live install.** `~/.t3/userdata` is the developer's real T3 Code database, in use while you work. Reading it and copying from it are fine… Never start a server against it, never open it read-write, never clean it up." (line 62)

**Hit every surface (converted from "the most common defect"):**

> "The most common defect in this repo is a change that works on the path you tested and is missing everywhere else. Before calling frontend work done, walk this list and say which entries applied:" (line 67)

> "- **Reverse states.** If you added a way in, add the way out and the way to see it. Snooze needs unsnooze. Close needs reopen. A one-way door is a bug." (line 73)

**Verifying (the anti-"run everything" rule):**

> "- Smallest proof that the change works. `vp test run <files>` for the tests you touched, targeted lint and typecheck for the scope you changed.
> - Test meaningful logic or observable behavior. Do not render components to static markup to assert props or attributes, or add tests that merely assert callback wiring or mirror the implementation.
> - **Do not run repo-wide checks.** No `vp check`, no `vp run -r test`, no `vp run -r typecheck` unless I ask. CI owns the full suite.
> - … The server is event-sourced and its async flows emit typed receipts. Wait on receipts and worker drains, never on sleeps or polling. A test that needs a timeout to pass is wrong.
> - Upon request, user-visible frontend changes should get one integrated pass in a real client: `test-t3-app` for web, `test-t3-mobile` for mobile. The primary agent does this once after integrating. Subagents do not launch their own dev servers. Ask permission before doing computer use or spinning up browsers." (lines 106–111)

**Pull requests (this is the "File PR" + "Babysit PR" skills, inlined for the repo):**

> "- Never make a PR unless the developer explicitly asks you to do so.
> - Conventional commit titles, plain language: `fix(web): new threads no longer spike CPU`.
> - Body: the problem in a sentence or two, then how you fixed it. End with the model and harness that did the work.
> - UI changes need before/after images. Motion or timing needs a short video.
> - Upload PR evidence to GitHub. Never commit PR-only screenshots or assets such as `.github/pr-assets/`.
> - One concern per PR. If the description says 'also', split it.
> - When babysitting: poll checks and comments newer than the last push, verify each bot finding against the source, fix real ones, dismiss false positives with a written reason. Stay quiet when nothing is new. Stop when the bots are green on the latest commit." (lines 115–121)

**Plans and work artifacts (the "Stop letting your agents write Markdown" stance, applied to the repo):**

> "- Do not commit implementation plans, research notes, or agent scratch files. Keep temporary working material outside the worktree. `.plans/` is gitignored only as a safety net for legacy tooling.
> - … A merged PR is the implementation record. Close or update its tracking item when the work lands; do not preserve a second checklist in the repository." (lines 125–128)

**Taste:**

> "- Complexity belongs at the adapter boundary. Orchestration stays pure, UI stays dumb.
> - Inferred types over annotations. `any` is the enemy.
> - Comments describe how a thing is used, and move when the code moves…
> - Our users drive agents all day and notice a dropped frame, a lying spinner, and a stale label. No continuously repainting animations; they peg the GPU on high-refresh displays.
> - If a rule here fights the task in front of you, say so loudly and get a human sign-off before breaking it." (lines 147–151)

### 3.3 What is *absent*, and why that is deliberate

- **No formatting/style rules.** Formatting is enforced by `vp fmt` in a pre-commit hook (`.vite-hooks/pre-commit` runs `vp staged`; `vite.config.ts` says "Formatter only for now — no lint or typecheck on commit") [PRIMARY]. Prose can't do what a formatter does; he doesn't spend tokens on it.
- **No architecture rules beyond one paragraph.** Durable facts live in `docs/internals/` with file links (glossary, overview, providers…), which the file points at. Per `docs/internals/work-artifacts.md`: "Code search should return the product as it exists, not a mix of current behavior and abandoned intentions" [PRIMARY].
- **No library tutorials.** Instead he vendors the library source: `.repos/effect-smol` and `.repos/alchemy-effect` are read-only git subtrees synced by `scripts/sync-reference-repos.ts`, and the rule is "Prefer their patterns over invented ones. Never edit or import from them" [PRIMARY: AGENTS.md line 143].
- **No lint-like rules in prose.** Those are real lint rules (`oxlint-plugin-t3code`, Section 8.3) and Macroscope review agents (`.macroscope/check-run-agents/*.md`). This matches the "hierarchy of interventions" he credits to Lauren Tan: eliminate via architecture → enforce via lint/CI → … → only then "accept a skill or rule" [SECONDARY: BigGo "We all fell for it…"].
- **No memory files, no plan templates, no checklists.** He deleted memory ("This is garbage. Useless.") after auditing 45 memory files, 19 reads vs 80 writes across 355 sessions [SECONDARY: BigGo Aug 25 2026]. The repo forbids committing plans.
- **No harness-specific text.** Cursor Cloud quirks are quarantined in `.cursor/rules/cursor-cloud.mdc` "since T3 Code is developed in many places" [PRIMARY].
- **Short.** His stated principle: **"Less context is best as long as it has the context it needs."** [SECONDARY: Aug 11 video]

**[INFERRED]** The file is written as a letter, in first person, with a glossary and values first and mechanics second, because he believes tone is contagious: "If you talk a certain way to the model, the model's more likely to talk that way back" [SECONDARY]. The mechanics sections (dev servers, test data) exist purely to save the tool calls the agent would otherwise burn rediscovering them — which is the same argument he made in "How does Claude Code actually work?" (with CLAUDE.md: zero exploration tool calls; without: 6+) [SECONDARY, Apr 13 2026].

---
