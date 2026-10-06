The search is back. Three findings change what I asked you. Q2, Q4 and Q5 stand as asked; Q1 and Q3 are revised below, and nothing is decided until you answer.

**1. Harm also comes from rules on how the work is handed back.** The constraints audit from run 2 used the old "protect the world / shape the search" split, so it counted the hand-back format as safe and skipped it. Its own late addendum found otherwise. The Standards review refuses a finding unless it cites a ticket criterion, and the brief never shows the reviewer the ticket. One reviewer, Sol, followed that rule and filed nothing on a PR that had four real bugs. That gate is still live (`review-brief.sh:494`). This is your point in action: the split took one symptom as the principle and missed a different one.

**2. Some rules about method have earned their place.** The mandatory trail review caught the subagent's mistakes 3 times out of 3. The delegation rule needed a hook because the written rule alone was broken knowingly. The design-hole step caught two gaps that two runners and a judge missed. Each of these carries evidence. Many other rules carry no reason at all, for example "never an arena", the 30-second test limit, and "subagents never launch dev servers".

**3. The factory has five ways to depart from a rule, and they point different ways:**
- `AGENTS.md`: say so loudly and get a sign-off first.
- `template/AGENTS.md:16`: follow the file, then explain why your instinct differed.
- pstack: skip a step visibly with `skip: <reason>`.
- Review flags: mark each `accepted: <reason>` or fix it.
- The writer: stop and report a test cell it can't implement.

No text says how a subagent gets a sign-off. Nothing records the sign-off route ever being used.

The research branch for "Research how wording and missing context shape a reader's response" adds a caution. Specific method helps on simple tasks and for beginners. Holding back what the writer volunteers is a different thing from limiting what the reader may look for. No study of models tests limits on strategy directly.

---

❓ **Q1 (revised) - What makes a rule binding?** I proposed that a rule binds only when it states the task (what's wanted, what done means) or a limit of someone's authority (you merge, another subagent owns a file), and only the owner can make it binding.

Finding 1 shows a hole in that test. The ticket-citation gate looked like "what done means" and still decided what counted as an answer. A shape for the answer is fine: where it goes, and that it's readable. A rule that filters which answers are allowed is a limit on the route, even when it's dressed as a format.

Finding 2 shows the other side. Some route rules you own are good because they have evidence behind them.

➡️ A rule binds when its owner set it, whether it's about the task, a limit of authority, or the route. Every binding rule carries its reason, including the ones you own, so that a reader who meets a case nobody predicted can see whether the reason still applies. A rule that decides which answers count is treated as a route rule, whatever it calls itself.

---

❓ **Q3 (revised) - What does the reader do when a binding rule fights the goal, and do the five ways to depart become one?** The options:
- (a) Stop that part, report the conflict to the rule's owner, and carry on with the rest.
- (b) Break the rule and report it.
- (c) Shrink the goal to fit the rule.

On the second half: keep the five ways as they are, or have the standard name one way and point the others to it.

➡️ (a), never (c), and make it one way. A rule that only guides the route (Q2) may be departed from with a one-line reason in the report, the same move as pstack's `skip: <reason>`. A binding rule is never broken alone: the reader stops that part and reports it. The orchestrator in the main conversation, which can actually ask you, is where "say so loudly and get a sign-off" applies. "Follow the file, then explain why your instinct differed" moves under the second case.

---

One thing outside this ticket: `MANUAL.md:168` still says "twelve ordered beliefs", but the philosophy has had eleven since the cost belief was removed. I can file that as a quick ticket if you'd like.