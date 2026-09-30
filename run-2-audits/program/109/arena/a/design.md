# #109 eco tier, candidate A: the tier is a digest line, the hook never reads it

Shape in one paragraph. The tier lives in one gitignored file in the root session's checkout,
`.claude/state/tier`, and is read exactly once per ticket, by whoever writes that ticket's digest (Ticket
step 0): the root for a root-run ticket, the root again for each autopilot-stack owner's brief. An eco digest
carries the line `Tier: eco`; a digest without it is `safe`. Owners never read the file, so the worktree trap
disappears and a mid-run change reaches only tickets started after it. Every eco rule is stated once, in Ticket
step 0 (ours, no patch), per P105; the one vendored edit is a clause in autopilot-stack step 1 naming the tier
line in the owner brief. The delegation hook does not read the tier: criterion 3 takes the second option, a
root-run ticket's small fixes still go to a fix lane, pinned by new `expect` rows under `echo eco > tier`.

## 1. Scenario table

### Legend

- `safe` / `eco`: the tier the ticket runs, as the contract below derives it.
- `block2(p)`: the hook exits 2 with the existing `write_msg p` text (P11); `block2r(p)`: exits 2 with `review_msg p`.
- `pass0`: the hook exits 0, empty stderr.
- `digest+`: the digest's first line is `Tier: eco`; `digest-`: the digest has no `Tier:` line (today's digest).
- "refused with the tool's own message": no code; the tool's own error is the answer.

### Table A: resolving the tier (who reads what, what the digest says)

Columns are the input shape: RR = a ticket run in the root session (`/poteto-mode "#N"`); AS = an owner launched
by autopilot-stack (a subagent in its own worktree); AS-old = an owner whose brief was written before this change.

| World state (root checkout) | RR | AS | AS-old |
|---|---|---|---|
| A1 no `.claude/state/tier` | `digest-`, `safe`, today's steps | `digest-` in the brief, owner `safe` | owner `safe` |
| A2 file holds `safe` | `digest-`, `safe` | `digest-`, `safe` | `safe` |
| A3 file holds `eco` (as `echo eco >` writes it) | `digest+`, `eco` | `digest+` in the brief, owner `eco` | n/a (brief predates) |
| A4 file holds anything else (`Eco`, `fast`, empty) | `digest-`, `safe`; the digest says `tier file holds "<x>", not eco; safe` | same, said once in the root's plan | `safe` |
| A5 file changed after an owner launched | the running ticket keeps its digest's tier | launched owners keep the brief's tier; the next owner gets the new one | n/a |
| A6 owner's own worktree has a `tier` file (or none) | n/a | ignored; the brief decides | ignored |
| A7 file unreadable (mode 000) | the `cat` fails, the test is false: `safe` | `safe` | `safe` |

### Table B: the delegation hook with the tier set (tests/hooks/delegation.sh)

Situation: execute phase, review state present for `big.sh` (the fixture's state at the point of insertion,
after the sub-agent rows), and `echo eco > .claude/state/tier`. The left column is today's behavior by class.

