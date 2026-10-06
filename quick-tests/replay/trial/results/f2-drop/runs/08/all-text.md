The background search is back, and it changes three of the round-one questions. Your answers to round one are still open; nothing below assumes them.

**What it found that matters here**

- **Five different ways to depart from a rule, and they contradict each other.**
  - "Say so loudly and get a sign-off," in both AGENTS files. No subagent has anyone to sign off, and the line pulls against "never block on the human."
  - "Follow the file, then tell me why your instinct differed" (`template/AGENTS.md:16`). That's the opposite default: obey first, explain after.
  - "Decide and record a Provisional row so Manuel can overrule it" (`PHILOSOPHY.md`, `DECISIONS.md`).
  - pstack's "keep the step in the list with `skip: <reason>`". The feature playbook switches this off for delegation.
  - Sending the problem back to the artifact or to you: a writer that can't build a test case as written stops and reports it, and the design-hole path amends the ticket.

  No audit looked at these mechanisms, and I found no record of the sign-off ever being used.
- **Your correction holds up in the evidence.** The constraints audit sorted rules into the old "protect the world vs. shape the search" classes, and its own late addendum admits that this missed the worst one. That was a rule about how a finding must be *written up*, not where the reviewer may look: the Standards brief required a `spec:` citation from a ticket it never showed the reviewer. Honest reviewers demoted real bugs because of it, and on pr99 one reviewer filed nothing at all, though its 4 hard bugs were all behaviour bugs.
- **Rules about the route have also done good.** Each of these has a measured reason or was set by you:
  - The mandatory trail review caught owner errors 3 times out of 3.
  - The delegation hook exists because prose alone was ignored.
  - The design-hole path caught two holes that two writers and a judge had missed.
- **Reasons are uneven.** Some rules carry their reason. Others don't: "never an arena," the 150-line read cap, "do exactly the task in your prompt," and the dev-server rule, which dropped Theo's reason when it was adopted.
- **There's a counterweight in the research.** The draft for the research ticket "Research how wording and missing context shape a reader's response" (on its research branch, not merged) finds that specific method helps on simple tasks and for novices. It separates holding back what the writer volunteers from limiting what the reader may seek. It also says no study on models tests limits on strategy directly.

**How the round-one questions change**

❓ **Q1, a stress case:** my test made "what done means" binding. The `spec:` gate *was* a definition of done, and it did the damage. So under my test, a writer could pass off a limit on the route as a condition for being done. Does the test need a second clause, something like "a definition of done may say what's wanted, never the form a finding must take to count"? Or is the form of the report also the reader's?

➡️ Add the clause. The report's shape belongs to whoever reads the report, so it may be asked for. It may never decide what counts as found.

❓ **Q2, the counterweight:** the research says step-by-step method helps weaker readers on simple tasks. Every reader here is a frontier model, so I'd keep my recommendation of (b): route knowledge as the writer's knowledge, with its reason. I'm raising it in case you see a lane where a script is the right call. The pstack playbooks are scripts by design (`PHILOSOPHY.md:23`).

❓ **Q3, now wider:** it's no longer "what does the reader do," it's "which of the five departure mechanisms does the standard keep." My recommendation follows from the earlier answer:
- Keep one rule for everyone. A binding rule that fights the goal stops that part, and the reader reports the conflict to the rule's owner. The reader never narrows the goal to fit the rule.
- A rule about the route can simply be departed from, with the departure and its reason in the report. This is pstack's `skip:` form, applied to all route knowledge.
- Retire "follow the file, then explain," and rewrite the sign-off line to match.

Q4 and Q5 are unchanged.

One aside, out of this ticket's scope: `MANUAL.md:168` still says "twelve ordered beliefs" though the philosophy has eleven since the cost belief came out. I'll file it as a quick ticket unless you'd rather I didn't.