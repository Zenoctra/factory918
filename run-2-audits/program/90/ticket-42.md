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

Amended 2026-09-22 by #89: the check skips `## Testing decisions` and `## Design` as it skips `## Diff` (row 7 and the contract's "Named paths"), so a posted table's example paths do not count as paths the ticket names; no assertion changed, one added.

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





