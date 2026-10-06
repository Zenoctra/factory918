I'll read the research myself rather than through a summary, since it's what the questions should rest on.

---

Yes, the research changes the questions. A few of my recommendations were wrong, and one question was asking the wrong thing. I read the note's sections on rules, "don't" instructions, readers who don't ask, and its implications for this ticket. Here is what changed, and then the revised round, which replaces the first one.

## What the research changed

**1. I only answered half of your sentence.** You wrote "how the task is pursued *or completed*." My Q1 split the goal from the route and treated "what done means" as safely binding. The research puts the strongest evidence about models exactly there:

- Radiologists who found one abnormality kept searching just as hard. What changed was that they raised their bar for reporting the next one.
- Anthropic's own prompting guide reports the same in Claude. Tell it "only report high-severity issues" and it still finds the lower-severity bugs, then leaves them out of the report. Recall drops even though its ability to find bugs went up.
- Studies of people paid on a measure found they treat the measure as the goal without noticing.

Your ruling that the "at most N" list in P109 was "a prediction, not a constraint" is that last finding. The `spec:` gate is the radiologist finding: a reviewer filed nothing on a PR that had four real bugs. So the completion side isn't the safe half. It's where the measured damage is.

**2. Q3 assumed the reader notices when a rule fights the goal. It usually doesn't.**

- Survey respondents who were told they could ask for clarification asked 4% of the time.
- Current models almost never ask on coding tasks that are badly underspecified.
- Models use hints planted in a prompt without mentioning them in their reasoning.
- Claude reads instructions literally and sticks to a stated bar.

So when a rule fights the goal, what really happens is my option (c): the reader quietly shrinks the goal to fit. I called that the failure to avoid, but it's the default. Q3 turns into a design question: how does a collision become visible to anyone?

**3. A distinction I didn't have: what the writer offers versus what the reader may go and look at.** Forensic science protects an analyst's independence by not handing them other people's conclusions. Across 16 studies, though, giving readers of medical tests relevant clinical information improved their accuracy, and no study found a significant loss. The line the field draws runs between relevant context and someone else's verdict. It doesn't run between more context and less. When the writer keeps its verdict out of a brief, the reader stays independent. When the writer forbids the reader to read a file, the reader is limited. These are different acts, and my questions had them blurred together.

**4. There is a real place for steps.** Detailed guidance helps novices and hurts experts, and specific goals help on simple tasks and hurt on complex, novel ones. You said the same about lists: they're fine "if you are looking at a closed ended task where the options truly ARE listable and complete." So a fixed procedure, like running a script and posting what it prints, can take steps. An open task can't.

**5. How a rule is worded matters as much as what it says.**

- Children given the same limits on a painting were less creative when the limits were worded as control, and weren't affected when they were worded as information.
- Claude over-applies emphatic wording, reads literally, and generalizes from the reason given for an instruction.
- Garfinkel and Suchman argue that no instruction written in advance can contain the situation it meets, so plans are resources for acting, not specifications of it.

That's the scholarly form of your "leave it open for something you CANT predict." It's also why the reason matters more than the rule: the reason is what lets the reader handle the case the writer didn't foresee.

**What the evidence doesn't cover.** No published study tests a limit on a model's *method* directly. The closest data is the factory's own: in the reviewer eval, 4 of 13 labelled bugs were in files the brief told the reviewer not to open. Most model studies are on models from 2022 to 2025. The vendor guidance is current but publishes no numbers. Where I lean on human findings below, treat them as predictions for models, not measurements.

## Round one, revised

Terms I use throughout:

- **The goal** is what's wanted.
- **The route** is how the reader pursues it: what it reads, runs and tries, and in what order.
- **A binding rule** is one the reader may not overrule on its own.
- **Route knowledge** is what the writer knows about the route, offered rather than ordered.

---

❓ **Q1 - Where does a binding rule's authority come from?** You said to leave "the door open for a model to overrule certain rules that aren't absolutely necessary." That leaves open who decides what is absolutely necessary. My first version judged by what the rule is about: goal and done were binding, route wasn't. The research breaks that, because "done" can carry a cap (point 1). The alternative judges by who owns the rule. A rule is binding only when it comes from someone who owns that decision:

- you;
- a ticket or spec you approved;
- an orchestrator, for the things it owns (for example, which files other subagents are writing right now).

