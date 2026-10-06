The background search finished while round one is still waiting on you. It changes Q3 and raises one new question. Q1, Q2, Q4 and Q5 stand as written.

**What it found that bears on this round**

- **The factory gives five different instructions for what to do when a rule fights the task, and they disagree:**
  - "Say so loudly and get a sign-off" ([AGENTS.md:26](AGENTS.md:26), [template/AGENTS.md:20](template/AGENTS.md:20)). This was taken almost word for word from Theo. No subagent has a way to get a sign-off, and nothing records that it has ever been used.
  - "Follow the file and tell me why your instinct differed" ([template/AGENTS.md:16](template/AGENTS.md:16)). This is the opposite default.
  - Decide where the spec is silent and record it under Provisional so you can overrule it.
  - pstack's `skip: <reason>`, which `feature.md:12` turns off for delegation.
  - "Stop and report the cell, never fill it in" for writers, and the `fixed:`/`accepted:` endings that the review script checks for.
- **Some rules about the route earned their place.** All of these were set by you or come from a failure we recorded:
  - The required trail review caught an owner's mistake in 3 of 3 runs.
  - The delegation rule was broken knowingly while it was only prose, so now a hook holds it.
  - The design-hole path caught two holes that two runners and a judge had missed.

  None of these came from an orchestrator's guess. That fits the "who owns it" half of my Q1 recommendation.
- **The run-2 constraints audit was built on the framing you have since rejected.** It sorted rules into reading, running, caps, safety and format. Its own addendum admits it skipped the rules about how work is finished, and those did comparable harm: Sol filed nothing on PR 99, which had four hard bugs, because the `spec:` gate required a citation from a ticket it was never shown. The audit's counts are useful. Its categories don't fit this question.
- **The audit's fixes are still not applied.** About 45 lines are still marked delete-or-replace, including the "Execute only the task and path scope the parent assigns" wrapper, the 150-line read cap, and the `spec:` gate. That belongs to the rework ticket (Decide the scope and order of reworking existing files), not this one. I'll note it there when this ticket closes.
- **The research for this map is on the `research/wording-and-reader-context` branch.** It supports the broader framing. It also gives a counterweight: a specific method helps on simple tasks and for novices. It notes that no study tests a limit on strategy directly.

---

❓ **Q3 (revised) - What does the reader do when a binding rule fights the goal, and do the five existing mechanisms become one?** Here is how my answer changes with the facts above:
- **One rule everywhere:** stop that part, report the conflict to whoever owns the rule, carry on with the rest, and never narrow the goal to fit.
- **The sign-off line** stays as the in-conversation form of the same rule, for when you're there to give one.
- **"Follow the file and tell me why"** applies only to binding rules. For route knowledge, departing and reporting it (Q2) replaces it.
- **The Provisional row, `skip:`, `accepted:` and "stop and report the cell"** all stay. Each is that same rule shaped for one situation.
- **`feature.md`'s "no skip-with-reason"** stays, because delegation is binding by your ownership.

➡️ Yes, one rule with those situation-shaped forms. Writing the reconciled wording itself belongs to the standard ticket (Decide what the writing standard is and what carries it).

---

❓ **Q6 - Does this treatment reach vendored upstream text?** Your 2026-09-24 ruling was that upstream pstack's constraints stay, and that it's the factory's own model-written text that is suspect. But the worst single limit the audit found sits in the factory's wrapper of a pstack lane. PHILOSOPHY belief 3 also pushes toward scripts the agent follows "rather than improvising". The options:
- (a) Factory-written text only. Upstream text is left alone.
- (b) Factory-written text, plus a patch in `patches/` wherever an upstream rule bounds the route without a reason we can find.
- (c) Factory-written text only, plus a line in the standard saying a vendored rule about the route is read as the upstream author's knowledge, with a reason (Q2), unless it's held by structure.

➡️ (c). It keeps your ruling, needs no patches, and gives every agent one way to read any rule about the route, wherever it came from. Where a specific upstream rule clearly does harm, it can still become its own patch ticket.

---

When you answer, cover Q1, Q2, Q3 (revised), Q4, Q5 and Q6.