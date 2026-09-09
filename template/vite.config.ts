import { defineConfig } from "vite-plus";

// DRAFT. Mirrors the working structure of pingdotgg/t3code's vite.config.ts (vite-plus 0.3.0).
// Verify every key against https://viteplus.dev/config/ at the pinned version before trusting it.
export default defineConfig({
  test: {
    environment: "node",
    exclude: [".repos/**", "node_modules/**", "dist/**"],
    hookTimeout: 60_000,
    testTimeout: 60_000,
  },
  staged: {
    // Formatter only on commit (Theo's rule). CI owns lint, types and tests.
    "*": "vp fmt --no-error-on-unmatched-pattern",
  },
  fmt: {
    ignorePatterns: [".repos/**", "dist/**", "node_modules/**", "pnpm-lock.yaml", "*.tsbuildinfo", ".artifacts/**"],
    sortPackageJson: {},
  },
  lint: {
    plugins: ["eslint", "oxc", "typescript", "unicorn", "react"], // drop "react" for non-React projects
    jsPlugins: ["./oxlint-plugin-project/index.ts"],
    categories: { correctness: "error", suspicious: "warn", perf: "warn" },
    rules: {
      "typescript/no-explicit-any": "error", // "any is the enemy"
      "no-console": ["error", { allow: ["error", "warn"] }],
      "project/no-todo-without-issue": "error",
    },
    overrides: [
      // Debt ceilings for rules that land on old code (Theo's pattern). Numbers only go down; delete the entry at zero.
      // { files: ["src/legacy/thing.ts"], rules: { "project/no-todo-without-issue": ["error", { maxOccurrences: 12 }] } },
    ],
    options: {
      reportUnusedDisableDirectives: "error", // a stale disable comment is itself an error
      typeAware: true, // docs recommend both; fall back to false if your TS setup conflicts, and keep `pnpm typecheck`
      typeCheck: true,
    },
  },
});
