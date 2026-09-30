PR #143 (a draft against `main`) is built but no reviewer run has happened. The runs need effort high, and this session can't get it.

I couldn't write the report to `.scratch/program/138/report.md` because the harness refused the file write. So the report is below.

## Why nothing ran

- **Every lane of this session runs at medium.** The root session was started with `--effort medium`, and each lane inherits that. This includes me, the writer and all the reviewers.
- **The pinned definitions can't be loaded yet.** Claude Code 2.1.280 reads an `effort` field in `.claude/agents/*.md`, but only loads the files when a session starts or on `/clear`. After I installed `review-upper-high.md`, the Agent tool still said `Agent type 'review-upper-high' not found`.
- **The other routes are closed.** The standalone CLI answers "Not logged in", and `set_session_effort` won't change the session it is called from.

So I stopped before spending any runs, as the brief said. No pilot ran and no Fable usage was spent.

## Status: UNFINISHED

- **Head:** `58b04584b187dd0980a9a7a5fe74615d632b2dad` on `feat/reviewer-eval-rerun`. `git ls-remote` shows the same.
- **Base:** I branched from `origin/feat/unled-review-briefs` at e710e99, per your override. #140 had merged by then, so the PR targets `main` and `Closes #138` links.
- **Conflict with `main`:** #135 merged after I branched, so the PR now conflicts in `DECISIONS.md`, its generated copy and `INDEX.md`. I did not rebase.

## Overlap

