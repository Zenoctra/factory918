Yes, the research changes the questions. Three of my recommendations were wrong, and two questions were missing.

**What changed**

- **"What done means" isn't safe.** In round one I treated the goal and the definition of done as binding, and only the route as negotiable. But the research's strongest evidence of harm is about how work is *finished*.
  - A reporting bar such as "only report high-severity issues" makes a reviewer find a problem and then leave it out of the report. Radiologists do this, and Anthropic reports that Claude models do too.
  - The factory has its own case. The Standards reviewer on PR 99 filed none of its four behavior bugs as hard, because the brief gave it no ticket criteria to cite under the `spec:` gate.
- **How the goal is worded limits what the reader sees.** People counting basketball passes miss the gorilla walking through the scene. A 2026 preprint found that a narrow task instruction stopped models reporting critical findings they reported otherwise, and an open-ended second reader recovered every omitted finding.
- **The reader won't catch it.** My old Q3 relied on the reader noticing when a rule fought the goal, and saying so.
  - People rarely notice what an instruction made them miss.
  - Models used hints without mentioning them in 61–75% of cases.
  - Survey respondents who were told they could ask for clarification asked for only 4% of the clarifications that happened.
  - Current models almost never ask.
  - Claude models also read instructions literally and lean toward agreeing. So advice gets read as a rule, and a line saying "you may override this" rarely gets used.

  The protection has to come from how the brief is written and from structure, not from the reader's report.
- **Your common root has a name in the evidence.** Garfinkel and Suchman argue that no instruction written in advance can contain the situation it will meet. A rule is a prediction made without seeing the situation, and the reader is the one who sees it. You said the same about P109: "a prediction, not a constraint". This replaces my round-one test, which sorted rules by what they are about.
- **Two counterweights.**
  - Step-by-step method helps on simple tasks and for novices, and it hurts experts. A subagent is a capable reader that knows nothing about this project, so what helps it is facts about the project, not instructions on how to do its work.
  - Withholding relevant context also costs accuracy. Forensic science protects an examiner's independence by withholding other people's conclusions, never the evidence.

**How strong this is.** The evidence on limits to *method* comes from studies of people; no study has tested a limit on a model's strategy directly. The gorilla study on models is a single-author preprint. Anthropic's notes give no numbers and cover Opus 4.8, not 5.5. The solid model findings are the ones on reporting bars and framing.

**What that does to the round.**
- Old Q1 and Q4 merge into the new Q1.
- Old Q5 grows into a question about how work is finished (Q2).
- Two questions are new: how the goal is worded (Q3) and independence (Q4).
- Old Q2 and Q3 depend on what counts as binding, so they move to the next round, along with a new question about hooks.

The cases below are the ones I found, not the whole space. If you think of a case that Q1's test handles badly, that's a sign the test is wrong.

---

❓ **Q1 - What can make a rule binding?** "Binding" means the reader may not overrule the rule on its own. My proposed test is that everything in a brief is a prediction unless something other than prediction stands behind it. I found two things that can:

- **Authority.** The decision isn't the reader's to make. Merging is yours. The files another subagent is working in right now are its. The ticket's scope is what you asked for. Authority limits what the reader changes and decides. It never limits what the reader reads, thinks or reports: a finding outside the scope still gets reported and becomes a ticket.
- **A rule you set because real runs showed it was needed.** You made the trail review mandatory after it caught the owner's errors in 3 of 3 runs. You moved the delegation rule into a hook after a subagent broke it knowingly.

An orchestrator can bind a reader only through authority it actually holds. It can't turn its own expectation of the route into a binding rule; that is how the reviewer briefs went wrong.

The options:
- (a) the test above;
- (b) authority only, so even a rule backed by runs, like the trail review, becomes strong advice the reader can depart from;
- (c) no single test; decide case by case.

➡️ (a). Is there a third kind of justification I haven't seen?

---

❓ **Q2 - How should the writing treat rules about how work is finished?** Examples include reporting bars, caps on findings or words, expected counts, citation requirements, required formats and budgets. Under Q1 these are all predictions.

Anthropic's fix for the reporting bar applies to all of them. The reader reports everything it found, with its own confidence and severity. Any filter, cap or required shape is a separate later step, done by whoever needs it. A budget is stated as a fact about the situation, not as a limit. (People given the same limit as information, rather than as control, stayed more creative.) A format that a script needs is fine, as long as it never decides what may be reported: anything that doesn't fit the format still gets said.

The options:
- (a) always keep finding separate from filtering;
- (b) as (a), but a bar you set yourself may stay in the brief;
- (c) keep bars, but write down what each one costs.

➡️ (a). Under it, the `spec:` gate becomes a field the reviewer fills in when it can, not a condition for filing a finding.

---

❓ **Q3 - How should the goal be worded so it doesn't limit what the reader sees?** spec-review's two reviewers each have a deliberately narrow goal: one checks standards, the other checks the ticket. The PR 99 case shows the gap this leaves.

The options:
- (a) The brief states the purpose the job serves, not only the task. For example, it says why you need the review, not just "check the diff against the standards".
- (b) (a), plus a second reader with an open brief wherever a job is narrow by design.
- (c) Leave this to "Decide what the writing standard is and what carries it".

➡️ (b). The second-reader part is about how subagents are arranged, not how briefs are written, so I'd file it as its own ticket on this map.

---

❓ **Q4 - Can protecting a reviewer's independence justify limiting what it may examine?** "Read nothing beyond the brief" was defended as protecting independence. The forensic evidence says independence comes from what the writer leaves out of the brief: its own conclusion, what it hopes to find, and the result it expects.

The edge case is other people's conclusions on the same question, such as findings from earlier review rounds. In every study that told examiners about an earlier decision (4 of 4), the examiners were biased by it. But keeping a reader away from those findings is still a limit on what it reads.

The options:
- (a) Never limit what the reader examines; independence comes only from what the writer chooses to include.
- (b) (a), with one exception you set, reason included: a reader may be kept from other people's conclusions on the same question.
- (c) Independence can justify limits on reading in general.

➡️ (b). It's the only limit on reading I can find evidence for, and it is narrow.

---

**Next round, once Q1 is settled:**

- **How advice that doesn't bind is written** (old Q2). The research sharpens it in three ways:
  - Give facts the reader can't know, not method.
  - Write the fact, not the route. For example, [ticket.md:10](template/.agents/skills/poteto-mode/playbooks/ticket.md:10) says to read the tier "in two plain commands". The fact underneath is that the guard refuses `git` inside `$(...)`.
  - Keep "must", "never" and "only" for binding rules, so a literal reader can tell the two kinds apart.
- **What happens when a rule fights the task** (old Q3). Under Q1, the factory's five conflicting mechanisms for departing from a rule would become two. The brief would treat reporting a conflict as essential and say that "none" is a valid answer, not the expected one.
- **Which rules may move up to a hook or a script that refuses work** (new). PHILOSOPHY's belief 3 pushes rules toward the strongest enforcement available. But a hook that enforces a prediction takes away even the reader's ability to depart from it and say why.