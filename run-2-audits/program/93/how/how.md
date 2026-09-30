# The spec-review round gate, end to end (at d8e382c)

Every `file:line` below was checked against the working tree at commit `d8e382c` on branch
`feat/would-break-extra-rounds`. The prior lane's write-up at `.scratch/program/93/prior/how.md`
was used as input; where it moved or was wrong, the correction is noted in Gotchas.

## Overview

`spec-review` reviews the diff between a fixed point and `HEAD` on two axes. Two reviewer lanes
(Standards, Spec) each write a report; the orchestrator sorts every report item into a judgment; a
script turns the three files into one PR comment. The gate is the comment's last two lines,
`round: N of 3` and `act-on items: N`. Babysit will not call a PR merge-ready until it reads
`act-on items: 0` on the latest commit, and `review-brief.sh` refuses to open a fourth round on the
same PR.

The whole loop is carried by two shell scripts and the PR's own comment history. There is no
database and no state file that survives a round: `review-brief.sh` reconstructs the round number by
reading the PR's earlier comments back through `gh`, and `review-comment.sh` deletes the working
state as its last act. **The comment is the record.** That is why the two lines are pinned strings
rather than anything parsed loosely, why a comment rebuilt in the same round repeats its `round: N`
instead of advancing it, and why any new fact a later round needs — such as which report heading a
fixed item came from, or which commit a round reviewed — has to be *written into the comment* by
`review-comment.sh` before `review-brief.sh` can read it back.

```
review-brief.sh <fixed>          two lanes            orchestrator       review-comment.sh
  gh pr view --> round N ------> standards-report --> judgment.md -----> ## Standards
  slice at the last `restart`    spec-report                             ## Spec
  carry `cites:` items                                                   ## Judgment
  write .scratch/review/<id>/                                            summary + fixed point
  write .claude/state/review/    (hook blocks the orchestrator's reads)  [restart]
       |                                                                 round: N of 3
       +-- refuses round 4, writes nothing --------------------------->   act-on items: N
                                                                         rm -rf .claude/state/review
```

## Key concepts

- **Fixed point.** The ref the diff is taken against, always three-dot: `git diff <fixed>...HEAD`
  (`review-brief.sh:207`), so the comparison is against the merge-base. It names the review dir
  (`:64`) and it is the only ref the comment prints (`review-comment.sh:219-222`).
- **Round.** One brief → review → judge → comment pass. A round is over when its comment is posted
  (`SKILL.md:25`). Three per PR (P20, `DECISIONS.md:87`).
- **Act on item.** A judgment item under `## Act on`. Counted unless one of three trailing fields
  takes it out: `fixed: <sha>` (fixed on this PR), `ticket: #N` (filed elsewhere), `hole: <ref>`
  (the design is wrong, not the code) — `review-comment.sh:214-216`.
- **Design hole.** A finding whose fix changes the artifact the work was built against (a
  scenario-table cell, a `## Design` signature, an acceptance criterion) rather than the code. It
  prints the bare line `restart` (`review-comment.sh:223`), which ends the round history for the
  next brief.
- **Settled item.** A Noted or Dismissed judgment item ending in `cites: <decision>`. Only these
  carry into later rounds' briefs (P21, `DECISIONS.md:88`).
- **Review dir vs review state.** `.scratch/review/<id>/` holds the round's material and survives;
  `.claude/state/review/` is the live flag the delegation hook reads
  (`template/.claude/hooks/delegation.sh:27,76,98`, `mode.sh:32,34`), and it exists only while a
  review is in flight.

## How it works

### Opening a round: `review-brief.sh`

Flags are parsed by a small state machine where `--standards`, `--paths` and `--commits` open a list
and any other flag closes it (`review-brief.sh:35-53`). `--previous FILE` supplies the earlier
comments from a file instead of `gh`; `--round N` sets the round directly. Both exist for tests and
for a branch whose PR lives elsewhere (`:14-15`).

**Reading the history.** The jq program at `:100` is the filter:

```
.author.login as $a
| [.comments[] | select(.author.login == $a and (.body | test("(^|\n)act-on items:")))]
| .[] | .body, ""
```

Two conditions: the comment's author is the PR's author (the account the orchestrator posts under),
and the body carries a line starting `act-on items:`. Anything by anyone else is a stranger's text
and neither counts a round nor reaches the briefs (P22, `DECISIONS.md:90`). Each body is followed by
a line holding only US-ASCII 30, the record separator (`rs`, `:95`), which is how the parse tells one
comment from the next. `gh`'s "no pull requests found" is swallowed as round 1 with nothing carried;
any other `gh` failure is printed and the run continues the same way (`:104-111`).

**The restart slice** (`:144-159`). An awk pass finds every line that is exactly `restart` outside
fenced text, records the index of the comment holding the last one, prints how many comments it cut,
then prints only the comments after it. So the redesign's first review is round 1 with nothing
carried, the restart comment's own items included. A restart comment with no separator after it cuts
at EOF. When anything was cut, the script prints
`restart: the round and the settled items count from the last restart comment` (`:179`).

**The round** (`:160-173`). Over the surviving comments, awk resets a counter to 1 at each separator
(`split`, `:122-125`) and sets it from any line matching `/^round: [0-9]+ of 3$/` (`:169`); the last
such line in a comment is its own, since a quoted hunk may hold an earlier one. The round is the
highest of those plus one (`:173`). A comment with no round line is from before the line existed and
counts as 1. A comment rebuilt in the same round repeats its N, so it advances nothing.

**The fourth-round refusal** (`:174-177`):

```
review-brief: three rounds were run on this PR; the remaining Act on items are fixed here
and marked `fixed: <sha>`, not reviewed in a fourth round
```

Exit 1, on stderr, and it fires before `mkdir -p "$dir"` (`:198-200`) and before the state is written
(`:259-264`), so no `.scratch/review/` and no `.claude/state/review/` exist afterward. The test
asserts exactly that at `tests/spec-review/review-brief.sh:327-339` (and again after a restart at
`:394-407`).

**The carry** (`:181-197`). From every surviving comment, in order, the judgment's Noted and
Dismissed items whose line ends in one of four `cites:` forms (`:187`): `user: "..." on #N`,
`DECISIONS.md <row>`, `#N comment <YYYY-MM-DD>`, or `#N <reference>` in the same
`table`/`design`/`criterion` grammar the `spec:` and `hole:` fields use (`:138`). Each distinct line
once. The script prints `settled: carried X, dropped Y without a citation` (`:196`). The items land
in both briefs under a fixed paragraph that says they are closed and says nothing about what to find
(`:329-336`).

**What gets written.** Into `.scratch/review/<id>/` (`:198-211`, `:265-266`, `:272`, `:388`,
`:422`): `diff`, `stat`, `log`, `files`, `fixed-point`, `round`, `ticket.md` when a ticket was
resolved, then `standards-brief.md` and `spec-brief.md`. Into `.claude/state/review/` (`:259-264`):
`fixed-point`, `files`, `dir`. The `<id>` is the fixed point with every character outside
`A-Za-z0-9._-` mapped to `_` (`:64`), so `HEAD~1` becomes `HEAD_1`.

