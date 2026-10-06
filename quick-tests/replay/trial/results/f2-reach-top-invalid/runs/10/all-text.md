The background search finished. Three of its findings change round one, so I've revised Q3, added Q6, and reworded my recommendation on Q1. Q2, Q4 and Q5 stand as asked. I'm still waiting on your answers to all six before closing anything.

**What it found:**
- **Five ways to depart from a rule, and they disagree.**
  - Both AGENTS.md files say "say so loudly and get a sign-off" ([template/AGENTS.md:20](template/AGENTS.md:20)). Nothing says how a subagent gets that sign-off, and it pulls against "never block on the human."
  - Four lines up, [template/AGENTS.md:16](template/AGENTS.md:16) says the opposite: follow the file first, then explain why your instinct differed.
  - pstack lets the agent skip a step if it writes `skip: <reason>`, but the feature playbook turns that off for delegation.
  - Review writers have to close every flag with `fixed:` or `accepted: <reason>`, and a script enforces it.
  - None of the run-2 audits looked at these exits.
- **Many rules carry no reason.** Examples: "never an arena", the 150-line read cap in `knowledge`, and "Do exactly the task in your prompt" in the reviewer and tier agents. The audit found no recorded reason for 150.
- **Some rules about the route did real good**, and each traces back to a measured failure:
  - The mandatory trail review caught the owner's errors in 3 of 3 runs.
  - The delegation hook exists because an agent broke the prose rule knowingly.
  - The design-hole step caught gaps that two runners and a judge missed.

  So "a rule about the route is suspect" can't mean "a rule about the route is wrong."
- **The constraints audit sorted limits using the old framing**, so its 45 recommended cuts lean on the test you rejected. Most of those cuts haven't been made yet.
- **The branch `research/wording-and-reader-context` was written for this ticket.** It finds that specific method guidance helps on simple tasks and for novices but hurts experts on complex ones. It also says no study tests a limit on strategy directly. I'll read it in full before closing.

---

**Q1, revised recommendation:** still (a) and (b) together, now with the evidence above in mind. The trail review is a rule about the route, it's binding, and it's good. It's binding because you made it binding, and its reason is a measured failure. Under this test an orchestrator could never have invented it. That's the property I'm after.

---

❓ **Q3 (revised) - What should the single way to depart from a rule look like?** Today there are five, and they disagree. Pick one shape for the whole factory:
- (a) **Two kinds of rule, two exits.**
  - A binding rule is followed. If it fights the goal, the agent stops that part and reports the conflict to whoever owns the rule.
  - Anything else may be departed from. The agent says what it did differently and why, the way `skip:` and `accepted:` already work.
  - The sign-off line and "follow the file, then explain" are both replaced by this.
- (b) Keep the sign-off as the one exit for everything, and give subagents a way to ask their orchestrator.
- (c) Leave the five as they are, each in its own context.

➡️ (a). It keeps the two exits that already work and are enforced. It removes the two that conflict. Every departure becomes visible without anyone blocking on you.

---

❓ **Q6 - Must every rule carry its reason?** The reason is what lets a reader recognize the case the writer didn't foresee. A rule without one can only be obeyed or broken blindly. The options:
- (a) Every rule, binding or not, states its reason where it is written. A rule with no reason anyone can recall gets flagged in the audit as a candidate for cutting.
- (b) Only rules about the route need reasons.
- (c) Reasons live in DECISIONS.md, and rules point there.

➡️ (a), with (c) allowed when the reason is long. The rule carries one clause and points to the DECISIONS row. Whether the reworking ticket uses "no recallable reason" as a cut signal is that ticket's call.