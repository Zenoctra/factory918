Yes, the research changes the round. I've now read the whole note, and the questions change in three ways. The revised round follows.

**What changed**

1. **Stating the goal is not as harmless as my first Q1 assumed.** I treated "what's wanted" and "what done means" as safe binding territory. The research says the way a task is stated decides what the reader sees.
   - People counting basketball passes missed a gorilla walking through the scene 46% of the time.
   - A 2026 preprint found the same in models. A narrow task instruction stopped models reporting critical findings they did report without it. A separate agent with an open brief then recovered every finding they had left out. It is one author, not peer reviewed.
   - A bar on what counts as done makes readers drop findings they already have. Radiologists kept searching but raised their bar for reporting. Anthropic says Claude does the same under "only report high-severity issues."

   That is the `spec:` gate case from my earlier message: a definition of done that worked as a cap.
2. **Your examples mix two different things.** One is what the reader may go and look for. The other is what the writer chooses to hand over. Withholding the writer's own conclusion protects a reviewer's independence: telling a model the code was bug-free dropped vulnerability detection from 97% to 4% for a small model, and from 96% to 89% for Opus 4.5. Withholding relevant context gives no such protection: across 16 medical studies, clinical information improved accuracy and never hurt it. My first round had no question about this.
3. **My Q3 assumed the reader would notice a conflict and say so. People and models rarely do.**
   - Survey respondents told they could ask for help seldom did: when interviewers clarified a question, 96% of the time it was the interviewer's idea.
   - Current models almost never ask on underspecified coding tasks.
   - Models often don't mention the hint that moved them: Claude 3.7 Sonnet mentioned a hint it used 25% of the time.

   So a way of handling conflicts that relies on the reader reporting them is weaker than I made it sound.

**How much weight this carries.** Most of the strong evidence is about people. No model study tests a limit on method itself, such as which files to read or what order to work in. The model studies cover reporting bars, formats, length limits and framing. Anthropic's notes cover Opus 4.8, not the Opus 5.5 the factory runs. Q8 asks what to do about that.

Same terms as before:
- **The goal** is what's wanted and what done looks like.
- **The route** is how the reader gets there.
- **A binding rule** is one the reader may not overrule by itself.

Old Q4 (who may write binding rules) is now part of Q1, and old Q5 (budgets) is now Q6. The options in each question are the ones I could see. Answer outside them wherever they miss.

---

❓ **Q1 - What makes a rule binding, and who can make one?** My answer is the same; the research gives a better reason for it.

Garfinkel and Suchman argue that no instruction written in advance can foresee every situation it will meet. The reader always fills gaps; the only question is whether the text helps it fill them well. Every rule will someday meet a case its writer didn't foresee. That case is exactly where a rule based on predicting the route fails. In your words: "if you could predict it, then you could constrain it."

What doesn't depend on prediction is authority: a rule binds when the decision isn't the reader's to make. You merge. Another subagent owns a file. The ticket draws the scope. The route rules you set yourself, delegation and the trail review, bind because you own them. The factory also has evidence for both: the trail review caught the owner's errors three times out of three, and the delegation rule held only once a hook enforced it.

The research adds a caution. A binding route rule still has a cost. A familiar method keeps people from seeing a better one even while they believe they're looking: chess players said they searched for a shorter mate, but their eyes stayed on the familiar one. So a binding rule should carry its reason. Then the reader knows what the rule protects and can recognise the case where it fights the goal (Q5).

On who writes binding rules into a brief: the orchestrator should pass down yours, AGENTS.md's and the ticket's, and add only what it owns itself, such as which files other subagents hold right now. Interrogators who expected guilt asked questions that shaped the answers, and even shaped how neutral listeners heard them. An orchestrator's guess about where the bugs are works the same way once it becomes a rule.

➡️ A rule binds only when it comes from authority over the decision, never from a prediction of the route. Only the owner of that authority can make it binding. Every binding rule carries its reason.

---

❓ **Q2 - How should the brief state the goal and what counts as done?** New question. The way the task is stated and the bar for done both limit what the reader reports, so they need their own treatment. Three cases:
- The `spec:` gate required a reviewer to cite a ticket criterion it was never shown. On one PR with four real bugs it filed nothing.
- With "only report high-severity" or "be conservative", Anthropic reports that recall falls even as the model's ability to find bugs rises.
- With "under 400 words" or "stop after N", the reader may do the work, and the cap decides how much of it reaches the page.

Anthropic's advice for its own models is to ask for every finding with a confidence and a severity, then filter in a separate step. The format research points the same way. Forcing JSON output hurt reasoning in one study, and answering freely before converting removed most of the loss; a rebuttal with matched prompts disputes this. An "other" slot does not open up a closed list. Four listed problems went from 2% of answers to 60% when they were listed, even with an explicit invitation to name a different one.

- (a) The brief states the purpose behind the task, not just the task. It asks for everything that purpose would care about, with each item tagged with what the next step needs. Thresholds and the required output shape are applied afterwards, by a script or a separate step, never by the reader.
- (b) Bars and formats stay in the brief, each with its reason.
- (c) Leave this to the ticket "Decide what the writing standard is and what carries it".

➡️ (a). Stating the purpose matters as much as moving the filtering out. In the preprint, the one model that reported the critical findings anyway was the exception, and the open-ended critic recovered the rest. A reader that knows why the task exists can report what the purpose cares about even when it falls outside the task as worded. For the `spec:` gate, this means the reviewer files every bug with what it is based on, and the script decides what counts as hard.

---

