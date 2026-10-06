A background agent is cataloguing what already exists: the writing skills, where briefs get written, and the earlier audits in `.scratch/`. The questions that depend on those facts wait for its report. The questions below settle the destination, and none of them depend on it. Where I offer options, they're the ones I could see, not the whole space.

---

❓ **Q1 - Rewrite the destination around your correction**: The destination line still ends with brief templates "whose fixed parts never shape the search". That's the narrow framing you just replaced. Your note supplies the test that should take its place: a constraint does harm when it was written without picturing what the reader might do better.

➡️ Change the line to: "...and brief templates for the recurring lane jobs, where every fixed part either carries something the reader can't know or protects something outside the task, and states why, so the reader can tell when it doesn't apply." Change it in the map body itself, since every session orients to that line. Your comment stays the record of why it changed.

---

❓ **Q2 - Where does this map stop?** Wayfinder's default is to plan, not do. The destination currently names three things. The **standard** is a decision. The **brief templates** are partly a design decision. The **audit and rework** of existing files is execution, likely a lot of it, spread across dozens of files.

➡️ The map ends when the standard is written down and agreed, the audit method is decided (what it checks, how, and in what order), and the template design is settled. All of that goes to `/to-spec`. The audit itself and the rework run afterward as ordinary tickets. Otherwise this map turns into a months-long execution effort and never closes.

---

❓ **Q3 - One standard for agent readers and human readers, or two?** You described both: agents that guess at undefined terms and move on, and a person who burns attention decoding jargon from a context they never saw. Today they're split across skills: `writing-for-agents` for agents, `unslop` and `technical-writing` for people.

➡️ One standard, with the reader model at its core: who is reading, what they already have, what they'll do with it, and where these words will pull them. The reader's differences (a person can ask back, a subagent can't; a person has standing context, a fresh lane has none) go inside it as inputs to that model, not as a second rulebook. The existing skills then become tools the standard calls on, not competitors to it. Whether they get patched, wrapped or replaced is a later question that depends on what the agent finds.

---

❓ **Q4 - Product or workshop?** Factory files are written by this repo's agents. But every project's agents also brief subagents, write PRs and hand off work.

➡️ Product: the standard ships in `template/`, because the failure you described happens wherever agents talk to agents. The audit of the factory's own files is a separate question: the factory's files are the product too, so auditing them improves every project.

---

❓ **Q5 - How do we know it worked, and whose job is that?** Your fear is silent failure. A standard nobody can check is just more prose. [Optimize token use and wall-clock time without losing reliability](https://github.com/Zenoctra/factory918/issues/145) owns the A/B benchmark and the baseline.

➡️ This map decides **what counts as better** for a brief or a file, in terms a test could measure: for example, whether a reviewer finds the bugs it would have found with no brief at all. The #145 map builds the machinery that runs the measurement. So one ticket here produces the criteria, and the #145 map receives them as a dependency.