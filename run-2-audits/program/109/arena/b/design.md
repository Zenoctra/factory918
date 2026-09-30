# #109 eco tier, candidate B

The shape in one line: the tier is one word in one file that no hook reads, stated once in Ticket step 0 and
pointed at from everywhere else, and the delegation hook's policy does not change at all.

## Scenario table

### Legend

Cell vocabulary, defined once.

- `allow (0)` — the hook prints nothing and exits 0; the call proceeds.
- `block-write (2)` — exit 2 with `write_msg <path>` verbatim (`tests/hooks/delegation.sh:30`); the caller briefs
  a writer lane with the paths, the data shape and the criteria, then reviews the returned diff.
- `block-read (2)` — exit 2 with `review_msg <path>` or `diff_msg` verbatim (`:31`, `:33`); the caller waits for
  the reviewers' reports, which are readable.
- `bypass (0)` — `delegation.sh:15` returns before any policy; the call proceeds and nothing is printed.
- `lanes:safe` — today's lane set, byte for byte.
- `lanes:eco` — the set in the contract below.
- `= row 3` — the same fixture and the same verdict as row 3's cell, because the hook's parsed input
  (`delegation.sh:9-11`, seven fields) contains no tier and no brief. Not re-asserted; the invariance is what
  rows 1 to 4 assert.

### Table

Situations down the side are the states the tier can be in. Across the top is the shape of the call.

| Situation | A. root Write/Edit of a tracked lane file | B. root runs `review-brief.sh <fp>` | C. root reads the diff under review | D. owner subagent writes a tracked lane file | E. the run's lane set |
|---|---|---|---|---|---|
| 1. No tier file | `block-write (2)` | `allow (0)` | `block-read (2)` | `bypass (0)` | `lanes:safe` |
| 2. `safe` | `block-write (2)` | `allow (0)` | `block-read (2)` | `bypass (0)` | `lanes:safe` |
| 3. `eco` | `block-write (2)` | `allow (0)` | `block-read (2)` | `bypass (0)` | `lanes:eco` |
| 4. A value that is not `safe` or `eco` (`ECO`, `fast`, empty, two lines) | `block-write (2)` | `allow (0)` | `block-read (2)` | `bypass (0)` | `lanes:safe`, and the run says once which value it could not read |
| 5. `eco` in the main checkout, the actor in a linked worktree | `block-write (2)` | `= row 3` | `= row 3` | `= row 3` | `lanes:eco`; the common-dir read returns the root's word |
| 6. The brief says `eco`, the file has since become `safe` | `= row 3` | `= row 3` | `= row 3` | `= row 3` | `lanes:eco` for this run; the tier is frozen at launch |

Column B is the eco owner's own review round: running the script is a write under `.claude/state/*`, which
`classify()` calls `untracked` (`delegation.sh:47`), so it is allowed in every row. Column C is the edge that
makes column B safe to use: the owner passes each reviewer its brief's path and never reads a brief itself.

### Contract

**Tier.** One word, `safe` or `eco`, held in the file `"$(git rev-parse --git-common-dir)/../.claude/state/tier"`.
That path is the main checkout's `.claude/state/tier` from any linked worktree, the resolution
`poteto-mode/scripts/overlap.sh:22` already uses for the go registry. No file, an unreadable file, or any other
content reads `safe`.

**Who writes it.** A person, or the root session on her word, with one `echo`. Nothing in the factory writes it
as a side effect. It is already gitignored (`.gitignore:7`, `template/.gitignore.factory:5`), already classified
`untracked` by the hook, and already absent from `apply`'s copy loop, so this design adds no new machinery
anywhere: no ignore line, no manifest entry, no `apply` change, no new script, no new skill.

**Frozen per run.** A run's tier is the value read at its first step, recorded in its digest and in its trail's
first row. An owner takes the tier from its brief. If the brief and the file disagree, the brief wins, because a
run that changed tier halfway would produce a stack of PRs built to two standards and a reviewer with no way to
know which applied to which.

