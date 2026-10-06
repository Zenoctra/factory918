Yes. Most of the questions change, and two are new. I've rewritten the whole round below, so answer this version instead of the old one.

The biggest change is the first question itself. Round one asked which rules are allowed. The research says to start somewhere else: a rule written in advance can't contain the situation it will meet (Garfinkel; Suchman, section 4 of the [research note](https://github.com/Zenoctra/factory918/blob/research/wording-and-reader-context/docs/research/wording-and-reader-context.md)). Every rule will hit a case its writer didn't foresee. And in the evidence, rules did harm less by existing than by how they arrived:

- without a reason;
- in controlling wording;
- disguised as the goal, or as the definition of done.

That last one changes my old recommendation. Round one treated "what done means" as safe to bind, and the evidence says it isn't.

The new questions lean on your words in two places:
- Your answer to Q2 on the map: "if you could predict it, then you could constrain it. The point is to leave it open for something you CANT predict."
- Your ruling on the "at most N lanes" criterion: "a prediction, not a constraint."

One caveat before the round. No study tests a limit on a model's method directly (section 4, "What the evidence does not show"). The closest evidence on models is ours, from run 2:
- 4 of 13 labelled bugs sat in files the brief told the reviewer not to open.
- The `spec:` citation gate made a reviewer file nothing on a PR with four real bugs.

Everything else here rests on research with people, on theory, and on those runs.

---

❓ **Q1 - What separates a rule that binds from one that doesn't?** Round one's test said a rule binds when it states what's wanted, what done means, or what isn't the reader's to decide. The research breaks the middle part. These are the harms it has measured so far; the list is what's been studied, not the edge of the problem:

- **A bar on what to report.** Radiologists who had already found one nodule searched just as long for a second, but became reluctant to report it (Berbaum 2015). Anthropic says the same of Claude: tell it "only report high-severity issues" and it still finds the bugs, then leaves them out of the report. Our `spec:` gate did exactly this.
- **A narrow task.** In one 2026 preprint, a focused instruction stopped models reporting critical findings they reported without it. A separate critic with an open brief recovered every one of them. This is the gorilla study run on models.
- **A measure standing in for the goal.** Managers paid on one measure acted as if the measure were the strategy. That's the same thing as the "at most N lanes" criterion you overruled.

Here is a test I'd propose instead, built from your two quotes above. Ask whether the rule is a **decision**, a **fact**, or a **prediction**:

- A **decision** binds, but only if the person who holds that decision made it. You merge PRs. You set the delegation rule. The ticket says what's wanted.
- A **fact** is just stated. "The guard refuses `git` inside `$(...)`." "Paths contain spaces."
- A **prediction** is the writer's guess about what will work. It never binds. Examples: "read only the diff", "report only high severity", "stop after N", and an acceptance criterion read as the goal itself. These are guesses about where the bugs are, what matters, and what success looks like.

Some cases to test it against:
- "Report only high severity" becomes "report everything with a severity; filtering happens after."
- The acceptance criteria stay your decision, but they are evidence the goal was met, and the goal wins when the two conflict. That's the rule you already set after the "at most N lanes" case.
- "Owners start one at a time" is the hard case. It has a measured reason, but is it a decision about what the orchestrator owns, or a prediction? Your answer there will show whether the test holds.

The options:
- (a) round one's test;
- (b) decision, fact or prediction;
- (c) no test, and every rule is argued case by case.

➡️ (b). It keeps what was right in round one, since a decision binds only when the person who owns it made it. It also catches the bars and narrow goals that round one let through as "the task". And it states what all the failures share, instead of listing them.

---

❓ **Q2 - How does the writing carry a prediction about the route?** In round one I recommended sharing route knowledge with its reason. The research says that isn't free either:

- **A known method blocks a better one.** Chess masters shown a familiar mate said they were looking for a shorter one, while their eyes stayed on the familiar squares.
- **Examples get copied.** Designers copied features of an example even after being told the features were flawed. Codex copied lines from a related function into 32–61% of its solutions.
- **Guidance only helps beginners.** Step-by-step guidance helped novices (d = 0.51) and hurt experts (d = −0.43).

A lane is expert in skill and new to the project. What resolves this: give the newcomer what it lacks, which is facts about the terrain, and hold back what the expert doesn't need, which is the method. Write "the guard refuses `git` inside `$(...)`, because…" and let the reader work out its route, not "read the tier in two plain commands." Write a method in only when it cost something to learn and the reader couldn't easily find it. Then include the reason and the case it was learned on, so the reader can tell whether its own case matches.

The options:
- (a) leave predictions out;
- (b) facts always; methods rarely, with the reason and the case they came from;
- (c) methods as defaults the reader may override.

➡️ (b).

---

❓ **Q3 - Do closed tasks get different treatment? (new)** In your first message you said lists are fine "if you are looking at a closed ended task where the options truly ARE listable and complete." The evidence agrees, up to a point:

