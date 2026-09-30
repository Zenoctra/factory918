# Spec review brief

Read nothing beyond this brief unless a finding needs the code around a hunk, and then read that one function or section, not the file. Run nothing.

## Commits

8b47278 Refuse the --diff record on a detached HEAD
ebf7e96 Treat a git error in the ancestor test as a failure, not as "no"
432397e Record that overlap.sh is ours and kept through sync
aac4dc6 Make the one-off go name the ticket the printed PR closes
46a0f1d Quote the program file path in the overlap test
661b8e1 Document the go command with bare ticket numbers
6b027ef Record the overlap rule and the go line as P24
67903cf Say in the playbook and the manual that a PR's line is its own commits
9439fb9 Diff each open PR from the PR under it, so a stacked PR reports only its own commits
b7ea7ed Record the program's go line when autopilot-stack starts
4839da7 Tell the manual's reader how two tickets relate before running both
d83b310 Route several tickets by how their files relate
b699cc6 Make the Ticket playbook run the overlap check before it branches
cce8b80 Add the overlap check the Ticket playbook runs before it branches
4de9c91 Add the test for the overlap check before its script
4da48ab Record the script path the brief got wrong
e79a411 Record the seven re-reviews mis-estimate in the ledger

## Changed files

 .github/workflows/factory-ci.yml                   |   4 +-
 AGENTS.md                                          |   1 +
 SOURCES.md                                         |   2 +-
 docs/agents/ledger.md                              |   2 +
 docs/knowledge/INDEX.md                            |   4 +-
 docs/knowledge/core/DECISIONS.md                   |   3 +-
 docs/knowledge/core/MANUAL.md                      |  22 ++-
 factory918.sh                                      |   2 +-
 .../poteto-mode/playbooks/autopilot-stack.md.patch |   7 +-
 template/.agents/skills/factory918/SKILL.md        |   4 +-
 .../poteto-mode/playbooks/autopilot-stack.md       |   2 +-
 .../.agents/skills/poteto-mode/playbooks/ticket.md |   4 +-
 .../.agents/skills/poteto-mode/scripts/overlap.sh  | 116 +++++++++++
 template/docs/factory918/DECISIONS.md              |   1 +
 template/docs/factory918/MANUAL.md                 |   4 +-
 tests/poteto-mode/overlap.sh                       | 213 +++++++++++++++++++++
 16 files changed, 367 insertions(+), 24 deletions(-)

## Blast radius

The sessions and skills this change reaches, as the author grounded them before the review. Check the diff against each one; the grounding is the author's claim, not evidence.

### What it does

Run 1's three prose surfaces still hold: `docs/knowledge/core/MANUAL.md:79-81` (copied to `template/docs/factory918/MANUAL.md:60-62`), the router rows `template/.agents/skills/factory918/SKILL.md:55-56`, and `poteto-mode/playbooks/ticket.md`. Every session kind reads the router row (`session-mandate.md:2`); `ticket.md` runs interactively and in every owner lane (`autopilot-stack.md:5`).

New: `template/.agents/skills/poteto-mode/scripts/overlap.sh`, under a vendored skill, kept across `sync` by `factory918.sh:381`; its test `tests/poteto-mode/overlap.sh`, wired into `factory-ci.yml:26-27`, the syntax loop widened to `poteto-mode/scripts/*.sh` (`:19`). `ticket.md:5` step 1 runs `overlap.sh N` after the dirty check and before the ticket is read: it force-fetches every open PR head (`overlap.sh:52-59`), diffs each against the PR under it or `origin/main` (`:63-73,87`), and exits 1 on a shared path no go covers (`:91-92,103`). `ticket.md:12` step 8 runs `--diff` and pastes the output as `## Overlap`. `autopilot-stack.md:7` step 3, via its patch, runs `overlap.sh go`, the only writer (`:22-27`) of `.claude/state/program`, resolved through `--git-common-dir` (`:20`). No step is renumbered.

### The one fact it's safe because of

