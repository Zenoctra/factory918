The fact-finding agent is still running. It's checking what already exists: the writing skills, current brief text, and the old audits in `.scratch/`. The questions that depend on those facts, such as where the standard should live, will come in the next round. These ones don't depend on them.

❓ **Q1** - **Rewrite the destination line**: The map's Destination still says the templates' "fixed parts never shape the search", which is the framing you corrected. Since this line steers every session on the map, it should carry your test rather than the old one.

➡️ "A theory-of-mind writing standard for everything an agent writes to another agent or to a person; an audit and rework of the factory's existing files and briefs against it; and brief templates for the recurring lane jobs, designed so that nothing fixed in them decides how the agent pursues the goal."

---

❓ **Q2** - **Does the map end at a plan or at reworked files?** By default, wayfinder plans and doesn't do the work. The destination as written includes doing the work ("an audit and rework"). One option is for the map to end once the standard's content, the audit method and the template design are settled, with the rework handed to `/to-spec` and `/to-tickets`. The other is to carry the audit and rework inside the map.

➡️ End at the plan. There's one exception: let a research ticket sample real briefs and files early, because what the audit finds should shape what the standard says, not just be measured against it afterwards.

---

❓ **Q3** - **One standard for both readers, or two?** The destination covers writing to agents and writing to people. You described them as two cases of the same failure: the writer doesn't picture what the reader has in their head. They also differ, because a person can stop and ask and an agent guesses and moves on. `unslop` and `technical-writing` already exist for writing aimed at people.

➡️ One standard. The core is reader modeling, which applies to both. Where agents differ (they can't ask, they're more open to suggestion), the standard says so. The existing skills for people stay, but sit under it rather than beside it.

---

❓ **Q4** - **Does the standard ship to every project?** Projects' agents brief subagents too, so the same failure happens there. Shipping the standard puts it in `template/`. Keeping it factory-only means just this repo.

➡️ Ship it in `template/`. The brief templates ship too, because projects run the same lane jobs (review, spec-review and the rest).

---

❓ **Q5** - **How do we know the standard worked, and whose job is proving it?** Without some measurement, "the briefs are better now" is a claim with no proof behind it. #145, "Optimize token use and wall-clock time without losing reliability", owns the benchmarking machinery.

➡️ This map decides what counts as evidence for this standard: what a better result from a lane looks like. #145 builds the general benchmark. A small before-and-after on a few briefs we already have stays in this map's scope, so it doesn't wait on #145.