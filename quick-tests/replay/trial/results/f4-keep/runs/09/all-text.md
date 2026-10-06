A background search is still collecting what already exists: the `writing-for-agents` skill, every place one agent writes a brief to another, and the run-2 audits in `.scratch/`. While it runs, here is round one. These questions only settle the destination, and none of them depends on what the search finds. The open questions about what the map has to decide come in round two, once the search is back.

---

❓ **Q1** - **Reword the destination's third part**: The destination currently ends with "brief templates for the recurring lane jobs whose fixed parts never shape the search." That's the old framing you corrected today. It needs a replacement that states your test, not a new boundary drawn around different examples.

➡️ "...and brief templates for the recurring lane jobs, where nothing in the fixed part decides how the task is pursued unless it carries knowledge the reader lacks or coordination with other agents, and says so." I'm not certain about this. I wrote that clause from my reply to your note, so it may be my framing more than yours. If it reads as narrower than what you meant, the shorter "...whose fixed parts never constrain how the task is pursued" is the safer version, and the map can sharpen it later.

---

❓ **Q2** - **Does the standard ship to every project, or only to the factory?**: Projects also brief subagents, review PRs and write PR text for a person. The other choice is to treat it as workshop-only, like the measurement work in "Optimize token use and wall-clock time without losing reliability".

➡️ It ships in `template/`, so every project gets it. The failure lives in how agents communicate, not in factory maintenance. The audit-and-rework part is the factory's own job, since it's about files the factory wrote.

---

❓ **Q3** - **Vendored files: in scope, or not?**: In the quote on the ticket you said this is "a deeply entrenched part of everything not vendored." But `writing-for-agents` is vendored from Matt, and you want it to either work or be replaced. Vendored skills (Matt's and pstack's) also contain briefs that their own subagents receive. One possible line: the factory's own files get audited and rewritten, and vendored files are touched only where they write briefs the factory relies on, through patches. You may want a different line.

➡️ The audit covers what the factory wrote. A vendored file comes into scope only when it is the thing that fails: either it writes a brief that factory lanes receive, or it is the writing skill itself. Whether to patch `writing-for-agents` or replace it with a factory-owned skill becomes a ticket on the map, not something we settle here.

---

❓ **Q4** - **Where does this map end?**: By default a wayfinder map ends at decisions and then hands off to `/to-spec`, so the writing itself happens afterwards in tickets. The alternative is to carry execution into the map: write the standard and do the audit as part of it.

➡️ It ends at a spec. The decisions are hard enough that mixing them with the writing would blur both. Separately, the spec should say how success will be judged against the baseline from "Optimize token use and wall-clock time without losing reliability", since that map exists to judge this one.

---

❓ **Q5** - **One standard for two readers?**: The destination covers writing to another agent and writing to you. Earlier you described the difference: you can stop and ask what a word means, and an agent guesses and moves on. Each reader has its own failure: for an agent it's the wrong result, for you it's lost attention.

➡️ One standard with one root: picture what the reader has in their head and where your words will pull them. Each reader gets a short section of its own. Splitting it into two standards would teach that these are two problems, and you've argued they're one.