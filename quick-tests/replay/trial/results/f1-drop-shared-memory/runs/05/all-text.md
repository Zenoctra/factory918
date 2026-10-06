I tried to post your answers word for word as a comment on the ticket, and that was declined, so nothing went to GitHub. They're saved word for word in a local file. When the ticket closes, I'll put them in the resolution comment unless you'd rather I didn't post them.

## Q1, explained through examples

Forget the categories. For every rule, ask one thing: **did someone who owns that decision set it, and did they mean it as a must?** If yes, it binds. If not, it's advice: the writer passes it on with its reason, and the reader decides.

"What the rule is about" only fills in the default when nobody has said anything. The task, what done means, and whose decision something is all pass down to the reader. The route stays with the reader.

| Rule | Who set it | Binds? |
|---|---|---|
| Never push to `main` | You. Merging is your decision. | Yes |
| The orchestrator never writes the code itself | You, on purpose, with evidence. It's about the route, but it's yours. | Yes |
| The trail review always runs | You, after it caught the owner's errors three times out of three | Yes |
| Don't edit `auth.ts`, another lane is working in it | The orchestrator, which owns coordination between lanes | Yes, with the reason |
| This ticket's scope is X | Your ticket | Yes |
| "Read only the diff," in a review brief | The orchestrator, guessing where the bugs are | No. At most: "the change is in this diff." |
| "Token burn must halve to close," from one anecdote | The agent, inventing a target nobody set | No. That's your story from Q5. |

So the problem isn't rules. It's an agent quietly promoting its own guess to a must. Your Q5 answer is the same principle applied to budgets: a budget binds only if you approved it as binding.

Do the verdicts in the table match yours? If any one feels wrong, that tells me where the test is off.

## Q4: the five mechanisms that exist now

1. **Say so loudly and get a sign-off before breaking the rule** ([AGENTS.md:26](AGENTS.md:26), [template/AGENTS.md:20](template/AGENTS.md:20)). A subagent running alone has nobody to sign off. It also pulls against "never block on the human".
2. **Follow the file, then explain why your instinct differed** ([template/AGENTS.md:16](template/AGENTS.md:16)). This is the opposite default: comply first, report afterwards.
3. **Where the spec is silent, decide and record a Provisional decision you can overrule.** This covers gaps, not conflicts.
4. **Skip a step visibly, with `skip: <reason>`.** This comes from upstream poteto-mode, and [feature.md:12](template/.agents/skills/poteto-mode/playbooks/feature.md:12) forbids it for delegation.
5. **Stop and hand it back.** A writer that can't build a test cell as written stops and reports it. Writer flags must end `fixed:` or `accepted: <reason>`. A design hole amends the ticket.

What I propose does this to them:
- **1 and 2 are replaced:**
  - For advice about the route, the reader uses its judgment, and its report always says where it departed and why, or that it didn't.
  - For a binding rule that fights the goal, it stops that part, tells the rule's owner, and carries on with the rest.
  - In your own session the owner is right there, so "tell the owner" becomes "ask Manuel". That keeps the sign-off from 1 where a sign-off is possible.
- **3, 4 and 5 stay**, because each is already a case of the above. 3 is a gap the reader fills. 4 is the departure report for playbook steps. 5 is stop-and-tell-the-owner.
- **The delegation exception in 4 stays**, because you made that rule binding.

## Q3: your worry is fair, and I overstated the evidence

The finding that "it still gets found" is about **bars**. A reviewer told "only high severity" keeps finding everything and just reports less. Your worry is about **focus**, and there the evidence agrees with you. What a reader is told to look for decides what it sees: the gorilla study, and the preprint where a narrow instruction hid findings the same models otherwise reported. So "we're especially wary of X" would cost what it focuses away from.

The remedy in that preprint wasn't a nudge. It was a second reviewer with an open-ended brief, and it recovered everything the first one missed. That's your "multiple passes", and it's a design question for the review system. So (a) stands, and the "slight push" question moves to whoever designs the review system.

## Q5

I've recorded it like this:
- In `safe`, a budget never shapes the process. Budgets are only measured afterwards, to find what to optimize.
- In `eco` and Let It Rip, a token or wall-clock budget reaches a brief only after you've been asked how binding it is.
- When in doubt, don't mention the budget at all.
- If it seems important and there's no chance to ask, it goes in as information.
- It goes in as binding only with your approval.

## Q2

Your micro-genre point is noted for the ticket "Decide how we'll know the writing works", as an experiment. It asks two things: does one term that pulls in a cluster of rules beat stating each rule, and which rules still need stating on their own? The research doesn't test it. Its finding that the best model followed 68% of 500 instructions only shows why the idea matters.

---

## Round two

❓ **Q6 - Where does the review system go?** You described your own review system: several passes, better briefs, wider than bugs, recall measured alongside false positives. The options:
- (a) A sixth map. Its destination is a review system, not a writing plan, and it would use this map's decisions.
- (b) Fog on this map, under "Not yet specified".
- (c) Part of the ticket "Prototype brief templates for the recurring lane jobs".

➡️ (a). It's bigger than templates, and "Optimize token use and wall-clock time without losing reliability" and this map both feed into it. I'd also add a line to this map's fog pointing at it, so it isn't lost before the new map is charted.

---

❓ **Q7 - How is a binding rule written and held?** The research says to write it once, plainly, with its reason, and as what to do rather than what not to do. It also says emphatic wording ("NEVER", "CRITICAL") makes current Claude models over-apply a rule. Where a hook already enforces the rule, the hook's refusal arrives at the exact moment it matters. The options:
- (a) The prose states the rule once, with its reason, and the hook's refusal message carries the reason and a way forward. Briefs point to the rule rather than restating it.
- (b) The prose restates the rule wherever it might matter, as today.
- (c) Hooked rules leave the prose entirely.

➡️ (a). Repeating a rule in every brief adds to the instruction count you just pinned, and briefs are where an orchestrator's own guesses slip in beside your rules and borrow their authority. (c) goes too far, because a rule the reader never sees until it's refused costs it a wasted turn.