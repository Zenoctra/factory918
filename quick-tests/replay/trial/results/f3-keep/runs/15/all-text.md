Yes, the research changes the round. The biggest change is to my own Q1.

**My Q1 made the mistake you corrected.** It sorted rules into two kinds again: the task, which binds, and the route, which is free. Then it called one kind safe. The research's best-measured harms sit on the side I called safe:

- **A reporting bar is part of "what done means," and it's the strongest harm measured.** Radiologists who find one abnormality keep searching, but they hold back from reporting the second (Berbaum 2015). Anthropic reports the same of Claude: told "only report high-severity issues," it still finds the bugs and leaves them out of the report. The `spec:` gate is this case: a reviewer filed nothing on a PR that had four real bugs.
- **The task statement decides what gets seen.** In a 2026 preprint (Shin), a narrow task instruction stopped models reporting critical findings they reported otherwise. A separate critic with an open brief recovered every one.
- **A precise goal on a complex task makes people chase the target and learn less about the problem** (Vollmeyer 1996). A measure attached to a goal gets treated as the goal itself, which the research calls surrogation. Your P109 ruling is an example.

So no kind of rule is safe. The new Q1 asks about two properties every rule has instead.

**The research separates two things your examples mix.** One is what the writer volunteers. Holding back its own conclusions protects the reader's independence, and forensic science does this on purpose. The other is what the reader may go looking for, and no evidence supports limiting that. What the writer volunteers splits again:
- Facts about the project help a capable reader who's new to it (McNamara 1996).
- Step-by-step method hurts a capable reader. This is the "expertise reversal effect": d = −0.43 for experts across 60 studies.

**A way out of a rule only works if the reader notices it needs one.** Survey respondents asked for help on 4% of the occasions it was offered. Current models almost never ask on underspecified coding tasks. Claude 3.7 used a planted hint and mentioned it 25% of the time. A rule like "say so when a rule fights the task" waits for a reader that rarely notices.

**How firm this is.** Most model studies predate Opus 5.5. Anthropic's observations have no published numbers. No study tests a limit on how a model goes about a task directly. The human evidence predicts the harm, but nobody has measured it in our lanes. Q7 asks what to do about that.

My old Q5 on budgets is folded into Q2 and Q4. The options below are where I started, not the edge of what you can answer.

---

❓ **Q1 - Replace the sort with two properties.** The old test and my round-one Q1 both asked which kind of rule is safe. I'd replace that with two questions asked of every rule, whatever it's about:

1. **Who can lift it?** A rule is *binding* when the reader may not set it aside on its own judgment.
2. **How is it written?** Every rule, binding or not, carries its purpose and its reason.

Garfinkel and Suchman explain why the second applies to binding rules too. No instruction written in advance contains the situation it will meet. A plan is a resource for acting, not a specification of it. A binding rule will also meet a case nobody predicted, and its reason is what lets the reader see that and say so.

➡️ Adopt it. The rest of the ticket then decides who can bind (Q2), how each kind of text is written (Q3, Q4), and what happens when a rule fights the task (Q5).

---

❓ **Q2 - Who may make a rule binding?** The factory's own record:

