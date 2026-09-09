<!-- lines: 67 | source: notes/1-matt-pocock.md | part 10/10 | title: Research note: Matt Pocock — Sources -->

## Contents (line numbers are for the Read tool's offset)
- L11: Sources
- L13: Local (primary)
- L21: Matt Pocock (primary, web)
- L42: Talks/videos (Matt; content via secondhand summaries because YouTube was rate-limited)
- L51: Harness/platform docs
- L56: Community (secondhand)

## Sources

### Local (primary)
- `research/1-matt-pocock/skills-repo/README.md`, `CLAUDE.md` (= `AGENTS.md`), `CONTEXT.md`, `CHANGELOG.md`, `LICENSE`, `package.json`, `.gitignore`
- `.agents/invocation.md`, `.agents/install-block.md`, `.agents/writing-docs.md`, `.agents/adr/0001-*.md`, `.agents/adr/0002-*.md`
- `.changeset/*.md` (8 unreleased changesets), `.out-of-scope/*.md` (3), `.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`, `.github/workflows/release.yml`
- `scripts/link-skills.sh`, `scripts/list-skills.sh`, `scripts/sync-plugin-version.mjs`
- `docs/engineering/*.md` (18 pages) and `docs/productivity/*.md` (7 pages)
- `skills/engineering/*` (18 skills incl. `ask-matt/PHASE-BOUNDARIES.md`, `codebase-design/{DEEPENING,DESIGN-IT-TWICE}.md`, `domain-modeling/{CONTEXT-FORMAT,ADR-FORMAT}.md`, `diagnosing-bugs/scripts/hitl-loop.template.sh`, `improve-codebase-architecture/HTML-REPORT.md`, `prototype/{LOGIC,UI}.md`, `setup-matt-pocock-skills/{domain,issue-tracker-github,issue-tracker-gitlab,issue-tracker-local,triage-labels}.md`, `tdd/{tests,mocking}.md`, `triage/{AGENT-BRIEF,OUT-OF-SCOPE}.md`, `wizard/template.sh`), `skills/productivity/*` (7), `skills/misc/*` (4), `skills/in-progress/*` (8), `skills/deprecated/README.md`, all `agents/openai.yaml` sidecars

### Matt Pocock (primary, web)
- https://github.com/mattpocock/skills and https://github.com/mattpocock/skills/releases
- https://www.aihero.dev/skills (hub) and https://www.aihero.dev/posts (index with dates)
- https://www.aihero.dev/my-grill-me-skill-has-gone-viral (2026-03-23)
- https://www.aihero.dev/5-agent-skills-i-use-every-day (2026-03-16)
- https://www.aihero.dev/things-people-get-wrong-with-grill-me-and-grill-with-docs (2026-05-25)
- https://www.aihero.dev/grill-with-docs (2026-05-05)
- https://www.aihero.dev/skills-changelog-ubiquitous-language-grill-with-docs (2026-04-30)
- https://www.aihero.dev/skills/skills-changelog-v1-1-wayfinder-to-spec-to-tickets-grilling-improvements (2026-07-08)
- https://www.aihero.dev/skills/skills-changelog-v12-wait-what-writing-for-agents-claude-code-plugin-and-more (2026-08-05)
- https://www.aihero.dev/tracer-bullets (2026-01-22)
- https://www.aihero.dev/how-to-make-codebases-ai-agents-love (2026-02-26)
- https://www.aihero.dev/getting-started-with-ralph (2026-01-08)
- https://www.aihero.dev/real-world-feature-build-with-claude-code (2026-03-20; body not retrievable, only its summary)
- https://www.aihero.dev/ai-coding-dictionary/smart-zone and https://www.aihero.dev/ai-coding-dictionary/context-pointer
- https://github.com/mattpocock/course-video-manager/blob/076a5a7a182db0fe1e62971dd7a68bcadf010f1c/CONTEXT.md
- https://github.com/mattpocock/sandcastle
- https://github.com/mattpocock/skills/issues/89, /issues/458, /issues/693 (bodies only; comments not rendered)
- https://ai.engineer/speakers/matt-pocock (bio)
- X posts referenced but not fetchable (robots.txt): https://x.com/mattpocockuk/status/2014328793746251841 (tracer bullet), /2051587758238371858 (context pointers), /2075218406266036236 (160K stars), /2074860312423997800 (v1.1), /2084985277102031137 (v1.2), /2072599827540578664 (wayfinder)