**Nothing records the commit that was reviewed.** See Answer 2.

### Closing a round: `review-comment.sh`

The script reads a directory, either the one named in `.claude/state/review/dir` or one passed as its
single argument, normalized so `./x`, `x/` and the absolute path all name the same dir (`:25-35`).

Everything is parsed with one awk fragment, `fenced` (`:45-51`), which tracks the current `## `
heading and skips fenced text. A fence opens on three or more backticks or tildes and closes only on
a line of the same character, at least as long, followed by nothing but spaces or tabs. So a quoted
hunk stays inside its block, and a report item's quoted diff can hold `## Dismissed` or `1. **x**`
without being read as structure.

The helpers built on it:

- `headings <file>` (`:58`) — every `## ` heading name, trailing whitespace stripped.
- `items <file> [heading]` (`:60`) — the `N. ` lines under one heading, or under every heading except
  `Walk`, in document order. The Spec report's walk is steps, not findings, so it is excluded here
  and therefore from every count, the numbering check and the `[P<n>]` set (P23,
  `DECISIONS.md:89`).
- `count` (`:61`) — `items | wc -l`.
- `title` (`:63`) — an item's `1. [S2] **Title.**` opening, for refusal messages.
- `stepless <file> <regex>` (`:66-74`) — the first Would-break or Fails-open item with no line
  matching the regex before the next item. Used twice: once for `^Documented step:` (`:114`), once
  for the `spec:` line (`:117`).
- `specs <file>` (`:77-85`) — one line per report item in document order, `<heading>\t<reference>`.
- `numbered <file>` (`:88-94`) — the written numbers run 1..N continuously across headings.
- `shape <file> <heading>...` (`:96-101`) — the headings are exactly these, in this order.
- `report <file> <heading>...` (`:105-119`) — shape, numbering, the `hard findings: N` line, that N
  does not exceed the Would-break plus Fails-open count, then the step line and (only when
  `<dir>/spec-brief.md` exists, `:116`) the spec line on every one of those items.
- `holed [heading]` (`:168`) — judgment items under that heading whose line carries `hole:` and does
  **not** end in `fixed: <sha>` or `ticket: #N` (`ending`, `:166`). The field that ends the line is
  the field, so a `hole:` before a trailing `fixed:` is just text.

Then the tail (`:210-226`):

```
act        = items under ## Act on                              (:210)
fixed_here = those ending in `fixed: <sha>`     (7-40 hex)      (:214)
ticketed   = those ending in `ticket: #N`                       (:215)
holes      = holed "Act on"                                     (:216)
ask        = items under ## Ask                                 (:217)

summary:  "Standards: W would break, F fail open, of T; Spec: ...; judged: act on A
           (X fixed, Y with a ticket), ask ..., consider ..., noted ..., dismissed ...;
           fixed point <ref>."                                  (:222)
restart          (only when holes > 0, on its own line)         (:223)
round: N of 3                                                   (:224)
act-on items: (act - fixed_here - ticketed - holes + ask)        (:225)
```

The round comes from `<dir>/round`, defaulting to 1 when the file is absent, and a file holding a
non-number is a refusal (`:192-196`). Last line: the state is removed, but only when it exists and
names this dir (`:226`), so a rerun from the dir argument after the state is gone clears nothing that
belongs to someone else.

A refusal exits 1 and clears nothing, so an off-shape report goes back to its reviewer without
burning a round (`SKILL.md:143`).

### Who reads the two lines

| Reader | What it does with them |
|---|---|
| `template/.agents/skills/spec-review/SKILL.md:25` | Step 1's round paragraph: how the round is derived, the restart slice, the fourth-round refusal, `--round`/`--previous` |
| `SKILL.md:132-137` | The four trailing fields and their grammars |
| `SKILL.md:141` | Step 6's contract: the lines are always present and `act-on items:` is always last, "Babysit reads this line" |
| `template/.agents/skills/poteto-mode/playbooks/babysit.md:16,18` | Merge-ready needs `act-on items: 0` on the latest commit; `round: 3 of 3` with zero is review-ready even when the fix commits follow; a `restart` line is never merge-ready |
| `template/.agents/skills/babysit/SKILL.md:40,41` | The same two sentences in the standalone skill's step 4 |
| `template/docs/agents/review-ladder.md:6` | Rung 1: the comment "ends with the lines `round: N of 3` and `act-on items: N`", the three-round cap, the design-hole rule |
| `docs/knowledge/core/DECISIONS.md:86` (P19) | `act-on items` is Act on plus Ask; `ticket: #N` is not counted; the reference check |
| `docs/knowledge/core/DECISIONS.md:87` (P20) | Three rounds at most, the cap is per PR, and a ticket is one PR |
| `docs/knowledge/core/DECISIONS.md:95` (P27) | The design hole, the `spec:`/`hole:` grammar, `restart`, and that it amends P18, P20 and P21 |
| `template/.agents/skills/poteto-mode/playbooks/ticket.md:12` | Step 8: a `restart` line sends the work to the Design hole section instead of step 9 |
| `template/.agents/skills/poteto-mode/playbooks/ticket.md:26-35` | Design hole: amend the artifact, rerun `architect` Phase B, review from round one |
| `docs/knowledge/core/MANUAL.md:103` | The human's merge checklist: "`spec-review`'s last line on the latest commit reads `act-on items: 0`" |

## Where things live

| Path | Owner |
|---|---|
| `template/.agents/skills/spec-review/scripts/review-brief.sh` | **Factory's own**, in `keep_files` (`factory918.sh:385`) |
| `template/.agents/skills/spec-review/scripts/review-comment.sh` | **Factory's own**, in `keep_files` (`factory918.sh:385`) |
| `template/.agents/skills/poteto-mode/playbooks/ticket.md` | **Factory's own**, in `keep_files` (`factory918.sh:385`) |
| `template/.agents/skills/spec-review/SKILL.md` | **Vendored** from mattpocock `engineering/code-review`; change only through `patches/mattpocock/spec-review.SKILL.md.patch` (`patches/series:19`) |
| `template/.agents/skills/poteto-mode/playbooks/babysit.md` | **Vendored** from pstack; `patches/pstack/poteto-mode/playbooks/babysit.md.patch` (`patches/series:4`) |
| `template/.agents/skills/babysit/SKILL.md` | **Vendored** from pstack; `patches/pstack/babysit/SKILL.md.patch` (`patches/series:5`) |
| `template/docs/agents/review-ladder.md` | Factory's own template doc |
| `docs/knowledge/core/DECISIONS.md`, `MANUAL.md`, `SCENARIO-TABLE.md` | Factory's own core docs; rebuild with `python3 tools/build_knowledge.py`, which regenerates `template/docs/factory918/` (`tools/build_knowledge.py:9,126`) |
| `tests/spec-review/{review-brief,review-comment,no-stale-wording,layout,fake-gh}.sh` | Factory's own |

