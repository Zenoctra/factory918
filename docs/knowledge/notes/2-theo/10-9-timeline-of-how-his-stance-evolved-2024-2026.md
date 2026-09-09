<!-- lines: 24 | source: notes/2-theo.md | part 10/12 | title: Research note: Theo — 9. Timeline of how his stance evolved (2024 → 2026) -->

## Contents (line numbers are for the Read tool's offset)
- L6: 9. Timeline of how his stance evolved (2024 → 2026)

## 9. Timeline of how his stance evolved (2024 → 2026)

| When | Stance / event | Evidence |
|---|---|---|
| 2024-04 | Jokes about Effect ("What you're referring to as Effect is actually…") | X post title (ID-decoded date) |
| Late 2025 (Nov–Jan) | "Heavy reliance on Cursor's plan mode with Opus models"; long plans as the core mechanism; terminal-centric post-prompt workflow ("bullied" Cursor into copy-path buttons) | SECONDARY: May 27 2026 recap; Aug 18 |
| 2025 → early 2026 | Opus 4.5 makes multi-hour agent tasks normal; "coding in Ubers" breaks; Codex desktop app becomes "the decisive tipping point" toward GUIs | SECONDARY: Aug 18 |
| Feb–Mar 2026 | T3 Code alpha (v0.0.0-alpha.3 on 2026-03-02); "It's finally here."; public "available for everyone" 2026-03-07; Claude support 2026-03-20; "built pretty much entirely with Effect" (Julius, 03-17) | PRIMARY: GitHub releases; X titles |
| Mar 2026 | Claude Code desktop teardown: "models do not find edge cases. Users find edge cases." | SECONDARY |
| Apr 2026 | Anthropic restricts third-party harnesses on subscriptions (Apr 4); "Claude Code is unusable now" — terminal alias switched to Codex; "How does Claude Code actually work?" (Apr 13): harness = 75 lines, less context is more, CLAUDE.md to cut discovery calls; cmux/tmux era | SECONDARY; New Stack |
| May 2026 | "Stop letting your agents write Markdown" (HTML plans/reviews; removed front-end design skill); "Claude Code's favorite tech stack" (universal CLAUDE.md: TS, no `any`, Bun, Convex/Clerk/Vercel); "I hated making this video…" (praises skills-with-scripts, `@import`, Workflows; 7×$200 subs); "We all fell for it…" (cognitive debt; Lauren Tan's hierarchy of interventions); May 27 "How I code with AI changed a lot": GPT-5.5 only, serial threads on main, 2-sentence prompts, "almost zero skills installed", agents.md as "a letter" with a glossary, 414 open PRs | SECONDARY |
| Jun 2026 | "Claude Code vs Codex vs Cursor"; "This might be a Hot Take"; X: T3 Code users can continue using Claude Code (06-15) | SECONDARY; X title |
| Jul 2026 | Fable 5 public (07-01); "Fable is Mythos" ($2k in 24h; "laid-back senior"); "We've been cooking" roadmap (inbox sidebar, mobile, T3 Connect, workflow visualization); Opus 5 "new go-to" (07-25); Lakebed / "go bigger" | SECONDARY |
| Aug 2026 | Mobile apps + T3 Connect launch; Muse Code PR triage (08-07); **AGENTS.md & SKILLS.md breakdown (08-11)** — 12–16 hours on markdown, six private skills, failure ledger, fleet; watermark video (~08-15); "I'm done with terminals" (08-18); APFS→Linux (08-20); model tier list (08-22): Sol default, Fable S+, Opus 5 demoted to D; "Boris is right" (08-24): verification is the bottleneck; memory deleted (08-25); "You're reading way too much code"; OpenAI–Cursor split (~08-31): "direct subscriptions" | SECONDARY |
| 2026-09-03/04 | Model manifest adds Claude Fable 5.1; repo at PR #9430; Macroscope agents on `claude-opus-5`; CodeRabbit auto-review off | PRIMARY |

**The arc in one line [INFERRED]:** from *human writes long plans in an IDE* (2025) → *human writes two sentences, agent runs one task per thread, GUI manages the fleet* (mid-2026) → *human invests in instruction text, guardrail code and verification infrastructure so that the two-sentence prompt keeps working across many models and machines* (Aug 2026).

---
