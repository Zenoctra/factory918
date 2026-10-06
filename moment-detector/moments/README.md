# Labelled moments: a correction from Manuel arriving

The evidence the moment detector (#174) is scored against: every message Manuel wrote in his past Claude Code sessions, labelled as a correction or not, with the near misses marked. The code is here; the library, and everything holding his words, is in the main checkout's `.scratch/moment-detector/moments/`, which git ignores. Nothing in this directory may carry transcript text.

## Steps

1. `python3 moment-detector/moments/extract.py` reads the top-level transcripts under `~/.claude/projects/` (all projects; `--projects GLOB` narrows it) and writes `moments.jsonl`. Rerunning rewrites it; ids are stable.
2. `python3 moment-detector/moments/label.py --name opus55` labels every moment with Opus 5.5 at high effort, one fresh `claude -p` judge call per moment with no tools in an empty box (`quick-tests/lib/qtlib.py`). The prompt is `definition.md` followed by the moment. A rerun labels only what is missing. `--show ID` prints a moment's prompt. The second labeller is the same prompt on another model: `--name opus5 --model claude-opus-5`.
3. `python3 moment-detector/moments/library.py` joins them into `library.jsonl` and `review.jsonl` and prints the counts.
4. `python3 moment-detector/moments/score.py PREDICTIONS.jsonl` scores a detector.

When Manuel rules on a borderline class, change that class's sentence in `definition.md` and relabel its members (`label.py --name opus55-r2 --ids ...`), then rebuild the library from the new labels.

## Where Manuel's words are in a transcript

A transcript is a tree of records linked by `parentUuid`; a forked or resumed session's file repeats its parent's records under the same uuids, so `extract.py` keeps each message where it was first written. Manuel's words arrive four ways (`delivery`):

- `prompt`: a `user` record whose `origin.kind` is `human`.
- `command`: a slash command's `<command-args>` (`/goal`, `/factory918`, `/wayfinder`, `/poteto-mode`); `/goal` records carry no `origin`. `/model`, `/loop` and `/auto-mode-setup` are settings or machine-written ticks and are skipped.
- `queued`: an `attachment` record of type `queued_command` with a human origin, typed while the agent was mid-turn. It never becomes a `user` record.
- `ask_answer`: the tool result of an `AskUserQuestion` call, starting "The user answered".

Not his: tool results, `origin.kind` `task-notification` or `peer`, `isMeta` records (skill bodies, the `/goal` Stop-hook notice), `<bash-input>` and `<local-command-*>` records, compaction summaries, `[Request interrupted by user]` (kept as context), and `<pasted_content>` blocks inside his messages (kept apart as `pasted`).

## Formats

`moments.jsonl`, one moment per line:

| Field | Meaning |
|---|---|
| `id` | `<session id, 8>-<record uuid, 8>`, stable across reruns |
| `project`, `session_id`, `uuid`, `line`, `ordinal`, `timestamp` | where to find it again; `uuid` is the `--at` for `quick-tests/replay/replay.py run` (a T moment) |
| `delivery`, `command`, `images` | how it arrived |
| `text`, `pasted` | his words; material he pasted |
| `context.previous_message` | his previous message in the session |
| `context.since_previous` | what the agent did since, in order: `said: ...`, `tool Name: ...`, tool errors, interrupts, background notifications |
| `context.last_reply` | the agent's last words to him before this message |
| `context.interrupted`, `context.starts_session` | flags |
| `after.agent_reply`, `after.next_message` | hindsight, for the labeller only; a detector must not read it |

`labels-NAME.jsonl`: `id`, `labeller`, `model`, `effort`, and the fields `definition.md` asks for.

`library.jsonl`, the file a scorer reads: `id`, the location fields, `delivery`, `starts_session`, `correction` (bool, the primary labeller's), `kind`, `surface` (`overt`, `quiet`, `none`), `near_miss`, `hard_case`, `confidence`, `unclear`, `second_correction` (the second labeller's bool), `reason`, `evidence`, `other_reading`.

`review.jsonl`: the library rows that are unclear or where the labellers disagree.

A detector's predictions: `{"id": ..., "fired": true|false}` per line. `score.py` reports recall on all, overt and quiet corrections, the false-alarm rate on all other messages and on near misses, and precision, leaving unclear moments out unless `--include-unclear`.
