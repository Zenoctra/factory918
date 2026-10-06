I'm partway through the research note, at the section on rules about how to do a task. When I've finished reading it I'll rewrite round one.

---

Yes, it changes the round. I read the whole note, `docs/research/wording-and-reader-context.md` on the `research/wording-and-reader-context` branch. Three findings change my questions, and one shows that my earlier test was wrong.

1. **My old Q1 test fails against the strongest model finding in the note.** I proposed that rules about "what done means" should be binding. The best-documented harm to models is a reporting bar such as "only report high-severity issues". Anthropic's guide for Opus 4.8 says the model still finds the bugs, then leaves the ones under the bar out of its report. That rule is about what done means, so my test would have made it binding. The run-2 `spec:` gate is the same failure inside the factory. "Done" now gets its own question.
2. **A reader allowed to depart from a rule often doesn't notice when it should.** One model study tested whether a narrow task instruction hides findings (Shin 2026). The models left out what the instruction pushed aside, and a separate critic with an open-ended brief recovered all of it. Models also act on hints without mentioning them in their reasoning. So a rule that only works if the reader notices the conflict is weak on its own.
3. **The note draws a line I didn't have: a subagent starts as an expert at the work but new to the project.** Step-by-step method helps novices and hurts experts (a meta-analysis of 60 studies). Explicit links and definitions help readers who lack background. That splits what I called "route knowledge" into two kinds.

**How strong the evidence is.** No model study tests a limit on method itself, such as which files to read or what order to work in. The broad framing rests mostly on studies of people. The model results behind it are a single study, a preprint, and vendor guidance with no numbers, and all of them tested models older than Opus 5.5. The note says this itself in sections 4 and 13.

**Terms.** Goal, route and binding mean what they did in the last round. Two new ones:
- **The terrain** is facts about the project and the situation that the reader can't see from where it starts: what a term means, a quirk of a tool, why a rule exists.
- **Directions** are the writer's plan for how to do the work.

---

❓ **Q1 - What is a rule in a brief, and which rules bind?** Two sources point the same way:
- Garfinkel and Suchman argue that no set of instructions can be complete. A plan is something to act with, not a specification of what to do.
- You said we should leave "the door open for a model to overrule certain rules that aren't absolutely necessary."

Together they suggest a default: a rule in a brief is something the reader may depart from, so it travels with its reason. Only a narrow class can't be overruled.

My revised test for that class: a rule binds when it records a decision that belongs to someone other than the reader, and only that owner can make it binding. You merge PRs. Another subagent owns its files. The ticket's scope says what may be changed. Under this test the delegation rule binds because you set it, and the orchestrator's guesses about the route don't. The research shows why those guesses mustn't bind:
- Interrogators told to expect guilt asked questions that presumed guilt (Kassin 2003).
- Commanders trying to state only their intent wrote orders full of method, and their subordinates' actions matched that intent 34% of the time (Shattuck 2000).

One addition: a binding rule may limit what the reader changes, but never what it notices and reports. In the radiology studies, readers kept searching after a first find; what dropped was their willingness to report a second one (Berbaum 2015). Shin and the reporting-bar finding show the same in models.

This could look like the "protect the world" test you rejected. I think it differs in two ways:
- The test is who owns the decision, not how much harm the rule prevents.
- The report half comes from radiology, survey research and models, not just from reviewers.

Tell me if it's the same collapse in new clothes. The options:
- (a) Rules are resources by default. Binding means the owner's decisions. Binding rules limit changes, never reports.
- (b) The same, without the split between changes and reports.
- (c) Rules are orders by default, and the writer marks the ones that may be overruled.

➡️ (a).

---

❓ **Q2 - How do we write "what done means" so it doesn't become a cap?** The research's strongest pattern is that what a reader is told done looks like changes the work itself:
- **Specific goals on complex tasks.** A specific goal hurt on complex, novel tasks. A goal to learn did better on complex tasks than either a specific goal or "do your best" (Winters & Latham 1996).
- **Output budgets.** Tight token budgets on the answer cut reasoning models' accuracy sharply (Sun 2025).
- **Measures replace the goal.** Being measured was enough to make the measure replace the goal, with no reward attached (Black 2022). That is your P109 principle-over-proxy rule, found independently in management research.
- **Expected counts move the bar.** When targets appeared on 50% of trials, observers missed 7% of them. At 1% they missed 30%.

The fixes share a shape. Anthropic recommends that a reviewer report every finding with its confidence and severity, and that a separate step does the filtering. In a study of output formats, answering in plain prose and converting to the required format afterwards removed most of the loss. Both move what the next step needs (a filter, a format, a length) out of the work and into a step after it. The options:
- (a) Done is stated as the purpose, plus checks that act as floors and never as ceilings. Anything a later step needs (filtering, a format, a length, a count) happens in a separate step after the work. No expected counts. When a criterion and the purpose disagree, the purpose wins, and the brief says so.
- (b) The same, but the done criteria may include caps when a later step needs them.
- (c) The writer decides case by case.

➡️ (a).

---

