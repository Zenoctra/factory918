The background search finished. Some of what it found changes the round I just asked, so here is a revised version. You haven't answered the first one yet, so nothing is lost.

**What the search found that bears on these questions**
- **The factory has five ways to depart from a rule, and they conflict.**
  - "Say so loudly and get a sign-off" (`AGENTS.md:26`, `template/AGENTS.md:20`) came from Theo's file. No skill repeats it, and no text says how a subagent would get a sign-off.
  - `template/AGENTS.md:16` says the opposite: follow the file, then explain why your instinct differed.
  - Three more ways exist: a Provisional row in DECISIONS, pstack's `skip: <reason>`, and stopping to report a test cell that can't be implemented as written.
  - None of the run-2 audits looked at these.
- **Some rules about method have evidence behind them.**
  - The mandatory trail review caught the owner's errors three times out of three.
  - When an agent skipped `architect`, a hook bug survived four review rounds.
  - An agent broke the delegation rule while knowing the rule, so a hook now enforces it.
  - My first-round test would make these rules binding only because you set them. Their real support is the evidence.
- **Many rules carry no reason.** Examples: "never an arena", the 150-line read cap, "Do exactly the task in your prompt". With no reason, the reader can't tell when the rule doesn't fit.
- **PHILOSOPHY leans the other way.** Belief 3 pushes rules down to the strongest rung, where no prose can override them. Belief 7 prefers copying a known pattern over working from first principles. Whatever we decide here may mean amending those beliefs.
- **The run-2 constraints audit sorted rules with the test you rejected.** Its classes were: what a subagent may look at, what it may run, caps, safety (kept), and report format (kept). Its "keep" calls need re-judging. That belongs to the rework ticket, not this one.
- **There is a research write-up on an unmerged branch.** The search reports that it supports your broader framing. It also says specific method helps on simple tasks and inexperienced readers, and that no study of models tests a limit on strategy directly. I haven't read it myself; my attempt to open it was blocked.

---

❓ **Q1 - What makes a rule binding?** A rule is binding when the reader may not overrule it alone. The options:
- (a) **What it's about:** it states the goal, what done means, or a decision that belongs to someone else (you merge; another subagent owns a file).
- (b) **Who set it:** only its owner can make it binding.
- (c) **Evidence:** a rule about method is binding when a recorded case shows the reader's own judgment fails there. The trail review and the delegation rule are examples.

➡️ All three, each covering different rules. (a) and (b) cover the task and authority. (c) is the only way a rule about method becomes binding, and the rule must cite its case. A rule about method with no case behind it is knowledge (Q2), not a rule.

---

❓ **Q2 - How does the writing carry something the writer knows about method?** The options:
- (a) Leave it out.
- (b) Say it as knowledge, with its reason. The reader may take another route and says so in its report.
- (c) Say it as an overridable default.

➡️ (b), and include it only when the reader couldn't easily find it out alone. The missing reasons above show why: a rule without its reason can only be obeyed or ignored, never adapted to a case the writer didn't foresee.

---

❓ **Q3 - One way to depart from a rule, or several?** The five above conflict: get a sign-off first, follow and explain afterward, record a Provisional row, skip with a reason, or stop and report. The options:
- (a) One mechanism everywhere.
- (b) One per kind of rule.
  - For a binding rule that fights the goal, the reader stops that part, reports to the rule's owner, and carries on with everything else.
  - For knowledge about method, the reader takes its own route and reports it, the way `skip:` already works.
  - Gaps in the spec keep the Provisional row.
- (c) Keep all five as they are.

➡️ (b). Two things go away: the sign-off line, which an unattended subagent can't satisfy, and "follow the file, then explain", which bends the goal to fit the rule. Under every mechanism, the reader never quietly narrows the goal to fit a rule.

---

❓ **Q4 - Who may write a binding rule into a brief?**

➡️ An orchestrator passes your rules and the ticket's rules down unchanged and binds only what it owns itself. Its own judgment about method goes in as knowledge (Q2). The reviewer failure started exactly when the orchestrator's guess about where the bugs were became a wall.

---

❓ **Q5 - Can cost or time limit the method?**

➡️ A budget is stated as a fact, and the reader plans its route within it. It is binding only when you set it yourself. The efficiency map can revisit this once it has measurements.

---

❓ **Q6 - Do PHILOSOPHY beliefs 3 and 7 change?**
- Belief 3 says the strongest rung wins. It still holds for rules that are binding under Q1. For knowledge about method, a hook would just be a wall with no exit.
- Belief 7 says a copied pattern beats a first-principles idea. It reads as advice about method, and Q2 would say it is knowledge, not a rule.

The options:
- (a) Amend both, so each states which kind of rule it applies to.
- (b) Leave them, and let the writing standard narrow them.
- (c) Leave this to the ticket "Decide what the writing standard is and what carries it".

➡️ (a), drafted under that ticket, but decided here, because the scope of each belief follows from Q1.