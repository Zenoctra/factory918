Yes, the research changes the round. Here is the revised round, which replaces round one.

**What the research changes:**

- **A rule about what "done" looks like can limit the work as much as a rule about how to do it.** Round one treated "what done means" as safe. The best-measured harm in the whole note is a reporting bar: a bar for what counts as worth reporting.
- **Readers mostly won't notice when a rule fights their goal.** So round one's Q3, where the reader reports a conflict when it notices one, can't be the main safeguard. It can only catch what slips through.
- **A writer can't find its own bad rules by trying harder.** What helped in both people and models was signal from the actual readers.

**Round one also made the mistake this ticket is about.** It gave you lettered options. In the research's clearest list experiment, four listed problems went from 2% of answers to 60%, even though people were explicitly invited to name a different one. So this round asks open questions. My recommendation after each one is my own view, and it leans the same way any recommendation does.

**Two cautions about the evidence:**
- No model study tests a limit on strategy directly. The model evidence covers reporting bars, formats, length limits and framing.
- None of the studies tested Opus 5.5. Several figures in the research note are marked as secondary sources.

Terms from round one still apply:
- **The goal** is what's wanted and what done looks like.
- **The route** is how the reader gets there.
- **A binding rule** is one the reader may not overrule by itself.

One new term:
- **The writer's needs** are what the writer wants from the result for its own later use: a format, a severity filter, a length, a citation.

---

❓ **Q1 - What makes a rule "absolutely necessary"?** Round one drew a clean line: the goal binds, the route is the reader's. The research breaks that line from both sides.

**First, the goal can itself be the limit.**
- When radiologists' images had an extra nodule added, they kept searching but raised their bar for reporting (Berbaum 2015).
- Anthropic reports the same in Claude. Told "only report high-severity issues", the model finds the bugs and then leaves out the ones below the bar. This is vendor guidance with no published numbers, written for Opus 4.8.
- Our own case: the `spec:` citation gate in `review-brief.sh` led a reviewer to file nothing on a PR that had four real bugs. Fable wrote: "not filed hard because the Standards brief carries no ticket criteria to cite."
- In the one model study of the "invisible gorilla" effect, a narrow task instruction stopped models reporting critical findings they reported without it. A separate critic given an open-ended brief recovered every one (Shin 2026, a single-author preprint). Any goal you write narrows what the reader sees.

**Second, some route rules are part of what's being asked for.**
- Forensic labs don't show the checker the earlier conclusion, because an independent judgment is the product. Prior conclusions biased examiners in 4 of 4 studies that tested it.
- The writer-cell rule puts tests before code, because tests written after the code don't test it.
- The trail review caught the owner's errors 3 times out of 3.

So the test I'd now propose: **a rule binds when the outcome its owner wants can't exist without it, and the rule says what breaking it would lose.**
- "Form your view before reading the writer's own report" passes, because an independent review is what was asked for.
- "Read only the diff" fails, because a good review doesn't need it.
- "Report only hard bugs" fails, because that's a writer's need, not part of the outcome (Q2).

Ownership stays part of the test. Only the owner of an outcome can say what the outcome needs. An orchestrator's guess about the route counts as knowledge, never as a rule. That guard matters: interrogators who expected guilt asked guilt-presuming questions. And in the one field test of commanders' intent statements, the statements written in practice were full of method.

The open part: you wrote about "rules that aren't absolutely necessary." Does "the outcome can't exist without it" capture what you mean? Or should "necessary" also cover rules the system around the task needs, such as your merge, files another subagent is working in, and secrets?

➡️ My view: there are two kinds of necessary. One is what the outcome needs. The other is a decision that belongs to someone else, like your merge or another subagent's files. Everything else is knowledge. I'm flagging that the second kind sits close to the old "protect the world" bucket you rejected. The difference I intend is that it asks whose decision the rule is, not what topic it covers. If you think that difference is too thin to matter, it should go.

---

❓ **Q2 - Should the writer's needs be met in a separate step?** The research's fixes share one shape: let the reader do the whole job, then apply what the writer needs in a later step.
- Anthropic's advice is to ask for every finding with its confidence and severity, and filter afterwards.
- Requiring JSON output hurt reasoning in one study, and answering in prose first and converting afterwards mostly removed the loss (Tam 2024; this one is disputed).
- Tight output budgets cut reasoning models sharply (Sun 2025).

Today the factory puts several of its own needs on the reader:
- the report shape that `review-comment.sh` checks;
- the `spec:` and `Documented step:` gates;
- the definition of "hard" in P18;
- caps on word count and number of findings.

The run-2 constraints audit filed the report format as safe. The research says it isn't free. Some of these needs are real: P18 exists because a script trusted a reviewer that counted code smells as hard bugs. Separating them doesn't drop the need. The reviewer reports everything with its own severity and evidence. Then a script or another subagent sorts, filters and asks for the citations.

A real budget you set, in time or money, is a fact about the situation, and the reader plans within it.

Should the writing standard say a writer's needs are met after the reader's work, not imposed on it?

➡️ Yes, as the default. The exception is where the format is the work itself, such as a ticket body that must have its sections. The extra step costs something. Weighing that cost belongs to the "Optimize token use and wall-clock time without losing reliability" map, with measurements, not to a cap on the reader now.

---

❓ **Q3 - What may the writer tell the reader about the route?** Round one said: pass it on as something the writer knows, with its reason, never as an order. The research sharpens where the line falls.

