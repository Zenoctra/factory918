Your answers to round one are saved word for word in my scratch folder. I'll post them on the ticket when it closes, the way the map keeps your other answers. Here's each one followed up, then round two.

## Q1 in practice

The test comes down to one question about each rule: **did someone with the authority to decide this say it must hold?**

- **You** decide what gets built, what merges, and how the factory works. So your rules bind, including rules about the route, like the delegation rule.
- **A ticket** carries your authority over what's wanted and how much is in scope.
- **An orchestrator** decides only what it hands out, such as which files each lane is working in. It has no say over how a reader does its job. When an orchestrator writes "read only the diff", that's its own guess about where the bugs are, so it goes in as information, not as a rule.

If a rule doesn't bind, it's something the writer knows. It's written as information with its reason, and the reader decides what to do with it.

| Rule | Who set it | Result |
|---|---|---|
| Never push to `main` | You: merging is yours | Binds. The git guard holds it |
| The orchestrator never writes the code; a lane does | You, with evidence | Binds. A hook holds it |
| Don't edit the files lane B is working in | The orchestrator, which handed them out | Binds |
| The ticket asks for X; don't redesign Y | The ticket, so you | Binds. If Y blocks X, the reader stops and reports |
| Read only the diff | The orchestrator, guessing | Doesn't bind. The brief says where the diff and ticket are; the reader reads what it wants |
| Look especially for SQL injection | The orchestrator | Doesn't bind (see Q3 below) |
| Use `vp test run`, not `npm test` | Nobody needs to: it's a fact about the tool | Information, with the reason |
| Cite a `spec:` line or it isn't a hard bug | A script | Moves to the filter step, by your Q3 answer |

## Q2

Pinned. Two places your micro-genre idea connects to the research:

- Anthropic says its models generalize from the reason behind a rule.
- A feature repeated in every item gets read as boilerplate.

Your idea goes further: one precise term might carry a whole cluster of rules, and you'd add only what that term wouldn't already bring. That can be tested. Two experiments:

- How many rules does a model actually follow, and where does following start to drop off?
- Does one term reproduce the behavior of the rules it's meant to replace? If not, which rules still need stating?

When this ticket closes, I'll add both to the ticket "Decide how we'll know the writing works", and add the idea to the map's notes as something every later decision should weigh.

## Q3, and your worry about it

I need to correct what I implied. The evidence separates two things:

- **A bar** ("only report severe bugs") changes what gets reported, not what gets found. Option (a) fixes that by moving the bar to a later step.
- **A focus** ("look especially for X") changes what gets *seen*. That's the gorilla study: the observers weren't failing to report the gorilla, they didn't see it.

Your "slight push" is a focus. The evidence says even a slight one costs whatever lies outside it.

Nor does the evidence say a single reviewer finds every type of bug. Every reviewer has blind spots. Different models give 71–82% similar answers to open questions, so a second model doesn't reliably cover the first one's blind spots either.

So your worry is real, and the fix belongs in the process, not in one brief's wording:

- One pass stays fully open.
- Each type you especially care about gets its own pass, where that focus is the job.
- A verifier sorts and rates everything afterwards.

In Shin's preprint, a separate open-ended critic recovered every finding the focused instruction had hidden. That's this structure. It also matches your point about review studies that report no false positives while missing half the planted bugs: the answer is more passes and better briefs, not one cleverer brief.

## Q4: the five mechanisms

When a rule fights the task, the factory gives five different answers today:

1. **Ask first.** "If a rule fights the task in front of you, say so loudly and get a sign-off before breaking it" ([AGENTS.md:26](AGENTS.md:26), [template/AGENTS.md:20](template/AGENTS.md:20)). It came from Theo. It works when you're in the session. A subagent has nobody to ask, and nothing says how it should get a sign-off. It also pulls against "never block on the human for reversible work", two lines above it in the template.
2. **Obey first, explain afterwards.** "Follow the file and tell me why your instinct differed" ([template/AGENTS.md:16](template/AGENTS.md:16)). That's the opposite default to number 1.
3. **Decide and record.** Where the spec is silent, the agent makes the call and writes a Provisional row in `DECISIONS.md` so you can overrule it. This covers gaps, not conflicts.
4. **Skip visibly.** pstack lets an agent skip a playbook step if it leaves a line `skip: <reason>`. Our feature playbook switches this off for delegation.
5. **Send it back up, step by step.** A writer that can't build a test cell as written stops and reports it. Writer flags must end `fixed:` or `accepted: <reason>`. A hole in the design gets a dated amendment on the ticket. Each of these is wired to one particular step.

