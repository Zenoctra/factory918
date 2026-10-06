Manuel hasn't answered round one yet, so I'll fold the background findings into it. Before I put any rule conflicts in front of him, I'll read each mechanism where it's actually written.

---

The background search is back, and so is the research note this ticket asked for. Two of the findings change round one, so here it is again. Q4 and Q5 haven't changed. Q1, Q2 and Q3 are revised, and Q6 is new.

**What the search found, briefly:**

- **The run-2 audits mostly counted limits on reading, running and output length.** They counted these because their brief used the old "shape the search" split. The audit's own late addendum and the answer-key audit found that rules about how the work gets *finished* did just as much damage.
- **The worst example is in the review script.** It sends back any finding that doesn't cite a ticket line (`review-brief.sh:494`), but the Standards reviewer is never shown the ticket. Honest reviewers therefore downgraded real bugs. In one run, a reviewer obeyed this, filed nothing, and the PR had four hard bugs.
- **The research note supports your broader framing over the search-only one.** The costliest findings in people are about limits on method and bars on what may be reported, not only limits on reading.
- **The note gives two counterweights:**
  - Specific method does help on simple tasks and with less capable readers.
  - Restraint in what the writer *volunteers* protects a reader's independence. That's a different thing from limiting what the reader may *seek*.
- **The factory already has five ways to depart from a rule.** The search reported that they contradict each other. I read each where it's written, and they mostly cover different situations:
  - "say so loudly and get a sign-off" is for a rule that fights the task;
  - "follow the file and tell me why your instinct differed" is for a disagreement over taste;
  - "record a Provisional row" is for when no rule exists;
  - `skip: <reason>` is for a playbook step judged not worth doing;
  - "stop and report the cell" is for a writer that can't build what the spec says.

  The real gap is a subagent running unattended when a rule blocks its goal. No text covers that case.
- **Almost none of the audits' recommended cuts have landed.** The "Execute only the task and path scope the parent assigns" line, the review-brief limits, the 150-line cap in `knowledge`, and the `spec:` bar are all still live.

---

❓ **Q1 - What makes a rule binding?** (revised) In round one I counted "what done means" as part of the task, so binding. The `spec:` bar shows why that's too generous. It was a writer's idea of what done looks like, and it threw away real findings. Your correction covers how a task is *completed* as well as how it's pursued, so a rule about finishing is route too.

The revised test: a rule is binding only when it is
- the goal as its owner stated it, or
- a decision that isn't the reader's to make, because you, another subagent, or the ticket's scope owns it,

and only the owner of that decision can make it binding.

Anything a writer adds to turn the goal into something checkable is route: a citation bar, a count, a list to choose from. Under this test, "never push to main" binds because merging is yours. The delegation rule binds because you set it. The `spec:` bar doesn't bind: no owner asked for it, and it narrows what counts as a finding.

➡️ This revised test.

---

❓ **Q2 - When may the writer share what it knows about the route?** (revised) Round one asked how to write it; the research changes the question to *whether* to share it at all. A tool quirk or a known trap helps any reader. But the writer's beliefs about the answer lead the witness: where it thinks the bugs are, what it expects to find, what it hopes is true. That damage is worst for a subagent whose job is to judge.

➡️ Share facts about the environment the reader couldn't easily find, always with the reason, and let the reader take another route as long as its report says so. Never share the writer's beliefs about the answer with a subagent whose job is to judge. Leaving something out is always allowed; dressing a belief up as a fact is not.

---

❓ **Q3 - What does a reader do when a binding rule blocks the goal and nobody is there to sign off?** (revised) The existing mechanisms stay, each for its own situation. This question fills only the gap.
- (a) Stop that part, report the conflict to whoever owns the rule, and carry on with the rest.
- (b) Break the rule and report it.
- (c) Shrink the goal to fit the rule.

➡️ (a). Never (c): quietly shrinking the goal to fit a rule is the failure this ticket is about, seen from the reader's side. The `spec:` reviewers did exactly that.

---

❓ **Q6 - Does any of this change with the task or the reader?** (new) The research's one case for specific method is simple tasks and less capable readers. The factory has a Supporting tier, and plenty of small mechanical jobs. The options:
- (a) The test from Q1 holds everywhere. What changes is only how much route knowledge the writer shares under Q2.
- (b) Simple tasks or Supporting-tier readers may receive route rules that bind.

➡️ (a). A cheaper reader gets more knowledge with reasons, never a wall. If a route has to be followed exactly, that means its owner made it binding, which Q1 already covers.

---

**Q4 and Q5 are unchanged:** an orchestrator passes binding rules down and binds what it owns, but doesn't invent any; and a budget is stated as a fact about the situation, binding only when you set it yourself.

**Next round, once Q1 settles:** which rules may sit on a rung that nobody can overrule, like a hook. Belief 3 pushes rules down the ladder, and the delegation hook already holds a route rule that no prose can override.