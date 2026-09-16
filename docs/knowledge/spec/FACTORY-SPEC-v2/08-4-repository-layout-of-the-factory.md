<!-- lines: 74 | source: spec/FACTORY-SPEC-v2.md | part 8/17 | title: The Factory spec, v2 — 4. Repository layout of the factory -->

## Contents (line numbers are for the Read tool's offset)
- L6: 4. Repository layout of the factory

## 4. Repository layout of the factory

```
factory918/                           this repository (its own git repo)
├── CLAUDE.md                         reading order and working rules for the model finishing this repo
├── README.md
├── SOURCES.md                        upstream repos, shas, paths taken, exclusions, patches applied (feeds `factory918 sync`)
├── VERSION
├── factory918.sh                     the CLI: init | apply [--profile] | doctor | update | sync | sync-repos | labels | knowledge
├── manifest.schema.json              what .factory918/manifest.json in a project looks like
├── patches/                          patch files applied to vendored skills (§5.4); today the list lives in SOURCES.md
├── docs/FACTORY-SPEC-v2.md           this document
├── docs/knowledge/                   THE FULL CORPUS (not copied into projects; `/knowledge` reads it from here)
│   ├── INDEX.md                      every file, its line count, when to read it
│   ├── core/  PHILOSOPHY.md  MANUAL.md  DECISIONS.md  GLOSSARY.md  CONVERSATION-DIGEST.md   hand-maintained
│   ├── spec/  FACTORY-SPEC-v2 (chunked)  FACTORY-SPEC-v1 (chunked)                             generated
│   ├── pages/ four-skill-systems/  deterministic-layer/  pocock-planning-evidence/               generated
│   └── notes/ 1-matt-pocock/ 2-theo/ 3-pstack/ 4-ras-mic/ 6-deterministic-layer/                 generated
├── research/                         read-only corpus: notes/, pages/, and the pinned upstream copies
│   ├── 1-matt-pocock/skills-repo/    mattpocock/skills @ 6654f6b
│   ├── 2-theo-t3code-excerpts/       pingdotgg/t3code @ f559fe0b: AGENTS.md, workflows, vite.config.ts, hooks, mobile app configs
│   ├── 3-pstack/                     upstream-cursor-plugin/ @ 7314f72 and open-pstack-claude-code-port/ @ v1.3.0
│   ├── 4-ras-mic/                    pointer only (no license upstream)
│   └── superseded/                   FACTORY-SPEC-v1.md
├── tools/
│   ├── build_knowledge.py            regenerates docs/knowledge/ (all but core/) and template/docs/factory918/
│   └── bootstrap/                    frozen: how template/ and profiles/ were first generated; writes to its _out/ only
├── .claude/skills/                   links to writing-for-agents, technical-writing, unslop, deslop, knowledge (sessions here)
├── profiles/
│   ├── vite-plus/README.md           the default; points at the template files
│   ├── react-native/  README.md  mobile-fingerprint-check.yml (T3 Code, MIT)  eas.json.example
│   └── python/        README.md  pyproject.toml  python.yml  .pre-commit-config.yaml
└── template/                         everything below is copied into a project
    ├── AGENTS.md                     the letter (§7.6); CLAUDE.md is the line `@AGENTS.md`
    ├── CLAUDE.md
    ├── CONTEXT.md                    empty glossary skeleton in Matt's format
    ├── CODING_STANDARDS.md           read at review time (§7.7)
    ├── docs/factory918/              slim copies: PHILOSOPHY.md  MANUAL.md  DECISIONS.md  GLOSSARY.md
    ├── .agents/skills/               vendored + custom skills (one folder, every harness)
    │   ├── pstack (51 dirs: all of open-pstack's except no-comments)                     ← from open-pstack
    │   ├── grilling/ grill-me/ grill-with-docs/ domain-modeling/ to-spec/ to-tickets/ wayfinder/
    │   │   research/ prototype/ setup-matt-pocock-skills/ writing-for-agents/ wizard/ wait-what/
    │   │   spec-review/ (renamed from code-review)                                       ← from mattpocock/skills
    │   └── factory918/ factory-start/ knowledge/ mode-plan/ mode-build/ factory-doctor/  ← ours
    │       (+ poteto-mode/playbooks/ticket.md, ours, inside the vendored router)
    ├── .claude/
    │   ├── skills -> ../.agents/skills   (symlink; T3 Code's pattern)
    │   ├── agents/                    pstack-fable-*.md, pstack-opus-*.md, poteto-agent.md  (no comment-sicko)
    │   ├── settings.json              hooks (§7.4)
    │   └── hooks/  mode.sh  format-on-write.sh  block-dangerous-git.sh  session-start.sh  session-mandate.md
    ├── docs/agents/
    │   ├── issue-tracker.md  domain.md  triage-labels.md      Matt's GitHub templates, pre-filled
    │   ├── review-ladder.md  evidence.md  feedback-loops.md   §7.5
    │   ├── models.md                  the role→model defaults for /setup-pstack (§7.12)
    │   └── ledger.md                  one line per surprise; rules are promoted from here
    ├── docs/adr/0001-toolchain.md
    ├── vite.config.ts                 fmt / lint / staged / test (§7.2)
    ├── oxlint-plugin-project/         index.ts + rules/ + one starter rule with test (§7.3)
    ├── sgconfig.yml                   ast-grep project config, at the root so scan and test take no flags
    ├── ast-grep/                      rules/ + rule-tests/ with committed snapshots (§7.11)
    ├── .vite-hooks/pre-commit         `vp staged`
    ├── .github/
    │   ├── workflows/ci.yml  pr-size.yml  labels.yml
    │   ├── labels.json  pull_request_template.md  pr-assets/.gitkeep
    ├── .repos/README.md  sources.json  vendored reference sources go here, read-only (§7.9)
    ├── tsconfig.base.json  .editorconfig  .gitignore.factory  package.scripts.json
```

Why one skills folder: Claude Code reads `.claude/skills/`; Codex, T3 Code and Ras Mic's set read `.agents/skills/`; T3 Code keeps the two byte-identical through a symlink **[primary]**. Why the knowledge base stays in the factory repo: projects carry the four core documents and the `knowledge` skill, which reads the full corpus from `$FACTORY918_HOME` (default `~/.factory918`, the clone the CLI runs from). One place to update, light projects.