Nothing parses the prose surfaces; the script's only callers are `ticket.md:5,12` and `autopilot-stack.md:7`; its only writes are `.claude/state/program` and `refs/remotes/origin/*`. Rung 4.

Grep (`*.sh *.py *.yml *.ts` under `tests/ tools/ .github/ factory918.sh template/.claude template/.agents/skills/spec-review/scripts`, research excluded) for `overlap.sh|state/program|Several unblocked tickets`: only `tests/poteto-mode/overlap.sh`, `factory-ci.yml:26-27`, `factory918.sh:381`. Readers of the changed paths: `factory918.sh:275-276` (`[ -f ]`), `build_knowledge.py:39`, `review-brief.sh:188` (path glob), `tools/bootstrap/` (frozen). No hook names the script or the file (grep of `template/.claude/hooks/*.sh`: nothing). `.claude/state/` is ignored here (`.gitignore:7`) and in projects (`template/.gitignore.factory:5`, appended by `factory918.sh:145`, checked at `:266`). Proof D: `refs/heads` unchanged across a run; only `origin/feat-a` moved.

Checks in a throwaway worktree of the writer's branch, removed after:

```
bash -n factory918.sh                                     exit 0
bash tests/poteto-mode/overlap.sh                         ok 51 assertions      exit 0
bash tests/hooks/delegation.sh                            ok 55 assertions      exit 0
bash tests/spec-review/review-brief.sh                    ok 334 assertions     exit 0
bash tests/spec-review/review-comment.sh                  ok 82 assertions      exit 0
bash tests/spec-review/no-stale-wording.sh                ok: no stale wording  exit 0
python3 tools/check_knowledge.py                          knowledge ok: 118 files  exit 0
python3 tools/build_knowledge.py && git status --short    knowledge files: 118, status empty  exit 0
./factory918.sh sync && git status --short                vendored: 72 skills, status empty  exit 0
```

MANUAL is 174 lines, 155 body: 65 under `build_knowledge.py:29` (220), 66 under `check_knowledge.py:16` (240).

### Risks

1. **A fork PR stops every ticket (interactive session, owner lane).** `overlap.sh:57` fetches `refs/heads/<headRefName>` from origin; a cross-repository PR's branch is not there, `git fetch` fails, the trap (`:17`) exits 2 for every `overlap.sh N` until that PR closes. Proven: a fake `pr list` naming `contrib-branch` gives `fatal: couldn't find remote ref refs/heads/contrib-branch`, exit 2. Likely wherever outsiders open PRs, never in Manuel's own repos; cost is a blocked step 1 with a clear stderr. Check: `gh pr list --json isCrossRepository` (the field exists) and skip, or fetch `pull/N/head`.
2. **No `gh` on PATH exits 2 (interactive session).** `:44` calls `gh` with no `command -v`; proven: `gh: command not found`, exit 2. Step 2 would have failed the same way. Low cost.
3. **`--diff` on detached HEAD reports the own PR (owner lane).** `:75` gives an empty `cur`, so `:86` skips nothing; proven: exit 1, `#1 feat-a: a.md`. Low: owners work on branches (`opening-a-pr.md:5`).
4. **`--limit 100` (`:52`).** PR 101+ is invisible, silently. Unlikely here.

### Cleared

- No origin: `:37-41` prints `base: main`, exit 0 (test 4). `origin/main` behind: `:54` force-fetches it.
- Linked worktree: `:20` reads the common dir's file (test 29); hooks read `.claude/state/mode` and `review` by project dir (`mode.sh:32`, `delegation.sh:25-26`), never the program file.
- Hooks: `block-dangerous-git.sh:7-17` sees only `overlap.sh N`; `delegation.sh:46` classes `.claude/state/*` untracked.
- `factory-start`, `factory-doctor`, `knowledge` SKILL.md: no `overlap|program|autopilot|ticket playbook|state/` hits.
- Review in progress: `review-brief.sh:188` matches `factory918/SKILL.md`, so the PR body needs `## Blast Radius`; `:196-197` ends it at the next `## `, so `## Overlap` after it is safe (run 1 proof).
- Stale refs: nothing relies on them; `factory918.sh:199`, `make-pr-easy-to-review/SKILL.md:24`, `multi-phase-plan.md:76` fetch first.
- `spec-review`: `review-comment.sh:133-141` reads its own headings only.
- `sync` keeps the script (`factory918.sh:381`) and reapplies the patch (`patches/series:3`); the widened CI syntax loop passes.

