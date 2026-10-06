# Replay a moment

`replay.py` restarts a past Claude Code session at a chosen point and has the model write that point again, many times, in a sealed copy of the repository. It is the "replay a moment" test from #153 decision 3, and the instrument for both tests per change from decision 5:

- **Does it help?** The change sits in front of the model at the moment: `--guidance`.
- **Does it reach?** The change sits where it would really live (CLAUDE.md, AGENTS.md, a skill, a hook, memory): `--patch`. Replay moments where it was needed to count how often it is applied, and moments where it was not to see whether it gets in the way.

Keep the two results apart; a change can help and still never reach.

Replay runs through the Claude Code CLI on Manuel's subscription, never the API. #160 holds the trial on the four failures from #152: which of them come back, how often, and what replay can't show. Its outputs are in `trial/results/`, its criteria in `trial/criteria/`. Read "How a replay differs from the original" below before you trust a count.

## Steps

1. **Find the moment.** `replay.py list <session.jsonl>` prints every turn (`T`, a prompt) and every response that wrote text (`M`, a moment) with its uuid. Root sessions for this repo are in `~/.claude/projects/-Users-manuel-Desktop-Work-Under-The-Sun-Collective-Core-918-factory918/`; GitHub comment timestamps narrow the search. `replay.py show <session> <uuid>` prints the original. Done when you hold the uuid of the response that holds the writing you care about.
2. **Replay it unchanged** to learn the base rate:
   ```
   replay.py run <session.jsonl> --at <uuid> --out /private/tmp/qt-replay/<name> -n 10
   ```
   An `M` uuid replays the moment: the copy ends just before that response and the CLI sends the fixed message `Continue.`. A `T` uuid replays the turn: the copy ends just before the prompt, and the prompt is sent again (or `--prompt-file`). Done when every run says `success` and the seal check names only the lines listed under "Seal check".
3. **Judge it** blind, against a criteria file that describes the failure (examples: `trial/criteria/`):
   ```
   replay.py judge <run-folder>... --criteria <file.md> --out <judge-folder>
   ```
   Pass every arm you compare in one call: the judge sees all runs shuffled under random ids, in one pass, and `tally.txt` splits the answers back by folder. Read a sample of the runs yourself and say how often you agree with the judge; #153 decision 8 wants the judge checked against Manuel before it is trusted.
4. **Test the change**, each arm in its own `--out`:
   - Help: `--guidance <file>` adds the text to the sent message as a `<system-reminder>` (`--guidance-raw` adds it bare).
   - Reach: `--patch <file.patch>` applies a git patch to the clone. A patched CLAUDE.md, AGENTS.md or memory file sits where a session started after the change would hold it (`--placement top`, the default) or arrives as Claude Code's "Instruction files were re-read" reminder beside the sent message, as it would mid-session (`--placement reminder`). Skills and hooks are read from the clone, so a patched skill or hook is live with no flag. Run both placements for an instruction file: on F2 the same sentence reached the moment 0 of 10 times from the top and 10 of 10 times as the reminder.
5. **Report** what ran and what it showed on the ticket, with the counts per arm and how they were judged. `replay.py summary <folder>...` lists each run's outcome and API-rate cost.

## Labelled moments

The trial's four moments, replayed unchanged with thinking kept. A change aimed at one of these can be tested against its base rate. `trial/criteria/` holds the criteria file for each.

| Failure | Session | `--at` | Base rate |
|---|---|---|---|
| F1. An anecdote of Manuel's turned into a universal rule | `c0c3530f-56c5-4eec-ae2f-949cebfc2e96` | `99996a3c` | 9 of 20 |
| F2. Mechanisms called conflicting from a summary, unread | `c0c3530f-56c5-4eec-ae2f-949cebfc2e96` | `9f50624c` | 10 of 10 |
| F3. The binding test contradicts itself | `c0c3530f-56c5-4eec-ae2f-949cebfc2e96` | `896ea769` | 2 of 20 |
| F4. The retired "shape the search" framing restated unflagged | `785efd6d-6cc5-45b5-a8b7-8e8996cc3e9b` | `832548a0` | 0 of 20 |

A moment with a base rate near zero cannot show that a change fixed it: a fix and no effect look the same. Add a moment here when a ticket labels a new failure and measures its base rate.

Add runs to an existing folder by running the same command again; numbering continues. A folder holds one moment, one `--thinking` and one `--patch`: a different one needs a new `--out`.

## Options that change what the model sees

- `--thinking keep|drop`: past thinking blocks are stored with empty text and a signature; `keep` (default) resends them as Claude Code does, `drop` removes them.
- `--ref`: the commit the clone checks out. The default, `auto`, is what HEAD pointed at in the session's checkout at the cut, from its reflog.
- `--model`, `--effort`: default to what the session used at the cut.
- `--memory <folder>`: replaces the memory the session held.
- `--keep-sandbox-note`: lets the model see the CLI's description of the Bash sandbox (see below).
- `--no-agents`: denies the Agent tool.