**`lanes:safe`.** Every lane the factory launches today, unchanged in count, prompt and model.

**`lanes:eco`.** Fresh lanes: the writer, the blast-radius lane, one architect runner, the arena judge, both
review axes every round, the trail review. The owner does itself: `how` (no explorer and no explainer lane), the
design synthesis, running `review-brief.sh` and launching the two reviewers directly (no review wrapper lane),
the small fixes it is allowed to write, the records commit, and a one-page hand-back under Autopilot-stack step
7's five headings. Unchanged in both tiers: Ticket step 6's table-first, tests-first order, and every rule about
what a lane is briefed with.

**The hook is tier-blind.** `template/.claude/hooks/delegation.sh` does not read the tier and its policy does not
change. In `eco` a small fix a root session cannot write under the guard still goes to a fix lane. The eco
affordance the ticket asks for is delivered by the bypass that already exists: an autopilot-stack owner is a
subagent (`delegation.sh:15`), so it writes its own small fixes and its own records commit in both tiers.

**Safe is byte for byte.** With no tier file every hook verdict, every message and every lane count is what it is
at `origin/main`. Rows 1 and 2 are the same row for a reason: a checkout that never hears of this ticket is in
row 1 and behaves as row 2.

### Test list

One assertion per cell, in the order the cells are written. Every hook cell is one `expect` line in
`tests/hooks/delegation.sh`, written before any hook edit; there is no hook edit, so they pass on the first run
and that is the fact being recorded. Fixture state named per line.

Row 1 is asserted today and gains no line: 1A is `:65`, 1B is the `.claude/state` allow at `:86`, 1C is the
`git diff` block in the review-state group at `:104-116`, 1D is `:118-125`. The new lines go after the
planning-phase group at `:131`.

1. `echo safe > .claude/state/tier`, then 2A: `expect 2 "$(write_msg big.sh)" orchestrator Write "$(path big.sh)" "safe tier: Write to big.sh"`.
2. 2B: `expect 0 "" orchestrator Write "$(path .claude/state/review/files)" "safe tier: write of the review state"`.
3. 2C: `expect 2 "$diff_msg" orchestrator Bash "$(bash_cmd 'git diff main...HEAD')" "safe tier: git diff under review"`.
4. 2D: `expect 0 "" agent Write "$(path big.sh)" "safe tier: sub-agent Write to big.sh"`.
5. `echo eco > .claude/state/tier`, then 3A: the same call, label `eco tier: Write to big.sh`, the same expected message.
6. 3B: the same call as 2B, label `eco tier: write of the review state`.
7. 3C: the same call as 2C, label `eco tier: git diff under review`.
8. 3D: the same call as 2D, label `eco tier: sub-agent Write to big.sh`.
9. `printf 'ECO\nfast\n' > .claude/state/tier`, then 4A: the same call, label `unreadable tier: Write to big.sh`.
10. 4B, 11. 4C, 12. 4D: the same three calls under that fixture, labels prefixed `unreadable tier:`.
13. 5A: `git worktree add ../wt -b wt-fixture` in the fixture, `export CLAUDE_PROJECT_DIR="$fx/../wt"`, the same
    Write call, the same expected message, label `linked worktree: Write to big.sh`; then restore
    `CLAUDE_PROJECT_DIR`. This is the one row-5 cell with a fixture the hook can see.
14. Cells 5B to 5D and 6A to 6D: `= row 3`, not re-asserted. Justification, not assumption: the hook's whole
    input is the seven fields at `delegation.sh:9-11`, none of which is the tier file or the brief, so no cell
    that differs only in those two can differ in verdict. Rows 2 to 4 are what prove it.
15. Column E, six cells: not hook assertions. Proved by the derived launch count below, reproduced in the PR's
    Verification section as a walk over the five tickets' shape.

The fixture removes the tier file before the degraded-review group, so the existing tail is untouched and only
the `ok $n assertions` count moves.

### The derived launch count (criterion 4)

Every point in a ticket run that launches a lane, from the playbooks as they will read after this change.

