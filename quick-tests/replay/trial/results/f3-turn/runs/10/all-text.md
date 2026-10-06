I'll read the research itself before I revise anything; so far I've only seen a subagent's two-line summary of it.

---

Yes, the research changes the round. I've read the whole note. It's on the branch `research/wording-and-reader-context` at `docs/research/wording-and-reader-context.md`, and the § numbers below refer to its sections. It changes the questions in three ways, and it comes with one warning about itself.

**1. The goal itself can limit the route.** In round one I treated the goal as safe and only the rules around it as risky. The research says otherwise.
- **Narrow tasks hide what's outside them.** People told to count basketball passes miss the gorilla. In the one model study of this (§4), an ordinary narrow task instruction stopped models reporting critical findings that they reported without it. A second reader with an open brief recovered all of them.
- **Reporting bars hold back what the reader already found.** The reader finds the bug and leaves it off the page. Radiology shows this, and so do Anthropic's evals of its own models (§4).

So the wording of the goal and of "done" belongs in this ticket.

**2. Suggesting a method has a cost.** In round one I recommended passing on what the writer knows about the route, with reasons. The research says:
- a familiar method blocks a better one, even when people say they looked for alternatives (§2);
- examples get copied into the answer (§2);
- guidance that helps novices hurts capable readers (§4);
- current Claude reads instructions literally, so a suggestion lands as an order (§11).

On the other side, a lane starting cold knows little about the project, and explicit context helps exactly that reader (§9). So the line moves: facts about the situation help; suggested methods anchor.

**3. A rule meeting a case nobody foresaw is the normal case, and readers don't report it unprompted.** Two sociologists, Garfinkel and Suchman, showed that no written instruction can foresee every situation it will meet (§4). Models act on hints without mentioning them (§3), and they almost never ask when a task is underspecified (§8). "Say so loudly" relies on the reader noticing, and mostly it won't.

**The warning.** The evidence is thinnest exactly where this ticket sits.
- No model study tests a limit on how a task is pursued (§4, §13).
- The model evidence is densest on reviewers. That's the same pull that produced the old "shape the search" framing.
- §12 offers its own two-way split: what the writer volunteers versus what the reader may look for. That's one lane's reading, and a two-way split is what went wrong last time. Below I put it to you as a question, not as a premise.

What changed from round one: Q1 is refined. Q2, Q3 and Q5 are new. Q4 reverses my old route-knowledge answer. Q6 extends the old conflict question. Q7 is the old "who may bind" question with one observation added. Q8 changes my budget answer. Q9 and Q10 are small and new.

---

❓ **Q1 - What makes a rule binding?** In round one I said: the goal, what done means, and the limits of authority, made binding only by their owner. The research splits "what done means" in two:
- **The purpose and end state** are the goal.
- **A count, a cap, a citation gate or a required format** is a measure of the goal. Measures replace goals without anyone noticing. Police measured on crime rates stopped recording crimes. In experiments, simply knowing a measure existed was enough, with no reward attached (§4).

Your ruling on P109 already said this ("a prediction, not a constraint").

The options:
- (a) Binding means the purpose, the end state and the limits of authority, as their owner set them. A measure is evidence of done that the reader may argue with, never the goal.
- (b) As in round one: measures count as part of done.
- (c) No single test.

➡️ (a).

---

❓ **Q2 - How open is the goal written?** A goal narrower than what's really wanted limits the route without looking like a rule, so nobody catches it. The options:
- (a) State the goal as wide as it truly is, with its reason.
- (b) Also add a line asking for anything noticed outside the task.
- (c) Where a miss is costly, add a second reader with an open brief, as in the study that recovered what the narrow task hid.

(b) on its own has a measured weakness: a list of four problems with an explicit "or name another" slot still drew 60% of answers to the four, against 2% when the question was asked openly (§2).

➡️ (a) always, and (c) where a miss is costly; (b) is not the fix. Whether (c) belongs to the writing or to the playbooks is for "Decide what the writing standard is and what carries it". Here I'd only decide that a too-narrow goal counts as a limit on the route.

---

❓ **Q3 - What happens to reporting bars?** Examples are "only hard bugs", "under 400 words" and "cite a spec line or don't file". The reader still does the work, and the bar cuts its report. Anthropic's advice for its own models is to ask for every finding with a confidence and a severity, then filter in a separate step (§4). The run-2 answer-key audit found a case of this: the Standards brief demanded a `spec:` citation from a ticket it never showed the reviewer, and a reviewer filed nothing on a PR that had four real bugs.

The options:
- (a) The reader reports everything it found, each item with its own confidence and severity. Any bar is applied afterwards by someone else, and filtered-out items stay visible.
- (b) Bars are allowed when their owner set them.
- (c) Keep things as they are now.

➡️ (a). Under it, the `spec:` gate becomes a filter after the report, not a condition for filing. Changing the script is a later ticket; this decides the rule.

---

❓ **Q4 - Facts about the situation, or suggested methods?**
- **Facts:** "the guard refuses `git` inside `$(...)`", "paths here contain spaces", "another lane is editing these files".
- **Methods:** "start from the tests", "read X first", "check these five things".

