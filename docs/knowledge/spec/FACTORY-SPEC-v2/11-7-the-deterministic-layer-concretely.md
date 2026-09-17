<!-- lines: 167 | source: spec/FACTORY-SPEC-v2.md | part 11/17 | title: The Factory spec, v2 — 7. The deterministic layer, concretely -->

## Contents (line numbers are for the Read tool's offset)
- L9: 7. The deterministic layer, concretely
- L11: 7.1 The toolchain decision (ADR 0001)
- L19: 7.2 `vite.config.ts` (DRAFT; mirrors T3 Code's working structure)
- L85: 7.3 The custom lint plugin (DRAFT)

## 7. The deterministic layer, concretely

### 7.1 The toolchain decision (ADR 0001)

**Default: Vite+ (`vp`).** One CLI over Vite, Rolldown, Vitest, tsdown, Oxlint, Oxfmt and Vite Task, with runtime and package-manager management; `vp create` scaffolds applications, libraries and monorepos, `vp migrate` converts existing projects, `vp hooks` manages git hooks, `vp staged` runs staged-file checks, `vp check` runs format and lint (and types when `options.typeAware`/`typeCheck` are on, which the docs recommend) **[primary: viteplus.dev guide, config, commit-hooks pages]**. Underneath it is pnpm on Node 24 (T3 Code: `packageManager: pnpm@11.10.0`, `engines.node ^24.13.1`) **[primary]**. Status: the docs call it beta; T3 Code runs it in production for a 200k-user product **[primary]**. Install: `curl -fsSL https://vite.plus | bash` (Windows: `irm https://vite.plus/ps1 | iex`) **[primary]**.

What it covers and does not: TypeScript/JavaScript projects of any shape (web app, Node service, library, CLI, monorepo). Not Flutter (Dart), not native mobile. React Native code can be linted, formatted and unit-tested with `vp` but is bundled by Metro. Python/Go/Rust: no; the factory's *shape* (thin hook, CI gates, labels, review ladder) still applies, with per-language commands. The template is TypeScript-first with a `toolchain` field in the manifest so other profiles can be added later.

Two words you asked about: **oxlint** is the Rust-based linter from the Oxc project, a drop-in for ESLint that runs 50–100× faster, ships hundreds of built-in rules grouped in categories (correctness, suspicious, perf, style, pedantic, restriction, nursery), and accepts ESLint-v9-compatible JS plugins for custom rules; it does not yet support type-aware custom rules or non-JS file formats **[primary: oxc.rs js-plugins page]**. **oxfmt** is its formatter, Prettier-compatible in intent. Both are what `vp lint` and `vp fmt` run.

### 7.2 `vite.config.ts` (DRAFT; mirrors T3 Code's working structure)

```ts
import { defineConfig } from "vite-plus";

export default defineConfig({
  test: {
    environment: "node",
    exclude: [".repos/**", "node_modules/**", "dist/**"],
    hookTimeout: 60_000,
    testTimeout: 60_000,
  },
  staged: {
    // Formatter only on commit (Theo). CI owns lint, types and tests.
    "*": "vp fmt --no-error-on-unmatched-pattern",
  },
  fmt: {
    ignorePatterns: [".repos/**", "dist/**", "node_modules/**", "pnpm-lock.yaml", "*.tsbuildinfo", ".artifacts/**"],
    sortPackageJson: {},
  },
  lint: {
    plugins: ["eslint", "oxc", "typescript", "unicorn", "react"],   // drop "react" for non-React projects
    jsPlugins: ["./oxlint-plugin-project/index.ts"],
    categories: { correctness: "error", suspicious: "warn", perf: "warn" },
    rules: {
      "typescript/no-explicit-any": "error",          // "any is the enemy" (Theo) / "unknown over any" (pstack)
      "no-console": ["error", { allow: ["error", "warn"] }],   // pstack: no console.log in shipped code
      "project/no-todo-without-issue": "error",       // the starter custom rule (§7.3)
    },
    overrides: [
      // Debt ceilings go here as rules land on old code (Theo's pattern):
      // { files: ["src/legacy/x.ts"], rules: { "project/some-rule": ["error", { maxOccurrences: 12 }] } },
    ],
    options: {
      reportUnusedDisableDirectives: "error",         // a stale disable comment is itself an error (Theo)
      typeAware: true,                                // docs recommend both; T3 Code disables them only for a tsgo conflict
      typeCheck: true,
    },
  },
});
```

Line-by-line: `test` is Vitest; `.repos` is excluded so vendored sources are never tested. `staged` maps a glob to a command run on staged files; `"*"` with `--no-error-on-unmatched-pattern` means non-code files are ignored quietly **[primary: t3code vite.config.ts]**. `fmt.ignorePatterns` keeps the formatter off generated and vendored files. `lint.plugins` are oxlint's built-in rule sets; `jsPlugins` loads your custom rules; `categories` sets whole groups at once; `rules` pins specific ones; `overrides` is where per-file exceptions and debt ceilings live; `options.reportUnusedDisableDirectives` is the self-protection rule. `no-explicit-any` and `no-console` are the two opinions all three seniors share. Verify `typescript/no-explicit-any` and `no-console` names against `vp lint --help`/oxlint docs at install time; if `typeAware`/`typeCheck` conflict with your TypeScript setup, fall back to T3 Code's `false` values and keep the separate `typecheck` script.

`package.json` additions (`template/package.scripts.json`, merged by `factory918 apply`; `vp create` writes the rest):

```json
{
  "_comment": "Merged into package.json by `factory918 apply`. Only what `vp` has no built-in for: dev, build, test, lint, fmt and check are built-in commands, and `vp check` already covers types.",
  "scripts": {
    "prepare": "vp config",
    "sg": "ast-grep scan",
    "sg:test": "ast-grep test"
  },
  "engines": {
    "node": "^24"
  },
  "devDependencies": {
    "@ast-grep/cli": "0.45.3",
    "@oxlint/plugins": "1.82.0"
  }
}
```

`vp config` (what `vp create` itself writes as `prepare`) installs the git-hook dispatcher under `.vite-hooks/_` (git-ignored), sets `core.hooksPath`, and refreshes Vite+'s delimited block in `AGENTS.md` if one exists; the project-owned `.vite-hooks/pre-commit` is committed **[primary: viteplus.dev/guide/commit-hooks; verified M0]**. `dev`, `build`, `test`, `lint`, `fmt` and `check` are `vp` built-ins and are not aliased as scripts; the template's scripts are `prepare`, `sg` and `sg:test` only, and `vp check` covers types, so there is no `typecheck` script.

### 7.3 The custom lint plugin (DRAFT)

`oxlint-plugin-project/index.ts`:

```ts
import { definePlugin } from "@oxlint/plugins";

import noTodoWithoutIssue from "./rules/no-todo-without-issue.ts";

export default definePlugin({
  meta: { name: "project" },
  rules: { "no-todo-without-issue": noTodoWithoutIssue },
});
```

`oxlint-plugin-project/rules/no-todo-without-issue.ts` (the starter rule; an unticketed note is a plan committed to the repo, which Theo forbids). `debtCeiling` reads the option out of unvalidated JSON without a cast; both helpers are exported so `no-todo-without-issue.test.ts` beside it can test the rule's two seams through `vite-plus/test`. Verified M0: the rule reports `// TODO fix later` and reported its own explanatory comment until that was reworded.

```ts
import { defineRule } from "@oxlint/plugins";

// Shape follows pingdotgg/t3code's rules (defineRule, meta, create(context), context.report).
// An unticketed note is a plan committed to the repo. Reference an issue, or file one and delete the note.
const TODO = /\b(TODO|FIXME|HACK)\b(?![^\n]*#\d+)/u;

/** True when a comment carries a TODO, FIXME or HACK with no `#123` beside it. */
export function needsIssueReference(comment: string): boolean {
  return TODO.test(comment);
}

/**
 * Theo's debt ceiling: the first N occurrences pass and the (N+1)th is reported.
 * The rule's options arrive as unvalidated JSON, so read the number out rather than casting.
 */
export function debtCeiling(option: unknown): number {
  if (typeof option !== "object" || option === null) return 0;
  if (!("maxOccurrences" in option)) return 0;
  const value = option.maxOccurrences;
  return typeof value === "number" ? value : 0;
}

export default defineRule({
  meta: {
    type: "problem",
    docs: {
      description:
        "Disallow TODO/FIXME/HACK comments that do not reference a tracker issue (#123).",
    },
    schema: [
      {
        type: "object",
        properties: {
          maxOccurrences: {
            type: "integer",
            minimum: 0,
            description: "Legacy debt ceiling for this file.",
          },
        },
        additionalProperties: false,
      },
    ],
  },
  create(context) {
    const allowed = debtCeiling(context.options[0]);
    let seen = 0;
    return {
      Program() {
        for (const comment of context.sourceCode.getAllComments()) {
          if (!needsIssueReference(comment.value)) continue;
          seen++;
          if (seen <= allowed) continue;
          context.report({
            node: comment,
            message:
              "Reference a tracker issue: `TODO(#123): ...`, or file the ticket and delete the note.",
          });
        }
      },
    };
  },
});
```

The `maxOccurrences` option is Theo's debt-ceiling mechanism, copied: "the first N occurrences pass, the (N+1)th is reported," and the number in `overrides` only ever goes down **[primary: t3code no-manual-effect-runtime-in-tests.ts]**. `defineRule`/`definePlugin` and the `context.report({ node, message })` shape are what T3 Code's six rules use **[primary]**; `context.sourceCode.getAllComments()` is an ESLint API oxlint lists as supported **[primary: oxc.rs]**; confirm at M1 by running `vp lint` on a file containing `// TODO fix later`. Ship the rule with a `*.test.ts` beside it as T3 Code does.