| Call | tier absent (today, by class) | tier `eco` (new row) |
|---|---|---|
| B1 orchestrator Edit `small.md`, a one-line `new_string` (the small fix) | `block2` | `block2(small.md)` |
| B2 orchestrator Edit `big.sh`, `old_string:"echo 1"`, `new_string:"echo 0"` | `block2(big.sh)` | `block2(big.sh)` |
| B3 orchestrator Bash `echo x >> small.md` | `block2` | `block2(small.md)` |
| B4 orchestrator Write `docs/agents/ledger.md` (records the root owns) | `pass0` | `pass0` |
| B5 orchestrator Write `.claude/state/tier` (setting the tier) | `pass0` | `pass0` |
| B6 orchestrator Bash `bash .claude/skills/spec-review/scripts/review-brief.sh main` (eco runs review itself) | `pass0` | `pass0` |
| B7 orchestrator Read `.scratch/review/main/diff` (the owner does not read what its reviewers read) | `block2r` | `block2r(.scratch/review/main/diff)` |
| B8 orchestrator Read `.scratch/review/main/standards-report.md` | `pass0` | `pass0` |
| B9 agent Edit `small.md` (a subagent owner's small fix) | `pass0` | `pass0` |

### Table C: lanes an owner launches per ticket (criterion 4)

| Step that launches | safe | eco |
|---|---|---|
| C1 `how` / `why` (Ticket 5, Feature 1) | explorers + explainer, investigators | none; owner reads |
| C2 `architect` Phase B and Design hole 2 | 2+ runners, judge unless converged | 1 runner + 1 adversarial judge, always |
| C3 Feature 4 writer | 1 writer, or an arena of writers | 1 writer |
| C4 `blast-radius` (cross-cutting only) | 1 | 1 |
| C5 review, each round | wrapper lane + 2 reviewers | 2 reviewers, launched by the owner |
| C6 fixes from round three, CI fixes, records | fix lane(s) | none for a subagent owner; fix lane for RR (table B) |
| C7 Feature 7 `interrogate` (contested design) | reviewers | not run; C2's judge stands in |
| C8 trail review (Ticket 9) | 1 | 1 |
| C9 hand-back | step 7's page for STACK-READY; Reply otherwise | step 7's page for every hand-back |

Outside the owner's count in both tiers: the owner lane itself and the root's STACK-READY swarm (autopilot-stack
step 4), which is the root's verification, not the ticket's work.

### Contract

- **The tier test** is the one command `[ "$(cat .claude/state/tier 2>/dev/null)" = eco ]`, run by the digest's
  writer in the root session's checkout. True means `eco`; anything else, including a missing file, means `safe`.
  `$(...)` strips the trailing newline `echo eco >` writes; no other normalisation (A4: `Eco` is safe).
- **The tier of a ticket** is fixed when its digest is written and is the presence of the line `Tier: eco` in it.
  Nothing re-reads the file mid-ticket. An owner's brief carries its digest, so the owner reads no file.
- **safe** is every playbook step as written; the digest is byte-for-byte today's.
- **eco** is `safe` with exactly the substitutions C1, C2, C3, C5, C6 (subagent owner only), C7, C9.
- **Small fix**: a round's Act on items, a CI fix, a rebase slice, the records commit. Nothing measures size; the
  hook's answer is by actor, phase, path class and review state only, in both tiers (P11, decision 19).
- **Fresh lane**: a subagent launched with a brief, never the owner's context: the writer, blast radius, each
  reviewer, the architect judge, the trail review. Fresh in both tiers.

### Test list (one assertion per cell, in cell order)

Table A is prose run by an agent; its assertions are a shell walk in the PR's Verification, each a fixture state
of `.scratch/109/tier-walk/.claude/state/tier` and the tier test's result:
1. A1 no file: test false. 2. A2 `safe`: false. 3. A3 `echo eco >`: true. 4. A4 `Eco`: false; `fast`: false;
empty file: false. 5. A5, A6: walked, not run (the owner reads no file; cited to the Ticket step 0 sentence).
6. A7 `chmod 000` on the file: false, no stderr (the `cat` error is redirected).
7. AS-old: an existing digest under `.scratch/program/` has no `Tier:` line, which reads as `safe`.

Table B, as `expect` lines in `tests/hooks/delegation.sh`, inserted after the sub-agent block (line 126) and
before `echo planning` (line 128), written in the first commit:

```bash
echo eco > .claude/state/tier
edit() { jq -cn --arg p "$fx/$1" --arg o "$2" --arg n "$3" '{file_path:$p,old_string:$o,new_string:$n}'; }
expect 2 "$(write_msg small.md)" orchestrator Edit "$(edit small.md 1 0)" "eco: orchestrator one-line Edit of small.md"
expect 2 "$(write_msg big.sh)" orchestrator Edit "$(edit big.sh 'echo 1' 'echo 0')" "eco: orchestrator one-line Edit of big.sh"
expect 2 "$(write_msg small.md)" orchestrator Bash "$(bash_cmd 'echo x >> small.md')" "eco: append to small.md"
expect 0 "" orchestrator Write "$(path docs/agents/ledger.md)" "eco: Write to the ledger"
expect 0 "" orchestrator Write "$(path .claude/state/tier)" "eco: Write the tier file"
expect 0 "" orchestrator Bash "$(bash_cmd 'bash .claude/skills/spec-review/scripts/review-brief.sh main')" "eco: the owner runs review-brief.sh"
expect 2 "$(review_msg .scratch/review/main/diff)" orchestrator Read "$(path .scratch/review/main/diff)" "eco: Read of the review diff under review"
expect 0 "" orchestrator Read "$(path .scratch/review/main/standards-report.md)" "eco: Read of a report under review"
expect 0 "" agent Edit "$(edit small.md 1 0)" "eco: sub-agent Edit of small.md"
rm .claude/state/tier
```

Only eco rows are new: the contract says the hook's answer is tier-independent, and the left column is already
covered by class. The rows pass against today's hook: the decision is no hook change, and the rows are the fence
that fails the first edit making the hook read the tier. The count printed at the end grows by nine.

Table C: the proof is a count walk in the PR's Verification (section 3, criterion 4).

## 2. File-by-file change list

1. `template/.agents/skills/poteto-mode/playbooks/ticket.md` (ours, `keep_files`, edited directly).
   a. Step 0, a fifth bullet after the `gh issue edit --body-file` bullet:

   > - **The tier.** A ticket runs `eco` when `[ "$(cat .claude/state/tier 2>/dev/null)" = eco ]` holds in the
   >   root session's checkout at the time its digest is written, and `safe` otherwise; an eco digest's first line
   >   is `Tier: eco`, and a digest without it is `safe`. The root writes that line into each eco owner's brief
   >   under Autopilot-stack, and an owner reads its brief, never the file. `safe` is every step as written. `eco`
   >   changes these and nothing else:
   >   1. `how` and `why` (step 5, Feature step 1) are your own reading; launch no explorer, explainer or
   >      investigator lane.
   >   2. `architect` Phase B, and Design hole step 2, is one runner (the first `architect runners` descriptor)
   >      and one judge from `arena cross-judge pool` on another model, briefed to read the candidate
   >      adversarially against the ticket's criteria and `architect`'s design red flags and to return its
   >      defects, not a base; you fix them in the synthesis. Feature step 4 briefs one writer, never an arena,
   >      and Feature step 7's `interrogate` is not run.
   >   3. You run `spec-review` yourself rather than in a review lane: its step 1 script, its two reviewers
   >      launched by you and polled per the poll rule, its judgment and its comment. The reviewers are the fresh
   >      context `AGENTS.md` asks for.
   >   4. An owner that is a subagent writes its small fixes (a round's Act on items, a CI fix, its slice of a
   >      rebase) and its records commit itself, with the red-first proof Feature step 5 asks of a fix lane. In
   >      the root session the delegation hook blocks a lane's file in both tiers, so a ticket run there briefs a
   >      fix lane as in `safe`.
   >   5. Every hand-back, the Reply below and each STACK-READY report, is Autopilot-stack step 7's one page.
   >
   >   In both tiers the writer, `blast-radius`, both reviewers every round, the architect judge and the trail
   >   review are fresh lanes, and step 6's table-first, tests-first order is unchanged. So an eco owner launches
   >   per ticket at most one writer, one blast-radius lane, one runner and one judge, two reviewers per round and
   >   one trail review; it logs each launch as a trail row, so the trail review can count them.

   b. Design hole step 2: "Two runners; the judge is skipped when they converge." becomes "Two runners, the judge
   skipped when they converge; in `eco`, one runner and the judge (step 0, "The tier")."

2. `template/.agents/skills/poteto-mode/playbooks/autopilot-stack.md` (vendored; the existing
   `patches/pstack/poteto-mode/playbooks/autopilot-stack.md.patch`, regenerated with `diff -u` against
   `research/3-pstack/open-pstack-claude-code-port/plugins/pstack/skills/poteto-mode/playbooks/autopilot-stack.md`;
   no new `series` line). Step 1: "then reading the digest (Ticket step 0) its brief carries;" becomes "then
   reading the digest (Ticket step 0) its brief carries, whose first line is `Tier: eco` when the root's tier file
   said eco at that owner's launch, and following that tier;". `SOURCES.md` item 11 gains: "Step 1 also names the
   tier line the root writes into each owner's digest (#109, Ticket step 0 "The tier")."

3. `tests/hooks/delegation.sh` (ours). The eleven lines in section 1, Table B, as the first commit.

4. `template/.claude/hooks/delegation.sh`. No change.

5. `docs/knowledge/core/MANUAL.md` (hand-maintained), `## Execution`, a new paragraph after the
   `/poteto-mode "#42"` paragraph and before **Several at once.**:

   > **Safe and eco.** A run has a tier. `safe`, the default, is every playbook as written. `eco` keeps fresh
   > every lane whose job is finding someone else's mistakes (the writer, blast radius, both reviewers every
   > round, the architect judge and the trail review) and has the owner do the rest: its own `how` reading, one
   > architect runner instead of two, the review without a wrapper lane, its own small fixes and records, and a
   > one-page report. Set it with `echo eco > .claude/state/tier` before starting; `rm .claude/state/tier` goes
   > back to `safe`. The tier is read when a ticket starts and carried in each autopilot-stack owner's brief, so
   > a change reaches only tickets started after it. When a model struggles in `eco` (a restart, a fifth review
   > round, a verifier finding what the owner missed), rerun the ticket in `safe`. The delegation hook guards the
   > session you type into the same way in both tiers, so owning small fixes is an autopilot-stack owner's; a
   > ticket you run directly still briefs a fix lane. The full list is Ticket step 0, "The tier".

   Then `python3 tools/build_knowledge.py` (it renumbers `## Contents` and regenerates
   `template/docs/factory918/MANUAL.md`).

