<!-- lines: 56 | source: notes/2-theo.md | part 3/12 | title: Research note: Theo — 2. Evidence inventory -->

## Contents (line numbers are for the Read tool's offset)
- L6: 2. Evidence inventory

## 2. Evidence inventory

| Artifact / video | Date | Type | What it tells us |
|---|---|---|---|
| `t3code/AGENTS.md` (156 lines) | HEAD 2026-09-04 | **Primary** | The team's real agent instruction file; structure, tone, guardrails, PR rules |
| `t3code/CLAUDE.md` (`@AGENTS.md`) | same | Primary | Claude Code is pointed at the shared AGENTS.md via an import — one source of truth |
| `t3code/CONTRIBUTING.md`, `.github/pull_request_template.md` | same | Primary | OSS contribution policy ("not actively accepting"), PR size/vouch labels |
| `t3code/.agents/skills/*` (4 SKILL.md + `agents/openai.yaml` + `references/` + `scripts/`) | same | Primary | His team's published skills, structure, triggering; `.claude/skills` is a symlink to `.agents/skills` |
| `t3code/.codex/config.toml`, `.mcp.json` | same | Primary | Same MCP server (XcodeBuildMCP) pinned for both Codex and Claude Code |
| `t3code/.cursor/rules/cursor-cloud.mdc` | same | Primary | Cursor Cloud-only rules kept out of the shared AGENTS.md |
| `t3code/.macroscope/*` | same | Primary | AI review agents (model `claude-opus-5`, effort high/medium) as PR check-runs; approvability rules |
| `t3code/.github/workflows/pr-vouch.yml`, `pr-size.yml`, `ci.yml` | same | Primary | Trust labels for external contributors, diff-size labels, CI gates incl. "Reject repository-owned PR assets" |
| `t3code/.github/triage/PLAYBOOK.md`, `ISSUE_TEMPLATE/via-triage.yml` | same | Primary | `npx t3 triage`: an agent-run support playbook; "Filed by: which agent and model" |
| `t3code/oxlint-plugin-t3code/*`, `vite.config.ts` | same | Primary | Six custom lint rules = encoded opinions; lint-debt ceilings per file |
| `t3code/docs/internals/*`, `docs/user/*` | same | Primary | How T3 Code runs agents: threads, turns, worktrees, checkpoints, permission modes, plan mode, PR flow |
| `t3code/apps/server/src/provider/model-manifest.json` | updated 2026-09-03 | Primary | The model landscape he targets: Claude Fable 5.1 / Opus 5 / Sonnet 5; GPT-5.6 luna/terra/sol |
| `t3code/apps/server/integration/TransferBudgetReport.integration.ts` | same | Primary | The CI "bandwidth budget" guard he described on stream |
| "It's finally here." (T3 Code launch) | ~Feb–Mar 2026 | Secondary (BigGo) | Why he built T3 Code; "models work best in the harness they were built around" |
| X: "T3 Code is now available for everyone to use." | 2026-03-07 (ID-decoded) | Secondary (title only) | Public launch date |
| "Claude's new Cursor killer just dropped" | ~Mar 2026 | Secondary | Teardown of Claude Code desktop; "models do not find edge cases. Users find edge cases." |
| "Claude Code is unusable now" | ~Apr 2026 | Secondary | Switched terminal alias to Codex; policy complaints |
| "How does Claude Code *actually* work?" | 2026-04-13 | Secondary | Harness = 60–75 lines; "you can just lie to the models"; less context is more; CLAUDE.md cuts tool calls |
| "So I stopped using Ghostty..." | ~Apr 2026 | Secondary | tmux/cmux era; parallel Claude Code sessions |
| "Claude Code's favorite tech stack" | ~May 2026 | Secondary | Universal CLAUDE.md preferences (TypeScript, no `any`, Bun, Convex/Clerk/Vercel) |
| "Stop letting your agents write Markdown." | ~2026-05-13 | Secondary | HTML plans/reviews, PostPlan, "C plus D plus A. File and babysit." |
| "I hated making this video..." | ~May 2026 | Secondary | Claude Code features he praises: skills w/ script execution, `@import`, Workflows, worktrees, remote control; 7×$200 subs |
| "We all fell for it…" | ~May 2026 | Secondary | Cognitive debt; high-runway vs ephemeral code; hierarchy of interventions credited to Lauren Tan (pstack) |
| "How I code with AI changed a lot" | 2026-05-27 | Secondary | 100 threads in 5 days, serial on `main`, 2-sentence prompts, "almost zero skills installed", 414 open PRs |
| "Claude Code vs Codex vs Cursor (an honest comparison)" | ~Jun 2026 | Secondary | Philosophies of the three harnesses |
| "This might be a Hot Take" | ~Jun 2026 | Secondary | AI widens the gap; learning journal advice |
| "Fable is Mythos, and it is really good." | ~Jul 2026 | Secondary | Fable as "laid-back senior"; model routing table |
| "We've been cooking" (stream w/ Julius, Maria) | 2026-07-22 | Secondary | T3 Code roadmap; team; "harness manager" architecture |
| "Opus 5 is my new go-to model" | ~2026-07-25 | Secondary | Opus 5 default (later reversed); $2,250/day across 4 accounts |
| "It's time to go bigger" / Lakebed | ~Jul–Aug 2026 | Secondary | Ambition thesis; agent-native platform |
| "Big launch today :)" (mobile apps, T3 Connect) | ~Aug 2026 | Secondary | Global agents.md excerpts; T3 Code cost ~$185k; business structure |
| "Claude is affecting my sleep" (Muse Code) | ~2026-08-07 | Secondary | 222-PR triage for $0.10; model routing |
| **"My AGENTS.md & SKILLS.md Breakdown (Don't copy them)"** | 2026-08-11 (YouTube `e1snsuY4lTI`) | Secondary | THE key video: global AGENTS.md, six private skills, failure audit, fleet, "don't copy" rationale |
| "Claude watermarks your code now" | ~2026-08-15 | Secondary | EU AI Act watermarking/C2PA — *not* about commit trailers |
| "I'm done with terminals" | 2026-08-18 | Secondary | Why GUI; 3–4 PRs/week → up to 20/day; Linux boxes; remote control |
| APFS → Linux (BigGo news) | 2026-08-20 | Secondary | 125 worktrees; worktree creation 2s vs 30s–2min |
| "Ranking Every AI Model (Currently)" | 2026-08-22 | Secondary | Tier list: Fable S+, 5.6 Sol S, Luna A, Opus 5 D |
| "Boris Is Right Again (I Hate It)" | 2026-08-24 | Secondary | "Coding is solved, software engineering is not"; verification infra |
| "Turn off Claude Code's Memory" | 2026-08-25 (YouTube `Jf54k7tFeEc`) | Secondary | Deleted memory; agents.md + CI + bash tools + skills instead |
| "You're reading way too much code" | ~Aug 2026 | Secondary | Generate disposable verification code; funnel model |
| "Well This Was Unexpected..." | ~Aug 27–31 2026 | Secondary | OpenAI–Cursor split; "direct subscriptions"; open-source harness managers |
| J. Queirós routing guide | 2026-07-26 | Secondary (community) | Opus/Fable/Sol routing; "a natural-language request to stop is not a permission system" |
| Better Stack T3 Code guide; daily.dev deep dive | 2026 | Secondary (community) | Product overview; 20k stars, 114 contributors, alpha |
| pstack README (cursor/plugins) | 2026 | Secondary (reference) | What he credits Lauren Tan for: hierarchy of interventions; "Babysit" playbook naming parallel |
| digg.com/tech/xl1a8dzo, wmowks0x, pnhf9v96 | 2026 | Unreachable (404/403) | Titles only: "Theo says using a CLAUDE.md file to steer...", "shares Fable AI workflow...", "shares custom configuration..." |

---
