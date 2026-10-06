Your answers are clear on Q2, Q3 and Q5. Q1 and Q4 need more from me, and one thing I said in Q3 needs correcting. I tried to post your answers word for word on the ticket, the way the map keeps your words, but the post was declined. They're saved locally in the meantime. Do you want them on the ticket?

**What I took from your answers:**

- **Q2.** I've pinned your micro-genre point. One dense term that already carries most of what you want, plus only what that term wouldn't imply, could replace a pile of separate rules. It fits the research: the best model followed 68% of 500 instructions at once. The risk runs the other way too: a dense term also brings in its genre's defaults, which is why you add the off-genre detail. It's testable, so I'll record it under "Decide what the writing standard is and what carries it" and as an experiment for "Decide how we'll know the writing works".
- **Q3, a correction.** The evidence does **not** say that a reviewer focused on one kind of bug also finds the others. It says two separate things:
  - Removing a reporting bar brings back what the reviewer found but didn't report.
  - Focus decides what gets seen in the first place. That's the gorilla study, and the 2026 preprint where a narrow task hid findings that a second, open-ended pass then recovered.

  So (a) fixes the reporting half, and your worry about the reviewer reading right past a bug type is real. Q7 below is about that half.
- **Q5.** Recorded by mode:
  - In `safe`, no budget ever shapes the process. It is only measured afterwards.
  - In `eco` and Let It Rip (where wall clock counts as a second budget), a budget reaches a brief only after you've set it and been asked how much it should bind.
  - When in doubt, leave it out. If there's no chance to ask, it's information, not a rule. Anything stated as binding has your approval.
  - A prediction, like "this should halve token burn", never becomes a done criterion.

  This also bears on "Design Let It Rip as the third mode" and on the token map, so I'll leave pointers on both.

**Q1, in practice.** My Q1 had a flaw. Option (c) as I wrote it, "both", would have made the delegation rule non-binding because it's about method. Yet one bullet earlier I had argued that it binds because you own it. Here is what (c) has to mean to work:

> A rule binds only when someone with the authority to decide it actually decided it. Everything else a writer puts in a brief is advice.

Picture a kitchen renovation. You're the homeowner, the orchestrator is the general contractor, and a subagent is the electrician.

- You say: blue cabinets, done by Friday, don't touch the load-bearing wall. **These bind.** They're your decisions.
- The contractor says: "Stay out of the bathroom Tuesday, the plumber's in there." **This binds.** The contractor really does own the schedule.
- The contractor says: "Run the wire through the attic." **This is advice.** It's the contractor's guess about the electrician's job. If the electrician finds a better path, they take it and say so.
- The contractor says: "Only check the kitchen outlets." **This is advice dressed as a rule.** If the electrician sees a scorched outlet in the hallway, they report it.

Your Q5 answer is this same rule applied to budgets. The "what it's about" half still matters in one place: it tells the orchestrator what it can own. It owns coordination: who works where, and where results go. It doesn't own how a subagent does its job.

---

❓ **Q6 - What happens when a rule gets in the way?** These are the five instructions the factory gives today:

1. **"Say so loudly and get a sign-off before breaking it."** This is in [AGENTS.md:26](AGENTS.md:26) and [template/AGENTS.md:20](template/AGENTS.md:20), copied from Theo. It works when you're in the session. A subagent has nobody to ask, and the rule pulls against "never block on the human".
2. **"Follow the file and tell me why your instinct differed."** This is in [template/AGENTS.md:16](template/AGENTS.md:16), in your own note: obey first, explain afterwards. It's the opposite default to #1, and nothing tells an agent which of the two applies.
3. **"Where the spec is silent, decide and record a Provisional decision Manuel can overrule."** This covers gaps, not conflicts.
4. **`skip: <reason>`.** This is upstream poteto-mode: a skipped step stays in the list with a one-line reason, and skipping silently isn't allowed. [feature.md:12](template/.agents/skills/poteto-mode/playbooks/feature.md:12) turns it off for delegation.
5. **Send it back up.** A writer that can't build a scenario-table cell as written stops and reports that cell. Writer flags must end `fixed:` or `accepted: <reason>` before review runs. A gap in the design amends the ticket with a dated line.

