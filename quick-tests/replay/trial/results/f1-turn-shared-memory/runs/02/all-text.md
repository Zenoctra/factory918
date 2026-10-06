Taking your answers in order.

**Q1, in practice.** I made it more abstract than it is. Here is the plain version, and I want to check it's what you picked. For any "do this" or "don't do that" sentence in a brief, ask one question: **who owns the thing this sentence is about?** Only that owner can make the sentence binding. The reader owns its own route unless you've decided otherwise.

| Sentence in a brief | Whose thing is it? | What it becomes |
|---|---|---|
| Never push to main | Yours: merging is your act | Binding |
| The orchestrator never writes the code | Yours: how the factory works is your call | Binding, even though it's about how |
| Don't edit `foo.ts`, another subagent is writing it right now | That subagent's, for now; the orchestrator assigned it | Binding |
| Read only the diff | The reviewer's: how it reads is its own route; an orchestrator added the rule to save tokens | Not binding. Drop it, or turn it into information: "the diff changes `parse()`, and three files call it" |
| `vp check` on the whole repo is slow, so run it on the changed files | The reader's route; the orchestrator learned this the hard way | Information, with its reason |

Anything that isn't binding is information the reader may use or not. Its report says where it went another way.

**Q2, the micro-genre point.** I read it this way: one well-chosen term brings a whole cluster of rules with it, more cheaply than spelling them out. Then you add only what that cluster wouldn't already carry. Whether that works for rules, and which rules still need their own push, is something to test, not assume. It belongs with the ticket "Decide how we'll know the writing works". One link to the research: the cluster is also the risk. A term brings in everything associated with it, including what you didn't want. Your "only add what the genre wouldn't carry" is the half that guards against that.

**Q3, your worry.** It's a real effect, and the research doesn't fully settle it. Two different things happen:
- **A bar on what gets reported** makes the reviewer withhold what it found. (a) fixes that.
- **Focus** decides what gets seen in the first place. That's the gorilla finding. A reviewer that fixes on edge-case inputs can read past a logic bug, and (a) doesn't fix that.

A "slight push" toward a bug type is the same narrowing instruction pointed somewhere else, so it trades one blind spot for another. The fix the evidence supports is more readers, not a better-worded push. In Shin's study, a second reviewer with an open-ended brief recovered everything the focused one missed. If one class of bug matters most, it gets its own reviewer alongside the open one. That's review-system design, which brings me to a new Q6 below.

**Q5.** Here is what I took from your answer:
- **In `safe`:** budget never affects the process. It is only measured afterward, to look for ways to optimize.
- **In `eco` and Let It Rip:** a token or wall-clock budget reaches a brief only after you've been asked how much it should weigh.
- **When in doubt, leave the budget out.** If it seems important and nobody can ask you, it goes in as information, never as a limit. A budget binds only if you approved it as binding.

Your example, where a predicted halving of token use became the ticket's closing requirement, is the same failure as the "at most" list. A prediction must never become a rule. This also bears on the map "Design Let It Rip as the third mode", so I'll point to it from there when this ticket closes.

---

❓ **Q1 (confirming)** - **Is the table above what you meant by (c)?** I originally wrote "it needs both: what the rule is about and who owns it". In practice that comes down to "whose thing is it". The "what it's about" half only ever answered "whose".

➡️ Yes, if the table matches your intuition. If a row feels wrong, that row is the one to talk through.

---

❓ **Q4 (with the five mechanisms this time)** - **What does a reader do when a rule and the goal collide?** Today the factory says five different things:

1. **Stop and get a sign-off.** "If a rule in this file fights the task in front of you, say so loudly and get a sign-off before breaking it" ([AGENTS.md:26](AGENTS.md:26), [template/AGENTS.md:20](template/AGENTS.md:20)). A subagent running alone has nobody to sign off, and nothing says what it should do instead.
2. **Comply first, explain after.** Your note in the template: "when this file and a vendored skill disagree with your instinct, follow the file and tell me why your instinct differed" ([template/AGENTS.md:16](template/AGENTS.md:16)).
3. **Decide and record it.** Where the spec is silent, the agent makes the call and writes a Provisional row in DECISIONS so you can overrule it.
4. **Skip visibly.** In poteto-mode, a step the agent chooses not to do stays in its list as `skip: <reason>`. The feature playbook forbids this for delegation.
5. **Hand it back on the artifact.** A writer's flag has to end `fixed: <sha>` or `accepted: <reason>`. A writer that can't build a test cell as written stops and reports that cell.

Numbers 1 and 2 are opposites: one says stop, the other says comply. Numbers 3 and 4 say decide for yourself. A subagent can pick any of the five and still be following the rules.

My proposal:
- **A binding rule fights the goal:** the reader stops that part, reports the conflict to the rule's owner, and carries on with the rest. This keeps the spirit of 1 and works with nobody watching.
- **Information:** the reader uses its judgment, and its report says where it went another way or that it didn't. This replaces 4.
- **3 and 5 already work this way and stay.**
- **2 is your own wording,** so it's your call. Under this proposal it would become "use your judgment and tell me why you differed": the explaining stays and the comply-first goes.

➡️ The proposal as above, with 2 reworded only if you agree.

---

❓ **Q6** - **Where does the review system you described live?** You described one with several passes, recall measured against planted bugs, a separate filter step, and maybe a reviewer per bug class. The factory already has a start on measuring that: the planted-bug reviewer eval under `tests/eval/reviewer/`, with its answer key from run 2. The options:
- (a) Fog on this map.
- (b) Its own map, taking this map's writing decisions as input.
- (c) Part of the ticket "Prototype brief templates for the recurring lane jobs".

➡️ (b). Review is a whole process: passes, filters, measurement. That's bigger than writing, and this map's destination is the writing. This map would carry one line under Not yet specified pointing to the new map, so the review brief templates aren't designed twice.

---

Last, I'd like to keep your words from this round, as we did for the charting rounds. I'll post them word for word on this ticket and add a pointer on "Decide how we'll know the writing works" for the micro-genre experiment, once you say go. My last command was refused, so I'm not posting anything to GitHub without you.