❓ **Q3 - What may a writer say about the route?** Refined. The research splits what I called "route knowledge" into two kinds:
- **Facts about the ground:** the worktree guard refuses `git` inside `$(...)`, paths contain spaces, this hook blocks that call.
- **Directions:** read these files first, use this tool, check in this order.

A subagent starting cold knows little about the project, however capable it is, and readers who know little are helped by explicit connections. But it is an expert at method, and step-by-step guidance hurts experts. A meta-analysis of 60 studies found help raised novices' results (d = +0.51) and lowered experts' (d = −0.43). Directions also get copied: Codex, given a related function as an anchor, copied its lines into 32–61% of its solutions.

My earlier option of "a default the reader may override" is weaker than I thought. Anthropic says current Claude models read instructions literally, so a default worded as an instruction gets followed as one. The wording matters for people too: children painting under the same limits were less creative when the limits were worded as control rather than as information.

The counterweight is that specific method does help on simple, routine tasks.

- (a) Facts about the ground go in freely, each with its reason. Directions stay out, and the reader finds its own route.
- (b) Both go in, written as what the writer knows, not as orders.
- (c) As (a), except that simple routine jobs may get directions, with their reasons.

➡️ (a). I doubt (c)'s exception is worth having. The factory's jobs that look routine, such as rebasing and running checks, are where the ledger records its surprises. If you want the exception, it has to name who decides that a job is simple.

---

❓ **Q4 - What the writer hands over, as opposed to what the reader may look for.** New question. This ticket's principle covers what the reader may look for: no rule limits what it may read, run or try. What the writer hands over is a separate decision. Forensic science keeps irrelevant information and earlier conclusions away from analysts, and medicine shows that relevant context improves accuracy. Both fields draw the line between context the task needs and context that only carries someone's conclusion.

This meets your answer to Q9 in the second charting round: full, unsummarized quotes of where the task was defined, including the orchestrator's conversation. Those quotes can carry the orchestrator's verdict, such as "this looks right to me." For a subagent judging that same work, a verdict like that is what moved the models in the code-review study.

- (a) The reader may look for anything. The writer gives the full context of where the task was defined and leaves out only its own verdict on the work being judged.
- (b) The writer gives everything and labels its verdicts as its own belief.
- (c) Leave the line to the ticket "Decide what the writing standard is and what carries it".

➡️ (a), with your words always quoted whole. A label (b) helps less than it seems: in human studies, a warning given after misleading information cut its effect to under half, not to zero, and models don't reliably say when a hint moved them. I'd draw the line here and leave the details to the writing-standard ticket.

---

❓ **Q5 - What does the reader do when a binding rule fights the goal?** Refined. The factory's five existing mechanisms still conflict, and whatever you choose here replaces all of them. What the research changes is that the reader probably won't notice the conflict or report it on its own. When people were told that checking a definition was *essential* rather than merely *available*, they checked on 81% of questions instead of 23%. A literal model given a rule that fights the goal is likely to shrink the goal without saying so, which is the outcome I said must never happen.

- (a) Stop that part, report the conflict to whoever owns the rule, and carry on with the rest. The brief says that reporting a conflict is part of finishing, not just something allowed.
- (b) As (a), plus a check that doesn't depend on the reader's own report: for judging work, a fresh subagent with an open brief looks for what was left out.
- (c) Break the rule and report it.

In the main conversation, where you are present, "say so loudly and get a sign-off" still works. For a subagent, the report plays that role.

➡️ (a) for every brief. (b) is a real option for judging work, since in the preprint the open-ended critic recovered every omitted finding. But it costs an extra subagent each time, so I'd hand the question of whether and where to the ticket "Decide how we'll know the writing works".

---

❓ **Q6 - Can cost or time justify a limit on the route?** The research leaves my answer the same and moves part of it to Q2. Tight output budgets cut reasoning models sharply: Phi-4-reasoning fell from 72% to 54% at 1,024 tokens. People also start treating a measure as the goal it was meant to track, even when nothing is riding on it and without noticing.

➡️ A token or time budget is stated as a fact about the situation, and the reader plans its route within it. It never caps findings or output length; Q2 moves that narrowing to after the work. A budget you set yourself is binding under Q1.

---

❓ **Q7 - How is a binding rule worded?** New question. Two findings bear on it:
- A prohibition keeps the forbidden thing active and doesn't say what to do instead, so models land on some other fixed habit. This was measured in older and smaller models; current frontier models mostly comply.
- Anthropic says emphatic wording ("CRITICAL", "MUST") makes current Claude models apply an instruction too widely.

The factory already has a good model: when the git guard blocks a force-push, its message says "Use --force-with-lease on your own branch, or ask."

- (a) Plain wording, the reason, what to do instead, and who owns the rule. A rule's binding status comes from naming its owner, not from emphasis.
- (b) Keep "never" and capitals for the few binding rules so they stand out.

➡️ (a). It applies to the "ways to hurt yourself" section in AGENTS.md as much as to briefs, and the ticket "Decide the scope and order of reworking existing files" would carry it out.

---

❓ **Q8 - Adopt this now, or measure first?** New question. These decisions rest mostly on evidence about people. The research names an experiment the factory can run itself: give subagents the same open-ended task with and without an example list, and count what each finds outside the list. A second experiment would test a limit on method directly.

- (a) Adopt now, and hand both experiments to the ticket "Decide how we'll know the writing works".
- (b) Run the experiments first.

➡️ (a). It matches your answer on who counts as the reader: apply the standard broadly, and narrow it only once a test shows a cost.

---

Once this round settles, I'll rewrite the memory that still holds the old "protect the world" test.