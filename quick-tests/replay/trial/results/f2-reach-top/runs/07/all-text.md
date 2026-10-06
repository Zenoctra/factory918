The background search is back. It doesn't settle any of the five questions; those are still yours. It does change two of my recommendations and adds evidence that applies to all of them.

**What it found:**

- **The factory has five different ways for a reader to depart from a rule, and they disagree.**
  - "Say so loudly and get a sign-off" is in both AGENTS files.
  - "Follow the file, then tell me why your instinct differed" is at `template/AGENTS.md:16`. That's the opposite default.
  - "Decide and record a Provisional row" is in the philosophy and the Ticket playbook.
  - pstack lets a reader skip a step if it writes down a reason, but `feature.md` turns that off for delegation.
  - The review scripts hand problems back as `fixed:` or `accepted: <reason>`, or as a reported design hole.
  - No audit ever looked at these mechanisms. Nothing tells a subagent how to get a sign-off. The search found no record of the sign-off line ever being used.
- **The run-2 constraints audit used a framework close to the one you rejected.**
  - It sorted limits into reading, running, output caps, safety (kept) and report format (kept). That's close to the "protect the world / shape the search" split.
  - Its late addendum admits the "report format" bucket hid real harm. The Standards brief requires a `spec:` citation from a ticket it never shows the reviewer, so honest reviewers demoted real bugs. One filed nothing on a PR with four hard bugs.
  - That rule bounds how the work is *finished*, not how it searches. It confirms your point that search was only the symptom we noticed first.
- **Rules about the route have also done good,** each with a recorded reason:
  - The mandatory trail review caught owner errors three times in three runs.
  - An agent that kept its grounding narrow let a hook bug survive four review rounds.
  - An agent broke the delegation rule knowingly, so a hook now holds it.
  - A cell was cut on a judge's guess, and the guess was wrong.

  In each case, agents left to choose their own route chose badly, and the rule exists because of it.
- **Rules carry their reasons unevenly.** "Never an arena", the 150-line read cap, the 30-second suite limit, and "Do exactly the task in your prompt" on our tier agents have no stated reason. The audit found none recorded for 150 either.
- **Most of the audit's recommended removals are still in the tree,** including the pstack wrapper's "Execute only the task and path scope the parent assigns".

**How this changes the round:**

- **Q1:** The test has to account for the trail review and the delegation rule. Both are about the route, and both did good. Under my recommendation (what the rule is about, plus who owns it) they stay binding because you adopted them with a measured reason. An orchestrator couldn't create such a rule on its own. I'd add one thing to that recommendation: a rule about the route that you make binding carries the evidence that made it binding, so it can be dropped when the evidence goes stale.
- **Q3 grows.** It's no longer only about what a subagent does with no one to sign off. It's whether the standard picks one departure mechanism and replaces the other four. My recommendation: one mechanism for everyone. A rule with a reason may be departed from when the reason doesn't apply. The departure goes in the report, or as a Provisional row when it's a decision. Only a binding rule (Q1) stops the work, and then just that part stops while the conflict goes to the rule's owner. That would replace both "follow the file first" and "sign-off before breaking it" as they're written today.

Q2, Q4 and Q5 are unchanged. I'm waiting on your answers to all five before the next round.