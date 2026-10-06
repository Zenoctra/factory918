Yes, it changes things. I wrote round one before reading the research, which I shouldn't have done. Having read it now, three things shift:

- **The harm comes through more than the limits on reading.** The research finds rules about method doing damage in several ways:
  - A bar on what counts as worth reporting makes the reader leave out findings it already made.
  - Telling the reader what to look at decides what it doesn't see.
  - A measure of the goal gets treated as the goal itself.
  - Step-by-step method slows down a capable reader.
  - Controlling wording works worse than the same limit stated as information.

  The research warns that this grouping is one reading of the evidence, not the whole space.
- **"What done means" is not safe ground.** In round one I counted it as binding. The research on measures replacing goals, and the factory's own `spec:` gate, show that's where limits on method hide best.
- **The reader rarely notices it's been narrowed, and rarely asks.** Any answer that relies on the reader saying "this rule fights my goal" fails in exactly the cases that matter.

The terms are the same as before. **The goal** is what's wanted and what done looks like. **The route** is how the reader gets there. **A binding rule** is one the reader may not overrule by itself. A **lane** is a subagent the main session briefs. The options under each question are the ones I could see, not the edges of the question, so answer outside them freely.

---

❓ **Q1 - What makes a rule binding?** In round one I proposed that a rule binds when it states the task (what's wanted, what done means, and whose authority it is) and its owner made it binding. The research breaks the "what done means" part.

People treat measures of a goal as if they were the goal, often without knowing it:
- Police under pressure to cut crime rates stopped recording crimes (Campbell, case studies).
- In experiments, managers paid on one measure of a strategy acted as if the measure were the strategy (Choi et al. 2012). Just knowing they were measured was enough, with no pay attached (Black et al. 2022).

The factory has its own cases:
- The `spec:` gate is a rule about what counts as a finished review. Under it, one reviewer filed nothing on a PR with four real bugs. Another wrote that it was "not filing hard because the Standards brief carries no ticket criteria to cite."
- Your ruling on #109's "at most N lanes" called it "a prediction, not a constraint."

The research also has a counterweight. Specific method helps when the task is simple, and sometimes the method *is* the task: "run the gate script and paste its output", "apply this patch exactly".

Proposed test: a rule binds only when it is one of these, and only when the owner of that goal or authority made it binding:
- the goal itself, in its owner's words;
- a limit on authority that belongs to someone else: merging, pushing, files another lane owns, the scope the ticket drew;
- the method, where the method is what was asked for.

Every check, gate, count, citation requirement or format that stands for the goal is evidence about the goal, not the goal. When the two disagree, the goal wins and the reader says so. The delegation rule binds under this test because it limits authority and you own it.

The alternatives:
- (a) this test;
- (b) round one's test unchanged;
- (c) no general test, so each rule is argued case by case.

➡️ (a). It's the principle-over-proxy rule from my memory, widened from tickets to every rule.

---

❓ **Q2 - What may the writer say about the route?** In round one I recommended passing on route knowledge "as something the writer knows, with the reason," and letting the reader depart from it as long as it reports that it did. The research says that's weaker than it sounds:
- **A familiar method blocks a better one.** Chess masters said they were looking for a shorter mate while their eyes stayed on the familiar one. That study is small, but the effect has been replicated since 1942.
- **Examples get copied.** Designers copied features from an example, flaws included. That finding is contested in size but real. Codex copied lines from an "anchor" function into 32–61% of its solutions (2022).
- **Readers don't notice the pull.** Models use hints without mentioning them: Claude 3.7 mentioned a hint it used 25% of the time. A suggested route can steer the reader without the reader knowing, so asking it to report departures won't catch this.
- **The vendor says current Claude reads instructions literally.** Then a suggestion reads as an order. That's a vendor observation, with no published numbers.

On the other side, the research separates two things. Relevant facts improve accuracy: clinical information helped people reading medical tests in 16 of 16 studies. What hurts is the writer's *conclusion*. Forensic science's fix is to withhold task-irrelevant information and conclusions, not context.

That suggests a split:
- **Facts about the terrain.** Things the reader couldn't easily learn itself, and what happened before. "The worktree guard refuses `git` inside `$(...)`." "This file is generated." "Three of five lanes skipped the trail review and all three missed something."
- **The writer's preferred route, or its guess about the answer.** "Start with X." "The bug is probably in Y."

➡️ Give terrain facts freely, each with its reason. Leave out the preferred route and guesses about the answer. If the writer thinks a route matters enough to suggest, it's one of two things: a rule someone owns, which goes through Q1, or a guess, which stays out.

---

❓ **Q3 - What happens when a rule fights the goal?** The factory has five departure mechanisms, and they disagree:
- say so and get a sign-off first;
- follow the file, then explain;
- re-read the reasoning, or record your own call;
- skip a step visibly with `skip: <reason>`;
- send the departure back up to the artifact or the human, as with `accepted: <reason>`.

The research adds a problem none of them handles: the reader often doesn't notice.
- People told they could ask for help asked on 4% of the occasions help was given (Conrad & Schober). Current models almost never ask on underspecified coding tasks (Ambig-SWE).
- In one 2026 preprint, a narrow task instruction stopped models reporting critical findings they otherwise reported. A second model with an open-ended brief recovered every one of them. That's a single author, not yet peer reviewed.

The narrowing happens quietly. No conflict gets flagged, and the finding just never shows up.

Two findings point to remedies:
- **Wording the check as essential, not optional, changes behaviour.** Readers told definitions were *essential* checked them on 81% of questions. Readers told they were *available* checked on 23%.
- **A structured handoff that ends with the receiver restating the plan cut medical errors 23%** across nine hospitals (I-PASS). That study wasn't randomized and bundled training with the template.

Proposed:
- One mechanism replaces all five.
- Guidance that isn't binding may be overruled freely, and the report says so.
- A binding rule that fights the goal: the reader tells the rule's owner, and breaks it only if the owner agrees. If the owner can't answer in time, the reader leaves that part undone, does the rest, and reports.
- The reader never narrows the goal to fit a rule.
- Every report carries a section worded as required: what I didn't do, what I couldn't do, and what I left out, each with its reason. This section exists because the reader won't reliably notice by itself.

➡️ This. Whether a second, open-briefed reader becomes a standing backstop is a cost question. It belongs to the tickets for the writing standard and the templates, not here.

---

❓ **Q4 - May an orchestrator turn its own judgment into a binding rule?** (The orchestrator is the session that briefs lanes.) The answer is unchanged, and the evidence behind it is stronger:
- Interrogators told to expect guilt asked guilt-presuming questions, and neutral listeners then judged the suspects' answers as more defensive (Kassin et al. 2003). The briefing's premise shaped everything downstream.
- Telling a code reviewer the code was bug-free cut detection from 97% to 4% for a small model, and from 96% to 89% for Opus 4.5 (single study, 2026).

An orchestrator's guess about the route is usually also a guess about the answer.

➡️ No. It passes down your rules, the ticket's, and AGENTS.md. It binds only what it owns, such as which files other lanes hold right now. Everything else goes through Q2.

---

❓ **Q5 - Budgets.** In round one I treated output caps as cost rules. The research says they're mostly reporting bars:
- Radiologists who found one abnormality kept searching just as long but grew more reluctant to report a second (Berbaum 2015).
- Anthropic reports the same of its models. Under "only report high-severity issues", the model finds the bugs, then leaves out the ones under the bar. Its advice is to ask for every finding with a confidence and severity, and filter in a separate step.
- Telling a reader how many problems to expect moves its bar too: missed targets went from 7% when targets were common to 30% when they were rare.
- Tight token budgets cut reasoning models' accuracy sharply (secondary source).

➡️ Budgets bind the orchestrator's dispatch: how many lanes, which model, when to stop launching. They never bind a lane's report. If a lane has to know about a time or token limit, the brief states it as a fact, along with what to do when it runs out: hand back what's done and list what's left. It is never a cap on findings or length. Filtering happens after the report, in a separate step. The efficiency map can revisit this with measurements.

---

❓ **Q6 - How are binding rules worded?** This question is new.
- People given the same limits worded as control were less creative than people given them worded as information (Koestner 1984). A rule given with its reason was taken on better (Deci 1994). Both are human studies.
- Anthropic says current Claude over-applies emphatic wording like "CRITICAL" or "MUST", and generalizes from the reason behind a rule. That's vendor guidance without numbers.
- A prohibition that offers nothing else to do tends to move the model to a different fixed default rather than to good judgment. That's measured in older models; frontier models mostly comply.
- Garfinkel and Suchman argue that no rule can contain every situation it will meet. The reason is what lets the reader apply it to the case nobody foresaw.

The factory is uneven. The git guard's message names an alternative ("use --force-with-lease on your own branch, or ask"). "Never an arena" and the 150-line reading cap carry no reason. AGENTS.md's "ways to hurt yourself" speaks in "Never".

➡️ Every binding rule carries its reason, its owner, and what to do instead, in plain words with no emphasis. A rule whose reason nobody can state is a candidate for deletion, not for capitals.

---

❓ **Q7 - Do cold readers justify giving method?** The strongest counterweight in the research:
- Guidance helps novices and hurts experts. In a meta-analysis of 60 studies, novices gained from high assistance (d = +0.51) and experts lost from it (d = −0.43).
- A lane starting cold is a novice *on this project*, however capable it is. Low-knowledge readers learn more from text with the links spelled out.

I read these as two different gaps. A cold, capable reader lacks context: project facts, the meaning of terms it never saw coined, why things are the way they are. It doesn't lack skill at choosing a method.

➡️ No separate exception. The cold-reader finding argues for more context, which belongs to the writing standard, and not for more method. Where the method genuinely is the task, Q1 already covers it.

---

❓ **Q8 - Does this decision wait for evidence?** The research found no model study that tests a limit on strategy as such: which files a lane may read, what order it must work in, which list it must cite from. The measured model cases are reporting bars, formats, length budgets, framing and instruction load. The human evidence on complex tasks and expert readers is strong and points one way. The research also names an experiment the factory could run itself: the same open-ended task with and without an illustrative list, or with and without a route rule, counting what each finds.

The options:
- (a) decide now and treat it as settled;
- (b) decide now, record what it rests on, and hand the experiment to "Decide how we'll know the writing works" so a contradicting result reopens it;
- (c) wait for the experiment.

➡️ (b).

---

Housekeeping, no decision needed: once this round settles, I'll rewrite my memory entry that still uses the old "side effects are the exception" test. Q1, Q3 and Q6 would replace it.