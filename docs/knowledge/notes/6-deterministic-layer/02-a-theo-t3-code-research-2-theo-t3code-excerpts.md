<!-- lines: 160 | source: notes/6-deterministic-layer.md | part 2/10 | title: Research note: deterministic layer (verbatim config) — A. Theo / T3 Code — `research/2-theo-t3code-excerpts/` -->

## Contents (line numbers are for the Read tool's offset)
- L8: A. Theo / T3 Code — `research/2-theo-t3code-excerpts/`
- L12: A.1 GitHub workflows (`.github/workflows/`)
- L106: A.2 Commit-time hook and `vite.config.ts`

## A. Theo / T3 Code — `research/2-theo-t3code-excerpts/`

Repo state: `git log --oneline | wc -l` returns `1` (a single squashed commit, `f559fe0b fix(web): show context meter in compact composer (#9430)`), so there is no usable commit history for "when did X change" questions.

### A.1 GitHub workflows (`.github/workflows/`)

Sixteen workflow files exist: `ci.yml`, `cursor-hygiene-webhook.yml`, `deploy-relay.yml`, `desktop-macos-preview.yml`, `issue-labels.yml`, `mobile-eas-preview.yml`, `mobile-eas-production.yml`, `mobile-fingerprint-check.yml`, `mobile-showcase-screenshots.yml`, `pr-size.yml`, `pr-vouch.yml`, `publish-aur.yml`, `release.yml`, `thread-transfer-report.yml`, `web-preview.yml`, `windows-tests.yml`.

#### `ci.yml` (the required gate)

Trigger (`.github/workflows/ci.yml` lines 3-7): `on: pull_request:` and `push: branches: [main]`. Concurrency: `group: ci-${{ github.event.pull_request.number || github.sha }}`, `cancel-in-progress: ${{ github.event_name == 'pull_request' }}` (lines 12-14). Every job uses `timeout-minutes: 10` and a sparse checkout that excludes the vendored `.repos/` directory.

Jobs, with exact commands:

1. **`check`** (`name: Check`, `runs-on: blacksmith-8vcpu-ubuntu-2404`):
   - Step "Reject repository-owned PR assets" (lines 30-36), quoted in full:
     ```
     - name: Reject repository-owned PR assets
       run: |
         files="$(git ls-files .github/pr-assets)"
         if test -n "$files"; then
           printf 'PR evidence must be uploaded to GitHub, not committed:\n%s\n' "$files" >&2
           exit 1
         fi
     ```
   - `uses: voidzero-dev/setup-vp@v1` with `node-version-file: package.json`, `cache: true`, `run-install: true` (lines 38-43).
   - `vp run --filter @t3tools/desktop ensure:electron` (line 46)
   - `vp check` (line 49)
   - `vpr typecheck` (line 52)
   - `sudo apt-get update && sudo apt-get install -y libsecret-1-dev pkg-config` (line 55)
   - `vp run build:desktop` (line 58)
   - `node apps/desktop/scripts/verify-preload-bundle.mjs` (line 61)
