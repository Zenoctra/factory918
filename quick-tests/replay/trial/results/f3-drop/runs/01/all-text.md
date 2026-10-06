Yes, the research changes round one. Four things move, and I'd also change how I ask.

**What changed:**

1. **Round one treated "what done means" as a binding rule. It's where some of the worst limits hide.** People held to a measure start treating the measure as the goal, often without noticing. A bar on what's worth reporting makes reviewers leave out things they already found. The run-2 audit has a case from this factory: a reviewer was required to cite a ticket line for every finding, and it filed nothing on a PR that had four real bugs. Your correction says "pursued **or completed**", so the finishing side gets its own question below.
2. **Round one treated everything a writer says about the route as one kind of thing. The research splits it into three:**
   - facts about the project, which help a reader that starts with no context;
   - advice on method, which tends to hurt a capable reader;
   - the writer's guess at the answer, which leads the reader even when it's offered as information.
3. **Round one assumed a reader notices when a rule works against the goal and says so. Readers rarely do.** That holds for people and for models. Models also act on hints without mentioning them. Permission to break a rule isn't enough; the report has to ask.
4. **The research has a gap.** No study tests a limit on a model's method directly. The closest model evidence is the factory's own:
   - 4 of 13 known bugs were in files the reviewer's brief told it not to open;
   - the reviewer above filed nothing.

   The human evidence points the same way. Confirming it on current models is a job for "Decide how we'll know the writing works".

**How I'm asking differently.** Round one gave you lettered menus. The research's best-replicated finding on lists is that a list limits the answers, even when it explicitly invites "other". This round gives each question, my recommendation and the reasons for it. If you disagree, you can disagree with a reason instead of picking a letter. My recommendations still pull your answer toward them, so push on the reasons.

The three terms are the same as round one:
- **Goal**: what's wanted.
- **Route**: how the reader gets there.
- **Binding rule**: a rule the reader may not overrule on its own.

---

❓ **Q1 - What may bind the reader?**

My round-one test, revised:

- **Binding is limited to the goal and the limits of someone's authority.** "What done means" moves out of the binding list; Q2 takes it.
- **Only the rule's owner can make it binding.** This is unchanged.
- **Every binding rule carries its reason.** This is new.
  - No rule written in advance can cover every situation it will meet (Garfinkel; Suchman). That's argued, not measured. The reason is what lets the reader spot the case the rule didn't foresee.
  - Anthropic's guide says Claude generalizes from the reason behind an instruction (vendor guidance, no published numbers).
  - In people, the same rule given with its rationale is accepted better (self-determination research).
- **Binding rules should be few and plainly worded.**
  - Current Claude models over-apply instructions written emphatically (vendor).
  - In one test, the best of 20 models followed only 68% of 500 rules given at once, favoring the earliest ones.
  - A bare "never X" tends to leave a model on some other fixed default, so a binding rule should say what to do instead. That was measured in older and smaller models and is observed by Anthropic in current ones.

Two cases to test this against:

- **"Copy these files unchanged."** The research's counterweight is that step-by-step method helps on simple tasks. This rule needs no exception: the method *is* the goal, an unchanged copy, so it binds as goal. The test is whether the method is part of what's wanted, not whether the writer judges the task simple. Writers overestimate how well they're understood: tappers expected 50% of listeners to name the tune, and 2.5% did. So the writer's sense of "simple" is the weak part.
- **The delegation rule.** It's about the route, but you own it, it carries a reason (keeping the writer and the reviewer separate), and the ledger holds evidence for it. Under this test, your phrase "rules that aren't absolutely necessary" gets a definition: a rule is absolutely necessary when you or the ticket made it binding and its reason says what breaks without it.

➡️ A rule binds only if three things hold:
- it states the goal or a limit of someone's authority;
- its owner made it binding;
- it carries its reason.

Everything else is information the reader weighs. An orchestrator passes your rules down. It binds only what it owns, such as files another subagent holds right now. It never turns its own guess about the route into a rule.

---

❓ **Q2 - How is "completed" written?**

The research:

- **Measures replace goals.** People rewarded on one measure acted as if the measure were the strategy, without realizing it. Knowing they were being measured was enough to cause it, even with no pay attached (Choi 2012; Black 2022).
- **Reporting bars cut what gets reported, not what gets found.** Radiologists who had found one abnormality kept searching just as long, then held back the next (Berbaum 2015). Anthropic's guide reports the same for Claude: "only report high-severity issues" lowered measured recall even as bug-finding improved. That's vendor guidance with no published numbers.
- **Specific goals backfire on complex tasks.** On novel problems, people with a specific goal closed the distance to it step by step and learned less about the problem than people without one (Vollmeyer 1996).
- **You've already ruled this way.** You said an "at most" count was "a prediction, not a constraint". The reviewer case above is the same failure.

➡️ "Done" is written as two things: the goal, then the evidence that would show it's reached, labelled as evidence. When the evidence and the goal disagree, the reader follows the goal and says so in its report. This is your "principle beats proxy" rule. My recommendation moves it out of my memory and into the writing standard.

For judging work, the reader reports everything it found, each finding with its confidence and severity. Any bar is applied afterwards, by the writer (Q3).

