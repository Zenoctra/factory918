Picking up where we left off. Your answers to Q2, Q3 and Q5 are settled. Before round two I owe you three things: a correction on Q3, a concrete version of Q1, and the five mechanisms I left out of Q4.

**Recorded so far**
- **Q5:** it's now a standing memory. In `safe`, a budget never shapes the work and is only measured afterwards. In `eco` and Let It Rip, you're asked how binding a budget is before it goes into any brief. When in doubt, it's left out. If it can't be asked about, it goes in as information, never as a limit.
- **Q2, your micro-genre point:** I'll put it into "Decide how we'll know the writing works" as an experiment to run. One precise term may carry many rules, and we'd test whether some of those rules still need stating on their own. It also goes into "Decide what the writing standard is and what carries it" as a principle to test.
- **Your answers will be posted verbatim** on the ticket when it resolves, the same way as on the map.

**A correction on Q3.** You took me to mean the evidence shows both kinds of bug get found anyway. It shows something narrower:
- A **bar** ("only report high severity") changes what gets reported, not what gets found.
- A **focus** ("look for X") does narrow what gets seen. That's the gorilla study and Shin's preprint.

So your worry is real, and it applies to a slight push as much as to a strong one. In Shin's study, wording didn't fix the narrowing. A second reviewer with an open brief did. That's structure, and it's Q8 below.

---

### Q1 in practice

Here is what (c) means when an agent looks at a rule. It asks two questions.

1. **Who set this rule?** You, AGENTS.md, or the ticket can set a binding rule. So can an agent, but only about something that agent actually controls, such as "these files are being edited by another lane right now". Anything an agent made up about *how* to do the job is advice.
2. **Did the person who set it mean it as required?** Your delegation rule and the mandatory trail review are processes you required, so they bind. A prediction you once made, like "this might halve token burn", doesn't.

If either answer is unclear, the rule is advice and not a wall.

That is your Q5 budget answer, made general. A budget binds only if you set it and said it's binding, and when in doubt it's information. Every rule works the same way.

My earlier "what the rule is about" test turned out to be unnecessary. Processes you require bind even though they're about *how*.

---

❓ **Q4 - One mechanism in place of five.** These are the five mechanisms that exist today:

1. **"Say so loudly and get a sign-off before breaking it."** [AGENTS.md:26](AGENTS.md:26) and [template/AGENTS.md:20](template/AGENTS.md:20). A subagent has nobody to sign off. It also pulls against "never block on the human" two lines earlier.
2. **"Follow the file and tell me why your instinct differed."** [template/AGENTS.md:16](template/AGENTS.md:16). This obeys first and explains afterward, the opposite default to mechanism 1.
3. **"Where the spec is silent, decide and record a Provisional decision Manuel can overrule."** DECISIONS and the Ticket playbook. This covers gaps, not conflicts.
4. **"Keep a skipped step in the list with `skip: <reason>`."** poteto-mode, vendored from pstack. [feature.md:12](template/.agents/skills/poteto-mode/playbooks/feature.md:12) switches it off for delegation.
5. **Hand it back up.**
   - A writer's flags must end in `fixed:` or `accepted: <reason>`.
   - A writer that can't implement a test cell stops and reports it.
   - A design hole amends the ticket.
   - Some freehand briefs ask "say where you deviate and why".

The proposal, mapped onto these:
- **Departing from advice:** the reader uses its judgment. Its report always says where it took a different route and why, or says it took none. This replaces mechanism 4 and the freehand "deviate" asks, and keeps mechanism 2's "tell me why" without the "follow first".
- **A binding rule fights the goal:** the reader stops that part, reports the conflict to whoever set the rule, and carries on with the rest. In your own window, that's mechanism 1 as it stands, because you are right there to sign off. For a subagent, the report goes to the orchestrator, which brings it to you.
- **Gaps:** mechanism 3 stays as it is, since it covers silence, not conflict.
- **Mechanism 5** already works this way and stays.
- **The reader never shrinks the goal to fit a rule.**

Changing mechanism 4 means a patch to a vendored skill. That's a step for later tickets, not a reason against the change.

➡️ Adopt it as above.

---

❓ **Q6 - Does Q1 sort these real rules correctly?** This is a test of the two questions. Mark any row you'd call differently.

| Rule today | Who set it | Comes out as |
|---|---|---|
| Never push to main (hook) | You | Binds |
| The orchestrator never writes the code (hook) | You | Binds |
| The trail review is mandatory | You | Binds |
| `spec-review`'s `spec:` gate: no ticket line cited means not a hard bug | An agent, for #32 | A bar on finishing, so by Q3 it moves to the filter step. The reviewer reports everything, and the citation is filled in where one exists. |
| `knowledge`: never read more than 150 lines in one call | An agent, no recorded reason | Advice. Kept only if a reason turns up. |
| pstack wrapper: "Execute only the task and path scope the parent assigns" | Upstream | The part about files another lane owns stays as a fact. The rest is advice. |
| Subagents never launch their own dev servers | Theo's rule, which you adopted. His reason was dropped. | **Your call:** a required process, or advice? |

➡️ The rows as shown. For the dev-server row I'd say binding, with its reason restored: two lanes starting servers collide on ports and state. But you adopted it, so it's your call.

---

❓ **Q7 - How is a binding rule worded and held?** The research and your rule-count point both say fewer, plainer rules get followed better.

- **Wording:** plain, with the reason, and saying what to do rather than only what not to do. No capitals or "CRITICAL": current Claude over-applies emphasis.
- **Where a hook holds the rule:** its refusal message carries the reason and the way forward, since it arrives at the moment the rule matters. The prose names the rule once and points to the hook, rather than restating it in every brief. Each restatement takes attention from everything else.

➡️ Both as stated.

---

❓ **Q8 - How do review lanes cover the kinds of bug you most want found?** Your worry was a reviewer spending itself on unhappy-path input edge cases and reading past the bugs you care about.

The options:
- (a) A slight push in the brief: "we're especially wary of X."
- (b) No push. Coverage comes from structure: several reviewers with open briefs, each reporting everything, and a separate step that classifies and ranks what comes back.

Against (a): naming a kind pulls attention toward it and away from the rest. Part-list cueing is the human version of that, and Shin's preprint is the model version.

➡️ (b). The design of those passes belongs to the review work in Q9.

---

❓ **Q9 - Where does "a review system of our own" go?** You described it as multiple passes, briefs written to this standard, measured by recall and not only false positives, and covering what both `interrogate` and `spec-review` cover today. This map's destination is how the factory writes. A review system is larger than that.

The options:
- (a) A ticket on this map.
- (b) Its own wayfinder map, which this map feeds with the writing standard and the review brief templates.
- (c) A line under this map's Not yet specified for now.

➡️ (b), with a line under Out of scope here that links to it. This map still covers review *briefs*, through "Prototype brief templates for the recurring lane jobs". I'd chart the new map only when you ask.