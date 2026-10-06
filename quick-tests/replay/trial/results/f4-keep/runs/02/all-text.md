The map already exists, so this session charts it. Step one is settling the destination, since it fixes the scope. A background search is still listing what already exists: the writing skills, every place where one agent briefs another, and the old audits in `.scratch/`. Questions that depend on what it finds will come in the next round. These four don't depend on it.

❓ **Q1** - **Rewording the destination after your correction**: The destination still ends with "brief templates for the recurring lane jobs whose fixed parts never shape the search." That's the narrow framing you replaced on Tuesday. Your test was whether a constraint was written with the agent's own, possibly better, strategy in mind. Constraints that pass on knowledge the agent lacks, or that keep parallel agents out of each other's way, still pass that test.

➡️ "...brief templates for the recurring jobs agents hand to each other, whose fixed parts give the reader what it can't know on its own and never fix how it goes about the goal."

---

❓ **Q2** - **Where this map ends**: As written, the destination includes doing the work: "an audit and rework of the existing files." Wayfinder maps normally end once nothing is left to decide, and then hand off to `/to-spec`. Two kinds of ending are possible here. One is planning only, ending in one or more specs. The other carries the rework into the map itself, which you'd have to state in the Notes.

➡️ Planning only. The map ends when three things are decided: what the standard says, how the audit finds and judges existing text, and how a template is built. Each of those becomes a spec. The rework itself runs as tickets afterwards, where review and CI can check it.

---

❓ **Q3** - **Who the standard is for**: Your note covers two readers: an agent reading a brief or a file, and a person reading a PR or a reply that is full of terms defined somewhere they never saw. Both come from the same failure, a writer who doesn't picture the reader. One option is a single standard for both readers. The other is two standards, one per reader.

➡️ One standard, built on that shared root, with a part for each reader where they really differ. A person can stop and ask what a word means. An agent guesses and keeps going. The sentence-level skills for human prose, `unslop` and `technical-writing`, would sit underneath the standard, not compete with it.

---

❓ **Q4** - **Factory only, or every project**: Agents in your projects brief subagents just as often as agents in the factory do, but the factory is where the 700+ lanes ran. The standard and the templates could be shipped in `template/` to every project, or kept in the workshop.

➡️ Ship it in `template/`. Every project's orchestrator writes briefs, so this is part of the product. Measuring whether a sentence change helps (the A/B side) belongs to the token-optimization map and stays in the workshop.

---

One question for after the search reports: what happens to `writing-for-agents`. It's vendored from Matt, so the options are to patch it, replace it, or put a factory-owned skill beside it. That decision depends on what's in it and how it's wired up.