I'll read the research document myself first; so far I only have the background search's summary of it.

---

Yes, the research changes the questions. One recommendation was wrong, one question was missing the distinction the research draws most sharply, and two questions are new. Here is what changed, then the revised round.

## What the research changed

1. **"What done means" doesn't belong among the binding rules.** In round one I put it there. The research says that's where the most-measured harm hides. Radiologists, and Claude in Anthropic's own evals, find a problem and then leave it out of the report when the brief sets a bar for what's worth reporting. People also treat a stated measure as if it were the goal, without noticing they've done it (section 4). The `spec:` citation gate is exactly this case.
2. **Q2 lacked the line between what the writer offers and what the reader may look for.** The research separates them sharply (sections 3 and 4). A writer holding back its own conclusions protects the reader's independence. A writer limiting what the reader may look at is the harm. Without that line, "share what you know about the route" turns into leading the witness.
3. **Current Claude models read literally.** Anthropic says Opus 4.8 does not infer requests the prompt didn't make (section 11). So a literal reader treats every sentence about the route as binding unless it is told which ones bind. That's a new question.
4. **A narrowly stated goal hides things by itself, before any rule is added** (section 4, the gorilla studies and a 2026 preprint). That's the other new question.

**How far to trust this.** Most of the evidence is about people. The model studies measure reporting bars, output formats, length budgets and framing. None measures a limit on strategy itself, such as which files a reviewer may read, and nothing covers Opus 5.5. So each recommendation below is a bet that the ticket "Decide how we'll know the writing works" should test.

**My own lists.** Every question below offers options, and the research says offered options pull the answer toward themselves: one problem went from 2% to 60% of answers once it appeared in a list (section 2). Answer outside my options wherever they don't fit. The cases in each question are illustrations, not the whole space.

Terms, unchanged from round one:
- **The goal** is what's wanted.
- **The route** is how the reader gets there.
- **A binding rule** is one the reader may not overrule by itself.

---

❓ **Q1 - What makes a rule binding?** Sociology supplies the starting point. Garfinkel found that no set of instructions can be made complete. Suchman found that plans are resources for action, not specifications of it (section 4). Taken together, every rule in the writing is something the reader uses, except for a small set that binds. The test I'd now propose: a rule binds only if it is one of these two things, and only if its owner made it binding.

- **The goal itself, in the words of whoever set it.** That fits your Q9 answer: quote the source whole rather than summarize it.
- **What isn't the reader's to decide**, because someone else holds that decision. You merge PRs. Another lane owns a file. The ticket draws the scope.

**The change from round one: a done criterion is not binding.** Passing tests, a required citation, or a count is evidence offered for the goal. The reader meets it where it serves the goal and reports where the two come apart. Three cases:
- **The `spec:` gate.** The Standards brief demanded a citation to ticket criteria it never showed. Fable then filed real bugs as minor because it had nothing to cite. Sol filed nothing at all on a PR that had four real bugs.
- **P109's "at most N lanes".** You ruled that it was "a prediction, not a constraint".
- **Surrogation.** In the experiments, people paid on one measure of a strategy acted as if the measure were the strategy, and didn't notice.

**A side effect of tying binding to who owns a decision.** "Never push to main" becomes "Manuel merges; you open a PR", which says what to do instead. The research finds that a bare prohibition tends to land a model on some other fixed default (section 5).

The options:
- (a) the test above;
- (b) round one's version, with "what done means" kept on the binding list;
- (c) no general test, so each rule is argued case by case.

➡️ (a).

---

❓ **Q2 - What does the writer pass on about the route, and how?** The research supports three things:
- Saying a rule's reason lets the reader generalize from it (Anthropic's guidance).
- The same limit hurts when worded as control and doesn't when worded as information (Koestner and others, in people).
- Step-by-step guidance helps novices and hurts experts (a 60-study meta-analysis), and specific goals help on simple tasks but hurt on complex, novel ones.

It also shows the writer's beliefs leak into the answer. Telling a model the code was bug-free cut its vulnerability detection from 97% to 4% for a small model, and from 96% to 89% for Opus 4.5.

The test I'd propose: the writer passes on **facts about the world** the reader couldn't easily find, each with its reason and worded as information. It holds back **its own expectations about the answer**. Steps in a set order belong only when the order is a fact, for example when step B needs step A's output, not when it's the writer's view of the best strategy. Three cases from the factory:
- **Keep:** [ticket.md:10](template/.agents/skills/poteto-mode/playbooks/ticket.md:10), "two plain commands, because a worktree agent's guard refuses `git` inside `$(...)`". It's a fact, its reason is attached, and the reader can check it.
- **Ambiguous:** "never an arena", with no reason given. The reader can't tell whether it's a fact (something broke) or a preference. With the reason, it becomes knowledge the reader can apply to cases the writer didn't foresee.
- **Never:** "Zero items is the expected result". It's the writer's expectation, and it voided the reviewer measurement.

The options:
- (a) leave the route out entirely;
- (b) the test above;
- (c) route advice as defaults the reader may override.