| Launch point | Safe | Eco |
|---|---|---|
| Ticket step 5 into Feature step 1, `how` | 2 to 4 explorers plus 1 explainer | 0, the owner does it |
| Feature step 2, `architect` Phase A | the same `how` again when it re-grounds | 0 |
| `architect` Phase B, arena runners | 2 or more | 1 |
| arena cross-judge | 1 | 1 |
| Ticket step 5, blast radius | 1 | 1 |
| Feature step 4, the writer | 1 | 1 |
| Ticket step 8, the review wrapper | 1 per round | 0 |
| `spec-review` step 4, the two axes | 2 per round | 2 per round |
| Would-break fix, from round three | 1 per round | 0 under an owner; 1 per fix round in a root-run ticket |
| The records commit | 1 | 0 |
| Ticket step 9, the trail review | 1 | 1 |

Eco under the five tickets' shape, per ticket: the writer, the blast-radius lane, one runner, the judge, two
reviewers a round, the trail review. Exactly criterion 4's list. The one caveat the criterion's wording hides:
the count holds because an autopilot owner is a subagent the guard does not bind. A ticket run from the root
session in `eco` adds one fix lane per fix round, and the contract says so rather than pretending otherwise.

## File-by-file change list

Two vendored files, both through patches that already exist and are already in `series`. No new patch file, no
new `series` line, no new skill, no new script, no hook edit.

1. **`docs/knowledge/core/DECISIONS.md`** (ours, direct). A Provisional row `P109` (id from the ticket, P110).
   Choice column: "Two tiers, one word in `"$(git rev-parse --git-common-dir)/../.claude/state/tier"`, no file
   and any unreadable value meaning `safe`, frozen for a run at its first step and named in the owner's brief.
   `safe` is every lane the factory launched on 2026-09-22. `eco` keeps fresh every lane whose job is to read
   someone else's work (the writer, blast radius, one architect runner, the arena judge, both review axes every
   round, the trail review) and moves into the owner the `how`, the design synthesis, the review wrapper, the
   small fixes, the records commit and a one-page hand-back. The table-first, tests-first step is the same in
   both. `template/.claude/hooks/delegation.sh` reads no tier and changes no policy, so a small fix the root
   session cannot write still goes to a fix lane; an autopilot owner writes its own, being a subagent."
   Reason column: the run's numbers (70 percent of an owner's wall clock waiting on lanes or with its turn
   ended, 53 percent waiting on children alone, 9 of 77 lanes changed the outcome and all nine read someone
   else's work), Manuel's quotes on the ticket, and the rejected alternatives from this package.
2. **`docs/knowledge/core/MANUAL.md`** (ours, direct). A new bold-lead paragraph between the `/poteto-mode "#42"`
   paragraph (`:77`) and **Several at once.** (`:79`), because that is the only paragraph about how a run starts:
   "**Safe and eco.** A run has a tier. `echo eco > .claude/state/tier` in the main checkout switches it, `echo
   safe` or deleting the file switches back, and a missing or unreadable file means `safe`. It sits beside the go
   registry in the main checkout, so an owner working in its own worktree reads the same word. `safe` is the full
   ceremony above. `eco` keeps every lane whose job is to find a surprise in fresh context (the writer, blast
   radius, both review axes every round, the arena judge, the trail review) and lets the owner do the rest
   itself: the `how`, the design synthesis, running the review script, its small fixes, the records commit and a
   one-page hand-back. The table-first, tests-first design step is the same in both. Set `safe` back when a model
   is struggling with the work; it is the fallback, and a run never changes tier halfway. What each tier keeps is
   P109 in `DECISIONS.md`." Plus one line at the end of `## Models and cost`: "The tier (Execution, **Safe and
   eco.**) decides how many of these roles a ticket launches; `eco` drops the explorer, explainer, review
   wrapper, fix and records lanes." Then `python3 tools/build_knowledge.py`, which rebuilds the `## Contents`
   line numbers and the `template/docs/factory918/` mirrors, and `python3 tools/check_knowledge.py`.
