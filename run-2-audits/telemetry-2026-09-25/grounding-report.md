# What a Factory918 subagent does before its first real work

Most of a lane's starting weight is fixed before the lane does anything: every subagent opens at about 48K tokens, and that floor makes up 35% of all input tokens the 788 lanes processed. The "120-200K before real work" pattern is real only for owner lanes, and for about one writer lane in ten. There it comes from prescribed process reading plus task reading done before the first delegate launch, not from lanes wandering. Rereading the rules after spawning takes seconds, not most of a lane's life.

## Scope and method

**Data.** All subagent transcripts under `~/.claude/projects/-Users-manuel-Desktop-Work-Under-The-Sun-Collective-Core-918-factory918/`, except session 22c5dda7 (this conversation). That is 799 transcripts. 788 were analyzed after dropping 11: model probes ("reply with your model ID"), two `claude-code-guide` lookups, and one-turn lanes. Of the 788, 576 come from 48857ffb (run 2, 2026-09-24), 103 from b4a8ae9c (run 1, 2026-09-22), and 109 from seven older sessions (2026-09-17 to 09-21).

**Roles** come from each lane's `.meta.json` description and its brief:

| role | lanes | what they are |
|---|---|---|
| owner | 18 | "Own ticket #N" lanes (6 in run 1, 12 in run 2) |
| writer | 70 | writer, fix, and implement lanes |
| architect | 36 | architect and arena runners |
| explorer | 15 | how, explorer, explainer, and blast-radius lanes |
| verifier | 73 | "Verify PR N gates/runtime/audit", re-verify, and audit lanes |
| reviewer | 206 | spec-review, standards, trail, and cross-judge lanes in normal work |
| reviewer-eval | 352 | the #138 reviewer-measurement harness (briefs under `/var/folders/.../review-work/`), kept apart because it is repetitive and would swamp the reviewer numbers |
| other | 16 | 10 "#143 round N" reviewers, 3 "Write PR X of #76" writers, 3 read-only research lanes |

**Measures.**
- *Context size* at a turn is `input_tokens + cache_read_input_tokens + cache_creation_input_tokens` of that assistant message, deduplicated by message id.
- *Tokens a call added* is the context growth from its turn to the next, split across parallel calls in proportion to result size. It includes the model's own thinking and tool-call text for that turn.
- *Time* comes from record timestamps. "exec" is tool_use to tool_result; "turn wall" is one assistant turn to the next.

**Classifying calls** (script: `analyze.py`). Every tool call before first work is classified. Bash commands are split on `&&`, `;`, `|` and newlines, and each part is classified on its own.
- *skill-load*: the Skill tool.
- *skill-docs*: any `skills/**` markdown.
- *rules-docs*: AGENTS.md, CLAUDE.md, `docs/knowledge/**`, `docs/agents/**`, the M0 findings, the session mandate, SOURCES.md, README.
- *orient*: cd, ls, pwd, git status/log/branch/rev-parse, ToolSearch, find, wc.
- *intake*: the brief file, the ticket (`gh issue view`, `gh pr view`), and handover files under `.scratch/`.
- *task*: everything else. A call that mixes categories counts as task.

**First real work** is a milestone that depends on the role:
- writer: first edit to a repository file. Edit, Write, `sed -i`, a python write, `git apply` and `git commit` count; scratch notes do not.
- owner: first Agent launch or repository edit.
- every other role: first call that is neither grounding nor intake, such as reading the diff, reading a source file, or running a command.

The context size at the milestone is compared with the size at turn 0.

**Supporting files** in the same folder:
- `agents.jsonl`: one record per lane.
- `calls.jsonl`: 20,886 tool calls with tokens and times.
- `sequences.md`: the ordered pre-work call list for every lane (tool, argument, tokens added, exec time, seconds since start).
- `sigs.md`: recurring calls by role.
- `final_table.md`: the summary table below.
- Scripts: `analyze.py`, `agg.py`, `skills.py`, `sigs.py`, `files.py`, `dup.py`, `pack.py`, `spawn.py`, `seqall.py`.

**Token/character ratio.** With this tokenizer, 1 token is about 2.0 to 2.5 characters. The poteto-mode SKILL.md, 19,457 characters, added 9,589 tokens. owner-brief.md, 11,895 characters, added 4,681. Character-to-token conversions below use that range.

