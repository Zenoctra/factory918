# The spec-review round gate, end to end

## Overview

`spec-review` is a two-axis review of the diff between a fixed point and `HEAD`. Two reviewer lanes (Standards, Spec) each write a report; the orchestrator sorts every report item into a judgment; a script turns the three files into one PR comment. The gate is the comment's last two lines, `round: N of 3` and `act-on items: N`. Babysit will not call a PR merge-ready until it reads `act-on items: 0` on the latest commit, and `review-brief.sh` refuses to open a fourth round on the same PR.

The whole loop is carried by two shell scripts and the PR's own comment history. There is no database and no state file that survives a round: `review-brief.sh` reconstructs the round number by reading the PR's earlier comments back through `gh`, and `review-comment.sh` deletes the working state as its last act. The comment is the record. That is why the two lines are pinned strings rather than anything parsed loosely, and why a comment rebuilt in the same round must repeat its `round: N` instead of advancing it.

```
review-brief.sh <fixed>          two lanes            orchestrator       review-comment.sh
  gh pr view --> round N ------> standards-report --> judgment.md -----> ## Standards
  slice at last `restart`        spec-report                             ## Spec
  carry `cites:` items                                                   ## Judgment
  write .scratch/review/<id>/                                            summary + fixed point
  write .claude/state/review/    (hook blocks the orchestrator's reads)  [restart]
       |                                                                 round: N of 3
       +-- refuses round 4, writes nothing --------------------------->   act-on items: N
                                                                         rm -rf .claude/state/review
```

## Key concepts

- **Fixed point.** The ref the diff is taken against, always three-dot: `git diff <fixed>...HEAD`, so the comparison is against the merge-base (`review-brief.sh:207`). It names the review dir and it is the only ref the comment prints.
- **Round.** One brief-review-judge-comment pass. A round is over when its comment is posted. Three per PR (P20).
- **Act on item.** A judgment item under `## Act on`. Counted unless one of three trailing fields takes it out: `fixed: <sha>` (fixed on this PR), `ticket: #N` (filed elsewhere), `hole: <reference>` (the design is wrong, not the code).
- **Design hole.** A finding whose fix changes the artifact the work was built against (a scenario-table cell, a `## Design` signature, an acceptance criterion) rather than the code. It prints the bare line `restart`, which ends the round history.
- **Settled item.** A Noted or Dismissed judgment item ending in `cites: <decision>`. Only these carry into later rounds' briefs (P21).
- **Review dir vs review state.** `.scratch/review/<id>/` holds the round's material and survives; `.claude/state/review/` is the live flag the delegation hook reads, and it exists only while a review is in flight.

## How it works

### Closing a round: `review-comment.sh`

The script reads a directory, either the one named in `.claude/state/review/dir` or one passed as its single argument, normalized so `./x`, `x/` and the absolute path all name the same dir (`review-comment.sh:24-34`).

Everything is parsed with one awk fragment, `fenced` (`review-comment.sh:44-50`), which tracks the current `## ` heading and skips fenced text. A fence opens on three or more backticks or tildes and closes only on a line of the same character, at least as long, followed by nothing but spaces or tabs. So a quoted hunk stays inside its block, and a report item's quoted diff can hold `## Dismissed` or `1. **x**` without being read as structure.

The helpers built on it:

- `headings <file>` (`:57`) — every `## ` heading name, trailing whitespace stripped.
- `items <file> [heading]` (`:59`) — the `N. ` lines under one heading, or under every heading except `Walk`, in document order. The Spec report's walk is steps, not findings, so it is excluded here and therefore from every count, the numbering check and the `[P<n>]` set (P23).
- `count` (`:60`) — `items | wc -l`.
- `title` (`:62`) — an item's `1. [S2] **Title.**` opening, for refusal messages.
- `stepless <file> <regex>` (`:65`) — the first Would-break or Fails-open item with no line matching the regex before the next item. Used twice: once for `^Documented step:`, once for the `spec:` line.
- `specs <file>` (`:76`) — one line per report item in document order, `<heading>\t<reference>`, the reference being the item's `spec:` value **only when the item sits under Would break or Fails open** (`:81`). Items elsewhere get their heading and an empty reference.
- `numbered <file>` (`:87`) — the written numbers run 1..N continuously across headings.
- `shape <file> <heading>...` (`:95`) — the headings are exactly these, in this order.
- `report <file> <heading>...` (`:103`) — shape, numbering, the `hard findings: N` line, that N does not exceed the Would-break plus Fails-open count, then the step line and the spec line on every one of those items.
- `holed <heading>` (`:158`) — judgment items under that heading whose line carries `hole:` and does **not** end in `fixed: <sha>` or `ticket: #N` (`ending`, `:156`). The field that ends the line is the field, so a `hole:` before a trailing `fixed:` is just text.

