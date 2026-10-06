The search is back. One of its claims is that the factory's ways of departing from a rule contradict each other. Before I pass that on, I'll read each one where it's written, along with the research doc that was written for this ticket.

---

The search finished, and so did a research note on an unmerged branch that was written for this ticket. Three things they turned up change my round, so here it is again with those changes. You haven't answered yet, so nothing is settled.

**What changed:**
- **Some rules about the route have done provable good.** The mandatory review of the decision trail caught an owner's mistake 3 times out of 3. The blast-radius step was added after a hook bug survived four review rounds. The delegation hook was added after an agent broke the rule knowing it was the rule. In each case a rule was added after the agent's own judgment was seen failing, and the reason was written down with it. My old test, "only the task binds, never the route", would have thrown all of these out.
- **Rules about how a task is *finished* do the same damage as rules about how it's pursued.** The Standards reviewer's brief demands that every hard finding cite a ticket criterion, but it never shows the ticket. So honest reviewers demoted real bugs. Fable wrote "not filed hard because the Standards brief carries no ticket criteria to cite." The constraints audit had filed rules like this under "report format" and kept them. My old Q1 counted "what done means" as part of the task, which would have kept that rule binding.
- **What the writer volunteers is a different matter from what the reader may look for.** Holding back the writer's own conclusions, or an earlier round's findings, protects a reviewer's independence. Stopping the reviewer from reading something does not. The research found evidence for the first kind of restraint and none for the second.

I also read each departure rule where it's written, because the search said they conflict. "Follow the file and tell me why your instinct differed" (`template/AGENTS.md:16`) covers your instinct disagreeing with a copied pattern. "Say so loudly and get a sign-off" (`:20`) covers a rule that blocks the task. They apply to different situations, so they don't conflict. The real gap is narrower: nothing tells a subagent how to get a sign-off.

---

❓ **Q1 - What makes a rule one the reader can't overrule?** You said you want to leave "the door open for a model to overrule certain rules that aren't absolutely necessary." So the question is what counts as absolutely necessary. The options:
- (a) Its subject: rules about the task bind, rules about the route never do. The evidence above breaks this.
- (b) Its owner: it binds if the person who holds that authority said it must. That would be you, the ticket's scope, or another subagent's ownership of a file.
- (c) Its record: a rule about the route binds only when it carries the failure that earned it, meaning a time the reader's own judgment was seen going wrong.

➡️ (b) and (c) together. An owner makes a rule binding. A rule about the route also carries its reason and the failure behind it, because the reason is how a reader recognizes the case the rule didn't foresee. A rule with no owner and no reason is knowledge the reader may use (Q3), not a wall.

---

❓ **Q2 - Where does the shape of the result stop and a filter on findings start?** Some of the hand-back shape really is fixed: where the result goes, and the fields a script parses. But a format can also decide what's worth reporting, like a required citation, a fixed list of categories, or a severity bar. That decides what the reader is allowed to have found.

➡️ The writer can fix where the result goes and what a script needs to parse. Nothing in the format may decide what counts as a finding. Anything the reader found that doesn't fit the format still gets reported, marked as not fitting, and is never dropped.

---

❓ **Q3 - How should the writing carry knowledge about the route?** This is my old Q2, unchanged. The writer may know a trap or a tool quirk the reader can't easily find. Pstack already handles a close case: a playbook step the agent decides not to do stays in its list with `skip: <reason>`. The options:
- (a) Leave the knowledge out.
- (b) Write it as something the writer knows, with the reason. The reader may take another route and say so in its report.
- (c) Write it as a default the reader may override.

➡️ (b). Include it only when the reader couldn't find it easily, and always give the reason.

---

❓ **Q4 - What does the reader do when a binding rule fights the goal?** This was Q3. Whatever you pick here also fills the subagent gap above. There's a precedent in the factory: a writer who can't implement a cell of the scenario table as written "stops and reports the cell, and never fills it in." The options:
- (a) Stop that part, report it to whoever owns the rule, and carry on with the rest.
- (b) Break the rule and report it.
- (c) Narrow the goal to fit the rule.

➡️ (a). Never (c).

---

❓ **Q5 - May an orchestrator invent binding rules from its own judgment?** This was Q4. The evidence is now firmer. The reading limits in the review brief were added by subagents to save cost, and no ticket asked for them. In another case, a subagent turned one of your questions into a rule on a ticket, and you removed it.

➡️ No. It passes down your rules, binds only what it owns itself, and offers everything else as knowledge with reasons.

---

❓ **Q6 - Can cost or time justify a limit on the route?** This was Q5. New evidence: under tight output budgets across 30 models, reasoning models fell sharply. Phi-4-reasoning dropped from 72.2% to 53.5% at 1,024 tokens. The options:
- (a) A budget is stated as a fact, and the reader plans its own route inside it.
- (b) A budget you set may cap the route directly.
- (c) Budgets stay out of the writing.

➡️ (a). (b) only when the budget is yours, and the map "Optimize token use and wall-clock time without losing reliability" can revisit it with measurements.

---

❓ **Q7 - Does this ticket cover what the writer holds back, or only limits on the reader?** Two cases show the difference. Not showing a reviewer the author's view of the diff is restraint by the writer. Forbidding the reviewer to open a file is a limit on the reader. The first is about leading the witness more than about bounding the task.

➡️ This ticket decides limits on the reader, both how it pursues the task and how it finishes it. Its answer names the distinction, and writer restraint goes to "Decide what the writing standard is and what carries it."

---

A caveat on the evidence: no study of models tests a limit on strategy directly. The model studies measure reporting bars, output formats, length budgets and how many instructions are given at once. Checking whether this works in practice belongs to "Decide how we'll know the writing works."