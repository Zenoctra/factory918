Your note is on the ticket. Before I write anything onto the map, here is the first round of questions. A helper is still reading the repo to see what writing guidance and brief text already exist. The questions that depend on what it finds will come next round. The questions below don't depend on it.

❓ **Q1 - Fix the Destination line**: The map's Destination still says the brief templates' "fixed parts never shape the search". That is the framing you just corrected. The quoted conversation should stay as it was said, but the Destination describes where the map is headed now, so it should be reworded. Possible wording: *"...and brief templates for the recurring lane jobs, whose fixed parts carry what the reader can't know (the goal, where results go, what must not be touched, and why) and leave the way the task is pursued to the agent."*

➡️ Edit the Destination in place with that wording, or with your rewording of it, and leave the quoted sections untouched.

---

❓ **Q2 - Does the standard cover writing for people too?** The Destination says "to another agent or to a person". Writing for people already has `unslop` and `technical-writing`. Your message does name a failure aimed at people: PRs full of terms that were defined in a context window the reader never saw. There are three options:
- (a) One standard for every reader, whether agent or person. The only variable is what that reader has in their head.
- (b) This map covers agent-to-agent writing only, and writing for people stays with the existing skills.
- (c) One standard, but the people side only adds the missing-context rule to the existing skills.

➡️ (a). The root failure is the same: the writer never pictures the reader. Splitting it into two standards would teach two habits for one mistake.

---

❓ **Q3 - Where does it live: in every project, or only in the factory?** Projects brief subagents just as much as the factory does. Every reviewer, `spec-review` and poteto playbook ships to them under `template/`. The audit of the factory's own files, though, is work on the workshop.

➡️ The standard and the brief templates ship in `template/`, so every project gets them. The audit and rework of existing files is factory work.

---

❓ **Q4 - Where does this map stop?** Wayfinder plans by default: it ends when nothing is left to decide, and the work after that becomes tickets through `/to-spec`. The Destination, though, includes "an audit and rework", which is doing.
- (a) The map ends at a spec. The standard, the audit and the templates become execution tickets afterwards.
- (b) The map carries the work itself.
- (c) The map ends at a spec, but includes one small sample audit, a few real briefs held against the draft standard. That tests whether the standard catches anything before we commit to it.

➡️ (c). A standard that has never been held against a real brief is a guess, and a small sample is cheap. The full sweep comes after the map.

---

❓ **Q5 - How do we tell that a rewritten brief is better?** Without a way to measure, "better" means "reads better to me", and nobody notices a silent failure. Your token map (#145) already plans A/B tests and frozen benchmarks.
- (a) This map decides what "better" means for a brief, for example findings recovered on a review task with a known answer. #145 builds the harness that measures it.
- (b) This map builds its own measurement.
- (c) No measurement; judge by reading.

➡️ (a). The question of what better means belongs here, and the tooling belongs to #145. #145 then has its first real customer.

---

❓ **Q6 - Where the standard comes from**: Your correction showed the risk: if the standard is built from the examples we already have (reviewers, smell lists, caps), it will be shaped like those examples. There are two sources. One is the outside literature on how wording changes answers, such as survey design, leading questions and anchoring. The other is the factory's own transcripts, where briefs went wrong. Both would be research tickets, and their own questions would have to be written openly. Briefing the research with our list would repeat the mistake.

➡️ Both, as two research tickets. The literature ticket's question is "what is known about how a request's wording changes the answer", with no list of topics. The transcript ticket asks it to find where briefs pulled lanes off course, with no list of failure kinds.