❓ **Q3 - What may the writer say about the route?** This fits your Q9 preference: the task's source words go into the brief whole. The question is only what the writer adds of its own. Two findings pull in opposite directions:
- **Experts don't need method.** As above, step-by-step method helps novices and hurts experts, while explicit links and definitions help readers without background (McNamara 1996). A subagent is an expert at the work and new to the project.
- **An offered method pulls even when marked optional.** Chess masters who said they were searching for a shorter mate kept their eyes on the familiar one (Bilalić 2008). Codex, given a related function to look at, copied its lines into 32–61% of solutions. Current Claude models also read instructions literally, so words meant as illustration bind harder.

Forensic science adds a third line. Give the context the task needs, and withhold context that only carries someone's conclusion:
- Clinical information made medical test readings more accurate across 16 studies.
- Case context made fingerprint experts contradict their own earlier matches.

The options:
- (a) Give the terrain generously, with reasons. Never give directions or the writer's own conclusions. Write a trap the writer hit as a fact, not a step. For example, "the worktree guard refuses `git` inside `$(...)`" is terrain.
- (b) The same, but allow directions as "what worked for me", with the reason.
- (c) My earlier recommendation: route knowledge as the writer's experience, whenever it seems useful.

One counterweight: on a simple, mechanical task, a specified method helps. There the method is usually what done means ("run these four commands"), which Q2 already covers.

➡️ (a).

---

❓ **Q4 - What happens when a rule fights the goal?** The factory has five mechanisms for departing from a rule, and they conflict:
- ask for a sign-off first;
- follow the file and explain afterwards;
- skip the step with a stated reason;
- decide and record a Provisional row;
- `accepted: <reason>` on a writer's flag.

A subagent has no way to get a sign-off. The research also says the reader often won't notice the conflict:
- Scripted survey interviews got unusual cases right 28% of the time.
- Respondents asked for help on 4% of the occasions it was offered.
- Models almost never ask on underspecified coding tasks.

Two wording findings bear on how a permission to depart is written:
- Readers told that definitions were *essential* checked them 81% of the time; readers told they were *available* checked 23%. So a permission to depart has to be written as expected behavior, not as an option.
- A line repeated in every brief gets read as boilerplate.

My proposal has two parts:
- **The reader's side.** If a binding rule fights the goal, the reader stops that part, reports the conflict to the rule's owner, and finishes the rest. If a non-binding rule fights the goal, it departs and says why. It never shrinks the goal to fit a rule.
- **The structure's side.** The reader opens its report by restating the goal and the rules as it understood them. This copies the medical handoff program I-PASS, where the receiver restates the plan. Across nine hospitals I-PASS cut medical errors by 23%, though it came bundled with training. The restatement shows the writer a misreading even when the reader didn't notice one.

Shin's separate open-ended critic also belongs in this picture, but which check and where it runs are for "Decide how we'll know the writing works" and "Decide where each piece lives". I'll note it on those tickets. The options:
- (a) Both parts, as one mechanism that replaces the five.
- (b) The reader's side only.
- (c) Keep all five and clarify each.

➡️ (a).

---

❓ **Q5 - Where do budgets live?** The research shows a budget written into a brief pulls on the work even when it's stated as a fact. Output-length budgets cut reasoning, expected counts move the reader's bar, and being measured is enough to turn a measure into the goal. That changes my earlier recommendation. The orchestrator already controls cost where it dispatches: how many subagents, which model, what effort level. None of those touch the reader's text. The options:
- (a) Budgets live in the dispatch. If there is a hard stop the reader can't see, such as a timeout, the brief states it as a fact along with what happens at the stop. It never states a target.
- (b) My earlier recommendation: the budget goes into the brief, stated as a fact.
- (c) Budgets you set bind and may cap the route.

➡️ (a). The map "Optimize token use and wall-clock time without losing reliability" can test whether control at dispatch is enough.

---

❓ **Q6 - How is a binding rule worded?** These are the rules a reader can't overrule, so their wording carries the most weight. The research:
- **Prohibitions.** In older and smaller models, a "don't" kept the forbidden idea active. Frontier models mostly comply, but often settle on some other fixed default instead, because "don't" says nothing about what to do.
- **Emphasis.** Anthropic says current Claude models over-apply emphatic wording like "CRITICAL: You MUST".
- **Control versus information.** In people, the same limit lowered creativity when worded as control and didn't when worded as information (Koestner 1984). A rule with its reason is taken up better and applied better at its edges.

The factory's rules are uneven here. Some carry their reason, and many don't, such as "never an arena" and the 150-line reading cap. The options:
- (a) Every binding rule is written plainly, with its reason, and says what to do rather than only what not to do. No emphasis.
- (b) The same, but emphasis is allowed for the few rules that guard against irreversible actions.
- (c) Leave all wording to "Decide what the writing standard is and what carries it".

➡️ (a). The writing standard as a whole belongs to that ticket. This question covers only the wording of binding rules.

---

What became of the first round's questions:
- The old Q1 and Q4 merged into the new Q1.
- The old Q2, Q3 and Q5 became Q3, Q4 and Q5.
- Q2 and Q6 are new.

The housekeeping item still stands: once this settles, I'll rewrite my memory note that still uses the old test.