**Can the script tell which report heading an Act on item's finding sits under?** Yes, through `specs`. Line `:170` does `specs "$f" | sed -n "${ref_id#[SP]}p"` — the `[S3]` reference is an index into the report's items in document order, and the row it pulls carries both the heading (`at`) and the reference (`want`). This is used only for the hole check: a `hole:` on an item under `## Standards breaches`, `## Fix alongside` or `## Not asked for` is refused with the heading named, because `specs` left its reference empty (`:172`). A `spec:` line written under one of those headings is inert — the test calls it exactly that (`tests/spec-review/review-comment.sh:708`). The count itself never looks at report headings; an `[S3]` from `## Standards breaches` can be an Act on item and is counted like any other.

Then the tail (`review-comment.sh:193-208`):

```
act        = items under ## Act on
fixed_here = those ending in `fixed: <sha>`     (7-40 hex)
ticketed   = those ending in `ticket: #N`
holes      = holed "Act on"
ask        = items under ## Ask

summary:  "Standards: W would break, F fail open, of T; Spec: ...; judged: act on A
           (X fixed, Y with a ticket), ask ..., consider ..., noted ..., dismissed ...;
           fixed point <ref>."
restart          (only when holes > 0, on its own line)
round: N of 3
act-on items: (act - fixed_here - ticketed - holes + ask)
```

The fixed point in the summary comes from `<dir>/fixed-point`, else `.claude/state/review/fixed-point`, else the words `fixed point unknown` (`:202-204`). The round comes from `<dir>/round`, defaulting to 1 when the file is absent, and a file holding a non-number is a refusal (`:175-179`). Last line: the state is removed, but only when it exists and names this dir (`:209`), so a rerun from the dir argument after the state is gone clears nothing that belongs to someone else.

A refusal exits 1 and clears nothing, so an off-shape report goes back to its reviewer without burning a round (`SKILL.md:143`).

### Opening a round: `review-brief.sh`

Flags are parsed by a small state machine where `--standards`, `--paths` and `--commits` open a list and any other flag closes it (`review-brief.sh:35-53`). `--previous FILE` supplies the earlier comments from a file instead of `gh`; `--round N` sets the round directly. Both exist for tests and for a branch whose PR lives elsewhere (`:14-15`).

**Reading the history.** The jq program at `:100` is the filter:

```
.author.login as $a
| [.comments[] | select(.author.login == $a and (.body | test("(^|\n)act-on items:")))]
| .[] | .body, ""
```

Two conditions: the comment's author is the PR's author (the account the orchestrator posts under), and the body carries a line starting `act-on items:`. Anything by anyone else is a stranger's text and neither counts a round nor reaches the briefs (P22). Each body is followed by a line holding only US-ASCII 30, the record separator (`rs`, `:95`), which is how the parse tells one comment from the next. `gh`'s "no pull requests found" is swallowed as round 1 with nothing carried; any other `gh` failure is printed and the run continues the same way (`:104-111`).

**The restart slice** (`:144-159`). An awk pass finds every line that is exactly `restart` outside fenced text, records the index of the comment holding the last one, prints how many comments it cut, then prints only the comments after it. So the redesign's first review is round 1 with nothing carried, the restart comment's own items included. A restart comment with no separator after it cuts at EOF. When anything was cut, the script prints `restart: the round and the settled items count from the last restart comment` (`:179`).

**The round** (`:160-173`). Over the surviving comments, awk resets a counter to 1 at each separator and sets it from any `^round: [0-9]+ of 3$` line; the last such line in a comment is its own, since a quoted hunk may hold an earlier one. The round is the highest of those plus one. A comment with no round line is from before the line existed and counts as 1. A comment rebuilt in the same round repeats its N, so it advances nothing.

**The fourth-round refusal** (`:174-177`):

```
review-brief: three rounds were run on this PR; the remaining Act on items are fixed here
and marked `fixed: <sha>`, not reviewed in a fourth round
```

Exit 1, on stderr, and it fires before `mkdir -p "$dir"` and before the state is written, so no `.scratch/review/` and no `.claude/state/review/` exist afterward. The test asserts exactly that (`tests/spec-review/review-brief.sh:313-324`).

**The carry** (`:187-197`). From every surviving comment, in order, the judgment's Noted and Dismissed items whose line ends in one of four `cites:` forms: `user: "..." on #N`, `DECISIONS.md <row>`, `#N comment <YYYY-MM-DD>`, or `#N <reference>` in the same `table`/`design`/`criterion` grammar the `spec:` and `hole:` fields use. Each distinct line once. The script prints `settled: carried X, dropped Y without a citation`. The items land in both briefs under a fixed paragraph that says they are closed and says nothing about what to find.

