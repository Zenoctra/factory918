<!-- lines: 16 | source: spec/FACTORY-SPEC-v1.md | part 13/14 | title: The Factory spec, v1 (superseded) — 10. Decisions only you can make [decide] -->

## Contents (line numbers are for the Read tool's offset)
- L6: 10. Decisions only you can make [decide]

## 10. Decisions only you can make [decide]

1. **Comments.** Keep pstack's `/no-comments` in the PR flow (deletes explanatory comments) or drop that one line while you are learning.
2. **Commit hook thickness.** Thin (formatter only; default) or thick (format + typecheck + tests on every commit) while suites are small.
3. **Model roles** for `/setup-pstack` on a Claude-only account: the default table above, or all `inherit-parent`.
4. **Auto-PR from tickets.** Default yes (a ticket is the ask). Alternatively require "file" to be said.
5. **Multi-repo systems.** Default: each repo gets the factory; one "system" repo holds the wayfinder maps, a `CONTEXT-MAP.md` pointing at each repo's `CONTEXT.md` (Matt's multi-context layout), and cross-repo tickets use full refs (`owner/repo#N`). Alternative: a monorepo via `vp create vite:monorepo`.
6. **Codex.** When you add it: open-pstack's Codex plugin path plus `.agents/skills` already being the Codex convention means nothing in the template moves.
7. **The name.** `factory` is a placeholder.

---