Facts fill gaps a cold reader can't see. Methods anchor the reader. Current Claude reads instructions literally, so a method offered as "what worked for me" still lands as an order. For this reader, a middle category of rules it may override mostly doesn't exist.

The options:
- (a) Give facts, each with why it matters, and leave methods out. A method that really is required becomes binding and goes through Q1 and Q7.
- (b) Give facts and methods, with methods marked as optional and given a reason. This was my round-one answer.
- (c) Allow methods for simple, mechanical jobs.

➡️ (a). The counterweight is real: method helps on simple tasks and for novices. But a mechanical job's method usually is its goal ("run this script"), and then it gets stated as the goal. Your Q2 answer from charting points the same way: if you could predict the better strategy, you could write it down, and the point is to leave room for the one you can't.

---

❓ **Q5 - What the writer leaves out.** This kind of rule binds the writer, not the reader. Forensic science protects independence by keeping the writer's conclusion out of what the examiner sees:
- Fingerprint experts shown suggestive context contradicted their own earlier decisions.
- Telling a code reviewer the code was bug-free cut detection from 97% to 4% for a small model, and from 96% to 89% for Claude Opus 4.5 (§3).

Withholding relevant information hurt too: in 16 studies of doctors reading medical tests, having the clinical information improved accuracy (§3). The field's line is that relevant context goes in, and the writer's conclusions, hopes and expected counts stay out.

The options:
- (a) Decide here that this restraint on the writer is a legitimate kind of rule.
- (b) Leave it to "Decide what the writing standard is and what carries it", and keep this ticket to rules on the reader.

➡️ (a). Limiting the reader and leading the reader are two halves of the same failure. The caution above applies, though: this is the research lane's two-way split. I'd adopt it as one consideration, not as the test.

---

❓ **Q6 - When a binding rule fights the goal.** The factory has five mechanisms for this today, and they conflict:
- say so loudly and get a sign-off first;
- follow the file, then explain why your instinct differed;
- `skip: <reason>`;
- make the call and record it under Provisional;
- `accepted: <reason>`.

What the research adds:
- Conflicts are the normal case, readers rarely notice them, and models tend to agree with the writer.
- Telling people that checking definitions was *essential* rather than *available* raised checking from 23% to 81% (§8).
- A medical handoff routine whose last step has the receiver restate the plan cut errors by 23% (§10).
- In a study of army officers, a company commander's actions matched the battalion commander's stated intent, other than by coincidence, 34% of the time (§4).

The options:
- (a) As in round one: stop that part, report to the rule's owner, finish the rest, and never narrow the goal.
- (b) (a), plus a required part of every report: where a rule and the goal pulled apart, and what the reader did about it.
- (c) (b), plus the reader restating the goal in its own words at the top of its report, so drift is visible.

➡️ (c), replacing all five mechanisms. The restatement costs a paragraph. It's the only check I found with a large measured effect on whether intent survives a handoff.

---

❓ **Q7 - Who may make a rule binding?** My recommendation is unchanged. An orchestrator passes your rules down and binds what it owns. It makes nothing binding from its own guess about the route.

One observation, which is my reading of three cases and not a finding. Three route rules here have a record of doing good: the mandatory trail review, the delegation rule and the blast-radius pass. Each one adds an independent reader or keeps roles separate. None of them narrows how a lane does its own part.

➡️ As in round one.

---

❓ **Q8 - Budgets.** In round one I recommended stating a budget as a fact. The research weakens that:
- Simply knowing a measure exists makes people treat it as the goal (§4).
- In one study, a tight output budget cut a reasoning model from 72% to 54% (§4).

Caps on findings and output are covered by Q3. The options:
- (a) State the budget as a fact.
- (b) A budget its owner set is binding.
- (c) Put no budget in the brief. Time and token limits are enforced outside the reader, and a reader stopped by one reports what it didn't get to.

➡️ (c) as the direction. How it's enforced goes to "Optimize token use and wall-clock time without losing reliability", which has the measurements.

---

❓ **Q9 - Which words the standard uses.** "Goal", "route" and "binding" are words I coined in this conversation. Two different pairs of people pick the same term for a thing about 10% of the time. Speakers reuse a term they coined 48% of the time with the same partner and 18% with a new one, because they sense it won't land (§7). The standard will be read by agents who were never here.

The options:
- (a) Keep my terms and define them in a glossary.
- (b) Write the standard in plain words and in your own sentence ("how the task is pursued or completed"), with no coined terms.

➡️ (b).

---

❓ **Q10 - How firm these decisions are.** Most of the support is evidence about people. The model studies mostly used 2022–2025 models, and the core of this ticket is untested on models.

The options:
- (a) Decide now, and mark which decisions rest only on evidence about people. Hand "Decide how we'll know the writing works" two experiments: the same open task given with and without an illustrative list, and with and without a suggested method.
- (b) Wait for measurement before deciding.

➡️ (a). Waiting would leave every brief written in the meantime under the current rules, which the run-2 audits already found lacking.