- The rules about method that did good were yours, set with measured reasons. The trail review caught the owner's errors 3 of 3 times. The delegation rule held only once a hook enforced it.
- The ones that did harm were added by lanes for cost, with no ticket asking (#33, #93 and #107, per the audit). Or a lane turned your question into a rule: "a model extends the intent without it being written" ([ledger.md:19](docs/agents/ledger.md:19)).
- Binding rules also compete with each other. When a model is given many instructions at once, it follows fewer of them and favors the early ones.

➡️ Only whoever holds the authority the rule protects can make it binding:
- you;
- a ticket you approved;
- an orchestrator, but only for what it coordinates: who is writing which file right now, and where results go.

A time or token budget you set is binding. One an orchestrator picks is given as a fact the reader plans around, not as a limit. Anything else an orchestrator knows is offered, never bound.

---

❓ **Q3 - How is a binding rule written?**

- The same limit worded as control lowered children's creativity. Worded as information, it didn't (Koestner 1984). A reason, plus acknowledging the reader's view, improved how well people took rules on (Deci 1994).
- Anthropic says current Claude reads literally and over-applies emphatic wording like "CRITICAL: you MUST." It generalizes from the reason when one is given.
- A bare "never X" keeps X active and gives no alternative, so the model lands on some other fixed default.
- The git guard's message already does this well: "Use --force-with-lease on your own branch, or ask."

➡️ Plain wording with no emphasis. State what the rule protects and why, what to do instead, and who owns it. Where a rule must hold, use a hook, and let the prose carry the reason rather than repeat the order.

---

❓ **Q4 - What may the writer volunteer about doing the work, and how?** A writer often knows things the reader doesn't. The research treats three kinds differently:

- **Facts about the project or tools** that the reader couldn't easily find, such as "the worktree guard refuses git inside `$(...)`." A lane starting cold knows little about the project however capable it is, and readers who know little are helped when connections are spelled out.
- **Method:** the order of steps, which files to read first. It helps on simple tasks and hurts capable readers on complex ones.
- **The writer's own conclusions:** its suspicion about where the bug is, what earlier rounds found, how many problems it expects. These lead the reader:
  - Framing code as bug-free cut detection from 96% to 89% for Claude Opus 4.5, and to 4% for a small model.
  - Fingerprint experts reversed their own earlier conclusions when given case context.

  Holding these back limits nothing the reader may look for.

➡️ Give project facts with their reasons. Leave method out unless the task is simple; when it's included, write it as what the writer would try first and why. Keep the writer's conclusions out of any judging lane's brief. That last part is about leading rather than rules, so the ticket "Decide what the writing standard is and what carries it" may be its real home. Recording it here is enough for this ticket.

---

❓ **Q5 - How does the writing keep the goal and "done" from limiting the work?** The old test never reached this part. These are the measured cases, not the whole space:
- a reporting bar makes the reader hold back findings;
- a narrow task makes findings go unseen;
- a measure replaces the goal;
- tight output limits cut reasoning models' scores sharply (Sun 2025).

➡️ Three things:
- **State the goal as wide as it really is.** Write any focus as where to start and why, and say that what lies outside it is reportable.
- **Keep finding separate from filtering.** The reader reports everything it found, with its own weight on each. Any bar is applied afterwards by whoever owns it. This is Anthropic's own recommendation.
- **Every check carries the purpose it serves**, and the purpose wins when they disagree, as in P109.

The `spec:` gate is the test case: under this, the reviewer reports, and the filtering happens in a later step.

---

❓ **Q6 - What happens when a rule fights the task?** Today the factory has five mechanisms, and they conflict:
- say so loudly and get a sign-off first;
- follow the file, then explain;
- record a Provisional call;
- `skip: <reason>`;
- `accepted: <reason>`.

The research adds one finding: telling readers that checking a definition was *essential* rather than *available* raised how often they checked from 23% to 81%.

➡️ One mechanism replaces all five:
- **For a non-binding rule**, the reader departs when its judgment says to. Every report has a section naming each departure and its reason, written as an expected part of the report, not an option.
- **For a binding rule**, the reader stops that part, reports the conflict to the rule's owner, and carries on with the rest.
- **The reader never narrows the goal to fit a rule.**

In a live session with you, "say so loudly and get a sign-off" survives as the binding case, with the owner present.

---

❓ **Q7 - Decide now, or treat the decisions as a hypothesis?** Our case is untested on models: no study limits how a model goes about a task, nobody has run the illustrative-list experiment, and nothing has been measured on Opus 5.5. The human evidence and the factory's own audits all point the same way.

➡️ Decide now, as the standard's working position. Hand the ticket "Decide how we'll know the writing works" two experiments that would check it:
- the same open task with and without an illustrative list, counting what each run finds outside the list;
- a reviewer with and without a reporting bar, counting what each reports.

---

Q8 from round one, saying back the goal, has moved: I'd now hand it to the writing-standard ticket rather than decide it here. After this round settles, I'll rewrite my memory note that still states the old test.