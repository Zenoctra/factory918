<!-- lines: 16 | source: notes/6-deterministic-layer.md | part 1/10 | title: Research note: deterministic layer (verbatim config) — (preamble) -->

## Contents (line numbers are for the Read tool's offset)

# The deterministic layer: primary-source notes

Raw material for a write-up. Every fact below is quoted or paraphrased from a file in the local clones; the path is given with each fact. Nothing was read from the web. Date of extraction: 2026-09-05.

Glossary for the reader (defined only by what the sources say, in their own words where possible):

- **Hook (git)**: a script git runs at a moment such as "before commit". Theo's repo has one (`.vite-hooks/pre-commit`), Matt's `setup-pre-commit` skill installs one (`.husky/pre-commit`).
- **Hook (harness)**: a script the coding-agent tool itself runs at a moment such as "session start" or "before a tool call". The pstack ports use a `SessionStart` hook; Matt's `git-guardrails-claude-code` uses a `PreToolUse` hook that can deny a command.
- **Review bot**: an automated reviewer that reads a PR and posts findings. Theo's repo configures one (Macroscope, `.macroscope/`); pstack and Ras Mic write triage rules for other people's bots (Bugbot, Greptile).
- **Seam**: Matt's `codebase-design` skill defines it (quoted in D.2). **ADR**: his `ADR-FORMAT.md` defines it (quoted in D.4). **Code smell**: his `code-review` skill lists twelve (D.3).

---