---

❓ **Q3 - Where does the writer meet its own needs?**

Writers sometimes have real needs: a short output for the next step, a checklist covered, a budget kept. The research points to one answer for all of them: the writer meets the need in its own steps around the reader, not inside the reader's route.

- **A narrower output.** Filter it afterwards. This is Anthropic's own recommendation.
  - In one 2026 preprint, a narrow task instruction stopped models reporting critical findings they reported without it. A separate reader with an open brief recovered every one. It's a single, unreviewed study, but it's the only one that measures this.
- **A checklist covered.** Ask the open question first and send the list as a second pass.
  - Offering four problems in a list moved them from 2% of answers to 60%.
  - The same experiment shows the other side: listing "the invention of the computer" raised it from 1–2% of answers to about 30%. A list also reminds people of things they would have counted but forgot.
  - Asking open first, then giving the list, gets the reminder without losing the answers that would have come from outside it.
- **A budget.** State it as a fact about the situation. Tight output budgets hurt reasoning models: one fell from 72% to 54% (Sun 2025). How big a budget should be belongs to the map "Optimize token use and wall-clock time without losing reliability".

➡️ This is the default shape. When the writer needs something narrower than the goal, it does the narrowing in its own later step. A budget is stated as a fact, never as a cap on the route, unless you set the cap yourself (Q1).

---

❓ **Q4 - What does the writer volunteer about the route?**

In round one I proposed passing route knowledge on "as something the writer knows, with the reason". The research splits that knowledge three ways:

- **Facts about the project the reader would otherwise lack.** Examples: the worktree guard refusing `git` inside `$(...)`, or that paths here contain spaces.
  - A subagent starting cold knows little about the project, however capable it is.
  - Making the links in a text explicit helps readers without background (McNamara 1996).
  - Across 16 medical studies, information relevant to the task improved accuracy, and none found a significant loss (Loy & Irwig).
  - Include these, with their reasons.
- **Advice on method.**
  - Guidance that helps novices hurts experts: in a meta-analysis of 60 studies, experts did worse with heavy guidance (d = −0.43).
  - Chess experts shown a familiar solution kept looking at it and missed a better one.
  - Leave method out. The exception is a lesson that cost a run to learn. Tell it as what happened and why, not as steps to follow.
- **The writer's guess at the answer.** Where it thinks the bug is, or what it expects to find.
  - This leads the reader even when worded as information.
  - Fingerprint experts given case context mostly contradicted their own earlier decisions on the same prints.
  - Telling a model the code was bug-free cut its vulnerability detection from 97% to 4% for a small model, and from 96% to 89% for Opus 4.5. That's a single 2026 study.
  - Leave this out of anything a judging reader receives. The research supports the writer holding back what it volunteers. It says nothing in favor of limiting what the reader may look for, and those are different things.

**Two facts that bear on the wording:**
- Current Claude models read instructions literally (vendor). "Start with X" reads as an order however it was meant.
- A note saying "these are examples, not the boundary" protects little: the list in the 2%-to-60% study explicitly invited other answers. This doesn't undo your Q9 answer, since the note costs almost nothing. It just shouldn't be the protection we rely on.

The writer's guess also overlaps with leading the witness, which "Decide what the writing standard is and what carries it" covers. I've included it here because "look at file X first" is a rule about the route and a guess at the answer at the same time.

➡️ Facts go in, with their reasons. Method stays out, except hard-won lessons told as history. The writer's guess at the answer stays out of anything a judging reader receives.

---

❓ **Q5 - What happens when a binding rule works against the goal?**

The factory already gives five answers, and they conflict:
- say so loudly and get a sign-off first;
- follow the file, then explain why your instinct differed;
- skip the step visibly, with the reason;
- decide, and record a provisional decision Manuel can overrule;
- mark the flag `accepted: <reason>`.

The research says a permission sentence won't be used:

- **Readers rarely ask, even when invited.** Survey respondents told they could ask for clarification asked on 4% of the occasions help was given. Current models almost never ask about underspecified coding tasks (Ambig-SWE).
- **Models act on hints without mentioning them.** One model mentioned a hint it had used 25% of the time.
- **Text repeated in every brief gets read past.** In surveys, a feature attached to every question stopped carrying meaning.
- **Framing the check as required, and asking the reader to restate, both worked.** Telling people that checking definitions was essential, rather than available, raised how often they checked from 23% to 81%. A hospital handoff that ends with the receiver restating the plan cut medical errors by 23%.

The wording needs care. "Which rules got in your way?" assumes some did, and an assumption in a question plants the thing it assumes. Asking models to find faults raised their false positives. A neutral version: "Which rules shaped how you did this, and did any work against the goal?"

➡️ One mechanism replaces all five:
- Every report answers that neutral question.
- When a binding rule works against the goal, the reader stops only that part, reports to the rule's owner, and carries on with the rest.
- A rule that isn't binding may be broken, and the break is reported.
- The goal is never narrowed to fit a rule.

A reader's own report won't catch every case, because a reader steered by a hint often can't see that it was. Whether a separate reader with an open brief checks for this is a question for "Decide where each piece lives and when it reaches the writer". I'll add it to that ticket's notes once this round settles.