**Detailed method guidance hurts capable readers.**
- In a 60-study meta-analysis, step-by-step guidance helped novices (d = 0.51) and hurt experts (d = −0.43). The d values measure effect size: 0.2 counts as small, 0.5 medium, 0.8 large.
- Specific goals on complex, novel tasks made people switch strategies too often and learn less about the problem.

**But a fresh subagent knows little about the project, however capable it is.**
- Readers without background learn more when the text spells out the connections.
- In 16 studies, giving readers of medical tests the relevant clinical information improved their accuracy, and none found a loss.

So the line I'd draw is between **facts about the situation** and **the procedure someone derived from them**:
- "The worktree guard refuses `git` inside `$(...)`" is a fact about the situation.
- "Read the tier in two plain commands" is a procedure derived from that fact.

Give the fact and its reason. The reader works out its own route, and if its situation differs, it can work out a different one.

**The wording matters more for models than for people, in a different way.**
- Children given the same limits were less creative when the limits were worded as control than when they were worded as information.
- People push back against controlling wording. Models don't push back: they over-apply emphatic instructions. Current Claude models also read literally, so a literal reader treats even an example as a rule.

**The reason is what lets the reader fill the gaps.**
- No instruction can foresee the situation it will meet, as Garfinkel and Suchman both argue. The reader fills the gaps either way. The text decides whether it fills them well.
- Anthropic says the model generalizes from the reason it's given.

One kind of withholding still helps. The writer keeping its own conclusions and hopes out of the brief protects the reader's independence. That limits what the writer volunteers, not what the reader may go looking for.

Is facts-and-reasons, never the derived procedure, the line you want?

➡️ Yes. Playbooks are the hard case, so I put them in Q5.

---

❓ **Q4 - What should a subagent's report say about the rules it was given?** The research says the reader usually won't notice a rule fighting its goal.
- People given an open invitation to ask for help asked on 4% of the occasions it was offered.
- Models almost never ask on underspecified coding tasks.
- Claude 3.7 Sonnet mentioned a hint it had used only 25% of the time.
- Chess masters said they had looked for a shorter mate while their eyes stayed on the familiar one.

A reviewer under a reporting bar doesn't experience the bar as a conflict. It just leaves findings out.

So the report is not the safeguard; Q1 to Q3 are. But the report has a second job. It is the signal from real readers that, in the research, was the only thing that improved writers. Writers who read transcripts of real readers struggling with texts improved, and the gain carried over to new kinds of text. Reports that say which rules were followed at a cost, and which were departed from and why, would fix the rules and the templates over time.

**The wording of the request decides whether it works.**
- On-screen definitions labeled "essential" were opened on 81% of questions. Labeled "available", 23%.
- Telling the reader what to expect moves its bar. In lineups where the culprit was absent, instructions implying the culprit was present led 78% to pick someone, against 33% when told the culprit "may not be present".

So a closing "feel free to deviate" line is weak. A section headed "Departures" invites departures. A required section on which rules affected the work, and how, does neither.

Today the factory has five departure mechanisms, and they conflict. One would replace them all.

The open questions:
- Should every report carry that required section?
- When a binding rule fights the goal and nobody can sign off, is the answer still to stop that part, report it, and carry on with the rest?
- Does your live session keep "say so loudly and get a sign-off"?

➡️ Yes to the required section. Yes to stop, report and carry on, and never narrow the goal to fit the rule. Your live session keeps the sign-off, because you are there to give it.

---

❓ **Q5 - Should a rule about the route ever be enforced by a hook, a refusing script or a fixed playbook?** PHILOSOPHY belief 3 pushes rules down to the strongest rung, where there is nothing to overrule. Belief 7 prefers a copied pattern over a first-principles idea. `PHILOSOPHY.md:23` praises playbooks for making the agent "follow… a script rather than improvising."

**A refusing script is a measure, and readers write to the measure.**
- Managers paid on one measure of a strategy acted as if the measure were the strategy.
- Simply knowing they were measured was enough, with no pay attached.
- The `spec:` gate is that case.

**A hook is right for a binding rule.** The delegation rule failed in prose and holds as a hook. The git guard's message names a way forward. Put knowledge into a hook, though, and it becomes binding by accident.

The open questions:
- Should only binding rules be allowed into a hook or a refusing script, with every refusal naming its reason and a way forward?
- Should each playbook step have to earn binding (the outcome needs it, with its reason) or else become knowledge?

➡️ Yes to both. This ticket settles the principle. "Decide the scope and order of reworking existing files" applies it to the actual files. It also amends beliefs 3 and 7, which are core documents, so it needs your explicit sign-off.

---

❓ **Q6 - Is the goal statement itself part of this ticket?** Q1 showed that any goal narrows what the reader reports. One response is in the writing: state the purpose behind the goal, as commanders' intent states purpose and end state, so the reader can report what matters to the purpose even when it falls outside the task. The other response is structural. In Shin's study an open-ended critic recovered every finding the narrow task had suppressed. `spec-review` runs two reviewers, Standards and Spec, both narrow by design, so that study predicts a gap there.

Should this ticket decide how goals are written, and is the open-ended critic a new ticket on the map?

➡️ The writing half belongs here: every brief states the purpose above the task. The structural half, an open-ended lane beside the narrow ones, is a new ticket for the map, not something to decide here.