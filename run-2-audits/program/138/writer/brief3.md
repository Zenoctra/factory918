# Writer brief 3: Opus 5 leaves, GPT-6 Sol joins through Codex (#138, Manuel 2026-09-24)

Work on `wt/138-writer`. Fast-forward it to `feat/reviewer-eval-rerun` (c8aca57) first. Add new commits only; do not rebase or push. Launch no reviewer run, Claude or Codex: the owner runs the pilot after you land this. The only exception is the one tiny smoke call in section 2, which the owner allows so you can learn the session-log shape.

Two paths recur below. W is `/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.claude/worktrees/agent-af1a10e904a9448aa`. M is the main checkout.

## 1. Opus 5 leaves the measurement

- `next` never prints or prepares a `claude:opus-5` run, even when the descriptor is named. When it is named, `next` prints one line saying the model is retired from scheduling (Manuel, 2026-09-24).
- Its collected runs stay in the table, and the table labels the model "partial (pass 1 and some pass 2; retired 2026-09-24)".
- The root stopped eight of its pass-2 runs mid-run. They are prepared runs with no complete receipt. Any report such a run left behind is not a result.
  - `collect` must never collect them. Give `next` or `collect` a way to set them aside, recorded as `retired: stopped by the root`, and use it on those runs.
  - They are Opus 5 runs under `W/.scratch/eval/reviewer-138/runs/claude-opus-5/` that have a `run.json` and no `receipt.json`. Set aside means moved under `dropped/`, the same as other set-asides; delete nothing.
  - Leave its complete runs alone.

## 2. The Codex route for `codex:gpt-6-sol`

Facts, checked by the root on 2026-09-24:
- `codex-cli 0.156.1` at `/opt/homebrew/bin/codex` runs `codex exec -m gpt-6-sol` on Manuel's ChatGPT login.
- `~/.codex/models_cache.json` lists `gpt-6-sol`.
- `gpt-6-terra` is excluded: do not add it.
- Session logs are `~/.codex/sessions/YYYY/MM/DD/rollout-*.jsonl`. Their first line is `session_meta`, with `cwd`, `cli_version` and `session_id`. Read a few real ones to learn the event shapes, including where the model, the reasoning effort, tool calls and outputs, and token usage are recorded.
- Before you write the parser, you may run one smoke call with a tiny prompt, e.g. `codex exec -m gpt-6-sol -c model_reasoning_effort="high" "Reply ok"`, from an empty temporary directory. Use its session log as a real fixture.

Build it this way:
- **Route.** Add `codex:gpt-6-sol` to MODELS as a Codex route. Bring back only what it needs from the route #138 removed (git history has the old `External` route).
- **Launch.**
  - `next --run codex:gpt-6-sol [--limit N]` prepares the ready Sol runs and launches them itself as `codex exec` subprocesses, at most 4 at once. It waits for them and collects them.
  - The command is `codex exec -m gpt-6-sol -c model_reasoning_effort="high" --cd <export> --json ...`, or whatever gives a session log you can bind to the run. Record the session file's path in `run.json` or the receipt.
  - Pick a sandbox that lets the reviewer write inside its export, run the tests, and reach the network, the same as the Claude lanes can. Candidates are `--sandbox workspace-write` with network access allowed, or full access. Record the choice and why.
  - Nothing in the prompt changes.
- **Same run as a Claude run.** Same export, same prompt text, same frozen `ticket.md` and `blast-radius.md`, same per-run `.scratch/work/`, same report path. The report is read from the export, the same as for Claude.
- **Receipt.**
  - Verify the served model from the session log, and refuse on any mismatch.
  - Verify the effort from the session log: `high` passes, anything else is refused. If the log does not record effort, say so in the result and record the requested effort as `requested: high`. Do not guess.
  - Take tokens (input, cached, output, reasoning if present) and wall clock from the log.
- **Content check and cross-run check.** Apply both to the Codex log. Map its tool calls and outputs (function_call, exec_command, apply_patch and their outputs) onto the same `tool_results` iteration the check uses. Map the first-contaminated call ordinal, the sightings and the outside-path records too.
- **Dropouts.**
  - A usage-limit message in the log or on stderr is a `usage-limit` dropout that pauses the model, the same as Fable. `--resume codex:gpt-6-sol` continues after it.
  - A Codex failure with no answer is a `no-response` dropout.
- **Tests first.**
  - A real Codex session fixture: the smoke call, or a real #103 astra session if you find one.
  - Model and effort parsing, effort refusal, and token and wall reading.
  - The content check hitting a future line inside a Codex exec output.
  - The cross-run check on a Codex call.
  - The usage-limit pause, and the concurrency cap of 4 (with a fake `codex` on PATH).
  - Copy the real fixtures into the test data, trimmed, so CI runs without `~/.codex`.

## 3. Verify

Run each of these:
- `refusals.sh`
- `corpus.sh`
- `check`
- `rebuild.sh` for all three rounds
- `fixes.sh`
- ShellCheck with the AGENTS.md line, updating the count if a script is added
- `next codex:gpt-6-sol --limit 8`, as a dry run with a temporary REVIEWER_OUT (not `--run`). It should print 6 pass-1 lines with the Codex command.

## Result

Write the result to your scratch and copy it to `M/.scratch/program/138/writer/done15`. Include:
- the head sha and the commits;
- the sandbox choice;
- what the Codex log records for model and effort;
- the fixtures used;
- the test outcomes;
- the list of runs set aside as retired;
- the exact pilot command the owner should run.
