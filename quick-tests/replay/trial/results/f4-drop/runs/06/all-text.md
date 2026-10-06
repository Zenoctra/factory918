A subagent is still mapping what already exists: the writing skills, every place one agent briefs another, and the old audits in `.scratch/`. The questions that depend on those facts, like where the standard should live and how the templates should be built, wait for its report.

The questions below are about the destination and the scope, which don't depend on those facts. The options I list are a starting point, not the whole space. If your answer is something else, say it.

❓ **Q1** - **Does this map end at a plan or at finished work?** By default a wayfinder map produces decisions. When the way is clear, it hands off to `/to-spec` and `/to-tickets`, and the building happens in tickets afterward. The current Destination reads like finished work: the standard written, the audit done, the templates built. The other option is to write a note on the map that carries the building into the map itself.

➡️ End at a plan, with one exception: draft the standard inside the map as a prototype ticket. You'll judge the wording best by reacting to a real draft, not a description of one. The final standard, the audit fixes and the templates then get built from tickets.

---

❓ **Q2** - **Rewording the Destination.** The current line ends with templates "whose fixed parts never shape the search". That's the framing you corrected. Proposed replacement:

> A spec for a theory-of-mind writing standard covering everything an agent writes for another agent or for a person. The spec covers four things: how the standard gets used every time it applies, not only when someone remembers to invoke it; an audit and rework of the factory's files and briefs against it; brief templates for the subagent jobs that recur; and a rule that these templates give the subagent the goal and leave how to pursue it to the subagent.

This version adds "used every time it applies". In 820 transcripts, the existing writing skill was invoked 8 times, so half of the problem is that the skill doesn't trigger. I also tried not to put a theory of constraints into the Destination. That decision belongs inside the map.

➡️ That wording, or your edit of it.

---

❓ **Q3** - **One standard for both kinds of reader, or two?** Your note covers agents briefing agents and agents writing to you, such as PR text and jargon from context you never saw. The root failure is the same: the writer doesn't picture the reader. The readers differ, though. You have standing context, and you can stop and ask. An agent can't ask, so it guesses and moves on.

➡️ One standard built on reader-modeling, covering both kinds of reader, with a part on what changes when the reader can't ask. `unslop` and `technical-writing` stay as the sentence-level tools under it.

---

❓ **Q4** - **Are vendored files in the audit?** Your note says the problem is entrenched in "everything not vendored". But agents also read Matt's skills and pstack, and an agent can't tell vendored text from ours. `writing-for-agents` is itself vendored. We can change vendored text only through patches, and each patch has to be re-applied whenever we re-vendor with `factory918 sync`.

➡️ Audit everything an agent reads, vendored files included, because the reader sees the result either way. Fix our own files directly. Patch a vendored file only where the finding is worth carrying a patch.

---

❓ **Q5** - **Who proves the standard works?** You can't show that a template is better than the brief it replaces without a test. The map "Optimize token use and wall-clock time without losing reliability" owns the general A/B harness, and its plan is to judge the other maps against a baseline. This map could wait for that harness, or it could define its own test for a brief.

➡️ Don't wait. This map decides what "better" means for a brief and uses a cheap test where one already exists. `tests/eval/reviewer/` is a candidate: plant findings that sit outside what the brief mentions, and check whether the reviewer finds them. The general harness stays with the token map. The templates come back to it for A/B testing once it exists.