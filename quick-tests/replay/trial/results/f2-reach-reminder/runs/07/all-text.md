Your answers to round one haven't come in yet, so "continue" means I'll fold in what the background search found. It reports five ways the factory lets an agent depart from a rule, and says they point in different directions. Before I tell you they conflict, I'm reading each one where it's written.

---

Your round-one answers haven't come in yet, so I've used the time to fold in what the background search found. Q1, Q3, Q4 and Q5 stand as I asked them. Q2 is revised below, and there are two new questions.

**Do the ways to depart from a rule conflict?** The search found five ways the factory lets an agent depart from a rule and called them contradictory. I read each one where it's written, and they don't conflict. Each covers a different situation:

- **"Follow the file and tell me why your instinct differed"** (your note, [template/AGENTS.md:16](template/AGENTS.md:16)): an agent's instinct disagrees with a copied pattern for how the product is built.
- **"Say so loudly and get a sign-off"** ([template/AGENTS.md:20](template/AGENTS.md:20)): a default blocks the task itself.
- **`skip: <reason>`** (poteto-mode): the agent decides not to do a playbook step. The Feature playbook turns this off for one step, delegating the code, and gives its reason.
- **The "spec is silent" ladder** in the philosophy: no rule answers the question at all.
- **"Read again when a rule fights you"** in the manual: this one is addressed to you, not to an agent.

The real gap is that none of them tells a subagent what to do, because there is nobody to give it a sign-off. The nearest existing pattern is in the Feature playbook: a writer that can't implement a table cell as written "stops and reports the cell, and never fills it in." That is Q3's option (a), already in use.

**Other findings that bear on the questions:**
- **The run-2 constraints audit used the split you corrected.** It sorted limits into "protect the world" and "shape the search". Its own late addendum then found that rules it had filed as "report format" did comparable damage. The Standards review brief demands a citation from a ticket it never shows the reviewer, so reviewers demoted real bugs. On one PR with four hard bugs, a reviewer filed nothing. That rule limits how the work is finished, not how it searches, which supports your broader wording.
- **Some rules about the route did good.** The mandatory trail review caught an owner's mistake three times out of three. The delegation hook exists because an agent knowingly broke the rule while it was only prose. You set both rules, and both have a measured reason.
- **Many factory rules carry no reason at all.** Examples are "never an arena", the 150-line read cap in `knowledge`, and "nothing wider is redesigned".
- **The research note supports your framing.** "How wording and missing context shape a reader's response" is the output of the research ticket, on a research branch. It says the evidence favours your framing over the search-only one, and that no study of models has tested a limit on strategy as such. It also draws a distinction I hadn't: holding back what the writer volunteers (its own beliefs about the answer) protects a reader's independence, and that is different from limiting what the reader may look for. That distinction changes Q2.

---

❓ **Q2 (revised) - What the writer knows about the route, and what it believes about the answer**: A writer might add two different things to a brief.
- **What it knows about doing the work:** a trap, a tool quirk, a lesson that cost a run.
- **What it believes about the answer:** where it thinks the bug is, what it expects will be found, its own conclusion.

The options:
- (a) Include both, each with its reason.
- (b) Include the first, with its reason. The reader may take another route and says in its report that it did. Leave the second out of any brief to a lane whose job is to judge. Give it to other lanes only when it's labelled as the writer's belief.
- (c) Leave both out.

➡️ (b). The first kind saves the reader rediscovering something. The second kind is leading the witness, even when it's written as helpful context.

---

❓ **Q6 - Do rules that require more get treated differently from rules that forbid?** The route rules that did good share one shape: they make the reader do at least something, like run the trail review or check the blast radius. Most of the harmful ones forbid going further: read only this, stop after N, never an arena. The options:
- (a) A rule that requires more may bind when its owner sets it with a reason. A rule that forbids going further on the route never binds, except as a limit on authority under Q1.
- (b) Treat both under the Q1 test, with no separate distinction.
- (c) Rules that require more are always fine.

➡️ (b). The citation demand above was a requirement, and it acted as a wall: reviewers dropped real bugs to meet it. A rule that requires more still needs an owner and a reason. A second test would be one more thing for writers to misapply.

---

❓ **Q7 - What happens to an existing rule with no recorded reason?** The options:
- (a) Read it as route knowledge, not binding, until its owner supplies the reason.
- (b) Keep it binding until someone reviews it.
- (c) Leave this to the ticket "Decide the scope and order of reworking existing files".

➡️ (a) as the principle: a binding rule carries an owner and a reason, and a rule without both is knowledge. Which files get swept, and in what order, belongs to the rework ticket.

---

Unrelated to this ticket: [MANUAL.md:168](docs/knowledge/core/MANUAL.md:168) still says "twelve ordered beliefs", but the philosophy has had eleven since the cost belief was cut. I can file a quick ticket for that if you want.