I'm saving your Q5 budget rule to memory and fixing the index line. The round-two questions come next.

---

First, a problem: I tried to post your answers word for word as a comment on the ticket, the way the map keeps your earlier rounds, and the post was declined. Nothing is on GitHub yet. Do you want me to post it, or keep the record somewhere else? Locally, I've rewritten my memory note about rules to match your Q1 answer and saved your Q5 budget rule as a memory of its own.

Here is round two. It starts by going back over Q1 with examples, as you asked.

---

❓ **Q6 - Q1 in practice: do these calls feel right to you?** Plainly put, a rule can stop the reader only if two things are both true:

1. It's about the job itself (what you want, what finished looks like, or something that's someone else's call), not about how the reader goes about it.
2. The person whose call it is made it a rule.

Anything else is advice: it goes in with its reason, and the reader may do better. Here's that test applied to rules from this factory and from your own stories:

| Rule | About the job, or how to do it? | Who set it | Binds? |
|---|---|---|---|
| Never push to `main` | The job: merging is your call | You | **Yes** |
| Don't edit the files another subagent is editing right now | The job: that work belongs to someone else | The orchestrator, which divided the work | **Yes** |
| The orchestrator never writes the code itself; it delegates | How to do it | You, with evidence | **Yes.** You took this choice off the table. Only you can do that. |
| The trail review is mandatory | How to do it | You, after it caught the owner's errors three times out of three | **Yes**, for the same reason |
| Reviewer, read only the diff | How to do it | An orchestrator, to save cost | **No.** At most it's advice, and here it's better left out |
| Under 400 words | How it's finished | An orchestrator | **No** (Q3 moves any bar to a later step) |
| "Halve token burn or the ticket isn't done" (your story) | Looks like the job: it claims to say what done means | The model invented it from your passing prediction | **No.** This is why the second check exists: the first one alone would have let it through |
| Read the tier file in two plain commands, because the guard refuses nested `git` | How to do it | Whoever hit the trap | **No, it's advice.** The reader follows it because it's right, and the reason lets it notice when it no longer is |

The pattern: you can make any choice binding, including one about how the work is done. An orchestrator can make binding only what it really owns, like the division of work. Nobody can turn a guess or a prediction into a rule.

➡️ If any row feels wrong to you, that row is where the test is wrong, and I'd rather find out now.

---

❓ **Q7 - Your worry on Q3: a reviewer fixating on one kind of bug.** I need to correct what I implied. The evidence that "both get found" is about a reporting bar: reviewers found the bugs and then held back the ones under the bar. Moving the bar to a later step fixes that. Your worry is different. The reviewer's own attention settles on one kind of bug, say unusual inputs on unhappy paths, and it reads straight past the kind you wanted. Moving the bar doesn't fix that. The gorilla studies say the focus decides what gets seen, whoever set the focus. The research also found that models' answers already converge, so a second run of the same brief tends to look in the same places.

Two ways to deal with it:
- (a) **A slight push in the brief** ("we're especially wary of X"). The research predicts the headache you foresaw. A push is a list of one. Examples get copied into the answer, and naming part of a space suppresses recall of the rest (§2). It would pull attention toward X and away from everything else.
- (b) **Separate passes, each with a different open goal.** For example, one pass finds what's wrong, and another asks whether this does what the ticket meant. In a separate pass, the kind you care about is that pass's goal, not a hint buried in someone else's brief. The evidence: in Shin's preprint, a second reviewer with an open brief recovered every finding the narrow one missed. Your own measurement in P103 found that a second reviewer run bought more recall than any change of model.

➡️ (b), which is the "multiple passes" you named. How many passes and with which goals is review-system design, which is Q8.

---