`cmd_sync` (`factory918.sh:379-405`) saves the `keep_files`, wipes and re-copies every vendored skill
from `research/`, restores the kept files on top (`:392`), then replays `patches/series` with
`git -C "$skills" apply` (`:397`). A patch that no longer applies prints `FAILED` and the sync
returns nonzero. `SOURCES.md` entry 6 is the prose description of the spec-review patch, including
the sentence that both scripts are in `sync`'s `keep_files`.

**The tests.** Both suites run twice via `suite project` and `suite factory` (`review-comment.sh:769-770`,
`review-brief.sh` likewise), against the copy of the skill each repo layout holds.
`tests/spec-review/layout.sh:9-27` builds a throwaway git repo: a project gets
`.agents/skills/spec-review/` with `.claude/skills -> ../.agents/skills`; the factory gets the same
under `template/` with both links pointing there.

`tests/spec-review/no-stale-wording.sh:9` greps `template/` and `docs/knowledge/core/` for three
retired strings — `## Latent`, `A hard finding is wrong behavior in normal use`, and
`Three trailing fields` — and fails on any hit. If #93 retires a phrase (for example "Three trailing
fields" became four, so "Four trailing fields" would be the next candidate), that grep is where the
retirement gets enforced.

## Gotchas

- **The fence rule is duplicated on purpose.** The identical awk fragment appears in
  `review-comment.sh:45-51` and `review-brief.sh:126-132`, and the reference grammar in
  `review-comment.sh:57` and `review-brief.sh:138`. Both files say the other holds the copy, and
  `tests/spec-review/review-brief.sh` asserts the strings together. Edit one, edit both.

- **CRLF is handled in exactly one direction.** `review-brief.sh:123` strips `\r` and trailing
  whitespace from every line before parsing, so a comment posted from the GitHub web UI parses like
  one posted by `gh` (tested at `tests/spec-review/review-brief.sh:278-282`). `review-comment.sh`
  does no such strip, because it reads local files a subagent wrote.

- **The stranger filter is author-equality, not identity.** `select(.author.login == $a)`
  (`review-brief.sh:100`) compares each comment's author to the PR's author. Any comment from another
  account is invisible to the round count and the carry, however well-formed
  (`tests/spec-review/review-brief.sh:317-326`).

- **A `restart` comment with no `act-on items:` line is never fetched.** The jq filter requires the
  line, so such a comment cannot end the history through `gh` — but it can through `--previous`,
  where the file is trusted (`tests/spec-review/review-brief.sh:437-452`).

- **Rebuilding a comment in the same round is the designed path, not a workaround.** The round comes
  from `<dir>/round`, so it does not move, and the state-clearing guard means the rerun after the
  state is gone is harmless (`SKILL.md:128,145`; test `review-comment.sh:324-339`).

- **`hole:` must be last on the line.** `holed` (`:168`) excludes any line ending in `fixed:` or
  `ticket:` before grepping for `hole:`. An item carrying both counts as fixed, no `restart` is
  printed, and the test pins this (`tests/spec-review/review-comment.sh:717-724`). Two holes still
  print one `restart` line (`:710-716`).

- **`hole:` must repeat the report item's `spec:` word for word** (`review-comment.sh:190`), and the
  report item must be one that carries a `spec:` line at all — that is, one under `## Would break` or
  `## Fails open` (`:189`). Anything else is refused with the heading named.

- **The sweep mode's fixed point is the literal word `paths`.** `--paths P... --commits SHA...` sets
  `fixed=paths` (`:59`) and the diff becomes `git show <commits> -- <paths>` (`:201-205`). `HEAD`
  plays no part; the id is `sweep-<short sha of the first commit>` (`:60`); the comment's summary
  reads `fixed point paths`. The round gate still runs `gh pr view` against whatever branch is
  checked out.

- **`--blast-radius` on a non-cross-cutting diff is a warning, not a refusal** (`:256-258`).

- **The smell baseline is read out of `SKILL.md` at runtime** (`:68-72`). `review-brief.sh` greps
  step 3 for its bullet lines with fix arrows and refuses before writing any state if it finds none.

- **Corrections to the prior lane's write-up.** Its line numbers are off by one to three in
  `review-comment.sh` (the helper block starts at `:45`, not `:44`; `headings` is `:58`; `items` is
  `:60`; `specs` is `:77`; `holed` is `:168`; the hole-lookup `sed` is `:187`, not `:170`; the tail
  is `:210-226`, not `:193-208`). `patches/series` lists the spec-review patch at line **19**, not
  17. `review-brief.sh`'s carry block is `:181-197` and its state block `:259-264`. Its claim that
  `previous.md` starts at `:201` is wrong — the heredoc opens at `:216`. Everything else it asserted
  that I re-checked (the fence rule duplication, the CRLF asymmetry, the author filter, the
  `hole:`-before-`fixed:` rule, the sweep fixed point, the smell baseline, hook lines 76/98 and
  mode.sh:34) holds at this commit.

---

## Answers for #93

### 1. Can `review-comment.sh` tell which report heading an `[S3]`/`[P2]` reference sits under?

**Yes, through `specs`,** and the mechanism already exists and is exercised — it is simply only
called on the *hole* path today, never on the `fixed:` path.

The chain is three helpers:

- `headings <file>` (`review-comment.sh:58`) — `awk "$fenced"'/^## / { print h }' "$1"` — the heading
  names in order. Not used for this, but it is the same `h` variable.
- `items <file> [heading]` (`:60`) — `h != "" && h != "Walk" && /^[0-9]+\. /` — the numbered lines
  under one heading or under all of them **except `Walk`**.
- `specs <file>` (`:77-85`) — the mapping helper:

```awk
awk -v want="^spec: $ref\$" "$fenced"'
  function flush() { if (item) print at "\t" v; item = 0; v = "" }
  /^## / { flush(); next }
  /^[0-9]+\. / { flush(); if (h != "" && h != "Walk") { item = 1; at = h } next }   # :81
  item && (at == "Would break" || at == "Fails open") && v == "" && $0 ~ want { v = substr($0, 7) }  # :82
  END { flush() }
' "$1"
```

`specs` prints **one line per counted report item, in document order**, as `<heading>\t<reference>`.
`## Walk` lines are excluded at `:81`: when the current heading `h` is `Walk`, the `1. ` line does
not set `item = 1`, so no row is emitted for it and the walk's own `spec:`/`hole:` text is invisible
(pinned by `tests/spec-review/review-comment.sh:678-683`, fixture lines `:644-648`). That exclusion
is exactly what makes the index line up with `[P<n>]`.

The index-to-heading map is `review-comment.sh:185-190`:

