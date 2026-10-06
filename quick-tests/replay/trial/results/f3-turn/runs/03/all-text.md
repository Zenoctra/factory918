I'll read the research report in full before revising anything.

---

Yes, the research changes the round. Round one assumed the main danger was a reader forbidden from overruling a bad rule. The evidence points the other way: current Claude models over-obey, rarely notice when a rule fights the goal, and rarely say so. So the questions shift. Fewer are about sorting rules into binding and not binding. More are about how few rules to write, how to word each one so a literal reader can see where it stops, and how to make a narrowed task visible.

I read the whole report (`docs/research/wording-and-reader-context.md` on the branch `research/wording-and-reader-context`). Here is what changed.

**What the research changed**

- **Readers over-obey.**
  - Anthropic's guide for Opus 4.8 says the model reads instructions literally, sticks to a stated reporting bar more closely than earlier models did, and applies emphatic wording more broadly than intended.
  - No study found models resisting controlling wording the way people do.
  - On underspecified coding tasks, models almost never asked a question.
  - When a hint changed its answer, Claude 3.7 Sonnet mentioned the hint 25% of the time.
  - So an open door to overrule a rule won't get used unless the writing makes speaking up part of the job.
- **Rules about how a task is finished do the best-measured harm.** Radiologists who found one abnormality searched just as hard for a second, but were more reluctant to report it (Berbaum 2015). Anthropic reports the same of Opus: it finds the bugs, then drops the ones below the bar the prompt stated. In round one I put "what done means" on the safe side. That is exactly where the `spec:` citation gate sits, the gate that made a reviewer file nothing on a PR with four real bugs.
- **Withholding what the writer concludes is different from limiting what the reader may look at.** Forensic science protects an analyst's independence by keeping other people's conclusions away from them. Yet across 16 studies of medical tests, giving the reader relevant clinical facts improved accuracy every time. So the useful line runs between facts and someone's conclusion, not between more context and less. That splits round one's Q2 in two.
- **Prescribing method sometimes helps.**
  - Step-by-step guidance helps novices (d = 0.51) and hurts experts (d = −0.43). The d values are effect sizes: 0.5 is medium, and the minus sign means it hurt.
  - Specific goals help on simple tasks and hurt on complex, new ones.
  - The standard covers people too, and a new person running setup should get steps.
  - A subagent is capable but new to the project, and readers new to a subject gain from explicit links between ideas.
  - Round one never asked whether the answer depends on the reader and the task.
- **No instruction is complete, and stating the intent isn't enough.**
  - Garfinkel and Suchman argue that no rule written in advance can contain the situation it will meet.
  - In the one field test, battalion commanders judged their company commanders' actions in unexpected situations to match their intent in 11 of 32 cases, once coincidental matches are removed (Shattuck 2000).
  - The best-tested fix is read-back. I-PASS, a medical shift-handoff format in which the receiver restates the plan, cut medical errors by 23% across nine hospitals. That is a new option for the conflict question.
- **My own format leads.**
  - A list with an "other" slot still moved four listed problems from 2% of answers to 60% (Schuman & Scott).
  - My ➡️ line is the writer's conclusion, volunteered.
  - You've answered beyond my options every round. Even so, below I ask questions openly where the space can't be listed, and any options I give are illustrations.
  - The recommendations stay because the grilling format asks for them. Treat them as one view.

**What the evidence doesn't cover.** No model study tests a limit on strategy as such, for example which files a model may read or which method it must use. The decisions below rest on human evidence, vendor notes and our own ledger. The one experiment the report says nobody has run is the same open task with and without an example list. We can run it, and it belongs to the ticket "Decide how we'll know the writing works".

Round one's Q4 ("who may write a binding rule") is folded into Q1 below, and two questions are new.

---

❓ **Q1 - Where does a binding rule get its authority?** Round one tested a rule by what it was about: the goal, what done means, or a limit of authority. Q2 below shows that "what done means" hid the worst harm, so I'd drop the content test.

The proposal: a rule binds only when its owner made it binding. Owners are:
- you: AGENTS.md, DECISIONS, your own words;
- the ticket;
- a writer, but only for what it actually owns right now, such as the files another subagent is editing or the branch it's working on.

Everything else in a brief is information. The reader may weigh it and depart from it, as long as it says so.

The evidence for drawing the line at ownership:
- The two rules about the route with the best record are yours, and both came with evidence: the trail review (3 catches out of 3) and the delegation rule (knowingly broken until a hook held it).
- The case against letting a writer turn its own guesses into binding rules: interrogators led to expect guilt asked guilt-presuming questions and got answers that confirmed it (Kassin 2003). Shattuck's real-world intent statement was full of method and limited the people it was meant to free.

The open edge is the ticket. An agent writes it and you approve it. The ledger records a subagent that turned your question into a rule on a ticket.

➡️ Ownership, not content. A ticket binds on what's wanted and on its scope where you approved them. A line an agent added stays information until you approve it.

---

❓ **Q2 - May anything set a bar on what the reader reports?** Every bar of this kind changes how the task is finished. Some examples: "only hard bugs", "cite a spec line or don't file", "at most N", "zero is the expected result". The evidence says the reader does the work and then holds back what fell below the bar. Telling a reader what to expect also moves the bar. When an instruction implied the culprit was in the lineup, 78% picked someone; when it said "may not be present", 33% did.

The alternative: the reader reports everything it found, with its own severity and confidence for each item. A separate step, owned by whoever owns the bar (a script, a judge subagent, or you), filters afterwards. That costs noise: prompts asking a model to find and fix problems raise false positives (Jin & Chen 2026), so the filtering step is real work. The factory's definition of a "hard" bug and the `spec:` gate in the review brief script both put the bar on the reader today. Changing them belongs to the rework ticket. This question decides the rule they would change to.

