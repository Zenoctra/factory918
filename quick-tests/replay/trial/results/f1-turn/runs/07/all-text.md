Saving your answers verbatim as a comment on the ticket was declined, so nothing is posted. Should they go on the ticket, or somewhere else? Until you say, they're only in this conversation.

Your Q4 complaint is fair: I asked you to approve a replacement for five things I never showed you. Below are Q1 explained with real rules, then the five mechanisms, then the new questions.

## Q1 in practice

The plain version: **a rule binds only when the person who owns that decision made it binding.**
- The goal, what "done" means and the limits are yours. Merging and pushing are limits.
- The route belongs to the reader, unless you take part of it back.
- An orchestrator writing a brief owns very little: mostly coordinating agents that run at the same time. It can pass your binding rules down and bind its own coordination. Anything else it writes about the route is information.

Here it is applied to rules the factory has:

| Rule | Who set it | Binds? | What happens to it |
|---|---|---|---|
| Never push to `main` | You | Yes | Stays. A hook holds it. |
| The orchestrator never writes the code | You, after it was broken | Yes, even though it's about the route | Stays. You took that part of the route back. |
| Don't edit these files, another agent is in them | The orchestrator, which owns that coordination | Yes | Stays, with the reason. |
| A reviewer reads only the diff | An orchestrator, to save cost; no ticket asked for it | No | Becomes information: where the diff, the ticket and related files are. |
| Never read more than 150 lines in one call (`knowledge` skill) | No recorded owner or reason | No | Information if it has a reason, otherwise deleted. |
| Cite a `spec:` line or it isn't a bug | A finishing bar | — | Moves to a filter step after the review (your Q3), whoever set it. |

Writing it plainly changed my (c) slightly. I had said a rule binds only when it is the right kind of rule and its owner made it binding. The delegation row shows that ownership alone decides. What a rule is about only tells you who normally owns it.

## The five mechanisms for departing from a rule

1. **Say so loudly and get a sign-off before breaking it.**
   - Where: [AGENTS.md:26](AGENTS.md:26) and [template/AGENTS.md:20](template/AGENTS.md:20).
   - Problems: a subagent has nobody to ask, and it sits two lines below "proceed on anything reversible".
2. **Follow the file, then tell me why your instinct differed.**
   - Where: [template/AGENTS.md:16](template/AGENTS.md:16).
   - It is the opposite default to 1: comply first, explain afterward.
3. **Where nothing was said, decide, and record a Provisional decision you can overrule.**
   - Where: [ticket.md:30](template/.agents/skills/poteto-mode/playbooks/ticket.md:30).
4. **Skip a playbook step only visibly, with `skip: <reason>`.**
   - Where: [poteto-mode SKILL.md:113](template/.agents/skills/poteto-mode/SKILL.md:113), from upstream pstack.
   - It is not allowed for delegation ([feature.md:12](template/.agents/skills/poteto-mode/playbooks/feature.md:12)).
5. **Send the problem back to whoever owns it.**
   - Every writer flag must end `fixed: <sha>` or `accepted: <reason>` before review starts ([spec-review SKILL.md:29](template/.agents/skills/spec-review/SKILL.md:29)).
   - A writer that can't implement a test cell stops and reports it rather than filling it in.

What each becomes under my proposal:
- **1** stays in the main window, where you're present: there, reporting the conflict to the owner is the sign-off. For a subagent, it becomes "stop that part, report the conflict, carry on with the rest".
- **2** goes. The file calls its own contents "good defaults", so they are route knowledge under your Q2. The reader uses its judgment and reports where it went its own way. Your reason for 2, "that is how the rules here get better", survives, because that departure report is what you'd read to improve the rules.
- **3** stays unchanged. It covers silence, not conflict.
- **4** becomes the general departure line, in the same shape. Delegation stays excepted because it is one of your binding rules.
- **5** stays. It is already the "report to the owner" form, working in specific places.

## What I took from Q2, Q3 and Q5

- **Q2, single terms that carry a whole cluster.** This fits the research: a term pulls in everything associated with it. That includes the parts you don't want, which is the same pull a list of examples has. So the experiment you describe should measure what the term drags in as well as what it covers. It belongs with the tickets on the standard and on measurement; I'll carry it there when this ticket closes.
- **Q3, your worry is half answered by the evidence.**
  - When the bar is on *reporting*, the evidence says the bugs still get found and then withheld. Your plan covers this: report everything, let a verifier sort.
  - When the brief puts the reader's *attention* somewhere, the evidence says it can miss other kinds entirely. That is the gorilla study. Reporting everything doesn't fix this.
  - The fix with evidence behind it is a second pass with an open brief.
  - Your "slight push" is a trade. A named kind of bug gets reminded and found more, and it crowds out what isn't named: 2% of answers became 60% once listed.
  - All of this belongs to the review design, which brings me to Q7.
- **Q5** is clear as you wrote it. Q8 asks about one extension your story suggests.

---

❓ **Q6 - Do you agree with the plain version of Q1?** A rule binds when its owner made it binding. The table's verdicts follow from that.

➡️ Yes, unless a row in the table looks wrong to you. A wrong row is the quickest way to find where the plain version breaks.

---

❓ **Q4 again - Should one mechanism replace the five, as mapped above?** The one mechanism has three parts:
- For route knowledge, the reader uses its judgment, and every report says where it took its own route and why, or that it took none.
- When a binding rule fights the goal, the reader stops that part, reports the conflict to the rule's owner, and carries on with the rest.
- The reader never narrows the goal to fit a rule.

➡️ Yes.

---

❓ **Q7 - Where does the review system go?** You described a review system of the factory's own: several passes, better briefs, and recall measured as well as false positives. That is process design, which goes beyond this map's destination of writing. The options:
- (a) Its own map, opened later. This map's briefs and templates feed it.
- (b) A ticket on this map.
- (c) Folded into the existing ticket "Prototype brief templates for the recurring lane jobs".

➡️ (a). Record it now under this map's Out of scope, with your words and a note that it is waiting for its own map. Your Q3 note goes there too: interrogate looks wider than spec-review, but even the vendored interrogate leads the witness.

---

❓ **Q8 - Does your budget rule cover any predicted number, not just budgets?** In your story, the model took a prediction ("this might halve token use"), made it a condition for closing the ticket, then cut required steps to hit it. The rule you gave for budgets would apply to any predicted number written into a ticket or brief: it is information, and it becomes a requirement only after you've been asked how much it matters and approved it.

➡️ Yes. The memory "principle over proxy" already holds part of this ("a derived criterion never overrides the principle"). This makes it a rule about writing, so the number never becomes a requirement in the first place.

---

❓ **Q9 - How is a rule that binds written and enforced?** The research gives three relevant findings:
- Current Claude over-applies emphatic wording ("MUST", capitals).
- A bare "don't" keeps the forbidden idea active and doesn't say what to do instead.
- A reminder that arrives at the moment of use works far better than a standing one.

The git guard already does the third: when it refuses, its message names a way forward ("Use --force-with-lease on your own branch, or ask").

➡️ Write each binding rule as one plain sentence: the rule, its reason, and what to do instead, with no emphasis. Where a hook can enforce it, the hook does, and its refusal message carries the reason and the way forward. A brief then mentions the rule only where the reader would plan its route around it, not in every brief.