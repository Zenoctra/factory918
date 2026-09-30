## What to build

Split from #104 (2026-09-22) at Manuel's request.

> user: "Maybe i would like the factory to be able to have a switch with two modes. Safe, and Eco. The thing is, we have a lot of ceremony in this factory, but the fronteir models we are using these days... they dont really need a whole lot of ceremony."

> user: "I know this is a pretty substantial philosophy shift, but maybe its more like... different standards are needed for different tiers of models and we are babying Fable a little too much. [...] And if we ever find that Fable is struggling hard with something, then we can keep safe mode in the back as like the big guns."

> user: "The guys whose thing is to find surprises should stay in fresh context, but maybe the other lanes dont need to."

> agent: "So the two modes look like this to me. Safe is what ran today. Eco keeps the table-first and tests-first design step, keeps every adversarial lane in fresh context (blast radius, both reviewer axes every round, the trail review, the judge), and lets the owner do the how, the synthesis, the writer's brief, small fixes, and a one-page report itself. [...] The one thing I would not move into the owner is the writer for a table with more than a handful of cells, because the tests-first commit order was the strongest quality signal in the run and a fresh writer follows a table more faithfully than an owner that already has opinions."

> agent: "the arena's two runners plus a judge can be one runner plus a judge that reads it adversarially, since the judge's one real catch was a defect in a candidate, not a choice between two."

> agent: "The fresh writer stays. [...] Round one stays a full two-axis read, and blast radius, the judge and the trail review stay fresh. [...] And the table-first, tests-first design step stays"

> user: "I agree with your choices here."

Facts the lane starts from. In the 2026-09-22 run an owner spent about two thirds of its wall clock waiting on lanes it launched and 15 to 25 minutes on its own reasoning; of 77 delegates, nine found something that would have shipped wrong, all of them lanes that read someone else's work (blast radius, the two reviewer axes, the trail review, the arena judge); the how explorers and explainers, the review wrapper lanes, the small fix lanes and the records lanes found nothing (`.scratch/program/postmortem/delegates.md` and `summary.md` in the main checkout, untracked). The delegation hook (`template/.claude/hooks/delegation.sh`) binds the root session only; a subagent owner passes it. This ticket edits the same playbooks as #105, so it waits for #105.

## Acceptance criteria

- [ ] A tier switch exists and the playbooks read it: `safe` is today's behavior, `eco` is the set below; `docs/knowledge/core/DECISIONS.md` has a Provisional row naming the two tiers and what each keeps, and `MANUAL.md` "Execution" says how to set the tier and that `safe` is the fallback when a model struggles.
- [ ] In `eco`: the owner does `how` itself (no explorer or explainer lanes); the architect step is one runner plus a judge that reads the candidate adversarially; the owner runs the review script and launches the two reviewers directly (no review wrapper lane); the owner writes small fixes and the records commit itself; the hand-back report is one page. The writer, blast radius, both reviewer axes every round, the judge and the trail review stay fresh lanes in both tiers; the table-first, tests-first step is unchanged in both.
- [ ] The delegation hook's behavior in `eco` is decided and tested: either the hook allows the orchestrator's small fixes in `eco` under a stated size, or small fixes in a root-run ticket still go to a fix lane; the scenario table on this ticket has the row and `tests/hooks/delegation.sh` asserts it, written before the hook changes.
- [ ] The autopilot-stack playbook's owner brief names the tier and the owner follows it; a run under `eco` with the five tickets' shape would launch, per ticket, at most the writer, the blast-radius lane, the runner and judge, two reviewers per round and the trail review.
- [ ] A dated `docs/agents/ledger.md` line records the numbers the tiers were set from: the share of an owner's wall clock spent waiting on lanes, the lanes that found the outcome-changing defects, and the lanes that found nothing.

## Blocked by

- #105 (it edits the same playbooks and the digest step the eco branches refer to).


## Testing decisions

Posted by the agent 2026-09-23

Synthesized from two architect runners and a cross-judge (base A, grafts from B). Both runners took criterion 3's second branch independently: the hook reads no tier, and a root-run ticket's small fixes still go to a fix lane.

### Legend

- `block2(p)`: the hook exits 2 with the existing `write_msg p` text (P11). `pass0`: exits 0, empty stderr.
- `safe` / `eco`: the tier a ticket runs, as the contract derives it.
- Fixture tiers for table B: `none` (no tier file, today), `eco` (`echo eco >`), `junk` (`printf 'ECO\nfast\n' >`).

### Table A: resolving the tier