2. **`test`** (`name: Test`): `vp run --parallel --concurrency-limit 4 --filter '!t3' --filter '!@t3tools/monorepo' test` (line 95). The comment above it (lines 63-67): "Everything except `t3` (apps/server). `--parallel` drops the package dependency ordering that `vp run` applies by default: these `test` tasks declare no `dependsOn` and resolve workspace deps from source, so ordering only bought us idle runners between dependency layers."
3. **`test_server`** (`name: Test Server ${{ matrix.shard }}`, `strategy.matrix.shard: [1, 2, 3]`, `fail-fast: false`): `vp run --filter t3 test --shard ${{ matrix.shard }}/${{ strategy.job-total }}` (line 132) with env `T3CODE_TRANSFER_BUDGET_REPORT_PATH: ${{ runner.temp }}/t3code-transfer-budget.md` and `T3CODE_TRANSFER_BUDGET_RESULT_PATH: ${{ runner.temp }}/thread-transfer-result.json` (lines 130-131). Comment (lines 97-100): "apps/server sets `fileParallelism: false`, so its 239 files run strictly one at a time. Sharding spreads them over separate runners instead of separate workers, so no two server test files ever share a machine and the isolation that flag buys is preserved exactly." The transfer-budget steps (lines 138-164), quoted:
   ```
   - name: Detect transfer budget report
     id: transfer_budget
     if: always()
     run: |
       if test -f "${{ runner.temp }}/thread-transfer-result.json"; then
         echo "present=true" >> "$GITHUB_OUTPUT"
       else
         echo "present=false" >> "$GITHUB_OUTPUT"
       fi

   - name: Publish transfer budget report
     if: always() && steps.transfer_budget.outputs.present == 'true'
     run: |
       if test -f "${{ runner.temp }}/t3code-transfer-budget.md"; then
         tee -a "$GITHUB_STEP_SUMMARY" < "${{ runner.temp }}/t3code-transfer-budget.md"
       else
         echo "Transfer budget report was not produced." >> "$GITHUB_STEP_SUMMARY"
       fi

   - name: Upload thread transfer result
     if: always() && steps.transfer_budget.outputs.present == 'true'
     uses: actions/upload-artifact@v7
     with:
       name: thread-transfer-results
       path: ${{ runner.temp }}/thread-transfer-result.json
       if-no-files-found: ignore
       retention-days: 30
   ```
   The comment above (lines 133-137): "src/server.test.ts writes the budget report, so exactly one shard produces these files. Gating the upload on their presence keeps a single `thread-transfer-results` artifact per run, which is the name thread-transfer-report.yml resolves."
4. **`rust`** (`runs-on: blacksmith-4vcpu-ubuntu-2404`): `cargo fmt --manifest-path native/resource-monitor/Cargo.toml -- --check` (line 187) and `cargo test --locked --manifest-path native/resource-monitor/Cargo.toml` (line 190). Comment: "Split out of Check and Test: both paid ~7-9s to install a Rust toolchain for checks that take under 3s, on the critical path of every PR."
5. **`mobile_native_changes`** (`runs-on: blacksmith-2vcpu-ubuntu-2404`, `timeout-minutes: 5`): an API-only gate. Comment (lines 192-195): "The static analysis below needs a macOS runner, which bills ~6.7x a Linux minute, so gate it on the native sources it actually lints instead of paying for it on every push. Detection is API-only (no checkout) and fails open: if the diff cannot be resolved, the lint runs." The matched path pattern (line 259): `'^apps/mobile/.*\.(swift|kt|kts)$|^apps/mobile/(\.swiftlint\.yml|detekt\.yml|\.editorconfig|Brewfile)$|^scripts/mobile-native-static-check\.ts$|^package\.json$|^\.github/workflows/ci\.yml$'`. It fails open when the PR files endpoint lists fewer files than `changed_files` reports, or when the compare endpoint returns ≥300 files.
6. **`mobile_native_static_analysis`** (`needs: mobile_native_changes`, `if: ${{ !cancelled() && needs.mobile_native_changes.outputs.changed != 'false' }}`, `runs-on: blacksmith-6vcpu-macos-26`): `brew bundle install --file apps/mobile/Brewfile` then `vp run lint:mobile` (lines 297-300). `scripts/mobile-native-static-check.ts` runs `swiftlint lint --config .swiftlint.yml --strict` (line 251), `ktlint` (line 261), and `detekt` (line 266).
7. **`release_smoke`**: `node scripts/release-smoke.ts` (line 325).

What fails `ci.yml`: any non-zero step in `check`, `test`, `test_server` (any shard), `rust`, `mobile_native_static_analysis`, or `release_smoke`. Budgets: the transfer budget (A.8) is enforced inside `test_server` via an assertion in `apps/server/src/server.test.ts`; runner timeouts are 10 minutes per job.

#### `pr-size.yml`

