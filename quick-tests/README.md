# Quick tests

Three tests from the starting kit of #153 (decision 3), ready for a ticket on the map #146 to run on a writing change within the ticket: **say it back**, **outside the list** and **re-run an old subagent**. Replay (restarting a past session at a turn) is a separate tool on the branch `research/quick-tests`. This kit is workshop-only (#153 decision 10): it never goes under `template/`.

Each test answers a narrow question in minutes, and a result never has to pass for a change to ship (#153 decision 2). Post what you ran and what you saw on the ticket, or say why no test fit.

## Which test

- The change is to a brief, and the question is whether readers take it the way it was meant: **say it back**. Cheapest: about 20 seconds per reader.
- The change adds or removes an example list (things to check, cases to cover) in an open task: **outside the list**.
- The change would have altered what a past lane did, and you want to see it act: **re-run an old subagent**. Most faithful, slowest: a run takes as long as the original lane did.

## How every run is made

Every model call is a fresh `claude -p` session of the standalone Claude Code CLI bundled with the desktop app, on Manuel's subscription, never the API. `lib/qtlib.py` finds the newest bundled CLI; set `QT_CLAUDE` to pin one. Python 3, standard library only.

Each session runs in a **box**: a directory under `/private/tmp/wsbox/` holding `factory918/`, a fresh repository with one commit's history and no remote, and `scratchpad/`. The boxes are kept away from Manuel's world by construction, and each batch proves it afterwards:

- The environment is rebuilt from nothing (`env` is not inherited): `gh` has an empty config directory and no token, git sees no global or system config and so no credential helper, and auto-memory is off.
- `--settings` turns on the OS sandbox with no network at all and writes only inside the box; reads and writes of the main checkout, of this repository's transcripts and of the session scratchpads are denied, and `~/.claude` cannot be written. `--permission-mode dontAsk` denies anything not allowed, so nothing waits on a prompt. WebFetch and WebSearch are off.
- `--no-session-persistence` keeps the sessions out of `~/.claude/projects`; `--setting-sources project` loads the box repository's settings and none of Manuel's.
- After each batch, `safety.json` records a hash check of Manuel's settings, `CLAUDE.md` and memory files, the main checkout's `git status`, and a scan of the output for the account's email and ids. A tool exits non-zero on any problem. The repository is public: never push a trial whose safety check failed.

A run sees the box repository's `CLAUDE.md` and skills, as a lane did; it cannot reach GitHub, so a brief that says "read ticket #N" gets an auth error. Hooks are off in every run: a box session is a main session, so hooks a subagent never meets (SessionStart, UserPromptSubmit, the delegation guard) would fire. `rerun-subagent.py run --hooks` turns them on.

## Say it back

```
python3 quick-tests/say-it-back.py --brief before=old.md --brief after=new.md --intent intent.md \
  [--readers 5] [--at COMMIT] [--tools read|none] [--out DIR]
python3 quick-tests/say-it-back.py --from-agent AGENT_ID --at COMMIT [--intent intent.md]
```

1. Write each brief variant to a file, exactly as the lane would get it, and name each with `--brief NAME=FILE`. One variant is enough to check a single brief.
2. Write `intent.md`: what the writer meant by task, done, may change and must not. Without it you get agreement between readers but no check against the writer.
3. Choose `--tools`. `read` (the default) lets readers open files in a box at `--at` (default `origin/main`), which fits a brief that points at files; `none` reads the text alone, which fits a brief that carries everything.
4. Run it. Each reader gets the brief as its first message under a general-purpose lane's system prompt (`lib/lane-system-prompt.txt`), with an appended instruction not to do the task but to state the task, what done means, what it may change, what it must not, the choices left open, and its questions.
5. Read `DIR/report.md`. Done when you can say, per field, whether the readers converged on one reading and whether it is the writer's, and which open choices recur.

The trial, `trials/say-it-back-137/`: the #89 Standards brief before and after #137's wording change, 5 readers each, `--tools none`, 40 seconds. Before the change every reader read the reading limit, the run ban and the 400-word cap; after it, the "may change" and "must not" fields matched the intent for 9 of 10 field readings, and all five readers raised a new open choice: whether "read-only commands, such as ... the test suite" lets them run `build_knowledge.py` or `sync`, which write to the tree. That ambiguity is #137's own and was found by no review.

## Outside the list

```
python3 quick-tests/outside-the-list.py --with with.md --without without.md --list list.txt \
  [--runs 3] (--at COMMIT | --seed-from PREPARED_DIR) [--out DIR]
```

1. Write the brief with its example list (`with.md`) and the same brief without it (`without.md`). Change nothing else between them.
2. Write `list.txt`, one list item per line. When the list is lines of its own, the tool can take the lines `without.md` lacks; when it sits in a sentence, write it.
3. Choose the box. For a past lane's task, `rerun-subagent.py prepare` it first and pass `--seed-from` that directory: its restored inputs, its system prompt and its model come along, and `{BOX}` in a brief is filled in. Otherwise `--at` a commit.
4. Run it. Every run is a fresh session in its own copy of the box (`--mode work`, a lane's tools with Bash sandboxed, by default).
5. Read `DIR/report.md`. One blind judge pass over all runs of both briefs lists the distinct findings, marks which list item each one is, if any, and which runs found it. Done when you can say how many findings outside the list each brief produced, and whether the listed items were found more often with the list. `--judge-only` judges the runs under `--out` again, for a new judge model or after a failed pass.

The trial, `trials/outside-the-list-88/`: the run-2 blast-radius lane for #88 (`prepared/`), whose brief carried a 13-item "also examine" list, 3 runs per brief on the original's model (`claude-fable-5-1`), 10 minutes a run, all six in parallel. Both briefs produced 11 to 15 findings outside the list per run, and 19 distinct ones each across their runs: the list did not crowd out other findings. Without the list, 8 of the 13 items were found by no run, among them the two real bugs the list pointed at, the cached binary reused without a checksum (L3) and the glob that silently matches nothing (L11), which review rounds 1 and 2 of PR #96 found again. No run of either brief found the space-in-path bug that round 2 found, which may have come in with the round-1 fix rather than be present at `69bd412`.

## Re-run an old subagent

```
python3 quick-tests/rerun-subagent.py show    AGENT
python3 quick-tests/rerun-subagent.py prepare AGENT --at COMMIT [--branch NAME] [--input PATH] [--out DIR]
python3 quick-tests/rerun-subagent.py run     DIR --label NAME [--brief FILE] [--overlay DIR] [--runs 3]
python3 quick-tests/rerun-subagent.py compare DIR [--key key.md] [--rubric rubric.md] [--note note.md]
```

`AGENT` is an agent id, an `agent-<id>.jsonl` name or a path. Subagent transcripts are under `~/.claude/projects/-Users-manuel-Desktop-Work-Under-The-Sun-Collective-Core-918-factory918/<session>/subagents/`, each with a `.meta.json` (type, description, depth). Run 2 is session `b4a8ae9c-…`, 2026-09-22; `run-2-audits/program/postmortem/delegates.md` on the branch `research/run-2-audits` says what each of its lanes did and who caught what. The source transcript is copied, never changed.

1. `show` the agent. It prints the brief, the models, the files read and written, the commits the brief names, and what `main` was when it started. Pick `--at`: the commit the lane worked on, usually the head of the branch it was reviewing or writing.
2. `prepare` it into a new directory. It builds the **seed** (a box at `--at`, with `main` at main-as-it-was), and restores into it the inputs the original read that git does not hold: a file still on disk and unchanged since the original started, else what other agents of the same session wrote to it before then, else the original's own Read results. Every old path in the brief becomes `{BOX}/...`. Read the input list it prints: a `MISSING` line is either the original's own scratch file (ignore it) or an input the re-runs will lack (pass `--input PATH` if the brief abbreviated the path, or accept the gap and say so).
3. Write the change. Copy `DIR/brief.md` and edit the copy under the change, keeping the `{BOX}` paths. When the change lives in a file the lane read rather than in its first message (a brief a script wrote, a skill), put the changed file in an overlay directory at its path under the box root (`factory918/...` or `scratchpad/...`) and pass `--overlay`.
4. `run` the original brief under one label and the changed one under another, 3 runs each by default. Each run is a fresh session in its own copy of the seed, under the original's system prompt (its prompt snapshot plus its environment block, remapped), model and requested effort. It records `stream.jsonl`, `final.md`, the files it wrote under `written/`, and `output.md`, which is what the judge reads.
5. `compare`. Write `key.md`: numbered items the original found, missed, or that review found later. Optionally a `rubric.md` to score 0 to 3, and `note.md` with what the record says happened after. One blind judge pass covers the original and every run; the report shows each key item per output and how often it came back per label, the findings outside the key, and the launching agent's next steps (`original/after.md`).
6. Done when you can say, per label, how often each key item came back, against the original, and whether the change moved it.

The trial, `trials/rerun-89-standards/`: the #89 round-1 Standards reviewer, whose hard finding was that the posting command wipes the ticket body. Re-run 3 times unchanged (`original-*`) and 3 times under #137's change (`pr137-*`, from `change-137/`), on the original's `claude-opus-5` at medium. The body-wipe finding came back in 2 of 3 runs under each brief; the phantom-overlap finding in 0 of 3 unchanged and 2 of 3 under #137, as did more findings outside the key. Under #137 the runs took about twice as long (6 to 15 minutes against 3 to 5), and two of the three copied the whole repository into the scratchpad to run `build_knowledge.py` and `sync` there: the say-it-back trial's open choice, resolved by the reader. Three runs per brief cannot separate the two briefs; they show the tool runs and what its output looks like.

## Judging

Where a result needs judgement, one model judge reads every output of every variant in one pass, under blind ids, and never learns which variant produced which (#153 decision 8, the Eval playbook). It runs with no tools in an empty box. `blind-key.json` maps the ids back. The judge defaults to `claude-opus-5-5` at high effort; `--judge-model` changes it.

Each tool writes `judged-items.jsonl`, one judge call per line. Before trusting a judge on a kind of question, have Manuel label about 20 of them once:

```
python3 quick-tests/judge-agreement.py sheet DIR [DIR ...] --n 20 --out labels.md
python3 quick-tests/judge-agreement.py score labels.md
```

`sheet` writes the questions with blank answers and keeps the judge's answers in `labels.key.json`; `score` prints the agreement, Cohen's kappa and each disagreement. No such labelling has been done yet.

## What a run is not

A re-run differs from the original lane in ways a reader of its results needs to know:

- The CLI is today's (2.1.286), not the original's, and the session is a main session given the lane's system prompt with `--system-prompt`, not a subagent spawned by the Agent tool. The tool list is today's lane tool set, not the snapshot's.
- No GitHub: the ticket, PR and comment reads the original made fail. The original's own outputs for them are in its transcript (`original/trace.md` lists every call).
- The date in the session is today's.
- An input missing from the seed changes what the lane could see; `prepare` says which.
- The original's model may no longer be the factory's choice; `--model` overrides it, and the report should say which was used.
