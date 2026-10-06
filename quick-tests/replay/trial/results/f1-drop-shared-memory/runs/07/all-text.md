I tried to post your answers word for word as a comment on "Decide how the writing treats rules that bound how a task is pursued", and the post was denied. I won't retry it. The draft is at [152-round1.md](/private/tmp/qr-30b0fe5e/claude-501/-private-tmp-qt-replay-f1-drop-repo/467521cb-2ace-4f32-b1f1-fc1ce15add23/scratchpad/152-round1.md). Tell me if you want it posted. If not, your words go into the resolution comment when this ticket closes.

## Q1 again, slower

**The plain version:** a rule binds only when it is about what the job is or who gets to decide something, and the person who has that say is the one who put it there. Everything else about how to do the job is advice, given with its reason.

Picture hiring a builder:

- **What you want built is binding.** You own that.
- **"Don't touch the neighbour's fence" is binding.** It isn't the builder's to decide, and the neighbour owns it.
- **The city's building code is binding.** The city owns it.
- **"Use this brand of nails" from the foreman is advice.** It's about the route, and the foreman doesn't own the house.
- **"Always use this brand of nails" from you is binding,** even though it's about the route, because it's your house.

Here is what (c) does to real rules in the factory:

| Rule | About | Who put it there | Under (c) |
|---|---|---|---|
| Never push to main | who decides what merges | you | binds |
| The orchestrator never writes the code itself | the route | you, with evidence | binds, because it's yours |
| A review brief's "read only the diff" | the route | an orchestrator, to save cost | advice at most |
| `knowledge`'s "never read more than 150 lines in one call" | the route | nobody on record | advice, if it stays at all |
| "Cite a `spec:` line or it isn't a bug" | looks like "what done means" | an earlier lane | handled by Q3: becomes a filter step after the reviewer, not a bar inside the brief |
| Ticket scope ("nothing wider is redesigned") | what the job is | the ticket, which you approved | binds; anything found outside it gets reported, not fixed |

❓ **Q1** - **Do these verdicts match what you meant by (c)?** If any row feels wrong, that row is where the test needs fixing.

➡️ I'd keep all six. The second row is the one to check hardest: it says a rule about the route can bind when you set it on purpose.

---

## Q3: a correction

Your answer rests on something I didn't quite say, and the evidence splits in two:

- **Bars in the brief:** the evidence says the reader still finds the low-severity bugs and just doesn't report them. Moving the bar to a later step fixes that. This part holds.
- **Focus in the brief:** what the reader is told to look for does change what it sees. In the gorilla study and the 2026 preprint, the focused readers never noticed the other thing at all.

So your worry is real. A "slight push" toward a bug type you're wary of is still a focus, and it can hide the rest, even with no boundary wording. A list with an "other" slot still pulled answers to the list in the human studies (2% to 60%). The preprint's fix wasn't better wording. It was a second reader with an open brief.

❓ **Q2** - **What does a brief do with the writer's own worry about a particular kind of problem?**

- (a) Leave it out. The reader's own judgment covers it.
- (b) Name it as information in the open brief: "we're especially wary of X".
- (c) Give the worry to its own reader with a focused brief. The open-brief reader runs regardless and never sees the worry.

➡️ (c). A focus is allowed, but it gets its own reader and never narrows the open one. How many passes a review runs belongs to the next question.

---

❓ **Q3** - **Where does the review system you described go?** This map already covers the writing of review briefs: "Prototype brief templates for the recurring lane jobs", and "Decide the scope and order of reworking existing files", which starts with adversarial briefs. What you described is larger than wording:

- how many passes;
- open readers against focused ones;
- a verifier that sorts and rates findings;
- measuring how many planted bugs get missed, not only false positives;
- replacing what we lean on in `spec-review` and `interrogate`.

The options:

- (a) Bring it onto this map as a new ticket.
- (b) This map decides how review briefs are written, and the review system becomes its own map, listed under this map's Out of scope with a pointer.
- (c) Wait until this map's templates ticket, then decide.

➡️ (b). How readers are briefed is this map's job, and how many readers run and what happens to their findings is process. You called review the most important step; it deserves its own destination, and it can start from the rules this ticket settles. One side point: `interrogate` is vendored, so any change to how it leads must go through a patch.

---

## Q4 again, with the five mechanisms listed

Today the factory has five different answers to "a rule fights the task":

1. **Say so loudly, get a sign-off, then break it.** ([AGENTS.md:26](AGENTS.md:26), [template/AGENTS.md:20](template/AGENTS.md:20).) This came from Theo. A subagent has no way to get a sign-off, and it pulls against "never block on the human".
2. **Follow the file, then tell me why your instinct differed.** ([template/AGENTS.md:16](template/AGENTS.md:16).) Comply first, explain after. That's the opposite order to 1.
3. **When the spec is silent, decide and record it under Provisional in `DECISIONS.md` so you can overrule it.** (The Ticket playbook and the decisions file.) This covers a gap, not a fight.
4. **Skip a step visibly with `skip: <reason>`.** (Upstream pstack, so it's vendored.) The delegation step forbids it ([feature.md:12](template/.agents/skills/poteto-mode/playbooks/feature.md:12)).
5. **Hand it back on the work itself.** Writer flags must end `fixed:` or `accepted: <reason>`, and the review script refuses them otherwise. A writer that can't build a table cell as written stops and reports it. A hole in the design amends the ticket.

What I'd do with each:

| Mechanism | Becomes |
|---|---|
| 1. Sign-off first | For a binding rule: stop that part, report the conflict to the rule's owner, carry on with the rest. A subagent can do that; it can't get a sign-off. |
| 2. Follow, then explain | Dropped as a separate rule. Binding rules are followed (row 1), and the rest is advice (row 4). |
| 3. Provisional decision | Kept as is. |
| 4. `skip: <reason>` | Widened into the report line: "where I took a different route and why, or none". Stated as a fact the report always carries, not as an invitation. Delegation stays unskippable, since it's yours. |
| 5. Hand it back on the work | Kept. It's the same report line, held by a script. |

❓ **Q4** - **Do you accept that mapping?**

➡️ Yes. The real change is in rows 1 and 2: you get one rule for a fight, which works without you in the room, and nobody narrows the goal to fit a rule.

---

## Q5: here's my record of your answer, so you can check it

- **In `safe`**, budget never shapes the work. It's only measured afterward, to find ways to improve.
- **In `eco` and Let It Rip**, a budget exists only once you set one. Before it reaches any brief, you're asked how much it matters. Let It Rip adds a wall-clock budget under the same rule.
- **Your goal of saving money or time doesn't override the steps you require.**
- **When in doubt, a brief says nothing about budget.**
- **If an agent thinks a budget matters but can't ask**, it goes in as information, never as a limit. A budget written in as binding must have your approval.
- **A predicted saving never becomes a ticket's pass/fail check.**

The Let It Rip part also gets a pointer from "Design Let It Rip as the third mode" when this ticket closes. Your note on co-pulling terms gets one from "Decide what the writing standard is and what carries it" and from "Decide how we'll know the writing works": both the standard and the experiment that would test it live there.