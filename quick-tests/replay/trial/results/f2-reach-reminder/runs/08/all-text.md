Your round-one answers haven't arrived, so I'm treating "Continue" as "carry on", not as agreement with my recommendations. The search found five separate ways the factory lets a reader depart from a rule, which bears on Q3. Before I tell you whether they conflict, I'll read each one where it's written.

---

I read each departure mechanism where it's written, and I couldn't read the research report this time (the command was refused). Your answers to round one haven't come in, so all five questions are still open. Here is what the search changes.

**The five ways to depart from a rule mostly don't conflict.** The search said they "don't agree with each other." Read where they're written, each covers a different situation:

- **"Get a sign-off before breaking it"** (`template/AGENTS.md:20`): a rule stops the task, with you present.
- **"Follow the file and tell me why your instinct differed"** (`template/AGENTS.md:16`): the agent's taste disagrees with a copied pattern, not a rule blocking the work.
- **`skip: <reason>`** (`poteto-mode/SKILL.md:113`): a playbook step the agent chooses not to do. The delegation step turns that option off.
- **`accepted: <reason>`** (spec-review): what was done about a risk or a writer flag. It isn't a way of breaking a rule.
- **"Read PHILOSOPHY again when a rule fights you"** (`MANUAL.md:169`): written for you, not for an agent.

The real gap is narrower. Nothing tells a subagent running with nobody to sign off what to do when a rule fights its goal. The closest existing answer is one case in `feature.md:12`: "a writer that cannot implement a cell as written stops and reports the cell, and never fills it in." That's option (a) of Q3, already in the product for one job.

**Two more things bear on the questions:**

1. **Rules about how the work is finished did as much harm as rules about reading.** The answer-key audit found that the Standards review only lets a reviewer file a bug as hard if it cites a ticket criterion, and the review never shows the reviewer the ticket. So honest reviewers demoted real bugs. Fable wrote "not filed hard because the Standards brief carries no ticket criteria to cite." That rule (the `spec:` gate, `review-brief.sh:494`) is still live. The audits sorted it under "report format," which is why it was missed at first. That's a new question, Q6 below.
2. **Some rules about method earned their keep.** Making the trail review mandatory caught the owner's mistakes three times out of three (`ticket.md:26`). An agent that scoped its own grounding narrowly let a hook bug survive four review rounds (`ledger.md:17`). So "leave the route to the reader" isn't free. This is the case Q1(b) is meant for: the trail review is mandatory because you made it so, not because an orchestrator guessed it would help.

---

**Round one is still open.** Q1 (what makes a rule binding), Q2 (how to write down what the writer knows about the route), Q4 (who may write a binding rule) and Q5 (cost and time limits) are unchanged from my last message. Q3 now has the facts above, and Q6 is new.

❓ **Q3 - What does a reader do when a binding rule fights the goal and nobody is there to sign off?** Options:

- (a) Stop that part, report the conflict to the rule's owner, and carry on with the rest. This is the `feature.md` rule, made general.
- (b) Break the rule and report it.
- (c) Narrow the goal to fit the rule.

The sign-off line stays as it is for the session you're in.

➡️ (a). Never (c).

---

❓ **Q6 - Do rules about the shape of the result count as rules that bound how a task is completed?** By that I mean report formats, required citations, what qualifies as a finding, and caps on length. Options:

- (a) Yes. A format may bind only what the receiver needs in order to use the result. A rule that decides what counts as a finding narrows the goal, so it is binding only if the goal's owner set it.
- (b) No. Report formats are a separate concern, and the ticket "Decide what the writing standard is and what carries it" handles them.

➡️ (a). The `spec:` gate shows why: a format rule that looked harmless decided which bugs got reported.

---

Housekeeping, waiting on these answers:

- My memory still states the old "side effects are the exception" test. I'll rewrite it once Q1 and Q4 settle.
- Hooks and other rules enforced by structure, which have no prose override, depend on Q1. They'll come in round two.