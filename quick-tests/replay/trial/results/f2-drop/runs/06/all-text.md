The search over the factory's current writing has finished. You haven't answered round one yet, so nothing is settled. Three of its findings change what I'm asking you, so here they are before you answer.

**For Q1: some rules about the route have done real good.**
- The mandatory trail review caught the owner's errors in 3 of 3 runs ([ticket.md:26](template/.agents/skills/poteto-mode/playbooks/ticket.md:26)).
- The delegation hook exists because an agent broke the prose rule while knowing it was breaking it ([ledger.md:16](docs/agents/ledger.md:16)).
- The design-hole step caught gaps that two runners and a judge had missed ([ledger.md:30](docs/agents/ledger.md:30)).

What these rules have in common is that **the reader can't judge its own case.** A writer can't tell where its own blind spots are. That doesn't fit my recommended (a)+(b) cleanly, so I'm adding a fourth option: (d) a rule about the route is binding when it guards against the reader judging its own work. I'm unsure whether (d) is its own category or just a reason why you set those rules. That's what I'd like you to weigh.

**For Q3: the factory gives five different answers to "what do I do when a rule gets in the way".** They don't agree:
1. Say so and get a sign-off ([AGENTS.md:26](AGENTS.md:26), [template/AGENTS.md:20](template/AGENTS.md:20)). There's no record it has ever been used, and a subagent has nobody to sign off.
2. Follow the rule first, then explain why your instinct differed ([template/AGENTS.md:16](template/AGENTS.md:16)).
3. Decide, and record a Provisional row in DECISIONS for you to overrule.
4. Mark the step `skip: <reason>`. This comes from upstream pstack, and [feature.md:12](template/.agents/skills/poteto-mode/playbooks/feature.md:12) turns it off for delegation.
5. Stop and report: a writer that can't implement a cell, and flags that must end `fixed:` or `accepted:`.

No audit has looked at these. So Q3 is really whether the standard picks **one** way to depart from a rule. If so, which one, or does the answer depend on who the reader is?

**For Q2: reasons are missing where the harm was.** The rules without a stated reason are [ticket.md:12,13,45,46](template/.agents/skills/poteto-mode/playbooks/ticket.md:12), the `knowledge` 150-line cap, and the agent definitions' "Do exactly the task in your prompt." The run-2 constraints audit also sorted rules using the same test you rejected (its "safety, kept" class). So its list of rules to keep needs re-sorting under whatever test Q1 settles on. That's a job for the rework ticket, not this one.

Questions that wait until Q1 and Q3 settle:
- Does a rule enforced by a hook need a way out, given that PHILOSOPHY belief 3 pushes rules down to the hardest level to get around?
- How does this sit alongside belief 7, which prefers a copied pattern over a fresh idea?

Q1 to Q5 stand as asked, with the two changes above.