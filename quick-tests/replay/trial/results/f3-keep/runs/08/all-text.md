I read the whole research note, and it changes the round. One recommendation was wrong. Two questions are new, and the others now rest on evidence rather than my opinion.

**What was wrong.** In round one I treated the goal and "what done means" as safe ground, with only rules about the route at risk. The research says otherwise. Four findings show that the statement of the task itself narrows what the reader does:

- **A narrow instruction hides what the reader can see.** People counting basketball passes missed a gorilla walking through the scene. In one 2026 preprint, models given a focused task stopped reporting critical findings they reported otherwise, and a separate critic with an open brief recovered all of them.
- **A bar on reporting makes readers hold back findings they already made.** Radiologists kept searching but raised their threshold for saying so. Anthropic reports the same of its own models when a review prompt says "only report high-severity issues".
- **A measure stands in for the goal.** Managers paid on one measure of a strategy acted as if the measure were the strategy.
- **The factory has its own case.** The `spec:` citation gate is a definition of done. Under it, a reviewer filed nothing on a PR with four real bugs.

So the danger isn't a category of rule. It's anything in the text that narrows how the reader goes about the task, or what it counts as done, more than whoever owns the task meant. That includes the goal itself.

**How far the evidence reaches.** Most of it is about people. No study tests a model under a limit on method as such: which files it may read, which order it must work in. The model evidence covers reporting bars, formats, framing and length budgets, and almost none of it is one model briefing another. Below, I say which recommendations rest on model evidence and which on human evidence only. The research note is on [its branch](https://github.com/Zenoctra/factory918/blob/research/wording-and-reader-context/docs/research/wording-and-reader-context.md); section numbers below refer to it.

Terms: the **route** is how the reader gets the task done. A **binding** rule is one the reader may not overrule by itself. The **owner** of a rule is whoever has the authority it rests on. The options under each question aren't the edge of the answer.

---

❓ **Q1 - What does this ticket cover?** The title says "rules", but the research shows unstated bounds narrow the reader as much as stated ones. These include:
- a goal stated narrower than it really is;
- a list that turns into multiple choice;
- an expected result ("zero items is the expected result");
- a format the answer must fit.

Leading the witness is related but different. There the writer's beliefs move what the reader believes, rather than what it may do.

- (a) Stated rules only.
- (b) Everything in the text that narrows what the reader may do or count as done, stated or not. Leading the witness and missing context stay with the ticket that decides the writing standard.
- (c) Everything, leading the witness included.

➡️ (b), with a test for each sentence: if it changes what the reader may do or count as done, it belongs here; if it changes what the reader believes, it belongs to the standard ticket. Some sentences do both, and then both tickets apply. "Zero items is the expected result" does both: it plants a belief, and that belief raises the bar for reporting. In lineups, saying the culprit "is present" rather than "may not be present" raised picks from 33% to 78% (§3).

One line from the research matters here. Withholding the writer's own conclusion protects the reader's independence. Withholding context relevant to the task does not: in 16 studies, clinical information made readers of medical tests more accurate, never less. So restraint applies to what the writer volunteers, never to what the reader may go and look for (§3, §4).

---

❓ **Q2 - What makes a rule binding?** *(Round one's Q1, revised.)* My test was that a rule binds if it describes the task, not the route. That fails, because the task statement narrows too. What's left is ownership: a rule binds only when its owner made it binding. The owner might be you, a ticket you approved, another subagent's claim on its files, or the harness.

Owned rules don't get a pass, though. Each one, the goal included, is checked against one question: does it narrow more than its owner meant?

Two factory cases fit. The mandatory trail review caught the owner's mistakes three times out of three. The delegation rule held only once a hook enforced it. Both are rules about the route, both are yours, and both carry a recorded reason.

The sociology adds a frame. Garfinkel showed that no set of instructions can be made complete. Suchman found that plans are resources for acting, not specifications of it (§4). On that view, guidance about the route is a resource, and a binding rule is the exception that has to justify itself.

- (a) Binding comes from the owner. Every bound, the goal included, is checked against how wide its owner meant it.
- (b) Binding comes from what the rule is about (round one's test).
- (c) No general test; case by case.

➡️ (a). The practical consequence is that a writer states the goal as wide as it really is. "Find the bugs in this diff" is narrower than "find what this change could break". Only the owner knows which one was meant, so a writer who narrows it is making up a binding rule.

---

❓ **Q3 - How does the writing pass on knowledge about the route?** *(Round one's Q2, revised.)* The research separates two kinds of route knowledge.

- **Facts about the project.** The trap a subagent hit, a tool quirk, why a file is odd. This helps. A subagent starting cold is a novice in the project, however capable it is, and explicit links help readers without background (§9). This is human evidence.
- **Method.** Step by step, how to do the job. For a capable reader this hurts. In a meta-analysis of 60 studies, detailed guidance helped novices (d = 0.51) and hurt experts (d = −0.43) (§4). Also human evidence.

Two model findings bear on the wording:
- **Current Claude models read instructions literally** (Anthropic's guide, no published numbers). Something offered as knowledge can be taken as an order unless the text says it isn't one.
- **The word that marks a sentence's status changes how readers treat it.** In a survey study, people told definitions were "essential" checked them on 81% of questions; told they were "available", on 23% (§8, human evidence).

- (a) Leave route knowledge out.
- (b) Give project facts freely, each with its reason, marked in words as knowledge and not a rule. Leave method out, except on a closed task.
- (c) Give method as a default the reader may override.

➡️ (b). On (c): to a literal reader a default is the expected route, so in practice it works as a rule.

The closed-task exception is yours: you said lists are fine "if you are looking at a closed ended task where the options truly ARE listable and complete". The research agrees that specific direction helps on simple tasks (§4). The test I'd use is whether the writer could list every acceptable result. If so, the method can be the task.

When the reader takes another route, it reports what it did and why. It should report actions, not influences: models used hints they never mentioned in their reasoning (§3), so a report of what swayed the reader can't be trusted, while a report of what it did can be checked.

---

❓ **Q4 - Where does a limit on output go? (new)** Examples: "only report high-severity", "under 400 words", "answer in JSON", "every item cites `spec:`". Two model findings point the same way:
- Anthropic says that under a reporting bar, Claude finds the bugs and then leaves out the ones below the bar. It recommends asking for every finding with its confidence and severity, and filtering in a separate step (vendor observation, no numbers).
- Forcing an answer into JSON hurt reasoning, and answering in plain language first and converting afterwards removed most of the loss. This one is contested: a rebuttal found no loss once the prompts were matched (§4).

The factory already does half of this. `review-brief.sh` and `review-comment.sh` check the shape of a report after it's written.

- (a) The reader reports everything it found, with confidence and severity. Any limit that exists for whoever uses the output is applied in a separate step afterwards.
- (b) Limits stay in the brief, with their reason.
- (c) Case by case.

➡️ (a). This is the recommendation with the most model evidence behind it, and it is how the `spec:` gate case would have gone right. The cost is more output to read, and the efficiency map can measure that.

---

❓ **Q5 - What does the reader do when a binding rule fights the goal?** *(Round one's Q3, revised. It depends on Q2 and Q3.)* The factory gives five different answers today. The research adds one fact: readers who misunderstand rarely notice, and rarely ask.
- **People:** in surveys, they asked on 4% of the occasions where help was given.
- **Current models:** they almost never asked on underspecified coding tasks (§8).
- **The factory:** Sol followed the `spec:` gate and filed nothing, without ever flagging the conflict.

So an answer that relies on the reader noticing the conflict won't hold.

If Q2 and Q3 go as I recommend, the five mechanisms reduce to two cases:
- **A binding rule:** the reader follows it, says where its owner will read it that the rule fights the goal, and does the rest of the work. It never quietly shrinks the goal.
- **Route knowledge:** the reader may depart from it, and reports what it did and why.

To make up for readers not noticing, every report has a fixed slot: *what did you see but not pursue or report, and what stopped you?* The slot asks the question every time, rather than waiting for the reader to raise it. It works like the handoff program that cut medical errors by 23% across nine hospitals, which ends with the receiver restating the plan (§10, human evidence, not randomized).

- (a) The two cases plus the fixed slot replace all five mechanisms. "Get a sign-off" stays for the main session with you present.
- (b) Keep the five and add the slot.
- (c) The reader stops at any conflict and waits.

➡️ (a). The `skip: <reason>` step becomes the route-knowledge case. Writer-flag dispositions (`accepted: <reason>`) stay, because they record a decision about the work, not a departure from a rule. Delegation stays binding, because you own it.

---

❓ **Q6 - Who may write a binding rule into a brief?** *(Round one's Q4. The recommendation is the same, with more behind it.)*

➡️ The orchestrator passes down what its owners made binding and binds only what it owns itself, such as which files other subagents are working in. Everything else goes in as knowledge, under Q3. Evidence for why:
- **The asker's premise shapes the questions.** Interrogators led to expect guilt asked guilt-presuming questions (§3).
- **Intent statements fill up with method.** Army orders meant to free subordinates turned out to be full of it, and subordinates matched their commander's intent in about a third of cases (§4).
- **The factory's own audit** found the reviewer limits were added by subagents to save cost, with no ticket asking for them. Separately, a subagent turned one of your questions into a rule on a ticket.

---

❓ **Q7 - Can cost or time justify a limit on the route?** *(Round one's Q5, narrowed by Q4.)* Limits on output length now fall under Q4. What's left is the budget for the process: time and tokens. Tight output budgets cut reasoning models' accuracy sharply. One model went from 72% to 54% at 1,024 tokens (§4, from someone else's account of the paper).

➡️ A budget for the process is stated as a fact the reader plans its own route within. It binds only when you set it.

---

One thing goes to another ticket. Some binding rules are held by a hook, and the hook's block message reaches the reader at the moment it matters. The research favors exactly that over standing text loaded early (§6, §12). Whether briefs still need to repeat such rules is a question about where things live, so I'll put it in the ticket "Decide where each piece lives and when it reaches the writer".

The memory rewrite from round one still stands; I'll do it once this round settles.