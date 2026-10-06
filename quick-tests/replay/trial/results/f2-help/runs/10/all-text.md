The search finished. Before passing on its claim that the departure mechanisms contradict each other, I'll read each one where it's written.

---

The search is done. I read each rule it cited in its own file before deciding whether any of them conflict. Your answers to Q1–Q5 are still open. The findings change my recommendation on Q1, and add a little to Q2.

**The rules for departing from a rule don't contradict each other.** The summary made them look like competing answers, but each one covers a different situation:
- **"Follow the file and tell me why your instinct differed"** (`template/AGENTS.md:16`) applies when the agent simply prefers something else. Nothing is blocked.
- **"Say so loudly and get a sign-off"** (`:20`) applies when following a rule would make the task fail.
- **"Proceed on anything reversible"** (`:18`) is about actions, and it lists the few that need asking first.
- **`skip: <reason>`** (upstream pstack) covers steps in a playbook. The delegation step is the one exception.

So the real problem is a gap, not a contradiction: no text says what a subagent working alone does when a rule fights its task, because nobody is there to sign off. That's Q3. One smaller wording problem: in the template, "These are good defaults" comes right after your note, so it could mean the note or the whole file. That belongs to the ticket "Decide the scope and order of reworking existing files".

**The run-2 constraints audit used the old split.** It kept "safety" and "report format" rules as harmless. Its own late addendum admits that one report-format rule did the same kind of damage. That rule is the `spec:` gate: the Standards review counts a finding as hard only if it cites the ticket, but that review is never shown the ticket. Following that rule, one reviewer filed nothing on a PR that had four real behaviour bugs. The answer-key audit found a second reviewer demoting a real bug for the same reason. Neither rule is about where to search. They decide what counts as a finished answer, which is your correction exactly.

That also breaks my Q1 test. I had listed "what done means" as binding, and the `spec:` gate is a rule about what done means. My template line from 2026-09-25 put "how to report" in the fixed part of a template for the same reason. Revised:

❓ **Q1 (revised) - What makes a rule binding?** The same choices as before. I've changed my recommendation on the "what done means" part.

➡️ A rule is binding when its owner set it and it states the goal or a limit of authority. The rule about how the result is handed back sets only what the receiver needs in order to use the result. It never sets a bar on what counts as a finding, or how many findings there should be.

**Where rules about the route did good.** Each of these rule-followed cases has a recorded reason, and you own the rule. When a rule was broken, the result is noted after it.
- The mandatory trail review caught the owner's mistakes in all three runs that used it.
- An agent knowingly broke the delegation rule while it was only written down, so a hook now enforces it.
- Owners start one at a time, and the measured reason is written down.
- An agent's narrow search let a hook bug survive four review rounds.

That fits (b) in Q1: the rules that earned their keep were owned, and their reason was written down.

**Adds to Q2.** The research for the ticket "Research how wording and missing context shape a reader's response" separates two things:
- **What the writer volunteers**, such as its own guess about where the bug is. Holding back here protects the reader's independence.
- **What the reader may look for.** The research found no evidence in favour of limiting this.

So Q2's "knowledge with its reason" covers facts about the route, never the writer's guess about the answer. The research also lists one place where a specific method helps: simple tasks and readers new to the work. The same evidence speaks to Q5. Tight output budgets cut reasoning models' accuracy sharply, so a budget should stay a fact the reader plans around, never a cap on its output.

One unrelated thing I noticed: `MANUAL.md:168` still says "twelve ordered beliefs", but PHILOSOPHY has had eleven since the cost belief was removed. I'll leave it for a quick ticket unless you'd rather I fold it in somewhere.