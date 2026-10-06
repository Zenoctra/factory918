Your answers are saved word for word in my scratchpad, and they'll go into the resolution comment when this ticket closes. Your budget rule is also in my memory now, since it matters well beyond this ticket.

**Q1 in practice.** Here's (c) run on four real rules:

| Rule | Is it about what's wanted, or how to get there? | Who set it? | Result |
|---|---|---|---|
| "Never push to main." | What's wanted: merging is your decision | You | Binds |
| "Read only the diff." | How to get there | An orchestrator | Doesn't bind. Only the fact under it survives: "the change is in these files." |
| "The orchestrator never writes the code." | How to get there | You, with evidence | Binds |
| "This should cut token use in half." | A prediction | The writer | Never becomes a requirement unless you say so. Your Q5 story is this exact case. |

As a rule of thumb: if a rule is about how to get there and didn't come from you, it's advice, not a rule.

**A correction on Q3.** You asked whether the evidence says both kinds of bug get found. It doesn't, and I didn't mean to suggest it does. The evidence shows that a bar in the brief cuts what gets *reported*, not what gets *found*. It says nothing about a reviewer spreading its attention evenly across kinds of bug. Your worry is a separate risk, and the gorilla evidence suggests it's real: what a reader is focused on decides what it notices. Q7 takes it up.

**Q5 as I'll record it.**
- In `safe`, a budget never shapes the process. Cost is only measured afterward.
- In `eco` and Let It Rip, a budget exists only once you set one. Before it goes into a brief as binding, you're asked how much it matters.
- When in doubt, the budget stays out of the brief. If it seems important and nobody can ask you, it goes in as information.
- A budget only binds with your approval.

This is (c) from Q1 applied to budgets, so the two answers agree.

---

❓ **Q4 - Departing from a rule (asked again, with the five spelled out).** Here is what the factory says today:

1. **Ask first.** [AGENTS.md:26](AGENTS.md:26) and [template/AGENTS.md:20](template/AGENTS.md:20): "If a rule fights the task in front of you, say so loudly and get a sign-off before breaking it." It came from Theo. It gives a subagent no way to get a sign-off, and it pulls against "never block on the human."
2. **Obey, then explain.** [template/AGENTS.md:16](template/AGENTS.md:16): when the file disagrees with the agent's instinct, "follow the file and tell me why your instinct differed."
3. **Decide and leave a record.** Where the spec says nothing, the agent makes the call and writes a Provisional row in `DECISIONS.md` for you to overrule.
4. **Skip, visibly.** poteto-mode: a step the agent chooses not to do stays on its list as `skip: <reason>`. Delegation is the exception: [feature.md:12](template/.agents/skills/poteto-mode/playbooks/feature.md:12) forbids skipping it.
5. **Stop that part and send it back up.** A writer that can't implement a test case as written stops and reports it rather than improvising. Writer flags must end `fixed:` or `accepted: <reason>` before review runs. A design hole amends the ticket.

The conflict is that 1 and 2 both claim the same situation, a rule that fights you, and give opposite answers. Nothing says which one applies when.

➡️ Keep all five, and give each one situation:

| Situation | What the reader does |
|---|---|
| The writer's advice about the route looks wrong | Takes its own route and says so in its report (4, widened) |
| A binding rule it disagrees with, but the goal is still reachable | Follows it and says why it disagreed (2) |
| A binding rule blocks the goal, and a person is present | Says so and asks (1) |
| A binding rule blocks the goal, and nobody can be asked (a subagent) | Stops that part, reports to the rule's owner, finishes the rest (5) |
| Nothing says what to do | Decides and records it for you to overrule (3) |

The reader never quietly shrinks the goal to fit a rule.

---

❓ **Q6 - How is a binding rule worded?** The options:
- (a) Plain wording, with the reason, saying what to do instead and not only what not to do, stated once.
- (b) Emphatic wording (capitals, MUST, CRITICAL) for the rules that matter most.

The research finds three problems with emphasis and bare prohibitions:
- Current Claude over-applies emphatic rules.
- A bare "don't" keeps the forbidden idea active and doesn't say where to go instead.
- A reason lets the reader handle the case the writer didn't foresee.

The git guard already works the plain way: its refusal says "Use --force-with-lease on your own branch, or ask." Your point about co-pulling terms belongs here too: fewer binding rules, each of them carrying weight.

➡️ (a). Where a binding rule lives, and whether briefs repeat a rule a hook already holds, is a placement question. It goes to the ticket "Decide where each piece lives and when it reaches the writer."

---

❓ **Q7 - The "slight push" toward the kinds of bug you care about.** The options:
- (a) No push in the open reviewer's brief. A kind of bug you're especially wary of gets its own pass, and the open pass stays open.
- (b) A light push, written as information ("we've been burned by X before"), in the single brief.
- (c) Leave it all to the review work later.

On (b): a hint moves a model's answer, and the model mentions the hint only 25–39% of the time. A light push would narrow the one reviewer in a way nobody could see. The one model study of the gorilla effect found that a separate reviewer with an open brief recovered every finding the focused one had dropped. That is your "multiple passes" point.

➡️ Settle the principle now with (a): a push never goes into the open pass. Leave the number of passes and which ones run to the review work.

---

❓ **Q8 - Where your two ideas for later go.**
- **A review system of our own.** This map plans the writing. Review also needs decisions about the process: how many passes, which lanes, which verifiers, and measuring how many planted bugs get missed. Two existing tickets touch it: "Eval the judge and trail-review models the way #103 evals reviewers" and "Choose each tier's review round count from the clean measurement."
- **Co-pulling terms.** Can one well-chosen term carry several rules, how many rules can a model follow, and which ones still need their own push?

➡️ Make the review system its own map when you're ready. I'd record it under this map's Out of scope with your words and a pointer forward, since this map's decisions feed it. Post your co-pulling paragraph word for word on two tickets: on "Decide what the writing standard is and what carries it" as an idea, and on "Decide how we'll know the writing works" as an experiment to design. I'll make those tracker edits once you say yes.