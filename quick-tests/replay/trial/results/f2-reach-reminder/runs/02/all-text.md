Your "Continue" doesn't answer round one, so Q1–Q5 stay open. The background search finished and reports that the factory's ways of departing from a rule disagree with each other. AGENTS.md now says to read each rule where it's written before telling you two of them conflict, so I'm doing that first.

---

I read each rule where it's written before telling you whether they conflict. That changes three of my five questions; Q4 and Q5 stand as asked.

**What reading them in place showed.** The search reported five ways of departing from a rule that "don't agree with each other." In context they mostly answer different situations:

- **Your instinct disagrees with the file, but the task isn't blocked.** Follow the file and tell you why your instinct differed (`template/AGENTS.md:16`).
- **A rule actually blocks the task.** Say so loudly and get a sign-off (`template/AGENTS.md:20`, `AGENTS.md`, "Phases").
- **No rule covers the case.** Decide, and record a Provisional row (`PHILOSOPHY.md:47-55`).
- **You drop a playbook step.** Keep it in the list as `skip: <reason>` (`poteto-mode/SKILL.md:113`). Delegation is the one step without that option (`feature.md:12`).

Two real problems remain:

1. **Nobody signs off for a subagent.** The sign-off line never says who signs off when no human is present, and an unattended subagent has none.
2. **"These" is ambiguous.** In the template, "These are good defaults" follows your note directly, so it could mean only the note or the whole file.

**What the evidence adds.** Two sources bear on this:

- **The run-2 audits:**
  - **The constraints audit sorted limits much like the old test did.** It checked limits on reading, running and output length, and kept safety rules and report format as safe. Its own late addendum then found that a report-format rule did comparable damage. The review brief requires a `spec:` citation from a ticket it never shows the reviewer. So a reviewer filed none of the 4 behaviour bugs in one PR, and honest reviewers downgraded real bugs.
  - **Some rules about method helped.** Examples: the mandatory trail review caught the owner's errors 3 times out of 3, and the delegation hook exists because prose alone didn't hold. You set each of those yourself.
- **The research for the ticket "Research how wording and missing context shape a reader's response"** separates what the writer *volunteers* from what the reader may *seek*. Holding back the writer's own conclusions protects the reader's independence. Nothing in it supports limiting what the reader may look for.

---

❓ **Q1 (amended) - What makes a rule binding?** Last round I said a rule describing the task itself, including "what done means", could be binding. The `spec:` gate breaks that test. It's a rule about what done means, and it caused readers to hold back findings they had already made. The research says this pattern, a bar on what may be reported, is among the costliest it found. So "what done means" can't be a safe category, any more than "protects the world" was.

That leaves ownership as the test, which also explains the rules that did good: each of them was set by you. Revised options:

- (a) A rule is binding only when its owner made it so, and it carries its reason. A rule with no owner, or no reason, is knowledge, not binding.
- (b) As (a), and in addition no rule may limit what the reader reports, whoever owns it, because filtering findings is the judge's job, not the finder's. (The judge is whoever weighs the findings afterwards.)
- (c) Ownership only, with no category ever exempt.

➡️ (a). It's tempting to add (b)'s exemption, but that is the same move that produced the old test: turning one symptom into the principle. If a reporting bar is wrong, the reason it must carry under (a) will show that.

---

❓ **Q2 (amended) - How should the writing carry knowledge about the route?** My earlier recommendation was to write route knowledge as something the writer knows, with its reason. That holds for a lane building something. For a lane judging something, the research says the writer's own beliefs about the work are what leads the witness, even when they're phrased as knowledge. That includes where the writer thinks the bugs are, and what it expects to find. Options:

- (a) Same rule for every lane: knowledge with its reason, never an order.
- (b) As (a). In addition, the writer of a judging brief leaves out its own conclusions about the thing being judged, while placing no limit on what the reader may look at.
- (c) Judging lanes get only the goal and the material.

➡️ (b). It limits what the writer offers, never what the reader may seek. That is the line the research draws, and it fits your Q9 preference for briefs.

---

❓ **Q3 (amended) - When a binding rule fights the goal, and nobody is there to sign off?** Reading the rules in place showed that the existing mechanisms cover the root session. The only gap is the subagent. Options:

- (a) The subagent stops that part, reports the conflict to whoever owns the rule (through its orchestrator), and goes on with the rest.
- (b) The orchestrator signs off, for rules it owns.
- (c) Both: the orchestrator decides for its own rules, and passes your rules up to you.

➡️ (c). Under (a) alone, the work stalls on rules the orchestrator could have settled itself. (c) also clears up "These" without new wording, because who signs off follows from who owns the rule.

---

**Q4** (an orchestrator passes down rules and binds only what it owns) and **Q5** (a budget is a fact the reader plans around, binding only when you set it) stand as asked last round.

Something out of scope: `MANUAL.md:168` still says "twelve ordered beliefs", but PHILOSOPHY has eleven since the cost belief was removed. I'll file it as a quick ticket unless you'd rather fold it into something else.