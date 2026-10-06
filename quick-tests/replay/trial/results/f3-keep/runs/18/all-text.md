I've read the whole research note. The research does change the round, and it shows my round-one answer to Q1 was wrong. Below are the three big changes, then the revised questions.

The terms I use:
- **The goal** is what's wanted and what "done" looks like.
- **The route** is how the reader gets there.
- **A binding rule** is one the reader may not overrule by itself.
- **A bar** is a threshold that decides which findings get reported.

## What changed

**1. My Q1 test would have approved the worst case the research measures.** I said a rule is binding when it states "what done means". A reporting bar is a definition of done, and it is the harm the research measures best:
- Radiologists who spotted a second abnormality often searched just as hard, then left it out of the report (Berbaum 2015).
- Anthropic's own guide says the same of Claude. When a review prompt says "only report high-severity issues", the model finds the bugs, then leaves out the ones below the bar.
- The run-2 audit found it here too. A reviewer model obeyed the `spec:` citation gate and filed nothing on a PR that had four real bugs.

So sorting rules by subject doesn't separate the harmful ones. My list of three led me, the same way the reviewer example led the old test.

**2. Offering a method costs something even when it isn't an order.**
- A method you already know can hide a better one (chess masters stuck on a familiar mate; Codex copying lines of an example function into 32–61% of its solutions).
- Current Claude reads instructions literally, so words meant as illustration bind harder than the writer meant.
- Guidance that helps novices hurts experts. A subagent starting cold is an expert at how to work but a novice about this project.

**3. "Report it when a rule fights the goal" only works if the reader notices, and readers rarely do.**
- People asked for clarification on 4% of the occasions it was offered.
- Claude 3.7 Sonnet mentioned a planted hint it had used in only a quarter of cases.
- In the one model study of a narrow task instruction (Shin 2026), the instruction hid findings the same models reported otherwise. A second reader with an open-ended brief recovered all of them.

**How strong the evidence is.** The human findings on reporting bars, novice-versus-expert guidance and noticing (the gorilla studies) are replicated. The Anthropic guidance covers Opus 4.8, not 5.5, and publishes no numbers. Shin is a single-author preprint. Some figures below are second-hand. No study tests a limit on strategy in models directly. Treat all of this as good reason to lean one way, not as proof.

I renumbered the questions. Old Q4 is folded into Q1, and four questions are new.

---

❓ **Q1 - What makes a rule one the reader may not overrule?**

I now recommend against my round-one test by subject. The research suggests these options:

- (a) **By owner.** A rule binds only when someone with authority over that decision made it binding: you; a ticket's author, for its scope; whoever owns a file another subagent is working in right now. The rule carries its reason, so the reader can tell when it has hit a situation the reason didn't foresee. Garfinkel and Suchman argue that no rule written in advance can contain the situation it meets, and the reason is what the reader works from in that gap.
- (b) **By mechanism.** Anything that must hold is held by structure (a hook or a script), and all prose is information. This matches the research on wording:
  - controlling wording lowers people's creativity;
  - emphatic wording makes Claude over-apply an instruction;
  - a prohibition keeps the forbidden thing in mind without saying what to do instead.

  Its limit: no hook can hold "don't redesign beyond the ticket's scope".
- (c) No binding category. Each rule is argued case by case in the standard.

➡️ (a), written the way (b) suggests. In prose, a binding rule is a fact about who decides and why, not a command. For example: "Merging is Manuel's decision; he reviews every PR before it lands." Where a rule has to hold no matter what, structure holds it. This also settles old Q4: an orchestrator binds only what it owns, and passes down what you and the ticket bind. The two route rules that earned their place, the trail review and the delegation rule, fit this: you set both, and each has a reason and a record behind it.

---

❓ **Q2 - How does the writing carry what the writer knows about the route?**

In round one I said to pass route knowledge on with its reason. The research says to split that knowledge in two:

- **Facts about the situation** that the reader can't see from where it starts. An example from our files: the worktree guard refuses `git` inside `$(...)`.
- **The method the writer built from those facts**: "read the tier in two plain commands" ([ticket.md:10](template/.agents/skills/poteto-mode/playbooks/ticket.md:10)).

The reader is a novice at the first and an expert at the second. Clinical context made readers of medical tests more accurate in all 16 studies of it, and step-by-step help made experts worse.

- (a) Leave route knowledge out.
- (b) Give the facts and why they matter, and leave the method to the reader.
- (c) Give the method, as knowledge, with its reason. This was my round-one answer.

➡️ (b). If some knowledge can only be said as a method, say it as "what worked, and why", and say plainly that it is one way, not the way.

