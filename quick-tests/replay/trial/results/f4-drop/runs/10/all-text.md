I've started a read-only search of what already exists: the writing skills, every place one agent briefs another, and the old audits in `.scratch/`. That will take a few minutes. Meanwhile, here's the first round. These questions are about where the map ends, and none of them depend on what the search turns up.

❓ **Q1** - **The destination wording**: The current destination ends with "brief templates for the recurring lane jobs whose fixed parts never shape the search". Your correction retires that framing, so the destination should change before anything is charted against it. Proposed rewrite:

> A theory-of-mind writing standard for everything an agent writes to another agent or to a person; an audit and rework of the factory's existing files and briefs against it; and brief templates for the recurring subagent jobs, designed so their fixed parts never constrain how the task is pursued or completed beyond what the writer can justify to the reader.

➡️ Use that wording, or your own. The phrase "can justify to the reader" carries the test from your note: whether the writer pictured what the reader might do better.

---

❓ **Q2** - **Plan or do**: Wayfinder maps normally end in decisions, then hand off to `/to-spec`. This destination includes an audit and a rework, which is execution. One option is for the map to end once the standard is decided and the audit's method is clear, with the audit and rework becoming tickets that `/poteto-mode` runs. The other is for this map to carry the audit itself.

➡️ End at decisions. The standard, the audit method, and the template design get settled here. The rework is a pile of PRs, and it should go through execution, where review happens.

---

❓ **Q3** - **People and agents in one standard**: Your message covers both readers: agents, which take a best guess and move on, and you, who pay with mental bandwidth decoding jargon. These could be one standard or two (an agent-facing one, plus `unslop`/`technical-writing` for people).

➡️ One standard, because the cause is the same: the writer doesn't picture the reader. The parts that differ go inside it as differences between readers, not as separate documents. Whether `unslop` and `technical-writing` fold into it or sit under it is a later question.

---

❓ **Q4** - **Vendored text**: Some of the worst briefs may live in vendored skills, like the review briefs in pstack or Matt's skills. Those can only change through a patch in `patches/`, which `factory918 sync` has to re-apply forever. Should the audit cover vendored text, or only text the factory wrote?

➡️ Cover it. The reviewers that read those briefs are the ones you said hurt most. Each finding in vendored text is fixed with a patch, so the patch count is visible as a cost and you can decide case by case.

---

❓ **Q5** - **Product or workshop**: Agents in every project brief subagents too, so the standard looks like product (`template/`) and not a workshop-only tool. The audit of the factory's own files is the workshop side.

➡️ The standard and the templates ship in `template/`. The audit is work on the factory.

---

❓ **Q6** - **How we know it worked**: "Better writing" fails silently, which is what you're afraid of. The map on token use and wall-clock time already plans a baseline and an A/B benchmark for single-sentence changes. This map could build its own proof or rely on that one.

➡️ Rely on it, and make that dependency explicit. This map defines what "better" means for a brief (findings a reviewer surfaces, terms a reader had to guess, how well a lane's output matches the goal it was given). The other map supplies the means to measure it. If its benchmark isn't ready when the rework starts, the rework waits for it rather than shipping unmeasured.