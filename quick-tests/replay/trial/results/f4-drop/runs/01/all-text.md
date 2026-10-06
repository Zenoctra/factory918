The map for "Write to agents with theory of mind" is already open but has no tickets yet, so this session starts by charting it: we settle where it ends, then create the first tickets. A background agent is collecting the facts the second round depends on: what the writing skills say and whether they're vendored, where briefs get written, and the audits from run 2. This round covers what I can ask without those facts.

All of these recommendations are mine. Overrule them freely, and treat any list here as examples rather than the full set of choices.

❓ **Q1** - **Rewrite the Destination line**: The Destination line ends with "brief templates for the recurring lane jobs whose fixed parts never shape the search." That's the framing your note replaced, and every session reads the Destination before it picks a ticket. If we leave it, every session starts from the narrow version.

➡️ Rewrite it to: "...and brief templates for the recurring lane jobs, whose fixed parts never constrain how the task is pursued or completed." Your test, that a constraint must be written with the agent's own better strategy in mind, then becomes the core of the standard itself. It's a principle the map has to work out, so it doesn't belong in the one-line Destination.

---

❓ **Q2** - **Who counts as the reader**: Your paragraph covers two kinds of reader. One is agents reading briefs and factory files. The other is you reading PR text and replies full of terms defined in a context you never saw. `unslop` and `technical-writing` already cover writing for people, though only for style.

➡️ One standard for any reader who doesn't have the writer's context, whether agent or person. The root failure is the same for both. The difference is that a person can stop and ask while an agent guesses and keeps going, so for agents the stakes are higher, not the rule different. `unslop` and `technical-writing` stay as the style layer underneath.

---

❓ **Q3** - **Product or workshop**: Some of this work could ship to every project, and some could exist only in this repo. The standard, the reworked files and the templates could all go under `template/`, or some could stay factory-only.

➡️ Product. Project agents brief subagents just as often as the factory's agents do, and the recurring lanes (spec-review, the poteto playbooks, interrogate) already ship in `template/`. The only workshop part is the evidence about whether a change helped, which belongs to the "Optimize token use and wall-clock time without losing reliability" map.

---

❓ **Q4** - **Where this map stops**: Wayfinder only plans by default. The current Destination includes doing things: "an audit and rework of the existing files". A standard is a strange case, because its text is the decision.

➡️ The map ends when three things are settled:
- The standard is drafted and approved by you. Drafting it is how its decisions get made, so this part happens inside the map.
- How the audit will judge existing files is decided and tried on a sample.
- How the templates are designed is decided, with one template prototyped.

The full audit sweep, the rework of each file and the remaining templates then go through `/to-spec` and `/to-tickets` as normal execution work.

---

❓ **Q5** - **How we'll know it helped**: This map changes the most-read prose in the factory. Without a "before" number, any rework is a claim and not proof, and the "Optimize token use and wall-clock time without losing reliability" map was ordered to run alongside the others and take a baseline now.

➡️ Take a baseline before anything is reworked, using whatever measurement already exists. The reviewer eval under `tests/eval/` and the 799-transcript studies are what I know of. Then require every reworked template to show results at least that good. Building a proper A/B harness belongs to the token-optimization map. If it doesn't exist yet when we need it, this map files a task ticket for the minimum version.

---

❓ **Q6** - **Ground it in the research literature**: Your paragraph points at decades of human research on how wording changes answers. Survey methodology is one field, and the research on how easily LLMs are steered is another. So far the factory has drawn on your examples and our own audits.

➡️ Yes, one research ticket with an open question: "what has been learned, in any field, about how the way a question or task is written changes the answer, and what has been measured on language models?" It shouldn't be seeded with your three examples or mine. That way the standard rests on more than the failures we happen to have hit.