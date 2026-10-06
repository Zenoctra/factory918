The map exists but has never been charted. It has a Destination, and its fog section still says "To be charted in the first wayfinder session." So this session charts it: first we settle the destination, then we lay out the open questions as tickets. Nothing gets resolved today. A subagent is checking what already exists: the writing skills, every place one agent briefs another, and the old audits in `.scratch/`. The questions that depend on those facts will wait for its report.

All of these are destination questions, and none of them depends on the subagent's report. The options I list are only examples, not the full set, so answer outside them whenever that fits.

❓ **Q1** - **Fix the Destination wording**: The Destination still ends with "brief templates for the recurring lane jobs whose fixed parts never shape the search". That's the framing your note on Write to agents with theory of mind replaced, and it's the line every session reads first.

➡️ Rewrite it as: "...and brief templates for the recurring lane jobs, whose fixed parts carry what the reader can't know on its own and leave the design of how the task is pursued to the reader." This keeps the template idea and swaps the old test for yours: did the writer picture the reader's own strategy and leave room for it?

---

❓ **Q2** - **What "done" means for this map**: Wayfinder plans by default, and the map ends when nothing is left to decide. But this Destination includes "an audit and rework of the existing files", which is execution. There are two ways to read it:
- **Plan only.** The map ends with the standard designed, the audit method decided and the template design settled, then hands off to `/to-spec` and tickets. The rework runs afterwards as normal execution work.
- **Plan and do.** The map carries the audit and rework itself, as Notes can allow.

➡️ Plan only. The rework will touch dozens of files across the product, which is ticket-and-PR work. It's also exactly the work this map's own standard should govern, so it should start after the standard exists, not during the same effort.

---

❓ **Q3** - **Who the reader is**: Your message covers two readers: agents (briefs, handoffs, factory files) and you (chat replies, PR text that's full of terms defined in a context you never saw). Today the person side sits with `unslop` and `technical-writing`, and the agent side with `writing-for-agents`. Should this map own both readers, or only the agent one?

➡️ Both, under one standard. The root failure is the same: the writer doesn't model what the reader has seen. The differences are real but small. A person can ask a follow-up question and an agent guesses. The existing person-side skills would stay as style guides underneath the standard.

---

❓ **Q4** - **Product or workshop**: Does the standard ship in `template/`, so every project's agents follow it when they brief subagents and write PRs, or does it stay a factory-only (workshop) tool?

➡️ Product. Every project's orchestrator briefs lanes and writes PRs, so the failure travels with the factory. The audit of the factory's own files is the only workshop-side part.

---

❓ **Q5** - **Reopen the approved taxonomy?** Your earlier message approved my sorting into "missing context / shaping the answer / plain unclear writing." Your correction showed my constraint test was a list mistaken for a principle. That taxonomy could have the same flaw: three bins drawn around your examples. Should the standard start from that taxonomy, or should its structure be an open question for the map?

➡️ Reopen it, as one of the map's first tickets. The standard's structure decides everything after it: the audit checklist, the templates, the triggers. If the structure is a closed list, every later step inherits the leading-the-witness problem. "Picture the reader" is the root, and how examples get presented without becoming the boundary is itself a design question.

---

❓ **Q6** - **Proof the standard works**: You said these failures are silent. Without measurement, a rewritten brief is just a claim that it's better. The map "Optimize token use and wall-clock time without losing reliability" is where the A/B benchmark for single-sentence changes is planned. Does this map decide how its own changes are proven, or does it depend on that map's harness?

➡️ This map decides what counts as evidence for its changes, for example a reviewer brief that finds more of the planted bugs. The other map owns the benchmark machinery. A fog note here would mark the dependency, so neither map blocks on the other's timeline.