Trigger (`.github/workflows/pr-size.yml` lines 3-5): `pull_request_target: types: [opened, reopened, synchronize, ready_for_review, converted_to_draft]`. It manages six labels (lines 23-54): `size:XS` "0-9 effective changed lines (test files excluded in mixed PRs).", `size:S` "10-29 …", `size:M` "30-99 …", `size:L` "100-499 …", `size:XL` "500-999 …", `size:XXL` "1,000+ …". Thresholds in code (lines 174-196): `< 10` XS, `< 30` S, `< 100` M, `< 500` L, `< 1000` XL, else XXL. Diff command (lines 224-230): `git diff --numstat --ignore-all-space --ignore-blank-lines <base>...<head>`. Test files are excluded via pathspecs (lines 149-158): `**/__tests__/**`, `**/test/**`, `**/tests/**`, `apps/server/integration/**`, `**/*.test.*`, `**/*.spec.*`, `**/*.browser.*`, `**/*.integration.*`. Rule (line 246): `const changedLines = nonTestChangedLines === 0 ? testChangedLines : nonTestChangedLines;` — a test-only PR is sized by its test lines; a mixed PR by its non-test lines. Security comment (lines 127-129): "This pull_request_target job may fetch untrusted PR commits only as passive git data. Do not add dependency installs, build/test scripts, or cache actions here; use pull_request plus workflow_run for that pattern instead." It never fails a PR; it only swaps labels.

#### `pr-vouch.yml`

Triggers (`.github/workflows/pr-vouch.yml` lines 3-13): `pull_request_target` (same five types), `issue_comment: types: [created]` (acted on only when the comment body includes `/recheck-vouch`, line 40), and `push` to `main` touching `.github/VOUCHED.td` or the workflow itself (which re-labels every open PR). Step `uses: mitchellh/vouch/action/check-user@v1` with `allow-fail: true` (lines 78-85). Labels (lines 96-112): `vouch:trusted` "PR author is trusted by repo permissions or the VOUCHED list.", `vouch:unvouched` "PR author is not yet trusted in the VOUCHED list.", `vouch:denounced` "PR author is explicitly blocked by the VOUCHED list." Mapping (lines 157-162): status `denounced` → `vouch:denounced`; `bot`, `collaborator`, `vouched` → `vouch:trusted`; anything else → `vouch:unvouched`. `.github/VOUCHED.td` header: "External contributors listed here are treated as trusted by the vouch workflow. Collaborators with write access are automatically trusted and do not need to be duplicated in this file." Syntax: `github:username` or `-github:username reason for denouncement`. `CONTRIBUTING.md`: "PRs are automatically labeled with a `vouch:*` trust status and a `size:*` diff size based on changed lines. If you are an external contributor, expect `vouch:unvouched` until we explicitly add you to [.github/VOUCHED.td](.github/VOUCHED.td)."

#### `thread-transfer-report.yml`

Trigger: `workflow_run: workflows: [CI], types: [completed]`, job runs only `if: github.event.workflow_run.event == 'pull_request'`. Comment (lines 22-23): "workflow_run has a write-capable token even for fork PRs. Only load the publisher from the trusted default branch and never execute PR code." It checks out `.github/scripts` from the default branch, runs `node --test .github/scripts/thread-transfer-report.test.cjs` (line 31), resolves the PR artifact and a `main` baseline artifact (both named `thread-transfer-results`), and posts/updates one PR comment. The publisher (`.github/scripts/thread-transfer-report.cjs`) renders a table `| Provider | Metric | Main baseline | This PR | Impact | PR ceiling | |` (line 202) with ✅/❌ per ceiling and notes such as "No successful `main` baseline artifact is available yet. This run establishes the initial measurement." (line 175).

#### Other workflows (trigger → what it does)

