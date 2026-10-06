Yes, the research changes the round. Five of my earlier recommendations still point the same way, but several rested on a distinction that was too coarse. The research also raises three questions I hadn't asked, and it changes how I should present the questions to you. Here is what changed, then the revised round, which replaces the first one.

## What the research changed

1. **A brief holds three different things, and round one treated them as one.**
   - Rules on what the reader may look at or do, such as "read only the diff".
   - Facts about the terrain, such as "the git guard refuses `git` inside `$(...)`".
   - The writer's own beliefs about the answer, such as "zero items is the expected result".

   Forensic science keeps the second and withholds the third. Clinical context improved diagnostic accuracy in all 16 studies of it, while a disclosed earlier conclusion biased experts in 4 of 4 studies. Holding back the writer's beliefs is restraint by the writer, not a limit on the reader. The old reviewer briefs mixed all three: "read nothing beyond this brief" was a limit on the reader that claimed to protect against leading.

2. **Writing route advice as information instead of an order helps less than I implied.**
   - Information about a method still anchors the reader. Chess masters missed a shorter mate once they knew a familiar one. Designers copied the flaws in example designs even after being told about the flaws. Codex copied lines from an anchor function into 32–61% of its solutions.
   - The vendor's notes say current Claude models read instructions literally. In the research note's words, a literal reader makes every word in a brief bind harder, including words meant only as illustration.

3. **Usually the reader won't notice it has been limited.** Round one's departure question assumed the reader sees the conflict. The evidence says it mostly doesn't.
   - In one preprint, a narrow task instruction stopped models from reporting critical findings they reported without it, and a separate critic with an open brief recovered all of them.
   - Hints moved models' answers without appearing in their reasoning.
   - People told they could ask for clarification did so on 4% of occasions; current models almost never ask on underspecified coding tasks.

4. **The definition of done is where route limits hide.**
   - A bar on what gets reported makes reviewers hold back findings they already made. That has been shown in radiologists, and the vendor reports it for Claude.
   - Measured goals replace the real goal, sometimes without the person noticing.
   - The `spec:` citation gate did exactly this on the run-2 PR where a reviewer filed nothing despite four real bugs.

5. **Prescribing a method sometimes helps.** Specific goals help on simple tasks, and step-by-step guidance helps novices while hurting experts. A subagent starting cold is capable in general but a novice in this project. You already made this exception for lists ("fine if you are looking at a closed ended task"). The open question is whether it extends to method.

6. **No rule can foresee every situation it will meet.** Garfinkel and Suchman argue that no written instruction is ever complete. So no test I propose will sort every rule correctly. What the answer needs is reasons written next to rules, so a reader can see when its situation is one the reason didn't foresee, plus a way out.

7. **The format of my questions leads you.** Lettered options bound answers even when "other" is offered: in one experiment, four problems listed as options went from 2% of answers to 60%. My recommendations anchor you too. In this round the options are only what I could see, not the full space, and each question gives the evidence before my recommendation.

**How strong the evidence is:** most of it is about people. The model evidence is mostly 2022–2025 models plus vendor notes without numbers. No study tests a limit on how a model may pursue a task as such. The decisions below rest on that base, and Q7 asks what to do about that.

---

❓ **Q1 - Which of the three kinds of content does this ticket govern?**

The three kinds are the ones in point 1: limits on what the reader may look at or do, facts about the terrain, and the writer's beliefs about the answer.

My proposal:
- This ticket governs the first kind.
- The writing standard requires the second kind, because a reader starting cold lacks it.
- The third kind is leading the witness, which belongs to the ticket "Decide what the writing standard is and what carries it".

This ticket still has to draw the line between the three, because mixing them is how the old reviewer briefs went wrong.

A case to test the line: a round-two reviewer that goes and reads round one's comments on the PR. Under this line, the writer doesn't hand those comments over, because that would be volunteering a belief about the answer. But the writer doesn't forbid the reviewer from finding them either, because that would be limiting what the reader may look at. Your memory rule "keep later review rounds equally blind" currently does both.

➡️ Adopt the three-way line, and settle the round-two case the way I described: the writer stays quiet, and the reader stays free to look. If that case feels wrong to you, it shows where the line needs to move.

---

❓ **Q2 - What makes a rule on the route binding?**

Round one proposed two conditions: the rule states the task or a limit of authority, and the person who owns that authority set it.

