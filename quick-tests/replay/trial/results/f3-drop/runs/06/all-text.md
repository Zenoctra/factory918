Yes, the research changes the questions, and in two places it overturns what I recommended. Here is what shifted, then a revised round that replaces the one above. Section numbers (§) refer to [the research note](https://github.com/Zenoctra/factory918/blob/research/wording-and-reader-context/docs/research/wording-and-reader-context.md).

**What changed**

1. **The goal side isn't safe to bind either.** My old Q1 assumed that stating what's wanted and what "done" means is always fine. The two strongest measured harms both sit there:
   - **A bar on what gets reported.** Anthropic found that "only report high-severity issues" makes Claude find a bug and then leave it out of the report. Bug-finding improved while reported findings dropped (§4).
   - **A narrow task.** In one 2026 preprint, models given a focused task stopped reporting critical findings they reported otherwise. A separate reviewer with an open brief recovered every one (§4).

   The factory's `spec:` gate is the first kind. The run-2 addendum shows a reviewer obeying it and filing nothing on a PR with four real bugs.
2. **No rule can foresee every case.** Garfinkel and Suchman argue that no rule written in advance contains the situation it will meet (§4). So the question isn't only which rules bind. It's also what every rule carries, so the reader can tell when it has hit a case the writer didn't foresee. That is your "leave it open for something you CAN'T predict", with a reason behind it.
3. **There is a real counterweight, and it's your own point.** Spelled-out method helps on simple tasks and for readers new to a field. It hurts on complex, new tasks and for capable readers (§4, a 60-study meta-analysis). That matches your line that a list is fine when a task really is closed.
4. **Two things the factory blurs are actually separate.**
   - Holding back what the writer volunteers protects the reader's independence: its conclusions, its hopes, earlier rounds' findings. Forensic science backs this (§3).
   - Limiting what the reader may look at has no evidence behind it.

   Current Claude models also read literally, so everything written binds harder than the writer meant, including words meant only as illustration (§11).

**What won't work, and why it matters for Q6**
- A generic instruction ("consider the reader", "you may depart from any rule") barely helped people or models (§10).
- A line repeated in every brief gets skimmed as boilerplate (§1).
- Readers who misread rarely notice, and rarely ask. People asked on 4% of the occasions they were offered help, and current models almost never ask on underspecified coding tasks (§8).

**What the evidence doesn't cover.** No model study tests a limit on method itself. Most model studies used 2022–2025 models. The vendor note covers Opus 4.8, not 5.5. Where a recommendation below rests on human evidence and your principle rather than a measurement on models, I say so.

The terms are the same as before:
- **The goal** is what's wanted, and why.
- **The route** is how the reader gets there.
- **A binding rule** is one the reader may not overrule by itself.

---

❓ **Q1 - What may a rule do to the reader?** Here is the revised test. A rule may do two things:
- **Say where the reader is going:** the goal, its reason, and the full nuance in the owner's words.
- **Mark what isn't the reader's to decide:** your merges, files another subagent holds, the scope a ticket draws.

A rule may not stand between what the reader notices and what it reports. Where a bar, a filter or a scope is truly needed, it is applied in a separate step after the work, to a complete report.

The cases:
- **"Only report high-severity issues."** It reads as a statement of what done means, but it's a bar between noticing and reporting. Under the test, the reviewer reports everything, each with a severity and a confidence, and a later step filters. That is also Anthropic's own recommendation.
- **The `spec:` gate** at [review-brief.sh:494](template/.agents/skills/spec-review/scripts/review-brief.sh:494). It refuses any finding without a ticket citation, so the reviewer learns to filter before it reports. Under the test, the script accepts every finding and sorts the cited ones from the uncited ones.
- **"Review this diff against the ticket."** This is a legitimate narrow goal. The preprint suggests the narrowness alone can hide findings. Under the test the goal stays, and the report still carries anything serious the reader noticed outside it.
- **"Never push to main."** This is your authority. It binds, and a hook enforces it.

One observation I want you to test, not use as the test. The rules about method that have earned their place mostly add an independent check rather than narrow the person doing the work:
- the trail review, which caught owner errors 3 times out of 3;
- delegation;
- the blast-radius check.

Filtering in a separate step has the same shape. But I'm drawing this from a handful of cases, which is the same move that went wrong with the reviewer example. So I'm not proposing it as the test.

The options:
- (a) the test above;
- (b) my old split between goal and route;
- (c) no single test, each rule argued case by case.

➡️ (a). The old split would have approved the `spec:` gate.

---

❓ **Q2 - Does a closed task get different treatment?** A subagent is a capable reader who knows nothing about this project: an expert in general and a novice here. The research says method helps on simple tasks and hurts on complex ones.

The catch is that the writer decides what counts as closed. Writers consistently overestimate how much of their picture the reader shares (§6), so a writer will call a task closed when it isn't.

- **A closed case:** renaming a symbol across forty files with a known codemod. Spelling out the method helps.
- **An open case:** finding what's wrong with a diff. It isn't closed.

The options:
- (a) one treatment everywhere;
- (b) closed tasks may carry method as binding rules;
- (c) one treatment, scaled: route knowledge is always offered as knowledge, and a closed task simply gets more of it.

➡️ (c). Don't make an exception that turns method into a binding rule, because the writer's judgment of "closed" is the weakest link. A closed task gets more help, not less freedom.

---

❓ **Q3 - How is route knowledge written?** What the research says:
- **Information beats orders.** The same limit, stated as information rather than as an order, didn't lower creativity in people (§4). Current Claude models over-apply emphatic instructions (vendor guidance).
- **A reason makes a rule work.** A rule that comes with its reason is followed better and more flexibly. The vendor says the model generalizes from the reason, and the reason is what lets the reader spot the case nobody foresaw.
- **A prohibition gives no direction.** It names the forbidden thing and keeps it in mind, without saying what to do instead (§5).
- **A sample route gets copied.** Readers reproduce it, flaws included (§2).
- **Context costs attention.** Text added "to be safe" takes attention from everything else (§9).

The cases:
- [ticket.md:10](template/.agents/skills/poteto-mode/playbooks/ticket.md:10) is already in the right form: read the tier in two plain commands, because the worktree guard refuses `git` inside `$(...)`. It states a fact and its reason, so the reader can tell when it doesn't apply.
- [knowledge/SKILL.md:20](template/.agents/skills/knowledge/SKILL.md:20), "never read more than 150 lines in one call", is an order with no reason. The audit found none recorded anywhere.

The options:
- (a) leave route knowledge out;
- (b) write it as information with its reason; the reader may depart from it and says so;
- (c) write it as a default the reader may override.

➡️ (b), and only for things the reader couldn't easily find out for itself. A rule whose reason nobody can state is a candidate for deletion, not rewording.

---

❓ **Q4 - Who may make a rule binding?** Two research findings bear on this:
- **What the asker expects shapes the answer.** Interrogators told to expect guilt asked questions that produced it (§3). An orchestrator's guess about where the problems are, made binding, turns into a search for confirmation.
- **A derived measure quietly replaces the goal** (§4). Your P109 ruling on "at most N lanes" is the factory's own case.

My proposal:
- **Who binds.** Binding comes only from whoever owns the authority: you, AGENTS.md, and a ticket scope you approved. The orchestrator binds only what it truly owns, such as which files other subagents hold right now.
- **Derived measures.** Counts, caps and gates that a writer derives are evidence of the goal, never the goal. When they disagree, the goal wins.
- **Budgets.** A budget you set binds. One an orchestrator invents to save cost is knowledge at most, and tight length budgets measurably hurt reasoning models (§4).

The options:
- (a) the proposal above;
- (b) the orchestrator may also make its own judgments about the route binding.

➡️ (a).

---

❓ **Q5 - Holding back versus forbidding.** Forensic science protects an examiner's independence by withholding conclusions and earlier decisions. Withholding relevant context hurts, though: across 16 studies, giving readers clinical information improved their accuracy and none found a loss (§3). So the line runs between relevant context and someone else's conclusion.

Models show the same pull. Telling a reviewer the code was bug-free dropped detection from 96% to 89% for Opus 4.5, and from 97% to 4% for a small model.

So the standard would treat these as two separate things:
- **What the writer volunteers.** It holds back its conclusions and hopes, and it gives all the relevant context.
- **What the reader may look at.** Nothing is forbidden.

**The hard case** is your rule that later review rounds stay blind to earlier rounds' findings.
- The writer can hold those findings back, but round one's comments sit on the PR. A round-two reviewer that reads them loses its independence.
- Holding back can't prevent that. Only forbidding it, or structure, can.
- Asking the reviewer to "say so if you read them" won't hold either. In two studies, models mentioned a hint they had used only 25–39% of the time (§3).

The options:
- (a) restraint only: the reader may read anything, and reports what it read;
- (b) a prohibition in the brief, binding because you own the rule;
- (c) structure: round two gets the diff and the ticket from somewhere other than the PR, or a hook covers reviewer subagents, so nothing has to be forbidden in prose.

➡️ (c), applied narrowly to earlier rounds' findings and nothing else. It's the one limit on looking that has an owner and a measured reason, and a written prohibition is the weakest way to carry it. How the structure works belongs to the ticket "Decide where each piece lives and when it reaches the writer".

---

❓ **Q6 - What does the reader do when a rule fights the goal?** Today five mechanisms disagree:
- say so and get a sign-off first;
- follow the rule, then explain;
- `skip: <reason>`;
- record a provisional decision;
- end a flag with `accepted: <reason>`.

Q2 above explains why conflicts are certain, and why readers rarely notice or ask. One more finding matters here: people told that checking a definition was *essential* checked 81% of the time, and people told it was *available* checked 23% (§8).

My proposal is one mechanism that replaces all five:
- **For route knowledge:** the reader takes its own route, and the report says where and why.
- **For a binding rule:** the reader stops that part, reports the conflict to the owner, and carries on with the rest. It never narrows the goal to fit the rule.
- **In a live conversation with you:** say so loudly and get your sign-off, as today.

Make the report expected, not offered. Every report has a required place for "where the brief or a rule fought the goal, and what I did", just as it has a place for the result. A permission line pasted into every brief gets skimmed; a required slot in the report gets filled.

The options:
- (a) the proposal above;
- (b) keep the five mechanisms;
- (c) depart and report, for binding rules too.

➡️ (a).

---

Two things to carry forward, neither needing your decision now:
- **An experiment for the ticket "Decide how we'll know the writing works".** The research flags one nobody has run: give subagents the same open task with and without an illustrative list, and count what each finds outside it. It would test Q1 and Q3 on Opus 5.5 directly.
- **My memory.** Once this round settles, I'll rewrite the memory that still states the old test.