**What gets written.** Into `.scratch/review/<id>/` (`:198-211`, `:262-266`): `diff`, `stat`, `log`, `files`, `fixed-point`, `round`, `ticket.md` when a ticket was resolved, then `standards-brief.md` and `spec-brief.md`. Into `.claude/state/review/` (`:259-264`): `fixed-point`, `files`, `dir`. The `<id>` is the fixed point with every character outside `A-Za-z0-9._-` mapped to `_`, so `HEAD~1` becomes `HEAD_1` and `origin/main` becomes `origin_main` (`:64`).

**Nothing records the commit that was reviewed.** No file holds `HEAD`, and the comment's summary line prints the fixed point, never the tip. The nearest thing is the first line of `<dir>/log`, which is the newest commit because `git log --oneline` is reverse-chronological. `template/docs/agents/review-ladder.md:6` says the comment "names the commit it reviewed", and babysit keys merge-readiness to the review comment "on the latest commit", but no script writes or checks that — it lives in the two human-facing sentences the orchestrator writes above the script's output (`SKILL.md:149`).

While `.claude/state/review/` exists, `template/.claude/hooks/delegation.sh:76,98` blocks the orchestrator from reading any file under review and `template/.claude/hooks/mode.sh:34` prints a REVIEW banner. That is why `review-comment.sh` clearing the state is what ends the round mechanically.

### The fixed point

`git diff <fixed>...HEAD`, three-dot. `SKILL.md:21` says whatever the user names is the fixed point and to ask if they did not. The Opening a PR playbook says only "after CI is green, run `spec-review` ... against the originating ticket and `CODING_STANDARDS.md`" (`template/.agents/skills/poteto-mode/playbooks/opening-a-pr.md:9`) and names no ref; the Ticket playbook likewise routes to it at step 8 without naming one (`template/.agents/skills/poteto-mode/playbooks/ticket.md:12`). So the choice is conventional, not enforced.

In practice it is `origin/main`. All three rounds on PR #92 print `fixed point origin/main`:

```
round 1: act on 4 (0 fixed, 0 with a ticket) ... fixed point origin/main.   act-on items: 4
round 2: act on 2 (0 fixed, 0 with a ticket) ... fixed point origin/main.   act-on items: 2
round 3: act on 3 (3 fixed, 0 with a ticket) ... fixed point origin/main.   act-on items: 0
```

Round three is the documented path: the remaining Act on items are fixed by a fix lane, marked `fixed: <sha>`, and the count falls to zero without a fourth review (P20, `SKILL.md:136`).

### Who reads the two lines

