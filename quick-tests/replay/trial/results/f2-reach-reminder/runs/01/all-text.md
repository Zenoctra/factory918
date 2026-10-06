The search finished. Before I report any of its claims that two rules conflict, I'll read each rule where it's written.

---

The search is back. None of Q1–Q5 depends on anything it found, so they all stand. What it found changes how strongly I'd recommend some answers, and it raises one new question.

**What it found**
- **Routes are bounded well beyond search.** The run-2 audits mostly looked at limits on what subagents may read, run or write. Their own addendum found that rules about how the work is finished did comparable damage. One example: the Standards review brief demands a citation from a ticket it never shows the reviewer. Honest reviewers then demoted real bugs, and in one PR a reviewer filed nothing at all when four hard bugs were present. That supports your correction: search was a symptom.
- **Some route rules did real good.**
  - The mandatory trail review caught the owner's errors 3 times out of 3.
  - The delegation rule was written only as prose until an agent knowingly broke it. Only then did you make it a hook.
  - Narrow grounding let a hook bug survive four review rounds, and that's where the blast-radius rule came from.
- **Most of the audits' fixes haven't landed.** These are still live:
  - the "Execute only the task and path scope the parent assigns" line;
  - the 150-line read cap in `knowledge`;
  - the citation gate in `review-brief.sh`.
- **The research note for "Research how wording and missing context shape a reader's response" is written.** It's on an unmerged branch.
  - It finds the strongest evidence supports your broader framing. The costliest findings in people are bars on what may be reported, step-by-step guidance for experts, and telling an observer what to look at.
  - It gives two counterweights. First, specific method helps on simple tasks and with novices. Second, holding back what the writer volunteers protects a reader's independence, and that is a different thing from limiting what the reader may look for.
  - No model study tests a limit on route directly.

**One conflict I checked and dropped.** The search reported that "follow the file and tell me why your instinct differed" contradicts "say so loudly and get a sign-off". Read where they're written in `template/AGENTS.md`, they cover different situations:
- The first is about the reader's taste disagreeing with a pattern.
- The second is about a rule blocking the task.

The real gap is narrower: nothing tells a subagent how to get a sign-off, which is Q3.

**How this moves the recommendations**
- **Q2:** The trail review and the delegation rule suggest one more line. When route knowledge keeps being ignored at real cost, the writer takes it to whoever owns the rule to make it binding. The writer never makes it binding on its own. The research also limits what (b) covers. In a brief for a reviewer, "the bug is probably in X" is leading the reader, not passing on route knowledge.
- **Q3:** The factory already has reader-side patterns that match (a):
  - a writer that can't implement a test cell stops and reports the cell;
  - a playbook step that gets skipped stays in the list with `skip: <reason>`;
  - writer flags have to end as `fixed` or `accepted: <reason>`.

  So (a) generalizes what already works.
- **Q4:** Two past cases support "no":
  - you ruled that the trail review's "at most" list was "a prediction, not a constraint";
  - you removed a rule a subagent had made out of one of your questions (ledger: "a model extends the intent without it being written").

---

❓ **Q6 - Does this treatment reach rules in vendored skills, or only the factory's own text?** pstack's router copies each playbook's steps into the todo list "verbatim … so the agent follows a script rather than improvising". That is a route rule by design, and you chose pstack for it. My memory records your 2026-09-24 ruling: "upstream pStack's constraints stay; it is Factory918-written text … that is suspect until proven." But the worst single limit the constraints audit found is in a pstack wrapper, and four of the worst ten are ours. The options:
- (a) Only the factory's own text. Vendored rules stay as written.
- (b) The factory's own text, plus a patch to any vendored rule that shows measured harm. A patch is the only route for changing a vendored skill anyway.
- (c) Everything, vendored included, judged by the same test.

➡️ (b). It keeps your 2026-09-24 ruling as the default. It lets evidence, not the new test, decide when an upstream rule changes. And pstack's own `skip: <reason>` already gives its scripts the kind of exit Q3 asks for.

---

The next round will ask how Q1 fits the rule that each rule lives on the strongest rung that can hold it. Hooks leave no way to depart, so whatever stays merely knowledge can't live in a hook. That depends on your answer to Q1, so it waits.