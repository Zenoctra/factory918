Your answers are saved word for word in a local file, and they go into the ticket's resolution comment. I also saved two of your points to memory so they carry into other sessions: the budget rule, and your micro-genre idea, kept as a hypothesis to test.

Below: Q1 again in plain terms, the five conflicting mechanisms I failed to name last time, and the new questions your answers opened up.

## Q1 in plain terms

Only the person whose call something is can make a rule binding.

- **You own what the project wants and how the factory works.** So your rules bind, including rules about how to work, like delegation.
- **An orchestrator owns very little itself**, mainly which subagent is working in which files right now. It can make those binding.
- **Everything else an orchestrator writes about how to work is advice**, with its reason. The reader may take a better route.

Here are real rules from the factory run through that test. They're tests of the rule, not kinds of rule.

| Rule | Who said it must hold | Result |
|---|---|---|
| Never push to `main` | You | Binds. A hook enforces it. |
| The orchestrator never writes the code; a separate agent does | You, after an agent broke it knowingly | Binds, because you made it bind. |
| The trail review always runs | You, after it caught the owner's errors three times out of three | Binds. |
| Don't edit files another subagent is working on | The orchestrator, which assigned the files | Binds. Assigning files is the orchestrator's call. |
| Reviewer: read only the brief and the diff | Nobody. A lane added it to save tokens. | Doesn't bind. If the writer knows "the change is in these three files", it says that as a fact. |
| `knowledge`: never read more than 150 lines at once | Nobody. No reason is recorded. | Doesn't bind. It becomes advice with a reason, or it goes. |
| Subagents never start their own dev servers | You adopted it from Theo, and his reason was dropped | The part about ports and processes other agents share binds, and gets its reason back. The rest is advice. |
| A finding without a `spec:` line isn't hard | Built into the review script | Moves out of the reviewer's brief into the step after it (your Q3 answer). |

❓ **Q6 - Do any of these verdicts look wrong to you?** If one does, the test is wrong, not the row.

➡️ They all look right to me. The dev-server row is the one I'd check, because it splits one rule into two.

---

## Q3: what the evidence does and doesn't say

The evidence does not say a reviewer finds every kind of bug. It says two separate things:

- **A bar on what to report** ("only high severity") mostly stops the reviewer from writing down what it found. It doesn't stop the finding. Your (a) fixes this.
- **What the reviewer is told to look for decides what it sees.** In the gorilla study, it depended on what observers were counting. In Shin's 2026 preprint, a focused instruction hid critical findings. That is your worry, and it's real. It also means even a slight push toward one kind of bug is a focus, and a focus costs seeing elsewhere, boundary or no boundary.

The fix the evidence supports is the one you named: more than one pass. In Shin's study, a second reviewer with an open brief recovered everything the focused one dropped.

❓ **Q7 - When you care most about one kind of problem, where does that care go?**
- (a) To a separate reviewer with that focus, alongside at least one reviewer whose brief stays open.
- (b) A light mention in the one brief.
- (c) Nowhere. The verifier sorts findings afterward.

➡️ (a). The principle for this ticket is that emphasis is focus, so it gets its own reader instead of tilting the open one. How many passes and which focuses is for the review system (Q9).

---

## Q4: the five mechanisms that exist today

1. **Ask first.** [AGENTS.md:26](AGENTS.md:26) and [template/AGENTS.md:20](template/AGENTS.md:20): "If one fights the task in front of you, say so loudly and get a sign-off before breaking it." A subagent has nobody to ask, and no text says what it should do instead.
2. **Follow the file, then explain.** This is your note at [template/AGENTS.md:16](template/AGENTS.md:16): "when this file and a vendored skill disagree with your instinct, follow the file and tell me why your instinct differed; that is how the rules here get better."
3. **Decide and record.** Where the spec says nothing, the agent makes the call and writes it under Provisional in `DECISIONS.md` so you can overrule it.
4. **Skip visibly.** poteto-mode: a playbook step you choose not to do stays in the list as `skip: <reason>`. The Feature playbook forbids this for delegation.
5. **Hand it back.**
   - Each writer flag must end `fixed:` or `accepted: <reason>`.
   - A writer that can't build a test case as written stops and reports it.
   - A hole in the design gets a dated line added to the ticket.

