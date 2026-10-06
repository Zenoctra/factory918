Yes, the research changes the questions. Below is what changed, then the round again, rewritten.

## What changed

**1. The goal/route split I proposed is too clean.** In round one I treated the task statement as safe and the route as the danger. The research's strongest findings say the task statement is itself the most powerful rule on the route:
- People counting basketball passes miss a gorilla walking through the scene.
- In one 2026 study, models given a narrow task stopped reporting critical findings they reported without it. A second model with an open brief recovered every one.
- A bar on what to report ("only high-severity", "don't nitpick") makes readers withhold findings they already made. Anthropic reports this of its own models: recall falls even as bug-finding ability rises.

So this ticket is also about how the goal is written, not only which extra rules get added. This is also why the review script's rule that a serious finding must cite the ticket hurt so much. It looks like a definition of "done", but it worked as a cap. On one PR it led a reviewer to file nothing when the PR had four real bugs.

**2. Your position has a reason beyond the reviewer evidence.** Two sociologists, Garfinkel and Suchman, argue that no instruction written in advance can contain the situation it will meet. The reader will fill the gaps whatever you write. The only choice is whether the text helps it fill them well. That is your "leave it open for something you CAN'T predict", reached from the nature of instructions rather than from one failure mode. It also explains why "stop limiting search" was a symptom, not the diagnosis.

**3. It shows where the position doesn't hold.** I would have glossed over this.
- **Simple tasks and beginners.** Specific goals and step-by-step guidance help on simple tasks and for beginners. They hurt on complex, novel tasks and for experts. A subagent is a capable reader who is new to this project. The research says what such a reader needs is *context*: facts and explicit connections. It does not need *method*.
- **Holding back is not limiting.** In forensics, keeping the writer's own conclusions out of the brief protects the reader's independence. But withholding context relevant to the task makes the reader less accurate. Holding back what the writer volunteers is a different act from limiting what the reader may look at.

**How strong the evidence is.** No model study tests a limit on *strategy* directly. The strong model evidence covers reporting bars, framing, format and length. For limits on method, the human evidence makes a prediction, but it isn't proof. "How we'll know the writing works" can test it.

**The format changes too.** Round one gave you lettered options and a three-item list in Q1. That is the closed question your own point warns about. In one survey experiment, four problems offered in a list went from 2% of answers to 60%, even with an "other" slot. So each question below states the problem and my view, with no list of choices. Answer in any direction.

Terms below:
- **Purpose** is why the work exists and what end state it serves.
- **Route** is how the reader gets there.
- **Binding** means the reader may not overrule it alone.

---

❓ **Q1 - What makes a rule binding, and who can make one?** In round one I proposed that a rule binds when it describes the task, not the route, and that only the owner of a decision can make a rule binding. Point 1 above breaks the first half, because "what done means" can hide a cap. My revised view is that two things bind:
- the purpose;
- whose decision something is.

Only the person who owns a decision can make a rule about it binding.

Three test cases:
- **The delegation rule** is route, and it binds because you set it. A hook holds it.
- **A vendored playbook you adopted, such as pstack's.** Does adopting it make every step binding? I'd say no. Adopting it makes it the default route you chose. It binds only where you or its author said it must. pstack already works this way: a step can be skipped with a written reason, except where it says "mandatory".
- **A rule a subagent invents in its own brief to another subagent.** It is never binding. A briefing that carries the writer's guess shapes what the reader finds: interrogators who expected guilt asked guilt-presuming questions. Each added rule also weakens the others. In one study, models given 500 instructions at once followed 68%.

➡️ The purpose and the limits of authority bind, and only their owner can bind them. Everything else is offered, not imposed.

---

❓ **Q2 - How should the purpose be written, given that the task statement steers what the reader sees?** A narrow task tells the reader what not to see. One answer is to state why the work exists and what it serves, not just the task. The reader is then told that anything it notices outside the task that bears on that purpose belongs in its report.

Military doctrine works this way: the commander states the intent and leaves the method open. But the one field test found that only a third of junior officers' actions matched the intent. Commanders also kept slipping method into their intent statements. So writing the purpose is necessary but not enough, and the measurement ticket has to check it. The opposite risk is real too. Prompts asking a model to find and fix problems raised its false positives. "Report anything" can turn into noise or manufactured dissent.

➡️ Write the purpose and the end state. Make the invitation to report beyond the task a fixed part of every brief, so it is never optional. Findings beyond the task are labelled as such, so the person reading the report can weigh them separately.

