# Original turn 02ad394f-d125-4fe2-8c5e-719ec54bde0c (2026-09-30T20:36:36.749Z)

## Prompt

Im about to go through and answer your questions. But first, we finished our research that is going to guide our decision making and design processes here and you made these questions before that research existed. Do you think you can maybe go back now with the research available and decide if the questions change in nature or flavor or if you have more advanced or nuanced opinions or if you have more deepl explanations or state cases or whatever else. As in, do your questions and reccomendations change in presentation if you have the research in mind when approching the primary questions of this ticket? I think you could be a more educated design guide in this process now that it's done.

## Tool calls

- Bash: {"command": "cd \"/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918\" && git fetch -q origin 2>/dev/null; git branch -a | grep wording; git show research/wording-and-reader-context:docs/research/wording-and-reader-context.md | wc -lc; gh issue view 154 --json state,comments --jq '.state, (.comments[]|.body)' | head -60"}
- Bash: {"command": "cd \"/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918\" && git show research/wording-and-reader-context:docs/research/wording-and-reader-context.md > \"/private/tmp/claude-501/-Users-manuel-Desktop-Work-Under-The-Sun-Collective-Core-918-factory918/c0c3530f-56c5-4eec-ae2f-949cebfc2e96/scratchpad/research.md\""}
- Read: {"file_path": "/private/tmp/claude-501/-Users-manuel-Desktop-Work-Under-The-Sun-Collective-Core-918-factory918/c0c3530f-56c5-4eec-ae2f-949cebfc2e96/scratchpad/research.md"}
- Read: {"file_path": "/private/tmp/claude-501/-Users-manuel-Desktop-Work-Under-The-Sun-Collective-Core-918-factory918/c0c3530f-56c5-4eec-ae2f-949cebfc2e96/scratchpad/research.md", "offset": 273, "limit": 160}

## Text

Yes, it changes things. My earlier line between rules the reader may overrule and rules it may not survives, but the research changes four things about how I'd put the questions to you:

1. **It gives your point a reason rooted in what instructions are, not only in what went wrong here.**
   - Garfinkel found that no set of instructions can be written completely, however hard you try.
   - Suchman found that people use a plan as a resource and act on the situation in front of them, and that the plan and the actions drift apart when a system assumes otherwise.
   - Your line about leaving it open "for something you CANT predict" is that finding.
2. **Rules about how a task is finished need their own question.** Bars on what to report, caps on how many findings, and gates on what counts behave differently from rules about the route.
   - A radiologist told what the bar is keeps searching and stops reporting what falls under it.
   - Anthropic's Opus 4.8 guide reports the same for its own models.
   - In one 2026 preprint, a narrow task instruction hid findings the model reported without it, and a second reviewer with an open-ended brief recovered them.
   - That is a structural fix, not a wording fix.
3. **Wording matters even for the rules that stay.**
   - The same limit harms less when stated as information with a reason than when stated as control.
   - Current Claude models read literally and over-apply emphatic rules.
   - A prohibition keeps the forbidden idea active and doesn't say what to do instead.
4. **The research also limits what you can claim.**
   - Detailed method helps on simple tasks and for beginners.
   - Holding back the writer's own conclusion protects the reader's independence, and that is a different act from limiting what the reader may look for.
   - No study has tested a limit on method directly on a language model. The core of this ticket rests on human evidence, the vendor's notes, and one preprint.

