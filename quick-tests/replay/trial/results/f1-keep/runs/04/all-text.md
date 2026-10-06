Posting your answers to the ticket was declined, so I haven't posted anything. They're saved word for word in my scratchpad. Should I post them to the ticket? I'd want to, because your Q2, Q3 and Q5 answers bear on other tickets too.

Here's where your answers leave things, followed by round two.

**Settled**
- **Q1: (c).** A rule binds the reader only if it states the task itself and its owner made it binding. Below I walk through cases so you can check the test against your intuition, not just against my wording.
- **Q2: (b).** What the writer knows about how to do the task goes in as a resource with its reason, never as an order. I'm pinning two of your points for later:
  - The more rules a brief carries, the fewer get followed.
  - Your micro-genre idea: one term that already carries most of a cluster of rules could replace listing them, with only the exceptions spelled out. That's an experiment, so it belongs to "Decide how we'll know the writing works". As a writing technique it belongs to "Decide what the writing standard is and what carries it".
- **Q3: (a).** On your worry, I need to correct what I implied. The evidence shows that a *reporting bar* changes what gets reported, not what gets found. It does **not** show that a reviewer finds every kind of bug. Your worry is a different effect: focus. A reviewer that drifts into edge cases can walk past the bug you wanted. The gorilla studies and Shin's preprint say focus really does decide what gets seen. So your worry stands, and Q8 below takes it up.
- **Q5.** Here's how I read your answer:
  - In `safe`, a budget never shapes the work. It's only measured afterward.
  - In `eco` and Let It Rip, any budget you set gets an interview about how binding it is before it goes into a brief. Wall-clock time in Let It Rip works the same way.
  - When in doubt, a budget isn't communicated at all.
  - If it seems important and there's no chance to ask, it goes in as information, not as a limit.
  - A budget is written as binding only with your approval.

  Your story about "cut token burn in half" turning into a closing requirement is the same failure as Q3: a prediction quietly became the goal. When this ticket resolves, I'll link your answer from the Let It Rip map and the efficiency map. Tell me if I've misread any of it.

---

❓ **Q4 - One way to depart, in place of five.** These are the five mechanisms the factory has today:

1. **Ask first.** [AGENTS.md:26](AGENTS.md:26) and [template/AGENTS.md:20](template/AGENTS.md:20) say: "If a rule fights the task in front of you, say so loudly and get a sign-off before breaking it." That's copied from Theo. Nothing says how a subagent with no human gets a sign-off.
2. **Obey first, explain later.** [template/AGENTS.md:16](template/AGENTS.md:16): "when this file and a vendored skill disagree with your instinct, follow the file and tell me why your instinct differed." This is the opposite default to #1.
3. **Decide and record it.** Where the spec is silent, the agent makes the call and logs a Provisional row in DECISIONS for you to overrule. [MANUAL.md:168](docs/knowledge/core/MANUAL.md:168) also says to re-read PHILOSOPHY "when a rule fights you".
4. **Skip with a reason.** pstack lets a step be dropped with a visible `skip: <reason>` line ([poteto-mode/SKILL.md:113](template/.agents/skills/poteto-mode/SKILL.md:113)). Delegation is excluded: "no skip-with-reason escape" ([feature.md:12](template/.agents/skills/poteto-mode/playbooks/feature.md:12)).
5. **Stop and hand the problem back.** A writer that can't build a test cell as written stops and reports the cell, without filling it in. Each writer flag must end `fixed: <sha>` or `accepted: <reason>`, and a script refuses the review otherwise. A design hole amends the ticket with a dated line.

The conflict: #1 says ask before breaking, #2 says obey and complain afterward, #3 and #4 say act and leave a visible record, and #5 says stop.

My proposal maps onto them like this:
- **The route**, which isn't binding, gets #3/#4's shape: act on your own judgment, and the report always says where you departed and why, or that you didn't.
- **A binding rule** that fights the goal gets #5's shape: stop that part, report to whoever owns the rule, and carry on with the rest.
- #1 survives only where a human is actually present to sign off.
- #2 goes. "Obey even when you think it's wrong" is exactly the deference the research warns about.

