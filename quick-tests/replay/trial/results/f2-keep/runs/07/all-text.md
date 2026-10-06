The background search is back. Three things it found change round one. Your answers to the five questions are still open, so I've decided nothing yet.

**1. The factory has five ways to depart from a rule, and they disagree.** This sharpens Q3.
- **Say so and get a sign-off first.** This is in both AGENTS files (`template/AGENTS.md:20`). It was copied almost word for word from Theo's AGENTS.md, nothing else in the factory repeats it, and nothing records it ever being used.
- **Follow the rule, then explain.** `template/AGENTS.md:16` tells the agent to "follow the file and tell me why your instinct differed." That's the opposite default from the first.
- **Decide and record it as Provisional,** so you can overrule it later (`DECISIONS.md:67`).
- **Skip a step, but keep it on the list with `skip: <reason>`** (upstream pstack, `poteto-mode/SKILL.md:113`). The delegation step turns this escape off.
- **Send it back to whoever owns it.** Examples: the writer that stops at a test case it can't build as written, the design-hole amendment on the ticket, and `accepted: <reason>` on review flags.

The sign-off line also pulls against "never block on the human" (`template/AGENTS.md:18`), and a subagent has nobody to ask. None of the run-2 audits looked at these mechanisms.

**2. Some route rules earned their place.** This bears on Q1.
- The mandatory trail review caught a mistake by the subagent that owned the ticket 3 times in 3 (`ticket.md:26`).
- An agent once broke the delegation rule knowingly, so a hook now holds it (`ledger.md:16`).
- Another agent scoped its own grounding narrowly, and a hook bug survived four review rounds (`ledger.md:17`).

All of these are rules about the route, and under test (a) alone none would be binding. They're binding because you set them, each with a recorded failure behind it. That makes me more confident in recommending (a) and (b) together.

The other direction is recorded too:
- In P109's amendment, you called a derived "at most" list "a prediction, not a constraint" (`DECISIONS.md:109`).
- A subagent turned one of your questions into a rule on a ticket, and you removed it (`ledger.md:19`).
- Of 77 mandated subagents in run 1, nine changed an outcome (`ledger.md:39`).

**3. The constraints audit was built on the framing you've since rejected.** It sorted limits into "may look at / may run / caps", which it removed, and "safety / report format", which it kept. Its own addendum admits that the "report format" bucket hid real damage. The `spec:` citation gate made honest reviewers demote real bugs, and one reviewer filed nothing on a PR that had four hard bugs. So the audit's keep-or-delete calls need re-reading under whatever test this ticket settles. That's the job of "Decide the scope and order of reworking existing files"; I'll leave a note there and not open it here.

The research branch for "Research how wording and missing context shape a reader's response" has a counterweight that bears on Q2. Specific guidance on method helps on simple tasks and for novices. And holding back what the writer volunteers is different from limiting what the reader may look for. No study it found tests limits on strategy directly.

Here are the two revised questions. Q2, Q4 and Q5 stand as asked.

---

❓ **Q1 (revised) - What makes a rule binding?** The options are the same.

➡️ (a) and (b) together, now with evidence. A rule is binding when it states the task, or a limit on who decides what, and only the owner of that authority makes it binding. One addition: a binding rule about the route carries the failure that earned it, the way the trail-review rule cites its 3 of 3. The reason lets a later reader tell whether the rule still applies, and lets you retire it when it no longer does.

---

❓ **Q3 (revised) - What does the reader do when a binding rule fights the goal?** The factory has five answers today. The options:
- (a) one mechanism for every reader: stop that part, send the conflict to the rule's owner, carry on with the rest;
- (b) two mechanisms: a person-facing session asks first, and a subagent reports back to whoever briefed it;
- (c) keep all five and say which applies where.

➡️ (a). For a subagent, the "owner" it reports to is whoever briefed it, which passes the conflict up to you when the rule is yours. The `skip: <reason>` line becomes the visible form of a departure on a non-binding rule, the case under Q2. "Follow the file, then explain" and "get a sign-off before breaking it" both retire. "Shrink the goal to fit the rule" is ruled out in every case.