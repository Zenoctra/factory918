I've saved your Q5 rule to my memory. I tried to post your answers verbatim to the ticket, as we did on the map, and the post was blocked. A copy is in my scratchpad; tell me if you want it posted.

**Q5 is settled as you put it**, and it's broader than this ticket:
- In `safe`, a budget never shapes the process. Cost is only measured afterward.
- In `eco` and Let It Rip, a budget counts only once you set one. You're asked how binding it is before it goes into any brief.
- Let It Rip adds wall clock as a second budget, under the same rule.
- When in doubt, leave the budget out. If it seems important and nobody can ask you, it goes in as information, never as a limit.
- A predicted gain never becomes a done criterion.

**Q3: I need to correct something you took from me.** The research shows two different things, and only one of them is reassuring:
- **A bar on what to report** ("only high severity") doesn't stop the reader finding things. It stops the reader reporting them. Moving the bar to a later filter step fixes that, so (a) holds.
- **Telling the reader where to look** does change what it sees. That's the gorilla study, and Shin's preprint shows it in models.

So your worry is real, and your "slight push toward bug types we're wary of" would cause it too: it raises those types and hides the rest. In Shin's preprint, the fix was a second reviewer with an open brief, which recovered every finding the focused one had dropped. So the evidence points to your multi-pass idea: one open pass, plus separate passes aimed at the types you care about. A nudge inside a single brief doesn't do the same job.

**Your Q2 note is pinned.** Two things need testing: how many rules a reader can actually follow, and whether one dense term can carry a cluster of rules. The research has nothing on the second, but it adds one caution. A dense term only works if the reader already shares it. Your micro-genre term works because the model learned it in training. A term the factory coined itself is jargon to a new reader. I'd add both to "Decide how we'll know the writing works" when I close this ticket.

Round two:

---

❓ **Q6 - Which way of departing from a rule replaces the five?** Here they are:

1. **Say so loudly and get a sign-off before breaking it.** Both AGENTS.md files have this. It works when you're there to answer. An unattended subagent has nobody to ask, and the line sits right next to "never block on the human".
2. **Follow the file, then say why your instinct differed.** This is in [template/AGENTS.md:16](template/AGENTS.md:16), inside your own note, four lines above mechanism 1. Mechanism 1 says ask first. This one says obey first and explain afterward.
3. **Where the spec is silent, decide, and record the choice under Provisional in DECISIONS so you can overrule it.** This one covers gaps in the spec, not conflicts with a rule.
4. **A skipped step stays in the to-do list as `skip: <reason>`, never silently dropped.** This comes from upstream pstack. Delegation is the one step that can't be skipped this way ([feature.md:12](template/.agents/skills/poteto-mode/playbooks/feature.md:12)).
5. **Ours, where the problem goes back to the writer of the plan.** A writer's flags must end `fixed: <sha>` or `accepted: <reason>`, and the review script refuses to start until they do. A writer that can't implement a test case as written stops and reports it, and doesn't improvise.

➡️ My proposal sorts them by the situation they cover, rather than keeping one rule for everything:
- **The spec is silent:** keep 3.
- **The reader took a different route than the writer suggested:** every report has one line saying where it departed and why, or that it didn't. This extends 4 from playbook steps to any brief.
- **A binding rule fights the goal, and you're present:** keep 1.
- **A binding rule fights the goal, and nobody's present:** use 5's pattern. The reader stops that part, reports the conflict to whoever owns the rule, and finishes the rest.
- **Mechanism 2:** it's your text, so it's your call. I'd reword it. Its point, copied professional patterns over first-principles ideas, is advice with a reason. As written, "follow the file" reads as obey everything, which conflicts with mechanism 1.

---

❓ **Q7 - Q1 again, in plainer terms, on real rules.** Here's (c) as one sentence: **a rule binds when the person who owns that decision said it must.** You own most decisions. An orchestrator owns only what it handed out, such as which lane is working in which files. Anything else in a brief is advice, written the way your Q2 answer says. Here is how that reads on rules the factory has now:

| Rule | Who owns it | My reading |
|---|---|---|
| Never push to `main` | You, and a hook enforces it | Binds |
| The orchestrator never writes the code itself | You, and a hook enforces it | Binds, even though it's about the route |
| The trail review always runs | You. It caught the owner's errors 3 times out of 3 | Binds |
| Don't edit files another lane is working in | The orchestrator, which assigned those files | Binds |
| "Read only the brief / the diff" in review briefs | Nobody. Lanes added it to save cost, and no ticket asked for it | Doesn't bind. As advice it does harm, so drop it |
| "Never read more than 150 lines in one call" (`knowledge` skill) | No reason or owner on record | Advice at most, unless you set it |
| The `spec:` citation gate on bugs | It's a bar on what gets reported | Goes to the filter step, by Q3 |

➡️ Correct any row I've got wrong. In particular, did you set the 150-line cap?

---

❓ **Q8 - How a binding rule is worded.**

➡️ Each binding rule says who owns it and why, in plain words, with no MUST or capitals. Current Claude over-applies emphatic rules. Where possible it also says what to do instead, because a bare "don't" keeps the idea active and offers no alternative. Where the rule lives and when it reaches the writer is left to "Decide where each piece lives and when it reaches the writer".

---

❓ **Q9 - Where does "a review system of our own" go?** Your Q3 note is bigger than this map. It covers how many passes a review gets, what each pass is aimed at, a verifier that rates the findings, and measuring recall on planted bugs, not just false positives. There's related work already: the reviewer eval from #103, "Eval the judge and trail-review models the way #103 evals reviewers", and "Choose each tier's review round count from the clean measurement". The options:
- (a) Add it to this map's "Not yet specified".
- (b) Give it a map of its own. This map's rules and brief templates feed it, and this map's "Out of scope" gets a line pointing to it.
- (c) Fold it into "Prototype brief templates for the recurring lane jobs".

➡️ (b). Review briefs stay in this map, since they're writing. The review process (passes, verifiers, measurement) is process design, and it deserves its own destination.