They conflict in two ways. Mechanisms 1 and 2 are opposite defaults: one asks before breaking a rule, the other complies and explains afterward. And 1 can't work for a subagent at all.

Your Q2 answer also creates a new collision with your note (mechanism 2). Q2 says the writer's knowledge about the route is something the reader may depart from. Your note says to follow copied professional patterns over instinct, because a copied professional idea beats a first-principles one. The two collide when the route knowledge is a copied pattern, such as a step in a vendored pstack playbook.

❓ **Q8a - Which governs a copied professional pattern?**
- (a) Your note. The reader follows it and reports the disagreement. The freedom from Q2 covers only route advice the factory's own agents wrote.
- (b) Q2. The reader may depart from anything, and reports it.

➡️ (a). It matches your 2024-09-24 ruling that upstream pstack's constraints stay and the factory's own model-written text is suspect until proven. The reported disagreement is how a bad upstream rule gets found and changed through `patches/`. The cost: the run-2 audit found some of the worst limits in vendored text, and (a) keeps them until someone patches them.

❓ **Q8b - Does this one rule replace the five?** It goes by situation:

| Situation | What the reader does | Replaces |
|---|---|---|
| Nothing was said | Decides, and records it so you can overrule | Keeps 3 |
| The reader sees a better route than the factory's own advice | Takes it, and says so in its report | Widens 4, and covers 2 for the factory's own text |
| A copied professional pattern seems wrong | Per Q8a | 2 |
| A binding rule fights the goal, in the session you type into | Asks you first | Keeps 1 |
| The same, in a subagent with nobody to ask | Stops that part, reports to whoever owns the rule, does the rest | Widens 5 |
| In every situation | Never shrinks the goal to fit a rule | New |

Every report carries one line: where the reader departed and why, or "none". It's stated as a fact the report includes, not as an invitation to depart, because assigned dissent makes readers contrary rather than better.

➡️ Yes.

---

## Q5: your answer, played back

- **In `safe`** (that's the first mode's name), budget never affects how work is done. It is only measured afterward.
- **In `eco` and Let It Rip**, a budget you set is first discussed with you to settle how much it weighs. Let It Rip adds wall-clock time as a second budget, under the same rule.
- **When in doubt, budget stays out of the brief.** If it seems important and nobody can ask you, it goes in as information, never as a limit. A binding budget means you approved it.
- **A goal for the overall effort isn't a rule for each reader**, and it never overrides process you made required.

❓ **Q8c - Did I get that right? And should I post your budget words on the map "Design Let It Rip as the third mode"**, since they set a rule that map has to design around?

➡️ Yes to both.

---

## The review system

❓ **Q9 - Where does "design the factory's own review system" go?** You described what it needs: several passes, better briefs, measuring missed bugs and not just false positives, and moving off `interrogate`'s leading prompts.
- (a) Its own map, charted later. This map records the boundary: review briefs get this map's writing standard, and the review process itself is the other map's job.
- (b) Fog in this map's Not yet specified.
- (c) A ticket in this map.

➡️ (a). This map ends in a plan for how agents write. How many passes and which reviewers is process design, beyond that endpoint. Your words from Q3 would open the new map.

---

## Your Q2 point, pinned

I'll send your micro-genre idea to the ticket "Decide how we'll know the writing works" as an experiment, and to the ticket "Decide what the writing standard is and what carries it" as a design input. The research note has no study of it.

One thought to add: a dense term pulls its whole cluster, including norms you didn't ask for. "Code review" probably pulls the industry norm that false positives are the worst sin, which is the exact norm behind your 50%-missed complaint. So a term is a pull, like a list, and needs the same care.