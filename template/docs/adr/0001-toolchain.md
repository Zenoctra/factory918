# Toolchain: Vite+ (`vp`) on pnpm and Node 24

We standardise on Vite+ as the single toolchain: `vp fmt` (Oxfmt), `vp lint` (Oxlint), `vp check`, `vp test` (Vitest), `vp build`, `vp hooks`/`vp staged` for git hooks, pnpm underneath, Node 24. Versions pinned: vite-plus <fill>, @oxlint/plugins <fill>, node <fill>, pnpm <fill>. Because every hook, CI job and skill names these commands, changing the toolchain is a repo-wide change: hard to reverse, surprising without context, and a real trade-off (one vendor's cadence versus assembling Prettier + ESLint + tsc + Vitest ourselves).