```sh
ref_id="$(printf '%s' "$line" | sed -nE 's/^[0-9]+\. \[([SP][0-9]+)\].*/\1/p')"     # :185
case "$ref_id" in S*) f="$dir/standards-report.md" ;; *) f="$dir/spec-report.md" ;; esac  # :186
rests="$(specs "$f" | sed -n "${ref_id#[SP]}p")"                                    # :187
at="${rests%%$'\t'*}"; want="${rests#*$'\t'}"                                       # :188
```

`${ref_id#[SP]}` strips the letter, giving the 1-based line number into `specs`'s output; `at` is the
heading, `want` is the reference. So for `[S3]` the script already has `at` = `Would break` /
`Fails open` / `Standards breaches` / `Fix alongside`, and for `[P2]` `at` = `Would break` /
`Fails open` / `Not asked for` (`Walk` can never be produced). The heading is already used in a
refusal message at `:189`:

```
'... is marked 'hole: $mark' but [$ref_id] carries no 'spec:' line: it is under '## $at' in $f, not a counted item'
```

tested at `tests/spec-review/review-comment.sh:759-760,763-764` for a `## Standards breaches` item.

Two consequences for #93:

- A `fixed:` item's heading can be found with the same two lines — `specs "$f" | sed -n "${n}p"`
  then `${rests%%$'\t'*}` — with no new parsing at all. Today `holed()` (`:168`) greps *out* any line
  ending in `fixed:`/`ticket:`, so `fixed:` items never reach `:182-191`; a new loop over
  `items "$dir/judgment.md" "Act on" | grep -E 'fixed: [0-9a-f]{7,40}$'` would be needed.
- The heading half of the row is populated for **every** counted item, including a review with no
  spec, where `report()` skips the `spec:` check (`:116`) and `want` comes back empty. So keying on
  `at == "Would break"` works even when the reference is empty — unlike the `hole:` check, which
  requires a non-empty `want` (`:189`).

### 2. Does anything record which commit (HEAD) a round reviewed?

**No. Nothing writes HEAD, and the comment never prints it.**

- `<dir>/` holds `diff`, `stat`, `log`, `files` (`review-brief.sh:201-211`), `fixed-point` (`:265`),
  `round` (`:266`), `ticket.md` (`:272`), `standards-brief.md` (`:388`) and `spec-brief.md` (`:422`).
  None of them is a commit id for the tip.
- `<dir>/fixed-point` holds the **fixed point**, not HEAD: `echo "$fixed" > "$dir/fixed-point"`
  (`:265`), where `$fixed` is the user's ref (`:49`, `:62-64`) or the literal word `paths` (`:59`).
- `.claude/state/review/` holds exactly three files: `fixed-point`, `files`, `dir`
  (`review-brief.sh:262-264`). Same `$fixed` value.
- `<dir>/log` is the nearest thing: `git log "$fixed..HEAD" --oneline > "$dir/log"` (`:209`), whose
  **first line is the tip**, because `git log` is reverse-chronological. But `log` goes only into the
  briefs (`review-comment.sh` never reads it; `review-brief.sh:307` pastes it under `## Commits` in
  each brief), so it is not in the PR comment and `review-brief.sh` cannot read it back from `gh`.
- The comment's summary line (`review-comment.sh:222`) ends with `$fixed`, built at `:219-221`:

```sh
if   [ -f "$dir/fixed-point" ]; then fixed="fixed point $(cat "$dir/fixed-point")"
elif [ -f "$state/fixed-point" ]; then fixed="fixed point $(cat "$state/fixed-point")"
else fixed="fixed point unknown"; fi
```

and prints as the final clause, e.g. `...; dismissed 1; fixed point main.` (pinned at
`tests/spec-review/review-comment.sh:262`). A missing file gives the words `fixed point unknown`.

`template/docs/agents/review-ladder.md:6` says the comment "names the commit it reviewed" and both
babysit copies key merge-readiness to the review comment "on the latest commit", but **no script
writes or checks that** — it lives in the two human-facing sentences the orchestrator writes above
the script's output (`SKILL.md:149`).

**Implication for #93.** "Fixed point = the commit the previous round reviewed" cannot be recovered
from anything that exists today. Either `review-comment.sh` must print the reviewed HEAD into the
comment (a new line, or an extra clause on the summary line at `:222`), and `review-brief.sh` must
parse it back; or `review-brief.sh` must record it at `:265` and the next round must be launched from
the same working tree, which the PR-comment-as-record design deliberately does not assume.

### 3. `previous.md`, the `pr` helper, and every `of 3` string

The `pr` helper, `tests/spec-review/review-brief.sh:38-43`:

```sh
# pr <author> [login:file ...]: pr.json, the PR opened by <author> with one comment per pair, in order.
pr() {
  local a="$1" c; shift
  for c in "$@"; do jq -n --arg l "${c%%:*}" --rawfile b "${c#*:}" '{author: {login: $l}, body: $b}'; done |
    jq -s --arg a "$a" '{author: {login: $a}, comments: .}' > pr.json
}
```

`pr.json` is read by `tests/spec-review/fake-gh.sh:16-20`, which runs the script's own jq expression
against it, so the author filter is what is under test. With no `pr.json`, the fake answers
`{"author": {"login": "me"}, "comments": []}` (`fake-gh.sh:20`) — a PR with no comments, round 1.

The `previous.md` fixture, `tests/spec-review/review-brief.sh:216-260`, in full:

````
cat > previous.md <<'EOF'
The review found two things and I dismissed one of them. The hook stays in bash by decision.

## Standards

## Would break

1. **Hook in Python.** The hook is bash.

```sh
## Dismissed
1. **Not an item.** inside a fence. cites: DECISIONS.md P1
```

## Standards breaches

## Fix alongside

hard findings: 1

## Spec

no spec: Standards axis only

## Judgment

## Act on

## Ask

## Consider

## Noted

1. [S1] **Hook in Python.** A port is a later ticket. cites: #74 comment 2026-09-17

## Dismissed

2. [S2] **Whole DECISIONS.md is writable.** Provisional rows are the agent's to add. cites: DECISIONS.md P17
3. [S3] **Bare number.** The constant is named two lines up.

Standards: 1 would break of 3; Spec: no spec; judged: act on 0 (0 with a ticket), ask 0, consider 0, noted 1, dismissed 2; fixed point main.
round: 1 of 3
act-on items: 0
EOF
````

Note what the fixture is *not*: it has no `## Fails open` heading and its summary line is in the old
pre-`fail open` form. It is a PR comment, not a report the script validates, so it is never shape-checked.
Every other fixture in this test is derived from it by `sed`/`awk` (`:295`, `:301`, `:319-321`,
`:351-355`, `:429`, `:439`, `:457`, `:465`).

**`printed` assertions whose pinned stdout contains `of 3`** (the `printed` helper is `:62-68`, exact
stdout comparison). Each entry gives the `printed` call's first line and the line inside the pinned
string that carries `of 3`:

