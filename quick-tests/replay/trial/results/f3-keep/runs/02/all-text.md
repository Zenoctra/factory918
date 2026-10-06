Yes, the research changes the round. It doesn't reverse the direction, but it breaks one recommendation, adds a question I hadn't asked, and weakens one safety mechanism I was relying on.

**What changed**

1. **My Q1 test made the same mistake you corrected.** I sorted rules by what they're about: the task (what's wanted, what "done" means) was allowed to bind, and the route was not. The research breaks that line in two places.
   - **The goal itself bounds what gets seen.** In the gorilla study, what observers were told to count decided whether they saw the gorilla. One 2026 preprint (Shin) found the same in models: a narrow task instruction stopped them reporting critical findings they reported otherwise. A separate critic with an open brief recovered every one.
   - **"What done means" can be a cap.** Radiologists given a reporting bar still find the second abnormality; they just don't report it. Anthropic says the same about Opus 4.8: "only report high-severity issues" lowers recall while bug-finding ability stays the same. Our `spec:` gate did exactly this on PR 99.

   Two more findings explain why: readers treat every part of a request as deliberate, and current Claude models read instructions literally. So everything the writer writes bounds the reader, and a test that sorts rules by content will always leak. I tried other content sorts on the factory's own cases, such as floors ("do at least this") against ceilings ("no more than this"). Each one broke. The delegation rule is a ceiling that did good, and some mandatory lanes are floors that were pure waste.

2. **There is now a reason behind your point, not just a preference.** Garfinkel and Suchman argue that no instruction can contain the situation it will meet; plans are resources for action, not specifications of it. That backs your "leave it open for something you CAN'T predict." It also moves the question. Since every rule will meet a case it didn't foresee, the question becomes what the text gives the reader for that case. The evidence answers "the reason". Rules stated as information, with their rationale, were taken up better than the same rules stated as control, and Anthropic says its models generalize from the reason.

3. **The reader's report can't catch everything.** In round one, the reader saying "I departed, and why" was my safety valve. But readers rarely notice they've misread something, and rarely ask: people asked on 4% of the occasions help was offered, and current models almost never ask. A hint in a brief can move a model's answer without its reasoning ever mentioning the hint (Claude 3.7 mentioned one only 25% of the time). So most of the weight falls on the writer, not on the reader's honesty afterwards.

**How far to trust it.** No study tests a limit on a model's *strategy* directly. The recommendations below rest on human evidence, a few single model studies, and vendor notes without published numbers. The research note was also written by Opus 5.5, the model being studied. Where a recommendation leans on something thin, I say so.

Terms, carried over from round one: **the goal** is what's wanted; **the route** is how the reader gets there; **binding** means the reader may not overrule it alone. One new term: **a bound** is anything in the text that limits how the task is pursued or completed, whether it's written as a rule or not.

---

❓ **Q1 - What makes a bound legitimate?** Since the content of a rule can't decide this, the options are:
- (a) Keep a content test, repaired: goal and done are binding, the route never is.
- (b) Authority and reason. A bound is binding only when whoever owns that decision set it (you for merging, the ticket for scope, the orchestrator for which files other subagents hold right now), and it carries its reason so the reader can recognize a case the rule didn't foresee. Everything else is knowledge the reader may act against, saying so.
- (c) Nothing is binding except what a hook enforces; all prose is knowledge.

