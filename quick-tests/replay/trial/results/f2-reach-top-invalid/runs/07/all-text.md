The background search has finished. Round one is still waiting on your answers, and nothing below assumes any of them. Three of its findings change what I asked, so I've revised two recommendations and noted a question for the next round.

**What the search found that matters here**

- **The factory gives five different answers to "a rule fights my task", and they disagree.**
  1. `AGENTS.md` says to say so loudly and get a sign-off first. Nothing explains how a subagent gets one.
  2. `template/AGENTS.md:16` says the opposite: follow the file, then explain why your instinct differed.
  3. The manual says to re-read the philosophy, or to record your own call as Provisional so you can overrule it.
  4. pstack lets a skipped step stay in the list marked `skip: <reason>`. The feature playbook then forbids that for delegation.
  5. Some departures go back to you through a script gate or a design-hole note.

  No audit has looked at these five mechanisms. Q3 is really about which of them survives.
- **Some rules about the route earned their place.**
  - The mandatory trail review caught the owner's mistakes three times out of three.
  - An agent that chose to skim its grounding let a hook bug survive four review rounds.
  - An agent broke the delegation rule knowingly, and that's why a hook now holds it.

  All three are your rules, each backed by a recorded failure. That supports tying a binding rule to its owner and its reason.
- **The philosophy leans the other way from this ticket.**
  - It describes playbooks as making the agent follow "a script rather than improvising".
  - Belief 3 pushes rules to the strongest rung, where nobody can override them.
  - Belief 7 prefers a copied pattern over reasoning from first principles.

  Whatever we decide here has to be squared with those three. That needs Q1 and Q2 settled first, so it comes in the next round.

The research for this map is already written, on the local branch `research/wording-and-reader-context`. It supports your broader framing over the search-only one. It also gives two counterweights:
- Spelling out the method helps on simple tasks and for novices.
- Holding back what the writer volunteers isn't the same as limiting what the reader may look for.

It found no study that tests a limit on strategy directly.

---

❓ **Q1, revised - What makes a rule binding?** My first answer was that a rule is binding when it states the task or someone's authority, and the owner of that authority decides. Your words in the first charting round go further than that: "leaving the door open for a model to overrule certain rules that aren't absolutely necessary." Read that way, even your own rules about the route can be overruled unless they're truly necessary. So there are three kinds of rule, not two:

- **Binding:** the goal, what counts as done, and authority that isn't the reader's, such as merging, another subagent's files or the ticket's scope.
- **Your defaults about the route, each with a recorded reason:** examples are the trail review, the playbook steps and the delegation rule. The reader may depart from one when it judges the default is wrong for this case. It must say so, with its reason, where you'll see it. A hook can still enforce one of these; then the departure becomes a request rather than an act.
- **Anything else about the route:** this is knowledge, as in Q2. It's never a rule.

➡️ I'd pick the three kinds. What lets a default carry weight is the recorded reason behind it. That reason also tells the reader when the default doesn't apply.

❓ **Q2, Q4, Q5:** unchanged from round one.

❓ **Q3, revised - When a binding rule, or one of your defaults, fights the goal, which mechanism applies?** With the five mechanisms above in view, I'd keep two:

- **For a binding rule:** stop only the part that conflicts, report it to whoever owns the rule, and carry on with the rest. This keeps the sign-off idea without ever blocking the whole job on you.
- **For a default:** depart from it and record the departure with the reason. This is the `skip: <reason>` mechanism, extended to any default. "Follow the file, then explain" would go, because it's compliance first.

In neither case does the reader narrow the goal to fit the rule.

➡️ Those two. The new rule would replace the sign-off line in both `AGENTS.md` files, and "follow the file" in the template.

---

One stray finding, unrelated to this ticket: `MANUAL.md:168` still says "twelve ordered beliefs", but the philosophy has had eleven since the cost belief was removed. I'll leave it for a quick ticket unless you want it handled differently.