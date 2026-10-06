Posting your answers to the ticket as a comment was declined, so I haven't put them anywhere public. Unless you tell me to post them now, they'll go word for word into the ticket's resolution comment. The two memories, budgets and which rules bind, already match your answers.

## Q1 in practice

Think of hiring a contractor to build a deck.

- **What's wanted:** a deck, here.
- **What done means:** it holds twenty people and passes inspection.
- **What isn't theirs to decide:** they don't touch the neighbor's fence, and they don't sign anything in your name.
- **What you don't tell them:** which saw to use, or what order to cut the boards in.
- **What you know that might help:** if the boards warped last time because they weren't treated, you tell them that, with the reason, and they decide what to do about it.
- **Who can add a "must":** only you. A foreman passing your order to a subcontractor can't invent new musts about how to cut.

Here is the same test applied to six factory rules:

| Rule | Under (c) | Why |
|---|---|---|
| Never push to `main` | Binds | Merging is your decision, and you set the rule. |
| The orchestrator never writes the code itself | Binds | You made a separate writer part of what done means. |
| An orchestrator writes "read only the diff" | Doesn't bind | It's the orchestrator's guess about the route. It becomes "the diff is here, the ticket is there", and the reviewer reads whatever it wants. |
| "Run `git` as two plain commands, because the worktree guard refuses `$(...)`" | Information | It's route knowledge with a reason (Q2). The reader follows it because it's right, not because it's ordered to. |
| "Only report high-severity issues" | Moves out of the brief | It's a bar on finishing, so it becomes a later filter step (Q3). |
| A model writes "cut token burn in half" from a prediction | Doesn't bind | Nobody who owns that goal said so (Q5). |

A correction to my last round: I said the delegation rule binds "because you made it bind, not because of what it is about." That contradicts (c). The accurate version uses your own Q5 words, "specific processes that are required." A process you require becomes part of what done means. That is why it binds. An orchestrator can't do the same with its own guess about the route.

## Q2, your point about dense terms

I'll add this to the map as an open question for two tickets: "Decide how we'll know the writing works" and "Decide what the writing standard is and what carries it". The hypothesis has three parts:

- One accurate dense term may carry many rules at once, the way a micro-genre name carries most of a song's style.
- Explicit rules then cover only what the term doesn't carry.
- We measure how many explicit rules get followed, with and without the term.

The research found the cost of many instructions: with 500 at once, the best model followed 68%. It found nothing on dense terms, so this would be our own experiment. It has a risk you already named: a dense term brings its whole cluster, including the parts you don't want.

## Q3, your worry

I overstated the evidence, and your worry is right. The evidence says a reporting bar changes what gets **reported**, not what gets **found**. It does not say an open reviewer finds every kind of bug. The gorilla studies show that whatever the reader is paying attention to decides what it sees. A reviewer's own habits are a focus too: models already converge on similar answers 71–82% of the time. So (a) fixes the bar. It does nothing for coverage.

Coverage comes from several passes. Shin's open-ended second reviewer recovered everything the narrow one dropped. Your "slight push" would be information with a reason, such as "the bugs that hurt us most were X, because...". The list research warns, though, that naming a bug type pulls attention toward it and away from the rest: four listed problems went from 2% of answers to 60%. So if a push is used, it belongs in a pass of its own, never in the open pass. That is a design question for the review system (Q7 below). Your 50% planted-bug point belongs with the ticket "Decide how we'll know the writing works": measure recall against known bugs, not only false positives.

## Q5

Recorded. Your "Safety Mode" is the `safe` tier. Your Let It Rip point about wall-clock time is also a decision for the map "Design Let It Rip as the third mode". I'll link it there when this ticket resolves.

---

❓ **Q4 - What happens when the reader departs from the route, or a binding rule fights the goal?** Here are the five mechanisms that exist today. Two of them are your own words, in "A note from Manuel" in the template's AGENTS.md.

