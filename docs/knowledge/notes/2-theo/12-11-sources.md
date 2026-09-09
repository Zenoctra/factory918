<!-- lines: 80 | source: notes/2-theo.md | part 12/12 | title: Research note: Theo — 11. Sources -->

## Contents (line numbers are for the Read tool's offset)
- L11: 11. Sources
- L13: Primary (local repo, `research/2-theo-t3code-excerpts/`, HEAD `f559fe0b`, 2026-09-04)
- L27: Secondary — BigGo Finance secondhand summaries (dates as shown on the pages or decoded from relative dates)
- L59: Secondary — community / press
- L67: X posts (titles/dates only; content not retrievable from this environment)
- L76: Unreachable (titles only)

## 11. Sources

### Primary (local repo, `research/2-theo-t3code-excerpts/`, HEAD `f559fe0b`, 2026-09-04)
- `AGENTS.md`, `CLAUDE.md`, `CONTRIBUTING.md`, `README.md`, `t3.json`, `.mcp.json`, `.coderabbit.yaml`, `.gitignore`, `vite.config.ts`, `package.json`, `.vite-hooks/pre-commit`
- `.agents/skills/test-t3-app/{SKILL.md,agents/openai.yaml,references/sqlite-fixtures.md}`; `.agents/skills/test-t3-mobile/{SKILL.md,agents/openai.yaml,scripts/pair-client.sh}`; `.agents/skills/ios-debugger-agent/{SKILL.md,agents/openai.yaml,LICENSE}`; `.agents/skills/ios-simulator-browser/{SKILL.md,agents/openai.yaml,LICENSE}`; `.claude/skills -> ../.agents/skills`
- `.codex/config.toml`; `.cursor/rules/cursor-cloud.mdc`; `.cursor/.gitignore`
- `.macroscope/approvability.md`; `.macroscope/check-run-agents/{effect-service-conventions,ui-consistency}.md`
- `.github/pull_request_template.md`; `.github/VOUCHED.td`; `.github/triage/PLAYBOOK.md`; `.github/ISSUE_TEMPLATE/{via-triage.yml,config.yml}`; `.github/workflows/{ci.yml,pr-vouch.yml,pr-size.yml,cursor-hygiene-webhook.yml}`
- `docs/README.md`; `docs/internals/{overview,glossary,work-artifacts,workspace-layout,ci,providers,scripts,remote,assistant-citations}.md`; `docs/user/{permission-modes,source-control,composer,thread-sidebar,tool-activity,providers-claude,providers-codex,usage,install,project-settings,remote-access}.md`
- `oxlint-plugin-t3code/index.ts` and `rules/*.ts`
- `apps/server/src/provider/model-manifest.json`; `apps/server/integration/TransferBudgetReport.integration.ts`; `apps/server/src/provider/Layers/ClaudeAdapter.ts` (plan mode mapping); `apps/server/package.json`
- `packages/contracts/src/{orchestration,settings,environment,t3ProjectFile,model}.ts`
- `apps/web/src/components/chat/{ComposerPrimaryActions,ProposedPlanCard,ComposerPlanFollowUpBanner}.tsx`; `apps/web/src/components/{AgentsPanel,GitActionsControl.logic}.tsx`; `apps/web/src/components/pullRequest/PullRequestDetailPanel.tsx`
- `apps/marketing/src/pages/index.astro`; `apps/marketing/src/lib/site.ts`
- `.repos/effect-smol/LLMS.md`; `scripts/lib/reference-repos.ts`; `scripts/sync-reference-repos.ts`

