The background search finished. I checked what it reported against the files themselves, and nothing in it changes the round-one questions, which are still open for your answers. Four findings bear on them.

**1. The problem reaches past search, as you said.** The clearest case isn't about reading at all. The spec-review brief requires every serious finding to cite a line from the ticket, and it never shows the reviewer the ticket. A reviewer that followed this rule filed nothing on PR 99, which had four serious bugs. That rule is about how the work gets finished and reported, not where to look. The run-2 constraints audit missed it the first time because it had filed the rule under "report format", and its own late addendum says so. The audit's categories were built around reading limits, so rules about order and process mostly weren't counted.

**2. Some rules about the route did real good.** These are the cases where the agent's own choice was worse:
- The mandatory trail review found something the owner had wrong in all three runs that did it.
- An agent broke the delegation rule knowingly, which is why a hook now enforces it.
- An agent scoped its own work narrowly, and a bug survived four review rounds.

All three rules came from a failure that actually happened, the reason is written down, and you set or approved each one. That fits my Q1 recommendation that binding comes from the owner. It also suggests a refinement: you make a rule about the route binding only after a recorded failure, and the rule carries that failure as its reason.

**3. Read in their files, the existing ways to depart from a rule don't conflict. They cover different situations.**
- "Follow the file and tell me why your instinct differed" applies when your judgment differs from a pattern the factory copied.
- "Say so loudly and get a sign-off" applies when a rule blocks the task.
- `skip: <reason>` applies to a playbook step the agent chooses not to do.
- `accepted: <reason>` applies to a writer's flag that is being left unfixed.

None of them covers a subagent running unattended with nobody to sign off. That's the gap Q3 is about, and nothing written today fills it. `skip:` and `accepted:` are already the "say what you departed from and why" form Q2(b) proposes, so the factory already has the pattern.

**4. The research note for "Research how wording and missing context shape a reader's response" is written.** It sits on the unmerged branch `research/wording-and-reader-context`, and that ticket is still open. Three of its points bear on this ticket:
- **It supports your broader framing.** In the human studies, the costliest rules limit how the work is done and what may be reported, not only what may be read.
- **It adds a distinction worth keeping.** Holding back what the writer volunteers (its own conclusions and hopes) protects the reader's independence. Limiting what the reader may look for is a different thing, and the evidence doesn't support it. This affects Q2: knowledge about the route can be offered, but the writer's guesses about the answer shouldn't be.
- **It gives one counterweight.** Specific instructions on method help on simple tasks and with inexperienced readers. It also says that no study of models tests a limit on how a task is done directly.

Your answers to Q1–Q5 decide the next round. One stray fact for later, unrelated to this ticket: `MANUAL.md` still says "twelve ordered beliefs", but `PHILOSOPHY.md` has had eleven since the cost belief was removed.