The research adds a third condition: the rule's reason has to be written down.
- **Mission command** is the military practice of stating the end state and the reason and leaving the method to the subordinate. In the one empirical test I know of, only about a third of subordinates' actions matched their commander's intent once coincidental matches were removed.
- **Commanders' written intent statements**, which were supposed to leave method open, were full of method. Writers slip method in even when the rule tells them not to.
- **No rule is complete**, as in point 6. A reason is what lets a reader spot the situation the rule didn't foresee.
- **The factory's own method rules that worked all fit these conditions.** The trail review caught the owner's errors 3 of 3 times, and the delegation hook replaced a rule that prose alone couldn't hold. Both were set by you, with evidence.

➡️ A rule on the route is binding when its owner set it and its reason is written next to it. A binding rule with no written reason is a defect to fix, not a rule to obey blindly. This makes "never an arena" and "Read no brief and no diff while the review state exists" defects until someone writes down why they exist.

---

❓ **Q3 - May a method be prescribed when the task is closed?**

You said a list is fine for a closed task whose options really are listable and complete. The research supports extending that to method: step-by-step guidance helps on simple tasks and for readers new to a domain.

Some factory tasks look closed:
- running the gate scripts;
- rebasing the chain;
- posting a review through `review-comment.sh`.

Others look open even though a playbook scripts them, such as feature work. `PHILOSOPHY.md` praises playbooks for making "the agent follow… a script rather than improvising."

The questions are whether the exception extends to method, and who gets to call a task closed.

➡️ Yes, it extends. Tasks are open by default. A writer may call a task closed only if it can say why every right way of doing it is already known. Playbook steps that script method on open tasks stay binding where you set them (under Q2), and they become audit targets for the ticket "Decide the scope and order of reworking existing files". The tension with the philosophy belongs in that ticket's audit rather than being resolved here.

---

❓ **Q4 - How should the writing state what done means?**

"Done" is part of the goal, so it's binding. But a definition of done can be a stand-in for the goal, and then it replaces the goal. Cases where that happened:
- "Only report high severity" made the reviewer find the bugs and leave them out of its report (vendor observation, reproduced in radiologists).
- "Zero items is the expected result" set the reviewer's bar in advance.
- The `spec:` citation gate refused real bugs that had no citation.

The vendor's remedy is to report every finding with its severity and confidence, and to filter in a separate step.

➡️ State done as the goal itself, never as a stand-in for it.
- A report format may shape how a finding is written down. It may never decide which findings are let in.
- Thresholds, caps and required citations move into a separate filtering step that someone else owns, after the full report exists.
- P18's definition of "hard" survives, because it classifies findings after they are reported. The `spec:` gate, which refuses findings before they are reported, does not.

---

❓ **Q5 - What about budgets?**

The research separates two kinds of budget:
- **A budget for spending:** time, tokens, money.
- **A bar on output:** a number of findings, a word limit, a severity level.

Bars on output are Q4's problem: tight length budgets hurt reasoning models sharply, and telling a reader how many problems to expect moves where it sets its bar. Numbers anchor people even when the people know the numbers are random.

➡️ Never write a bar on output. A spending budget appears only when it is real and its owner set it, stated as a fact about the situation with its reason, and the reader plans its own route within it. A writer never invents a budget "to be safe." The token-and-time map can revise this once it has measurements.

---

❓ **Q6 - How do departures from a rule work?**

The factory has five mechanisms, and they conflict:
- say so loudly and get a sign-off;
- follow the file, then explain;
- `skip: <reason>`, which `feature.md` forbids for delegation;
- record a Provisional decision you can overrule;
- end a writer flag with `accepted: <reason>`.

Point 3 adds that the reader often won't notice a conflict at all. Readers checked definitions on 81% of questions when told they were essential and on 23% when told they were merely available. A medical handoff template cut errors by 23%, and it ends with the receiver restating the plan.

➡️ Replace the five with one mechanism.
- **Guidance that isn't binding:** the reader may depart from it freely and says so in its report, with the reason.
- **A binding rule that fights the goal:**
  - The reader does everything else, never narrows the goal to fit, and reports the conflict to the rule's owner.
  - It asks the writer partway through when it can reach it. Letting a less-informed agent ask beat pushing instructions to it.
  - The sign-off line stays for the session where you are present.
- **Every report states what the reader didn't do and which rule stopped it**, as a required part of the report, not an option. That makes a silent narrowing visible even when the reader never felt it as a conflict.

---

❓ **Q7 - How firm should this decision be, given the evidence?**

The case for the broad principle is strong in people, and it rests on vendor notes and one preprint for current models. Two experiments could test the shakiest parts, and the factory could run both itself:
- the same open-ended task with and without an illustrative list, counting what each lane finds outside the list;
- a reporting bar in the brief against reporting everything and filtering afterwards.

➡️ Decide now, so the rest of the map isn't held up. Record which parts rest on evidence from people only. Hand both experiments to the ticket "Decide how we'll know the writing works", so a result can overturn the specific parts it tests without reopening the whole decision.