The background search finished. It found five different ways the factory currently tells a reader it may depart from a rule. Before I say any of them conflict, I'm reading each one where it's written.

---

You haven't answered round one yet. The search turned up enough to correct one question and add three, so here they are, followed by the whole round to answer together.

**What the search found that matters here**

- **Today the factory has five ways to depart from a rule.** I read each one where it's written. They cover different situations, so they aren't competing answers:
  - **Your note** in [template/AGENTS.md](template/AGENTS.md):16 says that when the file disagrees with the agent's instinct, it should follow the file and explain why its instinct differed.
  - **The same note, line 20,** says that when a default fights the task, the agent should say so and get a sign-off.
  - **PHILOSOPHY's "when the spec is silent"** has the agent decide and record its call under Provisional.
  - **pstack's `skip: <reason>`** lets an agent skip a playbook step, as long as it says so.
  - **`accepted: <reason>`** is how a writer's flags get settled.
- **Rules about the route did good as well as harm.**
  - Good: the mandatory trail review caught the owner's mistakes in all 3 of its runs. An agent broke the delegation rule on purpose until a hook enforced it. A skipped grounding step let a bug survive four review rounds, which is why the blast-radius step exists.
  - Harm beyond search: P109's "at most" list, which you ruled was "a prediction, not a constraint". Also the review brief's `spec:` gate, which made honest reviewers downgrade real bugs because the gate wanted a citation from a ticket they were never shown. That rule shaped how the work is finished, not what gets read.
- **Most of the audits' fixes aren't applied yet.** Lines like "Execute only the task and path scope the parent assigns" are still in place. Fixing them belongs to the ticket "Decide the scope and order of reworking existing files"; here we decide the principle.
- **The research note makes a distinction we need.** Holding back what the *writer offers* (its own guess at the answer) protects the reader's independence. Limiting what the *reader may seek* has no evidence on its side. The note also says no study of models tests a limit on method directly, and that specific instructions help only on simple tasks and with novice readers.

**A correction to Q3:** I said the template's sign-off line covers the whole file. Read in place, it closes your note, and "These are good defaults" may mean only the note. This repo's own [AGENTS.md:26](AGENTS.md:26) does cover "this file". My question still stands: neither line says how a subagent with nobody to ask gets a sign-off.

---

❓ **Q1 - What makes a rule binding?** Unchanged.

➡️ (a) and (b) together. A rule is binding when it states the task or the limits of someone's authority, and only the person who holds that authority can make it binding.

---

❓ **Q2 - How should the writing carry a rule about the route?** One addition: what the writer offers is knowledge about the route, never its guess at the answer. "The bug is probably in X" is leading the witness, not route knowledge. How the standard guards against leading in general belongs to the ticket "Decide what the writing standard is and what carries it".

➡️ (b), with (a) as the starting point. Include route knowledge only when the reader couldn't easily find it, always give the reason, and the reader reports when it takes another route.

---

❓ **Q3 - What does the reader do when a binding rule fights the goal?** Unchanged apart from the correction above.

➡️ (a): stop that part, report the conflict to whoever owns the rule, and carry on with the rest. Never narrow the goal to fit the rule.

---

❓ **Q4 - Who may write a binding rule into a brief?** Unchanged.

➡️ The orchestrator passes your rules down and binds only what it owns itself. Everything else it offers as knowledge.

---

❓ **Q5 - Can cost or time limit the route?** Unchanged.

➡️ (a): a budget is a fact the reader plans around. (b) applies only to a budget you set yourself.

---

❓ **Q6 - Does "follow the file and tell me why your instinct differed" cover the route?** Your note argues for copying a proven pattern over "a first-principles idea from someone who has never seen the pattern". Your correction argues for leaving room for "something you CAN'T predict". Read in place, the note is about what gets built: one codebase, one toolchain, one way of doing each thing. The correction is about how a task is pursued. The options:
- (a) The note covers what gets built, and Q2 covers the route.
- (b) The note covers both, so the reader follows route rules too and explains afterwards.
- (c) The note gets rewritten to match whatever this ticket decides.

➡️ (a). The two apply to different situations. The standard should say which one governs where, so a reader doesn't take "follow the file" as permission to bind the route.

---

❓ **Q7 - What happens when giving the reader freedom on the route has already failed?** The delegation rule was written as prose, an agent broke it knowingly, and now a hook holds it. A lesson that cost a run, such as the trail review or blast radius, could stay as knowledge the reader may depart from, or become binding. The options:
- (a) It stays as knowledge unless you bind it. A measured failure is the evidence that goes to you with the request.
- (b) The orchestrator may make it binding on that evidence alone.
- (c) Every lesson that cost a run becomes binding automatically.

➡️ (a). It keeps Q4 consistent, and the evidence makes the request quick for you to judge.

---

❓ **Q8 - Is the shape of the report part of the task or part of the route?** The run-2 audit kept "hand-back format" as safe. Yet the `spec:` gate was a format rule, and it decided which bugs could be reported at all. That's the same failure as your smell list. The options:
- (a) The writer may set the report's shape only as far as the receiver needs to parse it. Anything that decides what counts as reportable is the route, so it's out.
- (b) The report format is fully binding.
- (c) The report's shape belongs to the reader as well.

➡️ (a). A parser needs a shape. A rule about what qualifies to be reported is the reader's judgment taken away.

---

One thing outside this ticket: [MANUAL.md:168](docs/knowledge/core/MANUAL.md:168) still says "twelve ordered beliefs", but PHILOSOPHY has had eleven since the cost belief was cut. If you want, I'll file it as a quick ticket.