Your budget answer is settled, and I've saved it as a standing rule in my memory:
- In `safe` (the first tier, the one you called Safety Mode), a budget never shapes the work. It's only measured afterward.
- In `eco` and Let It Rip, a budget reaches a reader as binding only after you've been asked how much it matters, and only with your approval.
- When in doubt, the budget isn't mentioned. If it seems important and you can't be asked, it goes in as information, not as a limit.

I tried to post your answers word for word as a comment on the ticket, and the post was refused. They're kept locally for now. I'll put them in the resolution comment unless you'd rather they go up sooner.

Two notes from your answers will go onto the map when this ticket closes, so they aren't lost:
- **Terms that carry many rules at once.** One well-chosen term might do the work of a dozen rules, the way your micro-genre term does for music. That's an experiment, and it belongs to the ticket "Decide how we'll know the writing works".
- **A review system of your own.** I've asked where it goes in Q3 below.

On Q1, here's (c) again, slower, since round two builds on it.

**Think of hiring a contractor.** You decide what gets built, when it's finished, and who signs off. The contractor decides how to build it. That's the default: the task is yours and the route is the reader's. You can still insist on a method ("use this pipe"), and it binds because it's your call to make. A general contractor briefing a subcontractor can pass down what you insisted on and set what it really controls, like which rooms other crews are in today. What it can't do is invent new must-dos from its own guess about how the job should go. It can only offer that guess as advice.

Applied to rules the factory has now:
- **"Never push to main"** binds. Merging is your call.
- **"The orchestrator never writes the code"** is about the route, and it still binds, because you claimed that piece of the route yourself.
- **"Read only the diff"** doesn't bind. An orchestrator guessed where the bugs would be. At most it becomes information: "the change is in these files."

So (c) in one sentence: the route belongs to the reader unless you, or whoever owns that piece, take it back.

---

❓ **Q1 - Is that what you meant by (c)?** I sharpened it while explaining it. In my first version both conditions had to hold, which would have left the delegation rule unbinding. The contractor version fixes that: who owns the decision is what counts, and the route is the reader's only by default.

➡️ Yes, the contractor version. If it still doesn't match your intuition, tell me where it breaks and I'll take another run at it.

---

❓ **Q2 - Your worry in Q3 is real, and I need to correct what you took from me.** The research separates two things:
- **A bar** ("only report serious bugs") changes what gets reported, not what gets found. Radiologists kept searching and simply stopped saying so. That's why moving the bar to a later filter step works.
- **A focus** ("look for X") changes what gets seen. Observers counting basketball passes missed the gorilla. In the 2026 preprint, a narrow task made models stop reporting critical findings they reported without it.

So your fear, a reviewer chasing edge cases and reading right past the bug we care about, is the second case. A "slight push" toward a bug type is also a focus, and it pulls the same way. In that preprint, what fixed it was a second, separate reviewer with an open brief.

The options:
- (a) Each review brief states the goal whole and names no bug types. Wherever a type really matters, it gets its own pass, alongside at least one open pass. Every pass reports everything it notices, inside its focus or not.
- (b) One brief with a light push toward the types you care about.
- (c) Leave how many passes there are, and of what kind, to the review system design. This ticket rules only that a brief never narrows silently.

➡️ (a) as the rule for how a brief treats focus, with the actual set of passes left to the review system.

---

❓ **Q3 - Where does that review system go?** You want a review process of your own: several passes, better briefs, measured on how many planted bugs it misses rather than only on false positives. This map's destination covers how review briefs are written and templated. It doesn't cover how many passes run, of what kind, or how the results get checked. Related tickets already exist: "Choose each tier's review round count from the clean measurement" and "Eval the judge and trail-review models the way #103 evals reviewers".

The options:
- (a) A ticket on this map.
- (b) A map of its own, taking this map's decisions as input.
- (c) Fold it into "Prototype brief templates for the recurring lane jobs".

➡️ (b). It's a process design as big as this one, and leaving it out of scope here keeps this map about writing. I'd record it under Out of scope with a pointer to the new map, and draft that map's opening for you when this ticket closes.

---

❓ **Q4 - What happens when a reader departs from the route, or a binding rule fights the goal?** Here are the five ways the factory handles this today:

1. **Say so loudly, then wait for sign-off** ([AGENTS.md:26](AGENTS.md:26), [template/AGENTS.md:20](template/AGENTS.md:20)). This was taken from Theo. A subagent has no way to get a sign-off, and the rule pulls against "never block on the human, proceed on anything reversible".
2. **Follow the file, then explain why your instinct differed** ([template/AGENTS.md:16](template/AGENTS.md:16)). This one is the reverse of 1: obey first, talk afterward.
3. **Where the spec is silent, decide and record it as Provisional** so you can overrule it ([ticket.md:30](template/.agents/skills/poteto-mode/playbooks/ticket.md:30), `DECISIONS.md`). This covers gaps, not conflicts.
4. **Skip a step with a visible `skip: <reason>`** (from pstack). It's turned off for delegation, where no skip is allowed ([feature.md:12](template/.agents/skills/poteto-mode/playbooks/feature.md:12)).
5. **Send it back to whoever owns it.** A writer that can't implement a test cell stops and reports it. Writer flags must end `fixed:` or `accepted: <reason>`. A design hole amends the ticket. Criteria that can't be tested go back to you.

The proposal:
- **Route knowledge:** the reader uses its judgment, and its report always says where it took a different route and why. This keeps 4 and generalizes it.
- **A binding rule that fights the goal:** the reader stops that part, tells the rule's owner, and carries on with the rest. When the owner is present, as you are in the main conversation, telling you is a question and that part waits for your answer. When the owner isn't present, it goes in the hand-back. This is 5 made general, and it replaces 1 and 2.
- **3 stays as it is.** Deciding where nobody has decided is the reader's route.
- **Never shrink the goal to fit a rule.**

➡️ That proposal. The new part compared with today: 1 and 2 go away, so a rule fighting the goal is never resolved by silent obedience or by stalling while waiting for a sign-off.

---

❓ **Q5 - How is a binding rule worded?** The research found three things. Emphatic wording ("CRITICAL", "MUST") makes current Claude over-apply a rule. A bare "don't" keeps the forbidden idea active and doesn't say what to do instead. A rule that comes with its reason gets applied more sensibly at its edges.

➡️ Every binding rule is plain, carries its reason and its owner, and says what to do instead. When a hook holds the rule, the hook's refusal message carries the reason and the way forward at the moment it's needed. Where those messages live, and whether prose repeats the rule, is for the ticket "Decide where each piece lives and when it reaches the writer".