### Talks/videos (Matt; content via secondhand summaries because YouTube was rate-limited)
- "Full Walkthrough: Workflow for AI Coding" (AI Engineer, 2026-04-24): https://www.youtube.com/watch?v=-QFHIoCo-Ko — summaries: https://videohighlight.com/v/-QFHIoCo-Ko, https://finance.biggo.com/news/e7209c094224b09c, https://talksintel.ai/ai-ml/conferences/aie-eu-2026/full-walkthrough-workflow-for-ai-coding-matt-pocock/, https://www.sean-weldon.com/blog/2026-04-27-workflow-for-ai-coding-matt-pocock, https://www.explainx.ai/blog/matt-pocock-ai-coding-real-engineers-workshop-2026, https://podwise.ai/episodes/7846759
- "Building Great Agent Skills: The Missing Manual" (AI Engineer): https://www.youtube.com/watch?v=UNzCG3lw6O0 — summaries: https://finance.biggo.com/news/e88eeef727a29496 (2026-06-29), https://mirul.xyz/posts/the-missing-manual-how-to-write-great-skills/ (2026-07-08)
- "Software Fundamentals Matter More Than Ever": https://videohighlight.com/v/v4F1gFy-hqg
- "mattpocock/skills: A complete AI Coding workflow, end-to-end": https://www.youtube.com/watch?v=M6mYodf0dJM (summary: https://daily.dev/posts/mattpocock-skills-learn-the-whole-flow-end-to-end-ge7l5ksx8, 2026-07-16)
- "9 Things People Get Wrong With My /grill-* skills": https://www.youtube.com/watch?v=UzMNBN6xLLA (summary: https://daily.dev/posts/9-things-people-get-wrong-with-my-grill--skills-mfbdd93de, 2026-05-25)
- "New Skills! v1.2 ...": https://www.youtube.com/watch?v=gaDdrDdczO4 (summary: https://daily.dev/posts/new-skills-v1-2-brings-wait-what-writing-for-agents-and-fixes-grill-me-pmyvx5tqf, 2026-08-05)
- "LIVE: The /wayfinder Demo": https://www.youtube.com/watch?v=251hsWgoTPM (not retrievable)

### Harness/platform docs
- https://code.claude.com/docs/en/discover-plugins
- https://claude.com/plugins/mattpocock-skills
- https://skills.sh/mattpocock/skills

### Community (secondhand)
- https://skillselion.com/guides/matt-pocock-skills-map (updated 2026-08-16; X quotes)
- https://devtalk.com/t/anyone-tried-mattpocock-skills-for-claude-code-here-is-what-i-found-after-a-week/244771 (pre-1.0)
- https://www.developersdigest.tech/blog/github-trending-skills-2026-05-13 and https://www.developersdigest.tech/blog/skills-for-real-engineers-governance
- https://daily.dev/posts/matt-pocock-s-ai-coding-skills-from-requirement-grilling-to-fog-of-war-planning-vlkst4zef (2026-08-20)
- https://github.com/DeepLearningAI/Claude-Skills (stale pre-1.0 fork)
- https://kaizencode.art/notepad/matt-pocock-skills-guide/ (2026-07-16)
- https://blog.alexrusin.com/agentic-coding-pipeline-matt-pocock-skills/ (2026-08-07) and https://blog.alexrusin.com/matt-pocock-skills-main-flow/ (2026-07-16)
- https://andrew.ooo/posts/matt-pocock-skills-claude-code-review/ (2026-05-02)
- https://tosea.ai/blog/matt-pocock-skills-claude-code-guide (2026-04-26; stale)
- https://cussid-huaz.github.io/agent-brain/entities/ai/matt-pocock/
- https://hn.algolia.com/api/v1/search?query=mattpocock%20skills&tags=story (HN index; no substantive comment threads found)
