I'll read the research itself first, not the summary of it.

---

Yes, it changes them. The research is [docs/research/wording-and-reader-context.md](docs/research/wording-and-reader-context.md) on the `research/wording-and-reader-context` branch. Reading it shifted three things:

1. **The goal/route line still holds, but it leaks in two places.** A definition of "done" can carry a filter that hides findings. And route advice offered "only as knowledge" still pulls the reader toward it.
2. **My old Q3 assumed the reader notices a conflict and says so.** The evidence says neither people nor models reliably do. So the question becomes how a conflict gets seen without counting on the reader to raise it.
3. **I had blurred two things the research separates.** One is limiting what the reader may go looking for. The other is the writer holding back its own conclusions. The evidence points opposite ways on them.

The format also needs a warning. In Schuman & Scott (1987), four problems listed with an explicit "or name another" slot went from 2% of open answers to 60%. My (a)/(b)/(c) options are examples, and my ➡️ lines are my own leanings. Please answer outside both whenever they don't fit.

Terms, again, plus two new ones:
- **The goal**: what's wanted, and what done looks like.
- **The route**: how the reader gets there.
- **A binding rule**: one the reader may not overrule by itself.
- **A reporting bar** (new): a threshold for what goes into the report, such as "only hard bugs" or "must cite the spec".
- **A terrain fact** (new): a fact about the project or tools the reader would otherwise run into the hard way, such as "the worktree guard refuses `git` inside `$(...)`". It is different from a suggested method.

The old questions move as follows: Q1 stays Q1, old Q2–Q5 become Q3, Q4, Q5 and Q7, and Q2, Q6 and Q8 are new.

---

❓ **Q1 - What makes a rule binding?** My earlier test stands: a rule binds when it states the task or a limit of someone's authority, and only the owner of that authority can make it binding. The research adds two things about how even a binding rule should be written.

- **No rule written in advance covers the situation it will meet.** Garfinkel (1967) found that each push for a more complete set of instructions made the task harder, until it couldn't be done. Suchman (1987): "plans are resources for action, not specifications of it." The one field test of commander's intent (Shattuck 2000) found that only 34% of subordinates' actions in unexpected situations matched intent by design rather than by chance. So a binding rule still needs its reason, or the reader can't tell which case it was written for.
- **Current Claude models read literally and over-apply emphasis.** Anthropic's own guidance says Opus 4.5/4.6 over-apply instructions written as "CRITICAL: you MUST". It also says the model generalizes from the reason when one is given. With people, the same limit stated as information rather than as control kept creativity intact (Koestner et al. 1984). A bare prohibition tends to move the reader to some other fixed default instead (Opus 4.8 guide; the pink-elephant studies).

➡️ The task-plus-owner test, and every binding rule written plainly, with its reason, saying what to do rather than only what not to do. Under this, `ticket.md`'s "never an arena" and the `knowledge` skill's 150-line cap can't stay as they are: neither carries a reason.

---

❓ **Q2 - Can "what done means" include a reporting bar? (new)** This is where "it's only the goal" hides a limit on the route.

- Radiologists who found one abnormality kept searching just as hard. What changed was their bar for *reporting* the second one (Berbaum et al. 2015).
- Anthropic observed that when a review prompt says "only report high-severity issues", the model still finds the bugs and then leaves them out. Recall falls even though bug-finding ability went up.
- A 2026 preprint (Shin) found that narrow task instructions suppressed models' reports of critical findings they made otherwise, by up to 92%. A separate critic with an open brief recovered every one.
- Our own case: the `spec:` citation gate. Sol obeyed it and filed nothing on a PR that had four real bugs.

The options:
- (a) A definition of done may include a bar.
- (b) The reader reports everything it finds, with its own confidence and severity. Any bar is applied afterwards, as a separate step, by whoever owns it.
- (c) Bars only for some jobs.

➡️ (b). It's also the vendor's own recommendation. This one decision covers the `spec:` gate, "Documented step:", and every "only report X" line we have.

---

❓ **Q3 - How should the writing carry knowledge about the route?** My earlier answer was to pass it on "as knowledge, with the reason". The research says that isn't enough, because suggested methods anchor the reader:
- Chess masters shown a familiar mate kept their eyes on its squares while saying they were looking for something better (Bilalić et al. 2008).
- Codex copied lines from a related example function into 32–61% of its solutions (Jones & Steinhardt 2022).
- Experts given step-by-step help did worse than with little help (d = −0.43 across 60 studies).

Facts about the terrain go the other way:
- Clinical context improved diagnostic accuracy in all 16 studies reviewed (Loy & Irwig 2004).
- Explicit links help readers with little background (McNamara et al. 1996).
- Telling designers which flawed element to avoid reduced fixation (Chrysikou & Weisberg 2005).

The research names the synthesis: a fresh lane is **expert in method and a newcomer to the project**. So the line falls between terrain facts and suggested methods, not between knowledge and orders. Our own `ticket.md:10` shows it. "Read the tier in two plain commands" is a method. The terrain fact underneath it is "the guard refuses `git` inside `$(...)`", and with that fact the reader picks its own workaround.

