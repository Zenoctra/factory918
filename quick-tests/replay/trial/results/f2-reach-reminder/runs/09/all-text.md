Before I relay what the search found about the rules for departing from a rule, I'll read each one where it's written, as AGENTS.md now asks.

---

I've read each of the factory's ways to depart from a rule in its own file, and most of them aren't competing answers, because each covers a different situation. That leaves two real problems. First, nothing tells a subagent what to do when a rule it can't break fights its goal. Second, the factory's own philosophy prefers scripted steps, and this ticket has to settle that.

**What the search found**

- **Ways to depart from a rule.** Each one, read where it's written:
  - When a rule disagrees with the agent's instinct, it follows the rule and tells you why its instinct differed ([template/AGENTS.md:16](template/AGENTS.md:16)).
  - When a rule fights the task, it says so loudly and gets a sign-off ([template/AGENTS.md:20](template/AGENTS.md:20), [AGENTS.md:26](AGENTS.md:26)).
  - When the spec says nothing, it takes the smaller, more reversible option and records it as Provisional so you can overrule it ([PHILOSOPHY.md:47](docs/knowledge/core/PHILOSOPHY.md:47)).
  - When it skips a playbook step, it leaves the step in its list marked `skip: <reason>` (upstream, [poteto-mode/SKILL.md:113](template/.agents/skills/poteto-mode/SKILL.md:113)).
  - When a code-writing subagent can't make one row of the design's test table work as written, it stops and reports that row ([feature.md:12](template/.agents/skills/poteto-mode/playbooks/feature.md:12)).

  Only two of these overlap: "Proceed on anything reversible" (`:18`) and "get a sign-off before breaking it" (`:20`) both apply when an agent wants to break a reversible rule while you're away. The sign-off line exists only in the two AGENTS files, and nothing says how a subagent would get one.
- **Rules about the route that did good.**
  - The required review of the decision log caught the subagent that owned the ticket wrong three times out of three ([ticket.md:26](template/.agents/skills/poteto-mode/playbooks/ticket.md:26)).
  - The delegation rule failed when it was only written down, and works now that a hook enforces it ([ledger.md:16](docs/agents/ledger.md:16)).
  - An agent that kept its first look at the code narrow let a hook bug survive four review rounds ([ledger.md:17](docs/agents/ledger.md:17)).
- **Rules about the route that did harm, beyond search.**
  - You ruled that an "at most N" list was "a prediction, not a constraint" (P109).
  - A subagent turned your question into a rule on a ticket ([ledger.md:19](docs/agents/ledger.md:19)).
  - The standards reviewer is told to cite a ticket it is never shown, so honest reviewers downgraded real bugs. That rule is about how the report has to be finished. The constraints audit filed it under "report format" and kept it until a late addendum.
- **Most rules don't carry their reason.** Examples: "never an arena", "Do exactly the task in your prompt", and the `knowledge` skill's 150-line read cap, whose reason nobody recorded. Only `DECISIONS.md` requires a reason for every entry.
- **The audits built their categories on the old split.** They sorted limits into what an agent may look at or run, caps, safety (kept) and report format (kept), so their counts measure the symptom you named rather than the cause.
- **Most of their recommendations haven't been applied.** One example is the line on the pstack subagents: "Execute only the task and path scope the parent assigns."

I tried to read the findings of the research ticket "Research how wording and missing context shape a reader's response" on its branch, and the read was refused. I've seen only the search's summary of it, so nothing below relies on it.

Q2, Q4 and Q5 from the last round still stand as I asked them. Q1 and Q3 are revised below, and Q6 and Q7 are new.

---

❓ **Q1 (revised) - What makes a rule binding?** I still propose that a rule is binding when it states the goal, what done means, or where someone else's decision begins, and that only the person who holds that decision can make the rule binding. Two cases from the search test it:

- **"Execute only the task and path scope the parent assigns."** Under the test, this binds only for files another subagent owns right now. Anywhere else, it's the parent's guess about the route.
- **The required review of the decision log.** This is a rule about the route, and it has a measured reason: it caught errors three times out of three. Under the test it isn't binding unless you adopt it. Without that, it becomes route knowledge, and the bet is that a reader who sees "three of three caught errors" will run the review anyway. The alternative is that a rule backed by evidence binds by itself, but then any agent that collects one data point can make a rule binding.

➡️ Binding comes from the person who holds the decision, never from evidence alone. Evidence goes in as the reason. Where a rule like the log review matters enough to bind, you adopt it, and that's on record.

---

❓ **Q3 (revised) - What does the reader do when a binding rule fights the goal?** The factory answers this for a writer who can't make a test-table row work, which stops and reports. It answers it for the main session, which asks you for a sign-off. It doesn't answer it for any other subagent. For the main session while you're away, "proceed on anything reversible" and "get a sign-off" also overlap. The options:

- (a) Every reader follows one rule. It never breaks a binding rule, never narrows the goal to fit it, stops that part, and reports the conflict to whoever holds the rule while it carries on with the rest. A rule that isn't binding, it departs from and says why in its report.
- (b) The main session keeps the sign-off, and subagents get (a).
- (c) A reader may break a binding rule when the change is reversible, and reports that it did.

➡️ (a). It covers both gaps with one sentence. It keeps the stop-and-report behaviour the test-table rule already proved, and it leaves "proceed on anything reversible" to cover everything that isn't a binding rule.

---

❓ **Q6 (new) - Do playbooks count as rules about the route?** By design they do. [PHILOSOPHY.md:23](docs/knowledge/core/PHILOSOPHY.md:23) says the pstack playbooks make the agent "follow… a script rather than improvising". Poteto-mode tells the agent to copy a playbook's steps verbatim before it reasons about the task. `feature.md:12` forbids skipping delegation, with no `skip:` way out. On 2026-09-24 you ruled that upstream pstack's constraints stay and that factory-written text is suspect. The options:

- (a) Playbooks stay scripts, and the new treatment covers only what the factory writes itself.
- (b) Every playbook step becomes route knowledge that may be skipped.
- (c) An upstream playbook binds as a whole because you chose pstack, keeping its own `skip:` rule. Every step the factory has added gets the new treatment, and a step that fights the goal is reported under Q3.

➡️ (c). It matches your 2026-09-24 ruling and makes the factory's additions earn their place. The philosophy's "a script rather than improvising" belief would then need rewording, which belongs to "Decide the scope and order of reworking existing files".

---

❓ **Q7 (new) - Does every rule carry its reason?**

➡️ Yes, binding or not. A binding rule's reason is how the reader recognises the case under Q3 where it fights the goal. A rule whose reason nobody can state, like the 150-line cap, is a candidate for deletion rather than a rule to keep.

---

One more thing outside this ticket: [MANUAL.md:168](docs/knowledge/core/MANUAL.md:168) still says "twelve ordered beliefs", but the philosophy has had eleven since the cost belief was removed. I can file that as a quick ticket once we're done here.