| Reader | What it does with them |
|---|---|
| `template/.agents/skills/spec-review/SKILL.md:25` | The round paragraph: how the round is derived, the restart slice, the fourth-round refusal, `--round`/`--previous` |
| `SKILL.md:132-137` | The four trailing fields and their grammars |
| `SKILL.md:141` | Step 6's contract: the lines are always present and `act-on items:` is always last, "Babysit reads this line" |
| `template/.agents/skills/poteto-mode/playbooks/babysit.md:16,18` | Merge-ready needs `act-on items: 0` on the latest commit; `round: 3 of 3` with zero is review-ready even when the fix commits follow; a `restart` line is never merge-ready |
| `template/.agents/skills/babysit/SKILL.md:40-41` | The same condition in the standalone skill's step 4 |
| `template/docs/agents/review-ladder.md:6` | Rung 1: the comment "ends with the lines `round: N of 3` and `act-on items: N`", the three-round cap, the design-hole rule |
| `docs/knowledge/core/DECISIONS.md:86` (P19) | `act-on items` is Act on plus Ask; `ticket: #N` is not counted; the reference check |
| `docs/knowledge/core/DECISIONS.md:87` (P20) | Three rounds at most, the cap is per PR, and a ticket is one PR |
| `template/.agents/skills/poteto-mode/playbooks/ticket.md:12` | Step 8: a `restart` line sends the work to the Design hole section instead of step 9 |
| `template/.agents/skills/poteto-mode/playbooks/ticket.md:26-34` | Design hole: amend the artifact, rerun `architect` Phase B, review from round one |
| `docs/knowledge/core/MANUAL.md:103` | The human's merge checklist: "`spec-review`'s last line on the latest commit reads `act-on items: 0`" |

## Where things live

| Path | Owner |
|---|---|
| `template/.agents/skills/spec-review/scripts/review-brief.sh` | **Factory's own**, in `keep_files` (`factory918.sh:385`) |
| `template/.agents/skills/spec-review/scripts/review-comment.sh` | **Factory's own**, in `keep_files` |
| `template/.agents/skills/poteto-mode/playbooks/ticket.md` | **Factory's own**, in `keep_files` |
| `template/.agents/skills/spec-review/SKILL.md` | **Vendored** from mattpocock `code-review`; change only via `patches/mattpocock/spec-review.SKILL.md.patch` (`patches/series:17`) |
| `template/.agents/skills/poteto-mode/playbooks/babysit.md` | **Vendored** from pstack; `patches/pstack/poteto-mode/playbooks/babysit.md.patch` (`series:4`) |
| `template/.agents/skills/babysit/SKILL.md` | **Vendored** from pstack; `patches/pstack/babysit/SKILL.md.patch` (`series:5`) |
| `template/docs/agents/review-ladder.md` | Factory's own template doc |
| `docs/knowledge/core/DECISIONS.md`, `MANUAL.md` | Factory's own core docs; rebuild with `tools/build_knowledge.py` |
| `tests/spec-review/` | Factory's own |

`cmd_sync` (`factory918.sh:380-404`) wipes and re-copies every vendored skill from `research/`, restores the `keep_files` on top, then replays `patches/series`. A patch that no longer applies prints `FAILED` and the sync returns nonzero. `SOURCES.md` entry 6 is the prose description of the spec-review patch, including the sentence that both scripts are in `sync`'s `keep_files`.

**The tests.** Both suites run twice via `suite project` and `suite factory`, against the copy of the skill each repo layout holds. `tests/spec-review/layout.sh:9-27` builds a throwaway git repo: a project gets `.agents/skills/spec-review/` with `.claude/skills -> ../.agents/skills`; the factory gets the same under `template/` with both links pointing there. This catches path assumptions that hold in one layout and not the other.

`tests/spec-review/review-brief.sh` puts `tests/spec-review/fake-gh.sh` on PATH as `gh`; it answers `pr view` from a `pr.json` fixture and serves a fixed ticket body otherwise, so most runs need no fixture. The `pr <author> [login:file ...]` helper (`:38-42`) builds `pr.json` with one comment per pair, which is how a stranger's comment is staged. `previous.md` (`:201`) is a full review comment with one cited Noted item, one cited Dismissed item, one uncited Dismissed item, and a fenced hunk containing a fake `## Dismissed` heading and a fake item. Assertions use `has`/`lacks` (fixed-string grep, `:46-60`) and `printed` (exact stdout, `:62-67`).

