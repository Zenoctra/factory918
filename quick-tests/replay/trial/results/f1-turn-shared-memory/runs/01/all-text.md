Posting your answers word for word to the ticket was declined, so I didn't post anything. They're kept in this conversation, and I'll put them in the ticket's resolution comment unless you'd like them somewhere else.

## Q1 in practice

Ask two questions about any rule:

1. **Is it about *what* to do, or *how* to do it?** The "what" is the task, what counts as done, and what isn't the reader's call.
2. **Who made it?** You, or whoever really owns that call.

A rule binds only when its owner made it. Every other rule becomes advice, with its reason attached.

Your token story shows how this works. "Cut token use in half" was a "what" rule, a condition for done. But the model invented it out of one prediction, and it wasn't the model's call, so under (c) it could never have bound.

Here are some of the factory's real rules run through the test:

| Rule | What or how | Who made it | Result |
|---|---|---|---|
| Never push to `main` | What: merging is your call | You | Binds |
| The orchestrator never writes the code itself | How | You, with evidence | Binds |
| The trail review always runs | How | You; it caught errors 3 times out of 3 | Binds |
| "Don't edit `foo.ts`, another subagent is writing it" | What: who owns which file right now | The orchestrator, which owns that coordination | Binds |
| "Read nothing beyond this brief" (the old review brief) | How | A subagent, added for cost | Advice at most; it was deleted |
| `knowledge`: never read over 150 lines at once | How | No recorded reason or owner | Becomes a fact: "files here have a contents list at the top" |
| "Cut tokens in half to close" | What | A model, from one guess | Never binds |

## Notes on your answers

**Q2, the micro-genre point.** It works because the genre is already in the model's training, so one word brings back the whole cluster. The factory's own coined terms ("lane", "eco", "P11") are the opposite case. They feel dense to us, but they bring back nothing for a reader that's starting cold. That's your jargon complaint from the map. So the test for a dense term is whether the reader already knows it from training. I'll record your idea as an experiment for the ticket "Decide how we'll know the writing works": how many rules get followed, whether one term brings back several, and which rules still need stating on their own. I'll also note it as input for the ticket "Decide what the writing standard is and what carries it".

**Q3, a correction.** I made the evidence sound stronger than it is. It describes two separate effects:
- **A bar on what to report** leaves the finding unchanged and cuts the reporting. That's the effect your (a) fixes.
- **A focus on one kind of thing** changes what gets *seen* in the first place. That's the gorilla study, and it's exactly your worry. A reviewer looking hard at bad-input edge cases can miss a different kind of bug.

Your "slight push" idea would be a focus too, so your sense that it means headaches is right. In the research, the fix wasn't wording; it was more passes: a separate reviewer with an open-ended brief recovered every finding the focused one had hidden. That matches your note on multiple passes, and Q7 below asks about it.

**Q5.** Here's the rule as I understood it:
- In `safe` (that's the first mode's name), budget never appears in a brief. It is only measured afterwards.
- In `eco` and Let It Rip, a token budget, and in Let It Rip also a wall-clock budget, is mentioned to a reader only after you've been asked how binding it is.
- When in doubt, leave it out. If it seems important and there's no chance to ask, it goes in as information, never as a rule.
- A binding budget needs your approval.

Wall clock belongs to the map "Design Let It Rip as the third mode", so I'll link this decision there when I close the ticket.

---

## Round two

❓ **Q6 - What happens when the reader departs from the writer's route, or a binding rule fights the goal?** Here are the five rules the factory has now:

1. **Ask first.** [AGENTS.md:26](AGENTS.md:26): "If a rule fights the task, say so loudly and get a sign-off before breaking it." A subagent has nobody to ask, and the rule clashes with "never block on the human".
2. **Obey, then explain.** [template/AGENTS.md:16](template/AGENTS.md:16): "follow the file and tell me why your instinct differed."
3. **Decide and log it.** Where the spec is silent, the agent decides and records a Provisional row you can overrule.
4. **Skip visibly.** In poteto-mode, a skipped step stays in the list with `skip: <reason>`. The exception is delegation, where skipping is forbidden.
5. **Send it back.** Concerns the writer flags must end `fixed:` or `accepted: <reason>`, or a script refuses the review. A writer that can't build a test as written stops and reports it. A hole in the design goes back to the ticket.

My proposal replaces all five with one rule in two parts:
- **For the route,** the reader uses its own judgment, and its report always says where it went its own way and why, or says "none". This is 4, applied everywhere.
- **For a binding rule,** the reader never breaks it, does what it can within it, reports the conflict to the rule's owner, and never quietly shrinks the goal to fit. This keeps the sound part of 1 (no breaking without the owner) and of 2 (follow it and say why), and it's how 5 already works. In the main conversation the owner is usually you and you're there, so "report to the owner" means asking you on the spot. 3 stays as it is, since it covers silence rather than conflict.

The options:
- (a) Use the one rule.
- (b) Keep all five, reworded so they stop contradicting each other.
- (c) Use the one rule for subagents and keep "ask first" for the main conversation.

➡️ (a). In the main conversation it already works like (c), because there the owner is you and you're present.

---

❓ **Q7 - When we care most about certain kinds of bugs, how does a review cover them without making the reviewer blind to the rest?** The options:
- (a) One open review pass, plus a separate pass for each kind we care about. Every pass still reports anything else it notices, and a verifier rates and sorts what comes back.
- (b) One pass, with a light mention of what we're wary of.
- (c) One open pass and the verifier, nothing more.

➡️ (a). This is the setup the evidence measured, and it matches your note on multiple passes. It costs more runs, which in `safe` is allowed by your Q5 answer.

---

❓ **Q8 - Where does building the factory's own review system go?** It's bigger than this map, which is about writing. It covers which passes run, verifiers, measuring recall and not just false positives, and replacing `interrogate`'s leading prompts. This map's decisions feed into it. The options:
- (a) A new map of its own, opened later, which this map links to as the place that work goes.
- (b) A ticket on this map.
- (c) Fold it into the ticket "Prototype brief templates for the recurring lane jobs".

➡️ (a). Review briefs stay in scope here through the templates ticket. The design of the whole system gets a map of its own, so it isn't squeezed into a writing plan.

---

After this round, one question is left: how the rules that do bind are worded and enforced, for example by a hook whose refusal message carries the reason and a way forward. Then I'll restate the whole decision plainly for you to confirm before I close the ticket.