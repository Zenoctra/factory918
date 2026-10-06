I'm still charting this map, so the first step is to settle the destination. Every later question depends on it. A background search is cataloguing what already exists: the writing skills, every place one agent briefs another, and the old audits in `.scratch/`. Questions that need those facts wait for its report. These four don't.

The options I give under each question are a starting point, not the full set. If none of them fits, say what does.

---

❓ **Q1 - Reword the destination line**: The map's one-line destination still promises brief templates "whose fixed parts never shape the search". That's the framing you retracted today, and it sits in the sentence every future session reads first. If it stays, each session will steer toward a principle about search.

➡️ Rewrite it, carrying your test instead: templates whose fixed parts carry only what the writer knows that the reader can't, each with its reason, and leave the agent free to design how it pursues the goal. I'd also add a line under Notes pointing to your 2026-09-30 comment. Old sessions then read the quoted response with the correction beside it.

---

❓ **Q2 - Where the map ends**: Wayfinder plans by default and ends when nothing is left to decide. The destination as written includes "an audit and **rework**" of the existing files. The rework is execution, and it could be dozens of PRs. Three ways to draw the line:
- The map ends at a spec covering the standard, the template design and an audit plan, and the rework runs as tickets after `/to-spec`.
- The audit itself happens inside the map, because what it finds should shape the standard. Only the rework comes after.
- The map carries the rework through to the end.

➡️ The second. The old audits from run 2 suggest the real failures are a better teacher than theory, so I'd let the audit run as research inside the map and inform the standard. Fixing the files comes after the spec.

---

❓ **Q3 - What the audit covers**: Your message said the problem is "a deeply entrenched part of everything not vendored." Vendored skills (Matt's and pstack's) can only change through patches, so every edit to them adds a patch to maintain on each sync.

➡️ Audit and rework everything the factory itself wrote: the template, the playbooks, the briefs, the hooks' messages and both `AGENTS.md` files. For vendored skills, the audit records where they break the standard. A patch happens only where the harm is large, and each one is its own decision. I'd treat the brief a subagent receives as the main target, since that's where the 700+ subagents get their instructions.

---

❓ **Q4 - How we'll know the standard worked**: A writing standard can fail silently, which is the outcome you fear most. Map #145 owns the general measurement tools, such as the baseline and A/B testing of single sentences. But this map comes first, so those tools won't exist yet. Two options:
- This map proves its own result on a small scale. For example, run an old reviewer brief and a rewritten one against the same planted bugs and compare what each finds. The repo already has a reviewer eval in `tests/eval/reviewer/`.
- This map ships the standard unmeasured and leaves the measuring to #145.

➡️ The first, kept small. One before-and-after on the job that hurts most, the reviewer, is enough to show the standard changes behavior rather than just wording. Everything broader goes to #145.