3. **`template/.agents/skills/poteto-mode/playbooks/ticket.md`** (ours, direct, no patch). The rule is stated
   once, in step 0's digest bullets, and pointed at four times, per #105's precedent.
   - Step 0, a fifth bullet: "**The tier:** `cat "$(git rev-parse --git-common-dir)/../.claude/state/tier"
     2>/dev/null || echo safe`, one word, `safe` or `eco`; no file, an unreadable file or any other word reads
     `safe`. It is the main checkout's file, so an owner in its own worktree reads the root's word, and the brief
     names the word the root read at launch; when the two differ the brief wins, because a run never changes tier
     halfway. `safe` is today's lane set. In `eco` you do `how` yourself, the architect step is one runner and a
     judge that reads the candidate adversarially, you run `review-brief.sh` and launch the two reviewers
     yourself, you write the small fixes you are allowed to write and the records commit, and the hand-back is
     one page under Autopilot-stack step 7's headings; the writer, the blast-radius lane, the judge, both review
     axes every round and the trail review stay fresh lanes, and step 6's table-first, tests-first order is
     unchanged. The delegation hook reads no tier, so a small fix it blocks still goes to a fix lane (P109)."
   - Step 5, after "`how` and `why` over the affected subsystem come first in all of them.": "In `eco` you do
     them yourself and launch no explorer and no explainer lane (the tier, step 0)."
   - Step 6, after the sentence naming `architect`'s first deliverable: "In `eco` the architect step is one
     runner plus a judge that reads the candidate adversarially against the ticket and the grounding rather than
     against a sibling (the tier, step 0); the table-first order is unchanged."
   - Step 8, after "poll each review lane's result file per the poll rule (step 0)": "In `eco` there is no review
     lane: you run `scripts/review-brief.sh` yourself and launch the two reviewer subagents with their brief
     paths, then judge and aggregate. Pass each brief's path and read no brief and no diff: while the review
     state exists the guard blocks the orchestrator from the files under review, and it blocks them in both
     tiers (the tier, step 0)."
   - Design hole, step 2, after "Two runners; the judge is skipped when they converge.": "In `eco` it is one
     runner and an adversarial judge (the tier, step 0)."
   - The **Reply:** line, appended: "In `eco` the hand-back is one page under Autopilot-stack step 7's headings."
4. **`template/.agents/skills/architect/SKILL.md`** (vendored) through the existing
   `patches/pstack/architect/SKILL.md.patch`, whose hunk already covers the Phase B block at `:29-35`. After
   "**Design it twice.**...": "A caller whose tier sets one runner (Factory918's `eco`) meets this by having the
   cross-judge read that candidate adversarially against the rubric and the grounding instead of choosing
   between siblings." Regenerate the patch with the `diff -u` form in `patches/README.md:7-9` against
   `research/3-pstack/...`, never against `template/`. Amend `SOURCES.md` item 14 with one clause naming the eco
   sentence.
5. **`template/.agents/skills/poteto-mode/playbooks/autopilot-stack.md`** (vendored) through the existing
   `patches/pstack/poteto-mode/playbooks/autopilot-stack.md.patch`. Step 1, inside the sentence about the
   digest: "...reading the digest (Ticket step 0) its brief carries, the tier among its facts; the brief's tier
   is the value for that owner's whole run." Regenerate the patch; amend `SOURCES.md` item 11 with one clause.
6. **`tests/hooks/delegation.sh`** (ours). The thirteen `expect` lines and their four fixture mutations above,
   inserted after the planning-phase group at `:131`, with the tier file removed before the degraded-review
   group.
7. **`template/.claude/hooks/delegation.sh`**: no change. Recorded as a decision in P109, not as an omission.
8. **`docs/agents/ledger.md`** (ours, the hook's `owned` list): criterion 5's dated line, the owner's to write.

Not touched: `template/.claude/hooks/mode.sh`, `how/SKILL.md`, `arena/SKILL.md`, `spec-review/SKILL.md`,
`feature.md`, `bug-fix.md`, `refactoring.md`, `perf-issue.md`, `babysit.md`, `template/AGENTS.md`,
`review-ladder.md`, `factory918.sh`, `.gitignore`, and `spec-review/scripts/review-brief.sh` (#108's).

Verification beyond the criteria: `bash tests/hooks/delegation.sh`, the ShellCheck line from AGENTS.md,
`./factory918.sh sync` leaving `git status` clean (the two regenerated patches), `python3
tools/build_knowledge.py` leaving it clean, and `python3 tools/check_knowledge.py`.

## Rationale

### Problem

The factory's ceremony was designed for models that needed it, and the 2026-09-22 run measured what it now buys:
an owner spent 70 percent of its wall clock waiting on lanes or with its turn ended, and 9 of 77 lanes found
something that would have shipped wrong, all nine of them lanes that read work someone else had done. Manuel
settled which lanes each tier keeps. What is left to design is where one word lives, how five playbooks read it
without contradicting each other, and what the delegation hook does in `eco` when it cannot see the one property
a size rule would need. Three constraints shape it. Vendored files change only through a patch, a `series` line
and a `SOURCES.md` item, and fewer is better. An autopilot owner runs in its own worktree, so per-worktree state
does not reach it. And `safe` must be byte for byte today's behavior wherever the file is absent, which is every
existing checkout.

### Usage (caller's view)

The person, once:

    $ echo eco > .claude/state/tier
    $ /poteto-mode "autopilot-stack #4 #5 #8"

The root session, writing each owner's brief:

    Tier: eco (read from /repo/.claude/state/tier at 14:02). Ticket step 0's tier bullet is your lane set.

An owner, at step 0, in its own worktree at `/repo/.claude/worktrees/agent-4`:

    $ cat "$(git rev-parse --git-common-dir)/../.claude/state/tier" 2>/dev/null || echo safe
    eco

and its first trail row records `tier=eco`. A person going back to full ceremony after a model struggled:

    $ echo safe > .claude/state/tier    # or: rm .claude/state/tier

### Shape

The data structure is one word in one file, and the design's real content is who reads it and when.

The placement is the load-bearing choice. `.claude/state/` already exists, is already gitignored in both the
factory and applied projects, is already the hook's `untracked` class, and is already outside `apply`'s copy
loop, so a file there costs nothing to introduce. Resolving it through `git rev-parse --git-common-dir` rather
than `CLAUDE_PROJECT_DIR` is what makes one word serve a root and its worktree owners, and it is not a new
pattern: `overlap.sh:22` resolves the go registry exactly that way, for exactly this reason. The brief still
names the tier, but as a frozen copy for the run, not as a second source of truth, and the contract says which
wins so no reader has to guess.

The prose structure follows #105: the rule is written once, in Ticket step 0, where the digest already collects
the facts a run paid for, and the four other sites carry a pointer rather than a restatement. That keeps the
branch in a file we own, which is why only two vendored files move, and both through patches that already exist.
It also means a reader who gets the tier wrong gets it wrong in one place. Per `laziness-protocol` and
`minimize-reader-load`: the alternative, an eco sentence in `how/SKILL.md`, `arena/SKILL.md`,
`spec-review/SKILL.md` and four pstack playbooks, is seven vendored files, two new patch files and seven places
for the tiers to drift apart.

The hook does not change, and that is a decision rather than a gap. Criterion 3 offers a size rule, and size is
the one property the hook cannot see: `guard_write` is a pure function of (subagent, work tree, phase, path
class), the `jq` filter reads no `new_string`, no `content` and no heredoc body, `tokens()` drops heredoc bodies
by design, and #132 says an interpreter writing a lane's file is missed entirely. A rule that *widens* an
allowance survives those gaps, because a route the hook misses only widens it further in the same direction. A
rule that *narrows* one, which a size cap is, fails open on every route the hook cannot parse: a three-line
`Edit` would be allowed and a three-thousand-line `python - <<EOF` would be allowed too, and the stated cap
would be a sentence the hook does not enforce. Per `boundary-discipline` and `encode-lessons-in-structure`, a
guard that cannot see the property it claims to guard should not claim it. So `eco` takes the other branch the
ticket allows, and it costs almost nothing, because the place `eco` actually runs is an autopilot owner, which
is a subagent the guard never bound. The root-run case keeps its fix lane, and the design says so out loud.

Interface depth: the public surface is one word and one sentence per reader. Behind it sit the whole lane-set
difference, the freeze rule, the worktree resolution and the hook's invariance, none of which a caller has to
know to set `eco` or to read it.

### Synthesis decision

For the arena orchestrator.

### Tradeoffs accepted

- We accept that a root-run `eco` ticket still spends one fix lane per fix round, in exchange for a guard that
  never states a limit it cannot enforce and a zero-line diff on a hook that reaches every session.
- We accept that the tier is invisible in a turn's context, in exchange for not editing `mode.sh`. A `TIER:`
  line would be the cheapest read, and it would also put this ticket's diff inside `.claude/hooks/` twice, with
  a blast radius over every session kind, for a display convenience. Step 0 is read at the start of every run
  that could act on the tier.
- We accept prose branches over a mechanism that could enforce them, in exchange for not inventing a lane
  registry no other part of the factory has. Criterion 4's count is derived and walked, not asserted by a test,
  because a grep over playbook prose passes a reworded wrong sentence and fails a reworded right one.
- We accept that `eco`'s owner may not read its own review briefs, in exchange for leaving the review guard
  untouched. It never needed to: step 4 passes paths, and the reports are readable.

### Alternatives considered

- **Per-worktree `$CLAUDE_PROJECT_DIR/.claude/state/tier`, like `mode`.** Exposes the worktree problem to every
  caller: an owner silently reads no file, defaults to `safe`, and runs full ceremony inside an `eco` program
  while its brief says otherwise. Hides nothing that the common-dir resolution does not hide.
- **Tier only in the brief, no file.** The smallest possible diff, and it loses the root-run ticket and the
  interactive session entirely, which is where a person would first try `eco`. It also leaves the human no way
  to set the tier except by typing it into a prompt.
- **A size cap in `guard_write`.** Needs an eighth parsed field, shifts the `7,$p` address, covers `Edit` and
  `Write` only, and fails open on `NotebookEdit`, on heredocs and on #132's interpreter route. Rejected above.
- **Widening `classify()`'s `owned` set in `eco`**, so a root session writes `SOURCES.md`, `patches/series` and
  `VERSION` in its records commit. This is the enforceable shape, since the path is always in the parsed input,
  and it is the right ticket to open if Manuel later wants root-run `eco` to stop spending a records lane. Out
  of scope here: criterion 3 asks for one of two branches and this is a third, and it changes what P11 means
  rather than how much ceremony a run buys.
- **An eco sentence in each vendored skill (`how`, `arena`, `spec-review`, the four pstack playbooks).** Puts
  the branch where the lane is launched, which reads well in isolation, and costs seven vendored files, two new
  patches and seven drift sites. Rejected per `laziness-protocol` and the ticket's own "fewer is better".

### Open questions and risks

- `architect`'s Phase B says "Design it twice" and cites the exhaust-the-design-space principle. `eco` overrides
  the count with an adversarial single-candidate read. Is one runner plus a hostile judge the intent, or should
  `eco` keep two runners for a ticket that reaches a design-hole restart?
- Should the trail's first row be required to carry `tier=<word>`, so the trail review can see which standard
  the run was held to? This package records it as a should, not as a refusal in `check-trail.sh` (#111's script).
- A run that starts `eco` and meets a model that struggles has to finish `eco` under the freeze rule, and the
  fallback takes effect on the next run. Is a mid-run escape hatch wanted, or is finishing and re-running the
  right answer?

### Next implementation step

Write the thirteen `expect` lines and their fixture mutations into `tests/hooks/delegation.sh` and run it green
against the unmodified hook, so the tier-blindness the whole design rests on is a passing assertion before a
word of prose is written.
