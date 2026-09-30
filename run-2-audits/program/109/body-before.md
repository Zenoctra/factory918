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