➡️ Adopt that.

---

❓ **Q6 - Q1 in practice: do these verdicts match your gut?** These six cases illustrate the test. They don't bound it. For each I give my verdict under (c); tell me where yours differs.

1. **"Never push to main."** Merging is yours, so it's about the task and you own it. **Binds.** The guard hook holds it either way.
2. **"Read only the diff" in a review brief.** It's about the route, and nobody owns it: a lane added it to save cost. **Doesn't bind.** It goes.
3. **"The orchestrator never writes the code."** It's about the route, but you set it, with evidence, and a hook holds it. **Binds**, because it's yours.
4. **`knowledge`'s "never read more than 150 lines in one call."** It's about the route, it has no recorded reason, and nobody owns it. **Doesn't bind.** It either becomes advice with a reason or goes.
5. **"Subagents never launch their own dev servers."** Two subagents on one machine would fight over ports and processes that neither of them owns, so this is "not yours to decide" territory. **Binds**, but the reason Theo gave was dropped when it was adopted, so it has to come back.
6. **The review's `spec:` gate: no ticket line cited, not a bug.** It's a bar on what counts as done. Under Q3 it **moves to the filter step**: the reviewer reports everything, and the gate sorts afterward.

➡️ Those verdicts. If any one feels wrong to you, that's where the test needs another look.

---

❓ **Q7 - How is a binding rule worded?** The research gives three things to apply:
- **Plain wording.** Current Claude over-applies rules written in capitals or with "CRITICAL".
- **The reason, stated with the rule.** Readers apply a rule more sensibly when they know why it exists.
- **What to do instead.** A bare "don't" keeps the forbidden idea in play and leaves the reader to land on some other fixed default.

Where a hook holds the rule, its refusal message arrives at the moment it matters, so the message should carry the reason and the way forward. The git guard already does this: "Use --force-with-lease on your own branch, or ask." Where the rule lives and how it reaches the writer is the ticket "Decide where each piece lives and when it reaches the writer", so it's not decided here.

➡️ All three for every binding rule, plus a reason and a way forward in every hook refusal.

---

❓ **Q8 - What happens to a writer's specific worry?** This is your Q3 worry: "especially watch for X". By Q2 it's information, not a rule. But for a reader whose job is open search, information about what to look for acts as a focus. That's the gorilla effect, and it could produce exactly the miss you fear. The options:
- (a) The worry goes in the brief as information with its reason, and the brief tells the reader the worry is not the whole job.
- (b) The open reader gets the goal without the worry. The worry goes to a second, focused reader, or to the filter step, and both report.
- (c) The worry is left out.

➡️ (b) wherever there's a second reader, and (a) only when there's just one. This is the "multiple passes" you described. It's also a pattern beyond review, since research lanes face the same problem.

---

❓ **Q9 - Where does the review system you described belong?** That's the spec-reviewer finding mostly bugs, `interrogate` covering more but also leading, and "no false positives" hiding a 50% miss rate. This map's destination is the *writing*: how briefs, templates and rules are worded and where they live. Redesigning review itself means deciding how many passes, which lanes, a verifier, and measuring recall on planted bugs. That's process, not writing. "Prototype brief templates for the recurring lane jobs" covers the review *briefs*. Among the open tickets I found related review work ("Choose each tier's review round count from the clean measurement", "Eval the judge and trail-review models the way #103 evals reviewers"), but no ticket redesigns the whole system. The options:
- (a) Add it to this map as a ticket.
- (b) Rule it out of scope here, and open it as its own wayfinder map that inherits this map's decisions.
- (c) Leave it in fog until the template ticket gets there.

➡️ (b). By your own reckoning, review is the most important step. It deserves its own destination, and it should start from what this map decides about writing. I'd add one line to this map's Out of scope linking the new map, with your Q3 words quoted in it.