The full note is [wording-and-reader-context.md](https://github.com/Zenoctra/factory918/blob/research/wording-and-reader-context/docs/research/wording-and-reader-context.md). The section numbers below refer to it.

Here is round one again. I merged the old Q1 and Q4, and added a question on finishing rules. Terms, as before:

- **The goal** is what's wanted and what done means.
- **The route** is how the reader gets there.
- **A binding rule** is one the reader may not overrule by itself.

---

❓ **Q1 - What binds, and who can make it bind?** My earlier test: a rule binds only when it states the task itself (what's wanted, what done means, what isn't the reader's to decide) and never the route. Only the person who owns that authority can make a rule binding.

The research adds three things:

- **Military doctrine supports this, and the one field test warns against trusting it.** "Mission command" says to state the end and the reason and leave the method open. But in Shattuck's study, intent reached subordinates in only 11 of 32 cases, and a real intent statement turned out to be full of method (§4). So "what done means" can smuggle a route in. Q3 below is where that happens most.
- **Ownership explains the rules on the route that have worked.** The mandatory trail review caught the owner's errors three times out of three. The delegation rule held once a hook enforced it. You set both, with evidence. They bind because you made them bind, not because of what they are about.
- **Leaving out the writer's own conclusion is not a rule on the reader.** Forensic science withholds the investigator's conclusion from the examiner and improves accuracy. It still gives the task-relevant context: across 16 studies, clinical information helped readers of medical tests and never hurt them (§3). "Don't tell the reviewer what the owner thinks is fine" is the writer's restraint, so it belongs to the standard ticket, "Decide what the writing standard is and what carries it". "Don't let the reviewer open files outside the diff" limits the route, so it belongs here.

The options:
- (a) Binding depends on what the rule is about.
- (b) Binding depends on who owns it.
- (c) Binding needs both.
- (d) There is no test, and every rule is argued case by case.

➡️ (c). The test applies to each rule. It is not a list of kinds of rule. The standard carries your point in full, with the Garfinkel and Suchman reason under it, rather than as one sentence and a taxonomy. You asked for that in your answer to the second question in the first charting round.

---

❓ **Q2 - How is what the writer knows about the route written down?** Suchman gives the frame: a plan is a resource for acting, not a specification of it. The research sharpens this in three ways:

- **Give context generously, and method sparingly.** A subagent starting cold is a reader with little knowledge of the project, however capable it is. For such readers, explicit connections and stated facts help (§9). A capable reader told step by step how to work does worse: in 60 studies, guidance helped beginners (d = 0.51) and hurt experts (d = −0.43) (§4). So facts about the project, the tools and the traps go in freely. How to go about the work goes in only when it carries a lesson the reader couldn't easily find.
- **Write it as information, with the reason.** The same limit worded as control lowered creativity, and worded as information it did not. Anthropic's guidance is to give the reason, because the model generalizes from it. Current Claude reads literally, so even an illustration binds harder than the writer meant (§4, §11).
- **Every added rule costs the reader something.** With 500 instructions, the best model followed 68%. Adding every requirement did not reliably help (§4). What gets added to be safe takes attention from what matters.

The counterweight is a task that really is mechanical, like rebasing or running a fixed set of commands. There the exact steps help. They are still a resource, and the reader follows them because they are right, not because they bind.

The options:
- (a) Leave route knowledge out entirely.
- (b) Write it as a resource with its reason.
- (c) Write it as a default the reader may override.

➡️ (b), with leaving it out as the starting point and context kept separate from method. I'd drop (c). "Default" still reads as control, and the research says the wording is what does the harm.

---

❓ **Q3 - What happens to rules that bound how a task is finished?** Examples are "only report high-severity issues", "under 400 words", "cite a `spec:` line or it isn't a bug", and "stop after N findings". The evidence here is the strongest in the note, and it points somewhere new:

- **A bar changes what gets reported, not what gets found.** Radiologists kept searching but raised their bar for saying so. Anthropic reports the same of Opus 4.8: its ability to find bugs went up while measured recall went down (§4). The `spec:` gate is this case. A reviewer that knew the bugs were real filed nothing, because it had no ticket line to cite.
- **A narrow task hides what lies beyond it.** In the gorilla study, what the observers were counting decided what they saw. In Shin's 2026 preprint, a focused instruction suppressed critical findings the same models reported without it. A separate reviewer with an open-ended brief recovered all of them (§4). This holds even when the narrow goal is legitimate.
- **A measure takes the goal's place.** In experiments, people paid on one measure acted as if the measure were the strategy, without noticing (§4). Your "principle over proxy" ruling on the "at most" list is the same finding.

The options:
- (a) The reader reports everything it found, with its own confidence and severity. Any bar the next step needs (what blocks a merge, what a person should see first) is applied afterward, in a separate step, by something other than the reader. Every brief also leaves the reader room to report what it noticed outside the task.
- (b) Bars stay in the brief, reworded as ways to rank findings rather than reasons to withhold them.
- (c) Decide case by case.

➡️ (a). The bar moves to the filter step, where it does no harm to what gets found. The outside-the-task room widens the task rather than bounding it, so it doesn't break the principle. Shin's recovering critic is the evidence that it pays.

---

❓ **Q4 - What happens when the reader departs from the writer's route, or when a binding rule fights the goal?** The factory currently has five mechanisms, and they conflict. The research adds three facts:

- **Readers rarely raise a problem on their own.** People told they could ask did so on 4% of the occasions. Told that checking was essential rather than available, 81% checked instead of 23%. Current models almost never ask about an underspecified task (§8). A permission like "you may raise this" mostly goes unused. A field the report always carries does not.
- **Models don't reliably say what influenced them.** A hint that moved the answer was mentioned 25–39% of the time (§3). A departure line catches the choices the reader knows it made, not the pulls it didn't notice. It is useful, but it doesn't measure how much the brief led.
- **Assigned dissent is weak and can make things worse.** Real minority dissent produced better solutions. Role-played dissent mostly strengthened the original view (§3). Your worry about agents becoming "unnecessarily adversarial" is this. The permission to depart must not read as an instruction to depart.

➡️ One mechanism in place of the five:
- For route knowledge: the reader uses its judgment. Its report always says where it took a different route and why, or says it took none, stated as fact and not as an invitation.
- For a binding rule that fights the goal: the reader stops that part, reports the conflict to the rule's owner, and carries on with the rest.
- The reader never shrinks the goal to fit a rule.

---

❓ **Q5 - Can cost or time justify limiting the route?** The evidence cuts against it: under tight output budgets, reasoning models fell sharply, one from 72% to 54% (§4). Q3's filter step also meets the usual reason for a cap, which is too much output for the next step to read.

The options:
- (a) A budget is stated as a fact about the situation, and the reader plans its route within it.
- (b) A budget you set yourself binds, by Q1.
- (c) Budgets stay out of the writing.

➡️ (a) by default; (b) when the budget is yours. The map "Optimize token use and wall-clock time without losing reliability" can revisit this once it has measurements.

---

Round two covers two questions that depend on Q1. The first is how binding rules are worded and held. The research argues against emphatic wording and bare prohibitions. It also suggests that a hook's refusal message, which arrives at the moment of use with the reason and a way forward, may do more than restating the rule in every brief. The second is a set of cases to test your answers against, including the `spec:` gate and the delegation rule.
