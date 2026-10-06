The background search has finished. Three of its findings change round one. Q1 to Q5 are still open, and I'm waiting on your answers.

**1. The factory already has five instructions for what to do when a rule gets in the way, and they disagree.**
- **Ask first:** say so loudly and get a sign-off before breaking the rule (both AGENTS.md files). Nothing explains how an unattended subagent gets that sign-off. It also pulls against "never block on the human; proceed on anything reversible", which is in the same file.
- **Comply first:** follow the file, then explain why your instinct differed (`template/AGENTS.md:16`).
- **Skip visibly:** a skipped step stays in the list with a one-line reason (upstream pstack). The delegation playbook turns this off for itself.
- **Hand it back:**
  - A writer that can't implement a test cell as written stops and reports it.
  - Writer flags must end as `fixed:` or `accepted: <reason>`.
  - A design hole is written back onto the ticket.
- **Decide and record:** where the spec is silent, decide and write a Provisional row so you can overrule it.

None of the audits looked at these five. So Q3 really asks whether one of them wins, or whether one rule replaces all five. My recommendation stays the same: stop that part, report to the rule's owner, carry on with the rest. The "ask first" line would then need rewording, because as written it can't work for a subagent.

**2. Some rules about the route earned their place.**
- The mandatory trail review found an owner's error in 3 of 3 runs.
- The delegation hook exists because an agent knowingly broke the prose rule.
- The blast-radius rule exists because a narrowly scoped agent let a hook bug survive four review rounds.

Each has a recorded failure behind it and a decision you approved. That fits my Q1 recommendation, but it adds a condition. What makes these rules good is that each one carries its reason, not only that you own it. With the reason, a reader can tell when it faces a case the rule wasn't written for and take it to Q3 instead of complying silently. Revised Q1 recommendation: a rule is binding when its owner made it binding and it carries its reason. Today many rules carry no reason, for example "never an arena", the 150-line read cap and "do exactly the task in your prompt".

**3. A rule about how results are handed back did as much harm as the reading limits.** The review brief requires every serious finding to cite a line from the ticket, but it never shows the reviewer the ticket. Honest reviewers therefore downgraded real bugs. On PR #99 one reviewer filed nothing at all, though the PR had four serious behaviour bugs. This matters because the response on the map that you approved put "how to report" in the always-safe fixed part of a template. That repeats the "protect the world" mistake: it treats a whole category as safe without checking. It becomes Q6 below.

The research ticket also has a draft on its branch. It finds that step-by-step method instructions help on simple tasks and hurt on complex tasks given to capable readers. It also finds that no study tests a limit on strategy directly. That supports Q2 (b): pass on what you know, with its reason, never as an order.

---

❓ **Q6 - Is the shape of the report part of the route?** Some scripts need fixed fields; `review-comment.sh` refuses a report in the wrong shape. The options:
- (a) Yes. The writer says what it needs and why, the reader decides how to present it, and any script that needs a fixed shape does its own conversion.
- (b) The shape may be binding when a script reads it, but it may never decide what gets reported. Anything that doesn't fit the shape still goes in, in a section of its own.
- (c) The shape is binding.

➡️ (b). The harm didn't come from having a fixed shape. It came from the shape deciding what counted as a finding. The rule would be: a report format can say how to write a finding down, never which findings exist.

---

One thing goes to a different ticket. The audit rates upstream pstack's "Execute only the task and path scope the parent assigns" as the single worst limit, but my memory says upstream rules stay as they are. Whether this decision reaches vendored text belongs to the ticket "Decide the scope and order of reworking existing files". I'll note it there when this one resolves.