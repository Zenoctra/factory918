I'll read the research itself now, rather than relying on the background search's two-line summary of it.

---

Yes, the questions change. After reading the whole research note, three of my round-one answers were wrong in ways that matter, two more now have evidence behind them, and I'm adding two questions. The note is `docs/research/wording-and-reader-context.md` on the branch `research/wording-and-reader-context`, and the § numbers below are its sections.

**What changed:**
- **Q1:** I counted "what done means" as safe. Most of the measured harm is right there.
- **Q2:** I said to offer route knowledge "as knowledge, not an order." Current Claude models read literally, and a method pulls the reader even when it's only offered. The line that holds up is between facts about the world and the steps the writer would take.
- **Q3:** It assumed the reader notices when a rule fights the goal. Mostly it doesn't.

**What the research can't settle.** No study on models tests a limit on method directly. The model results cover reporting bars, output formats, length budgets and framing (§4, §13). Anthropic's notes cover Opus 4.8, not 5.5. Most of the weight rests on human studies and our own audits. Q7 asks what to do about that.

The terms from round one still apply: the goal, the route, a binding rule. The cases under each question test the proposed answer. They aren't the edge of what it covers.

---

❓ **Q1 - What makes a rule binding?** In round one, "what done means" was on the binding side. The research says that's where the best-measured harm sits:
- **Radiologists:** given an extra abnormality to find, they didn't search worse. They raised their bar for reporting (§4).
- **Claude:** Anthropic reports the same thing. "Only report high-severity issues" lowers recall even though the model found the bugs.
- **Measures:** a measure tends to replace the goal it stands for. Merely knowing they were measured was enough to shift managers' behavior, with no pay attached (§4).
- **Commander's intent:** in the one test of commander's intent, intent statements written in practice were full of method. Only 34% of subordinates' actions matched the intent (§4).
- **The goal itself:** in a 2026 preprint, a narrow task instruction stopped models reporting critical findings they reported otherwise. An open-ended critic recovered every one (§4; one author, not peer reviewed).

The proposed rule: a rule binds in two cases.
1. It is part of what's wanted, including properties of the result such as independence, or it marks whose decision something is.
2. You set it, with a stated reason.

A "done" criterion never binds on its own. It's evidence about the goal, and when the two disagree, the goal wins. That was your ruling on P109.

How the cases come out:
- **"Later review rounds don't see earlier findings."** This limits what the reader may look at, yet it binds, because independence is the product. Forensic labs do the same.
- **The `spec:` citation gate.** It's a "done" criterion that filtered real bugs out, so it doesn't bind.
- **"Never push to main."** It binds because merging is your decision.
- **The delegation rule.** It binds on both counts: you set it, and its stated reason is review separation ([feature.md:12](template/.agents/skills/poteto-mode/playbooks/feature.md:12)), which is a property of the result.
- **The mandatory trail review.** This is pure route. It binds only because you set it with a measured reason.

The options:
- (a) Only the first case binds. The route is always the reader's, even for your rules.
- (b) Both cases bind, as proposed.
- (c) Every rule is argued case by case.

➡️ (b). Under (a), the trail review would stop binding. It's a route rule we have measured evidence for. The research also finds that a fixed method helps on simple tasks (§4). That fits a fixed check in a pipeline better than a rule on how a subagent does its own work.

---

❓ **Q2 - What may the writing say about the route?** Advising instead of ordering isn't enough, for two reasons:
- **Literal reading:** current Claude models read instructions literally and over-apply them (§4, §11), so advice reads as an order.
- **Anchoring:** a familiar method blocks a better one even when it's only offered. Chess masters shown a familiar mate kept looking at it while they said they were searching for something shorter. Codex copied a related function it had been shown into 32–61% of its solutions (§2).

What does help a reader is context. A subagent knows little about the project but is highly skilled. Explicit context helps readers who lack background (§9). Step-by-step guidance helps beginners and hurts skilled readers (§4).

The proposed rule: state facts about the world the reader can't see, and what follows from them. Leave the steps to the reader. For example, write "the worktree guard refuses `git` inside `$(...)`" instead of "read the tier in two plain commands" ([ticket.md:10](template/.agents/skills/poteto-mode/playbooks/ticket.md:10)). Write a method only where the task is closed, meaning only one way works, and give the reason with it.

The options:
- (a) Say nothing about the route.
- (b) Give facts, not steps, as proposed.
- (c) Give route knowledge as advice the reader may ignore. This was my round-one answer.

