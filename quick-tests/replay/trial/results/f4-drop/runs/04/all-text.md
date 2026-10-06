I'm starting with where this map should end up. The current Destination line still contains the "shape the search" wording you just corrected, so it has to change before anything else. Meanwhile a background agent is finding out what already exists: the writing skills, where briefs to subagents get written, and the earlier audit files in `.scratch/`. Questions that depend on those facts will come in the next round.

❓ **Q1** - **Reword the Destination**: Here is the current line:

> ...and brief templates for the recurring lane jobs whose fixed parts never shape the search.

That ending is the narrow framing your note replaced. Here's my proposed rewrite of the whole line:

> A theory-of-mind writing standard for everything an agent writes to another agent or to a person (briefs, review briefs, handoff files, PR text, factory files); an audit and rework of the existing factory-authored files and briefs against it; and brief templates for the recurring subagent jobs, whose fixed parts give the reader what it can't know on its own and leave how it pursues the task to the reader.

"Give the reader what it can't know on its own" makes room for the two kinds of constraint we talked about that do help. One kind carries knowledge, like "use `vp`, not `npm`". The other keeps parallel agents from colliding, like "another agent owns these files".

➡️ Use the rewrite, unless you'd rather keep your own sentence, "we don't want to constrain the design architecture of how the task is pursued or completed", as the template clause word for word.

---

❓ **Q2** - **Where does the map stop?** By default a wayfinder map only plans. It ends when every decision is made, and a spec carries the actual work into tickets. The current Destination also names doing the work: the audit, the rework and the templates. There are three ways to draw the line:

- **(a)** The map ends at decisions: what the standard says, how the audit is run, and how templates are built. Then `/to-spec` and `/to-tickets` turn that into the work.
- **(b)** Same as (a), except the standard itself gets drafted inside the map as a prototype ticket, so you're reacting to real text rather than a description of it.
- **(c)** The map carries all the execution through to the end.

➡️ **(b)**. The standard is the thing every later decision depends on, and you'll judge it better by reading a draft than by answering questions about one. The audit and the rework across dozens of files are execution, so they go to tickets.

---

❓ **Q3** - **Is writing for people in scope?** The Destination includes PR text, and your original message covers the agent who talks to you in words you never saw defined. That would put two readers in this map:
- other agents;
- you, along with any stranger who reads a PR.

Today those are separate skills: `writing-for-agents` for agents, and `technical-writing` and `unslop` for people.

➡️ In scope, as one standard with the reader as the thing that varies. Your diagnosis is the same for both: the writer doesn't picture what the reader has in their head. `unslop` and `technical-writing` stay as style passes on top of it, not as competing standards.

---

❓ **Q4** - **How will we know it worked?** The map "Optimize token use and wall-clock time without losing reliability" is meant to supply the baseline and the A/B testing, but none of its tickets exist yet. If this map's rework lands first, there's no "before" to compare against. The options:

- **(a)** Judge by reading. You and a reviewer agent compare old and new.
- **(b)** Before the rework, this map takes a small "before" sample on its own: a few recurring jobs, briefed the current way, with their results kept. The comparison runs later, once the optimization map's harness exists.
- **(c)** Hold the rework until the optimization map has its baseline.

➡️ **(b)**. It's cheap, it keeps the "before" from being lost, and it doesn't stall this map on the other one.

---

❓ **Q5** - **A standing rule for this map's own sessions**: every brief this map's sessions write, whether to research agents or reviewers, has to meet the standard being designed, starting now and under the rule from your note. Each ticket also quotes your words rather than summarizing them, the way the map does. This would go in the map's Notes so every session reads it.

➡️ Yes. A map about how to brief agents shouldn't brief its own agents the old way, and it's the first live test of the ideas.