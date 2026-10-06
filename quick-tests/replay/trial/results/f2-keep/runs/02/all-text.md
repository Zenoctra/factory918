"Continue" doesn't answer the round, so Q1–Q5 are still open. The search has finished, though, and three of its findings change the questions. Q2, Q4 and Q5 stand as I asked them. Q1 and Q3 are revised below, and Q6 is new.

**What the search found that matters here:**
- **Some rules about the route have earned their place.** One example is the rule that every ticket's PR gets a review of the subagent's decision log (the "trail review"). It's mandatory because it caught the subagent's own mistakes in 3 of 3 runs (`ticket.md:26`). The delegation hook exists because an agent broke the prose rule knowingly. The blast-radius rule came from a hook bug that survived four review rounds. So evidence can stand behind a rule about the route, not only your say-so.
- **The factory has five different ways to depart from a rule, and they disagree:**
  - get a sign-off first (both AGENTS files);
  - follow the file, then explain where your instinct differed (`template/AGENTS.md:16`);
  - decide yourself and record it under Provisional in DECISIONS (`PHILOSOPHY.md:47-55`);
  - skip a step visibly with `skip: <reason>` (pstack, which the feature playbook switches off for delegation);
  - stop and report without filling anything in (`feature.md:12`).

  No audit looked at these. Nothing says how a subagent with nobody to ask gets a sign-off.
- **Many rules carry no reason.** Three examples are "never an arena", "Do exactly the task in your prompt" on every tier agent, and the 150-line read cap in the `knowledge` skill.
- **The run-2 constraints audit sorted rules with the test you rejected.** Its keep or delete call on about 45 of our lines was made under that test, so those calls need judging again once this ticket settles. That belongs to the ticket "Decide the scope and order of reworking existing files"; I'll note it there when I record the resolution. The audit's own addendum admits it missed rules about how the work is finished, such as the `spec:` gate that led reviewers to downgrade real bugs.
- **The research write-up on `research/wording-and-reader-context` supports the broader framing, with counterweights.** Spelling out the method helps on simple tasks and for novices. And no study of models tests a limit on strategy as such.

---

❓ **Q1 (revised) - What makes a rule binding?** My earlier test was: a rule binds only if it states the task, what done means, or what isn't the reader's to decide, and only the owner of that authority can make it binding. The trail review breaks that test. It's a rule about the route, you didn't dictate it, and it's justified by measurement. The options:
- (a) Ownership only. Evidence makes a strong case for a rule, but only you can turn it into one that binds.
- (b) Ownership or evidence. A route rule with a measured reason binds even if nobody owns it.
- (c) Evidence never binds by itself. A route rule with a measured reason goes to the reader as knowledge, with the measurement attached, and the reader may depart under Q3.

➡️ (a). Evidence earns a rule a proposal to you, recorded in DECISIONS. Once you accept it, it binds. That keeps "a lane found it useful once" from quietly hardening into a wall, which is how the review-brief limits arrived without any ticket asking for them.

---

❓ **Q3 (revised) - One way to depart, or several?** When a binding rule fights the goal, what does the reader do? And should the five mechanisms above collapse into one? My candidate for the one: the reader says so, doesn't narrow the goal to fit the rule, and does what its situation allows. If it can ask the rule's owner, it asks. If it's unattended, it sets that part aside and reports the conflict to the owner. A rule about the route that isn't binding needs no permission: the reader departs and writes in its report what it did and why.

➡️ Collapse them into that one. The current five give opposite defaults: follow first versus ask first. A subagent can't tell which applies, so it falls back on obeying, which is the failure this ticket is about.

---

❓ **Q6 - Does every rule carry its reason?** The options:
- (a) Every rule, binding ones included.
- (b) Only rules about the route, where the reason is what lets the reader see when it doesn't apply.
- (c) Reasons are optional.

➡️ (a). A binding rule with no reason gets read too broadly. "Do exactly the task in your prompt" is how a reviewer ends up not following a side effect out of the diff. The reason is what tells the reader where the rule's edge is.

---

**Next round, once Q1 settles:** PHILOSOPHY's belief 3 pushes every rule up to the strongest form, a hook or a script, and there no departure is possible. Should only binding rules be pushed up, with route knowledge staying in prose? That question depends on your Q1 answer, so I'm holding it.

One unrelated thing the search turned up: `MANUAL.md:168` still says "twelve ordered beliefs", but PHILOSOPHY has had eleven since the cost belief was removed. I'll file it as a quick ticket unless you'd rather fold it into something else.