My proposal:

- **Advice:** the reader uses its judgment. Its report always has a line saying where it took a different route and why, or "none". This is #4 extended to everything.
- **A binding rule that fights the goal:** the reader stops that part and goes to the rule's owner. If the owner is in the session, that is #1's sign-off. If not, the report carries the conflict and the rest of the work continues. This is #5.
- **The goal is never shrunk to fit a rule.**
- **#3 stays as it is,** since it's about gaps, not conflicts.

That leaves #2, which is yours. Under Q1, your own words bind, so I can't drop it. Its point is that a pattern copied from professionals beats an untested instinct, and that survives as advice with its reason: "the patterns in this file were copied from professionals; depart only with a reason, and say what it is."

➡️ The proposal above, with #2 reworded as advice. Or do you want #2 to keep binding: obey first, explain afterwards?

---

❓ **Q7 - How does a brief say "we're especially wary of this kind of bug" without narrowing the review?** This is the part (a) doesn't cover. The options:

- (a) **Say nothing.** A later verifier sorts findings by type. This fixes reporting only, not where the reviewer looks.
- (b) **Add a light line in the open brief, as information after the goal.** Naming something raises how often people find it: "invention of the computer" went from 1–2% to 30% once it was listed. But naming part of a list also suppresses recall of the rest, at a medium effect size, and pulls answers toward what was named. That's the headache you saw coming.
- (c) **Keep the open reviewer's brief clean, and give each kind you're wary of its own pass whose whole job is that kind.** A narrow brief hurts nothing when narrow *is* the job, and the open reviewer keeps its whole field. The preprint's recovery pass had the same structure the other way round.

➡️ (c). In `safe` it costs more subagents, which by your Q5 doesn't steer the process. Deciding which passes, and how many, belongs to Q9.

---

❓ **Q8 - Do these real rules sort the way you'd expect?**

| Rule today | Where | Sorted as | Why |
|---|---|---|---|
| Never push to main | AGENTS.md, guard hook | Binds | Merging is yours |
| The orchestrator never writes the code | [AGENTS.md:26](AGENTS.md:26), delegation hook | Binds | You set it, with evidence |
| Subagents never launch their own dev servers | [template/AGENTS.md:68](template/AGENTS.md:68) | Binds only if it's yours | Copied from Theo, and his reason was lost on the way |
| Never read more than 150 lines in one call | [knowledge/SKILL.md:20](template/.agents/skills/knowledge/SKILL.md:20) | Advice | A guess about reading, with no recorded reason |
| "Execute only the task and path scope the parent assigns" | upstream pstack wrapper | The task binds; "path scope" is advice | Upstream text, so changing it needs a patch |
| A `spec:` citation, or the item is sent back | [review-brief.sh:494](template/.agents/skills/spec-review/scripts/review-brief.sh:494) | Goes, by Q3 | It's a bar on finishing; a later step can say what a finding rests on |
| "Halve token burn" as a done criterion | your example | Never binds unless you approve it | It's a prediction |

➡️ The rows as shown. The one I'm unsure of is the dev-server row. Is that rule yours, and do you remember the reason behind it?

---

❓ **Q9 - Where does a review system of the factory's own live?** You want one: several passes, better briefs, and success measured by bugs caught, not just by having no false positives. The options:

- (a) Unresolved fog on this map.
- (b) A ticket under this map.
- (c) A wayfinder map of its own.

➡️ (c). It's bigger than writing: how many passes, who verifies, and how recall is measured against planted bugs. This map's destination is the writing. This map keeps the wording of the review briefs (the template prototype and the rework tickets) and points to the new map. Existing work would feed it: the reviewer evaluation from the run-2 audits, "Choose each tier's review round count from the clean measurement", and "Eval the judge and trail-review models the way #103 evals reviewers". Charting it would be its own session, with your Q3 words quoted in full.