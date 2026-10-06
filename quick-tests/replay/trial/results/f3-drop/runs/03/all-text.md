Yes, the research changes the questions. Round one treated the problem as sorting rules: which ones bind and which don't. The research says that sorting is only part of it. How a rule is worded, where it sits, and whether the reader has an expected way to depart from it matter as much. It also shows that the task statement itself, and the definition of "done", can narrow the work as much as any rule.

## What changed

- **The goal and "done" are not neutral.** I had treated "what's wanted" and "what done means" as safe things to make binding. Three findings say otherwise:
  - *Reporting bars.* Radiologists who had already found one abnormality kept searching but held back reporting the next (Berbaum 2015). Anthropic's own guide reports the same in Claude: a "high severity only" brief finds the bugs and then leaves some out of the report.
  - *Narrow tasks.* A narrow task instruction stopped models from reporting critical findings they reported otherwise, and a separate open-ended critic recovered them (Shin 2026, a preprint).
  - *Proxy goals.* People treat a measure as if it were the goal (surrogation).

  Our `spec:` gate is all three at once: a reviewer obeyed the gate and filed nothing on a PR that had four real bugs.
- **Wording does as much as content.** The same limit stated as control lowered creativity, and stated as information it did not (Koestner 1984). Current Claude models read literally and over-apply emphatic wording, and they generalize better when given the reason (Anthropic's guidance).
- **Telling the reader things is different from limiting what the reader looks at.** Forensic science's evidence supports withholding the writer's own conclusion. It supports nothing that limits what the reader may go and look at. Several of your examples mix the two, and so did my round one.
- **Cold doesn't mean weak.** Step-by-step guidance helps novices and hurts experts (meta-analysis, d = 0.51 against −0.43). A fresh subagent is capable but knows nothing about the project. Project facts help it. Instructions on method cost it.
- **Readers rarely ask.** Survey respondents told they could ask for help asked on 4% of the occasions it was given. Current models almost never ask on underspecified tasks. Telling readers that checking a definition was *essential* rather than *available* raised checking from 23% to 81%. So "say so and get a sign-off" only works if departure is built into what the reader hands back.

**Where the evidence is thin:** no study tests a limit on method in models directly, the vendor guidance covers Opus 4.8 rather than 5.5, and the Shin preprint has a single author. Most of the support for your framing is human evidence plus the nature of instructions: Garfinkel and Suchman argue that no rule written in advance can contain the situation it will meet.

## Revised round one

The cases in each question are illustrations, not the edge of the question.

❓ **Q1 - What does this ticket cover?** Three things can bound how a task is pursued:
- **explicit rules:** "read only the diff", "cite a `spec:` line";
- **implicit bounds:** a list of smells to look for, examples, a narrowly worded task, a template's fixed shape. The research shows these move readers as much as rules do. A list with an "other" slot still pulled 60% of answers onto four listed items, against 2% when the question was open.
- **what the writer volunteers:** its own conclusion ("I think this diff is fine"), its hopes, earlier rounds' findings. This leads the witness, but it limits nothing the reader may do.

The options:
- (a) all three;
- (b) explicit and implicit bounds on the reader, with the writer's restraint going to the ticket "Decide what the writing standard is and what carries it";
- (c) explicit rules only.

➡️ (b). The first two both limit the reader. The third shapes the reader without limiting it, and the research treats it as its own mechanism, with its own remedy: hold back conclusions that aren't relevant to the task.

---

❓ **Q2 - What makes a rule binding, and who may make one?** This merges my old Q1 and Q4. A binding rule is one the reader may not overrule on its own. The proposal: a rule binds only when someone with that authority made it so. That means you, the ticket, AGENTS.md, or a live fact the writer owns, such as "another subagent is editing this file." An orchestrator writing a brief may pass binding rules down and may bind what it owns. Its own judgment about the method it may only offer, never impose.

The research backs the last part. In practice, written statements of intent were full of method, and they matched the commander's actual intent only 34% of the time (Shattuck 2000). An interrogator's expectation shaped the questions, the answers, and how bystanders heard the answers (Kassin 2003). The writer's guess about the route always leaks into the brief.

Two test cases:
- The delegation rule is about method, yet it binds because you set it, with evidence: the prose failed and a hook now holds it.
- The mandatory trail review caught the owner's errors 3 times out of 3. It binds for the same reason.

➡️ Binding comes from authority, not from what the rule is about. Every binding rule travels with its reason and its owner, so the reader can apply it sensibly in a case nobody foresaw and knows whom to tell when it conflicts with the goal.

---

❓ **Q3 - How are the goal and "done" written so they don't narrow the work?** This question is new. The options:
- (a) Write the purpose above the task: what the larger effort is for. Then the check the writer will use, saying the purpose wins over the check. Ask for everything the reader found, with its own confidence and severity, and leave any filtering to a separate step. Give it a place to report what falls outside its task.
- (b) Write "done" as checkable criteria only.
- (c) State the purpose and leave "done" to the reader.

➡️ (a). (b) is the `spec:` gate failure: readers report what the check counts. (c) loses the check the writer actually needs. The separate filtering step is Anthropic's own fix for the reporting bar. The outside-the-task place is the open-ended critic that recovered the missed findings. Doing this means changing the review scripts' gates, not just their prose.

---

❓ **Q4 - How is knowledge about method written?** This was my old Q2, now sharpened. The options:
- (a) Leave it out.
- (b) Give project facts freely, meaning things the reader couldn't cheaply find. Offer method as something the writer knows, with its reason, never as an order. The reader may take another route and says so.
- (c) Write it as a default the reader may override.

➡️ (b). A cold reader needs the project spelled out: explicit links helped readers without background (McNamara 1996). Method is where the expertise-reversal cost lands. The reason is what lets the reader spot the case the writer didn't foresee.

One sub-case: specific method did help on simple tasks (Winters and Latham 1996). For a mechanical job, such as a rebase check, offering the whole method costs nothing. It should still be offered, not imposed.

What to avoid is a *partial* list of where to look or what to find. Being given part of a list makes people recall less of the rest (part-list cueing, meta-analysis over 109 samples).

---

❓ **Q5 - Budgets and output caps.** This was my old Q5, now split in two. A budget on effort (time, tokens) is different from a cap on what's reported ("under 400 words", "top 3"). Tight output budgets cut reasoning sharply in reasoning models (Sun 2025), and a cap on reporting works like a reporting bar. The options:
- (a) State effort budgets as facts the reader plans within. Never cap what's reported; if the receiver needs it short, a separate step condenses it.
- (b) Allow both.
- (c) Neither appears in the writing.

➡️ (a). The ticket "Optimize token use and wall-clock time without losing reliability" can revisit the effort side once it has measurements.

---

**Next round** (these depend on your Q2 answer):
- **Rules held by structure.** PHILOSOPHY belief 3 puts a rule on the strongest rung that can hold it. A rule moved into a hook or a script has no override. I'll ask whether only binding rules may climb that ladder.
- **What the reader does when a rule fights the goal.** The factory has five departure mechanisms that conflict. One is your own note: "follow the file and tell me why your instinct differed", next to "get a sign-off". I'll ask whether that note is about taste rather than conflict, and propose one mechanism that builds departure into what the reader hands back, since readers rarely ask on their own.

Housekeeping, unchanged: once this settles, I'll rewrite my own memory that still states the old "protect the world" test.