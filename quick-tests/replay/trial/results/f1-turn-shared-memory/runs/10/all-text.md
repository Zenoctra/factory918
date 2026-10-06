I tried to post your answers word for word as a comment on the ticket, and the post was declined. Your Q2 point about dense terms and your Q5 budget rule are both in my memory already. Do you still want them on the ticket?

**Q2 and Q5 are settled as you answered them.** One correction on Q3 before the round. I told you a bar changes what gets reported, not what gets found. That holds for bars. Your worry is about something else: focus. The research says your worry is real.

- **A bar** ("only report high severity"): the reader finds the bug and keeps quiet about it. Your answer (a) fixes this, because a separate step applies the bar.
- **A focus** ("look especially at input edge cases"): the reader actually misses what's outside it. The gorilla study shows this, and so does the one model study. Answer (a) doesn't fix it, and a "slight push" toward certain bug types is exactly this kind of focus.

What fixed it in that model study was a second reviewer with an open brief, which recovered everything the focused one missed. That supports your instinct: several fresh passes, at least one of them open, then a verifier to sort what they found. Your point about 50% of planted bugs going unfound is the same point. The measure should be how many real bugs get found (recall), not how few false alarms get raised. Where that review work lives is Q7.

---

❓ **Q1 - What binds, in practice**: Ask two questions of any rule.

1. Does it say **what the job is** (what you want, when it's done, whose call something is), or **how to do the work**?
2. Did **the person whose call it is** actually say it?

A rule binds only if it's about the job **and** that person said it. Anything else is advice that goes in with its reason, or it gets cut. Some real rules run through the test:

| Rule | About the job? | Said by whose call it is? | Result |
|---|---|---|---|
| Never push to main | Yes: merging is your call | Yes: you, in AGENTS.md | Binds |
| Don't edit `src/auth/`; another subagent is in it | Yes: whose files these are right now | Yes: the orchestrator assigned the files | Binds |
| The orchestrator never writes the code | Borderline. It reads like how to work, but it really says who does which part | Yes: you, with evidence, held by a hook | Binds. This is the hardest case: it passes only because it divides the work |
| Read only the diff | No: how to work | No: an orchestrator's guess | Doesn't bind. At most "the change is in these files" as a fact |
| Only report high-severity bugs | It bounds how the job finishes | — | Your Q3: moves to a filter step after the reader |
| Cut token burn in half | Only if you made it the goal | Only if you approved it | Your Q5: never binds unless you said so |

➡️ Confirm that this is what you meant by (c). If the third row feels wrong to you, that's where the test needs more work.

---

❓ **Q4 - Departing from a rule (the five mechanisms, named this time)**: The factory currently tells an agent five different things about what to do when a rule gets in its way:

1. **Ask first.** [AGENTS.md:26](AGENTS.md:26): "say so loudly and get a sign-off before breaking it." A subagent has nobody to ask, and I found no record of this ever being used.
2. **Obey first, explain later.** [template/AGENTS.md:16](template/AGENTS.md:16): "follow the file and tell me why your instinct differed."
3. **Decide and record.** Where the spec says nothing, the agent makes the call and writes a Provisional row in DECISIONS.md for you to overrule.
4. **Skip visibly.** poteto-mode lets a step be skipped with a written `skip: <reason>`, except delegation, where skipping is banned.
5. **Stop and hand back.** A writer that can't build a test case as written stops and reports it, and every writer flag must end as `fixed` or `accepted: <reason>`.

They conflict. (1) says ask before acting, (2) says act and explain afterward, (3) and (4) say act and record, and (5) says stop. (1) also fights the standing rule "never block on the human for reversible work."

➡️ Replace all five with two cases:
- **Advice about the route.** The reader uses its own judgment, like (3) and (4). Its report always says where it went another way and why, or that it didn't.
- **A binding rule that fights the goal.**
  - In the conversation with you: ask, like (1), since you're there.
  - In a subagent: stop that part, report to whoever owns the rule, and carry on with the rest, like (5).
  - Never shrink the goal to fit the rule.

That drops (2): once advice no longer binds, "obey, then explain" has nothing left to cover.

---

❓ **Q6 - How a binding rule is written and enforced**: The research says three things here:
- Shouty wording ("CRITICAL", "MUST") makes current Claude apply a rule too broadly.
- A bare "don't" keeps the forbidden idea in mind without saying what to do instead.
- A reminder at the moment it's needed works far better than a standing instruction.

Your Q2 note adds a fourth: every extra rule costs attention. Today most binding rules are repeated in prose and also enforced by a hook.

- (a) Prose only: state each rule plainly, as what to do, with its reason.
- (b) Where a hook can enforce a rule, the hook's refusal message carries the reason and a way forward, and the prose names the rule in one line.
- (c) Keep restating everything everywhere, as now.

➡️ (b). Keep the one line of prose. The ledger shows subagents lost turns hitting a guard they didn't know existed.

---

❓ **Q7 - Where the review system goes**: Review briefs are inside this map's scope ("templates for the recurring lane jobs"). A whole review process is bigger than writing: how many passes, which ones are open, the verifier, and measuring recall on planted bugs. The options:

- (a) Add it now to this map's "Not yet specified" section, in your words, and decide whether it becomes its own map once the ticket "Prototype brief templates for the recurring lane jobs" is worked.
- (b) Open a separate map for it now.
- (c) Make it a ticket on this map now.

➡️ (a). It keeps your words safe without guessing the shape too early, and the template work will show where writing ends and process begins. This is an edit to the map on GitHub, so I'll wait for your yes before making it.