| `printed` call | pinned line with `of 3` | string |
|---|---|---|
| `:85` | `:86` | `round: 1 of 3` |
| `:204` | `:204` | `round: 1 of 3` (first line of the pinned string) |
| `:262` | `:263` | `round: 2 of 3` |
| `:304` | `:305` | `round: 2 of 3` |
| `:360` | `:362` | `round: 1 of 3` |
| `:372` | `:374` | `round: 2 of 3` |
| `:380` | `:382` | `round: 1 of 3` |
| `:388` | `:390` | `round: 1 of 3` |
| `:409` | `:411` | `round: 3 of 3` |
| `:421` | `:423` | `round: 2 of 3` |
| `:432` | `:433` | `round: 3 of 3` |
| `:442` | `:443` | `round: 3 of 3` |
| `:448` | `:450` | `round: 1 of 3` |
| `:568` | `:569` | `round: 1 of 3` |

Two more exact-stdout comparisons are written inline rather than through `printed`, and pin the same
line: `:555-557` (the `refused_risks` helper, `round: 1 of 3` at `:556`) and `:606-608`
(`round: 1 of 3` at `:607`). `has` assertions (substring, `:46-53`) pin it at `:97`, `:106`, `:298`,
`:324`, `:342`.

**Every occurrence of the literal `of 3`** under `template/`, `docs/knowledge/core/`, `tests/`,
`patches/` and `SOURCES.md` (`grep -rn 'of 3'`), grouped:

*Producers (the string the scripts emit):*
- `template/.agents/skills/spec-review/scripts/review-brief.sh:169` — the parse regex `/^round: [0-9]+ of 3$/`
- `template/.agents/skills/spec-review/scripts/review-brief.sh:180` — `echo "round: $round of 3"`
- `template/.agents/skills/spec-review/scripts/review-comment.sh:224` — `echo "round: $round of 3"`
- `template/.agents/skills/spec-review/scripts/review-brief.sh:8`, `:160` — the header/inline comments

*Prose that would go stale:*
- `template/.agents/skills/spec-review/SKILL.md:25` (step 1) and `:141` (step 6)
- `template/.agents/skills/poteto-mode/playbooks/babysit.md:16`
- `template/.agents/skills/babysit/SKILL.md:40`
- `template/docs/agents/review-ladder.md:6`
- `docs/knowledge/core/DECISIONS.md:87` (P20)
- `template/docs/factory918/DECISIONS.md:79` (**generated** from the line above by `tools/build_knowledge.py`)
- `SOURCES.md:16` (item 4), `:18` (item 6), `:24` (item 12)
- `patches/mattpocock/spec-review.SKILL.md.patch:20`, `:130`
- `patches/pstack/poteto-mode/playbooks/babysit.md.patch:7`
- `patches/pstack/babysit/SKILL.md.patch:8`

*Tests:* `tests/spec-review/review-brief.sh:11,86,97,106,204,257,258,263,292,298,305,319,320,324,342,351,352,354,355,362,374,382,390,411,423,429,433,443,450,556,569,607`
and `tests/spec-review/review-comment.sh:174,262,263,282,283,320,321,337,338,379,380,417,436,457,475,497,523,524,570,611,682,689,696,705,715,723,741,756`.

**Trap:** not every `of 3` is the round line. `of 3` also appears as the item **total** in the summary
line — `Standards: 1 would break, 0 fail open, of 3;` at `tests/spec-review/review-comment.sh:262`,
`:282`, `:320`, `:337`, `:379`, `:523`, and `1 would break of 3;` at
`tests/spec-review/review-brief.sh:257`. A mechanical rewrite of `of 3` would corrupt those. The safe
anchor is the full line `^round: [0-9]+ of 3$`.

### 4. `above()`, `judged()`, and a full `accept` with a `fixed:` mark

The helpers, `tests/spec-review/review-comment.sh:668-677`:

```sh
# judged <S1 tail> <P1 tail> <S2 tail> <P2 tail>: the judgment with S1 and P1 under Act on, S2 and P2 under Noted.
judged() {
  printf '## Act on\n\n1. [S1] **Hook exits 0 on a miss.** The test proves it.%s\n2. [P1] **Sweep form ignores --ticket.** The commit list is empty there.%s\n\n## Ask\n\n## Consider\n\n## Noted\n\n3. [S2] **Bare number.** The constant is named two lines up.%s\n4. [P2] **Token in the log.** Data retention is settled.%s\n\n## Dismissed\n' "$1" "$2" "$3" "$4" > "$dir/judgment.md"
}
# breach <S2 tail>: the judgment with S1, P1 and S2 under Act on, P2 under Noted.
breach() {
  printf '## Act on\n\n1. [S1] **Hook exits 0 on a miss.** The test proves it.\n2. [P1] **Sweep form ignores --ticket.** The commit list is empty there.\n3. [S2] **Bare number.** The constant is named two lines up.%s\n\n## Ask\n\n## Consider\n\n## Noted\n\n4. [P2] **Token in the log.** Data retention is settled.\n\n## Dismissed\n' "$1" > "$dir/judgment.md"
}
# above: the comment above its summary line, from the fixture files.
above() { printf '## Standards\n\n%s\n\n## Spec\n\n%s\n\n## Judgment\n\n%s' "$(cat "$dir/standards-report.md")" "$(cat "$dir/spec-report.md")" "$(cat "$dir/judgment.md")"; }
```

**The reports they build** (written at `:623-667`, right above the helpers; the block is introduced
by the comment at `:619-621`):

`$dir/standards-report.md` (`:623-641`) — headings `Would break`, `Fails open`,
`Standards breaches`, `Fix alongside`; `hard findings: 1`:

- `## Would break` holds item **1**, `**Hook exits 0 on a miss.**`, with `Documented step:`,
  `Result:` and **`spec: table 2/D`**.
- `## Fails open` is empty.
- `## Standards breaches` holds item **2**, `**Bare number.**`, with an **inert** `spec: table 9/Z`
  (inert because `specs()` only fills the reference for Would break / Fails open, `:82`).
- `## Fix alongside` is empty.

`$dir/spec-report.md` (`:643-667`) — headings `Walk`, `Would break`, `Fails open`,
`Not asked for`; `hard findings: 2`:

- `## Walk` holds two numbered lines, one carrying `spec: table 1/A` and one carrying
  `hole: table 1/A` — both invisible, because `items`/`specs` skip `Walk`.
- `## Would break` holds item **1**, `**Sweep form ignores --ticket.**`, with
  **`spec: design overlap.sh N --diff`**.
- `## Fails open` holds item **2**, `**Token in the log.**`, with **`spec: criterion 3`**.
- `## Not asked for` is empty.

`echo brief > "$dir/spec-brief.md"` at `:642` is what makes this a review *with* a spec, so the
`spec:` rule is enforced.

So `specs "$dir/standards-report.md"` yields `Would break\ttable 2/D` then
`Standards breaches\t` (empty), and `specs "$dir/spec-report.md"` yields
`Would break\tdesign overlap.sh N --diff` then `Fails open\tcriterion 3`. Those are exactly the rows a
new "is this fix a `## Would break` finding?" check would read.

