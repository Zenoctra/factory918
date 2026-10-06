Yes, they change. I've now read the [research note](https://github.com/Zenoctra/factory918/blob/research/wording-and-reader-context/docs/research/wording-and-reader-context.md) in full. Four changes:

1. **Round one's test let the costliest rules through.** It sorted rules by what they're about, and "what done means" counted as part of the task. But some of the strongest evidence is about rules on finishing, not on searching. Radiologists who had already found one nodule kept searching just as hard but became reluctant to report a second. Anthropic's own evals show the same thing in Claude: told "only report high-severity issues", the model still finds the bugs and leaves them out of its report. Our `spec:` citation gate did exactly this on PR 99.
2. **"Route knowledge offered politely" isn't harmless.** A known method blocks a better one, even while the reader believes it looked elsewhere. In one study, Codex copied lines from an example function into 32 to 61% of its solutions. Current Claude models read instructions literally, so an illustration binds harder. Round one's Q2 needs a sharper line.
3. **Round one did the thing you warned about.** Every question came with (a), (b), (c). The strongest survey result in the note is that people stay inside an offered list even when it has an "other" slot. This round asks open questions and gives my recommendation, and I name alternatives only where they make the question clearer.
4. **Some honesty about the evidence.** No study has tested limits on *strategy* in models. Most of what follows is human evidence, plus vendor notes on older Claude models. These are design choices grounded in evidence, not measured ones.

---

❓ **Q1 - What makes a rule binding?** The research supports the core of your correction from two directions:
- **Sociology.** Garfinkel showed that no set of instructions can repair its own incompleteness. Suchman showed that plans are resources for acting, not specifications of the action. That is your "leave it open for something you CAN'T predict", argued from the nature of instructions themselves.
- **Military doctrine.** Mission command states the purpose and the end state, and leaves the method to whoever carries it out. The one empirical test is sobering, though. In practice, intent statements were full of method, and only about a third of subordinates' actions matched the commander's intent. So stating the goal isn't enough. The goal statement itself has to stay free of method.

The refined test: a rule is binding only when it states what's wanted, or a decision that belongs to someone other than the reader. What "done" means is stated as what's wanted, never as a filter on what the reader may report. Any filtering happens afterwards, as a separate step done by someone else. That's the vendor's own advice: ask for every finding with its confidence and severity, then filter.

Ownership: only the owner of an authority can make a rule binding. The research doesn't test this; it's my inference. One nuance: a rule you merged isn't automatically yours. The constraints audit found reading limits that subagents added for cost and nobody asked for. A rule is yours when a decision records you choosing it.

Two cases to test the line:
- The mandatory trail review is a route rule. You set it, and it caught the owner's errors 3 times out of 3. It's binding because it's yours.
- "Read the tier in two plain commands" ([ticket.md:10](template/.agents/skills/poteto-mode/playbooks/ticket.md:10)) isn't binding. It's a fact about the ground the reader works on (see Q2).

➡️ Adopt the refined test. A filter on what gets reported counts as a rule about the route, even when it's written as part of the goal.

---

❓ **Q2 - How does what the writer knows about the route reach the reader?** The research suggests a line I didn't draw in round one:
- **Terrain** is facts about the world the reader works in. For example: "the guard refuses git inside `$(...)`", "paths contain spaces", "4 of 13 known bugs sat in files outside the diff".
- **Method** is a suggested route. For example: "start with these files", "work through this checklist", "look for these smells".

What the evidence says about each:
- **Terrain helps.** A subagent starting cold is a low-knowledge reader for this project, however capable it is, and explicit links help low-knowledge readers.
- **Method hurts capable readers.** Step-by-step guidance helps novices and hurts experts (d = −0.43 across 60 studies).
- **A known method blocks a better one.** Chess masters given a familiar mate said they were looking for a shorter one. Eye tracking showed their gaze never left the familiar squares.
- **How a rule is worded matters.** The same limit lowered creativity when stated as control, and didn't when stated as information.
- **Prohibitions mostly don't backfire in current models, but they don't help much either.** A "don't" keeps the forbidden idea active and doesn't say what to do instead, so the reader lands on some other fixed default. Terrain is better stated as a plain fact than as a "don't".

➡️ Give terrain freely, each fact with its reason, and leave method out by default. When the writer has learned something the hard way about method, turn it into terrain: say what happened and why, not which step to take.

---

❓ **Q3 - Is what the writer chooses to leave out a rule?** Several of your examples mix two different things:
- **A limit on what the reader may look for**, such as "read only the diff".
- **What the writer chooses to tell it**, such as its own belief about where the bug is.

The forensic evidence supports holding back the second kind. Withholding task-irrelevant context, and an earlier analyst's conclusion, protects an expert's independence. In one study, telling a model the code was bug-free cut vulnerability detection from 97% to 4% for a small model.

