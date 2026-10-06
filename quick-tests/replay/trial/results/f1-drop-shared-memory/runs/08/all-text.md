I couldn't post your answers to the ticket because the permission was denied. They're saved word for word in [152-round1.md](/private/tmp/qr-8f208021/claude-501/-private-tmp-qt-replay-f1-drop-repo/9b61b783-7693-47e7-8fe1-b646e82ed37b/scratchpad/152-round1.md). I'll post them with the resolution, or now if you allow it.

**Settled from round one:**
- **Q2:** what the writer knows about how to do the job goes in as information with its reason, never as an order.
- **Q3:** the reader reports everything it found. Any bar is applied later, in a separate step.
- **Q5:** depends on the mode.
  - In `safe` (the "Safety Mode" you meant), no budget ever affects how work is done. Budgets are only measured afterward.
  - In `eco` and Let It Rip, a budget reaches a reader only after you set it and say how binding it is.
  - When in doubt, leave the budget out. If it seems important and nobody can ask you, it goes in as information. It binds only if you approved it.
  - Your wall-clock point also belongs to the map "Design Let It Rip as the third mode", and I'll copy it there.
- **Your note on dense terms**, like the micro-genre that carries 90% of a style: it bears on two tickets. I'll put your words on "Decide how we'll know the writing works", which should test how many rules a reader can follow and whether one term can carry several of them, and on "Decide what the writing standard is and what carries it".

---

❓ **Q6 - Q1 again, plainly.** My first version said a rule needs "both" things to bind. That contradicted my own example of the delegation rule. Here is what I actually meant. Ask two things about any rule:

1. **Who made it:** you, or an agent?
2. **What is it about:** where we're going (what's wanted, when it's done, whose call something is), or how to get there?

