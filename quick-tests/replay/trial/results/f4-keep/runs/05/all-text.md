I've started charting #146. In the background, a search agent is listing what already exists: the `writing-for-agents` skill and its triggers, every place one agent briefs another, and the old audits from run 2. Questions that depend on those facts will come in a later round. These ones settle what the map is aiming at, and none of them depend on the search.

I've tried to keep these questions open where the real answer space is open. When I do give options, they're only my reading of the space, not a full menu.

---

❓ **Q1** - **The destination's wording**: The destination still says the brief templates' "fixed parts never shape the search", which is the framing you corrected today. It needs a replacement, and that replacement will steer every ticket under this map, so the wording matters more here than anywhere else. How would you put it?

➡️ "...brief templates for the recurring lane jobs, whose fixed parts leave the reader free to pursue the goal however it judges best, and which give the reason for any constraint they do impose." That second clause is the test from your note: a constraint built without the reader's own strategy in mind is the harmful kind. Giving the reason is what lets the reader see when the constraint doesn't fit its situation.

---

❓ **Q2** - **Where this map stops**: Wayfinder normally plans and doesn't build. Your destination says "an audit and rework of the existing files", and that's building. One option: the map ends once the standard, the audit method and the template design are all decided, and then it hands off to `/to-spec`, which turns the rework into tickets. The other option: the map carries the audit and rework itself.

➡️ Stop at the decisions and hand off. The audit itself will touch dozens of files, so it belongs in tickets and PRs, where each change gets reviewed. It shouldn't happen inside planning sessions.

---

❓ **Q3** - **Which readers count**: The destination includes writing for people (PR text, replies to you) as well as writing for agents. People already have `unslop` and `technical-writing`. Should one standard cover both readers, or should this map be about agents, with people mentioned only where the root cause is the same?

➡️ One standard, both readers. As you said, the root is the same: the writer doesn't picture what the reader has in their head. The difference is in degree. A person can stop and ask, and an agent guesses. The existing people-facing skills would stay, and they'd point to this standard as the foundation underneath them.

---

❓ **Q4** - **Product or workshop**: Should the standard ship in `template/`, so every project's agents follow it when they brief each other? Or is it workshop-only, for writing the factory's own files?

➡️ The product. Every project runs the same review, owner and swarm lanes, so every project has the same brief-writing problem. Auditing the factory's own files is the workshop part of the work.

---

❓ **Q5** - **How we'd know it worked**: These failures are silent. A brief that leads the witness still gets back a confident answer. Should this map design its own way to measure whether a rewritten brief does better? Or should it rely on the A/B benchmark that the token-and-time map ([#145](https://github.com/Zenoctra/factory918/issues/145)) is supposed to build?

➡️ Rely on #145 for the measuring tool, but this map should decide what counts as "better" for a brief. Example: a review brief is better if the reviewer finds more real bugs it wasn't pointed toward. #145 knows how to measure, but it can't know that. In practice, one ticket here defines success for briefs, and that ticket's answer goes to #145.