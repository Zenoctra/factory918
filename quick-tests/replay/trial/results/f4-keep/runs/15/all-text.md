The search for what already exists is still running. These five questions don't depend on what it finds, so I'll ask them now. Questions about where the standard lives, what happens to `writing-for-agents`, and which jobs get templates will come in the next round.

Each question includes my recommended answer, because the grilling format asks for one. Treat it as one possible answer, not the edge of what's allowed.

---

❓ **Q1 - The destination's wording**: The map's Destination line still uses the framing you corrected today. It ends with "brief templates for the recurring lane jobs whose fixed parts never shape the search." A "brief" is the message one agent writes to start another, and a "lane" is a subagent doing one job. The Destination fixes the map's scope, so it should match your correction before anything is ticketed against it.

➡️ Replace the ending with: "...and templates for the briefs agents send each other most often. A template's fixed part gives the receiving agent what it can't see for itself, such as facts, reasons, and what other agents are working on, and leaves the method to the agent." That covers the two kinds of good constraint I raised earlier, without bringing back a list of approved constraint types.

---

❓ **Q2 - Planning or doing**: Wayfinder plans by default. The map is done once nothing is left to decide, and writing, auditing and reworking files happen afterwards as normal tickets. The other option is to carry the audit itself inside the map.

➡️ Plan only. The map settles what the standard says and how the audit and templates will work. Writing the standard, auditing the files and building the templates then go to `/to-spec` and become execution tickets. The decisions are the hard part. The rest is work an agent can run once those decisions exist.

---

❓ **Q3 - Vendored text**: You said the problem runs through "everything not vendored." But agents also read the vendored skills, Matt's and pstack's, and some of the briefs that run most often may come from them. The search will tell me which ones. Vendored text can only change through a patch in `patches/`.

➡️ The audit reads vendored text as well, because it judges what agents actually see, not who wrote it. Each fix to vendored text is still a patch, and it's worth making only when the brief runs often. Everything else in vendored text gets flagged, not rewritten.

---

❓ **Q4 - A "before" measurement**: If we rewrite the briefs and nothing measured how they did beforehand, we can't tell whether the standard helped or quietly hurt. That's the silent failure you're worried about. The approved order said the baseline from the token map (#145) should judge each of the others.

➡️ This map gets a ticket to freeze a baseline before any rework. It would be a set of real past briefs with their outcomes, for example what a reviewer found and what it missed, replayable after the rewrite. It's built together with the token map so it's only built once. The rework waits for it. Writing the standard doesn't.

---

❓ **Q5 - Agents and people as readers**: The destination covers both readers: an agent reading a brief, and you reading a PR or a report. Both fail at the same root, which is a writer who never pictures the reader. But the reader is different: a person can stop and ask, and an agent guesses and keeps going.

➡️ One standard with two reader cases, not two standards. The shared part is picturing the reader: what's in their head and where your words will pull them. The person-facing case can lean on the existing `unslop` and `technical-writing` skills for sentence-level clarity, so the new work is mostly the agent-facing case.