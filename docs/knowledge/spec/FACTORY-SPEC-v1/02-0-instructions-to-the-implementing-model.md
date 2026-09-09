<!-- lines: 18 | source: spec/FACTORY-SPEC-v1.md | part 2/14 | title: The Factory spec, v1 (superseded) — 0. Instructions to the implementing model -->

## Contents (line numbers are for the Read tool's offset)
- L6: 0. Instructions to the implementing model

## 0. Instructions to the implementing model

You are building a template repository (working name `factory`) and a small CLI that applies it to new and existing projects. Read this whole document first. The companion bundle `four-skill-systems-sources.zip` contains every upstream source referenced here (Matt Pocock's skills at `6654f6b`, pstack upstream at `7314f72`, the open-pstack Claude Code port at v1.3.0, T3 Code excerpts at `f559fe0b`) and six research notes. `factory-skeleton/` in the same bundle contains drafts of the files this spec describes; they are starting points marked DRAFT, not finished artifacts.

Rules for this build:

1. **Verify versions before writing config.** `npm view vite-plus version`, `npm view @oxlint/plugins version`, `claude --version`. T3 Code pins `vite-plus@0.3.0` and `@oxlint/plugins@^1.63.0` **[primary: t3code/pnpm-workspace.yaml, package.json]**; the Vite+ docs describe `vp` commands without a version **[primary: viteplus.dev]**. Pin what you install; record it in `docs/adr/0001-toolchain.md`.
2. **Do not invent `vp` flags or config keys.** Every key used in `vite.config.ts` below appears in T3 Code's working config or the Vite+ config reference. If a key errors, consult `viteplus.dev/config/*`, fix, and note the change in `SOURCES.md`.
3. **Every milestone has acceptance checks. Run them.** A milestone whose checks did not run is not done ("A generated skill that was never executed is a draft, not a deliverable" — pstack, and it applies to you).
4. **Do not edit vendored skill bodies except through the patch list in §5.** Patches are recorded so `factory sync` can re-apply them on upstream updates.
5. **Ask Manuel only for [decide] items.** Everything else has a default in this document.

---
