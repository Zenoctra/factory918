The search finished. It says the factory has five ways of departing from a rule and that they disagree. Before I repeat that, I'm reading each one where it's written.

---

The search is done. Here's what it changes in round one. Nothing is decided yet; Q1–Q5 above are still open.

**The ways of departing from a rule don't conflict.** The search said the factory has five of them and that they disagree. I read each one where it's written, and each covers a different situation:
- **Your instinct disagrees with a rule.** "Follow the file and tell me why your instinct differed" ([template/AGENTS.md:16](template/AGENTS.md:16)).
- **A rule fights the task.** "Say so loudly and get a sign-off" ([template/AGENTS.md:20](template/AGENTS.md:20)).
- **A playbook step looks unnecessary.** Leave it in the list with `skip: <reason>` (poteto-mode).
- **The spec says nothing.** Decide, and record it under Provisional.
- **A writer can't implement a test cell as written.** "Stops and reports the cell, and never fills it in" ([feature.md:12](template/.agents/skills/poteto-mode/playbooks/feature.md:12)).

The actual gap is narrower. The sign-off line assumes someone is available to sign off, and no text says what a subagent does when nobody is. That's Q3, and the writer-cell rule is already a factory precedent for my recommendation there: stop that part, report it, and don't fill the gap with a guess.

**Your "follow the file" line fits the Q1 test.** "One toolchain, one way of doing each thing" is a rule about the route, and it's binding because it's yours. It also comes with a channel for disagreeing: follow it, then say why your instinct differed. That supports the ownership half of my Q1 recommendation.

**Some rules about the route did good.** The search found these:
- The mandatory trail review found owner errors 3 times out of 3.
- An agent chose to ground itself narrowly and skipped `architect`. A day-zero hook bug then survived four review rounds, which is where the blast-radius rule came from.
- An agent knowingly broke the delegation rule, so it's now held by a hook.

In each case the reader's own route was the worse one. Each fix was a rule you adopted after a measured failure, with the reason attached. That fits Q1, but it's honest counter-evidence to the idea that the reader's route is always better. It's why Q6 below exists.

**The research note splits Q2 in two.** It's on the research branch, written for "Research how wording and missing context shape a reader's response". Two things look alike but behave differently:
- **What the writer leaves out.** For example, not telling a reviewer where the writer thinks the bug is. The forensic-interviewing evidence supports this kind of restraint, because it protects the reader's independence.
- **What the reader is forbidden to look at or do.** The evidence gives no support for this kind of limit.

So a brief that withholds the orchestrator's guess is good writing, and a brief that forbids reading past the diff is a rule about the route. The note also gives the one measured case where specific method helps: simple tasks and novice readers.

Two new questions follow from this. Both stand without your round-one answers.

---

❓ **Q6 - When a lesson about the route was learned the hard way, is it binding or knowledge?** Take "check blast radius beyond the diff" or "a review of the trail is mandatory". Each exists because a reader's own route failed once. The options:
- (a) It's binding once you adopt it. It is written with its reason and the failure it came from, and it can be undone only by you.
- (b) It's knowledge under Q2: written with its reason, and the reader may depart from it if it says why in its report.
- (c) It depends on what the failure cost. Lessons from failures that stay silent and pile up are binding; the rest are knowledge.

➡️ (a). These lessons are your judgment, made from evidence, and the agent that would depart from one is the kind of reader that failed before. What keeps this from becoming the old problem is the attached reason, plus a rule that a reader who thinks a lesson is wrong for this case says so in its report (the "follow the file, tell me why" form). It doesn't quietly route around it.

---

❓ **Q7 - Does a simple task or a less capable reader change the answer?** The evidence says step-by-step method helps on simple tasks and for novices. Some recurring jobs are close to mechanical: run the sync, re-vendor, post a comment. Some are routed to the less capable tier. The options:
- (a) No change. Steps for a simple task are knowledge under Q2, and a capable reader follows good steps anyway.
- (b) For tasks you've marked mechanical, the steps may be binding.
- (c) The tier changes the answer: the less capable tier gets binding steps.

➡️ (a). A simple task with good steps loses nothing when the steps are offered rather than imposed. A task that turns out not to be simple is exactly the case a binding rule can't foresee.

---

Two things outside this ticket, so I'll note them rather than act on them:
- The run-2 constraints audit sorted every rule using the framing you've since rejected. "Decide the scope and order of reworking existing files" should re-sort with whatever we settle here, not reuse the audit's list of rules to keep.
- [MANUAL.md:168](docs/knowledge/core/MANUAL.md:168) still says "twelve ordered beliefs". PHILOSOPHY has had eleven since the cost belief was removed. That's a quick ticket if you want it.