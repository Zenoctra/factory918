The background search finished. You haven't answered round one yet, so nothing is settled. Three findings change how I'd put the questions.

**1. The factory has five different ways to depart from a rule, and they disagree.** Q3 matters more than I framed it.

| Mechanism | Where | What it says |
|---|---|---|
| Sign-off | [AGENTS.md:26](AGENTS.md:26) | Say so loudly and get a sign-off before breaking the rule. |
| Follow the file | [template/AGENTS.md:16](template/AGENTS.md:16) | Follow the file, then explain why your instinct differed. |
| Skip with a reason | poteto-mode | Write `skip: <reason>`, except for delegation, where skipping isn't allowed. |
| Record and decide | Provisional rows | Where the spec is silent, decide and record it so you can overrule. |
| Report at hand-back | Review scripts | `accepted: <reason>`, and "stop and report the cell, never fill it in". |

The sign-off line pulls against "never block on the human". No text says how a subagent gets a sign-off, and no record shows it was ever used. None of the run-2 audits looked at these mechanisms. So Q3 is really choosing one rule to replace all five, not adding a sixth.

**2. A rule about how the work is finished did harm too, which supports your broader wording over the old split.** The run-2 constraints audit used the old split itself and kept "report format" rules as safe. Its own late addendum admits that was wrong:
- The Standards brief requires a `spec:` citation from a ticket it never shows the reviewer.
- So honest reviewers demoted real bugs. One filed nothing on a PR with four hard bugs.

That rule bounds how the task is completed, not what gets searched. It also means the audit's "keep" verdicts rest on the framing you rejected. The ticket on reworking existing files will need to judge them again.

**3. The rules about the route that did good mostly share a shape.** You or an incident set them, and each carries its reason:
- the mandatory trail review, which caught owner errors 3 of 3 times;
- the delegation hook, added after an agent broke the prose rule while knowing it;
- the blast-radius rule, added after a hook bug survived four review rounds.

That fits Q1's "binding only if its owner said so" and Q2's "always with the reason". The research written for the research ticket (on the branch `research/wording-and-reader-context`) adds a counterweight: specific method helps on simple tasks. It also says no study tests a limit on strategy as such.

One new question comes from this. It's independent of the other five, so it joins round one:

---

❓ **Q6 - What way out does a rule held by structure leave?** Belief 3 in the philosophy pushes rules down to the strongest rung (a hook, a script, CI), and a hook leaves no room for the reader's judgment. Some hooks already name a way out: the git guard says "use --force-with-lease on your own branch, or ask", and the delegation hook says how to abandon a review. The options:
- (a) Every hook's block message names the reason and a way out. That makes the hook a binding rule under Q1 that still points somewhere.
- (b) Hooks hold only rules that are binding under Q1. A rule about the route never goes into a hook.
- (c) Leave hooks as they are; this ticket covers prose only.

➡️ (a) and (b) together. A rule about the route that's held in a hook can't be departed from. That's exactly what your correction warns against, just enforced in code instead of words.

---

A stale fact I noticed along the way: [MANUAL.md:168](docs/knowledge/core/MANUAL.md:168) says "twelve ordered beliefs", but the philosophy has had eleven since the cost belief was removed. That's out of scope for this map. I'll file it as a quick ticket unless you'd rather I didn't.

Q1–Q6 are all open; answer in whatever order you like.