➡️ (b). The difference from round one is the test for what goes in: it's now "fact about the world versus the writer's expectation", not only "could the reader find this itself".

---

❓ **Q3 - How does a literal reader tell a binding rule from everything else?** *(new)* Three findings bear on this:
- **Literal reading.** If Opus 4.8 doesn't infer requests the prompt didn't make, a sentence meant as knowledge can be read as an order.
- **Too many instructions.** With 500 instructions at once, the best of 20 models followed 68%, and it favored the earlier ones.
- **Emphasis and repetition.** Emphatic wording ("CRITICAL", "MUST") gets over-applied. A section repeated in every message gets read past as boilerplate.

The options:
- (a) Binding rules sit in one named place, kept few, each with its reason, in plain words. The text says that everything outside that place is the writer's knowledge, offered for the reader to use or not.
- (b) Each binding rule is marked where it appears.
- (c) No marking; wording alone carries it, informational for knowledge and firm for binding rules.

➡️ (a). It fits the brief shape you gave in Q9 (who you are, the task, the full context). The risk is that a fixed section gets read past, and the measurement ticket should check whether it does. How the section is laid out is the job of the ticket "Prototype brief templates for the recurring lane jobs", not this one.

---

❓ **Q4 - What does the reader do when a binding rule fights the goal?** *(was Q3)* Today the factory gives five answers that conflict:
- sign-off first ([AGENTS.md:26](AGENTS.md:26), [template/AGENTS.md:20](template/AGENTS.md:20));
- follow the file, then explain ([template/AGENTS.md:16](template/AGENTS.md:16));
- skip a step visibly with a reason;
- decide and record a Provisional decision;
- end each writer flag with `accepted: <reason>`.

No text says how a subagent gets a sign-off. Q1 to Q3 make the question smaller. Departing from route knowledge needs nobody's permission, only a line in the report. Only binding rules need a path for conflict, and because a binding rule covers a decision that isn't the reader's, the path follows from that: stop that part, report the conflict to the rule's owner, and carry on with the rest. Never narrow the goal to fit the rule.

The research adds two cautions:
- **Readers rarely notice they've misread, and rarely ask.** People asked on 4% of the occasions help was available, and current models almost never ask on underspecified coding tasks (section 8). Saying that checking definitions was "essential" rather than "available" raised checking from 23% to 81%. So reporting the conflict should be written as part of the job, not as permission to report.
- **Pushing too hard backfires.** Assigned dissent was weaker than genuine dissent, and more detailed find-and-fix prompts raised false positives in model reviewers. So the reader reports conflicts it meets; it isn't asked to hunt for them.

The options:
- (a) the path above;
- (b) break the rule and report afterwards;
- (c) keep the five mechanisms as they are.

➡️ (a), with you asked directly when you're present. Whatever you choose replaces the first two of those five in the factory's own text. pstack's `skip:` rule is upstream, so changing it would need a patch, and that belongs to the ticket "Decide the scope and order of reworking existing files".

---

❓ **Q5 - May an orchestrator invent binding rules of its own?** *(was Q4)* The audits answer this one. Every measured harm in a reviewer brief was the orchestrator's own addition:
- Upstream's "zero items is valid" became "expected".
- A cost fix from #33 grew into "read nothing, run nothing" without any ticket asking for it.

➡️ No. It passes your rules on, binds only what it owns, such as which lane holds which file right now, and puts everything else through Q2's test.

---

❓ **Q6 - Can cost or time limit the route?** *(was Q5)* Three findings say a limit on the output is a limit on the thinking:
- Tight length budgets cut reasoning models' accuracy, Phi-4-reasoning from 72% to 54%.
- A bar on what's worth reporting lowers how many findings come back while the ability to find them stays the same.
- Anthropic's advice is to ask for every finding with its confidence and severity, then filter in a separate step.

The options:
- (a) A budget is stated as a fact about the situation, and the reader plans its route within it. When the output must be short or filtered, that's a separate step done after the finding, never a cap on the finder.
- (b) Budgets cap the route directly.
- (c) Budgets stay out of the writing.

➡️ (a). A budget you set binds under Q1. The map "Optimize token use and wall-clock time without losing reliability" can revisit this once it has numbers.

---

❓ **Q7 - What about the narrowness of the goal itself?** *(new)*
- **People.** Observers counting basketball passes missed a person in a gorilla suit 46% of the time, and 20 of 24 radiologists missed a gorilla drawn into a lung scan.
- **Models.** One 2026 preprint found that a narrow task instruction made models leave out critical findings they reported without it, and a separate critic with an open brief recovered every omitted finding. It's a single author, not peer-reviewed, and I've seen only the abstract.

So a goal with no rules attached still decides what gets seen. The options:
- (a) The writing states the goal as openly as it really is, and makes clear that things outside the focus that matter to the goal are welcome.
- (b) Pair every narrowly focused judging lane with an open-ended one.
- (c) Leave it to other tickets.

➡️ (a) as part of this ticket's decision. The pairing in (b) costs a lane every time and rests on one preprint, so I'd put it under "Not yet specified" for the measurement ticket to test first, not decide it now.