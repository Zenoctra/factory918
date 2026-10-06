I'll read the research document itself first; so far I only have the background search's summary of it.

---

Yes, the questions change. Having read the research, I see three shifts:

1. **There is no clean line between the task and the route.** Round one assumed a brief splits into a binding part (the goal, what done means) and a route part that should be left open. The research shows the goal and the definition of done steer the route too. What a reader is told to look for decides what it notices. A bar in the definition of done decides what it reports. So a rule hidden in the goal or in the report has to be covered as well as one written explicitly about the route.
2. **Permission to depart from a rule mostly goes unused.** Readers rarely notice when a rule is hurting them, and they rarely ask. Current Claude reads instructions literally. An offer like "say so loudly" therefore does little unless it is built into what the reader has to return.
3. **How much route guidance helps depends on the job.** It depends on whether the task is simple or complex, and on whether the reader's value is its independence. A reviewer and a writer need different treatment.

The research also supports your point beyond the review case. Garfinkel concluded that no set of instructions can ever be made complete. Suchman, studying people using a photocopier's built-in help system, concluded that plans are resources for action, not specifications of it. Both argued this from observation, without measurements. Together they explain why "leave it open for what you can't predict" applies to instructions in general, not just to searching.

One caution: the model evidence is thinner than the human evidence. No study tests a limit on a model's strategy directly. The measured cases are reporting bars, output formats, length budgets and framing, and the vendor's notes on current Claude publish no numbers. Q6 asks what to do about that.

I'm using the same terms as round one:

- **The goal** is what's wanted and what done means.
- **The route** is how the reader gets there.
- **A binding rule** is one the reader may not overrule on its own.
- **A filter** is new: anything that decides which of the reader's results count, such as a severity bar, a scope or a required citation.

This round replaces round one. Old Q1 and Q4 are merged, and Q2 and Q6 are new.

---

❓ **Q1 - What may bind, and who may make it bind?** Round one asked these separately, but they turn out to be one question. The research adds two problems for any split between task and route:

- **The goal itself steers.** In the gorilla study, what observers were told to count decided whether they noticed a gorilla walking through. A 2026 preprint (one author, not peer reviewed) found the same in models. A narrow task instruction stopped models reporting critical findings that the same models reported without it. So even the binding part of a brief limits the route somewhat.
- **Writers turn intent into method without noticing.** Shattuck studied 32 Army episodes where commanders faced something unexpected. The written intent statements were full of method, and only 11 of the 32 actions matched the intent (one small study). The factory has its own examples. Lanes added limits to review briefs to save cost that no ticket asked for (#33, #93, #107). Another lane turned your question into a rule on a ticket ([ledger.md:19](docs/agents/ledger.md:19)).

The options:

- (a) A rule may bind only if it states the goal, what done means, or a decision that belongs to someone other than the reader. Only the person or agent who owns that decision may make the rule binding. An orchestrator binds only what it owns itself, such as which files other lanes are working in right now.
- (b) The same as (a), but an orchestrator may also bind route rules it judges necessary, if it gives the reason.
- (c) No general test; the standard decides each rule case by case.

➡️ (a). Because the goal steers anyway, write it as open as it really is. Write binding rules plainly, with their reason, and as what to do rather than what not to do. The vendor reports that current Claude over-applies instructions written emphatically, and that it generalizes from the reason behind an instruction. A prohibition keeps the forbidden thing in the reader's mind without saying what to do instead. Under (a), the delegation rule and the mandatory trail review bind because you set them and had evidence for them. "Read only the diff" doesn't bind.

---

❓ **Q2 - Where does a filter go?** The strongest evidence in the research is about reporting bars:

- Radiologists shown an extra finding didn't search any less. They raised their bar for reporting what they found (replicated; how large the effect is remains disputed).
- Anthropic reports the same of Claude Opus 4.8. Told "only report high-severity issues" or "don't nitpick", the model still finds the bugs, then leaves the ones below the bar out of its report. Measured recall falls even though the model got better at finding bugs.
- The run-2 audits found this in the factory's own text. The Standards review brief requires each finding to cite the ticket, but never shows the reviewer the ticket. One reviewer filed nothing on a PR that had four real bugs.

A filter is part of what done means, so under Q1 it can bind. The question is which brief it goes in:

- (a) In the finder's brief, as now.
- (b) The finder reports everything it saw, each with its own severity and confidence, and the filter runs as a separate step, either a script or a different reader.
- (c) The finder reports everything and nothing filters it; whoever uses the results reads them all.

The research flags one cost: more detailed find-and-fix prompts raised false positives in model reviewers. In the factory, the definition of "hard" (P18) exists because a reviewer counted smells as hard bugs. That definition makes the reviewer classify each finding without stopping it from reporting any, so it survives under (b).

➡️ (b). It is also what the vendor recommends. The finder may classify; it never decides what is worth mentioning.

---

❓ **Q3 - What may the writer say about the route?** This is old Q2. The research splits it by kind of job:

- **Doing jobs**, such as writing, fixing or researching. The writer often knows things about the route that the reader can't easily find out, like the worktree guard quirk behind [ticket.md:10](template/.agents/skills/poteto-mode/playbooks/ticket.md:10).
  - The same limit lowered children's creativity when stated as an order, but not when stated as information.
  - Step-by-step guidance helps novices (d = 0.51) and hurts experts (d = −0.43), across a meta-analysis of 60 studies.
  - Specific goals help on simple tasks and hurt on complex, novel ones. Our readers are capable, and most of our tasks are complex.
- **Judging jobs**, such as review, critique or judging. What the writer believes about the answer leaks into the result. In one 2026 study, telling a model the code was bug-free cut vulnerability detection from 97% to 4% in a small model, and from 96% to 89% in Claude Opus 4.5. The research separates two kinds of limit here: restraint on what the writer volunteers, and limits on what the reader may look for. The evidence from forensic interviewing supports the first and offers nothing in favour of the second.
- **Mechanical jobs**, where one procedure is correct. This is the one place where specific method helps. In this factory, a job with a single correct procedure should be a script, not a brief.

➡️ For doing jobs, include route knowledge only when the reader couldn't easily find it, and state it as something the writer knows, with the reason, never as an order. For judging jobs, give the reader what it is judging and how to run it, and none of the writer's guesses about where the answer lies. For mechanical jobs, write a script. If the job can't be scripted yet, it isn't mechanical.

---

❓ **Q4 - What does the reader do when a rule fights the goal?** The research changes this question the most:

- Survey respondents who were told they could ask for help asked on 4% of the occasions help was given.
- Told that checking a definition was essential, respondents checked on 81% of questions. Told definitions were available, they checked on 23%.
- On underspecified coding tasks, current models almost never ask.
- The vendor says current Claude reads instructions literally and sticks closely to any bar it is given.
- The worst case is the one the reader never notices. In the narrow-instruction study, models didn't refuse; they quietly reported less.

[template/AGENTS.md:20](template/AGENTS.md:20) is the "available" kind of line: an offer that readers rarely take up. On top of that, the background search found five departure mechanisms in the factory's text that disagree with each other: the sign-off, "follow the file and explain", `skip: <reason>`, the Provisional decision, and `accepted: <reason>`.

The options:

- (a) One mechanism, built into what every reader returns. The report always has a place for three things: where a rule or the brief's wording got in the way of the goal, what the reader did about it, and anything it noticed outside what it was asked. When a binding rule is in the way, the reader stops that part, reports to the rule's owner, and carries on with the rest. Any other rule, it departs from and says so in that place.
- (b) Keep the permission line as written, and extend it to subagents.
- (c) (a) for subagents. The root session talking with you also keeps the sign-off.

The research names two risks for (a). A section repeated in every report gets read past as boilerplate. A section that seems to expect content invites invented dissent; dissent people were assigned to argue was weaker than dissent they actually held. So the section carries no expected count, in either direction.

➡️ (c): the report place everywhere, plus the sign-off where you are there to give it. In no case does the reader narrow the goal to fit the rule. Replacing the five mechanisms is rework, and belongs to "Decide the scope and order of reworking existing files".

---

❓ **Q5 - Budgets, and the shape of the output.** The approved template design put "how to report" in the fixed part of every brief. The research shows the shape of a report has costs:

- In one study, requiring JSON output hurt reasoning. A rebuttal found no difference when the prompts were matched. Answering in prose first and converting afterwards removed most of the loss.
- Tight output budgets cut the accuracy of reasoning models sharply across 30 models. This comes from someone else's account of the study, so treat the numbers as unconfirmed.

A spending budget, in tokens or time, is a different thing: it is a fact about the situation the reader is in.

- (a) The output shape belongs to whoever consumes it, and it binds. The reader works however it likes and converts to the shape at the end. Output length is never capped. A spending budget is stated as a fact the reader plans within.
- (b) Budgets you set bind directly as caps.
- (c) Budgets stay out of the writing.

➡️ (a). A cap you set yourself still binds, under Q1. The map "Optimize token use and wall-clock time without losing reliability" can revisit this once it has measurements.

---

❓ **Q6 - Decide now, or after measuring?** The human evidence, the vendor's notes and the run-2 audits all point the same way. In the reviewer evaluation, 4 of the 13 labelled bugs sat in files the brief told the reviewer not to open. But no study tests a limit on a model's strategy directly, and nothing measures current Claude with published numbers. In the charting round, you said any narrowing should wait for tests.

- (a) Decide the principle now, and hand two experiments to "Decide how we'll know the writing works":
  1. Give lanes the same open task with and without an example list, and count what each finds outside the list.
  2. Rerun the run-2 reviewer evaluation with a route-limited brief and an open one, on the same labelled bugs.
- (b) Mark this whole decision provisional until those experiments have run.

➡️ (a). If the principle turns out wrong, the report place from Q4 will show it, because conflicts and departures get written down instead of disappearing.

---

The housekeeping from round one still stands: once this settles, I'll rewrite my memory note that still uses the old test.