### Secondary — BigGo Finance secondhand summaries (dates as shown on the pages or decoded from relative dates)
- My AGENTS.md & SKILLS.md Breakdown (Don't copy them), Aug 11 2026 — https://finance.biggo.com/podcast/63e17fcb23548c16 and https://finance.biggo.com/news/63e17fcb23548c16 (YouTube: https://www.youtube.com/watch?v=e1snsuY4lTI)
- Stop letting your agents write Markdown., ~May 13 2026 — https://finance.biggo.com/podcast/6f71ab363f4b2ede ; daily.dev — https://daily.dev/posts/stop-letting-your-agents-write-markdown--amq2ta7iv
- How does Claude Code *actually* work?, Apr 13 2026 — https://finance.biggo.com/podcast/2c422828cf842028 ; https://finance.biggo.com/news/2c422828cf842028
- Claude Code's favorite tech stack, ~May 2026 — https://finance.biggo.com/podcast/b8b48d607ed15a27
- I hated making this video..., ~May 2026 — https://finance.biggo.com/podcast/9e726c7e7d19c891
- This might be a Hot Take, ~Jun 2026 — https://finance.biggo.com/podcast/d937a14d8664fc51
- We all fell for it…, ~May 2026 — https://finance.biggo.com/podcast/d8fd8d3b1ff80ac1
- Claude watermarks your code now, ~Aug 15 2026 — https://finance.biggo.com/podcast/f96fc09f59b73a15
- How I code with AI changed a lot, May 27 2026 — https://finance.biggo.com/podcast/c7c3cb2193d150d2 ; https://finance.biggo.com/news/c7c3cb2193d150d2
- You're reading way too much code, ~Aug 2026 — https://finance.biggo.com/podcast/eea9b09e4c1a567a
- Fable is Mythos, and it is really good., ~Jul 2026 — https://finance.biggo.com/podcast/02211289dbf10203 (page's own date claim is unreliable)
- Ranking Every AI Model (Currently), Aug 22 2026 — https://finance.biggo.com/podcast/d89ed76c1e8f2f00 ; https://finance.biggo.com/news/d89ed76c1e8f2f00
- Claude Code is unusable now, ~Apr 2026 — https://finance.biggo.com/podcast/00b9ba398b30a42e
- Big launch today :), ~Aug 2026 — https://finance.biggo.com/podcast/25052e3c107f7d9a
- We've been cooking, Jul 22 2026 — https://finance.biggo.com/podcast/da6498722711bc24
- It's finally here. (T3 Code launch), ~Feb–Mar 2026 — https://finance.biggo.com/podcast/a1e858acad27d477
- I'm done with terminals, Aug 18 2026 — https://finance.biggo.com/podcast/1e4bc1739e6c1fa0 ; https://finance.biggo.com/news/1e4bc1739e6c1fa0
- Turn off Claude Code's Memory, Aug 25 2026 — https://finance.biggo.com/news/bb1b56f140ee671f (YouTube: https://www.youtube.com/watch?v=Jf54k7tFeEc)
- Boris Is Right Again (I Hate It), Aug 24 2026 — https://finance.biggo.com/podcast/3c4173f0fe65eff9 ; https://finance.biggo.com/news/3c4173f0fe65eff9
- APFS → Linux, Aug 20 2026 — https://finance.biggo.com/news/a1cc91818da11d06
- Muse Code / Claude is affecting my sleep, ~Aug 7 2026 — https://finance.biggo.com/news/27781f853e7292fc ; https://finance.biggo.com/podcast/fc849827810abd43
- Opus 5 is my new go-to model, ~Jul 25 2026 — https://finance.biggo.com/news/107e8c7a3bc7007c
- It's time to go bigger — https://finance.biggo.com/podcast/851bf8f15a35df18
- I really miss coding., ~Apr 2026 — https://finance.biggo.com/podcast/0d50cfcccd139e77
- Claude Code vs Codex vs Cursor (an honest comparison), ~Jun 2026 — https://finance.biggo.com/podcast/2ce178fdcae7e994
- Claude's new Cursor killer just dropped, ~Mar 2026 — https://finance.biggo.com/podcast/4bff5e1161025b77
- So I stopped using Ghostty..., ~Apr 2026 — https://finance.biggo.com/podcast/98aa3952dbdefa48
- I don't really like GPT-5.5…, ~May 2026 — https://finance.biggo.com/podcast/7b0eaafb7d564d73
- Well This Was Unexpected..., ~Aug 27–31 2026 — https://finance.biggo.com/podcast/f310a774e0c42748
- Channel index — https://finance.biggo.com/s/Theo%20-%20t3.gg?hot_keyword=1

### Secondary — community / press
- João Queirós, "Claude Opus 5 Is the New Default: Theo's Practical Model-Routing Guide", Jul 26 2026 — https://www.ai.joaoqueiros.com/blog/claude-opus-5-default-theo-fable-gpt-5-6-sol-routing
- Better Stack, "T3 Code: An Open-Source GUI for Managing AI Coding Agents" — https://betterstack.com/community/guides/ai/t3-code/
- daily.dev, "A deep dive into T3 Code" — https://daily.dev/posts/a-deep-dive-into-t3-code-6h6lkupwc
- daily.dev, "A deep dive into pstack" — https://daily.dev/posts/a-deep-dive-into-pstack-evqbnto9j ; pstack README — https://github.com/cursor/plugins/blob/main/pstack/README.md ; Leslie Li notes — https://leslieli.dev/notes/go-deep-first-pstack/
- The New Stack, "Anthropic's harness shakeup…", Apr 6 2026 — https://thenewstack.io/anthropic-claude-harness-restrictions/ ; HN thread — https://news.ycombinator.com/item?id=47633568
- GitHub repo page and releases — https://github.com/pingdotgg/t3code ; https://github.com/pingdotgg/t3code/releases (alpha.3 dated Mar 2 2026)

### X posts (titles/dates only; content not retrievable from this environment)
- 2026-03-07 "T3 Code is now available for everyone to use." — https://x.com/theo/status/2030071716530245800
- 2026-03-17 Julius: "T3 Code is built pretty much entirely with Effect…" — https://x.com/jullerino/status/2033731748643950861
- 2026-03-20 "T3 Code now supports Claude…" — https://x.com/theo/status/2034831968463200359
- 2026-04-16 "Going to start talking a lot more about T3 Code." — https://x.com/theo/status/2044710197114097922
- 2026-06-15 "T3 Code users can continue using Claude Code…" — https://x.com/theo/status/2066669344483143701
- 2026-07-24 "T3 CODE WORKS GREAT WITH YOUR CLAUDE…" — https://x.com/theo/status/2080778486416101835
- 2024-04-27 "What you're referring to as Effect is actually…" — https://x.com/theo/status/1784307259205702079

### Unreachable (titles only)
- https://digg.com/tech/xl1a8dzo ("Theo - t3.gg says using a CLAUDE.md file to steer…") — 404
- https://digg.com/tech/wmowks0x ("T3 Stack creator Theo shares Fable AI workflow that…") — 404
- https://digg.com/tech/pnhf9v96 ("T3 Stack creator Theo Browne shares custom configuration…") — 403
- Lauren Tan's pstack X posts (2026-05-25 … 2026-08-31) — robots-blocked; the only Theo→pstack link I could verify is the BigGo summary of "We all fell for it…" crediting "Potato Lauren… working on… the P Stack" for the hierarchy of interventions.