My proposal against these:

- It **replaces 1 and 2**. They conflict, and 1 can't work in a subagent.
- It **generalizes 5**. When a binding rule fights the goal, the reader stops that part, reports to whoever owns the rule, and carries on with the rest. When you're in the session, "the rule's owner" is you, so 1 survives as that case.
- It **makes 4's visibility universal**. Every report says where the reader took a different route from what the writer suggested and why, or says it didn't.
- It **leaves 3 as it is**, because 3 is about silence, not conflict.
- In every case, the reader never shrinks the goal to fit a rule.

❓ **Q4 again**: one mechanism as above, replacing 1 and 2?

➡️ Yes.

## Q5

Here's how I read your answer. A correction on names: the first tier is `safe`, the other is `eco`, and Let It Rip is still being designed on its own map.

- **`safe`:** no budget ever reaches a brief or shapes the process. Tokens and time are measured afterwards, only to look for ways to optimize.
- **`eco` and Let It Rip:** a budget reaches a reader only after you've been asked how much it matters, and Let It Rip adds wall-clock time as a second budget. A budget never overrides a process you've required.
- **Always:** when in doubt, leave the budget out. If it seems important and nobody can ask you, it goes in as information. It's written as binding only if you approved that.

Please correct anything I've misread. I'll also leave pointers on the maps "Design Let It Rip as the third mode" and "Optimize token use and wall-clock time without losing reliability".

---

## Round two

❓ **Q6 - Check the table.** The table under Q1 above is the test applied to real cases. Is there any row where you'd decide differently?

➡️ If every row reads right to you, the test is settled.

---

❓ **Q7 - Does Q5's rule cover more than budgets?** Your token story wasn't really about a budget. A *prediction* ("this might halve the burn") was turned into a closing criterion without anyone asking you. It's the same failure as the "at most" list on the tier ticket, which you ruled "a prediction, not a constraint".

- (a) Generalize it: any number or outcome a writer predicts is information. It becomes a criterion only when you approve it.
- (b) Keep the rule to budgets.

➡️ (a). Budgets are just the most common case.

---

❓ **Q8 - How are binding rules worded and held?** The research has three findings here:

- Emphatic wording ("CRITICAL", "MUST") makes current Claude models over-apply a rule.
- A bare "don't" keeps the forbidden idea active and doesn't say what to do instead.
- Every added rule takes attention from the others.

The options:

- (a) A binding rule is written once, plainly, as what to do. It carries its reason and who set it. Where a hook can hold it, the hook's refusal message carries the reason and a way forward, and a brief points to the rule instead of restating it.
- (b) Restate binding rules in every brief, to be safe.
- (c) Leave the wording as it is today.

➡️ (a). The evidence that matters most: when the delegation rule lived only in prose, it was broken by an agent that knew it. A hook made it hold.

---

❓ **Q9 - Where does your review-system idea go?** No existing ticket designs a review system. The nearest ones are "Choose each tier's review round count from the clean measurement" and "Eval the judge and trail-review models the way #103 evals reviewers", and both tune the current process. This map's destination covers review *briefs*, through the template ticket, but not how review is built: how many passes, what each one looks at, and who verifies.

- (a) Note it in this map's "Not yet specified" now, and make it its own map once this map's writing decisions land, so it's built on them.
- (b) Widen this map to include it.
- (c) Open the new map now.

➡️ (a). Review is process design, larger than writing. Built after the writing standard, it starts with briefs that don't lead the witness.