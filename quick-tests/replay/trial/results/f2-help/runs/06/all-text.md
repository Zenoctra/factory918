Before I pass on the agent's claim that the factory's ways of departing from a rule contradict each other, I'll read each one where it's written.

---

Before you answer round one: the background search finished, and I checked its main claims against the files and the research branch. Three of its findings change the round. Q4 and Q5 stand as I asked them; Q1, Q2 and Q3 are revised below, and Q6 is new.

**Some rules about the route did good.**
- **The required trail review.** The trail is the log of decisions an owning subagent records as it works, and a separate subagent reviews it. That review caught the owner's mistakes all three times it ran (`ticket.md:26`).
- **The delegation rule.** An agent broke it knowingly until a hook enforced it (`docs/agents/ledger.md:16`).

Both rules exist because the reader's own judgment is the thing that fails, and a reader can't check that from inside its own run. My Q1 test missed this kind of rule.

**Rules about the hand-back did harm too.** The Standards review brief makes a reviewer cite a line of the ticket before it may call a bug hard, but the brief never shows the ticket. Honest reviewers therefore downgraded real bugs. One wrote "not filed hard because the Standards brief carries no ticket criteria to cite". On one PR with four hard behaviour bugs, the reviewer filed none. The constraints audit had marked report format as safe, and its own addendum admits that was wrong. So "what done means" in my Q1 can't be exempt from scrutiny.

**The ways of departing from a rule don't conflict.** The agent reported five mechanisms and said they disagree. Read where each is written, they cover different situations:
- "Follow the file and tell me why your instinct differed" (`template/AGENTS.md:16`) applies when the reader prefers another pattern.
- "Say so loudly and get a sign-off" (`:20`) applies when a rule fights the task.
- `skip: <reason>` applies to playbook steps.
- The Provisional row applies when nothing else answers.

The real gap is narrower. Every one of them assumes a person is in the conversation, and none covers a rule written into a brief.

**The research for "Research how wording and missing context shape a reader's response" is done**, on the branch `research/wording-and-reader-context`:
- It supports your broader framing over the search-only one.
- No study tests limits on strategy in models directly, but the human evidence says such limits cost most on novel tasks given to capable readers.
- Specific method helps only on simple tasks and with novice readers.
- It separates two things: holding back what the writer volunteers protects a reader's independence, while limiting what the reader may look for is a different matter.

---

❓ **Q1 (revised) - What makes a rule binding?** A rule would be binding when it does one of these:
- (a) states the task: what's wanted and what done means;
- (b) marks something that isn't the reader's to decide, such as your merges, another subagent's files, or the ticket's scope;
- (c) guards against a failure the reader can't see from inside its own run, such as reviewing its own work or judging whether it needs a check at all.

Part (c) is the one most open to abuse. "Read only the diff" could claim it ("guards against wandering"), but a reader can judge for itself whether it's wandering, so that rule fails the test.

➡️ All three. A rule under (c) must also name the failure it guards against and the evidence for it, the way the trail review does, and only the owner of the authority can make it binding. That's still Q4's answer: you, AGENTS.md, the ticket, or the orchestrator for what it owns.

---

❓ **Q2 (revised) - How should the writing carry knowledge about the route?** The research puts the line by the reader's role:
- **Someone doing the work** gets the writer's route knowledge as knowledge, with the reason, never as an order. The reader may take another route and says in its report that it did.
- **A reviewer or verifier** gets the materials it can use: the ticket, the diff, where things live. It gets nothing about where the writer thinks it should look or what the writer concluded. The writer volunteers no conclusions, and the reader is free to look anywhere.
- **On a simple task**, a step-by-step method is allowed, because that's the one place the evidence says it helps.

➡️ All three, as above. The third is my least certain part; it could stay out until measurements show it helps.

---

❓ **Q3 (revised) - What does an unattended reader do when a binding rule fights the goal?** The options are the same as before:
- (a) stop that part, report the conflict to the rule's owner, and keep going on the rest;
- (b) break the rule and report it;
- (c) narrow the goal to fit the rule.

The new detail is routing. A conflict with a rule written into a brief goes to the brief's writer. A conflict with one of your rules reaches you through the report.

➡️ (a), never (c).

---

❓ **Q6 - Is the form of the hand-back binding?** A script often reads the report, so its shape matters. The spec-citation rule shows how a shape can quietly become a filter on what gets reported. The options:
- (a) The shape is binding, but it can never filter. Anything the reader found that doesn't fit the shape still goes in the report, in a place made for it, and its weight is judged separately.
- (b) The shape is the reader's choice.
- (c) The shape stays binding as it is now.

➡️ (a). The script needs a shape, but the shape must never decide what gets reported. A finding with no ticket line to cite is reported as such, with why it matters, not downgraded.

---

Separate from this ticket: `MANUAL.md:168` still says "twelve ordered beliefs", but PHILOSOPHY has had eleven since the cost belief came out. Tell me if you want a quick ticket filed for it.