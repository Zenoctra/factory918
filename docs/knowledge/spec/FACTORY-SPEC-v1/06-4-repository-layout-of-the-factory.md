<!-- lines: 59 | source: spec/FACTORY-SPEC-v1.md | part 6/14 | title: The Factory spec, v1 (superseded) — 4. Repository layout of the factory -->

## Contents (line numbers are for the Read tool's offset)
- L6: 4. Repository layout of the factory

## 4. Repository layout of the factory

```
factory/                              the template repo (its own git repo, MIT)
├── README.md
├── SOURCES.md                        upstream repos, shas, paths taken, patches applied (feeds `factory sync`)
├── factory.sh                        the CLI: init | apply | doctor | update | sync | labels
├── manifest.schema.json              what .factory/manifest.json in a project looks like
├── patches/                          sed/patch files applied to vendored skills (§5.4)
└── template/                         everything below is copied into a project
    ├── AGENTS.md                     the letter (§7.6); CLAUDE.md is the line `@AGENTS.md`
    ├── CLAUDE.md
    ├── CONTEXT.md                    empty glossary skeleton in Matt's format
    ├── CODING_STANDARDS.md           read at review time, not implementation time (§7.7)
    ├── .agents/skills/               vendored + custom skills (one folder, every harness)
    │   ├── poteto-mode/  how/  why/  teach/  architect/  arena/  swarm/  interrogate/  tdd/  bro/  unslop/
    │   │   no-comments/  technical-writing/  typescript-best-practices/  blast-radius/  recall/
    │   │   show-me-your-work/  figure-it-out/  reflect/  automate-me/  setup-pstack/
    │   │   create-verification-skill/  maintain-verification-skill/  principle-*/ (21)
    │   │   deslop/  babysit/  fix-ci/  fix-merge-conflicts/  get-pr-comments/  what-did-i-get-done/
    │   │   make-pr-easy-to-review/  thermo-nuclear-code-quality-review/          ← from open-pstack
    │   ├── grilling/  grill-with-docs/  grill-me/  domain-modeling/  to-spec/  to-tickets/  wayfinder/
    │   │   research/  prototype/  setup-matt-pocock-skills/  writing-for-agents/  wizard/  wait-what/
    │   │   spec-review/  (renamed from code-review)                                ← from mattpocock/skills
    │   └── ticket/  mode-plan/  mode-build/  factory-doctor/                         ← ours
    ├── .claude/
    │   ├── skills -> ../.agents/skills   (symlink; T3 Code's pattern)
    │   ├── agents/                    pstack-fable-*.md, pstack-opus-*.md, poteto-agent.md, comment-sicko.md
    │   ├── settings.json              hooks (§7.4)
    │   └── hooks/  mode.sh  format-on-write.sh  block-dangerous-git.sh  session-start.sh  session-mandate.md
    ├── docs/agents/
    │   ├── issue-tracker.md           Matt's GitHub template, pre-filled
    │   ├── domain.md                  Matt's single-context template
    │   ├── review-ladder.md           §7.5
    │   ├── feedback-loops.md          Matt's ten rungs, as a reference for the bug-fix playbook
    │   └── evidence.md                evidence conventions (§7.5)
    ├── docs/adr/0001-toolchain.md
    ├── vite.config.ts                 fmt / lint / staged / test (§7.2)
    ├── oxlint-plugin-project/         index.ts + rules/ + one starter rule with test (§7.3)
    ├── .vite-hooks/pre-commit         `vp staged`
    ├── .github/
    │   ├── workflows/ci.yml  pr-size.yml  labels.yml
    │   ├── labels.json                the seven planning labels + size labels
    │   ├── pull_request_template.md
    │   └── pr-assets/.gitkeep         (rejected by CI if anything else lands here)
    ├── .repos/README.md               vendored reference sources go here, read-only (§7.8)
    ├── tsconfig.base.json             strict
    ├── .editorconfig
    └── .gitignore                     + .artifacts/ .scratch/ .plans/ .claude/state/ .vite-hooks/_ .repos/*/ (except README)
```

Why one skills folder: Claude Code reads `.claude/skills/`; Codex, T3 Code and Ras Mic's set read `.agents/skills/`; T3 Code keeps the two byte-identical through a symlink **[primary: t3code .claude/skills → ../.agents/skills]**. Same skills, both harnesses, checked in.

---