| | About where we're going | About how to get there |
|---|---|---|
| **You made it** | Binds | Binds. It's a process you require. |
| **An agent made it** | Binds only for what that agent owns (its own files, a port it's using) | Not a rule. It's information with a reason. |

Here it is applied to real rules in the factory:

1. **"Never push to main."** You made it, and it's about whose call merging is. **Binds.**
2. **"The orchestrator never writes the code; a lane does"** ([AGENTS.md:26](AGENTS.md:26)). You made it. It's about how, but it's a process you require. **Binds.**
3. **"Read nothing beyond this brief. Run nothing."** This was in the old review brief, added by a lane to save cost. An agent made it, about how. **Goes.** The brief just says where the diff and the ticket are.
4. **"Never read more than 150 lines in one call"** (the `knowledge` skill, no reason recorded). An agent made it, about how. **Goes,** or becomes a fact with its reason, if one exists.
5. **"A bug needs a `spec:` line to count"** (the review script's gate). An agent made it, about when the work is done. **By Q3,** the reviewer reports everything and the filter step deals with citations.
6. **"Subagents never launch their own dev servers"** ([template/AGENTS.md:66](template/AGENTS.md:66)). It came from Theo, and it splits:
   - The port and the simulator are shared with other agents, so that part binds, written as a fact about whose they are.
   - The rest is about how, so it becomes information.
7. **An `eco` owner writes "keep this under 50K tokens."** By your Q5 answer, it stays out of the brief unless you approved it.

➡️ Do these seven verdicts match what you'd expect? If any feels wrong, that one tells us more than the table does.

---

❓ **Q7 - What counts as "you made it"?** Three kinds of rule are unclear:

- **Rules you merged but an agent wrote.** The review-brief limits in case 3 came in through PRs you merged.
- **Rules from upstream** (Matt, pstack, Theo) that you chose to adopt.
- **Provisional decisions.** These are an agent's own calls, recorded so you can overrule them.

The options:

- (a) Everything in the factory counts as yours, since you merged it.
- (b) Only rules you can trace to your own words: a DECISIONS row quoting you, or a ticket or comment where you set it.
- (c) (b), plus upstream rules, which keep their author's standing until a patch changes them. On 2026-09-24 you ruled that pstack's constraints stay and that factory-written text is suspect until proven.

➡️ (c). This has a big consequence for the ticket "Decide the scope and order of reworking existing files": every binding rule in factory-written text has to trace back to your words. A rule that doesn't gets rewritten as information.

---

❓ **Q4 - When a rule fights the goal.** These are the five mechanisms the factory has now, and what I'd do with each:

1. **Say so and get a sign-off first.** [AGENTS.md:26](AGENTS.md:26) and [template/AGENTS.md:20](template/AGENTS.md:20): "If one fights the task in front of you, say so loudly and get a sign-off before breaking it."
   - A subagent has nobody to ask, and I found no record of this ever being used. Two lines above it, "never block on the human" pulls the other way.
   - **Proposal:** keep it, and widen it. The reader stops only the part the rule blocks, reports the conflict to whoever briefed it (who passes it to you when the rule is yours), and carries on with the rest.
2. **Follow the rule, then explain** ([template/AGENTS.md:16](template/AGENTS.md:16)): "follow the file and tell me why your instinct differed."
   - **Proposal:** keep it, but only for its real case, where your rule differs from the agent's preference. A rule that blocks the goal goes to mechanism 1.
3. **Make the call and record it.** Where the spec is silent, the agent decides and writes a Provisional row you can overrule.
   - **Proposal:** keep it. It handles gaps, not conflicts.
4. **Skip a step visibly.** In poteto-mode, "a step you choose not to do stays in the list with a one-line `skip: <reason>`". [feature.md:12](template/.agents/skills/poteto-mode/playbooks/feature.md:12) bans this for delegation.
   - **Proposal:** it becomes a line every report carries: where the reader took a different way than the writer suggested and why, or "none". The delegation ban stays, because it's your rule (case 2).
5. **Hand the conflict back on the artifact.** A writer that can't implement a test cell as written "stops and reports the cell, and never fills it in". Writer flags must end `fixed:` or `accepted:` before review runs.
   - **Proposal:** keep it. It's mechanism 1, built into the work itself.

The research is why the report line has to be required: readers almost never raise a problem when they're merely allowed to. And across all five, the reader never shrinks the goal to fit a rule.

➡️ Keep 1, widened. Keep 2, narrowed. Keep 3 and 5. Turn 4 into the report line.

---

❓ **Q8 - Your worry about the kind of bug that matters.** Who wants the emphasis decides whether it's allowed.

- **If you or the ticket say** "this touches payments, and we're most worried about money going missing", that's part of the goal. It goes in with its reason.
- **If the orchestrator guesses** "probably input edge cases", that's leading the witness.

Even a legitimate emphasis carries a cost. Naming some kinds of bug makes people recall fewer of the rest, and unusual examples pull hardest. So the emphasis goes in as one stated worry with its reason, never as a list of types, and always next to "report everything you find". Coverage across the kinds of bug comes from more than one reviewer with open briefs, not from more words in one brief.

The options:
- (a) No emphasis ever.
- (b) Emphasis only from the goal's owner, as a worry with its reason, never a list.
- (c) The orchestrator may add emphasis too.

➡️ (b).

---

❓ **Q9 - Where does the review system go?** You described designing the factory's own review system: several passes, recall measured against planted bugs, a broader range than spec-review's bug hunt, and replacing the leading in the vendored `interrogate`. The options:

- (a) Fog on this map.
- (b) Its own map, charted when you choose, with a line under this map's Out of scope that points to it.
- (c) Folded into "Prototype brief templates for the recurring lane jobs".

➡️ (b). How many passes to run, which reviewers, and how to measure them is process design, bigger than writing, and you called review the most important step. This map still decides how review briefs are worded, and the new map takes those results as given. Two open tickets would likely move into it: "Choose each tier's review round count from the clean measurement" and "Eval the judge and trail-review models the way #103 evals reviewers".

---

❓ **Q10 - How a binding rule is written.** Once a rule binds, how should it read?

➡️ In plain words, with:
- its reason;
- who set it;
- what to do instead;
- what to do if it fights the goal (Q4).

No capitals and no "MUST": current Claude models over-apply emphatic rules. Where a hook can hold the rule, the hook's refusal message gives the reason and a way forward. Where each piece of text lives belongs to "Decide where each piece lives and when it reaches the writer", not here.