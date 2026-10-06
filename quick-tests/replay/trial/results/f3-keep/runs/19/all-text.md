Yes, the research changes the round. In some places it changes what I'm asking, not just how I'd argue it. Here are the three main shifts, then the revised round.

**1. Round one was reaching for the wrong kind of answer.** My Q1 offered a sorting test: decide whether a rule binds by what it's about, or by who owns it. That is the same kind of answer as the "protect the world / shape the search" test you rejected: one sentence meant to sort every future rule.
- Two sociologists, Garfinkel and Suchman, argue that no instruction written in advance can cover the situation it will meet.
- The one study of army commanders' intent found that about a third of subordinates' actions matched the intent. Intent statements written to free subordinates came out full of method.

So any sorting test will misfire on a case nobody foresaw. The weight shifts to two other things:
- each rule carries its purpose, so the reader can see the case it doesn't fit;
- a departure from a rule shows up in the report.

Some sorting is still needed, but much less of it.

**2. The best-measured harms sit in the definition of done, not the route.** Anthropic's prompting guide for Opus 4.8 reports this from its own evals: told "only report high-severity issues", the model still finds the bugs, then leaves out of its report the ones below that bar. The factory has a case of the same thing. The `spec:` citation rule made Fable demote real bugs on a PR that had four. Round one treated "what done means" as the safe side.

**3. Numbers pull even when they're stated as plain facts.** My old Q5 recommended stating budgets as facts. The anchoring evidence says the number still pulls the answer.

**How the questions are asked has changed too.** A list of options with an "other" slot still bounds what comes back: in one study, four listed problems went from 2% of answers to 60%. Round one gave you a closed (a)/(b)/(c) list for every question. This round gives fewer options. Where your own framing differs from mine, that's the answer I most want.

**Where the evidence is thin.** No study of models tests a limit on method as such. The firm model evidence covers four things: reporting bars, framing, number anchors, and limits on format and length. So Q3 and Q6 below stand on firmer ground than Q1 and Q4. Those two rest on human studies, sociology and vendor guidance.

---

❓ **Q1 - Which rules may the reader not break on its own?** Round one asked what makes a rule binding. On the map you put it the other way round: "leaving the door open for a model to overrule certain rules that aren't absolutely necessary." So every rule is **open** by default: the reader may break it and say so. A rule is **closed** only when it's absolutely necessary. The question is who decides that, and what has to come with it.

Four cases from the repo:
- **The mandatory trail review** caught the owner's errors 3 times out of 3. You made it mandatory, with that evidence.
- **The delegation rule** held only once a hook enforced it. You set that one too.
- **"Read nothing beyond this brief"** was written by an orchestrator to save cost. No ticket asked for it.
- **"Never an arena"** ([ticket.md:12](template/.agents/skills/poteto-mode/playbooks/ticket.md:12)) has no recorded reason, so no reader can tell whether it's necessary.

➡️ A rule is closed only when its owner closes it and writes down why. The owner is you, or whoever the decision belongs to: an orchestrator owns which files other subagents are working in right now. Every other rule is open. An orchestrator may pass down rules you closed. It may not close a rule about the route on its own judgment. A closed rule without a written reason is a defect, because the reason is what lets the reader spot the case nobody foresaw and raise it.

---

❓ **Q2 - May hooks and scripts hold open rules?** Belief 3 in PHILOSOPHY pushes each rule to the strongest enforcement it can get: hooks, scripts, CI, where nothing in the text can be argued with. That's right for closed rules. But a hook or script closes every rule it holds, whether or not anyone decided the rule should be closed.

The `spec:` gate in `review-brief.sh` is an example. It began as a report format. Nobody decided it was absolutely necessary, yet the script made it closed, and reviewers then demoted real bugs because they couldn't cite a spec line. The git guard and the delegation hook get this right: when they block, the message names a way forward ("or ask"; "brief a lane").

➡️ Hooks and scripts hold only rules their owner closed. Any hook or script that blocks the reader says in its block message why it blocked and what the reader can do instead. A script that checks a reader's output checks that the output can be read. It never filters what the reader found. Checking the existing hooks and scripts against this belongs to the ticket on reworking existing files.

---

❓ **Q3 - Does "what done means" get the same scrutiny?** The evidence here is the strongest in the research:
- **Anthropic's own evals:** a severity bar in a review prompt cut what reached the report. The model's ability to find bugs hadn't dropped.
- **Radiology:** a reader who has already found one abnormality reports a second less often. The search itself doesn't change; the bar for reporting goes up.
- **Management studies:** a measure stated as the goal replaces the goal, even when no reward is attached.
- **A 2026 preprint on models:** a narrow task instruction suppressed critical findings the same models reported otherwise. A separate reviewer with an open-ended brief recovered every one of them.
- **Your own ruling:** you threw out the "at most N" limit on #109 as "a prediction, not a constraint." That is the same failure.

