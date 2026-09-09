<!-- lines: 20 | source: spec/FACTORY-SPEC-v2.md | part 4/17 | title: The Factory spec, v2 — 0. Instructions to the implementing model -->

## Contents (line numbers are for the Read tool's offset)
- L6: 0. Instructions to the implementing model

## 0. Instructions to the implementing model

You are finishing a template repository (`factory918`) and a small CLI that applies it to new and existing projects. Read this whole document first. This repository is the draft: `template/`, `profiles/`, `factory918.sh` and `docs/knowledge/` are drafts of the files this spec describes, starting points marked DRAFT, not finished artifacts. `research/` contains every upstream source referenced here (Matt Pocock's skills at `6654f6b`, pstack upstream at `7314f72`, the open-pstack Claude Code port at v1.3.0, T3 Code excerpts at `f559fe0b`) and six research notes. `CLAUDE.md` at the root gives the reading order and says which files are the truth.

Rules for this build:

1. **Verify versions before writing config.** `npm view vite-plus version`, `npm view @oxlint/plugins version`, `claude --version`. T3 Code pins `vite-plus@0.3.0` and `@oxlint/plugins@^1.63.0` **[primary: t3code/pnpm-workspace.yaml, package.json]**; the Vite+ docs describe `vp` commands without a version **[primary: viteplus.dev]**. Pin what you install; record it in `docs/adr/0001-toolchain.md`.
2. **Do not invent `vp` flags or config keys.** Every key used in `vite.config.ts` below appears in T3 Code's working config or the Vite+ config reference. If a key errors, consult `viteplus.dev/config/*`, fix, and note the change in `SOURCES.md`.
3. **Every milestone has acceptance checks. Run them.** A milestone whose checks did not run is not done ("A generated skill that was never executed is a draft, not a deliverable" — pstack, and it applies to you).
4. **Do not edit vendored skill bodies except through the patch list in §5.** Patches are recorded so `factory918 sync` can re-apply them on upstream updates.
5. **Ask Manuel only for [decide] items.** Everything else has a default in this document or in `docs/knowledge/core/DECISIONS.md`, which wins over this document where they differ.
6. **Load the writing skills into your own session before you write anything another model will read.** `writing-for-agents` (Matt), `technical-writing`, `unslop` and `deslop` (pstack) are linked into this repository's `.claude/skills/`, so they are available as `/writing-for-agents` and so on in any session opened here; install nothing at user level (a personal copy would later shadow project copies); apply `writing-for-agents` to every skill, playbook, mandate and `AGENTS.md` text, and `technical-writing` + `unslop` to every human-facing document. `deslop` applies to code you write (`factory918.sh`, hooks, the lint plugin).
7. **The knowledge base is your reference; read it by section.** `docs/knowledge/INDEX.md` lists every file with its line count and when to read it; `core/PHILOSOPHY.md` is the one file to read whole. Use the `knowledge` skill's procedure (grep, mini-TOC, ranged Read) for everything else. Never read a knowledge file over 200 lines without `offset`/`limit`.

---
