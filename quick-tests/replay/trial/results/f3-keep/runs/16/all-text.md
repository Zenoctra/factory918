Yes, the research changes the round. Three things move, and the rest gets better grounding. Section numbers below refer to [the research note](https://github.com/Zenoctra/factory918/blob/research/wording-and-reader-context/docs/research/wording-and-reader-context.md). Terms as before: the **goal** is what's wanted, the **route** is how the reader gets there, and a **binding** rule is one the reader may not overrule by itself. The **orchestrator** is the main session that writes briefs, and a **lane** is the subagent that reads one.

**What changed:**

1. **"What done means" is not a safe place for a rule.** In round one I listed it as binding. The research says the most costly rules aren't limits on reading. They're bars on what gets reported.
   - Radiologists who found one nodule kept searching but stopped reporting the next one (§4).
   - Anthropic's own guide says "only report high-severity issues" makes Claude find a bug and then leave it out of the report.
   - Your run 2 shows the same thing. The `spec:` gate made a reviewer file nothing on a PR with four real bugs.

   A rule that defines "done" can hide a cap.
2. **Deleting rules isn't enough.** The task statement itself decides what the reader sees. People counting basketball passes miss the gorilla. In the one model study of this (Shin 2026, a single-author preprint), a narrowly worded task suppressed findings the same models reported otherwise. A separate reviewer with an open brief recovered every one. Your principle needs something positive in the writing, not only fewer rules.
3. **There are real counterweights.** Specific method helps on simple tasks and for newcomers (§4). A lane is a capable model, but it starts with no knowledge of the project (§9). And restraint in what the writer volunteers is a different thing from limits on what the reader may look at. The forensic evidence supports the first and says nothing for the second (§3).

**Limits of the evidence:** no study tests a limit on strategy in a model directly, and nothing covers Opus 5.5 (§13). What follows rests on human evidence plus the closest model findings.

**About this format:** a numbered list of options with my recommendation is itself the kind of request §2 warns about. People keep to an offered list even when there's an "other" slot. Your answers in the earlier rounds went well past my options, and that's the answer I want here too.

---

❓ **Q1 - What makes a rule binding?** Two of the factory's rules about the route clearly worked. The trail review caught the owner's errors three times out of three. The delegation rule only held once a hook enforced it. Both are yours, and you had evidence behind them. Two other rules did harm: "Read no brief and no diff" ([ticket.md:13](template/.agents/skills/poteto-mode/playbooks/ticket.md:13)) and the pstack wrapper's "Execute only the task and path scope the parent assigns". Those were written by models, for reasons nobody recorded.

So the difference isn't what a rule is about. It's who designed it and at what level. You design the structure: which roles exist, who checks whom, what nobody may do. Each reader owns its route inside its own job. Military doctrine draws the same line: a commander states the purpose and the end state, not how to get there (§4). One study complicates that. Intent statements written that way reached subordinates in only 34% of cases, so stating the end is necessary but not sufficient.

➡️ A rule binds only if it comes from whoever owns that decision: you, the ticket you approved, or the factory's structure as you designed it. Inside its job, the route belongs to the reader. Run 2 showed that a definition of "done" can hide a reporting bar, so how the report is handled is decided separately in Q2.

---

❓ **Q2 - Does any brief set a bar on what gets reported?** A **reporting bar** is any rule that keeps a finding out of the report. Examples:
- a severity floor;
- a required citation, like the `spec:` gate;
- a word or count cap;
- a task statement so narrow that whatever falls outside it doesn't seem worth reporting.

The evidence that bars cost findings is the strongest in the note: radiology, the vendor's own guidance, Shin's preprint, and run 2. One case from run 2: Fable wrote "not filed hard because the Standards brief carries no ticket criteria to cite."

➡️ No bars. The reader reports everything it found, inside or outside the task, each with its confidence and severity. Filtering is a separate step that someone else owns. Telling readers the report is *essential*, rather than merely *available*, made survey respondents check definitions 81% of the time instead of 23% (§8). So ask for the findings outside the task as part of the job, not as an optional extra.

---

❓ **Q3 - What may the writer say about the route?** In round one I proposed passing on route knowledge as information, with its reason. The research adds a warning: a method you offer still anchors the reader.
- Codex copied lines from an example function into 32–61% of its solutions.
- Chess masters who knew one mate couldn't see a shorter one, even while they were looking for it (§2).

Wording also matters. The same limit cut children's creativity when it was worded as control, and didn't when it was worded as information (§4).

A case from the factory: [ticket.md:10](template/.agents/skills/poteto-mode/playbooks/ticket.md:10) says to run "two plain commands" because the guard refuses `git` inside `$(...)`. The fact is the guard. The method is the two commands.

➡️ Pass on facts about the situation (traps, tool quirks, what's true in this repo) freely and clearly, because a cold reader needs them. Leave method out. If a fact strongly implies a method, state the fact and let the reader work out the method. A reader that knows the guard's behavior can find its own way around it.

---

❓ **Q4 - Does a closed task change this?** You said yourself that lists are fine when the options really are complete. Step-by-step guidance helps on simple tasks and for newcomers (§4). Example: "run `build_knowledge.py` and confirm `git status` is clean." The risk is that the writer misjudges which tasks are closed. Writers overestimate how well they understand the reader's situation, a bias called the **curse of knowledge** (§6).

➡️ Exact method is allowed when the writer can list the whole task: every step and every outcome. If there's any doubt, treat the task as open. Exact method still carries its reason, so the reader can spot the case where it doesn't apply.

---

❓ **Q5 - What the writer holds back is a different question.** "Read only the diff" limits what the reader may look at. "The brief doesn't include my theory of where the bug is" is the writer holding back its own conclusion. The second is supported:
- Forensic examiners who were given case context reversed their own earlier conclusions (§3).
- Code reviewers told the code was bug-free found far fewer vulnerabilities (§3).
- "Zero items is the expected result" did the same damage in run 2.

But information the reader actually needs for the task helped: medical readers were more accurate with clinical details, and no study found a loss (§3).

➡️ This ticket records that holding back conclusions is not a limit on the route, so the rest of these decisions leave it alone. What to hold back and how belongs to "Decide what the writing standard is and what carries it". The line to draw there: hold back the writer's conclusions, never the information the task needs.

---

❓ **Q6 - What happens when a binding rule fights the goal?** The research changes this question. In round one I treated quietly narrowing the goal as an option to rule out. It's actually what readers do by default:
- People who misunderstand rarely notice, and asked for help on only 4% of the occasions it was given (§8).
- Current Claude models follow instructions literally (§11).
- So a rule that fights the goal gets obeyed in silence, and the goal shrinks without anyone saying so.

The factory also has five ways to depart from a rule, and they conflict: sign-off first; follow the rule then explain; a written `skip:` with a reason; a Provisional decision; `accepted:` with a reason. None of them says how a lane gets a sign-off.

The one large field test of a fixed handoff structure (I-PASS, nine hospitals) cut medical errors by 23%. Its last step is the receiver restating the plan to the sender (§10).

➡️ One mechanism, with two cases:
- A session where you're present asks you.
- A lane running unattended stops that part, reports the conflict, and carries on with the rest.

Either way, the report always has a section that says how the reader read the goal, what route it took, and any rule that got in the way. Asking for that section every time is what makes silent narrowing visible.

---

❓ **Q7 - May an orchestrator make its own guesses about the route binding?** The evidence makes this sharper:
- Interrogators told to expect guilt asked leading questions, and outside listeners then judged the suspects as more defensive (§3).
- Run 2's limits on reviewers were added by lanes to save cost; no ticket asked for them.
- A lane once turned one of your questions into a rule.
- A model reads literally, so whatever the orchestrator writes binds harder than it meant.

➡️ No. An orchestrator passes your rules down. It binds only what it actually owns, such as which files other lanes are editing right now. It offers everything else as facts, under Q3.

---

❓ **Q8 - Resource budgets.** This is only about time and tokens; caps on output are covered by Q2. Under tight output budgets, reasoning models lost accuracy sharply (§4). A budget is a fact about the situation, and a capable reader can plan around it.

➡️ State a budget as a fact the reader plans within, never as a limit on its route. Only you set budgets. The map "Optimize token use and wall-clock time without losing reliability" can revisit this once it has measurements.

---

❓ **Q9 - How are binding rules worded?**
- Readers follow a rule better, and apply it more sensibly, when they know its reason (§4, plus the vendor's guidance).
- A bare "don't" keeps the forbidden idea in mind and gives no alternative, so the reader falls back on some other fixed default (§5).
- Emphatic wording makes current Claude models over-apply an instruction (§4).
- Fixed text repeated in every brief stops being read (§1).

The factory's git guard already does this well: its block message names the allowed alternative.

➡️ Every binding rule is written plainly, with its reason, and it names what to do instead. It also appears where it applies, not as a wall of fixed text at the top of every brief. Exactly where each rule lives is for "Decide where each piece lives and when it reaches the writer".

---

Once you've answered, I'll rewrite my memory of the old "protect the world / shape the search" test to match. The experiment the note says nobody has run is the same task given with and without an illustrative list, counting what each finds outside the list. That belongs on the ticket "Decide how we'll know the writing works", and I'll put it there when I close this one.