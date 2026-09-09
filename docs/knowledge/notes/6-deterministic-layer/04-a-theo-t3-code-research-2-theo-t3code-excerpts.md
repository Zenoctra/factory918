<!-- lines: 32 | source: notes/6-deterministic-layer.md | part 4/10 | title: Research note: deterministic layer (verbatim config) — A. Theo / T3 Code — `research/2-theo-t3code-excerpts/` -->

## Contents (line numbers are for the Read tool's offset)
- L7: A.8 Transfer budget (`apps/server/integration/TransferBudgetReport.integration.ts`)
- L28: A.9 `docs/internals/ci.md`

### A.8 Transfer budget (`apps/server/integration/TransferBudgetReport.integration.ts`)

What it measures: bytes and message counts for one thread turn, per provider (`codex` and `claudeAgent`). `TransferBudgetRun` fields (lines 20-38) include `threadSnapshot` (HTTP), `measuredTurnWebSocket` ("One socket holding only the thread subscription. This is the capped measurement."), `measuredTurnShellWebSocket`, `measuredTurnSecondClientWebSocket`, `reconnectThread`/`reconnectShell` (catch-up mode `"replay" | "snapshot"`), `measuredTurnSqlStatements`, `reconnectSqlStatements`.

Headroom rule and caps (lines 47-58), quoted:
```
// These caps leave roughly 30% headroom above the client projection of the
// deterministic 9 MB retained-result fixture. Full MCP results stay in
// persistence, so accidentally shipping them again exceeds these caps by
// orders of magnitude. The CI report preserves exact values for review.
const TRANSFER_BUDGET = {
  totalWireBytes: 15_500,
  threadSnapshotWireBytes: 7_500,
  measuredTurnWebSocketWireBytes: 8_000,
  measuredTurnWebSocketDecodedBytes: 68_000,
  measuredTurnWebSocketMessages: 21,
} satisfies ProviderTransferBudget;
```

What fails: `transferBudgetViolations(runs)` (lines 155-190) returns a string per breach in the form `` `${run.provider}: ${metric} was ${observed}, maximum ${maximum}` `` for five capped metrics (total thread wire bytes, thread snapshot wire bytes, measured-turn WebSocket wire/decoded bytes, measured-turn WebSocket messages), or `"<provider>: no transfer budget is configured"`. In `apps/server/src/server.test.ts` the test `it.live("reports thread HTTP and WebSocket transfer budgets", …)` (line 9852) writes the markdown report and JSON result to the env-var paths and ends with `assert.deepEqual(transferBudgetViolations(runs), []);` (line 10140), with a 120 000 ms timeout. Shell, second-client, reconnect, and SQL rows are reported with `Budget = none, Result = INFO` (comment lines 128-133: "Shell delivery coalesces on a 50 ms window, so message counts and bytes move with scheduler timing between runs… The rows exist so CI shows the numbers next to the capped thread measurement."). The report header explains the scenario: N historical turns with command tools and one retained MCP result each, then one measured turn; "Payload sizes are calibrated from heavy local Codex and Claude histories and contain no user data."

### A.9 `docs/internals/ci.md`

Title "CI quality gates". Summary of its content: `ci.yml` runs on PRs and pushes to main; **Check** = `vp check` (format and lint, `typeCheck: false`) then `vpr typecheck`, plus `vp run build:desktop` and the preload verifier ("The verifier parses imports, then executes the trusted artifact with controlled bridge stubs to confirm that its required APIs are callable."); **Test** = `vp run test`; **Mobile Native Static Analysis** = `vp run lint:mobile` on macOS, gated by the cheap Linux job, "Otherwise the job is skipped, which GitHub reports as success for the required check. … The gate fails open in every other case"; **Release Smoke** "so release breakage surfaces on PRs rather than at tag time." `windows-tests.yml` "is not a required check". `release.yml` builds macOS arm64/x64, Linux x64, Windows x64 from one `v*.*.*` tag and "auto-enables signing only when platform credentials are present."

---
