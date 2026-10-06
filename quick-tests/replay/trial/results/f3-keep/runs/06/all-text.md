Yes, the research changes the questions. I've now read [the whole research note](https://github.com/Zenoctra/factory918/blob/research/wording-and-reader-context/docs/research/wording-and-reader-context.md). Four things changed:

1. **My first test for "binding" was too coarse.** I sorted rules by what they're about: the goal, what "done" means, and limits of authority were binding, and the route wasn't. But the research shows the goal and the definition of done can do the same harm as a limit on reading:
   - **Narrow instructions:** in a 2026 preprint (Shin), a narrow task instruction made models stop reporting critical findings they reported without it. A separate reviewer given an open brief got them all back.
   - **Reporting bars:** a bar on what to report makes reviewers hold back findings they already made. Radiologists did this (Berbaum 2015), and Anthropic sees the same in its own models: "only report high-severity" lowers recall even when the bugs were found.
   - **Our own case:** the run-2 `spec:` citation gate is one of these. A reviewer filed nothing on a PR with four real bugs.

   So the better line is between what the reader **does** and what it **notices and reports**.
2. **"Constraints" has been mixing two different things.** One is limiting what the reader may look for. The other is the writer holding back its own conclusions. The forensic evidence strongly supports the second (don't tell the analyst what you think the answer is). It says nothing in favor of the first.
3. **Route advice offered "as information" still pulls.** Known methods and examples anchor even when they're marked optional. Codex copied a sample function's lines into 32–61% of its solutions. Chess masters given a familiar mate kept looking at its squares while saying they were searching for something better. What's safer to hand over is facts about the ground the reader will cross, not suggested paths across it.
4. **One of your standing preferences pulls against the evidence.** Your Q9 preference is that briefs carry the full, unsummarized conversation. For a reviewer, that conversation contains the orchestrator's own verdict. Q3 is about that.

**About my own format.** Round one gave you lettered options. In the classic survey study, a list that explicitly invited "other" still took the four listed problems from 2% of answers to 60%. You have far more context than a subagent, so the pull on you is weaker, but it isn't zero. This round I give my recommendation and the main alternative I weighed, without menus. An answer outside both is what I most want to hear.

**How much weight this can bear.** Almost no study tests limits on method in models directly. What follows rests on human evidence, Anthropic's notes on an older Claude, one unreviewed preprint, and our own run-2 audits. Some figures came through a summarizing tool and haven't been checked against the papers. Q9 asks what to do about that.

Terms, as before: **the goal** is what's wanted and what done looks like. **The route** is how the reader gets there. **A binding rule** is one the reader may not overrule by itself. Two new ones:
- A **judging reader** is a subagent whose job is an independent verdict: a reviewer, a judge, a verifier.
- A **doing reader** is one that builds something.

---

❓ **Q1 - May a binding rule limit what the reader looks at or reports, or only what it does?**

The evidence for the line:
- **Attention:** an observer told what to count misses the gorilla, and in Shin's model study the task instruction decided what got reported.
- **Reporting:** a bar on what to report suppresses findings that were already made.
- **Incompleteness:** Garfinkel's point is that no instruction can contain the situation it will meet. Whatever the rule didn't foresee, the reader is the only one placed to notice it.

Where today's rules fall:
- **Kept:** "That is the scope; nothing wider is redesigned" ([ticket.md:45](template/.agents/skills/poteto-mode/playbooks/ticket.md:45)). It limits what the reader changes. The reader still reports the wider problem it saw, which the factory already says: "a finding outside its scope becomes a ticket."
- **Goes:** "Read only the diff" and "Read no brief and no diff" limit what the reader looks at.
- **Goes:** "Under 400 words", "stop after N" and "zero items is the expected result" limit what it reports.
- **Goes as a gate:** the `spec:` citation gate limits reporting too. In its place: say where a finding comes from if you know; a finding you can't cite still gets reported, and filtering happens in a separate step. That is the fix Anthropic recommends: ask for everything, with confidence and severity attached, and filter afterwards.
- **The hard case:** the delegation hook stops the main session from reading files under review. That limits looking. Its honest reason, though, is to keep the main session from forming its own verdict and leaking it into the review. That's the writer holding itself back (Q3), not a limit on the task.

The main alternative I weighed was my round-one test, sorting rules by subject. I'm dropping it because "done" and "scope" can carry reporting bars inside them.

➡️ A binding rule limits only what the reader does: what it changes, publishes, merges or spends. It never limits what the reader looks at, notices or reports. The one exception is a reader keeping itself blind to protect someone else's independent judgment, and only the owner of that judgment sets it.

---

❓ **Q2 - Who may make a rule binding?**

This is round one's Q4, plus the ownership half of round-one Q1, now with evidence behind it. Interrogators told to expect guilt asked guilt-presuming questions, and neutral listeners then heard the innocent suspects as defensive. An orchestrator's guess about where the bugs are is that kind of premise. Written as a rule, it decides what gets found. That's the reviewer failure, described as a mechanism rather than an anecdote.

➡️ Only whoever owns the authority. An orchestrator passes your rules and the ticket's down unchanged. It binds only what it owns itself, such as who is working in which files right now. Anything else it knows goes in as knowledge, on Q4's terms.

---

❓ **Q3 - What should the writer hold back, and from whom?**

This question is new. The evidence cuts both ways:
- **Holding back:** forensic science keeps irrelevant context and earlier conclusions away from the analyst. Fingerprint experts shown case context reversed their own past matches. Telling a model reviewer the code was bug-free dropped vulnerability detection from 97% to 4% for a small model, and from 96% to 89% for Claude Opus 4.5.
- **The influence doesn't show:** a model often uses a hint without its reasoning mentioning it. Reading the subagent's reasoning won't catch the lean.
- **Sharing:** across 16 studies of doctors reading medical tests, relevant clinical information improved accuracy and never hurt it.

The field's line runs between facts relevant to the task and conclusions, not between context and no context.

That meets your Q9 preference head on. You want the full, unsummarized conversation in the brief, orchestrator talk included. For a judging reader, the orchestrator's talk includes "this looks fine" and "I expect it's in X." The main alternative is to split by reader type: judging readers get no conclusions, doing readers get everything.

➡️ Split by fact versus conclusion, for every reader:
- **Facts** are what's decided or checkable: your words, the ticket, the diff, what the owner approved.
- **Conclusions** are the writer's untested beliefs: where it thinks the problem is, whether the change is safe, what it expects to be found.
- **Who gets what:** your words always go in whole, because they define the task. A judging reader gets no conclusions from the orchestrator about the thing it is judging. A doing reader may get one, labeled as the writer's guess, with its reason.

---

❓ **Q4 - How should knowledge about the route be handed over?**

This replaces round-one Q2. Expertise reversal: step-by-step guidance helps novices (d = 0.51) and hurts experts (d = −0.43). A fresh subagent is both at once: expert at the craft, new to the project. New readers gain from explicit links between facts, and they're hurt by being told the method. Suggested paths anchor (Einstellung; the copied sample code above). Current Claude also reads literally, so an illustration binds harder than the writer intended.

Today's rules, reread this way:
- **Rewritten as terrain:** [ticket.md:10](template/.agents/skills/poteto-mode/playbooks/ticket.md:10) gives a path ("read the tier in two plain commands") because of a fact (the guard refuses `git` inside `$(...)`). As terrain, it's just the fact, and the reader works out the rest.
- **Reason restored:** "Subagents never launch their own dev servers" lost Theo's reason when it was adopted. Restore the reason and state it as a fact.
- **Goes:** the 150-line reading cap in `knowledge` has no reason recorded anywhere. With no fact behind it, it goes.

The main alternative is round-one's (b): offer paths as suggestions, labeled optional.

➡️ Give facts about the terrain generously, each with its reason, and suggested paths almost never. When a lesson can only be passed on as a path, give the reason, say a different path is fine, and ask the reader to note in its report that it took one.

---

❓ **Q5 - Can a rule require a step, as opposed to forbidding one?**

This question is new, and the evidence goes both ways:
- **For:** the mandatory trail review caught owner errors three times out of three. In Shin's study, an added open-ended reviewer got back every finding the narrow one missed. A fixed handoff structure (I-PASS) cut medical errors 23%.
- **Against:** required method hurts capable readers. In run 1, nine of 77 delegated subagents changed an outcome, so a required step can be pure cost.
- **The trap:** a required element of the report can behave like a ceiling. "Cite a named smell" is a floor on the report that throws away every smell without a name.

The main alternative is to treat required steps like any route rule, skippable with a stated reason (poteto's `skip: <reason>`).

➡️ A required step binds when its owner set it and it adds an independent check or a point where you decide. It never prescribes how the main work gets done. A required element of the report gets tested against Q1: if it can make the reader leave a finding out, it's a ceiling and goes.

---

❓ **Q6 - What does the reader do when a binding rule fights the goal?**

This replaces round-one Q3. The factory currently has five answers, and they disagree:
- say so loudly and get sign-off first;
- follow the file, then explain;
- skip with a stated reason;
- decide and record a Provisional row;
- end each flag `accepted: <reason>`.

None of them says how a subagent gets sign-off.

The evidence:
- **Nobody asks unprompted.** People asked for help on 4% of the occasions it was offered, and current models almost never ask on underspecified coding tasks.
- **Wording moves it.** Telling people checking was *essential* rather than *available* took how often they checked from 23% to 81%.
- **Narrowing is invisible.** A reader that quietly narrows the goal leaves no trace in its reasoning (the hint findings again), so the report has to say it.
- **Asking beats pushing.** Letting the less-informed agent ask beat pushing more instructions at it.

The main alternative: break the rule and report it.

➡️ One mechanism replaces all five:
- The reader never narrows the goal to fit a rule. It sets the blocked part aside and does the rest.
- Every report has a standing section listing what it didn't do and which rule stopped it. The section is always there, reading "none" when nothing was blocked, so it reads as expected rather than optional.
- The conflict goes to the rule's owner. A subagent sends it to whoever briefed it, which answers if it owns the rule or passes it up.

Whether every brief should also ask the reader to restate the goal first, as I-PASS does, is a template question. I'd pass it to the template prototype ticket.

---

❓ **Q7 - Can a budget limit the route?**

This replaces round-one Q5, and the research weakens my earlier recommendation. I said to state the budget as a fact and let the reader plan within it. But a number in a brief becomes the target:
- **Surrogation:** people treat the measure as the goal, even when nothing is paid for hitting it.
- **Anchoring:** stronger models anchored more consistently, and neither chain of thought nor "ignore this" removed it.
- **Length budgets:** tight output budgets cut the scores of reasoning models sharply.

The main alternative is my old answer.

➡️ Budgets live in the structure, not the reader's brief. The orchestrator chooses how many subagents and how much effort; the harness enforces hard stops. When a reader genuinely needs to know (time really is short, or a service costs money), the brief states the situation and why, with no number for the output to aim at. A budget you set binds what the reader does (how many runs, which paid service), never what it looks at or how long its report is.

---

❓ **Q8 - How is a binding rule worded?**

This question is new.
- **Emphasis backfires:** Anthropic reports that emphatic wording ("CRITICAL", "MUST") makes recent Claude models over-apply an instruction, and that a stated reason lets the model generalize correctly.
- **Prohibitions leave a gap:** a prohibition keeps the forbidden idea active and doesn't say what to do instead, so the model lands on some other fixed default.
- **Control versus information:** people given the same limit as a controlling order were less creative than people given it as information.

The factory already has a good example: the git guard's block message names a way forward ("Use --force-with-lease on your own branch, or ask"). The main alternative is to leave wording to the general writing-standard ticket.

➡️ Decide it here for binding rules only: plain words, the reason, and what to do instead, with a hook holding the rule wherever breaking it would really hurt, so the prose can explain instead of shout. All other wording stays with the writing-standard ticket.

---

❓ **Q9 - Decide now, or wait until it's measured?**

No study tests a limit on method in models, and the vendor's notes cover Opus 4.8, not the 5.5 the factory runs. But run 2 measured the cost of the current limits in this repository:
- four of 13 labeled bugs sat in files the brief told the reviewer not to open;
- the `spec:` gate filed nothing on four real bugs.

The main alternative is to treat this ticket as provisional until the "how we'll know" ticket has numbers.

➡️ Decide now, and record each decision as open to revision. Hand the "how we'll know" ticket two experiments that nobody has run:
- the same open task, with and without an illustrative list, counting what's found outside the list;
- the same review, with and without a reading limit, counting the real bugs found.

Waiting leaves the measured harm in place.

---

How round one maps onto this one:

| Round one | This round |
|---|---|
| Q1 (what makes a rule binding) | Q1, plus the ownership half of Q2 |
| Q2 (route knowledge) | Q4 |
| Q3 (when a rule fights the goal) | Q6 |
| Q4 (who may bind) | Q2 |
| Q5 (budgets) | Q7 |

Q3, Q5, Q8 and Q9 are new. My memory still holds the old "protect the world" test, and I'll rewrite it once this settles.