### Before you merge

```
git worktree add --detach <scratch>/wt42 wt/42-writer-v2 && cd <scratch>/wt42
bash -n factory918.sh; bash tests/poteto-mode/overlap.sh; bash tests/hooks/delegation.sh
bash tests/spec-review/review-brief.sh; bash tests/spec-review/review-comment.sh; bash tests/spec-review/no-stale-wording.sh
python3 tools/check_knowledge.py; python3 tools/build_knowledge.py && git status --short
./factory918.sh sync && git status --short
```

Risk 1 repro: a fixture clone with `.claude/skills` linked to the branch's skills, a fake `gh` listing a `headRefName` absent on origin, `overlap.sh 9`: expect exit 2.

## Diff

The diff is 578 lines; read it from `.scratch/review/origin_main/diff`.

## The ticket (#42)

## Problem

Observed (agent): the seven tickets #16 to #22 had no dependency on each other, but they touched the same files (`AGENTS.md`, the manual, `DECISIONS.md`), so they were stacked to avoid merge conflicts. Stacking turned independent work into a chain: reviews ran on all seven at once, and a fix low in the chain meant rebasing everything above. The manual's Execution paragraph routes every multi-ticket request to autopilot-stack without distinguishing dependency from file overlap. The agent also overstated the cost of fixing in place: autopilot-stack step 7 re-verifies only PRs whose `git patch-id` changed, so a fix low in a stack costs one re-review, not seven.

## Decision

> user: If one relies on the other, then we shouldnt move to the next and assume a retest will be affordable. That's not a good order. [...] working a ticket to completion before automatically moving on and considering the frontier that it touches as ONLY things that in no way ought to branch off of eachother and kicking back an error that requires user approval before doing anything otherwise.

> agent: Three cases. Truly dependent: `Blocked by`, off the frontier until the blocker merges. Independent and disjoint in files: parallel branches off `main`, no stacking. Independent but overlapping in files: sequence them (one to merge-ready, wait for the merge, then the next); stacking only for coupled work, and only after the human says so.

> user: I gotta be able to call up poteto mode and just say, hey, work on the fronteir and walk away.

> user: this is the kind of long horizon task. want to walk away from and come back to finished the next day 24 hours later.

> user: the biggest change of the ticket was not to stop autonomous work, but to tell the agent to finish a task enough that a later task has little no zero chance of having to get redone because a previous step was done imporoperly.

> agent: A go given at the start of a program (autopilot-stack, or a sweep run as one chain) is the human saying so for every stack that program builds: the overlap check records the overlap in the PR body and the stack goes on. Outside a program, overlap still means wait or ask.

## Acceptance criteria

- [ ] The manual's Execution section states the three cases and that file overlap is not coupling.
- [ ] The router's frontier row and the Ticket playbook check overlap before starting a second ticket: `git diff --stat` of the in-flight branch against the files the new ticket names; overlap means wait or ask, never stack silently, unless a standing go opened a program; then the overlap is recorded in the PR body and the stack continues.
- [ ] `autopilot-stack` routing in the manual says when it applies (coupled work) and that its patch-id rule keeps a rebase to one re-review.
- [ ] A ledger line for the agent's "seven re-reviews" mis-estimate and the shortcut it justified.

The program this rule must permit is the #41 sweep; #41's body says how each unit runs. Blocks #41.



## Testing decisions

Approved by Manuel 2026-09-21 ("go for it") for the second run, with the agent's defaults on the four open questions. The scenario table is the spec for the mechanism; a review finding that changes a cell is a design hole and returns the work to architect; a finding that leaves the table standing is an implementation bug fixed on the PR. Amended 2026-09-21 after the writer found, at the test, that the contract diffed a stacked PR against `main` and so contradicted the table's "contains" column: each PR is now diffed from the open PR it stacks on, else `main`; no assertion changed.

