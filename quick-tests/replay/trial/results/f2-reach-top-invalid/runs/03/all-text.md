The background search finished. You haven't answered round one yet, so nothing is decided; here's what it found that bears on those questions.

**The factory has five ways for a reader to depart from a rule, and they disagree.**
- **Sign-off first.** [AGENTS.md:26](AGENTS.md:26) and [template/AGENTS.md:20](template/AGENTS.md:20) say "say so loudly and get a sign-off before breaking it". The line was copied almost word for word from Theo. No skill or playbook repeats it, and nothing says how a subagent would get a sign-off. It also pulls against "never block on the human" in the same file.
- **Comply first, explain after.** [template/AGENTS.md:16](template/AGENTS.md:16) says to follow the file and say afterwards why your instinct differed.
- **Decide and record.** Where the spec is silent, the agent decides and adds a Provisional row in DECISIONS.md.
- **Skip in plain view.** Upstream pstack lets an agent skip a step if it leaves a `skip: <reason>` line. The feature playbook turns that off for delegation.
- **Send it back.** The `accepted: <reason>` disposition, the writer that "stops and reports the cell", and the design-hole path all return the departure to the ticket or to you.

None of the run-2 audits looked at these mechanisms. That makes Q3 bigger than I framed it: the real question may be which one of these five becomes the single answer.

**The audits support your correction.** The constraints audit sorted limits into categories that mirror the old "protect the world / shape the search" split. Its own late addendum admits it filed rules about how work is finished under "report format" and skipped them. One of those is the rule that a hard finding must cite the ticket (`spec:`), in a brief that never shows the ticket. Because of that rule, Sol filed nothing on pr99, which had four real bugs. That's a rule about finishing, not searching, doing the same damage.

**Some rules about the route did real good:**
- The mandatory trail review caught the owner's errors three times out of three.
- The delegation rule only held once a hook enforced it. The prose alone was broken by an agent that knew the rule.
- The design-hole path caught two holes that two runners and a judge had missed.

These test my Q1 recommendation. Under "binding only if its owner made it so", these rules survive only if you count the playbooks as yours. But the playbooks were written by models and approved by you, and your 2026-09-24 rule treats factory-written text as suspect until proven. So Q1(b) needs a sharper version: does a rule a model wrote and you approved count as owned by you?

**Many rules are missing their reasons.** "Never an arena", "Read no brief and no diff", the 30-second suite limit, the 150-line read cap and "Do exactly the task in your prompt" all appear with no reason. That supports Q2(b): a rule without its reason can't be weighed against a case the writer didn't foresee.

**The research branch has evidence on both sides.** `research/wording-and-reader-context` says the evidence favours your broader framing. It also says a specific method helps on simple tasks and for novices, and that no model study tests a limit on strategy as such. That's a reason not to make Q2(a), leave route knowledge out, an absolute rule.

**Most of the audits' fixes were never applied.** Still live on this branch:
- "Execute only the task and path scope the parent assigns" in the pstack wrapper;
- the 150-line cap in the `knowledge` skill;
- the review-brief limits;
- the `spec:` gate.

That's reworking existing files, so it belongs to the ticket [Decide the scope and order of reworking existing files](https://github.com/Zenoctra/factory918/issues/158), not this one.

Round one stands as asked, with two of my recommendations now in question:
- **Q1:** I still recommend "the goal, done, and limits of authority", with binding power coming only from the owner. Tell me whether model-written rules you approved count as yours.
- **Q3:** I still recommend "stop that part, report to the rule's owner, carry on with the rest". If you agree, it would replace all five departure mechanisms rather than add a sixth. The upstream `skip:` mechanism would stay, since it's vendored.