6. `docs/knowledge/core/DECISIONS.md`, Provisional, a row after P111 (id by ticket, P110):

   > | P109 | How much ceremony a run pays (#109) | Two tiers, set by `.claude/state/tier` (absent means `safe`) and
   > carried as a `Tier: eco` digest line, never re-read by an owner. `safe` keeps every step as written. `eco`
   > keeps the writer, blast radius, both reviewer axes every round, the architect judge and the trail review as
   > fresh lanes and the table-first, tests-first step unchanged, and has the owner do `how` and `why` itself,
   > run one architect runner plus an adversarial judge, run `spec-review` without a wrapper lane, write its own
   > small fixes and records commit when it is a subagent, and hand back one page. The delegation hook reads no
   > tier: in the root session small fixes go to a fix lane in both tiers. Amends P11 for a subagent owner in
   > `eco` | On 2026-09-22 about 70% of an owner's wall clock was waiting on lanes, and of 77 delegates the nine
   > that changed the outcome all read someone else's work; the how lanes, review wrappers, small fix lanes and
   > records lanes found nothing. The hook cannot measure a fix's size on every write route (a heredoc body is
   > dropped, an interpreter write is missed, #132), so a size allowance would be a rule it cannot hold |

   P11's Choice cell gains at its end: "Amended 2026-09-23 (#109, P109): in `eco` a subagent owner writes its own
   small fixes and records commit; the root session is unchanged."

7. `docs/agents/ledger.md`: the owner's dated line (criterion 5); outside this design.

Not touched: `review-brief.sh` and its test (#108), `mode.sh`, the `how`, `architect`, `arena` and `spec-review`
skill files, `feature.md`, `template/AGENTS.md`, `review-ladder.md`, `factory918.sh`.

## 3. Rationale

### Problem

Eco changes lanes launched from six vendored skills and playbooks, the tier must reach an owner in another
worktree, and the one mechanical actor, the delegation hook, cannot see a fix's size. Safe must stay byte-for-byte.

### Usage (caller's view)

```bash
echo eco > .claude/state/tier             # Manuel, before a run
/poteto-mode "autopilot-stack #88 #89"    # root: each owner's digest opens with "Tier: eco"
rm .claude/state/tier                     # back to safe, for tickets started after this
```

An owner's brief opens `Tier: eco`, then the digest; the owner runs Ticket step 0's five substitutions. A root-run
eco ticket: the root's own digest opens `Tier: eco`, and from round three its fixes go to a fix lane.

### Shape

The data is one bit per ticket, snapshotted at digest time. One reader of the file (the digest's writer), one
carrier (the digest line), one statement of the rule (Ticket step 0), per P105 and single source of truth. The
hook stays a pure function of actor, phase, path class and review state (decision 19): adding the tier would add
a dimension to every row for a behavior only the root has, and the root is where the hook cannot measure size.
Safe is untouched because the eco digest line is additive and its absence is today's digest.

### Criterion 3: why the fix lane, not a size allowance

A size rule needs `new_string`/`content` parsed (a new jq field, renumbering `field '7,$p'`) and still leaves
three write routes unmeasured: `NotebookEdit`, Bash heredocs (bodies dropped by `tokens()`), and interpreter
writes (#132). The ticket forbids leaning on the Bash matching for it, so the allowance would hold on `Edit` and
`Write` only, and a big edit would route through a heredoc: a rule the hook states and cannot hold. The fix lane's
cost falls only on root-run tickets; the run the tiers were set from was five autopilot-stack owners, subagents
that write their own fixes in eco with no hook involved. P11's "by path, not by size" stays true for the root.

### Criterion 4: how the count is proven

A walk in the PR's Verification: take `.scratch/program/postmortem/delegates.md`'s 77 delegates, give each its
table C row, and show that per ticket the eco-kept ones are at most writer, blast radius, runner, judge, two
reviewers per round and trail review, and that every other delegate falls in a row eco drops. A second walk greps
the playbooks an owner reaches (`ticket.md`, `feature.md`, `babysit.md`, `opening-a-pr.md`, `architect`, `arena`,
`spec-review`, `blast-radius`, `show-me-your-work`) for launch words (lane, subagent, runner, judge, dispatch,
spawn) and maps each hit to a C row. Going forward, the trail row per launch lets the trail review count a live run.

### Synthesis decision

Left for the arena.

### Tradeoffs accepted

- We accept a root-run eco ticket still paying a fix lane, in exchange for a hook with no rule it cannot enforce.
- We accept vendored skills (`architect` "Design it twice", `how` Step 2, `spec-review` step 4 framing) reading as
  safe, in exchange for one patch instead of six; Ticket step 0 is read first and says it overrides them.
- We accept nine hook rows that pass before and after, because the decision is "no change" and the rows fence a
  later tier-reading edit.
- We accept no per-turn `TIER:` line from `mode.sh`, so a person sees the tier only with `cat`; the digest line is
  what the agent acts on.
- We accept that Table A's assertions are a walk, not a committed test, because the command lives in prose.

### Alternatives considered

- Tier under `git rev-parse --git-common-dir`, read by owners directly (like overlap's program file). Lost: two
  readers can disagree mid-run, and the brief must name the tier anyway (criterion 4).
- The hook reads the tier and allows orchestrator `Edit`/`Write` under N lines in eco. Lost as above:
  unenforceable on heredocs, notebooks and interpreters, and it widens every hook row by a dimension.
- `mode.sh` prints `TIER: eco` every turn, with `/tier-eco` and `/tier-safe` setter skills like mode-plan. Lost:
  the root's prompt context never reaches a subagent owner, so the brief line is needed anyway; it adds two skills
  and a hook change for a display.
- Eco branches patched into each vendored skill. Lost: six patches and SOURCES items against P105's precedent,
  and each skill would need to know how to read the tier.

### Open questions and risks

- Does the root's STACK-READY swarm count against criterion 4's "per ticket"? This design says no, it is the
  root's gate. Should eco slim it too?
- `why` and Feature step 7's `interrogate` are not in Manuel's quoted list; this design drops their lanes in eco
  so criterion 4's cap holds. Is that inside what he settled?
- Will an owner reading `architect`'s "Design it twice" follow Ticket step 0 instead? The first eco run's trail
  review is where a miss would show.
- `template/AGENTS.md` and `review-ladder.md` say to run `spec-review` "in a fresh context"; eco reads that as the
  reviewers being fresh. A Spec reviewer may call it a contradiction; the ticket.md sentence names it.

### Next implementation step

Commit the nine `expect` rows in `tests/hooks/delegation.sh` and run it green against the unchanged hook.