Everything else is route knowledge.

Two cases to test it on:

- **The delegation rule.** It's about the route, a hook enforces it, and it's binding because you set it after an agent broke it knowingly.
- **"Read only the diff."** Lanes added it to reviewer briefs to save cost, and no one who owned that decision asked for it. Under this test it could never have been binding.

The second half of the question: must a binding rule also carry its reason in the text?

➡️ Ownership decides what is binding, and every binding rule carries its reason. The reason is what lets a literal reader recognize the situation the rule's author didn't foresee. A rule with no stated reason is a candidate for removal.

---

❓ **Q2 - How does the writing say what "done" means without capping it?** The cases are the `spec:` gate, "only file hard bugs", "under 400 words", "zero items is the expected result" and P109's "at most N". The options:

- (a) Keep finding and filtering apart. The lane reports everything it finds, each item with its own severity and confidence. Any bar, gate or count is applied in a separate step, by a script or another lane. This is the vendor's recommendation. In the one model study of a narrow instruction, a separate critic with an open brief recovered every finding the narrow instruction had suppressed.
- (b) Keep the bar in the brief, and add a section for findings below it.
- (c) Keep bars where an owner set them.

➡️ (a). "Done" is written as the goal. Any measure is written as evidence that the goal was met, never as the goal itself, and the principle beats the measure, as in your P109 ruling. (b) still tells a literal reader that the section below the bar matters less.

---

❓ **Q3 - How does the writer pass on what it knows about the route?** The research gives the distinction I was missing: whether the task is closed or open. The options:

- (a) Treat the two differently.
  - A closed procedure, one where the correct result is fully defined, may be written as steps, with reasons.
  - An open task gets the goal, the reason, and any route knowledge the reader couldn't easily find for itself. That knowledge is worded as information, never as a command, and never emphasized. The reader may take another route and says so in its report.
- (b) Treat all writing the same way.

➡️ (a). The test is whether the result is fully defined, not whether the writer thinks the task is easy, because that judgment is exactly the prediction you warned about. A review, a research job or a design is never closed.

---

❓ **Q4 - When a rule exists to keep a reader independent, is it binding?** "Keep later review rounds blind" is legitimate: it's the forensic remedy. But a round-two reviewer can read round one's findings on the PR with one command. A rule that keeps the writer from offering its verdict is legitimate. Forbidding the reader to look is the other kind. The options:

- (a) The writer simply doesn't offer its verdict, and the brief doesn't mention it. Where independence really matters, it's built into the setup (what the reader can reach) rather than written as a prohibition.
- (b) A binding prohibition: "don't read earlier rounds."
- (c) Write nothing either way and accept what happens.

➡️ (a). Naming the forbidden thing points the reader at it. A study of models found the concept stays active inside the model after a prohibition. Where the setup can't hold independence, I'd rather lose some of it than write a wall. That's a judgment, though, and it's your call.

---

❓ **Q5 - How does a collision between a rule and the goal become visible?** Point 2 says the reader won't raise it on its own. The factory has five ways to depart from a rule, and they conflict: ask for a sign-off, follow the file and explain afterwards, `skip: <reason>`, a Provisional decision, and `accepted: <reason>`. The options:

- (a) Every lane's report has a required section: what the brief's rules or wording kept it from doing or reporting, and where it left the offered route and why. The reader treats it as essential, not optional. On screen, people who were told the definitions were essential clicked them on 81% of questions; people told they were available clicked on 23%. When the reader hits a binding rule, it stops that part, reports to the rule's owner and finishes the rest. It never shrinks the goal.
- (b) Add an independent check with an open brief after narrow lanes.
- (c) Rely on the reader to raise it, as now.

➡️ (a), and the five mechanisms become one. Whether (b) is worth its cost is a measurement question for the ticket "Decide how we'll know the writing works."

---

❓ **Q6 - Can cost or time limit the route?** The research found that tight output budgets cut reasoning models' accuracy sharply, and that reporting bars cut recall. The options:

- (a) Budgets limit what the orchestrator spends: how many lanes, which model, how many rounds. They never limit what a lane reads or writes. If a lane needs to know the time or money available, it gets that as a fact.
- (b) A budget you set may cap a lane directly.

➡️ (a). The efficiency map can reopen this with measurements.

---

The memory note that still holds the old test gets rewritten once this round settles.