## Scenario table

Cell = prints / exit / what the agent does. `G` = first line `go: <label>` or `go: none`. `L(k)` = `#k <head>: <paths>`, the named paths k's own commits touch (its diff from `nearest`, the open-PR head under it, else `origin/main`), ascending by PR number. `B(x)` = last line `base: <x>`. Exit 0 always ends with a `base:` line; exit 1 prints `G` and the `L` lines and no base; exit 2 prints the tool's message on stderr and nothing decided. "Covered" = a line of `.claude/state/program` names #N and, for every printed PR, the ticket it closes (`closingIssuesReferences`).

| Situation | A. no overlap | B. one PR k overlaps | C. siblings k1, k2 | D. k2 contains k1 | E. `--diff` at step 8 |
|---|---|---|---|---|---|
| 1. No go names N | `G none`, `B(origin/main)` / 0 / branch from main | `G none`, `L(k)` / 1 / stop; reply: merge #k or say `stack #N on #M` | `G none`, `L(k1)`, `L(k2)` / 1 / stop, names both | `G none`, `L(k1)`, `L(k2)` / 1 / stop | own PR skipped; nothing else: prints nothing / 0 / no section; another PR j overlaps: `G none`, `L(j)` / 1 / section written, reply names #j to merge first |
| 2. Covered (go names N and every printed PR's ticket) | `G`, `B(origin/main)` / 0 | `G`, `L(k)`, `B(origin/<head k>)` / 0 / branch from k, report k as parent | `G`, `L(k1)`, `L(k2)`, `B(lowest number's head)` / 0 / branch, report both, root chains | `G`, `L(k1)`, `L(k2)`, `B(head k2)` / 0 / the head that contains the other | own PR skipped; parent's shared paths print with `G` / 0 / section verbatim |
| 3. Go names N, a printed PR's ticket is not on any line (Q1) | as 2A | `G`, `L(k)` / 1 / stop; reply: merge #k or add its ticket to the go | / 1 / stop | / 1 / stop | as 1E |
| 4. Program file present, no line names N | as 1A | as 1B (`G none`) | as 1C | as 1D | as 1E |
| 5. Program died; its line left behind | rows 2 to 4 apply unchanged: a line covers only stacks among the tickets it names while their PRs are open; nothing to clean up | | | | |
| 6. One-off go during a live program: `overlap.sh go "stack on #M" N` appends a line | rows 2 to 4 with that line; the program's lines untouched | | | | |
| 7. Review ticket (sweep) or body with no token: tokens under `## Diff` ignored | `G`, `paths: none`, `B(origin/main)` / 0 / branch; step 8 is the check | cannot overlap | | | as 1E / 2E |
| 8. Ticket names a file only PR k creates | pathspec matches the created file, on the creating PR's line only: as rows 1 to 4 | | | | |
| 9. Stale or missing remote-tracking ref | every open PR head fetched with a forced refspec before any diff: as rows 1 to 4 with fresh tips | | | | |
| 10. A PR head with no merge base against its base | git's `no merge base` on stderr / 2 / stop, report; the human closes or rebases that PR | | | | / 2 |
| 11. gh fails or is absent | gh's message (or `command not found`) on stderr / 2 / stop, report | | | | / 2 |
| 12. No origin remote | stderr `no origin remote; nothing in flight`, `G none`, `B(main)` / 0 / branch from main; gh not called | cannot overlap | | | prints nothing / 0 |
| 13. Token that is no path (`gh`, `#9`, `set -e` never a token, `{a,b}`) | matches nothing: as rows 1 to 4 for the real tokens beside it | | | | n/a |
| 14. Token outside the repository (a dot-dot path or an absolute path, unbackticked here so this ticket's own check does not trip on it) | git's own fatal on stderr / 2 / stop; the human fixes the body | | | | n/a |

## Contract

`.claude/skills/poteto-mode/scripts/overlap.sh N` (check, Ticket step 1); `overlap.sh N --diff` (record, Ticket step 8); `overlap.sh go "<label>" N...` (append `<label>: #a #b ...` to `.claude/state/program`, creating it; the only writer). `N` with or without `#`. Exit 0 decided (last line `base:`), 1 overlap without a covering go, 2 the check could not run (`trap 'exit 2' ERR` under `set -euo pipefail`; stderr carries the tool's message), 64 usage (no N; a flag other than `--diff`; a third argument).

Named paths (check): every backticked token without whitespace outside a `## Diff` section, deduped, passed together as pathspecs to one `git diff --name-only "$(nearest origin/$head)...origin/$head" -- "${toks[@]}"` per open PR, where `nearest <ref>` is the open-PR head, other than the ref's own, that is an ancestor of the ref with the fewest commits between, else `origin/main`; a stacked PR's line carries only its own commits; its output is `L(k)`. No token: `paths: none` and no PR loop. `--diff`: own paths = `git diff --name-only $(nearest HEAD)...HEAD`, the own PR's head excluded; the per-PR diff runs with `GIT_LITERAL_PATHSPECS=1`; the PR whose head is the current branch is skipped.

In flight: `gh pr list --state open --limit 100 --json number,headRefName,closingIssuesReferences`, drafts included. Before any diff: one `git fetch -q origin +refs/heads/main:refs/remotes/origin/main` plus `+refs/heads/<h>:refs/remotes/origin/<h>` per head. No origin remote: row 12.

Program file: `$(git rev-parse --git-common-dir)/../.claude/state/program` (a linked worktree reads the main checkout's; gitignored in the factory and in projects). Lines are append-only, written by `overlap.sh go` only. Covered = some line has the word `#N` and, for every printed PR, the word `#<its closing ticket>` on some line. A PR that closes no ticket is never covered (exit 1 says so). No removal step.

Base under a covering go: one printed head that contains every other (`git merge-base --is-ancestor`), else the lowest PR number's head.

## Report

A hard finding is one of two things: the documented path gives a wrong or silent result, or an input outside it proceeds silently (fails open). An input outside the documented path that is refused with a message saying how to correct it is not a finding; it is the design. Zero items is the expected result for a clean change.

- Manuel: "there are an infinite amount of unhappy paths and only 1 happy one"
- Manuel: "AT MOST hardening to fail fast and loud if we move outside of that"
- Manuel: "we notice the variable is unexpected and flag that without having to diagnose every reason the variable might be wrong for the user"
- Manuel: "An edge case outside the intended path being unsupported is not a flag."
- Manuel: "Primary focus must be the happy path, then unhappy paths that error in a way the user can correct."

Write the report as Markdown with exactly these `## ` headings, in this order, each holding numbered items or nothing:

- `## Walk`: one numbered line per documented step of the path the change touches (the ticket's criteria and the documentation the diff changes), each saying what the code does at that step. A walk, not findings: its lines are numbered 1..K on their own and count nothing.
- `## Would break`: a requirement missing, partial, or implemented so that the documented path gives a wrong or silent result.
- `## Fails open`: an input outside the documented path that proceeds silently instead of being refused with a message saying how to correct it.
- `## Not asked for`: behaviour in the diff the ticket did not ask for.

Each item opens with a line of the form `1. **Title.** body` and quotes the spec line it rests on in a fenced block (a criterion can carry `## ` or `1. ` lines, and only fenced text is exempt from the report shape); number the items continuously across the headings from `## Would break` on, so the judgment can name your third item as [P3]. Read nothing beyond this brief unless a finding needs the code around a hunk, and then read that one function or section, not the file. Under 400 words.

Every item under `## Would break` or `## Fails open` carries a line `Documented step:` quoting the ticket line or the `file:line` of the documentation the user follows, and a line `Result:` saying what happens instead; an item without its `Documented step:` line is sent back.

Write your report to `.scratch/review/origin_main/spec-report.md` and reply with only that path.
End the report with exactly one line `hard findings: N`, where N is the number of items under `## Would break` and `## Fails open` and nothing else.