**A full `accept` with a `fixed:` mark** — the closest model for a new assertion,
`tests/spec-review/review-comment.sh:684-690`:

```sh
rearm
judged " fixed: abc1234" "" "" ""
accept "$(above)

Standards: 1 would break, 0 fail open, of 2; Spec: 1 would break, 1 fail open, of 2; judged: act on 2 (1 fixed, 0 with a ticket), ask 0, consider 0, noted 2, dismissed 0; fixed point main.
round: 1 of 3
act-on items: 1" "a counted item with a spec line, fixed (1B)"
```

`rearm` (`:29-35`) restores the state an accepted run cleared; `accept <stdout> <label> [dir]`
(`:62-71`) requires exit 0, that exact stdout, and `.claude/state/review` gone.

The other `fixed:` expectation, in the earlier and longer fixture block, is
`tests/spec-review/review-comment.sh:347-381`: the judgment heredoc at `:347-366` marks
`1. [S1] ... fixed: abc1234` and `2. [P1] ... ticket: #12`, and the `accept` at `:367-381` pins

```
Standards: 1 would break, 0 fail open, of 3; Spec: 1 would break, 1 fail open, of 2; judged: act on 2 (1 fixed, 1 with a ticket), ask 1, consider 0, noted 1, dismissed 1; fixed point main.
round: 3 of 3
act-on items: 1
```

with the label `"an Act on item fixed on this PR is not counted, round 3"` and `"$dir"` as the third
argument (the state was already cleared, so the rerun names the dir).

### 5. How a vendored file is changed here

**Not `patch -p1` from the repository root.** `factory918.sh:395-399`:

```sh
while read -r p; do
  [ -n "$p" ] || continue
  if git -C "$skills" apply --check "$F918_DIR/patches/$p" 2>/dev/null; then git -C "$skills" apply "$F918_DIR/patches/$p"; echo "applied  $p"
  else echo "FAILED   $p (upstream moved; rewrite the patch)"; failed=1; fi
done < "$F918_DIR/patches/series"
```

`git apply` runs with `-C "$skills"`, where `skills="$TEMPLATE/.agents/skills"` (`:381`), and strips
one leading path component by default. So a patch's `a/spec-review/SKILL.md` resolves to
`template/.agents/skills/spec-review/SKILL.md`. `patches/series` is a plain list of patch paths
relative to `patches/`, applied top to bottom; the three in question are at `series:4`
(`pstack/poteto-mode/playbooks/babysit.md.patch`), `series:5` (`pstack/babysit/SKILL.md.patch`) and
`series:19` (`mattpocock/spec-review.SKILL.md.patch`).

The order inside `cmd_sync` matters: `keep_files` are copied out at `:387`, the vendor trees are
re-copied at `:388-391`, the kept files are restored at `:392`, and only then are the patches
replayed. `keep_files` (`:385`) is
`poteto-mode/playbooks/ticket.md poteto-mode/scripts/overlap.sh spec-review/scripts/review-brief.sh spec-review/scripts/review-comment.sh`
— so **both scripts and `ticket.md` are edited directly and need no patch**, while `SKILL.md` and the
two babysit files do.

**Regenerating `patches/mattpocock/spec-review.SKILL.md.patch`.** The pristine source is
`research/1-matt-pocock/skills-repo/skills/engineering/code-review/SKILL.md` — the path `cmd_sync`
copies from at `factory918.sh:391` (`cp -R "$matt/engineering/code-review" "$skills/spec-review"`,
with `matt="$F918_DIR/research/1-matt-pocock/skills-repo/skills"` at `:383`). The command that
reproduces the existing file **byte for byte** (verified in this lane by regenerating and diffing):

```sh
diff -u --label a/spec-review/SKILL.md --label b/spec-review/SKILL.md \
  research/1-matt-pocock/skills-repo/skills/engineering/code-review/SKILL.md \
  template/.agents/skills/spec-review/SKILL.md \
  > patches/mattpocock/spec-review.SKILL.md.patch
```

(`diff` exits 1 when the files differ, which is normal here; do not let `set -e` eat it.) The
`--label` flags are what suppress the timestamps plain `diff -u` would emit, and they are why the
patch starts directly with `---`/`+++` and carries no `diff --git` or `index` line — `git diff
--no-index` would add both. The pstack patches follow the same form against
`research/3-pstack/open-pstack-claude-code-port/plugins/pstack/skills/<skill>/...` (`factory918.sh:382`).

First 6 lines of each of the three patches:

`patches/mattpocock/spec-review.SKILL.md.patch`:
```
--- a/spec-review/SKILL.md
+++ b/spec-review/SKILL.md
@@ -1,5 +1,5 @@
 ---
-name: code-review
+name: spec-review
```

`patches/pstack/poteto-mode/playbooks/babysit.md.patch`:
```
--- a/poteto-mode/playbooks/babysit.md
+++ b/poteto-mode/playbooks/babysit.md
@@ -13,6 +13,10 @@
 5. **Order is conflicts, then review threads, then CI.** Conflicts and thread fixes both require a push that restarts checks, so CI work ahead of them is thrown away. [...]
 6. **Trust the active forge's verdict, not a green check list.** Ready means the forge agrees the PR can merge. [...]
 
```
(lines 4 and 5 are context lines, quoted here truncated at `[...]`; they are the full single-line
playbook steps.)

`patches/pstack/babysit/SKILL.md.patch`:
```
--- a/babysit/SKILL.md
+++ b/babysit/SKILL.md
@@ -37,7 +37,8 @@
    - Idle but want to catch new comments: hourly.
 
 4. **When to stop.**
```

CI enforces the loop at `.github/workflows/factory-ci.yml:34-35`: `./factory918.sh sync > /dev/null &&
git diff --exit-code && test -z "$(git status --porcelain template)"`. Editing a vendored file without
regenerating its patch fails there.

### 6. What babysit reads, in both copies

`template/.agents/skills/poteto-mode/playbooks/babysit.md:16` (a paragraph inside step 6, not step 6's
own numbered line):

> Merge-ready also needs the `spec-review` comment on the PR's latest commit to read
> `act-on items: 0`. A nonzero count, or no review comment on the latest commit, is a blocker of the
> same class as a red check, and the fix lands on this PR. Step 4's follow-up PR is not the route for
> it unless the reviewed PR has already merged. **The review runs at most three rounds on one PR; a
> comment reading `round: 3 of 3` and `act-on items: 0` makes the PR review-ready even when the fix
> commits it names come after the reviewed commit. An item under `## Ask` in that comment waits for
> the human and is not fixed on the PR; once the human answers, the orchestrator re-sorts it in the
> judgment with the answer as its reason and reruns `scripts/review-comment.sh <dir>` on the same
> reports, which is the same round.**

`template/.agents/skills/babysit/SKILL.md:40` (a bullet under step 4, "When to stop"):

