The background search has finished. Round one is still waiting on your answers. Here is what it found that affects those questions; the full report cites file and line for everything.

**On Q1: your correction holds up in the factory's own record.** The run-2 constraints audit sorted limits with the old split: what a subagent may look at or run were the suspect classes, and safety and report format were kept. It filed the `spec:` gate under report format and skipped it. Its own late addendum admits that rule did comparable damage. Reviewers had to cite a ticket they were never shown. Sol filed nothing on PR 99, which had four hard bugs, and Fable demoted a real bug for that reason. That rule is about how the work is finished, not about search. The record also shows rules about the route that did good:
- The mandatory trail review caught an owner's error three times out of three.
- The delegation rule was broken knowingly until a hook held it.
- A narrow grounding let a day-zero hook bug survive four review rounds.

So Q1 needs a test that can keep rules like those, which is why I lean on who owns a rule rather than on what it's about.

**On Q3: the factory already has five ways out of a rule, and they disagree:**
- **Sign-off.** "Say so loudly and get a sign-off" is Theo's line, copied in. Nothing records it ever being used. No text says how a subagent would get a sign-off, and it pulls against "never block on the human".
- **Comply first.** `template/AGENTS.md:16` says the opposite: follow the file, then explain why your instinct differed.
- **Skip with a reason.** pstack's `skip: <reason>` lets a step be skipped visibly. `feature.md` turns it off for delegation.
- **Record a call.** Where the spec is silent, the agent decides and adds a Provisional row to DECISIONS for you to overrule.
- **Account for every flag.** The review script refuses to run until each writer flag ends in `fixed:` or `accepted: <reason>`.

None of the run-2 audits looked at these. My recommendation (a) for Q3 would replace the sign-off line and the comply-first line, so whatever you decide there means editing both AGENTS files. That's work for the rework ticket, not this one.

**On Q2:** the research branch for "Research how wording and missing context shape a reader's response" finds that spelled-out method helps on simple tasks and inexperienced readers, and hurts experts on complex ones. It also separates the writer holding back what it volunteers from the writer limiting what the reader may look for. Both fit (b): route knowledge offered with its reason, which the reader can weigh.

One question the search raised that doesn't depend on the others, so it joins this round:

❓ **Q6 - Do binding rules carry their reason too?** Reasons are attached unevenly today. These have none:
- "never an arena"
- "Read no brief and no diff while the review state exists"
- the 150-line read cap
- "Subagents never launch their own dev servers", whose reason from Theo was dropped when it was copied in
- "Do exactly the task in your prompt" in the tier agents

DECISIONS is the only place that requires a reason. The options:
- (a) Every binding rule states its reason where it's written.
- (b) A reason only where the rule would surprise a reader.
- (c) The reason stays in DECISIONS and the rule points there.

➡️ (a). The reason is what lets a reader see that a binding rule doesn't fit its case and report the conflict under Q3, instead of obeying it into a bad result or quietly breaking it. It also lets someone deleting rules later tell which ones are guesses: a rule nobody can give a reason for, like the 150-line cap, is probably one.

One unrelated thing the search spotted: `MANUAL.md:168` still says "twelve ordered beliefs", but PHILOSOPHY has had eleven since the cost belief was removed. It's outside this ticket, so I'll file it as a quick ticket unless you'd rather fold it into something else.

Your answers to Q1–Q6 decide the next round. Questions waiting on them include how a rule enforced by a hook fits Q3, since a hook allows no override in prose.