Your answers are saved word for word in this session's scratchpad. I tried to post them as a comment on the ticket, but that was denied, so they'll go up with the resolution unless you'd like them posted sooner.

**Settled:**
- **Q2 (b).** Route knowledge is written as information with its reason. I've pinned your point about strongly linked terms, and I'll add it to the map so the standard ticket and the measurement ticket pick it up. One accurate term can pull in most of what a dozen rules would say. Spelled-out rules are then needed only for what that term wouldn't bring in. Both claims are to be tested, not assumed.
- **Q5.**
  - In `safe`, a budget never shapes the process. It's only measured afterwards.
  - In `eco` and Let It Rip, a token budget, plus wall clock in Let It Rip, reaches a reader only after you've been asked how much it binds.
  - When in doubt, leave the budget out. If it can't be asked about and seems important, it goes in as information.
  - It binds only if you approved it as binding.
  - Your story is the measure-replaces-goal finding from the research: a prediction from one case became a requirement for closing the ticket.
- **Q3 (a), with a correction.** You agreed partly because you understood the evidence to say both kinds of bug still get found. That's true for a bar on what to report. It's not true for focus. In the gorilla studies and in Shin's preprint, what the reader was told to look for decided what it saw. So your worry is real. A "slight push toward these kinds of bug" would cause it. It names a focus, and the rest of the field fades. That's Q3b below.

---

**Q1, explained again in practice.** Writing it out concretely showed me that my option (c) was muddled. Here's the plain version:

> **The reader owns the route. A rule binds only when it comes from whoever owns that call, and only you can take a piece of the route back from the reader.**

Here it is run against six real rules:

| Rule | Whose call is it? | Binding? |
|---|---|---|
| Never push to `main` | Merging is yours | Yes |
| Don't edit files another lane is working in | The orchestrator assigned those files, so it owns that call | Yes |
| The orchestrator never writes the code itself | This is route, but you took it back, with evidence | Yes, because it's yours |
| Read only the diff and the brief | Route, set by an orchestrator to save cost | No. At most, information |
| Read no more than 150 lines per call (`knowledge`) | Route, and nobody recorded why | No |
| Cut token burn in half to close this ticket | A model's own guess, turned into a requirement | No |

The "about the task or about the route" part of (c) only tells you who owns a call by default. What's wanted, what done means, and whose decision something is belong to whoever set the task. The route belongs to the reader. Ownership is what actually decides whether a rule binds.

---

❓ **Q1 (confirm)** - **Is this the rule you're agreeing to?** "The reader owns the route. A rule binds only when it comes from whoever owns that call, and only you can take a piece of the route back."

➡️ Yes. It's (c) stated plainly, and it gives the right answer on all six rows above.

---

❓ **Q3b** - **How do we get a particular kind of bug looked for without hiding the others?** For example, security issues, or the behaviour bugs you care about more than edge cases with unsupported input. The options:
- (i) A slight push in the brief, which is what you floated.
- (ii) Separate passes: one with an open brief that looks for everything, and a separate pass for each kind you especially want caught. A verifier then rates what all of them found. Shin's recovering critic is evidence for this shape. It's also your "multiple passes".
- (iii) Decide nothing here and leave it to the review work.

➡️ This ticket settles the rule: a kind of bug you care about gets its own pass and is never pushed inside the open pass. How many passes there are and how they're briefed is review-system design.

I'll add "a review system of our own" to the map's Not yet specified list. Your words on it go there in full: spec-review is mostly bug-hunting, interrogate looks wider but leads the witness, and studies celebrate having no false positives while missing half the planted bugs. Two existing tickets touch it, "Choose each tier's review round count from the clean measurement" and "Eval the judge and trail-review models the way #103 evals reviewers". Neither covers it.

---

❓ **Q4** - **What should replace the five ways a reader departs from a rule?** Here they are:

1. **Say so loudly and get a sign-off.** [AGENTS.md:26](AGENTS.md:26) and [template/AGENTS.md:20](template/AGENTS.md:20), taken from Theo. It assumes someone is there to sign off, but a subagent has nobody. It also conflicts with "never block on the human".
2. **Follow the rule first, then explain why your instinct differed.** [template/AGENTS.md:16](template/AGENTS.md:16). This is the opposite default to #1.
3. **When the spec is silent, make the call and record it under Provisional** in DECISIONS, so you can overrule it later.
4. **Skip a step visibly, with `skip: <reason>`.** This comes from upstream poteto-mode. For delegation it's switched off ([feature.md:12](template/.agents/skills/poteto-mode/playbooks/feature.md:12): "no skip-with-reason escape").
5. **Send it back up.** A writer flag must end `fixed:` or `accepted: <reason>`. A writer that can't implement a test cell as written stops and reports it. A hole in the design amends the ticket.

As far as the record shows, #1 has never been used. No audit has looked at any of the five.

My proposal keeps what works in #3, #4 and #5 and drops #1 and #2 for subagents:
- **When the reader takes a different route from the one the writer suggested**, it just does, and its report always says where and why, or says it took none.
- **When a binding rule fights the goal**, the reader stops that part, reports the conflict to whoever owns the rule, and carries on with the rest.
- **When the spec is silent**, #3 stays as it is.
- **The reader never shrinks the goal to fit a rule.**

#1 stays only for the session you're talking to, where you're present to sign off.

➡️ Adopt that. One open point I'd want your view on: whether #2, follow the rule and then explain, should also go for your own session, or stay as the default when you're present.