`tests/spec-review/review-comment.sh` uses `refuse <message> <label> [dir]` and `accept <stdout> <label> [dir]`: a refusal must exit 1 with exactly that one line and leave the state as it was; an accept must exit 0 with exactly that stdout and leave the state gone (`:45-68`).

`tests/spec-review/no-stale-wording.sh:9` greps `template/` and `docs/knowledge/core/` for three retired strings — `## Latent`, the old "A hard finding is wrong behavior in normal use" definition, and "Three trailing fields" (the field count before `hole:` was added) — and fails on any hit. It is the cheap guard against a rename that leaves the old words somewhere the other greps do not reach.

## Gotchas

- **The fence rule is duplicated on purpose.** The identical awk fragment appears in `review-comment.sh:44-50` and `review-brief.sh:126-132`, and the reference grammar in `review-comment.sh:56` and `review-brief.sh:138`. Both files say the other holds the copy, and `tests/spec-review/review-brief.sh` asserts the strings together. Edit one, edit both.

- **CRLF is handled in exactly one direction.** `review-brief.sh:123` strips `\r` and trailing whitespace from every line before parsing, so a comment posted from the GitHub web UI parses like one posted by `gh` (tested at `tests/spec-review/review-brief.sh:263-267`). `review-comment.sh` does no such strip, because it reads local files a subagent wrote. If a report ever arrived with CRLF, the failure would be uneven and platform-dependent: its `specs`/`stepless` checks are **awk** with a `$`-anchored regex, which does not tolerate a trailing CR, while `hard findings:` and `holed` go through **grep**, which on macOS treats CRLF as a line end and matches anyway (GNU grep does not). Worth knowing before trusting a refusal message about a missing `spec:` line.

- **The stranger filter is author-equality, not identity.** `select(.author.login == $a)` compares each comment's author to the PR's author. Any comment from another account is invisible to the round count and the carry, however well-formed (`tests/spec-review/review-brief.sh:302-311`).

- **A `restart` comment with no `act-on items:` line is never fetched.** The jq filter requires the `act-on items:` line, so such a comment cannot end the history through `gh` — but it can through `--previous`, where the file is trusted. The test names this split (`tests/spec-review/review-brief.sh:422-437`).

- **Rebuilding a comment in the same round is the designed path, not a workaround.** An Ask item the human answered, or a report sent back and rewritten, is handled by re-sorting the judgment, renumbering, and rerunning `review-comment.sh <dir>`. The round comes from `<dir>/round`, so it does not move, and the state-clearing guard means the rerun after the state is gone is harmless (`SKILL.md:128,145`).

- **`hole:` must be last on the line.** `holed` (`:158`) excludes any line ending in `fixed:` or `ticket:` before grepping for `hole:`. An item carrying both counts as fixed, no `restart` is printed, and the test pins this (`tests/spec-review/review-comment.sh:691`). Two holes still print one `restart` line (`:683`).

- **`hole:` must repeat the report item's `spec:` word for word** (`review-comment.sh:173`), and the report item must be one that carries a `spec:` line at all — that is, one under `## Would break` or `## Fails open`. Anything else is refused with the heading named.

- **The sweep mode's fixed point is the literal word `paths`.** `--paths P... --commits SHA...` sets `fixed=paths` (`:59`) and the diff becomes `git show <commits> -- <paths>` (`:202-205`). `HEAD` plays no part in the diff; the id is `sweep-<short sha of the first commit>`; the comment's summary reads `fixed point paths`. The round gate still runs `gh pr view` against whatever branch is checked out, so a sweep on `main` with no PR is round 1 with nothing carried.

- **`--blast-radius` on a non-cross-cutting diff is a warning, not a refusal** (`:256-258`): the file is simply not pasted, and the script says so on stderr while continuing.

- **The smell baseline is read out of `SKILL.md` at runtime** (`:68`). `review-brief.sh` greps step 3 for its bullet lines with fix arrows and refuses before writing any state if it finds none. A resync that reformats those bullets breaks the brief loudly instead of quietly shipping a reviewer with no baseline.
