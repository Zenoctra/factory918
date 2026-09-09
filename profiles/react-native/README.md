# Profile: react-native (Expo)

Applies on top of `vite-plus` when a product has a mobile surface. Exemplar: T3 Code Mobile (`apps/mobile` in pingdotgg/t3code): Expo SDK 57, React Native 0.86, tests via `vp test run` (139 Vitest files), `tsc --noEmit`, the root oxlint config, EAS builds with `development` / `preview` / `production` profiles, and the `test-t3-mobile` skill for simulator verification. **[primary: t3code apps/mobile/package.json, eas.json, .agents/skills/test-t3-mobile]**

## What carries over unchanged

Formatter, linter (including custom rules), typecheck, unit tests, the commit hook, the CI Check and Test jobs, PR size labels, the PR contract, the review ladder, the evidence conventions. The mobile app is one more package in the pnpm workspace; `vp check` and `vp test run` already cover it.

## What this profile adds

| Piece | File | Notes |
|---|---|---|
| App layout | `apps/mobile/` created with `npx create-expo-app@latest apps/mobile --template blank-typescript` (or an Expo template of your choice) inside the workspace | Managed workflow; no `ios/` or `android/` directories committed. `expo prebuild` generates them when a native build is needed. |
| Scripts | `apps/mobile/package.json`: `"test": "vp test run"`, `"typecheck": "tsc --noEmit"`, `"dev": "expo start"`, `"eas:preview": "eas build --profile preview"` | Mirror of T3 Code's minimal set. |
| Build profiles | `apps/mobile/eas.json` with `development`, `preview`, `production` | EAS builds in the cloud; no macOS runner in CI needed. |
| Native-change signal | `.github/workflows/mobile-fingerprint-check.yml` (copied from T3 Code, MIT) | Advisory: always passes; labels the PR `📱 Native Change` when `expo-updates fingerprint` differs, so native PRs can be batched before a store build. Paths in `on.pull_request.paths` must be edited to this repo's layout. |
| Native lint gate | Only if you eject or add native modules: T3 Code's `mobile_native_changes` job (Linux, detects `.swift`/`.kt` changes, fails open) gating a macOS `swiftlint` / `ktlint` / `detekt` job | Not applied by default; managed Expo apps have no native sources to lint. |
| Verification | `/create-verification-skill` generates `verify-<app>-mobile`; the exemplar is `sources/t3code/.agents/skills/test-t3-mobile/SKILL.md` | Simulator launched by the primary agent only; screenshots via `xcrun simctl io booted screenshot` (iOS) or `adb exec-out screencap -p` (Android) are the evidence; "an open Simulator window alone is not evidence that the intended app launched." |
| E2E (optional) | Maestro flows in `apps/mobile/e2e/*.yaml` | Text flows an agent can write and read; runs on simulators locally and in EAS Workflows. Add when the app has more than a handful of screens. |
| Shared code | `packages/shared` for types and logic used by web and mobile | The reason one language was chosen. Mobile imports from the package, never from `apps/web`. |

## Rules that change for mobile

- The primary agent runs one integrated pass on a simulator after integrating; subagents never launch simulators.
- "Do not enter pairing hosts or tokens through simulator keyboard automation" generalises to: never type secrets into a simulator; use deep links or env.
- A PR that changes the native fingerprint waits for the batch; the label is the signal, not a failure.

## What was verified and what was not

Verified: T3 Code's scripts, dependencies and workflow files (primary). Not yet run here: the fingerprint workflow on a fresh Expo project; Maestro on a Vite+ workspace. Both are M-profile acceptance checks.