➡️ Give terrain facts freely, with reasons, and before the content that depends on them. Context given first helps comprehension; the same context given after doesn't (Bransford & Johnson). Suggest a method only when it's a lesson that cost a run to learn, and phrase it as what happened, not as what to do.

---

❓ **Q4 - When a rule fights the goal, how does anyone find out?** The evidence:
- **Readers rarely notice and rarely ask.** Survey respondents asked for clarification on 4% of the occasions it was needed. Models almost never asked on underspecified SWE tasks.
- **The influence doesn't show in the reasoning.** Models use a hint without mentioning it: Claude 3.7 mentioned a hint it used 25% of the time.
- **So the failure is silent narrowing**, which my old option (c) described as the thing to forbid. It's the default behavior, not a choice the reader makes.

The factory currently has five departure mechanisms that disagree, and none of them was ever audited.

What the research says helps:
- **Framing the request as essential.** Readers told a check was essential did it 81% of the time; told it was available, 23%.
- **A read-back.** I-PASS cut medical errors by 23% by having the receiver restate the plan.
- **A separate open-ended check afterwards**, like Shin's critic.

The options:
- (a) The reader stops that part of the work and reports to the rule's owner, as I recommended before.
- (b) Same as (a), plus two required parts of every report: the goal restated in the reader's own words, and where any rule in the brief stopped or changed something the reader would otherwise have done.
- (c) Same as (b), plus an open-ended second reader on the jobs where silent narrowing costs most.

One risk with (b): asking "where did a rule stop you" can produce invented complaints. More detailed find-and-fix prompts raised false positives (Jin & Chen 2026), and assigned dissent was weaker than real dissent (Nemeth et al. 2001). So the wording has to be neutral: "none" is a valid answer, and it must not be framed as the expected one, which is the #137 lesson.

➡️ (b) as the one mechanism that replaces all five. Whether (c) is worth its cost belongs to "Decide how we'll know the writing works" and the templates prototype.

---

❓ **Q5 - Who may write a binding rule into a brief?** This is unchanged: the orchestrator passes your rules down, binds what it owns itself, and offers the rest as terrain under Q3. The research adds a reason. The orchestrator's guess about the route is also its guess about the answer, and in people the asker's hypothesis shapes their questions and then the answers (Kassin et al. 2003, interrogators who expected guilt).

➡️ No invented binding rules.

---

❓ **Q6 - Is "what the writer volunteers" part of this ticket? (new)** The research splits two things your examples mix:
- **Limiting what the reader may seek.** There is no evidence for it.
- **The writer holding back its own conclusions.** There is strong evidence for it. Told the code was bug-free, a small model's detection fell from 97% to 4%; Opus 4.5's fell from 96% to 89%. Fingerprint experts given case context reversed their own earlier matches.

The second isn't a rule about the route. It's leading the witness. It also collides with your Q9 preference: you want orchestrator conversation passed to the subagent whole, but the forensic remedy is to keep an independent judge away from the writer's conclusions. The field draws the line between context relevant to the task (helps) and context that only carries someone's conclusion (hurts). It does not draw it between context and no context.

The options:
- (a) Decide it here.
- (b) Send it to "Decide what the writing standard is and what carries it", with this collision named.
- (c) Make it a ticket of its own.

➡️ (b). This ticket stays on rules, and the collision gets its own answer where the whole standard is decided, so it doesn't get decided in passing here.

---

❓ **Q7 - Can cost or time limit the route?** My earlier answer was to state a budget as a fact and let the reader plan within it. The research weakens that:
- **Caps on findings or words are reporting bars**, so they fall under Q2.
- **Tight output budgets hurt reasoning.** Phi-4-reasoning fell from 72% to 54% at 1,024 tokens.
- **A measure becomes the goal without anyone noticing.** In surrogation studies, merely knowing a measure existed was enough, with no pay attached. A budget stated "as a fact" still pulls.

The options:
- (a) State it as a fact, as before.
- (b) Keep cost out of the brief. Control it where the orchestrator dispatches: how many lanes, which model, when to stop launching. State a limit in the brief only when it's real and the reader would hit it anyway, such as a context window or a deadline you set.
- (c) You set budgets and they bind.

➡️ (b). The efficiency map owns the numbers.

---

❓ **Q8 - Is this ticket's answer settled or provisional? (new)** The research says outright that no model study tests a limit on strategy itself (§4, §13). The model evidence I leaned on above has limits:
- one single-author 2026 preprint;
- a vendor note with no numbers, about Opus 4.8, not 5.5;
- studies on 2022–2025 models.

The research also names an experiment the factory could run itself: the same open-ended task given with and without an example list, counting what each finds outside the list.

The options:
- (a) Decide now as a standing rule.
- (b) Decide now, mark it provisional, and hand "Decide how we'll know the writing works" this specific test.

➡️ (b).