---

❓ **Q3 - What does the reader do when a binding rule fights the goal?**

The factory has five answers today, and they disagree:
- sign off first;
- follow first and explain;
- skip with a reason;
- decide and record a Provisional decision;
- mark the flag `accepted:`.

Whatever you choose here replaces all five. The research adds that relying on the reader to notice the conflict is not enough.

- (a) Stop that part, report the conflict to the rule's owner, and carry on with the rest. This was round one.
- (b) (a), plus every report says, without being asked, three things:
  - what the reader understood the goal to be;
  - which rules shaped its work;
  - what it would have done without them.

  A handoff program in nine hospitals cut medical errors 23%, and its last step has the receiver restate the plan. This line is the written version of that step.
- (c) Break the rule, then report it.

➡️ (b), and never narrow the goal to fit the rule. One caution: this line is self-report, and models don't reliably report what moved them. It makes some conflicts visible, not all of them. Checking how many it catches belongs to "Decide how we'll know the writing works".

---

❓ **Q4 - Where do bars on the result go?** (new)

"Only report high-severity issues", "at most N findings", "cite from this list" and "it counts as hard only with a `spec:` line" are all bars. Each one lets the reader do the work, then decides how much of it reaches the page. Anthropic recommends asking its models for every finding with a confidence and a severity, and filtering in a separate step.

- (a) The reader reports everything it found, with its own confidence and severity. Whoever owns a bar applies it afterwards, in a script or a later step. A bar never goes in the reader's brief.
- (b) Bars stay in briefs, with their reasons.
- (c) Decide case by case.

➡️ (a). This covers scripts too. A script may check the shape of a report, but a gate that drops or demotes findings is a bar, and it moves downstream. The live case is the `spec:` gate at [review-brief.sh:494](template/.agents/skills/spec-review/scripts/review-brief.sh:494).

---

❓ **Q5 - Can cost or time justify a limit on the route?** (revised)

In round one I said a budget is stated as a fact, never as a limit. The research adds two things:
- A number in a brief is an anchor, and stronger models moved toward anchors more consistently.
- Tight output budgets cut reasoning models' accuracy sharply. One went from 72% to 54% when capped at 1,024 tokens (a second-hand figure).

So even a budget stated as a fact pulls on the reader.

- (a) No budgets in the writing. The efficiency map handles cost through how subagents are dispatched, not through what they're told.
- (b) A budget you set may appear, as a fact with its reason.
- (c) Budgets may be limits.

➡️ (b) for a budget you set yourself; (a) otherwise. "Optimize token use and wall-clock time without losing reliability" can revisit this once it has measurements.

---

❓ **Q6 - What happens when the method is the job?** (new)

Sometimes the method really is what's wanted: "run these six verification commands and give me the output". Specific direction helps on simple tasks. The risk is the writer: writers overestimate how well they're understood, so a task can look simpler from the writer's side than it is.

- (a) No separate class. When the method is what's wanted, the writer states it as the goal, with the reason ("I need exactly these outputs because CI runs exactly these").
- (b) A separate class of "simple tasks", where method rules are fine.

➡️ (a). The writer would be the one judging what counts as simple, and the research says the writer is the one who misjudges.

---

❓ **Q7 - Does this ticket also cover rules on the writer?** (new)

The forensic research separates two kinds of rule hidden in your examples:
- **Rules on the reader** limit what it may look for, such as "read only the diff".
- **Rules on the writer** govern what it volunteers, such as its own conclusion about the diff or how many bugs it expects.

Withholding the writer's conclusions protects the reader's independence, and the evidence for that is strong. When a lineup witness was told the culprit was present, 78% picked someone, against 33% when told the culprit might not be there (a second-hand figure). Holding back a conclusion is a rule on the writer, not a limit on how the reader works.

- (a) This ticket covers rules on the reader only. The writer's restraint goes to "Decide what the writing standard is and what carries it", and this ticket records the distinction so nobody mistakes withholding a conclusion for limiting a search.
- (b) This ticket covers both.

➡️ (a).

---

**Next round, once Q1 is settled.** Three questions wait on Q1:
- Which rules should be held by a hook or script. The destination asks for "the highest rung each rule can reach", and a route rule held by a hook is the hardest wall there is.
- Whether briefs and docs should restate rules a hook already holds.
- How this stance meets [PHILOSOPHY.md:23](docs/knowledge/core/PHILOSOPHY.md:23), which says playbooks make the agent "follow a script rather than improvising".

These are the edges of the question I can see, not its boundary. If you see it differently, say so and I'll redraw the round.