> - Build is green, every comment resolved, the `spec-review` comment on the latest commit reads
>   `act-on items: 0`, branch merges cleanly → call it ready. **The review runs at most three rounds
>   on one PR; a comment reading `round: 3 of 3` and `act-on items: 0` makes the PR review-ready even
>   when the fix commits it names come after the reviewed commit. An item under `## Ask` in that
>   comment waits for the human and is not fixed on the PR; once the human answers, the orchestrator
>   re-sorts it in the judgment with the answer as its reason and reruns
>   `scripts/review-comment.sh <dir>` on the same reports, which is the same round.**

**Yes, byte-identical.** The bolded span above (from "The review runs at most three rounds" to "which
is the same round.") matches as one fixed string in both files, once each — verified with
`grep -cF` over both paths, which returned `1` and `1`.

The second sentence pair is byte-identical too — `playbooks/babysit.md:18` and `babysit/SKILL.md:41`
both read: "A review comment carrying the line `restart` names a design hole and is not a merge-ready
comment whatever its count: the Ticket playbook's Design hole section returns the work to
`architect`, and the PR is ready only when a later review comment without a `restart` line reads
`act-on items: 0`."

`SOURCES.md` item 4 (`SOURCES.md:16`), which covers `playbooks/babysit.md`:

> 4. `playbooks/babysit.md`: step 8 made conditional on an external bot being listed in
> `docs/agents/review-ladder.md`; step 6 adds `act-on items: 0` on the latest commit's `spec-review`
> comment to merge-ready, with a nonzero count or a missing review comment a blocker of the same
> class as a red check, fixed on this PR. The review runs at most three rounds on one PR: a comment
> reading `round: 3 of 3` and `act-on items: 0` makes the PR review-ready even when the fix commits
> it names come after the reviewed commit, and an Ask item waits for the human, then is re-sorted and
> the comment rebuilt with `review-comment.sh <dir>` in the same round. A review comment carrying the
> line `restart` names a design hole and is not merge-ready whatever its count; the PR is ready only
> when a later comment without that line reads `act-on items: 0`.

`SOURCES.md` item 12 (`SOURCES.md:24`), which covers `babysit/SKILL.md`:

> 12. `babysit/SKILL.md` step 4: ready also requires the `spec-review` comment on the latest commit
> to read `act-on items: 0`. The review runs at most three rounds on one PR: a comment reading
> `round: 3 of 3` and `act-on items: 0` makes the PR review-ready even when the fix commits it names
> come after the reviewed commit, and an Ask item waits for the human, then is re-sorted and the
> comment rebuilt with `review-comment.sh <dir>` in the same round. A review comment carrying the
> line `restart` names a design hole and is not merge-ready whatever its count; the PR is ready only
> when a later comment without that line reads `act-on items: 0`.

Both SOURCES entries paraphrase rather than quote, and both restate the three-round cap and the
literal `round: 3 of 3`. A change to the cap's wording touches six places for these two files: the
two vendored copies, the two patch files, and the two SOURCES entries.

### 7. What CI runs over these scripts

`.github/workflows/factory-ci.yml`, job **Factory**:

- `:18-19` ShellCheck over, among others, `template/.agents/skills/*/scripts/*.sh` and `tests/*/*.sh`
  — so both scripts and both tests are linted.
- `:24-25` `bash tests/spec-review/review-comment.sh`
- `:26-27` `bash tests/spec-review/review-brief.sh`
- `:30-31` `bash tests/spec-review/no-stale-wording.sh`
- `:32-33` `python3 tools/check_knowledge.py && python3 tools/build_knowledge.py && git diff --exit-code`
  — a DECISIONS.md edit must be followed by a rebuild, or `template/docs/factory918/DECISIONS.md`
  goes stale and this fails.
- `:34-35` `./factory918.sh sync > /dev/null && git diff --exit-code && test -z "$(git status --porcelain template)"`
  — the patches must regenerate the vendored files exactly.

Job **Fixture**, `:57-75`, "review-brief.sh briefs the apply diff inside the project":

```sh
git add -A && git commit -qm "factory918 apply"
mkdir -p /tmp/fake-gh && cp "$GITHUB_WORKSPACE/tests/spec-review/fake-gh.sh" /tmp/fake-gh/gh && chmod +x /tmp/fake-gh/gh
printf -- '## What it does\n\nApplies the factory.\n\n## Risks\n\n1. Every hook under `.claude/hooks/` is new here: `.claude/hooks/delegation.sh:1`.\n' > /tmp/blast.md
PATH="/tmp/fake-gh:$PATH" .agents/skills/spec-review/scripts/review-brief.sh HEAD~1 --ticket 1 --blast-radius /tmp/blast.md
d=.scratch/review/HEAD_1
test -s "$d/standards-brief.md" && test -s "$d/spec-brief.md"
```

It runs `review-brief.sh HEAD~1 --ticket 1 --blast-radius /tmp/blast.md` with the fake `gh` on PATH
and no `pr.json` in `/tmp/fx`, so the fake answers with a PR that has no comments
(`fake-gh.sh:20`) and the round is 1. **Its stdout is not captured or compared** — the step only
checks the exit status, then greps the two brief files.

The greps, `:66-74`, all run against `$d/standards-brief.md` and `$d/spec-brief.md`, never against
the script's stdout or a comment:

- `:67` the full definition sentence, fixed-string.
- `:68` `` `## Fails open` ``.
- `:69` fails if either brief carries `## Latent`.
- `:71` the Spec brief carries `` `## Walk` ``; `:72` the Standards brief must not.
- `:73` the Spec brief carries `The diff is cross-cutting: after the lines per documented step`;
  `:74` the Standards brief must not.
- `:75` `rm -rf .claude/state/review`.

**Would a change to the `round:` line's wording, or a new line in the comment, break a CI step that
does not go through the two test files?** No.

- No CI step greps a brief or a comment for `round:` or `act-on items:`.
- The Fixture job's `review-brief.sh` invocation ignores stdout entirely, so an extra printed line
  there is invisible to it.
- ShellCheck (`:19`) would catch a syntax or quoting regression in either script or test, nothing
  about wording.
- `no-stale-wording.sh` (`:31`) only fails on the three retired strings at
  `tests/spec-review/no-stale-wording.sh:9`; a `round:` change is invisible to it **unless** #93 adds
  the old wording to that grep list, which is the idiomatic way to retire a phrase here.
- The two knowledge/sync steps (`:33`, `:35`) fail on a DECISIONS.md edit without a rebuild, or a
  `SKILL.md`/babysit edit without a regenerated patch — which is where a prose change to the round
  wording *would* bite, not the wording itself.

So the blast radius of a `round:` change inside CI is: `tests/spec-review/review-brief.sh`,
`tests/spec-review/review-comment.sh`, and — for the prose — the sync and knowledge-rebuild steps.

### 8. DECISIONS P20, the Provisional row format, MANUAL, GLOSSARY

**P20 in full**, `docs/knowledge/core/DECISIONS.md:87`:

> | P20 | Three review rounds at most | `review-brief.sh` counts the PR's earlier review comments and
> refuses a fourth round before writing any state; the comment prints `round: N of 3`; the third
> round's Act on items are fixed on the PR by a fix lane, marked `fixed: <sha>`, not counted and not
> reviewed again; `ticket: #N` is for a finding outside the PR's scope at any round; Ask items wait
> for the human; `act-on items: 0` with `round: 3 of 3` makes the PR review-ready even when the fix
> commits follow the reviewed one. The cap is per PR, and a ticket is one PR (Ticket step 4 sends a
> multi-concern ticket back to be split). Amended 2026-09-22 (#90): a review comment carrying the
> line `restart` (a design hole, P27) ends the history; the count restarts at round one on the
> comments after it, and a `round: 3 of 3` comment carrying `restart` is not review-ready. | Manuel:
> after three passes, find the rest the hard way. Amended 2026-09-18 after #77: the cap is on
> reviews, not fixes; ticketing the last round's findings was ticket churn (#79, closed).
> 2026-09-18. |

(The generated copy is `template/docs/factory918/DECISIONS.md:79`; never edit it.)

**The Provisional section**, `docs/knowledge/core/DECISIONS.md:66-72` — heading, header row,
separator, and the first three rows:

```
## Provisional (added by agents; Manuel promotes or overrules)

| # | Decision | Choice | Reason |
|---|---|---|---|
| P1 | Dev environment isolation | No containers for the dev toolchain. Vite+'s node manager selects the Node and package-manager version each project declares. A `compose.yml` slot covers backing services when a project needs one | Decision 10 makes mobile Expo/RN, and an iOS simulator cannot run in a Linux container, so containers would split the environment in two from day one. The write hook calls `vp fmt` on every agent edit, and routing that through `docker exec` costs latency on every write. On a brownfield repo a container is the opposite of `apply` being additive. Vite+ already gives per-project version isolation for the JavaScript toolchain, `uv` gives it for Python, and CI is the gate that has to be clean. Revisit if a project brings conflicting system-level dependencies. Manuel, 2026-09-09. |
| P3 | Branch protection on private repositories | Not enforced by GitHub until Manuel chooses: GitHub Pro, public repositories, or none. Until then "the agent never merges" rests on `AGENTS.md`, the git guard hook and the human; `factory918 init` prints the protection step as a human-only step | GitHub's free plan refuses branch protection and rulesets on private repositories (verified 2026-09-16 on the M5 throwaway). Decision 8 makes repositories private by default, so the two collide and only Manuel can pick. |
| P4 | Python package name | `factory918 apply --profile python` names the package after the project directory; `--name <name>` overrides | The spec says `python/<name>` and never says where the name comes from. A default that needs no question keeps Day 0 short. |
```

Four columns: **`| P<n> | <short name> | <the choice, no trailing period> | <the reason, ending in a
name and a date> |`**, one physical line per row, no wrapping. Rows are not in numeric order (P19,
P20, P21 at `:86-88`, then P23 at `:89`, then P22 at `:90`, P27 at `:95`); new rows are appended.
Amendments are written inline in the Choice cell as `Amended <date> (#N): ...`, as P20 and P21 show.

**MANUAL.md**, `docs/knowledge/core/MANUAL.md:103` — the merge checklist item that names
`act-on items: 0`:

> 2. It is ready when: CI is green on the latest commit; `spec-review`'s last line on the latest
> commit reads `act-on items: 0` and that comment carries no `restart` line (a design hole returned
> to `architect`; the PR is ready only when a later review comment without one reads
> `act-on items: 0`); every claim in the Verification section points at evidence you could open; no
> comment is unresolved; and it does one thing. If any of those is missing, say "fix that and come
> back".

Note it says `spec-review`'s **last line**, which is `act-on items:` — it never mentions the round.
A PR that ends at round three with zero passes this sentence unchanged.

**GLOSSARY.md** — `docs/knowledge/core/GLOSSARY.md` has **no entry for a review round, a spec-review
round, `act-on items`, or the round gate**. The only line in the file containing the word is
`GLOSSARY.md:27`:

> **Grilling.** Matt's interview primitive: rounds of numbered questions; facts are the agent's to
> find, decisions the human's to make; ends when the frontier of questions is empty and the human
> confirms.

That is Matt's planning primitive, unrelated to the review gate. If #93 introduces a new term (an
"extra round", a "fix-only round", a "fixed point = the previous round's commit"), the glossary is
currently silent and a new entry would be the first one — which also means
`python3 tools/build_knowledge.py` must be rerun and `template/docs/factory918/GLOSSARY.md`
regenerated (CI `.github/workflows/factory-ci.yml:33`).

---

## What #93 has to touch (summary)

1. **`review-comment.sh`** — a new pass over `items "$dir/judgment.md" "Act on" | grep -E 'fixed: ...$'`
   that resolves each one's heading through `specs` (`:187-188`'s two lines), and a way to put the
   result and the reviewed HEAD into the comment (Answers 1 and 2). The `restart`/`round:`/`act-on
   items:` order at `:223-225` is contractual: `act-on items:` stays last (`SKILL.md:141`).
