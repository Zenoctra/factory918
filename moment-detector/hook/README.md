# The moment detector's hook

This is the machinery of #174: a Claude Code hook that asks a separate model one narrow question about the session, gives the main model a suggestion it may decline, and logs every check. It is proven on one moment, a correction from the user arriving. The suggestion is a placeholder; what is measured is the pipeline. Workshop-only, like `quick-tests/`: nothing here goes under `template/`.

## How it is wired

1. **The event.** A `UserPromptSubmit` command hook runs `md.py hook`. It fires before the main model sees the message, so its time is added to every prompt.
2. **What the detector reads.** The hook takes the new message from its input and reads the session's transcript (`transcript_path`, or `$MD_TRANSCRIPT` when set) for what came before it: the main model's text since the previous user message (`last_reply`), its tool calls with their paths and commands (`actions`), and optionally the previous user message. It never reads thinking. Each part is on or off, and cut to a length, in the moment's `slice`.
3. **The question.** The moment's question, optional labelled examples, the slice, and an answer format go to a fresh `claude -p` call on the subscription: `--safe-mode` (no hooks, CLAUDE.md, skills, plugins or MCP), no tools, thinking off where the model allows it, no prompt cache, no session file, a one-line system prompt, run from the temp directory. The model answers `{"score", "cue"}` as text, a score from 1 to 10, and the check fires at the moment's `threshold`; `--json-schema` costs a second turn and twice the tokens. The default is the one the scoring step chose: Opus 5.5 at low effort reading the agent's last reply and actions, with `question-definition.md`, firing at 6 (`moment-detector/scoring/README.md`).
4. **The suggestion.** When the verdict is yes, the hook returns the moment's suggestion as `additionalContext`, which reaches the main model as a system reminder beside the message. The placeholder names the cue the detector saw, says it is a separate model reading a short slice that can be wrong, proposes one scoped step (write one sentence naming what is being corrected and what the user now means), and invites a one-line decline. It states facts and offers a choice; it carries no "must" or authority (research note, sections 6.5 and 10).
5. **The trace.** The suggestion carries an id, `md-xxxxxx`. Taking it up means beginning the restatement with `(md-xxxxxx)`; declining means writing `(md-xxxxxx declined: <reason>)`. Both are in the reply the user reads.
6. **The log.** Every check, fired or not, is one JSON line: the id, the moment, the session and prompt ids, a hash of the prompt, the configuration (model, slice, hashes of the question, examples and suggestion files), the case the detector read, its raw answer and verdict, whether a suggestion went out and its text, the model that answered, latency (the model call's wall time, the API time, the check, the whole hook), tokens (input, cache read, cache write, output) and cost. A skipped check logs why. An error logs the error and delivers nothing; the hook always exits 0. The log goes to `$MD_LOG`, else `$CLAUDE_PROJECT_DIR/.scratch/moment-detector/checks.jsonl`.
7. **Uptake.** `md.py uptake TRANSCRIPT --log LOG` finds each suggestion by its id in the transcript's `hook_additional_context` record, collects the main model's text and tool calls until the next user message, and reports `taken`, `declined` with the reason, or `no_trace`. With the log it adds the verdict, latency and cost, and checks the prompt against the logged hash. A marker says what the model wrote, not whether the suggestion changed its work; paired runs measure that.

Several moments can share an event: every directory under `moments/` (or `$MD_MOMENTS`) whose `event` matches is checked in parallel, and their suggestions are joined. The hook then takes as long as the slowest one.

## Install it in a box

`trial.py` builds a box with `quick-tests/lib/qtlib.py` (no network for tools, writes only in the box, none of Manuel's settings), puts a small project in it with the hook in its `.claude/settings.json`, and runs one Claude Code session with the turns in `trial/turns.json`:

```
python3 moment-detector/hook/trial.py [--turns FILE] [--queue] [--model claude-opus-5-5] [--effort medium] \
  [--set key=value ...] [--out DIR]
```

Each turn is sent when the previous one has finished; `--queue` sends them all at once, as messages typed while the model works. `--set` changes the moment's configuration in the box. The session is persisted, because the hook reads its transcript; afterwards the transcript is moved out of `~/.claude/projects`, the account's identifiers are redacted, and `uptake` runs over it. The output (default `.scratch/moment-detector/hook-trials/<stamp>` in the main checkout) holds `summary.md`, `checks.jsonl`, `uptake.json`, `transcript.jsonl`, `stream.jsonl` and `safety.json`, the kit's check that nothing reached Manuel's settings, memory or main checkout.

The settings entry, for a project:

```json
{"hooks": {"UserPromptSubmit": [{"hooks": [{"type": "command",
  "command": "python3 \"$CLAUDE_PROJECT_DIR/.claude/md/md.py\" hook", "timeout": 60}]}]}}
```

## Configuration

A moment is a directory: `moment.json` and the files it names. `moments/correction/` is the one built here.

| Key | What it sets |
|---|---|
| `event` | The hook event it runs on. |
| `model`, `effort` | The detector's model (an alias such as `haiku`, `sonnet`, `opus`, or a full id) and requested effort (`null` leaves it out). |
| `thinking_tokens` | The CLI's `MAX_THINKING_TOKENS` for the call. `0` (the default) turns Haiku 4.5's thinking off; a budget such as `2048` turns it on. Sonnet 5.5 cannot have thinking turned off; `effort` is its lever. |
| `prompt_caching` | `false` (the default) sets `DISABLE_PROMPT_CACHING` for the call. Every check's prompt is new, and the CLI writes the cache at twice the input price, so a cache write is never read back and only doubles the input cost. |
| `threshold` | With a number, the answer carries a graded `score` and the check fires at `score >= threshold`; with `null`, the answer carries a boolean `moment`. |
| `timeout_s` | The model call's limit; past it the check logs a timeout and delivers nothing. |
| `slice` | `previous_user`, `last_reply`, `actions` on or off; `prompt_chars`, `previous_user_chars`, `last_reply_chars` (the tail is kept), `max_actions` (the last ones are kept). |
| `skip_first_message` | No check when nothing came before the message: a session's first message cannot correct the agent. |
| `skip_prompt_patterns` | Regular expressions; a matching prompt is logged as skipped. The defaults match the text of task notifications, slash-command expansions and `!` shell input as they appear in transcripts; whether those reach the hook was not tested. |
| `system_prompt`, `question`, `examples`, `answer_format` | What the detector is asked. `question` and `examples` are file names, relative to the moment or absolute; `examples` is `null` for the definition alone. `examples.synthetic.md` shows the format and is not real data. |
| `suggestion` | The suggestion's template: `{id}`, `{cue}`, `{confidence}`, `{score}`, `{model}`. |
| `deliver` | `false` is shadow mode: the check runs and is logged with the suggestion it would have sent, and nothing reaches the main model. The control arm of the paired runs. Default `true`. |

## For the scoring step

The scorer drives the same code path the hook runs, with no session:

```
md.py case TRANSCRIPT USER_RECORD_UUID [--moment correction] [--set key=value ...] > case.json
MD_LOG=scores/checks.jsonl md.py check correction --set model=sonnet --set slice.last_reply=false \
  --set examples=/path/to/labelled.md < case.json
```

`case` rebuilds, from a past transcript and the uuid of a user message (a typed or a queued one), the exact slice the hook would have read there; on the trial's transcript it matched the hook's logged case for all four turns. `check` runs one check over a case with overrides and prints the log record. `moment-detector/scoring/` drives these functions over the labelled library; its README has the method and the results. `question.md` is the short working definition the hook first shipped with, kept so that baseline can be rerun.

For paired runs with and without the suggestion, `moment-detector/paired/` runs this hook live under replay, delivering in one arm and in shadow mode in the other; its README has the method and the results.

## What was verified, Claude Code 2.1.288, 2026-10-05

The research note read 2.1.286 and the documentation. These are from the binary.

- A plain `claude -p` from a hook re-enters the project's hooks: `UserPromptSubmit` and `SessionStart` fired, and the project's CLAUDE.md was applied. `--bare` skips hooks but reads only an API key. `--safe-mode`, which the note does not mention, turns off hooks, CLAUDE.md, skills, plugins and MCP and keeps the subscription login: no hook fired and the call succeeded. The hook also exits at once when `MOMENT_DETECTOR_INNER` is set, which the inner call sets.
- The inner call spent 58 to 254 thinking tokens on Haiku by default; `MAX_THINKING_TOKENS=0` removes them. `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1` took a Haiku call from about 2.4 s to 0.75 s of wall time. With both and a one-line system prompt, the fixed overhead is about 400 input tokens.
- The hook input carries `prompt`, `prompt_id`, `session_id`, `transcript_path`, `cwd`, `scratchpad_dir` and `permission_mode`. `prompt_id` equals the `promptId` of the user record that follows.
- When the hook runs, the transcript holds everything before the new message and not the message itself. On a session's first message the file does not exist yet. It can lag: a queued message's hook did not see a tool call made about a second earlier.
- `additionalContext` reaches the model and is recorded as an `attachment` record of type `hook_additional_context`, with `content` (a list) and `hookName`.
- A message typed while the model is working fires `UserPromptSubmit` too, one hook after another, and reaches the model mid-turn as a `queued_command` attachment, not as a user record. Queued messages share the running turn's `prompt_id`, so the suggestion's id, not the prompt id, ties a check to what followed.
- User records of a `-p` session have no `origin` field; the desktop sessions' records carry `origin.kind` (`human` or `task-notification`).
- With `--json-schema` the answer takes two turns and about twice the tokens.
- Sonnet 5.5 and Opus 5.5 calls write and then read the prompt cache; Haiku 4.5 calls did not cache (the prompt is under Haiku's minimum).

Verified on 2.1.288, 2026-10-06, during the scoring step:

- `MAX_THINKING_TOKENS=2048` gives Haiku 4.5 a thinking block (output went from 103 to 428 tokens on a probe), so Haiku's thinking can be set from this path. Sonnet 5.5 returns a thinking block whatever the variable says; at low effort it wrote about 16 output tokens a check, so it hardly thinks. Temperature cannot be set from the CLI.
- The CLI writes the cache for the whole prompt at twice the input price (the 1-hour rate), and a check's prompt is never repeated, so the write is never read. `DISABLE_PROMPT_CACHING=1` halved a Sonnet check's cost (from $0.0226 to $0.0114 on the same 5,600-token prompt). The hook now sets it.
- Sonnet 5.5 twice answered a 1 to 10 scale with 72 and 96, in 3,537 scored checks; Opus 5.5 (423) and Haiku 4.5 (1,794) never did. A score outside `score_range` is now an invalid answer.

Verified on 2.1.288, 2026-10-06, under replay (`quick-tests/replay/replay.py run --hooks --persist`, which resumes a copy of a past session with `-p --resume --fork-session`):

- `UserPromptSubmit` fires on the replayed message, and the hook's `additionalContext` reaches the model and is recorded in the forked session's transcript as a `hook_additional_context` attachment, as in a live session.
- A forked session writes its transcript only when its first message is recorded, which is after this hook runs. The hook input names the new file, which does not exist yet, so the first check of a forked session read nothing and was skipped as the session's first message. This would also hit the first message after a fork in the desktop app (not tried there). `$MD_TRANSCRIPT` points the hook at another transcript; replay sets it to the copy it resumed from, which holds what the live hook read at that message. On the one moment compared, the slice built that way matched the scoring step's `md.py case` except where a rewritten path moved the 300-character cut of a tool call.

Not verified: whether the hook fires on a background agent's report (the skip patterns catch it by its text); the desktop app as opposed to the CLI; Codex.

## Measured

On the trial's three cases (a correction, a new request, a near miss starting with "No"), three times per model, `trial/results/models/checks.jsonl`. Wall time is the model call as the hook sees it; the whole hook adds about 5 ms, and starting Python about 50 ms. Cost is the CLI's figure at API list price, which on the subscription is usage, not a bill.

| Detector | Wall time, median (range) | Input tokens, median | Cost per check, median (mean) |
|---|---|---|---|
| Haiku 4.5 | 0.87 s (0.82 to 1.16) | 918 | $0.0011 ($0.0011) |
| Sonnet 5.5 | 1.31 s (1.23 to 1.63) | 1,102 | $0.0008 ($0.0019) |
| Opus 5.5 | 1.94 s (1.60 to 3.01) | 1,098 | $0.0024 ($0.0039) |

Sonnet and Opus were cheaper than their list price suggests after the first call, because these three cases repeated the same prompt and the cache was read; on real messages it never is, and the hook now turns caching off. One Sonnet call in another run took 6.0 s. All 27 verdicts matched the expected label; these cases are easy and say nothing about accuracy.

## The trials, `trial/results/`

All the words in them are written for the trial. The main session ran on Opus 5.5 at medium effort, the detector on Haiku 4.5.

- `sequential/`: four turns. The first was skipped as the session's first message. The correction fired; the main model began its reply with the marker, restated what it took the user to mean, and said that only one function existed. The new request and the near miss passed.
- `queued/`: the same four messages sent at once. The three queued messages each got a check during the first turn; the correction fired and its suggestion arrived mid-turn. The main model answered all the messages together and wrote no marker (`no_trace`). In an earlier queued run it did write one.
- `decline/`: a fixture question (`trial/fixtures/question-always-fires.md`) made the detector fire on the user's answer to the agent's own question. The main model declined: "this answers the question I asked rather than correcting something I said."

## Open

- The marker sits in the reply the user reads, and asking for it is itself a change to the main model's behaviour. The paired replays (`../paired/`) found that it tracks the restatement it asks for, not the work, and that the main model wrote it on every false alarm: measure uptake with paired runs, not markers.
- A decline reason is cut at its first `)`.
- The hook costs about 2 s on every message on Opus 5.5 at low effort (median 1.98 s, 90th percentile 2.9 s on the test split), against about 1 s on Haiku. The first-message skip and the skip patterns are structural gates; more of them, decided without a model, would cut the calls further.
- An answer to `AskUserQuestion` reaches the agent as a tool result, so `UserPromptSubmit` never fires for it; two of the library's clean corrections came that way. A `PostToolUse` hook on `AskUserQuestion` could check them. Whether a slash command's arguments reach the hook, and in what form, is untested; the skip pattern for `<command-message>` drops them as transcripts record them, which lost one correction on the test split.
- A queued correction is judged with whatever the transcript held at that moment, which can miss the latest action.