Holding back isn't free, though. Across 16 medical studies, giving readers relevant clinical information improved their accuracy, and none found it made them worse. So the line is between relevant context and context that only carries the writer's conclusion. It is not a line between context and no context.

➡️ The writer may choose what it volunteers. It never turns that choice into a limit on what the reader may go looking for. This ticket records only that line. What to volunteer and what to hold back is about leading the witness, so it belongs to the ticket [Decide what the writing standard is and what carries it](https://github.com/Zenoctra/factory918/issues/155).

---

❓ **Q4 - What does the reader do when a binding rule fights the goal?** Today the factory gives five answers that conflict with each other. The research adds three things:
- **Readers rarely ask, even when invited.** People asked for help on 4% of the occasions it was offered. Current models almost never ask on underspecified coding tasks. Wording moves this a lot: people told definitions were *essential* checked them on 81% of questions, against 23% when told they were *available*.
- **A model can follow a hint without mentioning it.** Claude 3.7 Sonnet mentioned a hint it used 25% of the time. A subagent that quietly narrowed its goal to fit a rule may not say so, and reading its reasoning won't catch it.
- **Pushing for problems produces false ones.** Detailed find-and-fix prompts raised false positives in models, and dissent assigned as a role was weaker than real dissent. A mandatory "list your conflicts" section could produce invented conflicts.

➡️ Replace all five mechanisms with one:
- **Unattended:** stop that part, carry on with the rest, and report the conflict to the rule's owner. The report is framed as an expected part of the job whenever a conflict happens, not as a section that must be filled.
- **With you present:** the current "say so and get a sign-off" stays.
- **Never** narrow the goal to fit the rule.

Because self-reports are unreliable, whoever receives the result also checks what came back against what the goal asked for. How that check works belongs to [Decide how we'll know the writing works](https://github.com/Zenoctra/factory918/issues/153).

---

❓ **Q5 - Who may write a binding rule into a brief?** In one study, interrogators led to expect guilt asked guilt-presuming questions. Their questions shaped the suspects' answers and changed how neutral listeners heard those answers. An orchestrator writing a brief knows what answer it hopes for, and its guesses about the route carry that hope.

➡️ Unchanged from round one. The orchestrator:
- passes down rules that belong to you: AGENTS.md, decisions you made, and the ticket;
- binds only what it owns itself, such as which files other subagents are writing right now;
- offers everything else as terrain (Q2).

Its beliefs about the answer are never rules (Q3).

---

❓ **Q6 - Can cost or time limit the route?** The research has three findings here:
- **Tight token budgets hurt reasoning models.** One model fell from 72% to 54% at 1,024 tokens.
- **A stated measure replaces the goal.** Knowing that performance is measured was enough to make people act as if the measure were the goal, with no pay attached.
- **"Stop after N findings" is a reporting bar** (Q1).

➡️ Where possible, the budget stays on the writer's side: the orchestrator decides when to stop waiting. When the reader needs the budget to plan, it's stated as a fact, along with what happens at the limit: "hand back what you have and say what's unfinished". It is never a cap on findings or on length. The map "Optimize token use and wall-clock time without losing reliability" can revisit this once it has measurements.

---

❓ **Q7 - Does this reach the factory's own playbooks and hooks?** [PHILOSOPHY.md:23](docs/knowledge/core/PHILOSOPHY.md:23) praises pstack's playbooks for making the agent "follow a script rather than improvising". Belief 3 pushes rules down into hooks, where prose can't override them. Those are rules about the route, held in structure.

The evidence cuts both ways:
- **Scripts help on simple tasks and for novices.** They hurt on complex, novel tasks and for capable readers.
- **Some mandatory steps have good records.** The trail review is one. The blast-radius step was added after a hook bug survived four review rounds.

One pattern I noticed is that the rules with good records add work, and the harmful ones take work away: a cap, a reading limit, a filter. That pattern comes from a handful of cases, the same way the old test came from reviewers. I'm offering it to test against more cases, not to adopt.

➡️ Yes, it applies to everything. A playbook step or a hook is a binding rule like any other and must pass Q1's test. That means it's yours, recorded with its reason, and its reason is written next to it. Which existing ones to rework, and in what order, belongs to [Decide the scope and order of reworking existing files](https://github.com/Zenoctra/factory918/issues/158).

---

❓ **Q8 - Decide firmly now, or record a hypothesis to test?** The note's biggest gap is that nobody has measured what a model misses outside an illustrative list on an open-ended task. The factory can run that experiment itself: give subagents the same task with and without the list, and count what each finds outside it.

➡️ Decide now on the evidence we have. Record the decision as a hypothesis, name the experiment, and hand the experiment to [Decide how we'll know the writing works](https://github.com/Zenoctra/factory918/issues/153).

---

Still pending from round one: once this round settles, I'll rewrite my memory that still carries the old "protect the world" test.