2. **`review-brief.sh`** — the round parse at `:169` (`/^round: [0-9]+ of 3$/`) and the cap at
   `:174-177`, plus a new read of the previous comment's fixed-item kinds. Old comments reading
   `of 3` must still parse if the printed form changes.
3. **Both tests**, which pin the exact strings listed in Answer 3 — `tests/spec-review/review-brief.sh`
   (14 `printed` blocks plus two inline comparisons) and `tests/spec-review/review-comment.sh`
   (22 `accept` blocks).
4. **Prose in six vendored/generated places** if the `round: N of 3` form changes:
   `spec-review/SKILL.md:25,141` (+ its patch at `patches/mattpocock/spec-review.SKILL.md.patch:20,130`),
   `poteto-mode/playbooks/babysit.md:16` (+ `patches/pstack/poteto-mode/playbooks/babysit.md.patch:7`),
   `babysit/SKILL.md:40` (+ `patches/pstack/babysit/SKILL.md.patch:8`), `SOURCES.md:16,18,24`,
   `template/docs/agents/review-ladder.md:6`.
5. **`DECISIONS.md:87` (P20)** amended inline in the Choice cell, plus a Provisional row if a new
   decision is made, then `python3 tools/build_knowledge.py`.
6. **Babysit must keep working unchanged for a PR that ends at round three** — which argues for
   leaving `round: N of 3` alone for rounds 1-3 and giving the extra rounds a distinct form, rather
   than renaming the cap to `of 5` everywhere.
7. **`docs/knowledge/core/SCENARIO-TABLE.md`** is the required design artifact: rounds are state,
   and `MANUAL.md:171` says a table is a rule for anything with "a file, exit codes, rounds, more
   than one actor".