| World state | root-run ticket | autopilot-stack owner (own worktree) |
|---|---|---|
| A1 no tier file | `safe`, today's digest | `safe`; the brief carries no `Tier:` line |
| A2 file holds `safe` | `safe` | `safe` |
| A3 file holds `eco` | `eco`; the digest's first line is `Tier: eco` | `eco`; the root writes `Tier: eco` into the brief's digest |
| A4 any other content (`ECO`, `fast`, empty, two lines) | `safe`, and the run says once which value it did not read | same |
| A5 file changed after the ticket started | the ticket keeps its digest's tier | the brief wins; the next owner gets the new value |
| A6 the owner reads the file from its worktree | n/a | the common-dir path returns the main checkout's word; the brief still wins |

### Table B: the delegation hook under each tier (`tests/hooks/delegation.sh`)

Inserted after the sub-agent group and before `echo planning`, so the phase is `execute` and the review state is live. Each call is asserted under all three fixture tiers; every cell in a row is the same, which is the claim.

| Call | none | eco | junk |
|---|---|---|---|
| B1 orchestrator Edit `small.md`, one-line `new_string` | `block2(small.md)` | `block2(small.md)` | `block2(small.md)` |
| B2 orchestrator Edit `big.sh`, `echo 1` to `echo 0` | `block2(big.sh)` | `block2(big.sh)` | `block2(big.sh)` |
| B3 orchestrator Bash `echo x >> small.md` | `block2(small.md)` | `block2(small.md)` | `block2(small.md)` |
| B4 orchestrator Write `docs/agents/ledger.md` | `pass0` | `pass0` | `pass0` |
| B5 orchestrator Write `.claude/state/tier` | `pass0` | `pass0` | `pass0` |
| B6 orchestrator Bash `bash .claude/skills/spec-review/scripts/review-brief.sh main` | `pass0` | `pass0` | `pass0` |
| B7 agent Edit `small.md` (a subagent owner's small fix) | `pass0` | `pass0` | `pass0` |

### Table C: lanes an owner launches per ticket (criterion 4)

| Launch point | safe | eco |
|---|---|---|
| C1 `how` / `why` (Ticket step 5, Feature step 1) | explorers, explainer, investigators | none; the owner reads |
| C2 `architect` Phase B, Design hole step 2 | two runners, judge unless they converge | one runner and one judge that reads it adversarially |
| C3 Feature step 4 writer | one writer, or an arena of writers | one writer |
| C4 `blast-radius` (cross-cutting diff) | 1 | 1 |
| C5 review, each round | a review lane and its two reviewers | two reviewers, launched by the owner |
| C6 fixes, CI fixes, records | fix lanes | none for a subagent owner; a fix lane in a root-run ticket (table B) |
| C7 Feature step 7 `interrogate` | its reviewers | not run; C2's judge stands in |
| C8 trail review (Ticket step 9) | 1 | 1 |
| C9 hand-back | step 7's page for STACK-READY, the Reply otherwise | Autopilot-stack step 7's page (`## Head`, `## Criteria`, `## Review`, `## CI`, `## Flags`) every time |

### Contract

- **The tier file** is `"$(git rev-parse --git-common-dir)/../.claude/state/tier"`, the main checkout's `.claude/state/tier` from any worktree (the resolution `overlap.sh` uses for the go registry). It reads `eco` only when its content, trailing newlines aside, is exactly `eco` (`[ "$(cat "$f" 2>/dev/null)" = eco ]`); anything else, including no file or an unreadable one, is `safe`.
- **A ticket's tier** is fixed when its digest is written and is the presence of the first line `Tier: eco` in it. Under Autopilot-stack the brief's digest wins over the file.
- **safe** is every playbook step as written; with no tier file the digest and every lane are today's.
- **eco** is safe with exactly the substitutions C1, C2, C3, C5, C6 (subagent owner only), C7 and C9. The writer, blast radius, both reviewers every round, the architect judge and the trail review stay fresh lanes, and Ticket step 6's table-first, tests-first order is unchanged, in both tiers.
- **The hook reads no tier.** Its answer is a function of actor, phase, path class and review state (P11, decision 19) in both tiers.

### Test list

1. Table B: 21 `expect` lines, one per cell in row order, committed before any other change, green against the unmodified hook; the tier file is removed before `echo planning`.
2. Table A: a shell walk in the PR's Verification over a fixture main checkout and a linked worktree, one line per cell A1 to A4 and A6 (A5 is the brief-wins sentence, cited).
3. Table C: a walk in the PR's Verification mapping each of the 2026-09-22 run's 77 delegates to a C row, showing an eco ticket keeps at most the writer, blast radius, runner, judge, two reviewers per round and the trail review.

