# research/ — the corpus behind Factory918

Read-only. Everything here is either a research note with citations or a primary source (the actual skill files and agent-instruction files) taken from the upstream repositories at the pinned commits in `../SOURCES.md`. The `knowledge` skill reads the chunked copies under `../docs/knowledge/`; come here when you need the original file, a diff against upstream, or a full note.

    notes/
      1-matt-pocock.md            ~12k words. Philosophy, the end-to-end flow, six axes, a catalog of all 37 skills,
                                  how the repo evolved, install steps, friction. Every claim cited.
      2-theo.md                   ~11k words. Evidence inventory, AGENTS.md analyzed section by section, his public and
                                  private skills, why "don't copy them", reconstructed workflow, timeline. Claims tagged
                                  PRIMARY / SECONDARY / INFERRED.
      3-pstack.md                 ~9k words. The 21 principles, the router→playbook→skills structure, all 45 skills and
                                  23 playbooks, running it in Claude Code via the ports, Theo's verdict, friction.
      4-ras-mic.md                ~4k words. Workflow, his seven skills, the distinctive ideas, caveats.
      5-matt-planning-evidence.md ~9k words. Real specs, ticket sets, CONTEXT.md files and wayfinder maps produced by
                                  Matt's planning skills, counted failure reports, and a BMAD comparison.
      6-deterministic-layer.md    ~16k words of verbatim config: T3 Code's CI workflows, pre-commit hook, lint rules,
                                  review-bot configs and verification skills; pstack's verification/structure skills and
                                  the three Claude Code ports compared; Matt's tdd/seams/ADR/hook skills; Ras Mic's
                                  evidence recorder.

    pages/
      four-skill-systems.md       the "Four Skill Systems" reference page (markdown export)
      deterministic-layer.md      the "The Deterministic Layer" reference page (markdown export)

    1-matt-pocock/skills-repo/    github.com/mattpocock/skills at 6654f6b (2026-08-24, v1.2.3). MIT.
        README.md, CLAUDE.md, CONTEXT.md, CHANGELOG.md   start with README and CHANGELOG
        skills/engineering/*/SKILL.md    the 18 promoted engineering skills (+ supporting files)
        skills/productivity/*/SKILL.md   the 7 promoted productivity skills
        skills/misc/, skills/in-progress/   skills.sh-only extras and the beta skills
        docs/engineering/*.md, docs/productivity/*.md   his per-skill docs pages with "Common questions"
        .agents/invocation.md, .agents/adr/   how he decides user- vs model-invoked; why it ships as a plugin
        .out-of-scope/                   things he has refused to build, with reasons

    2-theo-t3code-excerpts/       github.com/pingdotgg/t3code at f559fe0b (2026-09-04). MIT. Excerpts only.
        AGENTS.md                        the 156-line team instruction file (CLAUDE.md is just "@AGENTS.md")
        CONTRIBUTING.md, t3.json, .mcp.json, model-manifest.json, package.json, pnpm-workspace.yaml,
        tsconfig.base.json, vite.config.ts, .vite-hooks/pre-commit, .gitattributes, .coderabbit.yaml, .codex/
        .agents/skills/*/SKILL.md        his four public verification skills (+ agents/openai.yaml, scripts, references);
                                         .claude/skills is the symlink to it, as in the real repo
        .github/workflows/               ci.yml, pr-size.yml, issue-labels.yml, pr-vouch.yml, windows-tests.yml,
                                         mobile-fingerprint-check.yml, mobile-eas-preview.yml, mobile-eas-production.yml
        .github/triage/PLAYBOOK.md       the agent-run support triage playbook; .github/pull_request_template.md
        .macroscope/                     AI review-agent configs that run as PR checks
        .cursor/rules/                   the Cursor-Cloud-only rules he keeps out of AGENTS.md
        docs/internals/, docs/user/      how T3 Code runs agents (threads, worktrees, checkpoints, plan mode, PR flow)
        oxlint-plugin-t3code/            six custom lint rules = encoded opinions
        apps/web, apps/server            per-app vite.config.ts (test-environment overrides)
        apps/mobile/                     eas.json, package.json, tsconfig.json, app.config.ts, .fingerprintignore, README
                                         (Expo SDK 57 / RN 0.86 under Vite+; the react-native profile's exemplar)

    3-pstack/
        upstream-cursor-plugin/          github.com/cursor/plugins/pstack at 7314f72 (2026-09-02, v0.14.8). MIT.
            README.md, docs/guide/01..10    read the guide here; it is not ported
            skills/poteto-mode/SKILL.md + playbooks/   the router and the 23 playbooks
            skills/principle-*/SKILL.md     the 21 principles
            skills/*/SKILL.md               the 24 action skills
            agents/, automations/benny/
        open-pstack-claude-code-port/    github.com/ericlitman/open-pstack v1.3.0 (2026-09-03), whole repo minus images.
                                         The Claude Code port template/.agents/skills/ is vendored from: plugins/pstack/
                                         (skills, agents, hooks), docs/reference.md, UPSTREAM.md, CHANGES.md, tests/.

    4-ras-mic/README.md               pointer + clone command (his repo states no license, so it is not copied)

    superseded/
      FACTORY-SPEC-v1.md               the first draft of the spec; the change log at the top of v2 refers to it
      make_spec_v2.py                  the script that produced v2 from v1 by section replacement (history only)

## Licenses

Matt Pocock's skills, pstack, open-pstack and T3 Code are MIT-licensed; their LICENSE files are included alongside the copied content. The notes and pages were written for Manuel and carry no license.
