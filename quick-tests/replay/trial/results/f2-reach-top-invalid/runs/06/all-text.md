The background search is back. It doesn't settle anything for you, but it changes two of my questions and adds a third, so here are the facts first.

**What it found**

- **The factory has five ways to depart from a rule, and they contradict each other:**
  1. **Ask first.** `AGENTS.md:26` and `template/AGENTS.md:20` say to say so loudly and get a sign-off. Nothing says how a subagent would get one, and there's no record of it ever being used.
  2. **Comply first.** `template/AGENTS.md:16` says follow the file, then explain why your instinct differed.
  3. **Decide and record.** Where the spec is silent, the agent decides and writes a Provisional row you can overrule later.
  4. **Skip visibly.** pstack lets a skipped step stay in the list with `skip: <reason>`, but the feature playbook shuts that off for delegation.
  5. **Stop and report.** A writer that can't build a test cell as written stops and reports it, and flags must end `fixed:` or `accepted: <reason>`.
- **Rules about the route sometimes did real good.** The mandatory trail review caught the subagent owner's errors in all 3 of the 3 runs that used it. Narrow grounding let a hook bug survive four review rounds, and that's why the blast-radius rule exists. An agent knowingly broke the delegation rule, so a hook now holds it.
- **The philosophy leans toward rules on the route.** Belief 3 pushes rules down to the strongest rung, where prose can't override them. Belief 7 prefers a copied pattern over a fresh idea. The pstack playbooks are described as a script "rather than improvising."
- **The run-2 constraints audit has the same flaw you corrected.** It sorted constraints into the "protect the world / shape the search" bins. Its own addendum admits it filed process rules as "report format" and skipped them, like the `spec:` gate that made a reviewer file nothing on PR 99 despite 4 real bugs.
- **Most of the audit's recommendations aren't applied yet.** The "Execute only the task and path scope the parent assigns" line is still there. So are the `knowledge` skill's limit of 150 lines per read, the line in `ticket.md` saying "nothing wider is redesigned", and the `spec:` gate.
- **The wording research has the counterweight.** It's on the unmerged branch `research/wording-and-reader-context`. Step-by-step method helps on simple tasks and for novices. Holding back what the writer volunteers is different from limiting what the reader may look for. And no study of models tests a limit on strategy itself.

Q1, Q2, Q4 and Q5 from the last round stand as written. Q3 changes, and Q6 and Q7 are new.

---

❓ **Q3 (revised) - Which of the five ways to depart wins?** The question is still what a reader does when a binding rule fights the goal. Now it's also which of the five existing mechanisms survives, since "ask first" and "comply first" can't both be the default. The options:

- (a) **Stop and report** for binding rules: halt that part, tell the rule's owner, carry on with the rest. **Decide and record** for anything else: choose, act, and say in the report what you chose and why.
- (b) **Ask first** everywhere, with a defined channel to you even from deep subagents.
- (c) **Comply first, then explain**, everywhere.

➡️ (a). "Ask first" can't work unattended, and "comply first" is how a reviewer ends up filing nothing on four real bugs. Never let the reader narrow the goal to fit the rule.

---

❓ **Q6 - What about a rule on the route that has evidence behind it?** The trail review and the blast-radius rule are rules about the route, and each exists because a run failed without it. Under my Q1 test they'd be binding only if you own them. Should evidence count too? The options:

- (a) **Evidence doesn't make a rule binding.** A route rule with a measured reason is written under Q2 as knowledge with its evidence attached. The reader may still depart, but must say so and why in its report.
- (b) **A measured failure lets the rule become binding.** Its evidence and its owner are written down with it.
- (c) **It's binding only once a structural rung holds it**, like a hook or a script. Prose never binds the route.

➡️ (a), with one exception: when you've ruled on it, it binds by Q1. The reason travels with the rule, so a reader facing a case the evidence never covered can see that it doesn't apply.

---

❓ **Q7 - Does this ticket's answer reach the philosophy?** Beliefs 3 and 7, and the "script, not improvising" line, push toward rules on the route. Whatever we settle here either sits beside them or amends them. The options:

- (a) This ticket records the conflict, and ticket 155 ("Decide what the writing standard is and what carries it") decides whether the philosophy changes.
- (b) This ticket amends the beliefs directly once Q1–Q6 settle.

➡️ (a). This ticket decides how the writing treats binding rules. Rewriting the beliefs belongs to the standard.

---

I'm waiting on your answers to Q1–Q7 before I record anything on the ticket.