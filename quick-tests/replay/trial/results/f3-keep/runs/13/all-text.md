Yes. Having read the whole research note, three things change how I'd put the round. The evidence behind them is uneven, so here's where it stands first:

- No study tests a limit on *strategy* in a model directly. That means rules like which files a reviewer may read, what order it works in, or which list it must cite from.
- Most of the evidence comes from studies of people.
- The model evidence is mostly older models. The newest is Anthropic's guide for Opus 4.8, which gives no numbers and doesn't cover Opus 5.5.

So what follows applies the evidence to agents; it hasn't been measured on them. The ticket "[Decide how we'll know the writing works](https://github.com/Zenoctra/factory918/issues/153)" can test it.

**1. The danger is a rule the reader quietly obeys, not one it resents.** People resist controlling wording. Models show no sign of that. What models do is follow wording literally and over-apply emphatic instructions.
- In one 2026 preprint, a narrow task instruction made models leave out serious findings they reported without it. They never said they had left anything out. A second model, given an open brief, found all of them. This is a single-author study that hasn't been peer reviewed.
- People who misread a question rarely know it. They asked for help on only 4% of the occasions it was offered.

So any design that counts on the reader noticing a bad rule and objecting will catch little. This changes the old Q3 the most.

**2. "What done means" is not safe ground.** My Q1 test put the definition of done on the binding side. That turns out to be where some of the worst limits hide:
- **Reporting bars.** Radiologists found the second abnormality and didn't report it. Anthropic saw the same thing in its own tests of Opus 4.8 when a prompt said "only report high-severity issues."
- **Measures that replace the goal.** In management experiments, people treated the measure as if it were the goal, without noticing they were doing it.
- **Run 2.** The `spec:` citation gate is this exact case: a reviewer filed nothing on a PR that had four real bugs.

**3. Facts about the situation are not the same as instructions on method.** A subagent starting cold knows the work well but knows little about this project.
- Facts about the project help that kind of reader. In 16 out of 16 medical studies, giving the relevant clinical information improved accuracy.
- Step-by-step method costs expert readers.
- Forensic science draws a further line: what the writer *offers* is different from what the reader may *look for*. The writer holding back its own conclusions protects the reader's independence. That is not a limit on the reader.

The terms from round one still apply:
- **The goal** is what's wanted.
- **The route** is how the reader gets there.
- **A binding rule** is one the reader may not overrule on its own authority.

The options under each question are mine and don't cover every possibility. You can answer outside them.

---

❓ **Q1 - What makes a rule binding?**

The research changes my round-one test in two ways.
- **No rule fits every situation.** Two sociologists, Garfinkel and Suchman, argue that a rule written in advance never fully contains the situation it will meet. So "binding" can't mean "holds no matter what." It can only mean "not the reader's to overrule alone." Your own rules will meet cases they don't fit too. That's why Q4 matters.
- **The task side doesn't split cleanly.** A bar like "only hard bugs" looks like part of what done means, but it acts as a limit on the work.

Revised test: a rule binds only when it states one of two things:
- **the goal;**
- **authority:** a decision that isn't the reader's to make. Only whoever holds that authority can make the rule binding.

You can still bind the route. The delegation rule is an example. When you do, it's your authority being used, written down with its reason, and nobody further down the chain can add more such rules. Done criteria and output filters are left out of this test on purpose; Q2 deals with them.

The options:
- (a) the goal plus authority, with each binding rule backed by its owner;
- (b) ownership alone, so whatever an owner says binds;
- (c) no test, every rule argued case by case.

➡️ (a). Under (b), an orchestrator that owns a lane could bind anything, including its guesses about the route. That is how the reviewer briefs went wrong.

---

❓ **Q2 - Is a done criterion binding? (new)**

A done criterion stands in for the goal, and people come to treat the stand-in as the goal without noticing. One study found that just knowing they were being measured was enough, with no pay at stake. Your principle-over-proxy rule already says this. For example, P109's "at most N" was "a prediction, not a constraint."

Output filters are a separate case: severity bars, caps on how many findings, caps on length. They aren't done criteria. They're a filter applied after the work is done, and placed inside the brief they change the work itself. Anthropic's own advice for Opus 4.8 is to ask for every finding with a confidence and a severity, then filter in a separate step.

The options:
- (a) Only the goal binds. A done criterion is written as evidence of the goal. When the two disagree, the goal wins and the reader says so in its report. Filters move out of the reader's brief into a later step.
- (b) Done criteria bind as written.
- (c) Leave done criteria out.

➡️ (a). It puts your principle-over-proxy rule into the writing standard and removes the factory's most-measured way of losing findings.

---

❓ **Q3 - How does knowledge about the route reach the reader?** (round one's Q2, revised)

The research weakens my round-one answer, "pass it on as knowledge, with the reason":
- **A list with an "other" slot still bounds the answers.** In one study, four listed problems went from 2% of open answers to 60% of answers once they were listed, even with an invitation to name others. Giving people part of a list also makes them recall fewer of the remaining items. Adding "these are only examples" doesn't undo this.
- **A known method blocks a better one.** Chess masters who knew a familiar mate said they were looking for a shorter one. Eye tracking showed their eyes stayed on the familiar squares.
- **A literal reader treats an illustration as an order.** This comes from Anthropic's vendor guidance.

Leaving everything out fails too, because a cold reader needs facts about the project.

The way through is to separate facts from moves:
- "A worktree agent's guard refuses `git` inside `$(...)`" is a fact.
- "Read the tier in two plain commands" is a move.

The fact lets the reader plan its own way around the problem and spot cases the writer never saw coming. The move gives it one answer. Anthropic's example works the same way: say the text will be read aloud by a speech engine, rather than only banning ellipses.

The options:
- (a) Give facts about the situation generously, and give no moves except for truly closed tasks.
- (b) Give moves with their reasons, and have the reader report any departure.
- (c) Give nothing.

➡️ (a). The exception for closed tasks is your own carve-out from the map ("fine if … the options truly ARE listable and complete"). The evidence agrees with it: specific method helps on simple tasks. Even then the move comes with its reason, so the reader can spot the unusual case.

---

❓ **Q4 - When a binding rule fights the goal, and the reader may not notice, what happens?** (round one's Q3, revised)

The factory currently has five ways to depart from a rule, and they disagree with each other:
- get a sign-off first;
- follow the rule, then explain;
- record a Provisional decision;
- `skip: <reason>`;
- `accepted: <reason>`.

Whatever you choose here replaces all five. The research also adds a second problem: the reader often won't notice the conflict at all. Models use hints without mentioning them in their reasoning; one model mentioned a hint it had used only 25% of the time. So the answer has two parts.

- **(i) When the reader notices the conflict:** it stops that part of the work, reports the conflict to the rule's owner, and carries on with the rest. It never narrows the goal to fit the rule.
- **(ii) Making unnoticed conflicts visible.** The options:
  - (a) A read-back in every report. The reader restates the goal in its own words and says what it left undone and why. A hospital handoff structure that ends with the receiver restating the plan cut medical errors by 23%. That structure came bundled with training, so the read-back's own share of the improvement is unknown.
  - (b) A second reader with an open brief for adversarial work.
  - (c) Nothing structural.

➡️ (i) as stated, and (a) for (ii). Option (b) costs a lane per job, so it belongs to the review design and the efficiency map, not to this ticket.

---

❓ **Q5 - Who may write a binding rule into a brief?** (round one's Q4)

The research makes this sharper. In a study of military orders, statements meant to give only the commander's intent turned out to be full of method, and subordinates' actions matched that intent only 34% of the time. In another study, interrogators told to expect guilt asked guilt-presuming questions. A writer trying to state the goal slides into method without noticing.

➡️ Unchanged from round one. The orchestrator:
- passes your rules down;
- binds only what it holds authority over;
- writes everything else as facts, under Q3.

Most of what it holds authority over is really a fact plus an authority statement. For example: "lane X is writing file Y; it isn't yours."

---

❓ **Q6 - Can cost or time limit the route?** (round one's Q5, revised)

The research separates two kinds of budget.
- **Input budgets** (time, tokens, money). Stated as facts, they let the reader plan its own route.
- **Output caps** (how many findings, how long, what severity). The evidence on these is broad and consistent:
  - Reporting bars make readers withhold findings.
  - Telling people what to expect moves where they set their bar. Observers missed 7% of targets when they appeared half the time, and 30% when they appeared 1% of the time.
  - Tight token limits on output cut reasoning models' accuracy. One model dropped from 72% to 53% at 1,024 tokens.

➡️ Input budgets are stated as facts and the reader plans within them. Output caps never go in the brief; they become a filter applied afterwards, as in Q2. The map "[Optimize token use and wall-clock time without losing reliability](https://github.com/Zenoctra/factory918/issues/145)" owns the actual numbers.

---

❓ **Q7 - Where does this ticket end and the writing standard begin? (new)**

There's a risk that "leave the route open" gets read as "give the reader everything", including the writer's own conclusions. That is leading the witness. In the 2026 study of reviewer framing, being told the code was bug-free cut one small model's detection from 97% to 4%, and Opus 4.5's from 96% to 89%.

Your Q9 preference fits the research's line between what the writer offers and what the reader may look for. You asked for the full, unsummarized context of where the task was defined. That is relevant context. The writer's verdict is not.

➡️ Split it this way:
- **This ticket** owns limits on what the reader may do, look for, or report.
- **"[Decide what the writing standard is and what carries it](https://github.com/Zenoctra/factory918/issues/155)"** owns what the writer offers, including leading.

This ticket's resolution states the line: a writer holding back its own conclusions is not a limit on the route.

---

**Next round:** whether a route rule enforced by a hook is held to the same test. This includes prose that repeats a hook's rule to readers the hook deliberately doesn't reach. For example, the `knowledge` skill's 150-line cap passes the root session's reading limit on to subagents, whom the hook exempts on purpose. That question depends on your Q1 answer.

I'll still rewrite my memory note once this round settles.