1. **Say so loudly and get a sign-off first.** This is your note at [template/AGENTS.md:20](template/AGENTS.md:20), adapted from Theo, and the factory's own [AGENTS.md:26](AGENTS.md:26). A subagent has nobody to sign off. Your note's own "I believe in not blocking on the human" pulls against it.
2. **Follow the file, then tell me why your instinct differed.** Also your note, [template/AGENTS.md:16](template/AGENTS.md:16). The reader complies first and reports afterward.
3. **Where the spec is silent, decide and record a Provisional decision you can overrule.** This comes from the philosophy, DECISIONS and the Ticket playbook. It covers gaps where no rule exists, not conflicts with a rule.
4. **`skip: <reason>`.** pstack's poteto-mode: a skipped step stays in the list with its reason, and silent skipping is not allowed. The Feature playbook switches this off for delegation.
5. **Send it back to the owner.** A writer's concerns about its own work must each end `fixed:` or `accepted: <reason>` before review. A writer that can't implement a test case as written stops and reports it. A design hole amends the ticket. Criteria that can't be tested go back to you.

My proposal, more precisely than "replace all five":

- **Keep 3 and 5.** They do other jobs (gaps, and a wrong artifact), and 5 is already the shape I want.
- **Merge 1, 2 and 4** into one rule with two branches:
  - **Route:** the reader uses its judgment. Its report always says where it took a different route and why, or that it took none. This is mechanism 4's `skip:` line made general.
  - **A binding rule that fights the goal:** in your own session, ask you first, because you're there. In a subagent, stop that part, report the conflict to the rule's owner, and carry on with the rest.
  - **Either way:** the reader never shrinks the goal to fit a rule.
- **Your note changes.** Line 20 narrows to binding rules. Line 16's "follow the file" applies only to what in the file binds. For everything else, the reader uses its judgment and says where it differed. Your reason for the line, "that is how the rules here get better," still holds. That's your text, so it's your call.

➡️ The proposal above, with the edits to your note written as a draft you approve. They wouldn't be rewritten for you.

---

❓ **Q6 - Do the six verdicts in the table above match what you'd rule?**

➡️ Yes. Correct any you'd rule differently. Those are the cases where the test still has a gap.

---

❓ **Q7 - Where does the review system get designed?** Your Q3 answer describes something bigger than how review briefs are worded:

- several passes;
- what each pass looks at;
- whether any pass gets a push;
- a verifier that rates findings separately;
- measuring recall against planted bugs;
- `interrogate`'s wider range of concerns, and its own leading.

This map covers how review briefs are written, through "Prototype brief templates for the recurring lane jobs". Two related tickets already exist outside the map: "Choose each tier's review round count from the clean measurement" and "Eval the judge and trail-review models the way #103 evals reviewers".

- (a) A new map, "Design the factory's own review system", that takes this map's decisions as input.
- (b) A ticket on this map.
- (c) Fold it into the brief-templates prototype.

➡️ (a). A review system is a process design, and this map's Destination is the writing. A ticket here would either outgrow the map or squeeze the design into wording.

---

❓ **Q8 - How does a reader tell a binding rule from information?** If route knowledge is information and some rules bind, the reader has to be able to tell them apart. Current Claude reads literally, so anything that looks like an order gets treated as one. The research gives three findings on wording:

- A rule given with its reason is followed better and more flexibly.
- Emphatic wording ("NEVER", "CRITICAL") gets applied too broadly.
- A bare "don't" keeps the idea active without saying what to do instead.

The options:

- (a) Briefs keep two visibly separate parts. One is "not yours to decide", where each rule is stated plainly with its owner and reason, says what to do instead, and has no emphasis. The other is "what I know that may help".
- (b) One body of text, where the wording alone marks the difference.
- (c) Binding rules stay out of briefs entirely, and live only in AGENTS.md and the hooks.

➡️ (a). The separation is the signal, so information can't be misread as an order. Which binding rules a given brief needs to repeat, and which a hook already holds at the moment it matters, is a placement question for the ticket "Decide where each piece lives and when it reaches the writer".