## 1. Starting context versus context at first real work

| role | lanes | ctx at turn 0 | ctx at first real work, median / p90 | process tokens before it (median) | intake (mean) | task reads (mean) | turns to it | turns with no task call | seconds to it | share of lane life | lane life (s) | lane turns |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| owner | 18 | 48.9K | **128.8K / 185.4K** | **35.0K** | 12.6K | 39.4K | 21 | 4 | 180 | 4% | 5845 | 110 |
| writer | 70 | 48.3K | 81.9K / 149.6K | 9.6K | 5.4K | 28.8K | 8 | 2 | 54 | 21% | 322 | 34 |
| architect | 36 | 48.2K | 59.7K / 70.9K | 9.5K | 5.6K | 0 | 2 | 2 | 6 | 1% | 527 | 20 |
| explorer | 15 | 49.2K | 56.0K / 59.4K | 0 | 5.1K | 0 | 1 | 1 | 4 | 1% | 275 | 19 |
| verifier | 73 | 48.0K | 52.4K / 57.6K | 0 | 4.7K | 0 | 1 | 1 | 5 | 1% | 521 | 55 |
| reviewer | 206 | 47.6K | 56.1K / 81.4K | 0 | 11.6K | 0 | 1 | 1 | 5 | 2% | 214 | 12 |
| reviewer-eval | 352 | 48.1K | 67.0K / 91.2K | 0 | 21.5K | 0 | 2 | 2 | 8 | 5% | 171 | 11 |
| other (#143 reviewers and others) | 16 | 48.1K | 95.4K / 98.0K | 0 | 30.7K | 0 | 3 | 3 | 11 | 2% | 621 | 40 |

"Process" is skill loads, skill docs, rules docs, and orientation. "Intake" is the brief file, the ticket, and handover files. "Task" is reading the files the work is about.

What the table shows:

- **The floor dominates for most lanes.** Turn 0 sits at 47.6K to 49.2K for every role. For reviewers, verifiers, and explorers the floor is 85 to 92% of the context at first work. These lanes read their brief and start work within 1 to 2 turns and about 5 seconds.
- **Owners are where 120-200K happens before real work.** Owner context grows from 49K to a median of 129K by the first Agent launch (p90 185K), over 21 turns and about 3 minutes. The growth splits into roughly 35K of process reading, 13K of intake, and 39K of task reading.
- **Run 1 owners were heavier than run 2 owners.**

  | owner lanes | process tokens (median) | ctx at first launch (median) | seconds to first launch |
  |---|---|---|---|
  | run 1 | 49K | 178K | 297 |
  | run 2 | 33K | 120K | 142 |

- **Writers read mostly task files.** Writer growth before the first edit is 33.8K (median). About 29K of that (mean) is task files, and about 9.6K is the poteto-mode skill load.
- **The reviewer growth is its brief.** Reviewer and reviewer-eval growth is intake: the spec or standards brief file carries a reading pack, 17 to 27K tokens per brief.
- **Early reads are paid on every later turn.** The table below shows the share of all the lane's input tokens that goes to carrying (a) the turn-0 floor and (b) whatever was read before first work, through every later turn. Medians per lane:

  | role | floor share | pre-work reading share |
  |---|---|---|
  | owner | 22% | 30% |
  | writer | 54% | 25% |
  | architect | 47% | 28% |
  | reviewer | 60% | 8% |
  | reviewer-eval | 51% | 16% |
  | verifier | 49% | 5% |

  Across all 788 lanes, the floor alone is 893M of 2.55B input tokens processed, or 35%. Most of it is cache reads.

### What is in the 48K floor

Probe lanes whose whole brief was one sentence (66 to 70 characters) show the floor on its own:

| date | lane | ctx at turn 0 | skill listing |
|---|---|---|---|
| 09-24 | tier-lower a29868f5681152088 | 50,462 | 30.2K chars |
| 09-24 | tier-upper a99b0ea592c876d9d | 50,469 | 30.2K chars |
| 09-21 | general-purpose a4149906c0372ddd7 | 45,959 | 30.2K chars |
| 09-18 | general-purpose a7a9b96c9e3abc09e | 34,032 | 11.1K chars |
| 09-22, 09-18 | claude-code-guide lanes (4 tools, no skill listing, no deferred-tool list) | 23,137 to 23,568 | none |

The first-turn cache split pins the rest. For review-\* and tier-\* lanes, `cache_read` at turn 0 is 30.0 to 31.0K. That is the prefix every lane shares: the Claude Code system prompt plus the tool schemas. The lane system prompt itself is only about 1.5K characters, so almost all of those 31K tokens are **tool schemas**. The lane agent files (`.claude/agents/tier-*.md`) give "the same tools as the general-purpose agent", which includes Artifact, the Browser tools, the iOS simulator, the docs MCP, session management, and visualize.

The other ~17K tokens of the floor are attachments plus the brief. Characters per lane in run 2:

| part | characters | tokens (est.) |
|---|---|---|
| skill listing (about 70 skills) | 30.2K | 10 to 12K |
| instruction chain: `~/.claude/CLAUDE.md`, pstack-models.md, repo CLAUDE.md, AGENTS.md, MEMORY.md | 9.9K | 3.5 to 4K |
| deferred-tool names | 7.9K | about 3K |
| session context, environment, date, model | 1.9K | under 1K |
| brief (prompt) | 0.3 to 4.4K (median by role) | 0.1 to 1.8K |

Between 09-18 and 09-21 the skill listing grew from 11.1K to 30.2K characters, and the floor rose from 34.0K to 46.0K. Other things may also have changed between those dates, so treat that as an upper bound on what the listing adds.

No hook output reaches subagents: no hook attachments appear in any subagent transcript.

## 2. Which files lanes read before first work, and which recur

The percentage is the share of lanes in that role that read the file before first work. The token figure is the mean added per lane that read it. The full lists are in `files.py` output and `sigs.md`.

**Owners (n=18).** These files are read almost every time, so they are candidates to hand over or shrink:

| file | lanes | tokens |
|---|---|---|
| `.scratch/program/owner-brief.md` | 100% | 5.2K |
| `poteto-mode/playbooks/ticket.md` | 94% | 5.2K |
| `playbooks/feature.md` | 83% | 1.5K |
| `.claude/hooks/session-mandate.md`, together with the grep for DECISIONS rows P11, P14 and P20-24 that the owner brief asks for | 72% | 4 to 8.5K per call |
| `playbooks/opening-a-pr.md` | 56% | 2.4K |
| `spec-review/SKILL.md` | 50% | 5.8K |
| `architect/SKILL.md` | 50% | 4.3K |
| `show-me-your-work/SKILL.md` | 50% | 2.4K |
| `architect/references/runner-prompt.md` | 39% | 1.8K |
| `poteto-mode/references/provider-dispatch.md` | 33% | 4.1K |
| `how/SKILL.md` | 33% | 3.2K |

Owners also read a median of 21 distinct files before their first launch.

**Writers (n=70).** No file is read by more than 30% of writers, so writer reading is task-specific:
- `spec-review/scripts/review-brief.sh`: 30%, 7.9K tokens.
- `SOURCES.md`: 29%.
- `tests/spec-review/review-brief.sh`: 27%, 16.2K tokens.
- AGENTS.md: 24%, 1.6K tokens, even though it is already in context through the CLAUDE.md import.
- `spec-review/SKILL.md` and `playbooks/ticket.md`: 20% each.

The only thing nearly every run-2 writer loads is the poteto-mode skill: 39 of 70 lanes, 9.0 to 9.5K tokens each.

**Reviewers.** Reviewers read only what is handed to them:
- the spec or standards brief: about 25% each, 17 to 27K tokens;
- the diff file: about 24%.

Reviewer-eval lanes read the brief (about 47% each for spec and standards), the diff (49%, a 21K-token Read), and the ticket (18%).

**Verifiers.** Verifiers read `verify/<N>-<sha>/common.md` (68%, 2.7K) plus one slice file (1.4 to 2.1K). This is a working handover design: no process reading, first work at turn 1.

**Architects and explorers.** Architects read the architect SKILL.md and `runner-prompt.md` (11 to 22%) and `playbooks/ticket.md` (22%). Everything else they read is task-specific. Explorers have no recurring files.

**Recurring non-read calls.** These run in most owner and writer lanes. Each costs little, but each is a turn:

| call | owners | writers | verifiers |
|---|---|---|---|
| `git fetch origin` | 78% | 47% | 66% |
| `git switch -c` | 100% | 76% | |
| `git log` | 61% | 49% | |
| `git status` | 56% | 43% | |
| `gh issue view` | 89%, 4.2K tokens, 1.0 s | 17%, 4.4K | |

Owners often run `gh issue view` 2 to 3 times in a row in different formats (for example a2ce71454fd0910f0, turns 3 to 5). Tool exec times are all under 3 s. The turns are what costs time: each turn's model-side time rises with context size (median seconds per turn, from 16K turns):

| context size | seconds per turn |
|---|---|
| under 60K | 3.0 |
| 60 to 100K | 4.4 |
| 100 to 150K | 6.7 |
| 150 to 250K | 7.3 |
| over 250K | 7.6 |

This comparison is confounded, because later turns also do heavier thinking.

**Parent to child rereads** (script: `dup.py`). The question is whether a child rereads a non-scratch file its parent read before launching it.

| child role | median distinct files read before first work | median of those the parent had read | median reread tokens | mean reread tokens |
|---|---|---|---|---|
| writer | 6 | 2 | 6.5K | 12.7K |
| owner (parent is the root) | 21 | 1 | | |
| reviewer, verifier | ~0 | | | |

The files writers reread most are the ones owners also read before briefing them:

| file | writer lanes | tokens per lane |
|---|---|---|
| `tests/spec-review/review-brief.sh` | 10 | 19.4K |
| `tests/eval/reviewer/reviewer.py` | 9 | 12.0K |
| `spec-review/scripts/review-brief.sh` | 14 | 8.7K |
| `spec-review/SKILL.md` | 14 | 4.3K |

A writer has to read what it edits. The duplicated cost therefore sits on the owner side: the owner reads implementation files to write the brief, then carries them through its remaining ~90 turns.

## 3. The skill-first hypothesis

**What briefs say.** The run-2 prompts for writer, architect, fix, and several verifier and explorer lanes open with "First action: invoke the poteto-mode skill with the Skill tool, then do the task below." The owner prompts add `args: "#N"` and point at `owner-brief.md`. Reviewer prompts say "Read `<...>/spec-brief.md` whole and follow it." Nine older reviewer prompts say "Invoke the spec-review skill with the Skill tool and follow its SKILL.md exactly."

**Compliance** (script: `skills.py`):
- Prompts whose first line tells the lane to invoke the skill: **82 of 82** lanes made the Skill call their first tool call.
- Prompts that say to invoke spec-review: **9 of 9** invoked it first.
- Lanes told to read a SKILL.md path read it with Read or cat. None used the Skill tool, and none needed to.

**Run 1 partly supports the hypothesis.** In run 1 the skill step sat inside `owner-brief.md` rather than in the prompt. **5 of the 6 owners never called the Skill tool.** They read SKILL.md, ticket.md and feature.md with `cat` instead; see a73dbb8e2f9e6aec5, turns 3 to 4, 9.5K and 6.5K tokens. Those owners then spent 49K process tokens (median) and reached 178K before their first launch. Run-2 owners, told in the first line of the prompt, spent 33K and reached 120K. The run-1 owner brief also differed in other ways, so the skill instruction cannot take all the credit. The direction is consistent with putting the instruction in the prompt.

**Cost by what the prompt says** (medians):

| role and prompt instruction | lanes | process tokens before first work | ctx at first work |
|---|---|---|---|
| writer, skill-first | 40 | 9.5K (all of it the poteto-mode load) | 82K |
| writer, SKILL.md path given | 15 | 4.2K | 67K |
| writer, no skill named (older sessions) | 12 | 0.4K | 114K |
| reviewer, spec-review skill-first | 9 | 12.9K | 62K |
| reviewer, brief file handed over | 142 | 0 | 57K |
| owner, skill-first (run 2) | 12 | 14.8K (+5.2K chain) | 120K |
| owner, no skill line in prompt (run 1) | 4 | 34.3K | 154K |

The groups differ in task and session, so read this as a description, not a controlled comparison.

**The chain a skill pulls in.** The poteto-mode Skill call itself is 9.5 to 9.6K tokens. The sections of its SKILL.md:

| section | characters |
|---|---|
| Playbooks router | 5.7K |
| Principles | 4.5K |
| Non-negotiables | 4.1K |
| Subagents | 1.6K |
| Writing the reply | 1.6K |
| Comments | 0.6K |
| Platform Adaptation | 0.5K |
| Autonomy | 0.7K |

A lane that already has its task uses neither the router nor the reply section.

For owners the chain continues, and the owner brief prescribes most of it:
1. `owner-brief.md`: 4.7K.
2. `session-mandate.md` plus DECISIONS rows: 4 to 8.5K.
3. `ticket.md`: 5.2K.
4. `feature.md`: 1.5K.
5. `opening-a-pr.md`: 2.4K.
6. SKILL.md for each skill the owner will brief lanes on: spec-review 5.8K, architect 4.3K, show-me-your-work 2.4K, how 3.2K.
7. `provider-dispatch.md`: 4.1K.

The chain totals roughly 25 to 35K tokens on top of the 49K floor. The owner brief also says "Read its `AGENTS.md` first", which is already loaded through `CLAUDE.md` → `@AGENTS.md`.

Spec-review's own skill-first reviewers loaded 12.9K (median) before first work.

## 4. Brief sizes, and inlined content that gets reread

- **Prompts are small.** Median prompt size by role runs from 0.25K characters (verifiers) to 4.4K (explorers). Owners are 2.9K and writers 2.0K. Only 1 of 239 checked prompts had three or more long lines that reappeared verbatim in tool output later: aa7a1e68acf03d288, a writer on ticket #81. Prompts do not inline content that then gets reread.
- **The large handovers are files:**
  - reviewer `spec-brief.md` and `standards-brief.md` from `review-brief.sh`: 17 to 27K tokens each, up to 47K;
  - `owner-brief.md`: 4.7K;
  - verifier `common.md`: 2.7K;
  - audit packets: 25K.
- **Reviewers reread the reading pack anyway.** A spec or standards brief holds commits, changed files, the diff inline or as a pointer, and a reading pack: a median of 19 files, whole or as line ranges, plus a "deleted at HEAD: no text" stub for every deleted file. In **129 of the 147 lanes (88%)** whose brief carried a pack, the reviewer reread at least one pack file anyway (script: `pack.py`). The median reread was 3.6K tokens (mean 4.4K), mostly whole files where the pack held a range.
- **Big briefs need several reads.** The #143 reviewers (tier-lower, a7b41d053461b3c8e and nine siblings) read a 94K-character spec-brief in three Read pages, because of the 25K-token Read cap: 49.8K + 30.6K + 14.0K characters. They sat at **95K before their first other action**, 13 to 17 s in. Reviewer-eval a9241dac70f0c36fe read three brief and ticket files (18K + 13K + 22K tokens) and stood at 106.8K at turn 3.

## 5. Wall-clock

- **Spawn is instant.** From the parent's Agent call to the child's first record is a median of 0.0 s, and 0.009 s with or without a worktree. From the brief to the first model turn is 1.4 to 2.1 s (script: `spawn.py`).
- **Grounding takes seconds for most roles.** Reviewers, verifiers, and explorers reach first work in 4 to 8 s: 1 to 2 turns, 1 to 5% of lane life.
- **Writers take about a minute.** They reach their first edit in 54 s and 8 turns, 21% of a 322-second median life. About 2 of those turns contain no task call. The rest are task reading.
- **Owners take about three minutes.** They reach their first launch in 180 s and 21 turns (run 1: 297 s; run 2: 142 s). That is 4% of a 97-minute median life, because owners spend most of their lives waiting on lanes.
- **So rereading the rules is not where the wall-clock goes.** The data does not support "most of their wall-clock life goes to re-grounding". Starting heavy costs time differently: every later turn carries the context, and turns get slower as context grows (section 2).

## 6. Other causes of heavy starts

- **Duplicate CLAUDE.md/AGENTS.md injection in worktrees.** In 172 of 799 lanes (22%), reading a file inside a worktree injected that worktree's `CLAUDE.md` and `AGENTS.md` as nested memory. They repeat the root copies already loaded at turn 0: about 7.2K characters, roughly 3K tokens per injection.
  - 49 lanes also received `template/CLAUDE.md` → `template/AGENTS.md` (11K characters): the product's instructions, which the nesting rule says do not apply to factory work.
  - Some lanes got it repeatedly. a8cb3c8be984ea435 (#138 writer) received AGENTS.md 11 times (73K characters), and a7e863dda12fb2374 (owner #90) 6 times.
  - Total across lanes: 1.9M characters, about 0.75M tokens.
- **Oversized Bash output read twice.** When one Bash call `cat`s many whole files, the output goes over the inline limit. Claude Code saves it to `tool-results/*.txt`, and the lane then Reads that file: 201 lanes did this, adding 5.7M tokens over their lives. The run-1 owner a73dbb8e2f9e6aec5 did it four times before its first launch (18.6K + 20.4K + 15.1K + 14.2K tokens). This accounts for a large part of that owner's 220K start.
- **Owners run long, so early reading is carried far.** Owners run a median of 110 turns, and several passed 300 to 785K context over their lives. Anything read before the first launch is carried through about 90 more turns.

## Worked examples

- **Owner, run 2: a2ce71454fd0910f0 (#109).** Turn 0 at 49.2K.
  1. Skill poteto-mode: +9.6K.
  2. `cat owner-brief.md`: +4.7K.
  3. session-mandate plus DECISIONS grep: +8.5K.
  4. `gh issue view 109`, three times: +2.6K.
  5. `playbooks/ticket.md`: +5.4K.
  6. show-me-your-work SKILL.md and log.sh: +3.7K.
  7. git fetch, switch, overlap.sh, log.sh.
  8. postmortem summaries: +12.8K.
  9. `feature.md`: +3.3K.
  10. `autopilot-stack.md`: +6.9K.
  11. todo and digest writes.
  12. **Agent "how: eco tier subsystem" at turn 19, 100 s, 110.9K.**
- **Owner, run 1: a73dbb8e2f9e6aec5 (#93).** Turn 0 at 48.6K.
  1. Read owner-brief: +6.5K.
  2. git checks.
  3. `gh issue view`: +2.7K.
  4. `cat` poteto-mode SKILL.md plus ticket.md: +9.5K.
  5. `cat` feature.md plus opening-a-pr: +6.5K.
  6. todo file.
  7. spec-review scripts and SKILL.md in batched `cat -n` calls (+13.1K, +8.0K), plus four Reads of saved oversized outputs (+18.6K, +20.4K, +15.1K, +14.2K).
  8. babysit SKILL, ticket.md at HEAD, how/architect prompts.
  9. **Agent at turn 25, 522 s, 220K.**
- **Writer: ac0c772b7d9f7a589 (#110).** Turn 0 at 50.1K.
  1. Skill poteto-mode: +9.5K.
  2. git fetch/switch plus `gh issue view`: +4.7K.
  3. The owner's `.scratch/110/grounding.md` and architect notes: +11.2K.
  4. `review-brief.sh`, two slices: +11.4K.
  5. DECISIONS rows: +8.0K.
  6. **Write `tests/knowledge/provisional-ids.sh` at turn 9, 90 s, 97.4K.**
- **Reviewer, #143: a7b41d053461b3c8e.** Turn 0 at 48.1K. spec-brief in three pages brings it to 95.4K at 13 s. It then reads `reviewer.py` whole (+21.7K), then spends five turns trying to find transcript directories under `~/.claude/projects`.
- **Verifier: a2a5db42218cd5346 (blind audit).** Turn 0 at 48.0K.
  1. audit-brief: +3.3K.
  2. `packet.md`, read twice in pages: +24.9K, then +25.9K.
  3. First command at turn 3, 102K.

## Ranked causes and suggested changes

Ranked by tokens times frequency.

1. **The fixed 48K floor on every lane.** It is 35% of all subagent input tokens and 85 to 92% of reviewer and verifier context at first work. About 31K is the system prompt plus tool schemas, 10 to 12K the skill listing, 3.5 to 4K the CLAUDE.md → AGENTS.md → MEMORY.md → pstack chain, and about 3K deferred-tool names.
   - Give each lane type a `tools:` allowlist in `.claude/agents/tier-upper.md`, `tier-lower.md` and the review-\* files. For example: reviewers get Read, Grep, Glob, Bash and Write; writers add Edit; owners add Agent and SendMessage. Browser, iOS, Artifact, docs, and visualize schemas then stop loading. The 4-tool `claude-code-guide` lane opens at 23K.
   - Check what Claude Code allows for trimming the skill listing that subagents see. The listing grew from 11K to 30K characters between 09-18 and 09-21, alongside a 12K-token jump in the floor. If it cannot be trimmed per agent, shorten the descriptions, especially the 25 `principle-*` entries.
   - Test each change with the existing one-line probe, the way a29868f5681152088 was run, before and after.
2. **The owner lane's prescribed process chain,** about 33K tokens in run 2 and 49K in run 1, plus 13K of intake before the first delegate. The same files are read in 50 to 100% of owners: owner-brief, ticket.md, feature.md, session-mandate plus DECISIONS rows, opening-a-pr, and the spec-review, architect and show-me-your-work SKILL.md.
   - Hand owners these "always" files as one pre-assembled owner pack. Better still, shrink them to what an owner acts on.
   - Let the owner read a sub-skill's SKILL.md at the step that launches that lane, not up front. The brief then names a goal and a trigger ("when you launch the spec-review lane, its SKILL.md tells you how"), which fits the judgment-first preference.
   - Drop "Read its `AGENTS.md` first": it is already loaded.
3. **Owners read implementation files before delegating, and carry them for about 90 turns.** That is 39K of task reads by the median owner's first launch. Writers then reread the same files: 6.5K median, 12.7K mean, and up to 19K per file for `review-brief.sh`.
   - Brief the writer with the goal and the paths it will need, and leave the deep reading to the writer, who must read what it edits anyway. The owner reads only enough to scope the work.
4. **poteto-mode skill-first in every writer, architect, and fix lane: 9.5K tokens, 100% compliance.** It is the largest single grounding item for writers, carried through a median of 34 turns. About half of SKILL.md (the Playbooks router, Writing the reply, Platform Adaptation) is of no use to a lane that already has its task.
   - Give lanes a lane-sized entry point, such as a `lane` reference with Non-negotiables, Principles and Subagents at about 10K characters (4 to 5K tokens), and keep the full skill for owners and the root.
5. **Reviewer reading packs:** 17 to 27K tokens per brief and up to 47K. 88% of reviewers still reread at least one pack file, and large briefs take several Read pages.
   - Drop the "deleted at HEAD: no text" stubs.
   - List files the reviewer is likely to open whole as paths with a one-line reason instead of inlining line ranges.
   - Measure whether reread tokens fall.
   - This trims what is handed over; it puts no cap on what a reviewer may read.
6. **Duplicate nested AGENTS.md injection in worktrees.** It hits 22% of lanes, about 3K tokens each time and up to 11 times per lane. 49 lanes also got the product's `template/AGENTS.md`, which does not apply to them.
   - Find out why a worktree lane loads the root copy at turn 0 and the worktree copy later. If the worktree copy loaded at start, one copy would be enough.
   - Decide whether factory lanes that touch `template/` should be told in their brief that the product AGENTS.md that appears does not apply to them.
7. **Batched `cat` of many whole files, whose saved output is then read back.** 201 lanes, 5.7M tokens.
   - Tell lanes, in the lane entry point, to read large files with Read, or one `cat` per file.
8. **Wall-clock turns before first work.** Owners spend about 21 turns and 2.5 to 5 minutes, writers about 8 turns and 54 s.
   - Most of this goes away with items 2 and 3.
   - Folding repeated `gh issue view` calls and the git fetch/switch/log/status sequence into one scripted step would save 3 to 5 turns per owner.

## Where the sample is thin

- **Owners:** 18 lanes, 6 in run 1 and 12 in run 2, over two program runs whose briefs differed in several ways. The run-1 versus run-2 comparison is not controlled.
- **Explorers (15) and architects (36):** small groups, with mixed brief styles.
- **Older sessions:** the 109 lanes from 09-17 to 09-21 used general-purpose agents and different briefs. They mostly add reviewers.
- **reviewer-eval (352):** a measurement harness, reported separately so it does not set the reviewer numbers.
- **Heuristics:**
  - The "first real work" milestone and the call categories come from path and command patterns. Bash commands mixing rule reading and task reading count as task, so process tokens are slight undercounts.
  - Tokens per call include the model's own thinking and output for that turn.
  - Floor components other than the cached prefix are estimates from character counts at 2.0 to 2.5 characters per token.
- **Not measured:** each lane's output quality, so nothing here says which reading was useful.


## After first work

The stretch from first work to the end of each lane, and the two root sessions, is covered in `after-work-report.md` in this folder.
