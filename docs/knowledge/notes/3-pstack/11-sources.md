<!-- lines: 44 | source: notes/3-pstack.md | part 11/11 | title: Research note: pstack — Sources -->

## Contents (line numbers are for the Read tool's offset)
- L6: Sources

## Sources

Local (primary):
- `research/3-pstack/upstream-cursor-plugin/README.md`, `LICENSE`, `.cursor-plugin/plugin.json`
- `research/3-pstack/upstream-cursor-plugin/docs/guide/README.md`, `01-setup.md` … `10-recipes-and-pitfalls.md`
- `research/3-pstack/upstream-cursor-plugin/skills/poteto-mode/SKILL.md`, `playbooks/*.md` (23 files), `references/bugbot-triage.md`, `scripts/` (`watch-pr/`, `orch/`, `check-plan.mjs`, `worktree-audit.sh`, `bootstrap.ts`)
- `research/3-pstack/upstream-cursor-plugin/skills/{how,why,teach,recall,blast-radius,architect,arena,swarm,interrogate,setup-pstack,tdd,bro,unslop,no-comments,figure-it-out,show-me-your-work,automate-me,make-bot-ui,reflect,technical-writing,typescript-best-practices,create-verification-skill,maintain-verification-skill}/SKILL.md` and their `references/`
- `https://github.com/cursor/plugins/blob/7314f72/pstack/skills/principle-*/SKILL.md` (21 files)
- `research/3-pstack/upstream-cursor-plugin/agents/poteto-agent.md`, `agents/comment-sicko.md`
- `research/3-pstack/upstream-cursor-plugin/automations/benny/{README.md,FOR_AGENTS.md,skills/*/SKILL.md,templates/*}`
- `research/3-pstack/upstream-cursor-plugin/assets/logo.png`, `docs/guide/images/*.jpg`
- `git log` of `https://github.com/cursor/plugins/blob/7314f72/` (unshallowed; commits `24bd6eb` 2026-05-22 through `7314f72` 2026-09-02)
- `https://github.com/cursor/plugins/blob/7314f72/cursor-team-kit/skills/` (deslop, control-cli, control-ui)
- `https://github.com/michael-denyer/pstack-claude/blob/273d217/{README.md,CHANGES.md,CONTEXT.md,plugins/pstack/models.json,plugins/pstack/hooks/*}`
- `research/3-pstack/open-pstack-claude-code-port/{README.md,UPSTREAM.md,docs/reference.md,plugins/pstack/skills/poteto-mode/references/provider-dispatch.md,plugins/pstack/skills/setup-pstack/SKILL.md}`
- `https://github.com/IgorKhramtsov/pstack-skills/blob/ce47cec/{README.md,PORTING.md,UPSTREAM}`
- `https://github.com/backnotprop/pstack/blob/18e0e90/README.md` (backnotprop mirror)
- `research/2-theo-t3code-excerpts/AGENTS.md`, `apps/web/src/components/chat/composerSlashCommandSearch.test.ts`, `apps/web/src/providerSkillSearch.test.ts`

Web (secondary; X pages were not fetchable and are cited through the write-ups that quote them):
- Lauren Tan, "How I Use Cursor", X article, 2026-05-25: https://x.com/poteto/article/2058975157503570132 (quoted via https://leslieli.dev/notes/go-deep-first-pstack/)
- Lauren Tan, "new pstack principle" post, 2026-05-28: https://x.com/poteto/status/2059870196559700428 (content unverified; likely build-the-lever, added 2026-05-26)
- Lauren Tan, "1000 PRs" post, 2026-08-19: https://x.com/poteto/status/2090141955695198633 (quoted at https://www.bestxbuilds.com/builds/pstack)
- Lauren Tan, "The Complete Guide to pstack Pt. 1", 2026-08-31: https://x.com/poteto/article/2094457600259842065 (not fetchable)
- Maven workshop, 2026-08-12: https://maven.com/p/e23d9c/how-cursor-turned-ai-agents-into-better-engineers ; recap https://www.skool.com/start-my-ai/lauren-tan-on-pstack?p=b4e13358
- Denis Labelle interview reference (via open-pstack README): https://x.com/DenisLabelle/status/2091337807939706928 (2026-08-23; not fetchable)
- react.dev team page: https://react.dev/community/team ; GitHub profile: https://github.com/poteto ; older handle evidence: https://www.npmjs.com/~sugarpirate , https://keybase.io/sugarpirate
- SpaceXAI–Cursor acquisition: https://9to5mac.com/2026/08/14/spacex-lands-deal-to-likely-purchase-claude-code-and-openai-codex-competitor/ ; https://coursiv.io/blog/grok-bot (2026-08-26)
- Flavio Copes, "A deep dive into pstack", 2026-08-21: https://flaviocopes.com/pstack/ (mirror https://daily.dev/posts/a-deep-dive-into-pstack-evqbnto9j)
- Leslie Li, "Go Deep First: Notes on Lauren Tan's pstack", 2026-08-27: https://leslieli.dev/notes/go-deep-first-pstack/
- Kayvane, "Skill orchestrations, and what I like about pstack", 2026-05-28: https://www.kayvane.com/posts/building-a-multi-skill-system
- DeepWiki pstack page: https://deepwiki.com/cursor/plugins/3.4-pstack-plugin ; Cursor marketplace: https://cursor.com/marketplace/skills/poteto-mode ; guided tour: https://hustlecoding.github.io/pstack-explained/
- mcpmarket third-party listing: https://mcpmarket.com/tools/skills/poteto-mode-pstack-1 ; EpiLogos issue on adopting pstack: https://github.com/EpiLogos/ai-kit/issues/110
- Ports: https://github.com/michael-denyer/pstack-claude , https://github.com/ericlitman/open-pstack , https://github.com/IgorKhramtsov/pstack-skills , https://github.com/backnotprop/pstack
- Theo, "So I tried Matt's skills...", 2026-08-19: https://www.youtube.com/watch?v=0oXOOlqVu5M ; mirror/description https://daily.dev/posts/so-i-tried-matt-s-skills--0f5yy5jlx ; transcript https://youtubetotranscript.com/transcript?v=0oXOOlqVu5M ; summary https://youtubesummary.com/summary/0oXOOlqVu5M ; Chinese-language recap post https://x.com/chenchengpro/status/2090042073583927318 (not fetchable)
- Theo, "How I code with AI changed a lot" (~May 2026): https://finance.biggo.com/podcast/c7c3cb2193d150d2
- Theo, "My AGENTS.md & SKILLS.md Breakdown (Don't copy them)", 2026-08-11: https://finance.biggo.com/news/63e17fcb23548c16
- Theo, "Coding Is Solved, Software Engineering Is Not", 2026-08-24: https://finance.biggo.com/news/3c4173f0fe65eff9 (no pstack mention)
- Theo post, 2026-08-14 (subject unverified): https://x.com/theo/status/2088127851929423990