➡️ "Done" is stated as the purpose. A measure is evidence that the purpose was reached, never its definition. The reader reports everything it found, each with its own confidence and severity. Any bar or filter is applied later, as a separate step, by whoever uses the result. This holds for every subagent, not just reviewers. Any "only the X" inside a done criterion is a reporting bar.

---

❓ **Q4 - What the writer knows about the route: facts, or instructions?** Round one said to pass route knowledge on as knowledge, with its reason. The research turns that into a split between two kinds of knowledge:
- **A capable model starting cold knows little about the project.** For readers without background, spelling out how things connect helps.
- **It is a skilled reader of the task.** In a meta-analysis of 60 studies, step-by-step guidance helped novices (d = 0.51) and hurt experts (d = −0.43).
- **A known method blocks a better one.** In a chess study, eye tracking showed strong players kept looking at the familiar solution's squares while they reported searching for a shorter one.
- **Wording matters.** The same limit worded as control lowered creativity; worded as information, it didn't.
- **Current Claude reads literally**, so a method offered as a suggestion binds harder than the writer meant.

So facts about the ground the reader works on help: the trap, the tool quirk, what failed and why. A prescribed method has a cost, even when it's correct. For example, [ticket.md:10](template/.agents/skills/poteto-mode/playbooks/ticket.md:10) contains both:
- "The worktree guard refuses `git` inside `$(...)`" is a fact about the ground.
- "Read the tier in two plain commands" is a method derived from that fact.

Given the fact, a reader works out that method, or a better one.

➡️ State the facts fully and plainly, and leave the method to the reader. The exception is simple, mechanical tasks, where the evidence says method helps. When a method is offered, it comes right after the fact it's derived from and reads as the writer's suggestion.

What this leaves for another ticket: the writer volunteering its own view of the answer, such as its hunch or what it expects to find. The research separates two things:
- **Context relevant to the task** improved readers' accuracy across 16 medical studies.
- **The writer's conclusion** biases even experts. Telling a reviewer the code was bug-free cut detection from 97% to 4% on a small model and from 96% to 89% on Opus 4.5.

That is a rule on the writer, not on the reader's route. I'd leave it to "Decide what the writing standard is and what carries it" and record the distinction in this ticket's resolution, unless you'd rather settle it here.

---

❓ **Q5 - When a rule fights the goal, how does that come to light?** Round one asked what the reader does in that case. The research says the bigger problem is that the reader doesn't mention it:
- In one study, Claude 3.7 Sonnet mentioned a hint it had used only 25% of the time.
- In surveys, people told they could ask for help asked on 4% of the occasions help was given.
- When definitions were described as *essential* rather than *available*, people checked them 81% of the time instead of 23%.

Meanwhile the factory has five departure mechanisms that disagree with each other, and none tells a subagent how to get a sign-off.

➡️ One mechanism replaces all five:
- **Breaking an open rule:** the reader breaks it when the task calls for it and reports that it did, with the reason.
- **A closed rule that fights the goal:** the reader stops that part, reports it to the rule's owner, and carries on with the rest. It never narrows the goal to fit the rule. That part of round one stands.
- **Every brief asks, as a required part of the report,** which rules the reader broke, and what it held back from doing or reporting because of the brief. That makes reporting it essential, not merely available.

---

❓ **Q6 - Numbers in a brief.** The evidence that numbers pull:
- **The range of a scale moves answers.** Changing only the scale's range moved the share reporting over 2½ hours of TV a day from 16% to 37%.
- **Expectations move the bar.** Observers told targets were rare missed 30% of them instead of 7%.
- **Models drift toward numeric anchors.** The stronger models drifted more consistently, and telling them to ignore the anchor didn't remove it.
- **Tight output budgets** sharply cut the scores of reasoning models.

"Zero items is the expected result" and "under 400 words" were exactly these.

➡️ A brief carries no count, length or expected number unless it's a real limit that someone owns, such as a spend ceiling you set. A real limit is stated as the situation the reader is in, together with what to do when the limit is reached: report what's left undone rather than dropping it quietly. A brief never states how many findings to expect. Which limits are real is the efficiency map's decision.

---

The Q3 preprint also suggests pairing a narrowly briefed subagent with one briefed open-ended. That's a question for the brief templates, so I'll add it to the map's **Not yet specified** when this ticket resolves. After that, I'll rewrite my own memory that still states the old test.