`overlap.sh 138` printed `base: origin/feat/eco-tier` (overlaps #135, #136 and #140 on `DECISIONS.md`). I did not use that base; I followed your override.

`overlap.sh 138 --diff` at the final head:
```
go: autopilot-stack
#142 feat/unreadable-writer-flags: docs/knowledge/INDEX.md docs/knowledge/core/DECISIONS.md template/docs/factory918/DECISIONS.md
```

## Criteria

| # | Criterion | State | Evidence |
|---|---|---|---|
| 1 | P103 and the M0 section marked void | Met | Dated lines give the reasons. They also say which removed fixtures the section names, and that those stay readable at e710e99. |
| 2 | Briefs regenerated, ground truth rebuilt | Met | `rebuild.sh` reproduces pr94-r1, pr96-r1 and pr99-r1 exactly. pr96-r1's Risks list is emptied; its heading stays because the fixed script requires it. `tests/eval/reviewer/truth` holds 14 hard bugs (6, 4 and 4), with proofs in `truth-notes.md`. |
| 3 | Every run at effort high | Not met | The refusal of any other effort is built and tested, but no run was possible. |
| 4 | Three arms, 3 passes each, six briefs, three models | Built, not run | `next` prepares 7 steps per brief and model. The Fable agent definition pairs with `model: "fable"` and must record `claude-fable-5-1`. |
| 5 | One table per model | Built, not run | The table's arithmetic is tested. |

Criterion 2, leading-witness check: the brief text and the runner prompt state no expected result, count, cap or reading limit. The grep hits all sit in the code under review, which stays as written.

Checks at the final head:
- `reviewer.py check` passes, and all 33 masked patch sets apply.
- `refusals.sh` passes 217 of 217.
- `rebuild.sh` is identical for all three rounds, and `fixes.sh` rebuilds all 10 patches identically.
- ShellCheck exits 0 over 27 files.
- The knowledge build and check pass.

## Reviews

All reviewers were Opus 5, at medium effort like every lane here.

| Round | What it reviewed | Result |
|---|---|---|
| 1 | Whole diff | [6 items to act on](https://github.com/Zenoctra/factory918/pull/143#issuecomment-5803915339) |
| 2 | Whole diff | [9 items to act on](https://github.com/Zenoctra/factory918/pull/143#issuecomment-5804140986) |
| 3 | Whole diff | [6 fixed](https://github.com/Zenoctra/factory918/pull/143#issuecomment-5804473487), including Would-break items, so round 4 was owed |
| 4 | Round 3's fixes only | [8 fixed](https://github.com/Zenoctra/factory918/pull/143#issuecomment-5804683465), including Would-break items, so round 5 was owed |
| 5 | Round 4's fixes only | [7 fixed but not reviewed again](https://github.com/Zenoctra/factory918/pull/143#issuecomment-5804809910) |

Round 5 still found a Would-break item, so I posted [a report for Manuel](https://github.com/Zenoctra/factory918/pull/143#issuecomment-5804810452) and the PR stays a draft. Nearly every round found a gap in the same two places:
- **The contamination check** decides "path" versus "pattern" by guessing from shell text, and each fix pushed that line one way or the other.
- **The receipt tests** were built from hand-written transcripts, which is how the real "session limit" wording got through.

The report proposes two remedies. One is to test against real transcripts from this machine: #103's 377 receipts plus lanes that ended on a limit or an API error. The other is to isolate reviewers in the lane itself, with a tool list without Bash or a sandbox, instead of parsing shell.

## CI

- Green on run 35926595211 (4182e1c) and run 35928530737 (734485c).
- No runs after that, because every later head conflicts with `main`.

## Records

- **P103:** marked void, with the reasons, and a note that the labels, rounds and routes it names are at e710e99.
- **P138 (new):** records how the re-run is built. Its result is marked pending.
- **M0, void line:** says what #138 removed and that `reviewer.py table` no longer rebuilds the old table.
- **M0, effort line:** effort in agent definitions only loads at session start or `/clear`, and the CLI isn't logged in.
- **M0, limit line:** records the harness's "usage limit", "session limit" and `API Error: 500` lines.
- **Ledger:** nothing added.

## Decided

- **Pass 1 is shared by the three arms.** Each chain is 7 runs instead of 9, and the arms are paired on the same first pass.
- **One chain per brief, arm and model.** That follows your "3 passes each on the six briefs". The audit sized for 4 chains per brief; adding them is a small change.
- **pr96-r1's Risks list is emptied, not given made-up dispositions.**
- **Only the three rounds are kept.** The labels, the other nine rounds, the historical reports and the Sonnet and Codex routes are deleted; git history keeps them.
- **Masking uses committed per-bug patches** applied with `git apply --3way`, because whole fix commits don't apply cleanly on their heads.
- **Contamination rules:**
  - Only Read, Write, Edit, Grep, Glob, Bash, TodoWrite and ToolSearch are allowed.
  - Bash is flagged for `gh`, `git`, `curl` or `wget`, a path outside the export, or `..`.
  - A token between two slashes counts as a pattern only if it holds a regex character or a space.
  - A run is given up after its third contamination or no-response dropout.
- **A usage limit pauses that model** until `next --resume` names it.
- **The three effort-high agent definitions** are installed in the main checkout's `.claude/agents/` and committed under `tests/eval/reviewer/agents/`. `check` verifies the installed copies match.

## Blocked

- **Effort high needs a new session that only Manuel can start.** Once he starts a Claude Code session in the main checkout, it loads the three definitions. That session then:
  1. Runs `git fetch origin 'refs/keep/103/*:refs/keep/103/*'` and `python3 tests/eval/reviewer/reviewer.py check`.
  2. Runs the pilot with `python3 tests/eval/reviewer/reviewer.py next claude:opus-5 claude:opus-5.5 claude:fable-5.1 --limit 3`. It launches each printed line through the Agent tool, then runs `collect`. `collect` refuses any receipt not at effort high, and each `receipt.json` holds that run's tokens.
  3. Runs `next --limit 8` and `collect` in batches until `next` prints nothing, then `table`. Output goes to `.scratch/eval/reviewer-138/`.
- **PAUSED:** all 42 Fable runs remain (6 briefs × 7 steps). When Fable hits its limit, `next` prints `paused claude:fable-5.1` and the Opus runs carry on. After the reset, `python3 tests/eval/reviewer/reviewer.py next --resume claude:fable-5.1` picks it up.
- **No pilot token figures exist yet.** The estimate is the audit's medium-effort receipts scaled by 1.5 to 2 for high effort, across 126 runs (42 per model):

| Model | Cache read per run | Output per run |
|---|---|---|
| Opus 5 | about 1.3M to 2.8M tokens | about 17K to 30K tokens |
| Opus 5.5 | about 0.65M to 1.1M tokens | about 5.5K to 10K tokens |
| Fable 5.1 | no earlier figures | no earlier figures |

- **Round 5:** the PR waits for Manuel's call on the round-five report.

## Trail

- `check-trail.sh` passed on `/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.scratch/program/138/decisions.tsv`, and I added more rows after the trail review.
- **The trail review is weaker than the rule asks.** It was done by Opus 5, the same model family as me, because Fable is off-limits outside the measurement. It is at `/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.scratch/program/138/trail-review.md`.
- **Its main flag was answered in the trail.** The flag was that I never tried raising another session's effort. A row now records why that can't give this lane high-effort reviewers.

Principles that shaped the work:
- **Subtract before you add:** the void fixtures and routes were deleted before the arms were built.
- **Model the domain:** a step table drives which runs wait for which.
- **Build the lever:** `fixes.sh` and `check` prove the patches instead of a hand check.
- **Fix root causes:** round 3's look found the hand-written test transcripts as the common cause.
- **Never block on the human:** the PR went out as a draft, and only the effort block is handed up.

Files:
- `/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.claude/worktrees/agent-af1a10e904a9448aa/tests/eval/reviewer/` holds `reviewer.py`, `refusals.sh`, `rebuild.sh`, `fixes.sh`, `truth`, `truth-notes.md`, `agents/` and `rounds/*/fixes/`.
- `/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.claude/agents/` holds the three installed `review-*-high.md` definitions.

## Update 2026-09-24: the content check

The runner now judges contamination by what a run's tool results hold, not by parsing its shell commands. It passes 40 of 40 labelled real transcripts, including the pr96-r1 run that fetched live #88.

**Head.** `cb700ccb2197398e8207d1a01c13dd7be201b6d4` on `feat/reviewer-eval-rerun`, pushed. `git ls-remote` shows the same. There was no rebase. The PR still conflicts with `main` in the records files.

**Commits.**
- `603aea6`: the labelled corpus (`tests/eval/reviewer/contamination-cases`) and `tests/eval/reviewer/corpus.sh`. They were committed before the check existed, and the test failed at this commit.
- `9887a0d`: the content check replaces the Bash tokenizer (`bash_reaches` and the path and pattern rules are gone). Each run keeps its brief and diff under `given/`, and `collect --recheck` re-judges collected runs.
- `70ba03d`: live GitHub text counts as future text. The receipt records the first contaminated call, the earliest call per finding, and outside paths.
- `cb700cc`: P138 now describes the rule.

**The rule.**
- **Contaminated by content.** A tool result holds a line that the run was not given, taken from one of two sources:
  - A commit reachable from `refs/keep/103/*` or `origin/main`, not reachable from the head, and committed after the head. Rebased PRs carry their later code only on `main`. With descent from the head alone, 5 of the 10 future cases would be missed.
  - The live ticket or PR bodies and comments, minus the round's frozen `inputs/`. They are fetched once with `gh` and cached. Without a cache or network, the check refuses and names the command to run.
- **What "given" means.** The run's own tree (the head or the masked commit) plus its brief and diff. The brief's wording is newer than the head and never counts.
- **Length floor: 12 characters after stripping.** Generic lines are dropped. One hit contaminates. On the #103 corpus, every floor from 1 to 56 separates the 10 runs that read later code from the other 223. The tightest case is one 57-character line, so 12 leaves a wide margin and skips short tool output.
- **Tool-name check.** Kept only for `Agent`/`Task`, whose reads land in another transcript, and `WebFetch`/`WebSearch`, which return live network state. Bash and Skill go through the content check. `gh` needs no rule of its own, since live GitHub text is covered by content.
- **Records that change no verdict:**
  - The first contaminated call, as a 1-based ordinal and a timestamp.
  - For each report item, the earliest call whose result already held its quoted lines.
  - An `outside` list of calls that named a path outside the export.
- **The table** reports, per model, how many contaminated runs were excluded from recall.
- **Rule 1 holds.** No prompt, agent definition or settled text tells a reviewer what it may not read or run. The one phrase to consider is "run read-only commands", which `review-brief.sh` writes and this ticket does not own.

**Tests against real transcripts.**
- `corpus.sh`: 40 of 40 match their label. The cases are:
  - the 18 runs #103 marked contaminated;
  - `claude-sonnet/pr96-r3/spec/1`, which #103 scored clean although it read the later `shellcheck.sh`;
  - 20 clean runs across models and rounds;
  - the new `agent-a7282a4eeee51f4d4` run.
- **The a7282a4 call number.** It comes out contaminated at **tool call 14, not 32**. I re-counted the transcript myself: counting tool_use blocks from 1, it makes 29 calls. `gh issue view 88` from the export is call 13, which failed because the export has no git. From my worktree it is call 14, at JSONL line 69, and returned live #88. The run's gate runs at calls 8 to 11 came before call 14, but it ran the gate again at calls 15, 23 and 24. The test pins 14. If "32 and 33" counted something else, name the rule and it gets re-pinned.
- **The 7 other batch transcripts are not in the corpus yet.** The root has not named them.
- **The pilot runs.** Their directories under this worktree's `.scratch/eval/reviewer-138/runs/` had only `run.json` when I looked, so there was nothing to re-check yet. Once collected, `python3 tests/eval/reviewer/reviewer.py collect --recheck` re-judges them.

**Verification at `cb700cc`:**
- `refusals.sh`: 231/231.
- `corpus.sh`: 40/40.
- `reviewer.py check`: exit 0, with 33 masked subsets.
- `rebuild.sh`: identical for pr94-r1, pr96-r1 and pr99-r1.
- ShellCheck: exit 0 over 28 files. AGENTS.md now says 28 and lists `corpus.sh`, which skips in CI.
- `build_knowledge.py` and `check_knowledge.py`: ok, 119 files.
- `provisional-ids.sh`: 26 passed.
- `no-stale-wording.sh`: ok.
- CI has not run: the PR conflicts with `main`.

**Open.**
- The GitHub cache is a snapshot. A comment posted after the first fetch is unseen until the cache file is deleted.
- The future-commit filter uses commit timestamps. A commit dated before the head, on a branch merged later, does not count as future.
- These commits have not been through spec-review. The PR's five rounds ended before them, and P20 allows no sixth round, so this change waits on Manuel with the rest of the PR.

## Update 2026-09-24: frozen ticket and grounding in every export

Each run's export now carries the round's frozen ticket, and the PR's grounding where the round has one, and the prompt points at them in one sentence that forbids nothing. Reading them is clean under the content check.

**One mistake the root must act on.** When I cleaned up my own probe I removed the whole shared `$TMPDIR/review-work` directory (`/var/folders/94/565lnnsj5vq_0rjn4ntgzq900000gn/T/review-work`), not just my probe's subdirectory. That directory also held the exports of any runs the root had prepared, including the three held reruns: opus-5/pr94-r1/standards, opus-5.5/pr96-r1/standards and fable-5.1/pr96-r1/standards. Their `run.json` now points at checkouts that no longer exist. They were prepared before this change, so their exports lack `ticket.md` and their prompts lack the new sentence; they need preparing again either way. The fix is to remove those three run directories under `.scratch/eval/reviewer-138/runs/` and run `next` again. If any run was in flight when I did this, its checkout is gone too, and it should be treated the same way.

**Head.** `5f270e09ea865b47847787520907ec0df66b686f` on `feat/reviewer-eval-rerun`, pushed. `git ls-remote` shows the same. No rebase.

**What changed (commit `5f270e0`).**
- **Files.** `materialize` copies `inputs/ticket.md` into every export as `.scratch/review/<base>/ticket.md`, beside the brief. `inputs/blast-radius.md` goes in the same way as `blast-radius.md`, where the round has one: pr96-r1 has one, pr94-r1 and pr99-r1 do not. The masked arm's export gets the same files.
- **Prompt.** One sentence is added. For pr96-r1 it reads "The ticket as it stood at this commit is `<dir>/ticket.md`, and the PR's grounding is `<dir>/blast-radius.md`." For pr94-r1 and pr99-r1 it names only `ticket.md`. It forbids nothing, and the BANNED word check passes.
- **Briefs.** Unchanged. `rebuild.sh` still reports identical for all three rounds.
- **Content check.** Both files join the given set, so reading them is clean.

**Verification.**
- `refusals.sh`: 236 of 236 pass. The new cases:
  - the exact prompt;
  - `cmp` of both exported files against `inputs/`, the masked export included;
  - a later line that the exported ticket holds is not a hit;
  - the real-round prompts.
- I ran it myself too: 236 of 236.
- A real `next` for opus-5.5 printed this pr96-r1 standards prompt: "Read `<export>/.scratch/review/ab47eb9/standards-brief.md` whole and follow it. You are working in `<export>`; every relative path in the brief is relative to it. The ticket as it stood at this commit is `<export>/.scratch/review/ab47eb9/ticket.md`, and the PR's grounding is `<export>/.scratch/review/ab47eb9/blast-radius.md`." Its exported `ticket.md` is byte for byte `tests/eval/reviewer/rounds/pr96-r1/inputs/ticket.md` (`cmp`).
- `corpus.sh`: 40 of 40.
- `reviewer.py check`: exit 0.
- `rebuild.sh`: identical for all three rounds.
- `fixes.sh`: 10 identical.
- ShellCheck: exit 0 over 28 files.

**Still open.** The PR conflicts with `main` in the records files, so CI has not run on these heads. These commits came after the PR's five review rounds, so they are unreviewed and wait on Manuel with the rest of the PR.

## Update 2026-09-24: per-run scratch folder and the cross-run check

Every export now has its own `.scratch/work/` folder, and the prompt names it. A read of another run's files now marks a run contaminated. The pr94-r1/spec/S2 give-up turned out not to be a cross-run read: all three attempts read only scratchpad files they had written themselves. What contaminated them was two short Markdown headings from live #42, the worked example the frozen ticket points to.

**Head.** `897125ea71676e1e5353b7a5a4ab05020f6bfabf` on `feat/reviewer-eval-rerun`, pushed. `git ls-remote` shows the same. No rebase. `collect --recheck` can run on it now.

**Commits.**
- `75e8fbc`: `<export>/.scratch/work/` is created in every export, the masked one too. The prompt adds "Your scratch folder for notes and any files you make is `<export>/.scratch/work/`." The root's wording "test files" was changed because "test" is a BANNED prompt word. The sentence forbids nothing. The new `cross-run read` gate flags a Read, Grep, Glob or Bash call that names a path under the session scratchpad, or under another run's export, which this run did not write first.
- `32064f7`: the three pr94-r1/spec/S2 attempts, labelled clean from their transcripts. It was committed first, so corpus.sh failed at this commit.
- `4404972`: Markdown headings and `#` comments of up to three words no longer count as dated text. This clears "## Testing decisions" and "## Scenario table", the #42 headings.
- `897125e`: a run that was prepared before exports carried `given/` no longer gets the frozen ticket in its given set. It never had the ticket.

**How the gate treats a file as the run's own.** A file counts as the run's own once one of the run's calls has written it:
- a Write or Edit;
- a Bash redirect, or `tee`, `mkdir`, `cp`, `mv`, `touch`, `ln`, `rsync`, `tar`, `unzip`, `git init` or `git clone`.

Anything under an owned path is also owned. `NAME=value` assignments in the same command are expanded first, which covers the `S=.../scratchpad/rv89; cd $S` pattern. `/tmp` and `/private/tmp` are treated as one path.

**Test outcome.**
- The three pr94-r1/spec/S2 attempts (`agent-a8fccf18792dcf649`, `agent-accc4fbc1a5454840`, `agent-afa3d13c6b600ac71`): each is labelled clean and now checks clean. Each read only the `rv89`, `r89` or `i42.md` files it had made itself. Before `4404972` each was flagged, at calls 26, 15 and 20, on the #42 headings.
- One clean collected run, `claude-opus-5/pr99-r1/spec/1` (`agent-af5c0a9bbe823acbb`): labelled clean, checks clean. It read back diff slices it had written to the scratchpad.
- Across every #138 transcript collected or dropped so far, the gate found 0 cross-run reads.
- `corpus.sh`: 44 of 44. `refusals.sh`: 250 of 250, including:
  - flagged: another run's scratchpad file (by Read, and by its `/tmp` name from Bash), another run's scratchpad folder (by Grep), and another run's export;
  - clean: the run's own writes read back, and reads inside its own `.scratch/work/`.
- I ran both myself on the merged head.
- `check`: exit 0. `rebuild.sh`: identical for all three rounds. `fixes.sh`: 10 identical. ShellCheck: exit 0 over 28 files.

**What `collect --recheck` will change.** This is from a read-only survey; nothing under the output directory was changed.
- Six Opus 5.5 pr94-r1/spec receipts go from contaminated to complete: the given-up `S2` in `runs/`, plus the dropped `I3/1`, `M2/1`, `M2/2`, `S2/1` and `S2/2`.
- A dropped receipt comes back only when its report is still there and its `runs/` slot is free.
- Every other contaminated receipt stays contaminated: the live #88 reads on pr96-r1 standards, the #89 and #90 ticket text on the Standards runs prepared before exports carried the ticket, fable `pr99-r1/spec/1`, and opus-5.5 `pr99-r1/spec/I2/1`.

**Hazard the gate cannot see.** Runs launched before `75e8fbc` reused the same scratchpad folder names: `rv89` in 3 runs, `probe` in 5, `sync` in 4, and others. A sibling that `rm -rf`s and recreates such a folder can swap its contents under a running run, and that run still "wrote it first". The per-run `.scratch/work/` sentence removes the cause for runs launched from now on.

**Next.** The answer-key fix Manuel approved is in progress in the same writer lane, as new commits after `897125e`. I will add it here when it lands.

## Update 2026-09-24: the answer key fixed and every collected run re-scored

Manuel approved the fix on 2026-09-24 ("go ahead and fix the answer key"). The ground truth now marks each bug hard or non-hard, the audit's four mis-credits are fixed, and the table separates bugs filed hard from bugs found at all. No run was changed; only the scoring was redone.

**Head.** `c8aca57f023d7977f8ee173dadb9f76499bba5e2` on `feat/reviewer-eval-rerun`, pushed; `git ls-remote` shows the same. No rebase.

**What changed (`c8aca57`).**

- **Truth file.** `truth` gains a class column (`hard` or `nonhard`), and the loader refuses any other value.
  - pr94-r1 G3, G4 and G6, and pr96-r1 G3, are now `nonhard`.
  - pr94-r1 G5 stays in the file as `nonhard`. The notes call it designed behaviour: the loud refusal. Filing it hard counts as over-rating.
  - pr94 G2, pr96 G4 and pr99 G1 stay `hard`. `truth-notes.md` gives both readings of each.
  - `truth-notes.md` carries the dated line quoting Manuel and naming `.scratch/program/answer-key-audit/report.md`.
- **Masked arm.** A fix patch follows the filing, not the class: it applies when an earlier pass filed the bug hard. Every masked run already collected was built on that rule.
- **The four mis-credits.** Anchors are tighter for pr94 G5, pr96 G4, pr99 G2 and pr94 G1. Each report item now claims at most one bug, and hard items claim first. The "demoted" count is gone. `refusals.sh` scores each of the four audit items from its verbatim report text:
  - opus-5 pr94-r1/spec/1#4 goes to G6, not G5.
  - opus-5 pr96-r1/standards/1#1 goes to G4, not G1.
  - opus-5 pr99-r1/standards/1#1 goes to G4, not G2.
  - fable-5.1 pr94-r1/standards/1#3 goes to no bug.

  Over all 391 items on the three rounds, no historical or #103 item changed its match.
- **Table.** One table per model and axis. The columns are:
  - hard bugs filed hard;
  - hard bugs found (under any heading);
  - non-hard bugs found;
  - non-hard bugs filed hard, which is over-rating;
  - new found per pass;
  - other hard items and context failures;
  - tokens, wall clock and exclusions.

  On the Standards axis "hard bugs found" is the headline, with "filed hard" next to it and a footnote naming #144. The frozen briefs are unchanged.

**Re-score.** The old scorer (`897125e`) and the new one (`c8aca57`) ran on the same copy of the runs, taken at 20:45 CDT, and `table` was then rebuilt in `.scratch/eval/reviewer-138/`. `collect --recheck` changes nothing the table sees. The writer's `done14` holds both full tables (`.scratch/program/138/writer/done14`).

Pass 1, pooled over each model's six briefs:

| model | old hard hits | hard bugs filed hard | hard bugs found | non-hard filed hard |
|---|---|---|---|---|
| Opus 5 | 1.50 | 1.00 | 1.33 | 0.50 |
| Opus 5.5 | 0.50 | 0.50 | 0.83 | 0.00 |
| Fable 5.1 | 0.67 | 0.33 | 0.83 | 0.33 |

- **Opus 5.** Three of its nine old hits were non-hard bugs filed hard. It still leads on both hard measures, and it over-rates the most.
- **Opus 5.5.** Its old "demoted" finds now count as hard bugs found. It over-rates only in later passes: G6 on spec, and pr96 G3 once.
- **Fable 5.1.** Two of its four old hits were non-hard bugs filed hard, and it loses the mis-credited pr94 G1. It is now below Opus 5.5 on filed hard and ties it on hard bugs found.
- **Standards axis.** Hard bugs found at pass 1: Opus 5 1.67, Opus 5.5 1.33, Fable 5.1 1.33.

**One prepared run is out of step.** `runs/claude-opus-5/pr96-r1/standards/M2` was prepared with `unmatched-glob.patch`. The new scorer would apply `bare-gate.patch` instead, because it credits the pass-1 item to G4. The item itself asks for G1's fix, so the prepared tree is what an author would build. I kept it. Opus 5 now leaves the measurement anyway (next step).

**Verification at `c8aca57`, which I reran.**

- `refusals.sh`: 265 of 265.
- `corpus.sh`: 44 of 44.
- `check`: exit 0.
- `rebuild.sh`: identical for all three rounds.
- `fixes.sh`: identical.
- ShellCheck: exit 0 over 28 files.

**Next.** Following the root's reorder: Opus 5 leaves the measurement, and GPT-6 Sol gets a Codex route. After that come the Sol pilot and Sol's full chains.

## Update 2026-09-24: Manuel's ruling on two Fable runs

Manuel ruled that `claude-fable-5.1/pr96-r1/spec/I2` and `S2` count as normal runs. Both were flagged only for web fetches. Every page they fetched was public documentation, used to check which ShellCheck version the CI runner has: GitHub's actions/runner-images README, its `install-shellcheck.sh`, and the Arch Linux shellcheck package page. None of it came from this repository, its tickets or its PRs. He asked for no change to the test definition or the contamination check, so this is a data change only; there is no code commit for it.

**What was done** (`.scratch/138/count_fable.py` in the owner's worktree):
- Each flagged attempt moved from `dropped/.../spec/<step>/1` back into its `runs/.../spec/<step>` slot, with its report.
- That slot had held a re-prepared, never-launched run. The re-prepared run moved to `dropped/.../spec/<step>/unlaunched-reprep`, and nothing was deleted.
- Each receipt now reads `status: complete`. Its detail starts with the ruling, followed by the check's original verdict.
- `table` was rebuilt, and Fable's spec table now counts both runs. For example, I pass 2 has 3 chains, and S pass 2 has 3 chains with 0.67 hard bugs filed hard.

**Caution.** `collect --recheck` judges every run again from its transcript. It would flag these two again, because WebFetch is an undated tool. After a recheck, run `count_fable.py`'s edit again, or keep these two out of the recheck.

## Update 2026-09-24: Opus 5 retired, GPT-6 Sol added, and two notes from the root

**Head.** `f2cbc01` on `feat/reviewer-eval-rerun`, pushed. It is one writer commit on `c8aca57`. `refusals.sh` passes 316/316 and `corpus.sh` 44/44. I reran both on the merged head.

**Opus 5 retired.**
- `next claude:opus-5` prepares nothing and says the model is retired. Its collected runs stay in the table, labelled "partial (pass 1 and some pass 2; retired 2026-09-24)".
- `next` set aside 7 root-stopped Opus 5 runs under `dropped/`, each with the detail `retired: stopped by the root`. `collect` never collects them. Only 7 matched "prepared, no receipt", not 8; the eighth already had a receipt.

**The Sol route (`codex:gpt-6-sol`).**
- **Command.** `codex exec -m gpt-6-sol -c model_reasoning_effort="high" --sandbox workspace-write -c sandbox_workspace_write.network_access=true --skip-git-repo-check --cd <export> --json <prompt>`.
- **Same inputs as Claude.** It gets the same export, prompt, frozen ticket, `.scratch/work/` folder and report path as a Claude run.
- **Receipt.** The model and effort come from the session log's `turn_context`. A wrong model, or any effort other than high, is refused. Tokens (cached and reasoning shown apart) and wall clock also come from the log.
- **Checks.** Codex tool calls are mapped into the transcript shape the content, cross-run, sightings and outside checks already read.
- **Pauses.** A usage-limit message pauses the model until `--resume`. A run that ends with no answer counts as `no-response`.
- **Launching.** `next codex:gpt-6-sol --run` launches runs itself, at most 4 at once, and collects them.
- **Sandbox caveat.** Workspace-write leaves `$TMPDIR` writable, so a Sol run could write into a sibling export. The cross-run check catches reads of another run's files, not writes.
- **Test data.** The only Codex call made for the tests was one smoke call on gpt-6-sol. Its log recorded model `gpt-6-sol` and effort `high`, and a trimmed copy is the test fixture.

**Root note 1: the Fable I2 and S2 re-preps.** `next` re-issued `claude-fable-5.1/pr96-r1/spec/I2` and `S2` as fresh, unlaunched run directories (exports `5600f527fd54` and `3ad4db461d49`). The root will not launch them. Under Manuel's ruling the original collected runs are the ones scored. My `count_fable.py` moved the fresh directories to `dropped/.../<step>/unlaunched-reprep` and put the originals back in the `runs/` slots, marked complete.

**Root note 2: exports can reach this worktree.** Fable `pr99-r1/spec/M2` was rightly flagged.
- **What it did.** The reviewer `cd`'d into this worktree (`.claude/worktrees/agent-af1a10e904a9448aa`), ran `git archive` of 69bd412 into the session scratchpad, and ran `git log` there. That showed it HEAD `c8aca57`, the answer-key commit.
- **What caught it.** The content check flagged it, and the root relaunched the run fresh.
- **The standing risk.** An export sits outside any repository, but a reviewer can still reach the owner's worktree, or any checkout, by its absolute path. Nothing structural prevents that. The content check is the guard: whatever later text such a read returns contaminates the run. The outside-path record keeps a list of such reads, but it does not exclude a run on its own.

**Sol pilot.** Started at the time in `.scratch/program/138/sol-started`, with `next codex:gpt-6-sol --run --limit 1`. It launched `codex-gpt-6-sol/pr94-r1/standards/1`. Its tokens, wall clock and effort go in the next update.

## Update 2026-09-24: Sol pilot result, and the full Sol run started

The pilot ran at effort high, came out clean under the content check, and filed one ground-truth bug hard. The remaining Sol chains are running now, 4 at a time.

**Pilot: `codex-gpt-6-sol/pr94-r1/standards/1`.**
- Status `complete`. `first_contaminated` is empty. The content check and the cross-run check both passed.
- The log reports model `gpt-6-sol` and effort `high`.
- Wall clock: 204 s.
- Tokens:
  - input (uncached): 90,433
  - cache read: 1,359,104
  - output: 7,772, of which reasoning: 4,441
- Findings: pr94-r1 G4 (non-hard in the corrected key), filed hard. No other hard items.
- The outside-path record has one entry, at call 16, a Bash pattern `/(technical-writing|unslop)/SKILL.md$`. It is a record, not an exclusion.
- Session log: `~/.codex/sessions/2026/09/24/rollout-2026-09-24T21-15-58-01a0d659-1896-78d1-9a03-65c646b31cb0.jsonl`.

**Full run.** `.scratch/138/sol-all.sh` in the owner's worktree repeats `next codex:gpt-6-sol --run --limit 42` wave by wave. Each wave launches every ready run, at most 4 at once, and collects it. The script stops when a wave launches nothing, or pauses on a usage limit. Its log is `.scratch/138/sol-all.log` in the owner's worktree. The result table follows when Sol's chains complete.

## Update 2026-09-24: Fable M3 counted, and the scratchpad leak path

**Fable `pr96-r1/spec/M3` counted.** Manuel's ruling for I2 and S2 now covers this run too: its only web fetch was the public actions/runner-images `Ubuntu2404-Readme.md`. `count_fable.py M3` moved its set-aside attempt back into its `runs/` slot, marked it complete and put the ruling in the detail. It also parked the re-issued, unlaunched copy (export `b09eb6a0080a`) under `dropped/.../M3/unlaunched-reprep`.

**The last two Fable runs.** The root launched `pr99-r1/spec/M3` (export `681a9d24413c`) and attempt 3 of `pr94-r1/spec/M3` (export `77cd5d78894e`). The root collects them.

**Leak path: Fable writes into the shared scratchpad.** Fable reviewers keep writing into the harness's session scratchpad even though the prompt names their own `.scratch/work/` folder. The harness names that scratchpad to every subagent, so runs of the same round leave files there for each other. Attempt 2 of `pr94-r1/spec/M3` was flagged this way: it `cd`'d into the shared scratchpad and read files earlier runs had left.

The cross-run check catches a read of a file the run did not write. It cannot catch content that a sibling swapped into a folder the run itself created. The folder names repeat across runs: `rv89`, `probe` and `sync` appear in several.

Sol runs are not exposed to this. Codex is not given the harness scratchpad, and its sandbox confines writes to the export and `$TMPDIR`. The one gap on the Sol side is that a Sol run could still write into a sibling export under `$TMPDIR/review-work`.

## Update 2026-09-24: Sol paused on the ChatGPT usage limit, and the own-report false alarms counted

Sol's chains are not complete. The ChatGPT account hit its Codex usage limit after 20 Sol launches, and Codex gives the reset as "try again at Sep 25th, 2026 1:45" (the machine's local time). The seven false alarms are counted and their chains carried forward, as Manuel asked. Nothing was rerun.

**Head.** `fde13312eb34fad4854c49f249ae10484a999813` on `feat/reviewer-eval-rerun`, pushed; `git ls-remote` shows the same. `refusals.sh` 318/318 (rerun by me), `corpus.sh` 44/44, and ShellCheck 28 files, exit 0.

**False alarms.** Sol proof-reads its own report (`cat .scratch/review/ab47eb9/standards-report.md`), and the check flagged its own "spec: criterion N" lines, because commit cc36280 later added the same text. Commit `fde1331` skips a call that only reads the run's own report or a file in its own `.scratch/work/`. The seven flagged attempts cleared. The latest attempts of `pr94-r1/spec/1`, `standards/S2` and `standards/M2` went back into their slots, and each came out complete. `standards/I2` keeps its complete retry. The earlier `/1` attempts stay set aside and still count as excluded.

**Sol so far** (the writer's `done16` has both tables):

| axis | pass 1 chains | hard bugs found, pass 1 | hard bugs filed hard, pass 1 |
|---|---|---|---|
| spec | 3 | 0.67 | 0.67 |
| standards | 3 | 0.67 | 0.67 |

Some pass 2 runs are in; no pass 3 run has started.

Mean per run:
- spec: 5.5K output tokens, 1.16M cache read, 152 s;
- standards: 6.1K output tokens, 1.15M cache read, 169 s.

**Waiting on the reset.**
- Four runs are prepared and unlaunched: pr99-r1 spec I2, M2 and S2, and pr99-r1 standards M2.
- Four hold usage-limit receipts: pr96-r1 spec M2 and S2, and pr99-r1 standards I2 and S2.
- The rest of pass 2 and all of pass 3 follow them.
- After Manuel resets or the limit clears, one command resumes it all. Run it in the owner's worktree, and repeat it until it launches nothing, or rerun `.scratch/138/sol-all.sh` after adding `--resume codex:gpt-6-sol`:
  ```
  python3 tests/eval/reviewer/reviewer.py next --resume codex:gpt-6-sol --run --limit 42
  ```

**Recheck caution.** A `collect --recheck` flags Fable `pr96-r1/spec` I2, S2 and M3 again, because they made WebFetch calls. That would undo Manuel's ruling. The writer's recheck did exactly that, and the writer re-applied the ruling. After any recheck, rerun `python3 .scratch/138/count_fable.py`'s receipt edit, or leave those three out of the recheck.
