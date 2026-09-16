# Profile: vite-plus (default)

Every TypeScript surface: web apps, admin apps, Node services, CLIs, scripts, shared packages. Files: `vite.config.ts` (fmt, lint, staged, test), `.vite-hooks/pre-commit`, `oxlint-plugin-project/`, `tsconfig.base.json`, `.github/workflows/ci.yml`, `pr-size.yml`, `labels.yml`. Exemplar: pingdotgg/t3code at the pinned `vite-plus` version. Commands agents use: `vp check` (format, lint and types in one pass; it stops at the first stage that fails), `vp test run <files>`, `vp run -r build`, `vp fmt`, `pnpm sg` for the ast-grep rules.

Monorepo shape (`vp create vite:monorepo`): `apps/web`, `apps/admin`, `apps/mobile` (react-native profile), `packages/shared`, `scripts/`, `python/<name>` (python profile). One root `vite.config.ts`; per-package `vite.config.ts` only for test environment overrides (T3 Code's server sets `fileParallelism: false` for load-sensitive tests).

Cross-language custom rules live in `ast-grep/` (`rules/*.yml`, `rule-tests/` with committed snapshots) with `sgconfig.yml` at the repo root, and run in CI as `pnpm sg`; TypeScript-only rules live in the oxlint plugin.