➡️ (b). (c) assumed the reader would treat advice as optional. (a) leaves out context, which is what a reader who knows little about the project needs most.

---

❓ **Q3 - How do conflicts between a rule and the goal come to light?** The evidence that readers don't notice:
- People told they could ask for help asked on 4% of the chances (§8).
- Claude 3.7 Sonnet used a hint planted in the question and mentioned it 25% of the time (§3).

Wording helps. Readers told that checking definitions was *essential* checked on 81% of questions. Told it was *available*, they checked on 23% (§8).

The proposed answer has three parts:
1. **When the reader notices the conflict,** it stops that part, reports the conflict to the rule's owner, and carries on with the rest. It never shrinks the goal to fit the rule.
2. **When it doesn't notice,** the report still asks what any rule in the brief stopped it from doing or reporting. The question is worded as required, not available.
3. **Filtering moves to the receiver.** The reader reports everything it found, with confidence and severity, and whoever receives the report applies any bar. This is the vendor's own advice for reviewers (§4).

This would replace the five ways a reader can depart from a rule today, which disagree with each other: sign-off, follow-then-explain, `skip:`, Provisional, and `accepted:`.

The options:
- (a) Part 1 only.
- (b) Parts 1 and 2.
- (c) All three.

➡️ (c). The required question won't catch everything: what the chess players said didn't match where they looked (§2). Moving the filter removes the best-measured harm where it starts. Where the question and the filter live belongs to the ticket "Decide where each piece lives and when it reaches the writer".

---

❓ **Q4 - Who may write a binding rule into a brief?** My answer is the same as round one, now with evidence behind it. The orchestrator:
- passes down your rules, AGENTS.md and the ticket;
- binds what it owns itself;
- gives everything else as facts, under Q2.

It never turns its own guess about the route into a rule. The research shows the mechanism. Interrogators who expected guilt asked questions that presumed guilt, and the answers confirmed it (§3). Commanders' intent statements filled up with method (§4). An orchestrator's guess about where the bugs are is its hypothesis. A rule built from that guess carries the hypothesis into the reader's work.

This doesn't stop the writer holding back its own conclusions. Forensic labs keep analysts blind to earlier conclusions, while context that bears on the task improves accuracy (§3). That restraint applies to the writer, not to the reader, so it belongs in the ticket "Decide what the writing standard is and what carries it". I mention it so that "never bound the route" isn't read as "tell the reader everything you believe."

➡️ As above.

---

❓ **Q5 - Can a budget limit the route?**
- **Models:** tight output budgets cut reasoning models sharply. One model fell from 72% to 54% at a 1,024-token budget (§4).
- **People:** the same limit cost creativity when it was worded as control, but not when it was worded as information (§4). Nobody has tested whether models react the same way.

➡️ Unchanged. A budget is stated as a fact the reader plans within, and it binds only when you set it. The efficiency map revisits this once it has measurements.

---

❓ **Q6 - How is a binding rule worded?** (new) The research says:
- Current Claude models over-apply emphatic wording (§4).
- A bare "never X" keeps X in mind and gives no alternative, so the reader lands on some other default. This was measured mostly in older models (§5).
- Text repeated everywhere is read past as boilerplate (§1).
- People follow a rule better, and more flexibly, when it comes with its reason (§4, §9).

The proposed rule:
- plain words, no emphasis;
- the reason attached;
- stated once, where it applies;
- written as what to do, with "never" only alongside that.

A rule that must hold no matter what is held by a hook or a script. The prose says the hook exists and names the way forward, the way the git guard's message does now.

➡️ As proposed.

---

❓ **Q7 - Act on this now, or wait for measurement?** (new) For this ticket, the strongest evidence on models is one preprint and Anthropic's notes on an older model. The factory can run the missing tests itself:
- the same open-ended task with and without a list of examples, counting what each finds outside the list;
- a review with the reporting bar applied by the reviewer, and one with the reviewer reporting everything for the receiver to filter.

The options:
- (a) Settle the direction now, and hand those tests to "Decide how we'll know the writing works" as its first cases.
- (b) Record the answer as Provisional until the tests run.

➡️ (a). The human evidence is enough to act on, and so are our own audits: 79 of 108 versioned templates carried limits, and one reviewer filed nothing on a PR that had four real bugs. The tests can still overturn the decision.