---

❓ **Q3 - What may the writer say about the route?** Round one's answer was: knowledge, with its reason, never as an order. The research sharpens that in three ways:
- **Facts over steps.** For a reader new to the project, the useful thing is facts about the ground: what is there, what broke before, how the pieces connect. Steps are not.
- **Reasons travel.** A rule given with its reason is followed better and adapted better, in people. Anthropic says its models generalize from the reason.
- **Literal reading.** Current Claude models read literally, so words meant as illustration bind harder than intended. Route knowledge has to be marked as knowledge, or it will be read as an order.

The counterweight is that steps do help on simple, well-understood jobs.

➡️ The writer offers facts and reasons, marked as what it knows. It may offer steps on a simple job, but never require them unless the owner did (Q1). Leaving the suggested route always goes in the report.

---

❓ **Q4 - What happens to reporting bars, caps and budgets?** This is where the evidence is strongest. A bar on what to report suppresses findings the reader already made, in people and in Claude. A measure also tends to replace the goal it was meant to track, even with no reward attached to it. And tight output budgets cut reasoning models' accuracy sharply.

My proposal:
- **No bar on reporting.** No reader is told what is too small to report. It reports everything it found, with its own confidence and severity.
- **Filtering happens in a separate step afterwards.** That step decides what blocks the merge and what counts as hard.
- **The factory's definition of "hard" stays, as a label.** It exists because a reviewer once called style complaints serious and the script trusted it. The reviewer applies the label; it no longer decides whether a finding gets reported. The rule that a serious finding must cite the ticket becomes a label in the same way.
- **Effort budgets (time, tokens) may be stated** as a fact about the situation, with the reason, and the reader plans within them.
- **Length caps on output: none.**

➡️ As above. Reworking the review script is the rework ticket's job. This ticket only settles the principle.

---

❓ **Q5 - Is the writer holding back its own conclusions a rule on the route?** "Read only the diff" was justified as protecting the reviewer's independence. In forensics, independence comes from the writer holding back its conclusions and hopes. It does not come from limiting what the examiner may look at. Withholding context relevant to the task made readers less accurate in every study of it.

➡️ They are two different things. This ticket covers rules on the reader. Holding back what the writer volunteers is part of not leading the witness, and belongs to the ticket deciding the writing standard. This ticket should name the distinction, so independence can never again be the reason for limiting what a reader may look at.

---

❓ **Q6 - What does the reader do when a binding rule stands between it and the purpose?** The factory has five ways to depart from a rule now, and they conflict. The research adds that readers who misunderstand rarely know it and rarely ask, even when invited. Survey respondents told they could ask did so 4% of the time. Current models almost never ask on underspecified coding tasks. But respondents told that definitions were *essential* checked them 81% of the time, against 23% when told they were *available*. So "say so if a rule fights you" fails as an optional line.

➡️ One mechanism replaces the five. Every report has a section that is always filled in, never "if any". It says where the reader left the suggested route and why, and where a binding rule stood between it and the purpose. When a binding rule fights the purpose, the reader doesn't break the rule and doesn't shrink the purpose. It finishes what it can and puts the conflict at the top of its report for the rule's owner.

The section is evidence, not proof. Models mention the hints they used only 25–39% of the time, so the measurement ticket has to check it. One further idea comes from hospital shift handoffs: the receiving doctor restates the plan, and the handoff program that required it cut medical errors by 23%. The reader could restate the purpose at the top of its report, so a misreading shows up early. That is the templates ticket's call; I'm flagging it here.

---

❓ **Q7 - How are binding rules worded?** Three findings bear on this:
- A prohibition keeps the forbidden idea active and says nothing about what to do instead, so the model lands on some other fixed habit.
- Current Claude models over-apply emphatic wording.
- In people, the same limit hurts creativity when worded as control, and doesn't when worded as information.

➡️ A binding rule says whose decision it is, what to do instead, and why, in plain words. For example: "Merging is Manuel's: leave the PR open and say it's ready", rather than "NEVER merge". Where a hook holds the rule, the prose only gives the reason.

---

Q6 and Q7 assume my answer to Q1. If you answer Q1 differently, I'll ask them again. The full research note is [here](https://github.com/Zenoctra/factory918/blob/research/wording-and-reader-context/docs/research/wording-and-reader-context.md); section 4 is the part for this ticket.