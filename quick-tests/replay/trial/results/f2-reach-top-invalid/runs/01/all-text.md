The background search finished. Your answers to Q1–Q5 are still open, and nothing below needs them first. Here is what it found and how it changes my recommendations.

**For Q1 (what makes a rule binding).** Some rules about method clearly did good:
- The mandatory trail review caught an owner's error in 3 of 3 runs.
- Agents broke the delegation rule while it was prose only, and it held once a hook enforced it.
- A lane skipped a design step on its own judgment, and a hook bug then survived four review rounds.

You or a ticket set all of these, and each has a recorded reason. That supports the ownership half of my recommendation. Under the ownership test, every one of them can stay binding.

Every limit that did harm was added by a subagent to save cost, and no ticket asked for any of them: "read nothing, run nothing", "under 400 words" and "zero items is expected". The worst single line is still live in the pstack wrapper: "Execute only the task and path scope the parent assigns."

**For Q2 (route knowledge, with its reason).** Many rules carry no reason. Examples are "never an arena", the 150-line read cap in `knowledge`, and "Subagents never launch their own dev servers", whose reason was dropped when we adopted Theo's line.

The research branch for the wording research ticket already has a report. It finds that specific steps help on simple tasks and for beginners, and hurt on complex work. It also separates two things: a writer holding back what it volunteers, and a writer limiting what the reader may go and find. No study tests a limit on strategy as such. That supports (b): route knowledge offered with its reason, never as an order.

**For Q3 (when a binding rule fights the goal).** This is the biggest finding. The factory has five ways to depart from a rule, and they disagree with each other:

1. **Say so loudly and get a sign-off.** This is in both AGENTS files and nowhere else. No text says how a subagent gets that sign-off, and it pulls against "never block on the human".
2. **"Follow the file and tell me why your instinct differed."** This is the template, `template/AGENTS.md:16`. It defaults to complying, the opposite of mechanism 1.
3. **A visible `skip: <reason>`.** This is upstream pstack's, and `feature.md` turns it off for delegation.
4. **Stop and report.** A writer that can't implement a cell as written stops and reports it. The design-hole path works the same way.
5. **Record a Provisional row** in `DECISIONS.md` for you to overrule.

No audit has looked at these. So Q3 is really two questions: what the reader does, and whether these five become one rule. I'd still pick (a), stop that part and report it, and I'd make it the single rule that replaces 1 and 2. I'd keep 3 to 5 as the ways a departure gets recorded.

**For Q4 and Q5, nothing new.** The cost-driven limits were added for cost without anyone asking, which is the failure both recommendations are meant to block.

**One more question for a later round.** It depends on Q1, so it waits. `PHILOSOPHY.md` currently leans the other way:
- "follow a script rather than improvising" (`PHILOSOPHY.md:23`);
- push every rule to the strongest rung, where prose can't override it (belief 3);
- prefer a copied pattern over a first-principles idea (belief 7).

Whatever Q1 settles, the philosophy has to say it too.

**Two side notes:**
- The run-2 constraints audit sorted limits with the old protect-the-world split, and its brief said "do not propose new constraints". Its list of about 45 lines to delete or replace has mostly not been applied. Whether to redo it under the new test belongs to the ticket "Decide the scope and order of reworking existing files".
- `MANUAL.md:168` still says "twelve ordered beliefs", but `PHILOSOPHY.md` has eleven since ecdb732. I'll file a quick ticket unless you'd rather fold it into something.

I'll take your answers to Q1–Q5 whenever you're ready.