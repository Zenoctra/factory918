# Where subagent tokens go after first real work

Two things drive most of the spend: 18 long-lived lanes whose context passes 300K, and cache rewrites caused by waits longer than five minutes. Rereading the same files and rerunning unchanged commands turned out to be rare.

The 18 long-lived lanes are the two root sessions, the owners, and one #138 writer. They are 2% of lanes but 37% of the cost. Waits longer than five minutes let the prompt cache expire, so the whole context is written again at 1.25 times the input price. That adds 13% to total spend, almost all of it in owner polling loops.

This report follows `grounding-report.md`, which covered the stretch before first work.

## Data and method

**Data.** The same 799 lanes, plus the two root sessions: 48857ffb (768 turns, 2026-09-23 to 09-25) and b4a8ae9c (187 turns, 09-22). New scripts, all in this folder:

| script | what it does |
|---|---|
| `life.py`, `lifedrv.py` | Whole-life token accounting per lane. Writes `lifes.jsonl` and `callsfull.jsonl`. |
| `q1.py` | The tables in section 1. Writes `q1.md`. |
| `cache.py` | Cache rewrites. |
| `rep.py`, `reread.py` | Repeated calls and rereads. |
| `cross.py` | Cross-lane duplication. |

**How context tokens are attributed.** For each turn, the context is `input + cache_read + cache_write` from its usage record. Growth to the next turn is split in two:
- the model's own output for that turn, capped at the growth;
- that turn's tool results and incoming messages, split by size.

Each piece of growth is then charged once per later turn it rides along in: its **carried cost** is its size times the number of later turns, up to the end of the lane or a compaction. Floor plus carried pieces reproduces each lane's summed per-turn context exactly: 0 of 801 transcripts are off by more than 5%.

Two corrections were needed:
- Zero-usage assistant records are dropped. These are API-error placeholders; left in, they faked a compaction in the root.
- A single-turn context dip is ignored.

**Price weighting.** Where it matters, tokens are weighted by the standard ratios: cache read 0.1, cache write 1.25, uncached input 1, output 5. Every weighted figure below uses those ratios. Across everything:

| | tokens | share of tokens | share of weighted spend |
|---|---|---|---|
| total | 2,976M | 100% | 100% |
| cache reads | | 94.5% | 50% |
| cache writes | | 4.8% | 32% |
| output | | 0.64% | 17% |

Weighted spend by role:

| role | share of weighted spend |
|---|---|
| owner | 23% |
| reviewer-eval harness | 21% |
| writer | 16% |
| verifier | 11% |
| reviewer | 11% |
| root | 9% |
| architect | 4% |

## 1. What makes up the tokens after first work

The table shows each role's summed per-turn context from the milestone to the end of the lane, and what that context consists of:

- **floor**: the lane's turn-0 context;
- **pre-work**: everything read before first work;
- **own output**: the model's own output, which is mostly its tool inputs: file contents in Write and Edit, heredocs, Agent prompts, long commands.

| role | lanes | input after first work | output | floor | pre-work | file reads | diffs | saved-output reads | test/check output | gh | subagent launches and results | own output | other |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| owner | 18 | 568M | 1.79M | 15% | 25% | 13% | 3% | 1% | 3% | 1% | **12%** | **22%** | 5% |
| writer | 70 | 503M | 2.43M | 24% | 27% | 4% | 1% | 2% | **8%** | 0% | 0% | **24%** | 10% |
| verifier | 73 | 403M | 2.48M | **47%** | 5% | 12% | 7% | 4% | 5% | 3% | 0% | 12% | 5% |
| reviewer | 206 | 240M | 2.97M | **48%** | 14% | 12% | 8% | 5% | 2% | 1% | 0% | 7% | 3% |
| reviewer-eval | 352 | 464M | 4.93M | 41% | 22% | 6% | **17%** | 7% | 1% | 0% | | 6% | 0% |
| architect | 36 | 89M | 1.68M | 41% | 10% | 18% | 0% | 5% | 6% | 2% | | 16% | 2% |
| root | 2 | 401M | 0.62M | 16% | | 18% | 2% | | 3% | 5% | **17%** | **34%** | 5% |

The full table, with grep, git, polling, skill text and nested memory in separate columns, is in `q1.md`.

- **Tool results are a minority of what gets re-sent.** For every role, the floor, the pre-work reading and the model's own output make up 50 to 70% of the context re-sent after first work. Output tokens are 0.2 to 1.9% of the tokens, but 17% of the weighted spend.
- **Where the tool results go, by role:**
  - Reviewers put most into diffs and saved-output reads.
  - Writers put most into test and check output.
  - Owners and the root put most into lane outputs and task notifications.
  - Polling loops, grep, git and gh are small everywhere, at 0 to 5%.
