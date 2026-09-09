# Profile: vite-plus (default)

Every TypeScript surface: web apps, admin apps, Node services, CLIs, scripts, shared packages. Files: `vite.config.ts` (fmt, lint, staged, test), `.vite-hooks/pre-commit`, `oxlint-plugin-project/`, `tsconfig.base.json`, `.github/workflows/ci.yml`, `pr-size.yml`, `labels.yml`. Exemplar: pingdotgg/t3code at the pinned `vite-plus` version. Commands agents use: `vp check`, `pnpm typecheck`, `vp test run <files>`, `vp build`, `vp fmt`.

Monorepo shape (`vp create vite:monorepo`): `apps/web`, `apps/admin`, `apps/mobile` (react-native profile), `packages/shared`, `scripts/`, `python/<name>` (python profile). One root `vite.config.ts`; per-package `vite.config.ts` only for test environment overrides (T3 Code's server sets `fileParallelism: false` for load-sensitive tests).

Cross-language custom rules live in `ast-grep/` (`sgconfig.yml`, `rules/*.yml`, `rule-tests/`), run in CI as `ast-grep scan`; TypeScript-only rules live in the oxlint plugin. Verify `ast-grep` install and `scan` output format at M0.
