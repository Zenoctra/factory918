The background search is back. It doesn't change any of the five questions, but it sharpens three of my recommendations. Round one is still open.

**What it found:**
- **The old test missed real harm.** The answer-key audit found one case clearly. The Standards review brief made reviewers cite the ticket for any serious bug, but the brief never showed them the ticket. So honest reviewers downgraded real bugs. That rule limited what counted as a finding; it didn't limit reading. The constraints audit had classed it as "report format, keep", and only caught it in a late addendum. The research for this map (on its own branch, not merged) reaches the same conclusion from the human studies. The costliest limits are bars on what may be reported, specific goals on complex tasks, and step-by-step orders to experts. Limits on reading are only one of these.
- **Some rules about the route did good.** The mandatory review of the decision trail caught the owner's mistakes 3 times out of 3. The blast-radius rule came from a hook bug that survived four review rounds. The delegation rule needed a hook because the prose alone was broken knowingly. Every one of these was set by you, with a reason drawn from something that went wrong.
- **The factory has five ways to depart from a rule, and they disagree.** `template/AGENTS.md` has two of them three lines apart:
  - line 16 says "follow the file and tell me why your instinct differed";
  - line 20 says "say so loudly and get a sign-off before breaking it".

  Neither says what a subagent does, since it has nobody to ask. Then there are `skip: <reason>`, `accepted: <reason>`, and "a writer that cannot implement a cell as written stops and reports the cell" (a cell is one row of a ticket's test table). None of these were audited.
- **Many rules carry no reason.** Examples are "never an arena", the 150-line read cap in the `knowledge` skill, and "Do exactly the task in your prompt" on the tier agents. Most of the audits' recommendations haven't been applied yet.

**How this changes my recommendations:**
- **Q1:** The route rules that did good support (a) and (b) together: they bind because you set them, and each came with a reason. The answer-key case adds a refinement. A rule about the report can fix where results go and what shape they take. It must never decide which results count.
- **Q2:** The research gives one counterweight. Specific method does help on simple tasks and for inexperienced readers. A weak model on a mechanical job may be that reader. So (b) stands, with this case named: a step-by-step method is fine when the writer judges the task is simple. It still comes with the reason, and the reader still reports any departure.
- **Q3:** (a) is close to what the "stops and reports the cell" rule already does. Whatever you pick, I'd make it the single mechanism and fold the five into it. Rewriting the existing text belongs to "Decide the scope and order of reworking existing files"; this ticket would only record the decision.

A later round will ask whether this decision conflicts with two of PHILOSOPHY's beliefs. Belief 3 pushes rules down to the strongest level of enforcement, where nothing in the prose can override them. Belief 7 prefers a copied pattern over reasoning from first principles. That question depends on your Q1 answer, so it waits.

One thing outside this ticket: `MANUAL.md:168` still says PHILOSOPHY has "twelve ordered beliefs", but it has had eleven since the cost belief was removed. Want me to file a quick ticket for it?

Your answers to Q1–Q5 are next.