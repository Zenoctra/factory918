The background search finished. Before I tell you anything about how its findings bear on the round, I'm reading the departure rules it cites where they're written, as AGENTS.md now asks.

---

The search is back. It doesn't settle anything for you, but it changes Q2 and Q3 and adds a Q6. Q1, Q4 and Q5 stand as asked.

**What it found that bears on the round**

- **The factory already has four ways to depart from a rule.** I read each where it's written. They cover different situations, so they don't compete:
  - When your instinct differs from the file, follow the file and tell Manuel why (`template/AGENTS.md:16`).
  - When a rule fights the task, say so loudly and get a sign-off (`template/AGENTS.md:20`, `AGENTS.md:26`).
  - When the spec is silent, decide and record a Provisional row (PHILOSOPHY, "How to decide when the spec is silent").
  - When you choose not to do a playbook step, keep it in the list with `skip: <reason>` (`poteto-mode/SKILL.md:113`). Delegation is the exception: `feature.md:12` removes that escape.

  None of them says who gives the sign-off when the reader is a subagent, and none of the run-2 audits looked at these mechanisms.
- **Route rules did good where they came from an incident and kept its reason.**
  - The mandatory trail review caught the owner wrong 3 times out of 3 (`ticket.md:26`).
  - The delegation hook exists because an agent knowingly broke the prose rule (`ledger.md:16`).
- **The harm went beyond reading, which supports your broader framing.** The answer-key audit found that the Standards review brief demands a `spec:` citation from a ticket the reviewer is never shown. Honest reviewers therefore demoted real bugs. That gate is still live (`review-brief.sh:494`), and it governs how the work is finished, not what gets read.
- **Many factory rules have no stated reason.** For example, "never an arena" (`ticket.md:12`) and the 150-line read cap in the knowledge skill.
- **The research note** (`research/wording-and-reader-context`, section 5) supports giving the reason behind a rule.
  - It separates what the writer volunteers from what the reader may seek. Holding back what the writer volunteers protects the reader's independence. Limiting what the reader may seek has no support.
  - Its counterweight: specific method helps on simple tasks and for novice readers.

---

❓ **Q2 (revised) - How should the writing carry knowledge about the route?** The research adds a distinction. Some route knowledge is about the environment: a trap, a tool quirk, a lesson that cost a run. Some is the writer's expectation of the answer, like "the bug is probably in the parser." The second kind leads the witness even when it's phrased as a hint. The options:
- (a) Leave route knowledge out.
- (b) Write it as knowledge, with its reason. The reader may take another route and says so in its report.
- (c) Write it as an overridable default.

➡️ (b) for knowledge about the environment, given only when the reader couldn't easily find it itself. For a reader whose job is to judge, the writer never volunteers what it expects to find.

---

❓ **Q3 (revised) - What does a subagent do when a binding rule fights the goal?** The four mechanisms above already cover the main session. What's missing is the subagent, which can't reach you. The options:
- (a) Keep the four and add one line: a subagent's sign-off comes from whoever briefed it. The subagent stops that part, reports the conflict, and carries on with the rest. If the rule is yours, the orchestrator brings it to you.
- (b) Merge the four into one rule.
- (c) Let the subagent break the rule and report it.

➡️ (a). The four answer different situations, and merging them would lose that. Under every option, the subagent never narrows the goal to fit the rule.

---

❓ **Q6 - Must every binding rule carry its reason in the writing?** The reason is what lets a reader see when a rule fights the goal (Q3), and it's what the evidence supports. `DECISIONS.md` already requires a reason on every row, and the prose elsewhere doesn't.

➡️ Yes. A rule written without its reason gets one, or it gets questioned. Deciding which existing rules get reworked, and in what order, belongs to the ticket "Decide the scope and order of reworking existing files"; this ticket only sets the standard.

---

**Coming after Q1:** if ownership is part of the test, the next question is whether your merging a PR makes an agent-written rule yours. Most of the factory's rules were written by agents.

**Outside this ticket:** `MANUAL.md:168` says PHILOSOPHY has "twelve ordered beliefs", but it has had eleven since the cost belief was removed. I'll file that as a quick ticket when this one closes, unless you'd rather I didn't.