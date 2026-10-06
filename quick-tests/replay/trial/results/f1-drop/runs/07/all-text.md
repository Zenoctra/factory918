Your answers are saved word for word in my scratchpad. They'll go into the ticket's resolution comment as the record. Before round two, there are two corrections from me and a plainer version of Q1.

**Q3: a correction.** I didn't claim that a reviewer finds both kinds of bug, and the evidence doesn't say so. It covers two different problems:

- **Withholding.** A bar like "report only the serious ones" doesn't change what the reviewer finds. It changes what the reviewer writes down. Your (a) fixes that.
- **Drift.** This is your worry: the reviewer settles on one kind of bug and reads past the rest. On this, the evidence runs the other way. What a reader is looking for decides what it sees. On open-ended questions, models already give very similar answers to each other. So a model drifting to its favourite kind of bug on its own is plausible, and (a) does nothing about it.

The one fix the evidence shows is structural. A second lane with an open-ended brief recovered every finding the narrow one had dropped.

Your "slight push" cuts both ways. Naming a category made people pick it about 30 times more often (1–2% to about 30%). Naming some items also made people recall fewer of the items not named. A push toward one bug type in a second lane, with the first lane left open, might get both. That's a design question for the review system, which is Q8 below. I'll record (a) as your answer unless this changes it.

**Q1, plainer. My "(c) both" doesn't fit the delegation rule, so here is what it should have said:**

- **The route belongs to the reader by default.** The route is what it reads, what it runs, what order it works in, and when it stops.
- **The task and other people's territory belong to their owners.** Merging belongs to you. A file another lane is writing belongs to that lane. What "done" means belongs to the ticket.
- **A rule binds when its owner says it binds.** You can also claim a piece of the route, with a reason, and then it binds too. "The orchestrator never writes the code" is one example.
- **An orchestrator can't claim route.** It passes down what you claimed and binds only what it owns itself.
- **Everything else is information.**

Your token story is the clean case. The model turned a prediction ("this might halve token burn") into a requirement for closing the ticket. Under this rule it couldn't have: the budget is yours, you hadn't said it binds, so it could only ever be information.

**Q5, as I'll record it:**

- In `safe`, the first tier, a budget never shapes the process. Tokens and time are measured afterward, to look for savings.
- In `eco` and Let It Rip, a budget binds only after you set it and say how much it matters against your other goals. In Let It Rip that applies to wall-clock time as well as tokens.
- When in doubt, the brief leaves the budget out.
- If an agent thinks the budget matters but can't ask you, the brief states it as information, not as a limit.
- A budget written as binding has your approval.

**Q2, your note on dense terms.** I'll pin the instruction-load point and your micro-genre idea onto the map, as an experiment for the ticket "Decide how we'll know the writing works". My own reading, untested: the pull that makes a micro-genre term efficient is the same pull that makes a list limit the answer. A term brings in its typical members and crowds out the rest. That's good for carrying rules and knowledge about the route. It's risky inside an open goal: a reviewer told "security review" may fill up on the textbook security bugs.

---

❓ **Q6 - Do these verdicts match your gut?** This tests Q1 on real rules from the factory. A verdict that feels wrong means the rule needs fixing.

| Rule | Whose is it | Verdict |
|---|---|---|
| Never push to main; never merge | Yours | Binds. The guard hook holds it. |
| Don't edit files another lane is writing | That lane's; the orchestrator assigns it | Binds |
| The orchestrator never writes the code; it delegates | Route, but you claimed it with evidence | Binds. The hook holds it. |
| Run the trail review before reporting merge-ready | Route. It's in the playbook with evidence: three of five lanes ran it, and all three found something the owner had wrong. | Binds only if you claim it. Do you? |
| A reviewer's finding counts as hard only with a `spec:` citation | A completion bar added by a lane | Moves to the filter step under Q3. A reviewer made nothing of four real bugs because of it. |
| `knowledge`: never read more than 150 lines in one call | Route. No reason recorded; nobody claimed it. | Becomes information if a reason turns up. Otherwise it's deleted. |
| "Subagents never launch their own dev servers, simulators or emulators" | Mixed. Partly a shared resource, since the primary agent owns the one integrated pass. Partly route. | The shared-resource part binds. Its reason, dropped when the rule was copied from Theo, gets written back. |
| "Token burn must halve to close" | A prediction made into a requirement | Information at most (Q5) |

