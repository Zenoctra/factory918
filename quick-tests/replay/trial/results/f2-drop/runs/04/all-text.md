The background search is done. Nothing you've said has come in since round one, so all five questions are still open. Two of its findings change round one, and the rest adds evidence.

**A change to Q3.** I said the factory has one rule for when a rule fights the task. It actually has five, and they disagree:

- **Say so loudly and get sign-off first** (`AGENTS.md:26`, `template/AGENTS.md:20`). Nothing says how a subagent gets that sign-off.
- **Follow the file, then explain where your instinct differed** (`template/AGENTS.md:16`). This is the reverse: comply first, explain after.
- **Decide, and record it as Provisional so you can overrule it** (`PHILOSOPHY.md:47-55`).
- **Skip a step, but say why** (pstack's `poteto-mode`). `feature.md:12` then turns this off for delegation.
- **Stop and report the step instead of filling it in**: the writer facing an unbuildable spec case (`feature.md:12`), and the gap path in `ticket.md:41-50`.

None of the run-2 audits looked at these. So Q3 is really two questions. What should the reader do when a rule fights the task? And should these five become one rule? I'd still answer the first with (a): stop that part, report to whoever owns the rule, carry on with the rest. I'd also say yes to one rule. The last two mechanisms already work that way.

**A test of Q1, in both directions.** Some rules about the route clearly did good:
- The required trail review found an owner's mistake in 3 of 3 runs.
- The delegation hook exists because an agent broke the prose rule knowingly.
- The blast-radius rule exists because a narrow look let a bug survive four review rounds.

Each of these was set by you and carries a measured reason. The rules that did harm were added by agents for cost, with no reason given and no ticket asking for them:
- "Read nothing beyond this brief."
- The `spec:` citation gate, which made honest reviewers downgrade real bugs.
- The 150-line read cap.

That supports the owner test in my Q1 answer. It also points to a question for round two, which depends on Q1: whether a rule binds only if it states its reason. Today some rules give one and some don't. "Never an arena", "Do exactly the task in your prompt" and the 150-line cap don't.

**Also on the table**, but not decided here:
- `research/wording-and-reader-context` already holds a research doc written for this ticket. In its reading, the evidence supports your broader framing over the search-only one. It also gives a counterweight: on simple tasks and for less capable readers, specific steps help. And it notes that no model study tests limits on strategy directly. I'll bring it in where it bears on an answer.
- Two beliefs in `PHILOSOPHY.md` lean the other way. Belief 3 pushes rules into hooks, where nothing can override them. Belief 7 prefers a copied pattern to a fresh idea. If your answers here go the way I recommend, those beliefs need wording that fits. That would be a later question, or a ticket.
- Most of the audits' recommended cuts have still not landed: "Execute only the task and path scope", the `review-brief.sh` limits, the 150-line cap, and the `spec:` gate. Fixing them is the rework ticket's job, once this ticket settles the rule they'd be judged by.

Round one, Q1–Q5, is above and waiting on your answers.