- `cursor-hygiene-webhook.yml`: `push` to main, `pull_request` opened/reopened/ready_for_review, `issues`, `discussion` → `curl … -X POST "$URL"` forwarding the raw GitHub event payload to `CURSOR_T3CODE_WEBHOOK_URL`; exits 0 if secrets are missing.
- `issue-labels.yml`: push to main touching `.github/ISSUE_TEMPLATE/**` or the workflow, plus `workflow_dispatch` → creates/updates `bug`, `enhancement`, `needs-triage` labels.
- `mobile-fingerprint-check.yml`: `pull_request` on mobile-related paths → runs `npx expo-updates fingerprint:generate` for head and base; adds/removes the label `📱 Native Change`. Header comment: "The check is advisory: it always passes, the label is the signal." Label sync is skipped for forks: "This workflow must not move to pull_request_target — it installs and runs PR code."
- `web-preview.yml`: `pull_request: types: [labeled, synchronize, reopened]`; deploys to Vercel only when the PR carries the label `preview:web` and is same-repo; posts/updates a PR comment with the deployment URL.
- `desktop-macos-preview.yml`: `pull_request: types: [labeled, unlabeled, synchronize, reopened, closed]`; builds an unsigned DMG when label `preview:mac` is present; a separate publish job "never checks out PR code"; comments a download link; cleanup on unlabel/close.
- `mobile-eas-preview.yml`: `pull_request` opened/reopened/synchronize/labeled, gated on label `🚀 Mobile Continuous Deployment`; skips when `EXPO_TOKEN` absent.
- `mobile-eas-production.yml`: `workflow_dispatch` or push to main on mobile paths → `eas build --platform … --profile production --auto-submit …` and fingerprint-gated OTA.
- `deploy-relay.yml`: push to main → `vp run --filter t3code-relay deploy --stage prod --yes --github-output`.
- `release.yml` (1186 lines): tags `v*.*.*` (not nightlies), `schedule: cron "38 */3 * * *"`, `workflow_dispatch` with channel stable/nightly; `concurrency … cancel-in-progress: false, queue: max`.
- `publish-aur.yml`: `workflow_call` / `workflow_dispatch` → `packaging/aur/scripts/release.sh`.
- `mobile-showcase-screenshots.yml`: `workflow_dispatch` → `pnpm screenshots:mobile …` on iOS and Android, then `--validate-only`.
- `windows-tests.yml`: `workflow_dispatch` only. Header: "Manual only: nothing in the suite passes on Windows yet, so this exists to give contributors (and agents) a cloud Windows box to iterate against. Once the suite is green here, fold it into ci.yml."

### A.2 Commit-time hook and `vite.config.ts`

`.vite-hooks/pre-commit` is one line: `vp staged`.

Root `vite.config.ts` (193 lines) configures four things.

**`staged`** (lines 23-26), quoted:
```
staged: {
  // Formatter only for now — no lint or typecheck on commit.
  "*": "vp fmt --no-error-on-unmatched-pattern",
},
```

**`fmt`** (lines 27-46): `ignorePatterns` includes `.repos/**`, `.alchemy`, `dist`, `dist-electron`, `node_modules`, `pnpm-lock.yaml`, `*.tsbuildinfo`, `**/routeTree.gen.ts`, `apps/mobile/android/**`, `apps/mobile/ios/**`, `apps/mobile/uniwind-types.d.ts`, `*.icon/**`; `sortPackageJson: {}`; one override for `.devcontainer/devcontainer.json` (`trailingComma: "none"`).