- **The model's own output is a quarter to a third of owner, writer and root context.** Most of it is tool inputs, not text or visible thinking: heredoc briefs, file bodies, and Agent prompts. The root wrote 179 Agent prompts totalling 127K characters. Little of this can be cut without cutting the work itself.

## 2. Repeated work

- **Rerunning an unchanged command is rare.** Across 21,698 calls, the same call with the same output happened again only 102 times. Those repeats added 20K tokens and 0.6M carried: negligible.
- **Rereading unchanged content is rare.** A reread is counted only for the same file and range, or after an earlier whole read that was not truncated, with no state change in between. There were 18 such rereads, costing 2.5M carried. Two reviewers account for most of them: a505aeac75c1cb897 and a81886aa4fc6ab875 each read the same ranges of the diff several times.
- **A looser count misleads.** Counting any second read of a file finds 1,800 "rereads". Almost all of them are paging through a file bigger than Read's cap, or a Read that follows a `cat` whose output was cut off and saved to a file. Neither is waste.
- **Tests are rerun a lot, but not for nothing.** Writers ran 0.53M tokens of test output after first work. The #138 writer a8cb3c8be984ea435 alone ran 272 test and check commands over 29 hours. Identical reruns with identical output are among the 102 above. The rest follow an edit: a normal edit-test loop.
- **Several lanes on one ticket run the same gates.** Per ticket, the core gates ran a median of 68 times across that ticket's lanes. The same gate on the same ticket was run by a median of 2 lanes and up to 13. For example, `tests/spec-review/review-brief.sh` on #139 ran 88 times across 12 lanes. I could not tell whether those runs were at the same commit, so this is not proven duplicate work. Verifier lanes exist precisely to rerun gates independently.
- **Several lanes on one ticket read the same files.** 136 file-and-ticket pairs were read by three or more lanes, 1.8M tokens on first read. Most are `spec-review/scripts/review-brief.sh`, `review-comment.sh`, `SKILL.md`, and `tests/eval/reviewer/reviewer.py`. The largest single case is #143: `reviewer.py` read by 6 lanes, 135K tokens. This is modest.
- **Review and fix rounds.** Review rounds from two on, fix lanes and re-verify lanes make up 16% of ticket-attributed tokens: 292M of 1,799M. The most rounds were:
  - #143: 5 rounds, 10 reviewer lanes, each reading a 47K-token brief;
  - #135: 4 rounds;
  - #124, #139, #96 and #94: 3 rounds each.

  I cannot tell from token data whether a later round found real problems. Treat this as the size of the loop, not as waste.

## 3. Context carried for no reason

**Large results are expensive to carry.** Results of 5K tokens or more are 2,755 calls, and their carried cost is 673M tokens, 23% of all input:
- reviewer-eval harness: 221M
- owners: 124M
- writers: 108M
- reviewers: 75M
- verifiers: 67M

**Some of them stop being used long before the lane ends.** A large file read is treated as last used on the last turn that mentions its path in a tool call or visible text. Carried after that, those reads cost **371M tokens**, about 7% of weighted spend:

| role | carried after last mention | share of the role's input |
|---|---|---|
| reviewer-eval | 164M | 33% |
| owner | 61M | 10% |
| reviewer | 48M | 19% |
| writer | 37M | 7% |
| verifier | 28M | 7% |

This is a rough upper bound. A diff or a brief is used through the model's reasoning without its path being named again. Reviewer figures in particular are likely overstated.

The clearer cases are owners reading lane outputs whole into a context that lives 100 to 300 turns:

