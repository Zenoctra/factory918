I'm charting the map, which starts by settling what it ends at. A background agent is collecting the facts later rounds will need: where the writing skill comes from, which briefs already exist, and the old audits in `.scratch/`. The questions below don't depend on any of that.

---

❓ **Q1** - **Rewording the Destination**: The current Destination ends with "brief templates for the recurring lane jobs whose fixed parts never shape the search." Your note on 2026-09-30 retires that framing. Every session reads the Destination before choosing a ticket, so the old wording would keep pulling each one back toward the reviewer-search idea. Your note also sets a test the new wording has to meet: a constraint is harmful when it was written without the agent's own better strategy in mind, and a constraint that carries knowledge the reader lacks is fine.

➡️ Replace the last clause with: "...and brief templates for the recurring lane jobs, whose fixed parts give the reader what it can't know and leave how the task is done to the reader." Your correction would be quoted in Notes under the original quotes, so the reasoning travels with the map.

---

❓ **Q2** - **Who counts as the reader**: Your message covers two readers. One is agents reading briefs and factory files. The other is a person reading a PR, or you reading a reply full of terms defined in a context you never saw. These could be one standard, or two standards that share a root.

➡️ One standard, with the reader's state as the variable: what they already have in their head, and what they can do about a gap. A person can ask, but an agent guesses and moves on. The second branch is the important one, because it's why agent readers need more care, not a different rule. `unslop` and `technical-writing` would stay as the sentence-level tools under it.

---

❓ **Q3** - **Where this map ends**: As written, the Destination includes *doing* the audit and the rework. Wayfinder's default is to plan, not do: the map ends when nothing is left to decide, then hands off to `/to-spec` and tickets. One alternative is to carry the audit and rework inside the map. Another is to end at a spec that defines the standard, the audit method and the templates, with the rework running afterward as normal tickets.

➡️ End at a spec. The rework touches dozens of files and should run as normal tickets with review. One exception: a small sample audit of maybe three real briefs, run as a task ticket inside the map. The standard should be shaped by what the real failures look like, not by the failures already named in your message, which is the list trap you described.

---

❓ **Q4** - **Vendored text**: Many of the briefs agents send are written by vendored skills, from Matt and pstack, and those can only be changed through patches. One option is to keep the standard and the audit to factory-authored files. Another is to include vendored skills through patches. A third is to replace whichever vendored skills fail the standard.

➡️ The standard applies to everything agents in the factory send, because the reader can't tell who wrote the brief. For vendored files, the audit records each failure, and whether to patch it or replace it is decided case by case in its own ticket. I'll confirm the vendored list once the background agent reports.

---

❓ **Q5** - **How we'll know it worked**: A standard nobody can check fails silently, which is your worry from the night of 2026-09-25. Measuring belongs to the "Optimize token use and wall-clock time without losing reliability" map, which runs alongside this one. One option is for this map to decide how a brief gets judged, for example a stranger-reader test or an A/B run on one template. The other is to leave all measurement to that map.

➡️ This map decides what "a brief passes" means and names one check that can be repeated. The benchmark machinery stays on the optimize map. Without a check of its own, this map's destination is a document whose effect nobody can see.