- Specific goals help on simple tasks.
- Scripted survey interviews were near perfect when the respondent's situation was typical.
- On atypical cases, scripted interviews got 28% right and flexible ones 87%. Atypical cases are what lanes exist to catch.
- The writer is the worst judge of how closed its task is. Experts misjudge how hard a task is for someone new to it, and they resist correction.

The options:
- (a) one treatment for every task;
- (b) the writer marks a task closed, and closed tasks may carry method;
- (c) closed tasks may carry method as a default, always with its reason and the reader's licence to leave it when its case doesn't fit.

➡️ (c). It's really Q2 with a lower bar for including method, so it needn't be a separate rule.

---

❓ **Q4 - What does the reader do when a binding rule fights the goal?** The factory currently gives five answers that disagree:
- get a sign-off first;
- follow the file, then explain;
- skip the step with a reason;
- make the call and record it as Provisional;
- mark a flag `accepted: <reason>`.

Whatever we decide here replaces all five. The research adds a problem none of them deals with: readers rarely notice the conflict, and rarely say so.

- People who misread a question are often confident in the misreading.
- Told they could ask, survey respondents asked on 4% of the occasions help was given. Models on underspecified coding tasks almost never asked.
- A model's reasoning mentioned a hint it had used only 25–39% of the time, so reading its reasoning won't reliably show it.
- Calling definitions "essential" instead of "available" raised how often people checked them from 23% to 81%.
- The medical handoff format that cut errors by 23% ends with the receiver restating the plan.

So "say so if a rule fights you" won't fire as an invitation. It has to be a required part of the report: where the reader left the brief and why, and where a binding rule stopped it. The options for the conflict itself:
- (a) stop that part, report the conflict to the rule's owner, and carry on with the rest;
- (b) break the rule and report it;
- (c) narrow the goal to fit the rule.

➡️ (a), plus the required section. Predictions don't bind, so the reader can leave them freely and report it in that same section. Never (c).

---

❓ **Q5 - Who may write a binding rule into a brief?** Under Q1's (b), only the person who holds the decision. The orchestrator passes your decisions down and binds what it owns itself, for example which files other subagents are writing right now.

The research also explains how reading limits passed as protecting the reviewer's independence. The forensic evidence separates two things:
- **What the writer volunteers.** It supports the writer keeping its own conclusions to itself. Interrogators who expected guilt asked guilt-presuming questions. Telling a model the code was bug-free cut its detection from 97% to 4%.
- **What the reader may look at.** The evidence gives nothing in favour of limiting this. In all 16 studies of medical tests, information relevant to the task made readers more accurate.

➡️ The orchestrator may hold back its own guess about the answer; whether and how is for the writing-standard ticket ("Decide what the writing standard is and what carries it") to decide. It may never limit what the reader looks at.

---

❓ **Q6 - Can cost or time limit the route?** There's direct evidence on caps:
- Under tight output budgets, reasoning models fell sharply. Phi-4-reasoning went from 72% to 53% at 1,024 tokens.
- Reporting bars cause withholding (Q1).

Anthropic's advice points to a general pattern: if you want less output, filter after the producer, not inside it. Ask for every finding with a confidence and a severity, and filter in a separate step. A budget the reader really has to live within, such as wall-clock time or money, is a fact it plans with.

The options:
- (a) a budget is stated as a fact, and any filtering happens downstream;
- (b) a budget you set binds and may cap the route directly;
- (c) budgets stay out of the writing.

➡️ (a). A budget you set is binding as a decision, but it's still stated as the budget and the reason, and the reader decides how to meet it. The efficiency map can revisit this once it has measurements.

---

❓ **Q7 - How is a binding rule worded? (new)** The evidence:
- Children painted less creatively under the same limits when the limits were worded as control instead of information.
- Anthropic says current Claude models over-apply emphatic instructions and read instructions literally, so every word binds harder, examples included.
- A bare "don't" keeps the forbidden idea active and gives no alternative, so the model lands on some other fixed default.
- A rule that comes with its reason generalizes to cases the writer didn't foresee.

The factory's git guard already does this right: when it blocks, it names the alternative. Elsewhere, rules like "never an arena" and the 150-line reading cap carry no reason at all.

The options:
- (a) every binding rule carries its reason and what to do instead, in plain words, with no capitals or "CRITICAL";
- (b) the reason only;
- (c) leave the wording to the writing-standard ticket.

➡️ (a). The reason matters most, because it's the only part of a rule that reaches the case nobody predicted.

---

❓ **Q8 - Decide now, or wait for measurement? (new)** The ticket "Decide how we'll know the writing works" could test this directly. One way: give the same review to two lanes, one with a reading limit or a reporting bar and one without, and count what each finds.

➡️ Decide now from the theory and run 2's evidence, and ask that ticket to include the experiment. If the results disagree, the decision gets reopened.

---

My memory still says "safety rules about side effects are the exception." Once this round settles, I'll rewrite that line to match.