I'm in the first step of charting the map: settling the destination. An agent is checking what already exists in the repo: the writing skills, every place one agent briefs another, and the old audits in `.scratch/`. The questions that depend on those facts will come in the next round. These five don't depend on them.

Some terms, since I'll use them throughout:
- A **brief** is the message an orchestrating agent writes to start a subagent.
- A **recurring job** is a subagent task the factory runs over and over, such as a code reviewer or a spec reviewer.

---

❓ **Q1** - **The destination's wording on templates**: The map's Destination still says the brief templates' "fixed parts never shape the search". That's the framing your note replaced. The destination is what every session on this map orients to, so if it keeps the old framing, every later ticket inherits it. Here is a candidate rewrite of that clause:

> brief templates for the recurring jobs, written so that nothing in them limits how the agent pursues or completes the task unless the writer knows something the agent can't, and says so

➡️ Edit the Destination in place, and use your sentence plus the test from the one after it: a constraint is harmful when it wasn't written with the agent's own better strategy in mind. The wording above is my attempt at that, and you should rewrite it freely. The quoted conversation in Notes stays as it is, with your comment as the correction.

---

❓ **Q2** - **Where this map ends**: Wayfinder plans by default, and the map is finished when nothing is left to decide. The current destination also includes "an audit and rework" of the existing files, which is doing work, not deciding. One option is to end the map at a spec: the standard is defined, and the audit method and the template design are decided. The audit and the rework would then run afterwards as ordinary tickets. The other is to carry execution into the map itself.

➡️ End at a spec. One exception: audit a small sample of the existing files inside the map, as research. The standard should be drawn from failures actually found in the factory, not only from the failures already described in the ticket. That matters especially because your own message warned that its examples would become the boundary.

---

❓ **Q3** - **One standard or two**: The destination covers writing to an agent and writing to a person. Your message puts the root failure in the same place for both: the writer doesn't model what the reader has in their head. What differs is the reader. A person can stop and ask what a term means. An agent guesses and moves on. A person usually has more standing context than an agent does. Should this be one standard that asks the writer to model the specific reader, or two documents?

➡️ One standard, built on modeling the reader, with the differences between readers handled inside it. The other choice would leave `unslop` and `technical-writing` as the person-facing half, and #146 decides how they relate. I can't say how they relate until the agent reports back, so that part waits.

---

❓ **Q4** - **How we'll know it worked**: Your fear is silent failure. Is a brief written to the new standard actually better, and better at what? [Optimize token use and wall-clock time without losing reliability](https://github.com/Zenoctra/factory918/issues/145) is the map that owns measurement across the factory. One option is for this map to define what a better result means for a brief and let that map supply the instrument. The other is for this map to build its own before-and-after test.

➡️ This map decides what "better" means for each recurring job. Some examples: did a reviewer find bugs that sit outside the diff, and did a subagent invent a meaning for a term it was never given? The A/B instrument itself belongs to the token-use map. If that map hasn't built one by the time we need it, that becomes a blocking ticket here.

---

❓ **Q5** - **What's missing from what you've said so far**: Your message warned that a list of examples becomes the boundary of the answer. The ticket's examples are a constraint that fights its goal, a list that turns into multiple choice, leading the witness, and a term defined in a context the reader never saw. Those are the failures you happened to name. Are there others you've seen that aren't in the ticket? They could be in how agents write to you, to each other, or in the factory's files. Anything you name now goes in as one more starting example, not as a closed set. Part of the sample audit in Q2 exists to find what neither of us has named.

➡️ I don't have a recommendation here. This one is only yours to answer, and "nothing more for now" is a fine answer.