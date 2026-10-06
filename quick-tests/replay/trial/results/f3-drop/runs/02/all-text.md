Yes, the research changes the round. Three of my five recommendations move. The first was wrong, and the round left out two cases the research raises. Most of what follows comes from §4 and §12 of [the research note](https://github.com/Zenoctra/factory918/blob/research/wording-and-reader-context/docs/research/wording-and-reader-context.md).

## What changed

- **My Q1 test treated "what done means" as safe. That is where the research's best-measured harm is.**
  - Radiologists who find one abnormality hold back from reporting the next one they see.
  - Anthropic's notes on Opus 4.8 say "only report high-severity issues" makes the model find the bugs and then leave them out of its report.
  - A 2026 preprint found that a narrow task instruction made models leave out critical findings they would otherwise report.
  - Your constraints audit found the same thing here: the `spec:` gate made a reviewer file nothing on a PR that had four real bugs.

  Your sentence covers how a task is "pursued **or completed**". My test sorted rules into two bins by topic, just as the old one did, and put one of the worst kinds in the safe bin.

- **My Q2 relied on soft wording to free the reader, and a model reader barely registers the softness.** Current Claude models read literally, push emphatic instructions too far, defer to the asker, and almost never ask questions. In people, a definition marked "available" was used 23% of the time and one marked "essential" 81%. So advice that says "you may depart" tends to be either followed or ignored, not weighed. More of the weight falls on what the writer leaves out.

- **My Q3 assumed the reader would notice when a rule fights the goal.** People who misread a question rarely know they did. Models often act on a hint without mentioning it. A way out that the reader has to think of by itself will rarely get used.

- **The research supports one kind of withholding.** Experts shown someone else's conclusion change their own. That makes blind review a case the test has to handle, and my round never mentioned it.

- **It also says where a set method helps:** on simple tasks, and for readers new to the work. A subagent is capable but starts knowing nothing about the project, so the test has to sort that mix.

Two cautions on how much weight this carries:

- Almost no study tested a limit on a model's *strategy*. The measured cases are reporting bars, output formats, length budgets and framing, mostly on 2022–2025 models.
- The closest direct test we have is our own reviewer eval from run 2: 4 of 13 labelled bugs were in files the brief told the reviewer not to open.

## A note on the round's format

The grilling format hands you a list of options. A list bounds the answer even when it has an "other" slot: in one study, four listed problems went from 2% of open answers to 60% of closed ones. So where a question is open, I ask it openly and give my reading.

---

## Round one, revised

**The goal** is what's wanted and why. **The route** is how the reader gets there and finishes: what it reads, runs and tries, in what order, when it stops, and what it reports. **A binding rule** is one the reader may not overrule on its own.

❓ **Q1 - What makes a rule about the route binding?**

Garfinkel and Suchman argue that no instruction written in advance can cover the situation it will meet. The reader always fills the gaps, and the only question is whether the text helps it fill them well. That points to a test based on knowledge, not on what the rule is about: **when the decision is made, who knows more?** The writer, who wrote in advance, or the reader, who is in the situation?

A rule earns its place when it carries something the reader can't know at that point:

- **Authority the reader doesn't hold.** You merge.
- **A fact the reader can't see from where it stands.** For example, which files another subagent is writing right now.
- **Something about the reader that it can't see in itself, backed by evidence.** For example, a reader shown someone else's conclusion leans toward it without noticing.

A rule fails the test when the reader will know more than the writer did: where the bugs are, which files matter, how many findings there are, when it's done looking. Your point about leaving room for what can't be predicted is the same test from the other side.

Two conditions guard against the writer, because writers overestimate what they know about their reader:

- **Only whoever owns the authority or the fact can make the rule binding.** An orchestrator can't turn its guess about the route into a rule. This was my old Q4.
- **The rule travels with the knowledge behind it.** That lets the reader recognize a situation the knowledge doesn't cover. Survey research found that fixed wording fails on unusual cases: people answered unusual cases correctly 28% of the time with scripted questions and 87% when the interviewer could explain what the question meant. The field's fix was to hold the meaning fixed and let the words vary.

Cases to test it against:

- **"Read only the diff."** It fails, because the reviewer will know more than the writer about where the diff reaches.
- **"Only high-severity," "stop after N," and the `spec:` gate.** These fail too. The reviewer knows what it found, and any filtering can happen afterwards with everything visible.
- **Blind review: a later round may not look up the earlier round's findings.** This passes on the third kind of knowledge. It's the hardest case, because it limits what the reader may go looking for, not just what the writer chooses to say.
- **The delegation rule.** It passes on ownership and evidence: the ledger records an orchestrator breaking it while knowing the rule.
- **The mandatory trail review.** It passes the same way: it caught the owner's errors in three of three runs.
- **"Quote every path; paths contain spaces."** This is really a fact, and the reader works out the behavior. Many of our rules may be facts dressed as rules.
- **"Read the tier with two plain commands, because the guard refuses `$(...)`."** This passes. The writer can see the whole situation in advance, which is the one place the research says a set method helps.

➡️ I'd adopt this test. Please try to break it with a case I haven't thought of; I expect one exists.

---

❓ **Q2 - How is "done" written?** This is the completion half of your sentence.

- The vendor's advice for reviewers is to ask for every finding with a confidence and a severity, then filter in a separate step.
- In the preprint, a second reviewer with an open brief recovered every finding the narrowly briefed one left out.
- Budgets belong here too. Reasoning models dropped sharply under tight length limits. People judged on a single number start treating that number as the goal.

➡️ Write "done" as the purpose the work serves, never as a bar, a count or a length. Any filtering or ranking happens in a later step that sees all the findings. If you set a budget, the brief states it as a fact the reader plans around, and the reader reports what it left undone because of it.

---

❓ **Q3 - What may a writer say about the route, if not a rule?** On Q1 you described leaving the door open for a model to overrule rules that aren't strictly needed. The research says that door exists but is rarely used: a literal, deferring reader treats almost any advice about the route as a rule, and examples get copied into the work. On the other hand, a subagent knows little about the project however capable it is, and readers without background do better when connections are spelled out.

➡️ Give the reader facts about the situation instead of a method: what's true about the repository and the tools, what has been tried, and what happened. The reader builds its own route from those. Where the writer has reached a conclusion of its own, such as where it thinks the bug is, it leaves that out of any reviewer's or judge's brief. Context relevant to the task helps the reader; a stated conclusion pulls it.

---

❓ **Q4 - What does the reader report about its route?** Readers rarely notice that they misread something, so I'd make an account of the route part of every report, not something added only when there's a problem.

- A hospital handoff template whose last step has the receiver restate the plan cut medical errors by 23% across nine hospitals. It came bundled with training, so the template's own share of the effect is unknown.
- In Shattuck's study, junior commanders' actions matched their commander's stated intent about a third of the time. Stating the goal doesn't carry it on its own.
- The risk is that a section repeated in every report becomes boilerplate filled in without thought.

➡️ Every report says, in the reader's own words:

- what it took the goal to be;
- the route it took, and where it departed from anything it was told;
- what it noticed outside its task.

The orchestrator then checks the first part against the goal it meant. Keeping this section from going stale is a job for the brief-templates ticket.

---

❓ **Q5 - What happens when a binding rule fights the goal?** The factory gives five answers today, and they disagree:

- say so and get a sign-off first ([AGENTS.md:26](AGENTS.md:26));
- follow the file, then explain ([template/AGENTS.md:16](template/AGENTS.md:16));
- mark a skipped step with `skip:` and a reason;
- make the call and record a Provisional decision you can overrule;
- end a writer's flag with `accepted: <reason>`.

No text says how an unattended subagent would get a sign-off.

➡️ Replace all five with one answer. The reader stops that part, reports the conflict to whoever owns the rule, and carries on with the rest. It never shrinks the goal to fit the rule. Deciding which existing mechanisms get rewritten belongs to the ticket "Decide the scope and order of reworking existing files".