| owner | lane output read | size | turns carried |
|---|---|---|---|
| a2ce71454fd0910f0 (#109) | `.scratch/program/109/how/how.md` | 13.3K | about 184 |
| a2ce71454fd0910f0 (#109) | `arena/b/design.md` | 10.5K | 181 |
| aa93144dff7a44365 (#106) | `architect-upper.md` | 19.2K | 117 |
| a7e863dda12fb2374 (#90) | `explorer-1.md` and `explorer-3.md` | 16.6K and 19.0K | about 99 |

The session mandate, read at turn 2, stays until the end: 9K tokens across 324 turns for a91d9f1cee64cb2f2, and 8K across 210 turns for a2ce71454fd0910f0.

Two writer examples: a8cb3c8be984ea435 carried two saved oversized outputs (23K and 18K) for about 300 turns each, 13M tokens together.

**Suggested changes:**
- Lanes return a short summary, 1 to 2K tokens, plus the path to a detail file. Owners read the details only when a decision needs them.
- A long-lived lane that has absorbed a phase's results writes its state to a file and hands off to a fresh lane, instead of carrying it.

## 4. Orchestrator overhead

**The two roots.** 48857ffb reached 958K of context, processed 349M tokens, and made 7.6% of all weighted spend by itself. b4a8ae9c reached 498K and processed 52M.

Of 48857ffb's re-sent context:

| part | share | notes |
|---|---|---|
| its own output | 34% | about 430K tokens written, carried |
| lane outputs and scratch files | 17% | 118 reads, 155K tokens, 57.6M carried |
| task notifications | 13% | 185K tokens of lane final reports, 46M carried |
| Agent launches | 4% | 179 launches |
| gh | 4% | |
| its own test runs | 3% | 72 runs, mostly the `reviewer.py collect/next` harness |

It also made 44 poll/wait calls and 43 SendMessage calls.

**The "loop" command is expensive while idle.** It fired hourly: ten times, with 8.2K characters of `/loop` skill text each time. Each firing after an hour idle re-wrote the whole cached context of 320 to 620K at 1.25 times the input price. There were 11 such rewrites, 3.5M cache-write tokens.

**Owners carry the same orchestration load** (18 owners, 605M re-sent in total):

| activity | calls | carried | share of owner input |
|---|---|---|---|
| reading lane outputs | 324 | 81M (904K added) | 13% |
| task notifications | | 41.5M (338K added) | 7% |
| lane launches | 437 | 28.5M | 5% |
| running tests and gates themselves | 429 | 22.9M | 4% |
| gh | 408 | 21.1M | 3% |
| reading diffs themselves | 102 | 17.1M | 3% |
| poll/wait loops | 235 | 7.7M carried; 11.3 hours of wall-clock in `sleep` | |

Two items from that table need a caveat:
- **Owners running gates themselves.** 429 test and gate runs may repeat what writers and verifiers ran. I could not tie the runs to commits, so this is unproven.
- **Owners reading diffs themselves** is by design: the orchestrator reviews the diff.

**Polling is the real overhead, because it breaks the cache.** Owners wait with loops like `for i in $(seq 1 9); do test -s …/how.md && break; sleep 60; done`, up to 9 minutes. `owner-brief.md` asks for waits "under ten minutes per call, repeated". The data shows the cache lasts five minutes. The next turn is a cache miss only when more than five minutes have passed:

| time since last turn | cache kept | cache missed |
|---|---|---|
| under 4 min | 4,311 | 9 |
| 5 to 6 min | 10 | 10 |
| 6 to 10 min | 3 | 89 |
| over 10 min | 0 | 39 |

So after almost every long poll, the owner re-writes its whole context:

| who | rewrites | re-written tokens | share of the role's cache writes |
|---|---|---|---|
| owners | 133 | 43.1M | 88% |
| writers | 26 | 7.8M | 51% |
| root | 11 | 3.5M | 70% |

Weighted, owner rewrites alone are 54M units: about 10% of all spend, and nearly half of owner spend. The #103 owner a91d9f1cee64cb2f2 re-wrote its cache 29 times between 02:55 and 08:55 on 09-23, 15.9M tokens in all. In its last hour it re-wrote about 730K every 9 minutes. The #138 writer a8cb3c8be984ea435 re-wrote 809K and 834K after 17- and 24-minute gaps.

**Suggested changes:**
- Keep each wait under about 4.5 minutes, for example `sleep 60` at most four times, then return.
- Better, stop polling and let the lane's completion notification wake the owner. Owners already receive task notifications.
- Change the owner brief's "under ten minutes per call" to "under four minutes".
- In the root, stop the hourly loop from firing when nothing changed.

## 5. Failed or wasted effort

**Tool errors.** 1,636 of 21,698 calls (7.5%) returned an error:

| error | count | lanes | notes |
|---|---|---|---|
| worktree-isolation refusal | **1,040** | 291 | |
| command exited non-zero | 364 | 219 | mostly real test failures and greps that found nothing |
| `git`: not a repository | 82 | | reviewer-eval lanes whose working directory was a temp copy without `.git` |
| wrong path | 45 | | |
| Read too large | 34 | | |
| subagent tool restriction | 29 | | |
| hook blocked | 23 | | `block-dangerous-git.sh`, and "Blocked: sleep N followed by …" |

Only 37 errors were retried with the identical call.

**Worktree-isolation refusals are the big one.** The harness refuses any command in a worktree lane whose git use, or whose writes, it cannot verify stay inside the worktree: compound `cd … && …`, loops, `$(…)`, heredocs into paths. Its message: "Split it into plain, separate commands".

On the 919 refusals I could match to a turn:
- **124M tokens** of context were re-sent for nothing, about 2.2% of weighted spend;
- **165 minutes** of turn time were lost.

Where they fell:
- The worst lanes were a8cb3c8be984ea435 (32 refusals), a91d9f1cee64cb2f2 (18), a8edee7d294766f8f (13), and aa93144dff7a44365 and acb9c482825f3c72c (12 each).
- By role: writers 295, verifiers 283, owners 159, reviewers 132.
- Reviewers writing their report into another lane's worktree path were refused too.

Suggested changes:
- Tell worktree lanes in their entry point: run git as plain single commands from the worktree root, with no `cd` chains, loops or `$(…)` around git, and write only inside your own worktree or scratch folder.
- Alternatively, give lanes small scripts for the common multi-step git checks.

**Restarted and stopped lanes.**
- 21 non-eval lanes are labelled restart, fresh, rerun, redo or v2, totalling 113M tokens. The two biggest are owners in run 1: a7e863dda12fb2374 ("design hole restarts", 47M) and a8edee7d294766f8f ("fix-only rounds, fresh", 33M).
- TaskStop ended 14 lanes, about 36M tokens: owner #133 af2c9ced81b2ce774 (5.3M), its writer (2.6M), 8 eval reviewers, and one round-2 reviewer.

These were decisions to drop work. Whether the dropped work was unavoidable cannot be read from tokens.

## 6. Other waste, and easy fixes

- **A few very long lanes dominate.** 18 lanes whose context passed 300K account for **37% of weighted spend and 40% of tokens**. The top three:
  - root 48857ffb: 958K context, 7.6% of weighted spend;
  - owner #103 a91d9f1cee64cb2f2: 785K, 6.6%, 327 turns;
  - writer #138 a8cb3c8be984ea435: 962K, 6.3%, 532 turns over 29 hours.

  In a lane at 800K context, every turn costs as much as roughly 16 turns of a fresh 50K lane. Suggested change: bound owner and writer lanes by phase. When a phase ends (design, implementation, review round), the lane writes a state file and a fresh lane continues from it. Compact earlier. Do not let one writer iterate for 29 hours.
- **Oversized Bash output, then a Read of the saved copy.** Saved-output reads are 1 to 7% of context after first work, and 5.7M tokens were added over lane lifetimes. Suggested change: page large files with Read (offset and limit) instead of `cat`-ing several at once.
- **The reviewer-eval harness is a fifth of the spend.** Its 352 lanes are 21% of weighted spend: 508M tokens. Its diffs are 17% of the context it re-sends, and briefs plus diffs are about 22K tokens before any work. This is measurement cost. If it runs again, sharing the diff and brief as one cached prefix would help, as would fewer passes per arm.
- **Output is 17% of weighted spend.** Architects (35% of their weighted spend) and explorers (30%) are output-heavy, and that output is their deliverable. Nothing to cut there.

## Ranked opportunities

| rank | opportunity | approximate share of weighted spend |
|---|---|---|
| 1 | Poll waits longer than five minutes cause cache rewrites. Cap waits under 4.5 minutes or wait on notifications; change the owner brief's "under ten minutes". | about 13% (owners 10%) |
| 2 | Long-lived lanes pass 300K context. Split owner and writer work by phase with state files; compact earlier. | 37% sits in these lanes; the saving is a fraction of that |
| 3 | The 48K floor is carried every turn (grounding report): tool allowlists and a trimmed skill list. | 16% |
| 4 | Lane outputs and notifications are read whole into owner and root context. Return short summaries plus a path. | 4% carried, more with idle carry |
| 5 | Worktree-isolation refusals. Brief lanes on plain git commands and writing only inside their own tree. | 2% plus 165 minutes of turns |
| 6 | Oversized `cat`, then a read of the saved output. Use paged Read. | 1 to 2% |
| 7 | The eval harness, if it runs again. | up to 21% while it runs |

Not worth chasing: in-lane rereads, identical reruns, and test reruns. All measured small.

## Where the evidence is thin

- **Attribution** assumes a turn's growth equals its output plus its results; thinking the harness dropped makes this approximate. Tool inputs are measured in characters, and 2 to 2.5 characters per token is an estimate.
- **"Carried after last mention"** is a rough upper bound, especially for reviewers.
- **Ticket attribution** comes from the #N in lane descriptions. Owner review lanes use PR numbers, so one ticket's cost can be split across two numbers.
- **Cross-lane gate reruns** could not be tied to commits, so they are not shown to be redundant.
- **Review and fix rounds, restarts and stopped lanes** were measured in size only. Whether they were needed is a judgement the token data cannot make.
- **Price weights** are the standard relative ratios, not a bill.
