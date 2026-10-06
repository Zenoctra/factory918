I've sent an agent to map what already exists: the current writing skills, every place where one agent writes instructions for another, and the earlier audits sitting in `.scratch/`. The questions about where the standard should live and how far the audit reaches wait on what it finds. The ones below don't depend on it, so here's the first round.

I'll try to follow the standard while asking. Where I offer options, they're examples to react to, not the full range of answers.

---

❓ **Q1 - What the destination says about templates**: The map's destination ends with "brief templates for the recurring lane jobs whose fixed parts never shape the search." (A lane is a subagent given one job; a brief is the message that starts it.) That's the narrow framing you corrected today. Your version was "we don't want to constrain the design architecture of how the task is pursued or completed." Your follow-up sentence supplied the test: a constraint does harm when it wasn't written with the agent's own strategy in mind.

➡️ Rewrite the clause as "brief templates for the recurring lane jobs, whose fixed parts leave the reader free to pursue the goal in whatever way it judges best, and give a reason for every limit they do set." The reason is what lets the reader tell when a limit doesn't apply to its situation.

---

❓ **Q2 - What counts as a "brief"**: Your message covers agents writing to agents and agents writing to you, and the destination lists briefs, review briefs, handoff files, PR text and factory files. Those need one word that covers all of them, or the standard will apply itself narrowly again. My proposal is to define the thing by the reader's position, not the format: **any text whose reader has to act on it without being able to ask the writer what was meant.** A subagent can never ask. A future agent reading a skill can't either. You can ask, but each question costs you effort, which is the jargon complaint.

➡️ Adopt that as the definition of what the standard covers. Record it in the glossary under one name; I'd suggest "brief" in the broad sense, unless you'd rather keep "brief" for subagent starters and use another word for the whole class.

---

❓ **Q3 - One standard or two**: Writing for you and writing for agents fail from the same root: the writer doesn't picture the reader. But they fail in different ways. You can stop and ask; an agent guesses and moves on. Agents are also far more steerable, which matters most for leading the witness.

➡️ One standard with one root, plus short notes on where the reader types differ. Two standards would split the root idea, and the human-facing half would drift back toward "avoid jargon."

---

❓ **Q4 - Where the map stops**: The destination includes "an audit and rework" of the existing files. Rework is doing, not deciding, and wayfinder maps stop at decisions unless the Notes say otherwise. One option is to stop at a spec plus tickets and do the rework through `/to-spec` and `/to-tickets` as normal execution. Another is to carry the rework inside the map.

➡️ Stop at a spec plus tickets. The audit can still happen inside the map as research, because what it finds shapes the standard. The fixes it calls for become execution tickets.

---

❓ **Q5 - How we'll know it worked**: You worry that these failures are silent. A writing standard that reads well but changes nothing would be exactly that kind of silent failure. [Optimize token use and wall-clock time without losing reliability](https://github.com/Zenoctra/factory918/issues/145) plans an A/B benchmark for single-sentence changes, but it's a separate map running in parallel.

➡️ This map owns its own proof and doesn't wait for #145. Keep a frozen task, such as a review of a diff with bugs planted in it, and measure what the old brief and the new brief each find. If #145's baseline exists by then, use it; if not, don't block on it.