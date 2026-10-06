Your correction changes the map's Destination line, so the first round settles what this map is finding its way to. A background search is cataloguing what already exists: the writing skills, every place one agent writes a brief to another, and the old audits in `.scratch/`. The questions about where the standard should live, and which vendored briefs count, wait for that search. The rest are below. Where I give options, they're examples. Answer outside them whenever your real answer is somewhere else.

❓ **Q1** - **The Destination's wording**: Right now it ends with "brief templates for the recurring lane jobs whose fixed parts never shape the search." That's the framing you corrected. A replacement needs to carry your principle and also the test from your next sentence: whether a constraint was written with the reader's own better strategy in mind.

➡️ "...and brief templates for the recurring lane jobs, whose fixed parts give the reader what it can't know (facts, reasons, the limits that protect other people's work) and leave the design of how the task is pursued to the reader." If you want your own sentence in it word for word, I'll use that instead.

---

❓ **Q2** - **Who the readers are**: Your message covers three kinds of reader. Subagents read briefs. Agents in a future project read factory files (skills, playbooks, `AGENTS.md`). And you read PRs, replies and reports, which is where the jargon-from-an-unseen-context problem hits. `unslop` and `technical-writing` already cover some of the writing for people. Is all of that one standard in this map, or do the people-facing pieces stay with those skills?

➡️ One standard, covering all three, because the root failure is the same: the writer doesn't picture what the reader has in their head. The existing skills stay as style passes underneath it, not as a second standard.

---

❓ **Q3** - **Is "it actually gets used" part of the destination?** The evidence says `writing-for-agents` was invoked 8 times in 820 transcripts. A better standard that never loads changes nothing. One way to see it: the destination includes some mechanism that puts the standard in front of the writer at the moment of writing. That could be the templates themselves, a hook on the Agent tool, a line in the delegation path, or something we haven't thought of yet.

➡️ Yes. The destination says the standard reaches the writer when they write, and how it gets there is a ticket on the map, not decided now.

---

❓ **Q4** - **Where the map stops**: By default wayfinder plans and doesn't do. The current Destination includes "an audit and rework" of existing files, and that's execution. One option is that the map ends when the standard is decided and the audit, the rework and the templates are specified for `/to-spec` and tickets. Another is that your Notes carry the work into the map itself.

➡️ Stop at the spec. The one exception is a small sample audit, maybe five or six real briefs from recent transcripts held against the draft standard, run as a task ticket because the decisions need to see real failures, not imagined ones.

---

❓ **Q5** - **How we'll know it worked**: Your fear is silent failure, and "Optimize token use and wall-clock time without losing reliability" owns the A/B machinery. So who decides what "better" means for a brief? I can see a split where this map says what a good result is for each template, and the other map builds the harness that measures it. `tests/eval/reviewer/refusals.sh` already exists as one example of a frozen check on a lane's behavior.

➡️ This map defines a success check for each template (what a better reviewer, explorer or implementer output looks like). The benchmark harness stays with the optimization map, and the two link to each other.