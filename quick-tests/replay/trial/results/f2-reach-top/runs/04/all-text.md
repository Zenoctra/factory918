The background search has finished. I haven't had your answers to round one yet, so nothing below is settled. Four findings change the round: one revises Q3 and another adds a new Q6.

**1. The broader framing holds up.** The worst harm in the run-2 audits didn't come from limits on searching.
- The answer-key audit found that the Standards review brief requires every hard finding to cite a line of the ticket, but never shows the reviewer the ticket. Honest reviewers then downgraded real bugs they had found: Sol filed nothing on pr99, which had four hard bugs. That rule governs how a review is finished, not how it searches.
- The research note for "Research how wording and missing context shape a reader's response" is on its branch, though the ticket is still open. It reaches the same conclusion from the human studies: what costs most are limits on method and rules about what's worth reporting.
- The note adds one distinction worth keeping: it is fine for the writer to hold back its own opinion so the reader stays independent. Limiting what the reader may go and look at is a different thing.

**2. Some route rules did good, and the ones that helped share a trait.**
- The mandatory trail review caught an owner's mistake three times out of three.
- The delegation rule needed a hook because an agent broke it while knowing it.
- Each of those traces back to a real failure, and the reason is written down. The harmful limits were mostly added by subagents to save cost, without any ticket asking for them.
- This fits Q1's "only the owner of the authority can make it binding" and Q2's "carry the reason". I checked a neater test, "rules that add a step are fine, rules that cap one are harmful", and it fails: the ticket-citation rule above adds a requirement and did harm. So I'm not proposing it.

**3. The factory has five ways to depart from a rule, and they disagree.**
- `AGENTS.md:26` says to say so loudly and get a sign-off.
- `template/AGENTS.md:16` says the opposite: follow the file, then explain why your instinct differed.
- `MANUAL.md:168` says to re-read the reasoning and record a Provisional decision.
- pstack's `skip: <reason>` lets an agent skip a step visibly, except that `feature.md:12` forbids skipping delegation.
- Some departures go back up for a decision: a writer flag stays open until it is marked `accepted: <reason>`, and a writer that can't build a cell stops and reports it.

Nothing says how a subagent gets a sign-off, and the sign-off line pulls against "never block on the human". No audit looked at these mechanisms.

**4. The recommendations from the constraints audit haven't been applied.** The audit judged about 45 lines in the factory's own briefs and skills as ones to delete or replace, and nearly all are still there. It sorted them with the old "protect the world / shape the search" split. "Decide the scope and order of reworking existing files" should re-sort them under whatever this ticket decides, rather than inherit those calls.

Q1, Q2, Q4 and Q5 stand as asked. Here are the revised Q3 and the new Q6:

---

❓ **Q3 (revised) - What does the reader do when a rule bars the route it judges best?** I'd replace all five mechanisms with one:
- If the rule is binding (Q1), the reader stops that part and reports the conflict to whoever owns the rule. It carries on with everything else, and never narrows the goal to fit.
- If the rule isn't binding, the reader takes its own route and says in its report what it did differently and why.

This is the "stops and reports the cell" pattern the writer rule in `feature.md:12` already uses, applied everywhere. It reaches the owner without a live sign-off, so it works for a subagent with nobody to ask.

➡️ Adopt it as the only departure mechanism. Once that's settled, a later round will cover what happens to the "follow the file" line and to the sign-off line in both AGENTS files.

---

❓ **Q6 - May a writer prescribe the method for a closed task?** You said lists are fine "if you are looking at a closed ended task where the options truly ARE listable and complete." The research agrees: a fixed method helps on simple tasks. Some subagent jobs here really are closed, like reading the tier with two commands, or running a fixed check script. The risk is a writer calling an open task closed so it can lay down a method.

➡️ Yes, but the writer has to say so in the text ("this task is closed because …"), so the reader can push back under Q3 if it isn't. Without that statement, method is knowledge, not an order (Q2).

---

Two smaller things:
- `MANUAL.md:168` still says "twelve ordered beliefs", but PHILOSOPHY has eleven since the cost belief was cut. I'll file a quick ticket for it unless you'd rather fold it into something else.
- The research ticket's note is finished on its branch, but the ticket is still open. If another session is closing it, I'll leave it alone.