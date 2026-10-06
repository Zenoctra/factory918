The background search has finished. Two of its findings change how round one should read. You haven't answered yet, so here is what it found and a revised Q3 to replace mine.

**What it found**

- **The factory has five ways for a reader to depart from a rule, and they contradict each other.** All five were found by grep across the repo:
  - "Say so loudly and get a sign-off" (`AGENTS.md:26`, `template/AGENTS.md:20`). This was copied from Theo and appears nowhere else. Nothing says how an unattended subagent would get a sign-off.
  - "Follow the file and tell me why your instinct differed" (`template/AGENTS.md:16`). This means comply first and explain afterwards, the opposite default to the sign-off line.
  - Decide where the spec is silent and record a Provisional row for you to overrule.
  - pstack's `skip: <reason>`, which `feature.md:12` then shuts off for delegation.
  - Report back instead of improvising, as in `fixed:`/`accepted:` and "stop and report the cell".

  None of the run-2 audits looked at these.
- **The route rules that helped and the ones that hurt have different origins.**
  - The ones that helped were set by you after a failure was measured: the mandatory trail review (it caught the owner's errors 3 of 3 times), the delegation hook, the blast-radius rule, and P18's definition of "hard".
  - The worst harmful ones were added by subagents to save cost, with no ticket asking for them: "read nothing, run nothing", "under 400 words", and "zero items is expected" (#33, #93, #107).
  - This supports the owner half of my Q1 recommendation and Q4.
- **The harm reaches past search.** The `spec:` gate is a rule about how findings get filed. It made honest reviewers downgrade real bugs, and Sol filed nothing on pr99, which had 4 hard bugs. P109's "at most N" was a rule about how the work finishes.
- **The run-2 constraints audit was built on the old split.** It sorted limits into classes and kept "safety" and "format" as acceptable. Its own late addendum admits the format class hid the `spec:` gate. So its counts (79 of 108 templates) measure the old framing, not yours.
- **Some of the research for this map supports Q2.** It's on `research/wording-and-reader-context`, not yet merged. It finds that a specific method helps on simple tasks and for novices. It also finds that holding back what the writer volunteers is a different thing from limiting what the reader may look for. No study tests a limit on strategy directly.
- **Most of the run-2 audits' recommendations were never applied.** "Execute only the task and path scope the parent assigns", the 150-line read cap, `ticket.md:13,45,46` and the `spec:` gate are all still live. That's work for the rework ticket, not this one.

**Revised Q3**

❓ **Q3 - What does the reader do when a binding rule fights the goal?** The factory currently gives five answers that disagree with each other, listed above. The question is which one survives. The options:
- (a) **Stop and report.** The reader stops the part the rule blocks, tells the rule's owner what the conflict is, and carries on with everything else.
- (b) **Break it and report.** The reader breaks the rule and says so in its report.
- (c) **Comply and explain.** The reader follows the rule and reports why it thinks the rule was wrong.
- (d) **Shrink the goal.** The reader narrows the goal until the rule fits.

➡️ (a) for binding rules, and nothing else carries that weight. Route knowledge (Q2) is departed from freely, with a line in the report. The five current mechanisms collapse into those two. (d) is never acceptable. (c) should go, because it's how a reviewer ends up filing nothing on a PR with four hard bugs.

Q1, Q2, Q4 and Q5 stand as I wrote them. I'm waiting for your answers before the next round.