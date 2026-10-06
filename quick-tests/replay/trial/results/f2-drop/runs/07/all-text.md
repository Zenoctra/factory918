The background search finished. You haven't answered round one yet, and three of its findings change the questions, so here are the changes before you answer.

**1. The factory has five ways of departing from a rule, and they don't agree with each other.** This replaces Q3 as I wrote it.
- **Sign-off.** `AGENTS.md:26` says to say so loudly and get a sign-off. Only the two AGENTS files say it, and nothing tells a subagent how to get a sign-off.
- **Follow, then explain.** `template/AGENTS.md:16` says to follow the file first and explain afterward, which is the opposite default.
- **Re-read the reasoning, or record your own call.** `MANUAL.md:168` says to re-read PHILOSOPHY "when a rule fights you". Where the spec is silent, the agent decides and records a Provisional row.
- **Skip with a reason.** Upstream pstack allows a visible `skip: <reason>`, but `feature.md:12` turns that off for delegation.
- **Stop and send it back.** A writer that can't build a cell stops and reports it, a design hole is written onto the ticket, and a bad criterion goes back to you.

None of the audits examined these mechanisms themselves. I can't find any record of the sign-off line ever being used.

**2. The run-2 audits mostly measured limits on reading and running, but a rule on how the work is finished did comparable damage.**
- **The `spec:` gate.** It required every hard finding to cite a ticket criterion, yet the Standards brief never showed the reviewer the ticket. On pr99, Sol obeyed it and filed nothing, though all four of that PR's hard bugs were behaviour bugs.
- **The audit's own blind spot.** The constraints audit first filed the gate under "report format" and treated it as safe. Its late addendum corrects that. The audit's categories reproduce the "protect the world / shape the search" split, so it missed the same thing you corrected.

This is evidence for your broader framing: it covers how a task is *completed*, not only how it is searched.

**3. Some rules on method did good, and those mostly carry their reasons.**
- **Kept on evidence.** The mandatory trail review caught owner errors three times out of three. "Owners start one at a time" has a measured reason. The blast-radius rule came from a hook bug that got past four review rounds.
- **The reason-less ones look arbitrary.** Examples are "never an arena", "Read no brief and no diff" and the 150-line read cap. They're the ones the audits flagged.

This supports Q2(b): a rule about the route should carry its reason.

The audits' recommendations mostly haven't been applied. "Execute only the task and path scope the parent assigns" is still in the pstack wrapper. The `spec:` gate is still live at `review-brief.sh:494`. That's for the rework ticket, not this one.

Revised and added questions:

---

❓ **Q1, a case to add** - Under my test, "where results go and in what shape" counts as part of the task, so it's binding. The `spec:` gate looked like a shape rule but decided what the reviewer was allowed to report. Does the test need to separate the **shape of the answer** (binding) from **what counts as an answer** (part of the goal, so only the goal's owner may narrow it)?

➡️ Yes. A report format may say how findings are written down. It may never decide which findings are allowed to exist.

---

❓ **Q3, revised - Which departure mechanism does the standard adopt?** The factory has the five above, and they pull in different directions.

➡️ One rule for binding rules and one for the route.
- **A binding rule that fights the goal.** The reader stops that part and sends the conflict, with its reason, back to the rule's owner, which is your "stop and send it back" family. It never narrows the goal to fit the rule.
- **A rule about the route.** These are offered as knowledge under Q2, so departing from one needs no permission, only a line in the report saying what the reader did instead and why.

The sign-off line and "follow, then explain" would then be rewritten to match. I've kept that for the next round, because it depends on Q1 and Q4.

---

**Next round, once Q1 and Q2 settle.** PHILOSOPHY's belief 3 (push every rule to the strongest rung, where no prose override exists) and belief 7 (copy a pattern rather than reason from first principles), and line 23's "follow a script rather than improvising", lean toward binding the route. The standard will have to either fit inside them or amend them. A side note: `MANUAL.md:168` still says "twelve ordered beliefs", but there have been eleven since ecdb732.

The searcher also found a research note on the branch `research/wording-and-reader-context`. It says it was written for this question and adds a counterweight: specific instructions on method help on simple tasks and for beginners. It also separates the writer holding back what it volunteers from limiting what the reader may look for. I tried to open it to confirm which ticket it belongs to, and the shell call was denied, so that comes from the searcher's account, not my own reading.