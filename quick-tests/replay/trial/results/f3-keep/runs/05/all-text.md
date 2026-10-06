Yes, the questions change. I've now read the research note ([wording-and-reader-context.md](https://github.com/Zenoctra/factory918/blob/research/wording-and-reader-context/docs/research/wording-and-reader-context.md)). It moves the questions in three places:

1. **Round one treated "what done means" as safe.** The research finds the strongest narrowing exactly there: in reporting bars, narrow task statements and over-specific goals. The line I drew between the goal and the route doesn't hold on its own.
2. **Round one blurred two different things.** One is what the writer holds back, such as its own conclusions. The other is what the reader is allowed to go looking for. Holding back conclusions protects the reader; limiting what it may look for narrows it.
3. **Round one's override answer assumed the reader would notice a conflict and speak up.** Readers rarely notice their own misreadings and rarely ask, even when invited. That holds for people and for models. An override path that is only *available* mostly goes unused.

Round one also did what this ticket is about. It offered closed option lists, and Q1 carried a list of examples. I've kept a recommendation per question because the grilling format asks for one. Read my options as where my thinking went, not as the full range of answers.

Most of the evidence on limits to *method* comes from people. No model study tests a limit on strategy itself, and none tested Opus 5.5. I've marked where an answer rests on inference rather than measurement.

**Terms:**
- **The goal:** what's wanted and what it's for.
- **The route:** how the reader gets there.
- **A bound:** anything in a text that narrows how the reader pursues or completes the task, whatever form it takes.
- **Binding:** a bound the reader may not lift on its own.

---

❓ **Q1 - What counts as a bound?** Round one asked about rules. The research finds the strongest narrowing in text that doesn't read as a rule:

- **A bar for what to report.** Radiologists shown an extra nodule kept searching as before, but became reluctant to report what they found (Berbaum 2015). Anthropic says the same of Opus 4.8: "only report high-severity issues" makes the model find bugs and then leave them out, so recall falls.
- **What the reader is told to look at.** In a 2026 preprint (Shin, not peer reviewed), a narrow task instruction stopped models reporting critical findings they reported otherwise. A separate critic with an open brief recovered every one.
- **How specific the goal is.** On a complex problem, people given a specific goal closed in on it step by step and learned little about the problem. People without one explored and learned its structure (Vollmeyer 1996).
- **Examples.** Four listed problems went from 2% of answers to 60%, even with an invitation to name another (Schuman & Scott 1987).

Those are the cases the studies happened to measure, not the full set. The vendor also says current Claude models read instructions literally, so an illustration binds about as hard as a rule.

The factory case is the `spec:` citation gate at [review-brief.sh:494](template/.agents/skills/spec-review/scripts/review-brief.sh:494). It looks like a report-format rule, and the run-2 audit kept it as one. Sol obeyed it and filed nothing on PR 99, which had four real bugs.

Should this ticket cover anything that narrows how the task is pursued or completed, judged by its effect on the reader? Or only text written as an explicit rule?

➡️ Judge by effect. Your correction already says "pursued **or completed**", and the completion side is where round one had its gap.

---

❓ **Q2 - Who may make a bound binding, and what must a binding bound carry?** Round one's answer still stands: only the owner of a decision can make a bound binding. You own merging, a subagent owns its files, the ticket owns its scope. An orchestrator passes its owners' rules down and binds only what it owns. Everything else it knows goes under Q4. The research says nothing about ownership, but three findings bear on it:

- **No instruction is complete** (Garfinkel 1967). Suchman (1987) calls plans "resources for action, not specifications". Every binding rule, yours included, will meet a case its writer didn't foresee.
- **A stated measure gets treated as the goal**, without the person noticing (surrogation; Black 2022). Your P109 ruling that an "at most" list was "a prediction, not a constraint" is this effect.
- **Rules given with their reasons are taken on better** (Deci 1994). The vendor says Claude generalizes from the reason rather than the rule.

The factory has evidence on the other side too. The mandatory trail review caught the owner's errors 3 of 3 times, and the delegation rule held only once a hook enforced it. Owner rules with evidence behind them earn their place.

➡️ Keep ownership as the test, and require every binding rule to carry its reason. The reason lets the reader see when the rule fights the goal it was written to serve. A rule a hook enforces carries its reason in the hook's message, as the git guard already does.

---

❓ **Q3 - How is "done" written?** This is new. The findings in Q1 point one way: a bar, a cap or a narrow definition of done, placed in the finder's own brief, cuts what reaches the page while the finder's ability stays the same. Tight length budgets also cut reasoning models' accuracy sharply (Sun 2025). The vendor's fix is to ask for every finding with a confidence and severity, then filter in a separate step. The counterweight is that a specific goal does help on simple, closed tasks (Winters & Latham 1996).

- (a) Write done as the purpose and what the result will be used for. Every filter (severity, count, citation, length) moves to a separate step after the reader has reported everything.
- (b) Keep filters in the reader's brief, each with its reason.

➡️ (a) for open-ended work. A precise done stays only where the task really is closed, and the writer says why it is. This also answers round one's question about budgets: a budget is a fact the reader plans within, and a cap needed for cost goes on the downstream step, never on the finder.