**`lint`** (lines 47-181):
- `plugins: ["eslint", "oxc", "react", "unicorn", "typescript"]` and `jsPlugins: ["./oxlint-plugin-t3code/index.ts"]` (lines 61-62).
- `categories: { correctness: "warn", suspicious: "warn", perf: "warn" }` (lines 63-67).
- A list of rules set to `"off"` (lines 69-93), e.g. `"react-hooks/exhaustive-deps": "off"`, `"typescript/no-floating-promises": "off"`, `"typescript/no-unsafe-type-assertion": "off"`.
- `"eslint/no-restricted-imports": ["error", { paths: [...] }]` (lines 94-111) with two entries: `@t3tools/client-runtime` → message "Import from an explicit @t3tools/client-runtime/* subpath. The package has no root export."; `@pierre/diffs/react` importName `CodeView` → "Use StyledDiffCodeView so web diff surfaces share styling and virtualized geometry."
- Custom rules and severities (lines 112-116): `"t3code/no-global-process-runtime": "error"`, `"t3code/no-inline-schema-compile": "warn"`, `"t3code/no-manual-effect-runtime-in-tests": "error"`, `"t3code/no-native-title-tooltip": "error"`, `"t3code/namespace-node-imports": "error"`.
- `overrides` (lines 118-176): `packages/shared/src/hostProcess.ts` turns `no-global-process-runtime` off ("The one place that reads the host platform to seed the injected references."); `apps/mobile/src/**` enables `"t3code/no-mobile-uniwind-theme-escape-hatches": "error"`; a list of 22 mobile files gets `["error", { allowUniwindTheme: true }]` ("Reviewed native and third-party interop boundaries that cannot consume a className."); and the debt-ceiling block, quoted:
  ```
  // Legacy manual Effect runners tracked as debt: no net-new occurrences.
  // Lower a ceiling when you migrate a file, and delete its entry at zero.
  ...Object.entries({
    "apps/server/src/orchestration/Layers/CheckpointReactor.test.ts": 42,
    "apps/server/src/orchestration/Layers/OrchestrationEngine.test.ts": 5,
    "apps/server/src/orchestration/Layers/OrchestrationReactor.test.ts": 4,
    "apps/server/src/orchestration/Layers/ProviderCommandReactor.test.ts": 66,
    "apps/server/src/orchestration/Layers/ProviderRuntimeIngestion.test.ts": 29,
    "apps/server/src/orchestration/Layers/ThreadDeletionReactor.test.ts": 2,
    "apps/server/src/orchestration/commandInvariants.test.ts": 5,
    "apps/server/src/orchestration/projector.test.ts": 20,
    "apps/server/src/provider/Layers/CodexAdapter.test.ts": 1,
    "apps/server/src/provider/Layers/CodexSessionRuntime.test.ts": 5,
    "apps/server/src/provider/Layers/CursorAdapter.test.ts": 1,
    "apps/server/src/provider/Layers/CursorProvider.test.ts": 1,
    "apps/server/src/provider/Layers/ProviderService.test.ts": 2,
    "apps/server/src/provider/Layers/ProviderSessionReaper.test.ts": 12,
    "apps/server/src/provider/acp/CursorAcpSupport.test.ts": 1,
  }).map(([file, maxOccurrences]) => {
    const rule: ["error", { maxOccurrences: number }] = ["error", { maxOccurrences }];
    return { files: [file], rules: { "t3code/no-manual-effect-runtime-in-tests": rule } };
  }),
  ```
- `options` (lines 177-181): `reportUnusedDisableDirectives: "error"`, `typeAware: false`, `typeCheck: false`, with the comment "Revisit once Oxlint's tsgolint path can integrate with @effect/tsgo diagnostics."

**`test`** (lines 11-22): `environment: "node"`, excludes `.repos`, `node_modules`, `dist`, `dist-electron`; `hookTimeout: 60_000`, `testTimeout: 60_000`. `apps/server/vite.config.ts` lines 77-84 add `fileParallelism: false` ("Running files in parallel introduces load-sensitive flakes.") and 120 s timeouts.

**Commit time vs CI, exactly:**
- At commit: git runs `.vite-hooks/pre-commit` → `vp staged` → for every staged file, `vp fmt --no-error-on-unmatched-pattern`. That is the formatter only. No lint, no typecheck, no tests, per the comment "Formatter only for now — no lint or typecheck on commit."
- In CI (`ci.yml` job `check`): `vp check` (per `docs/internals/ci.md` line 8: "`vp check` (format and lint; this repo sets `typeCheck: false` in its lint options)"), then `vpr typecheck` (a separate workspace type check; root `package.json` `typecheck` script is `vp run -r --concurrency-limit 2 typecheck`), then a full desktop build and the preload-bundle verifier. Tests run in the `test` and `test_server` jobs. `AGENTS.md` tells agents "Do not run repo-wide checks. No `vp check`, no `vp run -r test`, no `vp run -r typecheck` unless I ask. CI owns the full suite."
- Root `package.json` `lint` script: `vp lint --report-unused-disable-directives`, so an `// oxlint-disable` comment that no longer suppresses anything is itself an error.