## What the copy is

`run` builds a template inside `--out`, then gives every run its own copy of it (`runs/NN/w/`), so no run sees another's writes:

- `repo/`: a clone of the factory with every branch, remote-tracking ref and tag, checked out at the cut's commit, with `origin` pointing nowhere and the main checkout's `.git/info/exclude` and git-excluded `.claude/agents/` copied in. The phase hook (`mode.sh`) is run over every prompt Manuel typed before the cut, so `.claude/state/mode` matches the session.
- `source.jsonl`: the transcript up to the cut, with every path into the repo, the session scratchpad and the memory folder rewritten to the run's own. The source transcript is never written.
- `memory/`: the MEMORY.md the session held at the cut, plus the memory files it indexes that have not changed since.
- `scratchpad/`: the session scratchpad's files last changed before the cut.
- `drift.txt`: every difference between what the session held and what the copy could rebuild. Read it: a file left out or changed since is a difference from the original.

Each run lands in `runs/NN/`: `all-text.md` (everything the model wrote), `final.md`, `tools.txt` (calls and errors), `meta.json` (outcome, turns, cost, refused calls with their full input), `repo-changes.txt` (what the run changed in its clone, which is then deleted), `w/memory` and `w/scratchpad` as the run left them, `hooks.jsonl`, `stream.jsonl`, and for the first run `api/`, the exact requests the model received.

## What keeps a replay sealed

A replay is a real model turn with real tools. These hold by construction; `replay.py selftest --out /private/tmp/qt-replay/selftest` proves them in a minute and must print `PASS` after any change to `replay.py` or `proxy.py`:

- Permission mode `dontAsk`: only reads, `Skill`, task tools, Bash, and Edit or Write inside the run's own folder are allowed. `gh`, `git push`, `curl`, WebFetch and WebSearch are denied.
- Bash runs in the CLI's OS sandbox with no network and writes only to its own run folder and the run's short temp folder. The CLI's own temp root `/private/tmp/claude-<uid>` is writable by default under its sandbox, so `--out` must be outside it (`run` refuses otherwise) and the settings deny it, along with `~/.claude`.
- No MCP servers; no session is saved; file checkpointing is off.
- Reads are open: a replay can read the main checkout and `~/.claude`, as the original session could.
- Hooks run unsandboxed. The repo's hooks write only inside the clone; the replay adds a logger that writes `hooks.jsonl` in the run folder.

`run` snapshots the source transcript, Manuel's settings and memory files, and the main checkout's HEAD, status and refs before the runs, and compares after. Files Claude Code writes under `~/.claude/projects/<key of a path inside the run folder>/` are moved into `claude-home-leftovers/`.

### Seal check

`seal-check.txt` gets one line per batch. These lines are not leaks:

- `backups/.claude.json.backup.*`, `sessions/*.json`, `shell-snapshots/*`: the CLI's own bookkeeping, written outside the sandbox, by replays and by any other Claude Code process running at the time.
- `refs changed in the main repository`: live sessions commit on their worktree branches, which share the main repository's refs; a replay cannot write there.
- `projects/<another run folder's key>/...`: another replay batch running at the same time; that batch moves its own files.

Anything else (a changed settings or memory file, a new transcript in the source project folder, a changed HEAD or status) is a problem to report before using the results.

## How a replay differs from the original

Measured, not assumed: `trial/results/*/request-facts.json` records what each arm's first request carried.

- **Sent message.** A moment replay adds a user message, `Continue.`, the same for every run.
- **GitHub.** Every `gh` call is refused, and a Bash command that contains `gh` anywhere is refused whole. The model then sees the refusal and often mentions it. A moment whose writing depended on reading GitHub is replayed blind to it.
- **Today's refs.** Branches other than the checked-out commit hold their current commits, which may postdate the moment.
- **Environment update.** Claude Code adds a system message after the sent message: the run's scratchpad path, MCP servers that disconnected, skills added since. `proxy.py` (a local pass-through every run goes through) removes three more things it would add: the Bash sandbox description, which the original sessions never had, "The date has changed", and a notice that any background agent running at the cut "didn't finish before the previous session ended". At the replayed moment that agent was still running; with the notice, the model restarted it and waited for it.
- **Hooks fire.** SessionStart fires with source `fork`; UserPromptSubmit, PreToolUse, PostToolUse, Stop and SessionEnd fire as in a live session.
- **Not reproducible**: uncommitted changes the checkout had at the time, scratchpad and memory files that changed after the cut, the live state of GitHub, background agents the original had running, and anything the session read from MCP servers.

## Cost

Runs do not share a prompt cache, because each run's paths differ. In the trial a run cost $0.07 to $1.40 at API list price, and ten runs at `--parallel 3` took 2 to 15 minutes, depending on how much tool work the moment did. On the subscription this is usage, not a bill. `meta.json` and `summary` carry the per-run figures.
