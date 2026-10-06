The search of the factory's writing finished. Your answers to round one aren't in yet, so nothing is settled. Three findings change the round: I'm sharpening Q1 and Q3 and adding Q6. Q2, Q4 and Q5 stand as asked.

**What it found that bears on this:**
- **Five ways of departing from a rule exist, and they disagree with each other.**
  - Say so loudly and get a sign-off first: `AGENTS.md:26` and `template/AGENTS.md:20`.
  - Follow the file, then explain why your instinct differed: `template/AGENTS.md:16`.
  - Decide and record a Provisional row that you can overrule: `DECISIONS.md:67`.
  - Skip a step visibly with a reason: pstack's `skip: <reason>`, which `feature.md:12` turns off for delegation.
  - Stop and report instead of filling in a cell or a flag: `feature.md:12`, P108.

  No text says how a subagent gets a sign-off. The sign-off line also pulls against "never block on the human". None of the run-2 audits looked at these mechanisms.
- **The audits used the framing you rejected.** The constraints audit sorted limits into reading, running and output caps, with safety and report format kept. Its own late addendum admits it filed the `spec:` citation gate as "report format" and skipped it. That gate is a rule about how the work gets finished, not about search, and it did comparable harm: Sol filed nothing on a PR that had four hard bugs. This supports your correction.
- **Some route rules did measurable good.** The mandatory trail review caught owner errors 3 of 3 times, after owners had skipped it. Two other failures led to rules: an agent that scoped its own grounding narrowly let a hook bug survive four review rounds, which produced the blast-radius rule, and the delegation rule was broken knowingly until a hook held it. All of these rules *add* a step. Your examples all *remove* options: may not read outside the brief, must cite from this list, stop at N characters.
- Many rules carry no reason, for example "never an arena", "nothing wider is redesigned", the 150-line read cap and "Do exactly the task in your prompt."
- Most of the audits' recommendations haven't been applied yet. "Execute only the task and path scope the parent assigns", the 150-line cap and the `spec:` gate are all still live.

---

❓ **Q1 (sharpened) - What makes a rule binding?** The trail-review finding exposes a gap in my first test. "Route belongs to the reader" would make the trail review optional, and agents skipped it when it was optional. The pattern in the evidence suggests a different line: **floors and ceilings**.
- **A floor** requires something more. "Run the trail review." "Check the blast radius." The reader may still do anything else it thinks of.
- **A ceiling** forbids or caps. "Read only this." "Cite from this list." "Stop after N." This is the kind that closes off the strategy nobody predicted.

Does that line hold? The delegation rule is a ceiling on the orchestrator, yet it's good. I'd argue it defines a role rather than capping a strategy: the orchestrator isn't the writer, the way a reviewer isn't the author. That may be special pleading, though, and I'd rather you judge it. The options:
- (a) Floors may be binding when evidence backs them and the rule carries that evidence. Ceilings are binding only when they state who owns a decision: you merge, another subagent owns that file, the ticket draws the scope.
- (b) My first test: the task and the limits of authority are binding, and the route never is.
- (c) Ownership alone: whatever you set is binding, whatever its shape.

➡️ (a). It keeps the good mandatory steps, it cuts every example you gave, and it fits your words: a floor never limits "how the task is pursued" beyond adding to it.

---

❓ **Q3 (sharpened) - One way to depart from a rule, or several?** The question is no longer only what an unattended subagent does. The factory has five mechanisms that disagree, so which survive? The options:
- (a) One mechanism everywhere. A reader that thinks a rule fights the goal says so where it can't be missed. If the rule is a floor or a ceiling it owns, the reader follows it and reports. Otherwise it departs and reports what it did and why. Your Provisional rows already work this way for spec gaps. Sign-off is kept only for your own rules, in your own session.
- (b) Keep sign-off as the universal mechanism and give subagents a path to it through the orchestrator.
- (c) Leave the five as they are, each in its own context.

➡️ (a). It replaces "follow the file, then explain" and the sign-off line with one rule that matches Q1. It keeps `skip: <reason>` and `accepted:` as instances of the same rule.

---

❓ **Q6 (new) - Does a binding rule have to carry its reason?** Many rules don't. The vendored `writing-for-agents` already says to cache "the reason behind a choice". Without the reason, a reader can't tell when its case is the one the rule never anticipated, and that is exactly when departing matters. The options:
- (a) Every binding rule carries its reason or its evidence. A rule whose reason nobody can recover is demoted to knowledge (Q2's form) or deleted.
- (b) Reasons are encouraged but not required.

➡️ (a). The rework ticket ("Decide the scope and order of reworking existing files") then gets a concrete test to apply line by line.

---

One stray finding outside this ticket: `MANUAL.md:168` still says "twelve ordered beliefs", but PHILOSOPHY has had eleven since the cost belief was cut. I'd file that as a quick ticket rather than fix it here.