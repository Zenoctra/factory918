The background search has finished. Round one is still waiting on your answers. What it found changes my Q3 and adds one question; Q1, Q2, Q4 and Q5 stand as I asked them. (I tried to read the research branch's write-up directly and that command was denied, so the points about it below come from the search agent's summary.)

**What the search found that bears on this round:**

- **The factory has five different ways to depart from a rule, and they contradict each other.**
  - Both AGENTS files say "say so loudly and get a sign-off" (`AGENTS.md:26`, `template/AGENTS.md:20`).
  - Two lines earlier, `template/AGENTS.md:16` says the opposite: follow the file first, then explain.
  - `template/AGENTS.md:18` says never block on the human for anything reversible.
  - pstack lets a step be skipped as long as the skip and its reason are recorded, but `feature.md:12` turns that off for delegation.
  - Some review steps send the problem back to you or to the ticket instead.
  - No text says how a subagent gets a sign-off, and I found no record of one ever being asked for.
- **Some rules about the route carry their reason and some don't.**
  - With a reason: "two plain commands, because the guard refuses `git` inside `$(...)`".
  - Without one: "never an arena", the 150-line read cap, "Do exactly the task in your prompt".
- **Some rules about the route did real good, and each was set by you with a measured reason.**
  - The mandatory trail review caught the owner's mistakes 3 times out of 3.
  - The delegation hook was added after an agent broke the prose rule knowingly.
  - The blast-radius rule came from a bug that survived four review rounds.
  - That supports the "who owns the rule" half of my Q1 answer.
- **The run-2 constraints audit sorted rules with the test you've now rejected.** Its "keep / delete" calls are built on the old sorting. Its own late addendum found the same kind of harm in rules about how the work is finished. Example: the `spec:` gate led Sol to file nothing on a PR that had four hard bugs. Most of the audit's recommendations haven't been applied yet. Whether they get re-sorted under the new test belongs to the ticket "Decide the scope and order of reworking existing files", so I'll note it there rather than ask here.
- **A research write-up for this ticket already exists**, on the unmerged branch `research/wording-and-reader-context`. Its summary is in three parts:
  - **What it supports:** the broader framing. The study evidence favors stating the goal specifically and leaving the method open, with one exception: telling the reader what to report holds up.
  - **Counterweights:** step-by-step method helps on simple tasks and for novices. A writer holding back what it volunteers is different from a writer limiting what the reader may look for.
  - **The gap:** no study tests a limit on an AI model's strategy directly.

**Revised Q3 and a new Q6:**

❓ **Q3 (revised) - Which single way of departing from a rule replaces all five?** When a binding rule fights the goal, should the reader follow the rule, stop and ask, or break it and report? It needs one answer that works in both settings: a subagent running unattended, and the conversation with you. The options:
- (a) Stop the part the rule blocks, carry on with the rest, and put the conflict at the top of the report to whoever owns the rule.
- (b) Follow the rule, then explain the conflict afterwards.
- (c) Ask for a sign-off. This only works in a live conversation.

➡️ (a) everywhere. In a live conversation, "reporting to the owner" is simply saying it to you, so (c) becomes a special case of (a). Rules about the route aren't binding (Q1), so the reader just takes another route and says so (Q2). Never quietly narrow the goal to fit the rule.

---

❓ **Q6 - Must every binding rule carry its reason?** The reason is what lets a reader recognize the case the rule's writer didn't foresee and report it under Q3. Without one, the reader can only obey or guess. The options:
- (a) Yes, in the same place the rule is written, or behind a pointer to the DECISIONS row.
- (b) Only where the reason isn't obvious.
- (c) No, and hooks carry the rules without prose.

➡️ (a). The DECISIONS table already has a required Reason column, so this extends a habit the factory already has. A rule whose reason nobody can state is a sign it should be looked at again, as the 150-line cap was.