<!-- lines: 12 | source: spec/FACTORY-SPEC-v2.md | part 5/17 | title: The Factory spec, v2 — 1. What Manuel needs, in one paragraph -->

## Contents (line numbers are for the Read tool's offset)
- L6: 1. What Manuel needs, in one paragraph

## 1. What Manuel needs, in one paragraph

Large-scope projects he owns end to end: novel logic across several surfaces (web app, admin tools, scripts, ad tooling), sometimes several repos, with uncommon dependencies. Nearly all code will be written by agents. He wants a loadable, opinionated, professional baseline for every new project so that the project-specific decisions are few, known in advance, and settled fast; a planning phase that turns big ideas into GitHub tickets; an execution phase that turns each ticket into a verified PR with the human at the ends; and a deterministic layer (formatter, lint, types, tests, CI, review) that catches what prompts cannot. He prefers bundled toolchains with minimal weight (Vite+), Claude Code today with Codex possible later, everything through GitHub, and copying experienced people's opinions until he has his own.

---

**Settled decisions (2026-09-09; full table with reasons in `docs/knowledge/core/DECISIONS.md`).** Comments stay in the code; pstack's `/no-comments` is not run. The commit hook is thin (formatter only). Never block on the human, except irreversible actions. A ticket auto-opens a PR that closes it; the human merges. Repositories are private; one monorepo per product by default. Mobile is Expo / React Native, not Flutter. Python is supported as a profile (`uv`, `ruff`, `pyright`, `pytest`). Cross-language custom rules use `ast-grep`. Opus 5 is the default model, Sonnet 5 for mechanical delegates, Fable 5.1 reserved for judgment that is the product. The knowledge base lives in the Factory918 repo with slim copies in projects. The name is Factory918.
