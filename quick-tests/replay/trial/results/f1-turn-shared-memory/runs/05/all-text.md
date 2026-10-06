Thanks. Your answers to Q2, Q3 and Q5 settle those. Q1 is settled for now, and since you found it abstract I've explained it again below in plainer terms, because the next questions build on it. On Q3, your worry is real, and I need to correct how you read what I said. Q4 comes back with the five mechanisms spelled out.

## Q1 again, in plain terms

Think of hiring a contractor to redo your kitchen.

- You tell them: "The cabinets are blue. Only a licensed electrician touches the wiring. Don't knock down the wall by the stairs." Those hold no matter what, because you own the kitchen and you said so.
- The contractor's helper tells a new worker: "Start with the cabinets, and only use the small drill." That's advice. If the worker finds a better way, they should use it and mention it.

Applied to briefs: **a rule binds only when the person who owns the work said it must hold.** Usually that's you. Sometimes it's whoever owns a resource, such as another subagent owning a file it's editing. Everything the writer of a brief adds on its own is advice, written with its reason.

Your Q5 answer is this rule in action. Processes you require bind. "Cut token use in half" was a prediction a model turned into a requirement, and nobody who owned the work had made it one.

In practice, the writer asks one question of every rule in a brief: **"Who said this must hold?"**
- If you did, or the ticket or AGENTS.md says so, it binds.
- If the writer is the only source, it's advice.

## Q3: your worry is right, and (a) alone doesn't fix it

You read my answer as saying the evidence shows both kinds of bug get found. It doesn't show that, and I should have been clearer. There are two separate failures:

1. **Withholding.** The reviewer found the bug and didn't report it because of a bar in the brief. The evidence says that's what a bar causes, and (a) fixes it.
2. **Attention.** The reviewer never saw the bug because it was looking somewhere else. This is the gorilla effect, and (a) does nothing for it. It also doesn't need a brief to cause it. Models already lean toward the same default focus: different models gave 71–82% similar answers to open questions. A reviewer that drifts into edge cases on unsupported input is following its own default.

Your "slight push" idea has a measured cost. Naming a kind of bug raises how often that kind is reported. In the human studies it also lowers recall of the kinds you didn't name, even with an "anything else?" slot.

The fix the evidence supports is structural: more than one pass, each with a different open brief. In the one model study of this, a second reviewer with an open-ended brief recovered everything the focused one had hidden. That's your "multiple passes" point. It belongs to the review design, not to this ticket, so it's in Q8.

## What's settled

- **Q1 (c):** a rule binds only if the person who owns the work said it must. Anything the writer adds on its own is advice.
- **Q2 (b):** what the writer knows about how to do the job goes in as information, with its reason. Facts about the project go in freely. Instructions on how to work go in only when they carry a lesson the reader couldn't easily find.
- **Q3 (a):** the reader reports everything it found, with its own confidence and severity. Any bar is applied afterward by a separate step, and the brief leaves room to report things outside the task. What the reviewer looks at is a separate problem, left to the review design.
- **Q5, in your words:**
  - In `safe`, a budget never shapes how work is done. It is only measured afterward.
  - In `eco` and Let It Rip, a budget enters a brief only after you've been asked how much it matters. In Let It Rip that covers wall-clock time as well as tokens.
  - When in doubt, leave the budget out.
  - If a writer thinks a budget matters but can't ask, it goes in as information.
  - A budget goes in as binding only if you approved it.

  I've saved this to memory.

## Round two

❓ **Q6 - One way to handle departures, replacing the current five.** These are the factory's current answers to "what does the reader do when a rule gets in the way of the job?":

1. **Say so loudly and get a sign-off first.** ([AGENTS.md:26](AGENTS.md:26), [template/AGENTS.md:20](template/AGENTS.md:20)) Nothing says how a subagent running unattended gets a sign-off, so for most readers it can't be used. It also clashes with "never block on the human; go ahead with anything reversible".
2. **Follow the rule anyway, then say why your instinct differed.** ([template/AGENTS.md:16](template/AGENTS.md:16)) This is the opposite default to 1: obey first, explain afterward.
3. **Make the call yourself and record it as a Provisional decision you can overrule.** (PHILOSOPHY, DECISIONS, the Ticket playbook) This only covers gaps where the spec says nothing, not a rule that fights the job.
4. **Skip a step, but leave a visible `skip: <reason>` line.** (poteto-mode, from upstream) It's switched off for delegation, where skipping is forbidden.
5. **Send the problem back up instead of working around it.**
   - A writer that can't build a test case as specified stops and reports it.
   - A writer's flagged risks must each end `fixed:` or `accepted: <reason>` before review runs.
   - A hole in a design gets a dated line added to the ticket.

So the same situation gets "stop and ask", "obey and explain", "decide and record" or "skip and note", depending on which file the reader happens to have read.

What I propose instead:
- **Advice (Q1).** The reader uses its own judgment. Its report always has a line that either says where it went another way and why, or says it didn't. That line is a fixed part of the report, because an optional "you may tell us" gets used about 4% of the time.
- **A binding rule that fights the job.** The reader stops that part, reports the clash to whoever owns the rule, and finishes the rest.
- **Never.** The reader never quietly shrinks the job to fit a rule.

Mechanism 3 stays as the way to fill a silent gap, because that's a different situation. Mechanism 5 is already this proposal in a few places. Mechanisms 1, 2 and 4 are replaced.

➡️ Adopt the proposal. One limit: the departure line only catches the choices the reader knows it made. When a brief steered the reader, models mentioned it only 25–39% of the time. Catching that kind of steering is the job of the ticket "Decide how we'll know the writing works".

---

❓ **Q7 - How binding rules are worded and enforced.** Two choices, one about wording and one about enforcement.
- **Wording.** A binding rule is stated plainly, with its reason and what to do instead, never in capitals or with "CRITICAL". The research says current Claude models over-apply emphatic rules, and that a bare "don't" leaves the reader landing on some other default.
- **Enforcement.** A rule held by a hook or a script is not restated in every brief. The hook's refusal message carries the reason and the way forward, and it arrives at the moment it matters. That's also when the research found reminders actually work. Today the prose repeats most hooks, and in places it puts hook limits on subagents the hook deliberately leaves alone, such as the 150-line reading cap.

➡️ Both, as stated. The brief names the hook in one line so the reader isn't surprised, and the refusal message does the rest.

---

❓ **Q8 - Where your two side notes go.** You asked before that your notes be saved somewhere you won't have to rediscover them.
- **Instruction load and terms that pull related ideas in.** Your micro-genre point: one well-chosen term may carry many rules at once, and only the exceptions need spelling out. This bears on every decision, and it's also an experiment: how many rules get followed, and whether a term really carries the rules it implies.
- **A review system of our own.** Review gets more than one pass, each with an open brief. It covers a wider range than bug-hunting, the way `interrogate` does, and it's measured on what it misses, not only on false positives.

➡️ I'll post your answers from this round on this ticket word for word, then:
- **Instruction load:** add a line to the map's Notes so every session considers it. Add the experiment to the ticket "Decide how we'll know the writing works".
- **Review system:** add it to the map's "Not yet specified" section for now. It's larger than writing and will probably become its own map once the brief templates exist. You may already have a ticket for it, in which case I'll link that instead.