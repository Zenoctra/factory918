Your Q5 answer goes further than the options I gave, so I've restated it below to check I have it right. Your words will go word for word into the resolution comment, as on the map. Q1 first, in concrete terms.

## Q1 in practice

Before a rule goes into a brief as a must, the writer asks two things:

1. Is the rule about what the job is, or whose call something is, rather than how to do the job?
2. Did whoever owns that call say it must hold?

If both answers are yes, the rule binds. Otherwise it goes in as advice with its reason, or it stays out.

| Rule | What it's about | Who said it must hold | Result |
|---|---|---|---|
| Never push to `main` | Whose call merging is: yours | You | Binds |
| The orchestrator never writes the code | Whose job writing is | You, with evidence | Binds |
| Don't edit files another subagent is editing | Whose files those are right now | The orchestrator, which handed them out | Binds |
| Read only the diff | How to review | An orchestrator, to save tokens | Advice at most; really, leave it out |
| Cut token use in half or the ticket stays open | What counts as done | A model, from one anecdote | Doesn't bind: you never said it must |

The last row is your Q5 story. The rule claimed to define "done", but nobody who owned "done" had said so.

## Q2: your note on rule count and dense terms

Two things will feed the experiments:

- Every added rule dilutes the others.
- One well-chosen term can carry what ten rules would.

Your micro-genre example points to two open questions: how many rules a model can actually follow, and whether one term can stand in for several rules, with only the exceptions spelled out. That belongs on "Decide how we'll know the writing works". I'll add it to that ticket and to the map's Not yet specified when I close this one.

## Q3: your worry is a separate effect

I made the evidence sound simpler than it is. It shows two different effects:

- **A bar on reporting.** The reader finds the bug and doesn't report it. Moving the bar to a separate filter step fixes this, and that's the (a) you picked.
- **A narrow focus.** The reader never sees what's outside the focus. That is your worry: a reviewer stuck on edge-case inputs reads past the bug you wanted. A filter step can't fix this, because the bug was never found. In the 2026 preprint, a second reviewer with an open-ended brief recovered what the first one missed.

So the cure for your worry is more independent passes, not a hint in the brief. A line like "we're especially wary of X" is a short list, and lists pull. It's also something the writer volunteers rather than a rule, so it belongs on "Decide what the writing standard is and what carries it". I'll put your worry there in your words.

---

❓ **Q4 - What the reader does when it departs from a rule**

These are the five ways the factory handles that today:

1. **Ask first.** [AGENTS.md:26](AGENTS.md:26): "If a rule … fights the task in front of you, say so loudly and get a sign-off before breaking it." A subagent has nobody to ask, no text says how it would, and this pulls against "never block on the human".
2. **Obey first, explain after.** [template/AGENTS.md:16](template/AGENTS.md:16): follow the file, then tell Manuel why your instinct differed.
3. **Decide and record it.** Where the spec is silent, the agent decides and writes a Provisional row in DECISIONS for you to overrule.
4. **Skip with a reason.** poteto-mode: a skipped step stays in the list as `skip: <reason>` and is never skipped silently. Delegation is the exception: [feature.md:12](template/.agents/skills/poteto-mode/playbooks/feature.md:12) forbids skipping it.
5. **Close every flag.** A writer's flags must each end `fixed: <sha>` or `accepted: <reason>`, and the review script won't start until they do. A writer that can't build a table cell as written stops and reports it.

What I'd replace them with:

- **Advice about the route:** the reader uses its judgment, and its report always says where it went another way and why, or that it didn't. This is 3 and 4 made a standing part of every report rather than something the reader may choose to do.
- **A rule that binds and fights the goal:** in the root session, ask you; that is 1, kept. In a subagent, stop that part, report the conflict to whoever owns the rule, and finish the rest.
- **Never:** shrink the goal to fit a rule.

2 is the one that goes: obeying first is how a bad rule gets carried out quietly. 5 already fits and stays.

➡️ Replace the five with this.

---

❓ **Q5 - Is this your budget rule?**

- **`safe`:** a budget never shapes the work. Tokens and time are measured afterward, only to look for savings.
- **`eco` and Let It Rip:** a budget exists only when you set one. Before it reaches any brief, you're asked how much it weighs against your other goals. Let It Rip adds wall-clock time with the same treatment, and it never overrides a process you've required.
- **When in doubt, leave the budget out of the brief.** An agent that thinks a budget matters but can't ask passes it on as information. It goes in as a must only with your approval.
- **A predicted saving is never a condition for closing a ticket** unless you made it one. This is your "principle over proxy" ruling applied to budgets.

➡️ Confirm, or correct the wording.

---

❓ **Q6 - Where does the review system go?** You described more than how review briefs are written:

- the review process itself: several passes, a verifier that sorts findings by kind, and how `spec-review` and `interrogate` divide the work;
- `interrogate`'s own leading wording;
- measuring recall against planted bugs instead of praising zero false positives.

This map's destination covers how review briefs and templates are written. The process around them is bigger than writing. The options:

- (a) A ticket on this map.
- (b) A sixth map of its own, charted after this map's rework ticket, so it starts from the finished writing standard.
- (c) Fog on this map for now.

➡️ (b). Your words from this answer go into the resolution comment now, and into that map's Notes when it's charted, so nothing has to be remembered.

---

Next round: how a binding rule is worded and enforced. For example, should a hook's refusal message, which arrives at the moment of use with the reason and a way forward, take the place of restating the rule in every brief?