❓ **Q8 - Where does the review system you described go?** You're right that it's bigger than briefs: spec-review mostly hunting bugs, interrogate's wider range and its own leading wording, multiple passes, verifiers, and recall measured against planted bugs rather than celebrating zero false positives. This map's destination is how the factory writes. It covers the review brief templates, which the ticket "Prototype brief templates for the recurring lane jobs" owns. It doesn't cover which passes exist, who verifies, or how review is scored. The options:
- (a) Give the review system its own wayfinder map, opened once this map's writing decisions exist, with them as inputs.
- (b) Widen this map's destination to include it.
- (c) Note it under this map's Not yet specified and decide later.

➡️ (a). It's as big as any of the five maps, and "Decide how we'll know the writing works" (recall against planted bugs) feeds it directly. Widening this map would also delay the writing standard, which every other map is waiting on. Until then I'd add one line under Not yet specified pointing at it, so it isn't lost.

---

❓ **Q4, asked again - what replaces the five ways of departing from a rule?** Here is what exists today, in plain words:

1. **Ask first.** [AGENTS.md:26](AGENTS.md:26) and [template/AGENTS.md:20](template/AGENTS.md:20): "If one fights the task in front of you, say so loudly and get a sign-off before breaking it." A subagent has nobody to ask, and no text says what it should do instead.
2. **Obey first, explain after.** [template/AGENTS.md:16](template/AGENTS.md:16): when the file disagrees with your instinct, "follow the file and tell me why your instinct differed." This contradicts mechanism 1.
3. **Decide and record it.** Where the spec is silent, the agent makes the call and writes a Provisional decision you can overrule (DECISIONS, the Ticket playbook). This is about silence, not conflict.
4. **Skip visibly.** poteto-mode, from upstream, lets a step stay in the list as `skip: <reason>`. [feature.md:12](template/.agents/skills/poteto-mode/playbooks/feature.md:12) forbids it for delegation.
5. **Hand it back up.** A writer's flags must end `fixed: <sha>` or `accepted: <reason>`, and a script refuses review until each one does. A writer that can't build a test cell as written stops and reports instead of improvising. A design hole amends the ticket.

What I'm proposing, mapped onto these:

- **Departing from advice** (the "No" rows in Q6): no permission needed. The report always carries a line saying where the reader took a different route and why, or that it took none. Mechanism 4 becomes this line, for everyone.
- **A binding rule fights the goal:** take it to whoever owns the rule. In your session, with you present, that means asking you, which is mechanism 1. In a subagent, it means stopping that part, reporting the conflict up, and carrying on with the rest, which is mechanism 5 generalized. The reader never quietly shrinks the goal to fit.
- **Silence:** mechanism 3 stays as it is.
- **Mechanism 2 goes.** "Obey, then explain" is the one that lets a guessed rule beat the goal.

➡️ That proposal: one rule ("take a conflict to the rule's owner"), which looks different depending on whether the owner is present.

---

❓ **Q9 - Your budget rule, read back so you can check I have it right.**
- In `safe` (the first mode), a budget never shapes the work. It's only measured afterward, to look for ways to optimize.
- In `eco` and Let It Rip, a budget can reach a brief as binding only after you've been asked how much it weighs against your other goals. Let It Rip adds wall clock as a second budget under the same rule, and it never overrides processes you required.
- When in doubt, leave budget out. If the writer thinks it matters but can't ask you, it goes in as information, never as a limit.
- A prediction ("this might halve token burn") never becomes a requirement. That's Q6's second check catching it.

➡️ If that's right, I'd also pass it to the map "Design Let It Rip as the third mode", since that map owns the mode.

---

I parked your Q2 point about dense terms. One precise term that already carries 90% of what you want, plus only what that term wouldn't carry, matches the research on rule count. The research didn't test it, though, and it has a catch you've already named: a dense term brings its own norms. "Code review" carries "hunt for bugs", which is roughly the narrowness you see in spec-review. It belongs to "Decide what the writing standard is and what carries it", with the experiment you describe going to "Decide how we'll know the writing works". I'll carry it to both once the ticket closes.