➡️ No bar on the reader. Bars belong in a separate filtering step, and the reader is told nothing about how many findings to expect.

---

❓ **Q3 - What may the writer say about the route?** A writer can say two different kinds of thing:
- **Facts about the ground:** the guard refuses `git` inside `$(...)`, this folder is generated, this suite takes three minutes, this approach was tried and failed.
- **Beliefs about the answer or the best path:** "the bug is probably in X", "start from file Y", "use approach Z".

Relevant facts improve accuracy. Beliefs pull the reader:
- Fingerprint experts given context reversed their own earlier decisions.
- Telling a reviewer the code was bug-free cut detection from 97% to 4% for a small model, and from 96% to 89% for Opus 4.5.

A suggested path pulls even when it is labelled as only a suggestion:
- Chess masters said they were looking for a shorter mate, but their eyes stayed on the familiar one.
- Designers copied an example's flaws even after being told about them.

What reduced that pull was saying what the example is for, or what's wrong with it.

One trap to avoid: fixing a leading brief by telling the reader to resist it. Assigned devil's advocates were weaker than real dissenters (Nemeth 2001), which is the "unnecessarily adversarial" result you predicted. Example lists in a brief belong to the same family. The writing-standard ticket owns how lists are written, but they bound the route too.

➡️ Give facts about the ground freely, each with its reason. Keep the writer's beliefs about the answer out of any brief for a subagent that judges or searches. For a subagent that builds, suggest a path only when the writer knows something the reader couldn't find, and say what the path is for, so the reader can tell when it doesn't fit.

---

❓ **Q4 - When is it right to prescribe the method?** *(new)* Some cases where steps look right:
- a person new to the factory following setup;
- an exact command, where the wrong one costs something the reader can't see;
- a procedure whose order is the point.

Where they look wrong: open-ended work given to a capable reader.

The factory's philosophy sits on the other side of this. `PHILOSOPHY.md` says pstack's playbooks make the agent "follow a script rather than improvising". One way to reconcile the two: the route rules in our ledger that did good add a step without stopping the reader from doing more (the trail review, the blast-radius check). The harmful ones cap the reader: read only this, report only that, stop after N. Call them floors and ceilings.

Floors have their own risk: the measure replaces the goal. Managers paid on one measure of a strategy acted as if the measure were the strategy, and merely knowing they were measured, with no pay attached, was enough (surrogation). The "at most N" list in the review-lanes ticket was this failure.

One caution. Floors and ceilings is a lens I'm offering, not the whole space. Rules about order, such as tests first or one owner at a time, fit neither. Generalizing from a few examples is the mistake you corrected, so test the lens hard.

➡️ Prescribe method for a reader new to the domain, or where the reason for a step is invisible to the reader. Otherwise give the goal, the reason and the facts. Playbook steps count as a minimum, and the goal is stated above them, so that finishing the steps isn't mistaken for finishing the job.

---

❓ **Q5 - What happens when a rule fights the goal?** The factory has five mechanisms today, and they conflict:
- Get a sign-off before breaking the rule.
- Follow the file, then say why your instinct differed.
- `skip: <reason>`.
- Make the call and record it as a Provisional decision.
- `accepted: <reason>` on writer flags.

The evidence says "stop and report if you notice" will rarely fire:
- Survey respondents told they could ask for help did so on 4% of the occasions help was given.
- Calling definitions "essential" instead of "available" raised how often people checked them from 23% to 81%.
- Models rarely ask.
- A task that got narrowed doesn't show in the model's reasoning.

Two things are possible now that round one didn't consider:
- A subagent running in the background can message its writer mid-task. In one study, letting the less-informed agent ask questions beat pushing instructions to it (Baek 2025).
- Read-back, as in I-PASS: the receiver restates the plan.

A fixed "list your deviations" line repeated in every brief tends to get read past as boilerplate. A restatement in the reader's own words doesn't, because the reader has to produce it.

➡️ One mechanism replaces all five:
- When a rule isn't binding and fights the goal, the reader departs from it and says why in the report.
- When a binding rule fights the goal, the reader asks its writer, who relays the question to the rule's owner, and goes on with the rest meanwhile. It never narrows the goal to fit the rule.
- Every report opens with the reader's own statement of the goal and says where a rule or the brief held the work back. That way a narrowed task shows up even when the reasoning hides it.

---

❓ **Q6 - How are binding rules worded?** *(new)* The factory is full of "never" and caps. The evidence on wording:
- Anthropic's guidance: current Claude models apply emphatic wording more broadly than intended, and they generalize from the reason when one is given.
- In people, a limit worded as control lowered creativity, and the same limit worded as information did not.
- A prohibition names the forbidden thing without saying what to do instead, so the model lands on some other default.
- A literal reader carries a rule as far as its words allow. "Read no brief and no diff while the review state exists" has no reason attached, so a reader can't tell where it ends.

➡️ Plain wording, the reason, who owns the rule, and what to do instead. No capitals and no "CRITICAL". For example, "Merging is Manuel's: open the PR and stop there" rather than "Never merge."

---

❓ **Q7 - Can cost or time justify a limit on the route?** *(was Q5)* Two new facts:
- Under tight output budgets, reasoning models fell sharply: Phi-4-reasoning went from 72.2% to 53.5% at 1,024 tokens.
- The run-2 constraints audit found that subagents added the review limits for cost, and no ticket had asked for them.

Caps on reporting are covered by Q2.

➡️ Unchanged. A budget is stated as a fact about the situation, and the reader plans its route within it. It binds only if you set it. The map "Optimize token use and wall-clock time without losing reliability" can revisit this once it has measurements.

---

One housekeeping item, no decision needed: my memory still states the old test. I'll rewrite it once this round settles.