I'm charting the map now, starting by settling where it ends. A background agent is collecting facts I'll need later: where `writing-for-agents` comes from, which briefs repeat, and the old audits in `.scratch/`. These five questions don't depend on those facts.

❓ **Q1** - **The destination's wording**: The current Destination ends with "brief templates for the recurring lane jobs whose fixed parts never shape the search." Your note on 2026-09-30 retires that framing. The Destination is the line every session reads before it picks a ticket, so the old wording would keep steering sessions toward the narrow rule.

➡️ Rewrite it as: "A theory-of-mind writing standard for everything an agent writes to another agent or to a person; an audit and rework of the factory's existing files and briefs against it; and brief templates for the recurring lane jobs, built so they never constrain how a lane designs its approach to the goal." The exact test for what counts as a harmful constraint should be decided in its own ticket, not settled in this line.

---

❓ **Q2** - **Where this map stops**: By default a wayfinder map only plans, and it ends by handing a spec to `/to-spec`. The current Destination also names "an audit and rework," which is execution work. Here are three possible end points:
- (a) The map ends at decisions: the standard's shape, how the audit runs, and how templates are designed. Writing the standard, auditing and reworking all become tickets afterward.
- (b) The map writes the standard itself, and the audit and rework become tickets.
- (c) The map carries everything through.

➡️ (a), with one exception: a small sample audit of real briefs runs inside the map as evidence. The standard should be built from failures we can see in this repo's own briefs, not only from theory. The full audit and rework wait until the standard exists.

---

❓ **Q3** - **What writing the standard covers**: Writing in the factory has several authors. Agents write briefs, PRs, comments, tickets and factory files. Vendored skills (Matt's, pstack's) are text we only change through patches. Your own messages, like the long one quoted in the ticket, also reach agents. Which of these does the standard govern, and which ones does the audit read?

➡️ The standard governs everything an agent writes. The audit also reads vendored skills, because `writing-for-agents` is vendored and it's the main suspect. A fix there goes through `patches/` only where it's worth the cost of maintaining a patch. Your own writing to agents is outside the standard, but the standard could teach agents how to receive it, for example by reading a list as examples unless it says it's complete.

---

❓ **Q4** - **One standard or two**: A reader who is an agent starts with nothing and gives in easily. A person reading a PR can ask questions, but gets worn down by jargon. Should agent readers and human readers get one standard or two?

➡️ One standard with one root: picture the reader, meaning what they already know and where your words will pull them. Agents and people differ in what that picture contains, not in the discipline itself. Two standards would split the root and teach that this is about format.

---

❓ **Q5** - **Is proving it works part of this map?**: The map "Optimize token use and wall-clock time without losing reliability" is building the baseline and the A/B instruments. If this map ends without evidence that the standard changed what agents do, the standard is another claim.

➡️ Yes, a narrow version: the map decides how the standard will be judged, for example a before/after test on one recurring lane job. It borrows the other map's instruments rather than building its own, and a ticket here waits on that map where the instruments aren't ready yet.