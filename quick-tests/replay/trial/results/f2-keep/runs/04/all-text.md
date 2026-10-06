The background search finished. Three of its findings change the round I just posted, so here they are before you answer.

**1. A rule about what done looks like did as much harm as the reading limits.** The constraints audit kept rules about the report's form as harmless. Its own late addendum took that back. The Standards brief requires every hard finding to cite the spec, then never shows the reviewer the ticket. Honest reviewers therefore demoted real bugs. In one case a reviewer filed nothing on a PR that had four hard bugs, all behaviour bugs (`constraints-audit/ours-with-calls.md:110-116`, `answer-key-audit/report.md:117-119`). My Q1 treated "what done means" as safely binding. This shows a definition of done can quietly limit the route too. So Q1 needs a further test: a binding rule about the result must not demand something the reader can't produce.

**2. The factory has five ways to depart from a rule, and they disagree.** This bears on Q3.
- `template/AGENTS.md:20` says to say so loudly and get a sign-off first.
- Four lines above it, `template/AGENTS.md:16` says the opposite: follow the file, then explain why your instinct differed.
- `MANUAL.md` and the decisions log say to decide and record it as Provisional so you can overrule it.
- pstack has `skip: <reason>`, and the factory shuts that off for delegation.
- Scripts refuse a review until every flag reads `fixed:` or `accepted:`.

None of these says how a subagent gets a sign-off, and "never block on the human" pulls against the sign-off line. No audit has looked at these mechanisms. Whatever Q3 decides should replace them all, not become a sixth.

**3. Some route rules earned their place:**
- The mandatory trail review caught the owner's errors three times out of three.
- An agent skipped `architect`, and a hook bug survived four review rounds.
- The delegation rule was broken knowingly until a hook took it over.

All of these were set by you or recorded as decisions with a reason. That supports the "who owns it" half of my Q1 recommendation. The research on `research/wording-and-reader-context` points the same way: step-by-step method helps on simple tasks and for novices. It also notes that holding back what the writer volunteers is a different thing from limiting what the reader may look for. No study it found tests a limit on strategy as such.

That raises one more question:

❓ **Q6 - Does the philosophy need to change with this?** `PHILOSOPHY.md` leans the other way in three places:
- Line 23 praises playbooks that make an agent follow "a script rather than improvising".
- Belief 3 pushes rules down to hooks, which leave no room to depart from them.
- Belief 7 prefers a copied pattern over a first-principles idea.

The options:
- (a) Leave the philosophy alone. A script is fine wherever you own it, and that is consistent with the owner test in Q1.
- (b) Add a belief that the route belongs to the reader unless its owner says otherwise, and that every binding rule carries its reason.
- (c) Rewrite beliefs 3 and 7.

➡️ (b). Beliefs 3 and 7 are about where a rule lives and where ideas come from, so they can stay. What the philosophy is missing is the default for everything nobody owns, and that default is what this ticket is deciding. Also, any hook that holds a route rule should name a way out in its block message, as the git guard already does.

---

Q1–Q5 from the round above are still open, with Q1 and Q3 adjusted as described. I'm waiting for your answers before I record anything on the ticket.

Separately, `MANUAL.md:168` says there are "twelve ordered beliefs", but PHILOSOPHY has had eleven since your cost-belief commit. That's outside this ticket, so I'll file a quick ticket for it unless you'd rather fix it on your branch.