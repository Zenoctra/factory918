I'm checking the repo for what already exists: the writing skills, every place one agent writes instructions for another, and the audits from run 2. The questions that depend on those facts will come in a later round. These five are about the destination, so they don't need to wait. The options under each are starting points, not the full set.

❓ **Q1** - **Rewording the destination**: The destination currently ends "brief templates for the recurring lane jobs whose fixed parts never shape the search." That is the framing your note corrected. I'd replace it with the test from your note's second sentence: every constraint in a brief is written with the reader's own better strategy in mind, and it states its reason so the reader can tell when the reason doesn't apply. The new line would read: "...and brief templates for the recurring subagent jobs, whose fixed parts constrain the work only where the writer knows something the reader can't, and say why." One alternative is your own wording as the rule itself: "never constrain the design of how the task is pursued or completed." Its weakness is that it also forbids constraints that carry knowledge ("run tests with `vp`") or coordinate parallel work ("only touch these files").

➡️ Use the reworded line, and put your full note into the map's Notes. The note itself should be what future sessions orient to, not my paraphrase of it.

---

❓ **Q2** - **Which readers the standard covers**: The destination says "to another agent or to a person." Your note gives two reasons this is one problem. Writing for a person fails the same way (terms defined in a context the person never saw), and person-facing text like PRs and tickets is read by agents too. On the other hand, `unslop` and `technical-writing` already cover person-facing prose, and keeping both readers in scope makes this map bigger.

➡️ One standard for both readers, because the root failure is the same: the writer doesn't picture the reader. The audit and the templates start on the agent-facing side, where the damage compounds without anyone noticing. Person-facing writing is covered by the standard but gets no audit in this map.

---

❓ **Q3** - **Where this map stops**: Wayfinder plans by default. The map would end once the standard's shape, the audit method and the template design are decided, and then hand off to `/to-spec`. Writing the standard, running the audit and reworking the files would all be execution tickets. The other choice is to note in the map that execution happens inside it. For example, the standard itself could be drafted here, since the audit and templates can't be designed well without something concrete to test against.

➡️ Plan only, with one exception: a rough draft of the standard as a prototype ticket, so the later decisions have something real to react to. The finished standard, the audit and the rework go to `/to-spec`.

---

❓ **Q4** - **Vendored files**: Your original message limited this to "everything not vendored". Vendored skills (Matt's, pstack's) can change only through a patch in `patches/`. Some of the briefs that do the most damage could still sit inside vendored skills, such as spec-review's reviewer briefs or interrogate's. The choices are to audit factory-authored files only, or to also audit vendored ones and fix what's found through patches.

➡️ Audit both, but record vendored findings as patch candidates, each needing your go. Leaving them out would miss part of the reviewer problem that started all of this. I'll confirm which skills are vendored once the repo check comes back.

---

❓ **Q5** - **Who proves the standard helps**: "Optimize token use and wall-clock time without losing reliability" (the map that runs alongside all the others) owns the instruments: the baseline and the A/B test for single sentences. The question is whether this map has to show that the new briefs get better results before the rework counts as done, for example a reviewer brief that finds more seeded bugs than the old one. The alternative is to treat the standard as clearly right and rework without measuring.

➡️ This map defines what "better" means for each template (what you'd measure and on which job) and borrows the instruments from the optimization map rather than building its own. Rework of the recurring templates waits until each has a before/after result. Without that, we'd be trusting the standard on how it reads, which is exactly what your note warns against.