---

❓ **Q4 - How does the writer pass on what it knows about the route?** Round one said: as knowledge with the reason, never as an order. The research splits that in two:

- **A lane is skilled, but it starts cold on the project.** For the project, that makes it a low-knowledge reader. Explicit links and context help low-knowledge readers (McNamara 1996).
- **Step-by-step method hurts capable readers.** This is the expertise reversal effect. A meta-analysis of 60 studies found it helps novices (d = 0.51) and hurts experts (d = −0.43).
- **A known method blocks a better one, even when it is only offered** (Bilalić 2008). Codex given a related function copied its lines into 32–61% of solutions (Jones & Steinhardt 2022).

So the line falls between **terrain** (facts about the situation: how a tool behaves, where a trap is, where things live) and **method** (what to do, and in what order). [ticket.md:10](template/.agents/skills/poteto-mode/playbooks/ticket.md:10) shows the difference. The terrain fact is that the worktree guard refuses `git` inside `$(...)`. "Read the tier in two plain commands" is a method derived from that fact. Given the fact alone, a reader finds its own way.

➡️ Give terrain facts generously, each with its reason. Leave method out unless the writer has evidence that the task is simple or that the method is the only safe one. Even then, word it as information rather than control: the same limits worded as control lowered creativity, and worded as information did not (Koestner 1984).

---

❓ **Q5 - What does the writer hold back?** This is new, and it is not a bound on the reader. It is a limit on what the writer says. The writer's conclusion leaks into the answer:
- Told the code was bug-free, Claude Opus 4.5's detection fell from 96% to 89%, and a smaller model's from 97% to 4% (Alexopoulos 2026).
- Fingerprint experts reversed their own earlier conclusions when given biasing context (Dror 2006).

Withholding relevant facts isn't free either. Across 16 studies, giving readers the clinical information improved how accurately they read medical tests, and none got worse (Loy & Irwig 2004). The forensic line is to withhold the conclusion and give the task-relevant facts.

The run-2 audit and my memory treated these two as one. "Read nothing beyond this brief" limited the reader. "Zero items is the expected result" was the writer volunteering its expectation.

➡️ Treat them separately. The writer holds back its own conclusions, hopes and expected counts, and, in a blind round, the earlier rounds' findings. It gives every task-relevant fact and never forbids the reader from looking for anything. If the reader finds the writer's view by looking, for example in the ticket thread, that was the reader's choice.

---

❓ **Q6 - What happens when a rule meets a case it didn't foresee?** By Q2, this always happens eventually. The research changes how to handle it:

- **Readers don't ask, even when invited.** Survey respondents asked for help on 4% of the occasions help was given (Conrad & Schober). Models almost never ask on underspecified coding tasks (Ambig-SWE).
- **Wording decides whether a reader checks.** Told that definitions were "essential", respondents looked them up on 81% of questions. Told they were "available", on 23%.
- **Models use hints without saying so.** Claude 3.7 Sonnet mentioned a hint it used 25% of the time (Chen 2025). Reading a lane's reasoning won't show that it bent.
- **A fixed handoff that ends with the receiver restating the plan cut medical errors by 23%.** That is the I-PASS program (Starmer 2014). Its share of the gain is unknown, because training was bundled with it.
- **The counterweight: assigned dissent is weaker than real dissent** (Nemeth 2001). A report slot that demands "list where the rules fought you" could manufacture conflicts.

The factory now has five departure mechanisms that disagree with each other.

➡️ Replace all five with one:
- When a **binding** rule fights the goal, the reader stops that part, reports it to the rule's owner and carries on with the rest. It never shrinks the goal to fit the rule.
- **Everything else** the reader departs from when it judges a better way, and says so.
- **Every report opens with a read-back**: the reader's restatement of the goal as it understood it, then a plain account of what it did. The wording stays neutral, not "list your conflicts". A read-back surfaces misreadings the reader can't see in itself.

The principle is decided here. The form goes to the ticket "Prototype brief templates for the recurring lane jobs". The sign-off line in AGENTS.md stays for the main session, where you are there to sign off.

---

❓ **Q7 - How firmly does this decision hold?** The evidence has gaps. No model study tests a limit on strategy as such, most model studies used 2022–2025 models, and Opus 5.5 is untested. The strongest support is:
- the human research;
- the vendor's own notes;
- one preprint;
- the factory's own run-2 evidence: 4 of 13 labelled bugs sat in files the brief told the reviewer not to open, and PR 99's four bugs went unfiled.

➡️ Decide it now as the standard, and record which parts rest on measurement and which on inference. Hand the ticket "Decide how we'll know the writing works" two experiments the factory can run itself: the same open-ended task given with and without an illustrative list, and with and without a reporting bar, counting what each version finds.

---

The research also bears on the ticket "Decide what the writing standard is and what carries it". The standard shouldn't be written as "don't constrain the reader". A prohibition keeps the forbidden idea active, and the model lands on some other fixed default instead. And telling a reader not to be led can make it combative (Nemeth). I'll carry that to that ticket when this one closes, and rewrite my memory of the old test then.