Cases to test it against:
- **The git guard:** you own merging, and the reason is stated. Binding under (b). Its hook even names a way forward ("use --force-with-lease, or ask").
- **The mandatory trail review:** you set it, with evidence (it caught the owner's errors three times out of three). Binding under (b), though it bounds the route.
- **The `knowledge` skill's 150-line reading cap:** no owner on record, no reason. Under (b) it stops binding and either gets a reason or goes.
- **"Read no brief and no diff while the review state exists"** ([ticket.md:13](template/.agents/skills/poteto-mode/playbooks/ticket.md:13)): written for subagents that the hook deliberately exempts, with no reason given. Under (b) it doesn't bind them.

➡️ (b). It's the only option where every factory rule that did good survives and every one the audits condemned doesn't. (c) is tempting, but a hook can only check what's mechanical, and some of your binding rules aren't.

---

❓ **Q2 - How do the goal and "done" avoid capping completion?** This question is new. The goal's wording is itself a bound, and a bar on what gets reported makes the reader withhold work it already did. The options:
- (a) Write the goal as the outcome wanted and why it's wanted, and give every report a standing place for what the reader noticed outside the goal.
- (b) Never ask the finder to filter. The finder reports everything it found, with its confidence and severity; a separate step owned by someone else decides what to keep. This is what Anthropic recommends.
- (c) Leave it to the writing standard as general advice.

Cases:
- **The Standards reviewer** couldn't file a real bug as hard because the brief required a `spec:` citation from a ticket it never saw.
- **"At most N lanes" in P109** was a prediction that turned into a target. Management research calls this surrogation: the measure replaces the goal, even when nobody is paid on it.

➡️ (a) and (b) together. Scope: how to word a goal in general belongs to the standard ticket ("Decide what the writing standard is and what carries it"). This ticket decides only the part where the goal or "done" caps completion.

---

❓ **Q3 - What may the writer say about the route?** (This was Q2.) The research splits route knowledge into two kinds:
- **Facts about the world the reader couldn't easily find:** the guard refuses `$(...)`; paths contain spaces; a trap that cost a run.
- **The writer's beliefs about the answer:** where the bugs probably are, what it expects to find.

The forensic evidence supports giving the first and holding back the second. Clinical context improved how accurately tests were read, while someone else's conclusion biased experts, including against their own earlier decisions. Another finding sharpens this: step-by-step guidance helps novices and hurts experts. A subagent is an expert at method and a novice at this project, so it gains from project facts and loses from method steps.

The counterweight is your own: lists and steps are fine where the task really is closed. The research agrees that specific method helps on simple tasks. The catch is that "this task is closed" is the writer's judgment, and writers misjudge what the reader needs.

The options:
- (a) Facts with reasons go in. Beliefs about the answer stay out. Steps are written as "the known way, and why", which the reader may depart from.
- (b) Everything goes in, marked as knowledge.
- (c) Nothing about the route goes in.

➡️ (a). One sub-case where I'm less sure: a subagent that *does* work rather than judges it, like a bug-fix lane. There, the orchestrator's hypothesis ("I suspect `parse()`") can save real time. I'd allow it for doing lanes only, written as a hypothesis with its evidence, never as "look here". For judging lanes, it never goes in.

---

❓ **Q4 - Who may make a bound binding?** (Unchanged in substance from round one.) May an orchestrator invent binding route rules from its own judgment? The evidence has grown:
- The audit found the review-brief limits were added by subagents to save cost; nobody asked for them. One cost fix grew into "read nothing, run nothing".
- A subagent once turned your question into a rule on a ticket ([ledger.md:19](docs/agents/ledger.md:19)).
- In people, the premise in an interrogator's briefing shaped the questions, the answers, and how bystanders judged the answers.
- In the one test of US Army commander's intent, writers stuffed method into intent statements meant to leave method open.

➡️ No. The orchestrator passes down binding rules from their owners, binds only what it owns itself, and offers everything else as knowledge under Q3.

---

❓ **Q5 - What does the reader do when a binding rule meets a case it didn't foresee?** (This was Q3.) The factory has five departure mechanisms today, and they conflict. The research adds:
- Claude reads literally and won't infer a door that isn't written.
- In one survey study, telling people that checking definitions was *essential* got 81% to check, against 23% when told it was *available*.
- A line repeated in every brief gets read past as boilerplate. So a blanket "these are defaults, not hard rules" line, like the one at [template/AGENTS.md:20](template/AGENTS.md:20), may do nothing.
- Assigned dissent was weaker than genuine dissent. An open invitation to depart risks departures made for show.

The options:
- (a) One blanket line, as now.
- (b) Each bound is marked where it's written: binding, with its owner and reason, or knowledge. Every report has a standing field: "where a rule fought the goal, and what I did". At a binding rule, the reader stops that part, reports to the rule's owner, and carries on with the rest. It never shrinks the goal to fit the rule.
- (c) The reader breaks the rule and reports it.

➡️ (b). Replacing the five mechanisms touches upstream pstack text (`skip: <reason>`), which can only change through a patch. That's for the rework ticket, "Decide the scope and order of reworking existing files". This ticket only decides what replaces them.

---

❓ **Q6 - Can a budget bound the route?** (This was Q5.) The evidence against caps has grown: under tight output budgets, reasoning models fell sharply (one went from 72% to 53%), and reporting bars lower recall as above.

The options:
- (a) A budget is stated as a fact with its reason, and the reader plans its own route within it.
- (b) A budget you set is binding (by Q1).
- (c) No budgets in the writing.

Under both (a) and (b), a cap on the number of findings or on report length never goes to a finder. Shortening happens afterwards, in the separate step from Q2.

➡️ (a) by default, (b) when you set the budget yourself. The efficiency map, "Optimize token use and wall-clock time without losing reliability", can revisit this with measurements.

---

There's one experiment no study has run that would test Q3 and the list problem directly: give subagents the same open-ended task with and without an illustrative list, and count what each finds outside it. That belongs to "Decide how we'll know the writing works". If it shows no loss, Q3 could loosen later.

The housekeeping is unchanged: once you've answered, I'll rewrite my memory note that still states the old "protect the world" test.