➡️ I'd stand by every row. The trail-review row is yours to call.

---

❓ **Q4 - What does the reader do when it departs from a rule, or when a rule fights the goal?** Here are the five mechanisms the factory has today:

1. **Ask first.** "These are good defaults, not hard rules. If one fights the task in front of you, say so loudly and get a sign-off before breaking it." This is from your note in `template/AGENTS.md`, and the factory's own AGENTS.md says the same. It works when you're at the keyboard. A subagent has nobody to ask, and nothing says what it does instead.
2. **Obey first, explain after.** "When this file and a vendored skill disagree with your instinct, follow the file and tell me why your instinct differed; that is how the rules here get better." This is also from your note. For a rule about the route, it contradicts your Q2 answer, under which such a rule is information.
3. **Decide and record.** Where the spec says nothing, the agent decides and writes it under Provisional in `DECISIONS.md` for you to overrule. This one is for gaps, not conflicts.
4. **Skip visibly.** From upstream pstack: a step the agent chooses not to do stays in its checklist, marked `skip: <reason>`. Delegation is the exception: no skip is allowed.
5. **Send it back up.** Writer flags must end in `fixed:` or `accepted: <reason>` before review runs. A writer that can't implement a test case as written stops and reports it instead of improvising. A hole in the design amends the ticket with a dated line.

So the real conflict is between 1 and 2, and 1 has no answer for a subagent. The other three already fit Q1.

➡️ One rule, by case:

- **For knowledge about the route:** the reader uses its judgment, and its report always carries a line saying where it departed and why, or "none". This generalises mechanism 4. It would change your note's line 2 so that the reason travels with it, along the lines of: "the patterns here are copied from professionals on purpose; prefer them over a first-principles idea unless you have a reason, and say when you depart." That keeps your point that copied patterns beat untested instinct, and it's the Q2 (b) form.
- **For a binding rule that fights the goal:** in the main session with you present, ask first, as mechanism 1 says now. In a subagent, stop that part, report the conflict to whoever owns the rule, and finish the rest. That is mechanism 5's shape.
- **Mechanism 3 stays as it is.** Nobody shrinks the goal to fit a rule.

Since line 2 is your wording, I'd only change it with your sign-off.

---

❓ **Q7 - How is a binding rule written, and what holds it?**

What the research says:
- Emphatic wording ("NEVER", "CRITICAL") makes current Claude models apply a rule too widely.
- A bare prohibition keeps the forbidden idea active and says nothing about what to do instead.
- A reason lets the reader handle the case the writer didn't foresee.

What the factory does today:
- The git guard and the delegation hook already refuse with a reason and a way forward, for example "Use --force-with-lease on your own branch, or ask".
- The same rules are also restated in prose in three or more places.

The options:

- **(a) Stated once, held by a hook where possible.** Each binding rule is stated once, in plain words, with its reason and what to do instead, where the reader plans its work. Where a hook or script can hold the rule, it does, and its refusal carries the reason and the way forward. Other files point to the statement rather than repeating it.
- **(b) Hook only.** The prose says nothing where a hook holds the rule.
- **(c) As now.** Restated wherever it seems relevant.

➡️ (a). Option (b) fails because a reader that doesn't know a wall exists plans its route straight into it; the harness's worktree guard cost lanes turns this way. Exactly where the single statement lives is a question for the ticket "Decide where each piece lives and when it reaches the writer". This ticket only fixes its shape.

---

❓ **Q8 - Where does the review system go?** You described something bigger than the wording of review briefs. You want a review process of the factory's own:

- several passes;
- a wider range than bugs;
- a verifier that rates findings;
- recall on planted bugs as the measure, not only a low false-positive rate.

That's a process design, and it sits past this map's destination, which is how agents write.

The options:

- **(a) A sixth map,** "Design the factory's own review system". This map's templates ticket writes the wording of the review briefs; the new map decides the passes, the lanes and the measure.
- **(b) A ticket on this map.**
- **(c) Fold it into the open ticket "Choose each tier's review round count from the clean measurement".**

➡️ (a). It's at least as big as Let It Rip. It also gets the most out of this map's decisions, so it's worth charting right after this map's standard ticket, "Decide what the writing standard is and what carries it", resolves. Option (c) is too narrow: round count is one dial on that machine. I'd put one line under this map's Out of scope that links the new map once you charter it. Charting it is a separate session.