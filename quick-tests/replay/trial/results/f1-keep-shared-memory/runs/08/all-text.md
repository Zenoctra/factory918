I tried to post your answers word for word as a comment on this ticket, and the post was declined. I won't retry. I'm holding them here and will include them verbatim in the resolution comment, which I'll show you before posting.

**Settled so far:**
- **Q2 (b)**: what the writer knows about how to do the work goes in as information with its reason. Your point about one precise "micro-genre" term carrying many rules at once is pinned below.
- **Q3 (a)**: the reader reports everything it found. Any bar is applied afterward, in a separate step.
- **Q5**: your budget rule, by mode. I've saved it as a standing memory so it applies outside this ticket too.

---

❓ **Q1 again, in plain terms - Who can make a rule binding?** Here's (c) as one sentence:

> **Only whoever owns a decision can make a rule about it binding.** An agent writing a brief can pass your binding rules along, and can bind things it's in charge of itself. Its own ideas about how the work should be done are always advice with a reason, never a rule.

One correction to what I said before. (c) as I worded it required the rule to be about the task *and* owned. The delegation rule shows that's wrong: it's about how the work is done, and it still binds, because you set it. So ownership is what decides. Here's how the sentence sorts real rules from the factory:

| Rule | Who owns it | Under the sentence |
|---|---|---|
| "Never push to main" | You (you merge) | Binds. A hook holds it. |
| "The orchestrator never writes the code itself" | You set it, with evidence | Binds, even though it's about method |
| The mandatory trail review | You set it (it caught owner errors 3 of 3 times) | Binds |
| "Don't edit files another subagent is working on" | The orchestrator splits the work | Binds. The orchestrator owns the split. |
| "Don't *read* files another subagent is working on" | Nobody: reading harms nothing | Goes away |
| "Read only the diff" in a review brief, added by an agent to save tokens | The agent's own guess | Goes away, or becomes advice with a reason |
| The 150-line reading cap in the `knowledge` skill | No recorded reason or ruling | Becomes advice ("reading in chunks keeps your context free"), or goes |
| The `spec:` citation gate in the review script | Agent-written | A finishing rule, so Q3 moves it to the filter step |

➡️ If every row matches your instinct, the sentence is the rule. If one doesn't, tell me which row, because that's where the sentence is wrong.

---

❓ **Q4 - One way to depart from a rule, in place of five.** These are the five that exist today:

1. **Say so loudly and get a sign-off before breaking it** ([AGENTS.md:26](AGENTS.md:26), [template/AGENTS.md:20](template/AGENTS.md:20), taken from Theo). A subagent running unattended has nobody to sign off, and no text says what it should do instead.
2. **Follow the rule, then tell Manuel why your instinct differed** ([template/AGENTS.md:16](template/AGENTS.md:16)). Comply first, explain afterward. This is the opposite default to #1.
3. **Where the spec says nothing, decide and record it** as a Provisional decision you can overrule (PHILOSOPHY, DECISIONS, [ticket.md:30](template/.agents/skills/poteto-mode/playbooks/ticket.md:30)). This is about filling a gap, not breaking a rule.
4. **Skip a step visibly**, writing `skip: <reason>` (upstream poteto-mode). It's forbidden for delegation ([feature.md:12](template/.agents/skills/poteto-mode/playbooks/feature.md:12)).
5. **Send it back up.**
   - Every writer flag must end in `fixed:` or `accepted: <reason>`, or the review script refuses to run.
   - A writer that can't build a test case as written stops and reports it.
   - A hole in the design gets a dated line added to the ticket.
   - Criteria that can't be tested go back to you.

➡️ Keep #3: it's a different job. Keep #5, since its scripts refuse to go on until a person sees the problem. Replace #1, #2 and #4 with one rule that depends on who's present:
- **You're live in the session:** #1 as it stands. Say so and get your sign-off.
- **Nobody is there to ask:**
  - A binding rule that fights the goal: stop that part, report the conflict to the rule's owner, carry on with the rest.
  - Advice about method: use judgment. The report always states where it took a different route and why, or that it took none.
- **Never, in either case:** shrink the goal to fit a rule. #2 ("follow it, explain later") is the closest thing to that today.

---

❓ **Q6 - Your worry under Q3, and where review goes.** Your worry is partly right, and I overstated the evidence. There are two separate effects:
- **A bar on what to report** changes what gets *reported*, not what gets found. Q3 (a) fixes that.
- **Telling a reader what to look for** changes what it *sees*. The gorilla study and Shin's preprint both show this.

So your "slight push" toward a type of bug is exactly what hides the other types, and your sense that it would cause headaches is right. In Shin's study, a second reviewer with an open-ended brief recovered everything the focused one had missed. That's your "multiple passes":
- one pass that's told nothing about bug types;
- if you want a type covered for certain, a separate pass aimed at it, instead of leaning the open one.

That's review design, not just wording, and it's bigger than this map. Your other points belong with it: spec-review hunts mainly for bugs, `interrogate` looks wider but leads its reviewers too, and recall on planted bugs matters more than having no false positives. The options:
- (a) Its own wayfinder map, "a review system of our own", which takes this map's decisions as input.
- (b) Fold it into this map's ticket "Prototype brief templates for the recurring lane jobs".
- (c) Leave it in this map's Not yet specified section.

➡️ (a). The templates ticket still covers how review briefs are worded, and "Decide how we'll know the writing works" gets recall on planted bugs as a measure.

---

❓ **Q7 - Where your micro-genre point goes.** Your point: one precise term can bring a whole cluster of rules into play, the way a micro-genre carries 90% of a song's style. You'd then state only what that term doesn't already carry, and test how many rules get followed and which ones still need an explicit push.

➡️ It goes in two places:
- **"Decide what the writing standard is and what carries it"**, as a way to keep the rule count down.
- **"Decide how we'll know the writing works"**, as an experiment: rules followed against rule count, and one term against the rules spelled out.

I'll add your words verbatim to both tickets when I resolve this one. I'll also record "every added rule dilutes the rest" as a standing note in the map's Notes, so every later ticket sees it.