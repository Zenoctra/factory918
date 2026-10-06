Before I tell you the departure mechanisms conflict, I'm reading each one where it's written, as AGENTS.md now asks.

---

The search is done, and nothing you've written yet answers Q1–Q5, so they're all still open. The findings change two things in the round: Q3 needs rewording, and there's a new Q6.

**What the search found**

- **Rules that bounded the method sometimes helped.** The mandatory trail review caught an owner's mistakes all three times it ran. The delegation hook exists because writing the rule down didn't stop an agent breaking it. Each of these has a written reason, and each was set by you, either directly or by merging it. That fits the owner-plus-subject test in Q1.
- **The worst harm wasn't about searching.** The answer-key audit found that the Standards review brief requires a `spec:` citation for each hard bug from a ticket the brief never shows. So honest reviewers downgraded real bugs. One wrote that it "not filed hard because the Standards brief carries no ticket criteria to cite." That rule is about how the job gets finished, not where the reviewer looks, which is your wider point exactly. It's still live at `review-brief.sh:494`.
- **The run-2 constraints audit is graded against the old test.** It sorted limits into "safety, kept" and "report format, kept", which is the protect-the-world framing you've since retired. Its own addendum admits it skipped the `spec:` gate for that reason. Whoever reworks existing files (the "Decide the scope and order of reworking existing files" ticket) should re-judge its keep list, not adopt it.
- **The research branch for "Research how wording and missing context shape a reader's response" is already written** (`docs/research/wording-and-reader-context.md`) and points the same way. Specific instructions on method help on simple tasks and for beginners. Holding back what the writer volunteers is a different thing from limiting what the reader may look for. And no study of models tests a limit on strategy directly.

**A correction to my own Q3**

The search reported five mechanisms for departing from a rule that "don't agree with each other". I read each one where it's written, and they don't compete. Each answers a different situation:

| Situation | Mechanism | Where |
|---|---|---|
| Your instinct disagrees with the file | Follow the file, then say why you differed | `template/AGENTS.md:16` |
| A default fights the task | Say so loudly, get a sign-off | `template/AGENTS.md:20` |
| The spec says nothing | Decide, and record a Provisional row | `PHILOSOPHY.md:47-55` |
| You skip a playbook step | Leave `skip: <reason>` in the list | `poteto-mode/SKILL.md:113` |
| A writer can't build a test cell as written | Stop and report the cell | `feature.md:12` |

What's actually missing is narrower. None of these was written for a subagent whose brief contains a rule that fights its goal. The sign-off line sits in your note to the root session, and nothing tells a subagent how it would get a sign-off. So Q3 becomes:

❓ **Q3 (reworded) - How does a subagent handle a binding rule that fights its goal?** This is the one situation the existing mechanisms don't cover. The options:
- (a) Stop that part, report the conflict to whoever owns the rule, and carry on with the rest.
- (b) Break the rule and report it.
- (c) Narrow the goal to fit the rule.

➡️ (a), using the same "say so loudly" wording so it reads as one rule with two audiences rather than a sixth mechanism. Never (c).

---

❓ **Q6 - Is the report's shape part of the task, or part of the route?** In Q1 I counted "how to report" as task, something a template's fixed part may carry. The `spec:` gate shows a report rule can do two things:
- set the shape: where results go, in what form;
- set what qualifies to be reported at all, and that rule threw away real bugs.

The options:
- (a) The shape is task. A qualifying bar is route, so it's offered as guidance with its reason (Q2), and anything the reader noticed but couldn't place still gets reported.
- (b) Both are task, so the owner may bind either.
- (c) Both are route.

➡️ (a). A reader should never have to throw away something it saw because the form had no box for it.

---

One finding outside this ticket: `MANUAL.md:168` still says "twelve ordered beliefs", but PHILOSOPHY has had eleven since you cut the cost belief. Want me to file a quick ticket for it?

Waiting on your answers to Q1, Q2, Q3 (reworded), Q4, Q5 and Q6.