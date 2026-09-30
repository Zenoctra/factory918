# How lane, ticket #103: the labeled reviewer set

Read-only. Every sha below was resolved in the repository's object store; pre-rebase commits survive
as unreferenced objects and were recovered through `git rev-list --all --reflog --children`.

## 1. Rounds inventory

PRs close tickets the other way round from the memory note: #94 closes #89, #96 closes #88.

| PR | ticket | round label as posted | fixed point (as posted) | reviewed head | `--previous` / `--ticket` | comment | surviving dir |
|---|---|---|---|---|---|---|---|
| 94 | 89 | `round: 1 of 3` | `ab47eb9` | `c83f166` | `--ticket 89` (commits name #42 and #89) | [5779120191](https://github.com/Zenoctra/factory918/pull/94#issuecomment-5779120191) | `owner-89-ab47eb9` |
| 94 | 89 | `round: 2 of 3` | `c83f166` | `0c63fa6` | `--ticket 89` | [5779392389](https://github.com/Zenoctra/factory918/pull/94#issuecomment-5779392389) | `owner-89-c83f166` |
| 94 | 89 | `round: 3 of 3` | `78be65e` | `715100c` | `--ticket 89` | [5779823400](https://github.com/Zenoctra/factory918/pull/94#issuecomment-5779823400) | `owner-89-78be65e` |
| 96 | 88 | `round: 1 of 3` | `ab47eb9` | `69bd412` (pre-rebase) | neither (commits name only #88) | [5779416046](https://github.com/Zenoctra/factory918/pull/96#issuecomment-5779416046) | none |
| 96 | 88 | `round: 2 of 3` | `ab47eb9` | `01e5386` (pre-rebase, **inferred**) | neither | [5779650623](https://github.com/Zenoctra/factory918/pull/96#issuecomment-5779650623) | none |
| 96 | 88 | `round: 3 of 3` | `ab47eb9` | `1362b48` (pre-rebase) | neither | [5779871731](https://github.com/Zenoctra/factory918/pull/96#issuecomment-5779871731) | `owner-88-ab47eb9` |
| 99 | 90 | `restart` + `round: 1 of 3` | `69bd412` | `52ccd8e` (pre-rebase) | `--ticket 90` (commits name #87, #90, #99) | [5780539782](https://github.com/Zenoctra/factory918/pull/99#issuecomment-5780539782) | none |
| 99 | 90 | `round: 1 of 3` (restarted series) | `69bd412` | `32978fa` (pre-rebase, **inferred**) | `--ticket 90` | [5781120649](https://github.com/Zenoctra/factory918/pull/99#issuecomment-5781120649) | none |
| 99 | 90 | `round: 2 of 3` | `69bd412` | `384bb43` (pre-rebase) | `--ticket 90` | [5781309601](https://github.com/Zenoctra/factory918/pull/99#issuecomment-5781309601) | `agent-a7e863dda12fb2374-69bd412` |
| 101 | 91 | `round: 1 of 3` | `52ccd8eb509a2871260827a8514c3a1fcaac4d5d` (full 40) | `7956c69` (pre-rebase, **recovered from a dangling chain**) | `--ticket 91` | [5781207159](https://github.com/Zenoctra/factory918/pull/101#issuecomment-5781207159) | none |
| 102 | 93 | `round: 1 of 3` | `d8e382ca37233bce98724c785ecdbb677abc4e2a` (full 40) | `7b01fd6` (**inferred**) | `--ticket 93` (commits name #87 and #93) | [5783722681](https://github.com/Zenoctra/factory918/pull/102#issuecomment-5783722681) | none |
| 102 | 93 | `round: 2 of 3` | `d8e382ca37233bce98724c785ecdbb677abc4e2a` | `fc75ac6` (named in the comment) | `--ticket 93` | [5783855182](https://github.com/Zenoctra/factory918/pull/102#issuecomment-5783855182) | `agent-a8edee7d294766f8f-d8e382ca37233bce98724c785ecdbb677abc4e2a` |

Recovered chains. #96 pre-rebase: `ab47eb9 → 1208407 → 741bc89 → 992ce94 → f156229 → 69bd412 →
01e5386 → 72953c0 → a64c7e6 → 1362b48 → 3f3814c`. #99 pre-rebase: `69bd412 → cc36280 → 8b3de0a →
52ccd8e → 096954b → 53ca502 → 32978fa → 785b158 → 831f4b4 → 384bb43` (no children). #101 pre-rebase:
`52ccd8e → ccf5bf6 → c0761dd → 6add1e3 → 469f78d → 7956c69` (no children).

Flags. No round's comment records its reviewed head: `<dir>/reviewed` is exactly what PR #102 added
(`review-brief.sh:328`), so every head above comes from a surviving brief's `## Commits` list, from
the chain walk, or from the comment prose. Four are inferred rather than read off an artifact: #96
round 2, #99 restarted round 1, #102 round 1, and #101's head, which is recovered but was never
written down anywhere. `52ccd8e` is no longer an ancestor of today's `d8e382c` (the stack was
rebased at 16:51, 19:09 and later), so `git diff 52ccd8e...d8e382c` today yields the whole stack,
not #101's five commits. Every regeneration must check out the pre-rebase head, not the PR's
current head.

## 2. Labels

`fixed:` marks only exist from PR #102 (the `would-break fixed after` machinery). Earlier rounds
carry their fixes as Act on items with no field, so the label set is "Act on items" for those.
`[S<n>]` is Standards report item n, `[P<n>]` is Spec report item n (`review-comment.sh:151`).

- **#94 round 1, 5 Act on, both axes.** [S1] `gh issue edit --body-file` replaces the ticket body and
  nothing says to write the old body back (`playbooks/ticket.md` step 6; terms: `gh issue edit`,
  `--body-file`, body wipe, acceptance criteria lost). [P1]+[S5] the posted scenario table's
  backticked paths become `overlap.sh` pathspecs (terms: `overlap.sh`, `## Testing decisions`,
  `## Diff`, phantom overlap, exit 1 or 2). [P3] the map still says four project documents while
  `build_core` copies five (terms: `MANUAL.md:165`, `build_knowledge.py`, five documents). [P4] a
  failed `gh issue edit` does not stop the work (terms: step 6, no stop clause, silent).
- **#94 rounds 2 and 3.** No Act on item on either axis. Both reports read `hard findings: 0`.
- **#96 round 1, 3 Act on.** [S1]+[P1] one glob among several that matches nothing is dropped and the
  gate still exits 0 (terms: `.github/shellcheck.sh`, `for f in $g`, "files checked: N", unmatched
  glob, fails open per glob). [S3] `tests/shellcheck/gate.sh` lands mode 100644, a fix-alongside.
- **#96 round 2, 4 Act on.** [S1] an argument with a space is word-split before globbing, so the gate
  refuses a file that exists (terms: unquoted `$g`, word splitting, path with spaces). [S2]+[P1] a
  binary already at the cache path is run as the pin without a checksum (terms: sha256 verified only
  on download, cached tarball, `shellcheck` cache path). [S3] the `docs/M0-findings.md` file count is
  one short (18 + `gate.sh` = 19, the twentieth is the gate).
- **#96 round 3.** No Act on item; `hard findings: 0` on both axes (surviving dir confirms).
- **#99 round 1, 2 Act on, both design holes, not fixes.** [S1] a reason that merely says "hole:" is
  read as a field (`hole: table 1/A`; terms: table B, column A vs column E). [P1] a review with no
  ticket cannot satisfy `spec:` (`hole: criterion 2`; terms: table B has no no-ticket row). Both
  restarted the rounds instead of landing a fix.
- **#99 restarted round 1, 4 Act on, all Standards.** [S1] `MANUAL.md:103`'s merge checklist reads
  `act-on items: 0` alone and calls a mid-restart PR ready (terms: `MANUAL.md:103`, `restart` line,
  merge gate). [S2] `DECISIONS.md` P20 "Three review rounds at most" is false at this commit. [S3]
  P21 still lists three `cites:` forms. [S4] the no-form refusal inserts a space the input lacked
  (terms: `hole:` written without the space, show the value as written).
- **#99 round 2.** No Act on item; Spec had one note, Standards three tidy-ups.
- **#101 round 1.** No Act on item on either axis. The two Standards points were noted (the Ticket
  playbook's `## Risks` heading shape versus `blast-radius/SKILL.md:43`, and `SKILL.md` reading as
  source-restricted where the script accepts either level).
- **#102 round 1, 3 Act on, all Standards, all `fixed: fc75ac6`.** [S1] the Ticket playbook scopes
  the fix-only round wider than `SKILL.md` step 1 (terms: table A row 12, round four). [S2]
  `review-ladder.md` still says `round: N of 3` two sentences before it says `round: 4 of 5`. [S3] an
  awk interval expression, the first in these scripts.
- **#102 round 2.** No Act on item; three Standards nits (bullet position, duplicated heading lookup
  in `review-comment.sh` lines 186-195, ragged comment wrap).

Rounds and axes with no fixed item: #94 r2 (both), #94 r3 (both), #96 r3 (both), #99 r2 (both),
#101 r1 (both), #102 r2 (both); plus the Spec axis alone in #96 r2 (its [P1] duplicates [S2]), #99
restarted r1 and #102 r1. Nine of the twenty-four briefs carry no label, which is the false-positive
half of the set.

`delegates.md` agrees line for line (lines 24-33, 93-103, 157-167, 218-219, 262-266) and adds that
every reviewer lane in the run was an `opus` lane, with per-lane wall clock from 0.8 to 7.7 minutes.
It also records that the #96 blast-radius lane had rounds 1 and 2's findings fifteen minutes before
the reviewers did (line 46), so those two labels are re-findings, not discoveries.

## 3. How `review-brief.sh` builds a brief

`template/.agents/skills/spec-review/scripts/review-brief.sh:4` is the signature:
`review-brief.sh <fixed-point> [--ticket N] [--standards FILE ...] [--previous FILE] [--round N]
[--blast-radius FILE]`, plus a sweep form `--paths P... --commits SHA...`.

Reads, in order. The smell baseline, `sed -n '/^### 3\./,/^### 4\./p' <skill>/SKILL.md` filtered to
`^- **...→` lines (:73), refused before any state is written. The ticket number from
`git log --reverse "$fixed..HEAD" --format=%B` unless `--ticket` (:83-92); two numbers is a refusal,
which is why four of the twelve rounds needed `--ticket`. The PR's own earlier review comments
through `gh pr view --json author,comments` filtered to the author's comments carrying `act-on
items:` (:105-108), or `--previous FILE` instead. The ticket body and the ticket author's comments
through `gh issue view` (:334-338). `CODING_STANDARDS.md` from the worktree (:340). For a
cross-cutting diff (`*.claude/hooks/*`, `*.claude/settings.json`, `*.agents/skills/factory918/*`),
the blast-radius grounding from `--blast-radius FILE` or the PR body's `## Blast Radius` section,
refusing without one and without a `## Risks` / `### Risks` heading (:283-316). #96's surviving brief
is the only one of the six carrying a `## Blast radius` section.

Writes. `.scratch/review/<id>/` where `<id>` is the fixed-point argument with every character
outside `A-Za-z0-9._-` turned into `_` (:69), holding `diff`, `stat`, `log`, `files`, `fixed-point`,
`round`, `reviewed` (:328, only from `27c43af`), `ticket.md`, `standards-brief.md` and, when a spec
was found, `spec-brief.md`. Also `.claude/state/review/{fixed-point,files,dir}`. The brief inlines
the diff in a fenced block under 500 lines and otherwise prints "read it from `<dir>/diff`" (:394).
That path string is in the brief text, so the spelling of the fixed-point argument changes the
bytes: #101 and #102 passed 40-hex, the rest short.

The fixed-point mode for rounds four and five (:207-236) never fired in this set. It requires the
last comment to carry `would-break fixed after <sha>`, the round to be exactly `top + 1`, `<sha>` to
resolve and to be the fixed point, and `--ticket` when the previous round had a spec. Both briefs
then carry `## The fix under review` with the `fixed:` items.

Reproducing the historical bytes. Not byte-exact today without pinning four drifting inputs. The
ticket bodies were amended during the run (#90's tables gained dated lines mid-round, `43dc844`), and
`gh issue view` always fetches current text; the ticket author's comments have grown since; the PR
comment history now holds every later round, so `gh` would compute the wrong round and carry the
wrong settled items; and `SKILL.md` plus `CODING_STANDARDS.md` are read from the worktree, so
checking out the reviewed head fixes them and checking out HEAD does not. A faithful regeneration is:
check out the reviewed head, run that head's own copy of the script
(`git show <head>:template/.agents/skills/spec-review/scripts/review-brief.sh`), pass `--previous`
with a file holding only that round's predecessor comments in `gh`'s RS-separated form, pass
`--round N`, pass `--ticket` and `--blast-radius` explicitly, and pin the ticket body by stubbing
`gh` — `--ticket` has no file equivalent, so the ticket body is the one input the script cannot be
told to read from disk.

Script version per round. #94 rounds 1-3: the copy at `ab47eb9` (the branch never touches the
script). #96 rounds 1-3: the copy at `69bd412` (`da12a25`'s ShellCheck cleanup). #99 round 1: the
copy at `52ccd8e` (`0b8e257`, restart added). #99 restarted round 1 and round 2: the copy at
`32978fa` / `384bb43` (`b248f8b`). #101: the copy at `7956c69` (`c0761dd`, the risk lines). #102
round 1: the copy at `7b01fd6` (`27c43af`, `1998c69`). #102 round 2: the copy at `fc75ac6`, which is
today's HEAD copy.

## 4. The report contract

A Standards report's headings, in this order and nothing else: `## Would break`, `## Fails open`,
`## Standards breaches`, `## Fix alongside` (`review-comment.sh:129`). A Spec report's: `## Walk`,
`## Would break`, `## Fails open`, `## Not asked for` (:136). The judgment's: `## Act on`, `## Ask`,
`## Consider`, `## Noted`, `## Dismissed` (:143). Items open `1. **Title.** body` and are numbered
1..N continuously across the headings, in document order; `## Walk` lines are steps, not items, and
are neither counted nor numbered with the findings.

The count line is defined in `review-brief.sh:361` as `count_rule` and carried word for word by
`spec-review/SKILL.md:85`: "End the report with exactly one line `hard findings: N`, where N is the
number of items under `## Would break` and `## Fails open` and nothing else." `SKILL.md:68` repeats
that each reviewer ends its report with it and replies with only the path.

`review-comment.sh` exits 1 and clears nothing (the full list is at `SKILL.md:146`) when a report
file is missing; when no line matches `^hard findings: [0-9]+$` (:113); when N exceeds the Would-break
plus Fails-open item count (:117, N below the count is tolerated); when a Would-break or Fails-open
item has no `Documented step:` line (:119); when, in a review with a spec, such an item has no
`spec:` line in one of the three forms (:122); when the headings are not the shape above, in order
(:104); when items are not numbered 1..N in document order (:96); plus the judgment-side refusals
(missing judgment, item-count mismatch, a missing or repeated `[S<n>]`/`[P<n>]`, a malformed or
misplaced `hole:`, a non-numeric `<dir>/round`, and a `fixed:` Would-break item with no valid
`<dir>/reviewed`). A malformed report goes back to its reviewer with the refusal text; no new round
is started for it. For the eval this is the "context failure" rule: a report with no `hard findings:`
line is a failure, never a zero.

## 5. The Codex route

`scripts/runner/pstack-runner` is a four-line `bun` wrapper over `cli.ts`. Argv (`cli.ts:16-24`,
strict, no positionals): `--parent <claude|codex> --provider <claude|codex|grok> --model <slug>
--effort <low|medium|high|xhigh|max> --mode <read-only|isolated-write> --prompt <file> --cwd <dir>
--output <file> --receipt <file> [--timeout <seconds>] [--help]`. `run.ts:486` refuses
`parent === provider` ("use the parent subagent primitive"), and `run.ts:492` refuses a versioned
Claude pin such as `claude-opus-5`, demanding the rolling alias. Output and receipt paths must not
exist. There is no implicit timeout.

The receipt is one JSON object, printed to stdout on exit 0 and to stderr otherwise
(`cli.ts:120-122`), shape in `types.ts` `RunnerReceipt`: `schemaVersion`, `status`, `parent`,
`provider`, `model`, `effort`, `mode`, `cwd`, `promptPath`, `outputPath`, `startedAt`, `completedAt`,
`elapsedMs`, `executable`, `preflight: {argv, status, evidence}`, `argv`, `exitCode`, `signal`,
`reportedModel`, `modelVerified`, `modelEvidence`, `sessionId`, `usage`, `costUsd`, `error`. Tokens
sit under `usage` as `NormalizedUsage`: `inputTokens`, `cachedInputTokens`,
`cacheCreationInputTokens`, `outputTokens`, `reasoningTokens`, `totalTokens`, normalized from the
provider's snake_case at `parse-output.ts:27-47`. `status` is one of `complete`, `cancelled`,
`unavailable-cli`, `unauthenticated`, `unavailable-model`, `timed-out`, `child-failed`,
`malformed-output`; every non-`complete` value is a receipt-bearing dropout.

`--mode read-only --provider codex --parent claude` runs preflight `codex login status`
(`commands.ts:22`), then `codex exec --model <slug> --config model_reasoning_effort="<effort>"
--sandbox read-only --cd <cwd> --skip-git-repo-check --ephemeral --disable plugins --disable
multi_agent --disable hooks --disable memories --json -` with the prompt on stdin
(`commands.ts:94-114`). `parseCodex` (`parse-output.ts:115`) reads the JSONL stream: `thread.started`
gives `sessionId`, `item.completed` with `item.type == "agent_message"` gives the text,
`turn.completed` gives `usage`, `turn.failed` throws. Codex reports no served model, so a Codex
receipt is `reportedModel: null`, `modelVerified: false`, `modelEvidence: "pinned-argv"`, and
`costUsd: null`. Codex here is 0.154.0; `provider-dispatch.md:93` still writes that caveat against
0.149.0, so it needs a dated re-check when the new rows land. On this machine `gpt-6-terra` and
`gpt-6-sol` are refused with a ChatGPT account and `gpt-6-astra` is served, already probed; a refusal
must land as an `unavailable-model` receipt, not a silent skip.

## 6. The Claude native route's evidence

Session `48857ffb-f0e5-4af1-9b36-ecddce7fb416`, file `subagents/agent-a29868f5681152088.jsonl`
(12 lines: 1 `user`, 1 `assistant`, 10 `attachment`). One JSON object per line. On an `assistant`
line: model id at `.message.model` (a concrete revision, `claude-opus-5`, not the alias);
`.message.usage.input_tokens`; `.message.usage.output_tokens`;
`.message.usage.cache_creation_input_tokens`; `.message.usage.cache_read_input_tokens`. Finer grain
sits at `.message.usage.cache_creation.ephemeral_5m_input_tokens` and `.ephemeral_1h_input_tokens`,
at `.message.usage.output_tokens_details.thinking_tokens`, and at `.message.usage.iterations[]`,
which repeats the four counters per API iteration. Timestamps are top-level `.timestamp`, ISO 8601
with a `Z` suffix, one per line, so per-lane wall clock is last minus first and per-message latency
is the gap between consecutive lines. Other top-level fields worth keeping: `.effort`,
`.perTurnEffort`, `.agentId`, `.sessionId`, `.requestId`, `.uuid`, `.parentUuid`, `.type`, `.cwd`,
`.gitBranch`, `.isSidechain`, `.version`, `.entrypoint`, `.advisorModel`, `.attributionAgent`,
`.attributionSkill`.

The sibling `agent-<id>.meta.json` is one flat object: `agentType` (here `tier-lower`, and
`tier-upper` on another), `description`, `toolUseId`, `spawnDepth`, `requestShape`
(`foreground`/`background`), `requestNonInteractive`, and, when the lane got a worktree,
`worktreePath`, `spawnedWithWorktree`, `worktreeBranch` and `parentAgentId`. It carries no tokens and
no timing; those come only from the JSONL.

## Open questions

1. Four reviewed heads are inferred, not recorded: #96 round 2 (`01e5386`), #99 restarted round 1
   (`32978fa`), #102 round 1 (`7b01fd6`), and #101's `7956c69`, which is recovered from unreferenced
   objects. A `git gc` would take #96's, #99's and #101's pre-rebase chains with it. They should be
   pinned with a tag or copied into the fixture set before anything else happens.
2. The ticket body cannot be supplied from disk: `--ticket N` always calls `gh issue view`. Either
   the fixture set commits the historical ticket bodies and the eval runner stubs `gh` on `PATH`, or
   `review-brief.sh` gains a `--ticket-body FILE` flag, which is a change to reviewed code and its
   own ticket.
3. Nine of twenty-four briefs carry no label. The acceptance criteria want them in the set, but a
   correct re-finding of a *noted* item (for instance #101's `blast-radius/SKILL.md:43` shape
   mismatch) is neither a labeled hit nor plainly a false positive. The scoring rule for a
   noted-but-real item needs deciding before the runs start.
4. `provider-dispatch.md` has no rows for Opus 5.5, GPT-6 Terra or GPT-6 Sol, and its Codex caveat is
   written against 0.149.0 while this machine runs 0.154.0. Whether Opus 5.5 is reachable as a
   rolling alias or only through `.claude/agents/tier-upper` decides whether the Claude lanes go
   through the native subagent primitive or the runner.
