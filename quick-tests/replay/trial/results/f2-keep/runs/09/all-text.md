The background search is done. Nothing it found settles a question for you, but three findings change my round-one recommendations, so here they are before you answer.

**1. "What done means" can fight the goal too (affects Q1).** My Q1 test treated "what done means" as safely binding. The run-2 audits show a rule of exactly that kind doing real damage. The Standards review counted a finding only if it cited the ticket, but the reviewer was never shown the ticket. So honest reviewers demoted real bugs, and one reviewer filed nothing on a PR that had four hard behaviour bugs. The constraints audit missed this at first: it filed these rules as "report format", a category it kept, and only caught them in a late addendum. That audit also sorted rules the same way as the "protect the world / shape the search" test you corrected.

So I'd tighten Q1. A rule about the deliverable is binding only if it comes from the goal's owner, and the writer has to check it against the goal rather than assume it's safe. That puts more weight on the ownership half (b) of my recommendation.

**2. Some rules about the route did good (also affects Q1).** Several of them have a record:
- the mandatory trail review caught the owner's mistakes in three of three runs;
- the delegation hook exists because an agent knowingly broke the rule when it was only prose;
- the blast-radius rule came from a hook bug that survived four review rounds after an agent scoped its own work too narrowly.

Under my Q1 recommendation these stay binding only because you made them binding. Each has a dated reason in the ledger or a playbook. Many of the harmful rules have no reason written down: "never read more than 150 lines" has none on record, and Theo's reason for the dev-server rule was dropped when it was adopted. So I'd add one requirement: every binding rule carries its reason. A rule without a reason can't be judged when it fights the task.

**3. The factory has five ways to depart from a rule, and they disagree (affects Q3).**
- **Say so and get a sign-off**, in both AGENTS.md files. Nothing says how a subagent gets that sign-off, and the line pulls against "never block on the human".
- **Follow the file, then explain why your instinct differed**, in `template/AGENTS.md:16`. That's the opposite default: comply first, report afterwards.
- **Decide and record a Provisional decision** where the spec is silent.
- **Skip a step with a written reason**, from upstream pstack. One playbook switches this off for delegation.
- **Send it back to the owner:** writer flags that need a disposition, "stop and report the cell", and amending the design-hole artifact.

No audit has looked at these. So Q3 is really asking: should the writing standard have one way to depart from a rule? I'd still recommend (a) in Q3: stop that part, report to whoever owns the rule, carry on with the rest. That's close to the "send it back to the owner" family, which is ours and has a good record. The other four would then be reconciled to it, or would say why they differ.

**For Q2:** the research on the wording branch supports (b). Specific guidance on method helps on simple tasks and for novices. It also separates two things: holding back what the writer offers is different from limiting what the reader may go and look for. It also notes that no model study tests a limit on strategy as such, so on that point we're reasoning from human studies.

**Outside this ticket:** most of the constraints audit's recommendations haven't been applied. Examples still in place:
- "Execute only the task and path scope the parent assigns" in the pstack wrapper;
- the 150-line cap in `knowledge`;
- the review-brief limits;
- the gate that makes every finding cite the ticket.

That belongs to the ticket "Decide the scope and order of reworking existing files". Separately, `MANUAL.md` still says "twelve ordered beliefs" when PHILOSOPHY now has eleven.

Round one is still open, with Q1 and Q3 amended as above. Answer whichever you like, in any order.