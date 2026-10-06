Yes, the research changes the round. I read the whole note ([wording-and-reader-context.md](https://github.com/Zenoctra/factory918/blob/research/wording-and-reader-context/docs/research/wording-and-reader-context.md), on its research branch). This round replaces round one, so please answer these questions instead.

Four findings change my thinking:

1. **The goal can limit the route as much as any rule.** In round one I treated "what's wanted and what done means" as safe. The worst harms the research measured are in exactly that place:
   - When a brief sets a bar on what to report, a reviewer finds a bug and then leaves it out. This was measured in radiologists, and Anthropic's prompting guide for Opus 4.8 reports the same in its own evals.
   - In one 2026 study, a narrowly framed task kept models from reporting critical findings they had noticed, in up to 92% of cases.
   - A measure can quietly take the goal's place: police under pressure to cut crime figures stopped recording crimes.

   The factory has its own case. The `spec:` citation gate made a reviewer file nothing on a PR that had four real bugs.
2. **Leaving something out of a brief is not the same as forbidding the reader to look.** Forensic science protects an examiner's independence by not handing over someone else's conclusion. It never stops the examiner from gathering evidence. In 16 medical studies, giving readers relevant context improved their accuracy, and no study found a significant loss. Several of your examples mix these two things up.
3. **Models don't push back against bossy wording; they apply it too broadly.** People resist controlling rules. Current Claude models read instructions literally and over-apply emphatic ones, so a line meant as an example acts as a rule. Permission that is merely offered also goes unused. When survey respondents were told they could ask for help, they asked on only 4% of the occasions it was given. Models almost never ask either.
4. **A subagent is an expert at the work and a newcomer to the project.** Across 60 studies, step-by-step guidance helped novices and hurt experts, and a familiar method can blind people to a better one. A reader without background does gain from explicit facts. That splits what round one called "route knowledge" into two kinds.

There is one gap in the research: no study tests a limit on a model's *strategy* directly. That's for the ticket "Decide how we'll know the writing works" to measure. The questions below rest on the human evidence and on the factory's own cases.

These options are my own list. If none fits, answer outside them.

---

❓ **Q1 - What may bind the reader?** A **binding rule** is one the reader may not overrule on its own; a **default** is one it may overrule if it says so. My proposal: a rule binds only when its owner marks it as binding and gives the reason. Everything else is a default. That matches your words, "rules that aren't absolutely necessary", and the template's "good defaults, not hard rules".

Who can mark a rule binding:
- You can, and so can AGENTS.md and the tickets you approve, since they carry your rulings.
- An orchestrator can mark binding only what it owns itself, such as which files other subagents are holding right now. It can never make its own guess about the route binding.
- Facts the reader can't change bind because they're facts, for example that the guard refuses `git` inside `$(...)`.

What changed from round one: a definition of "done" is evidence that the goal was met, not the goal. A brief states the goal first and then the evidence, so the reader can tell when the evidence misses the goal. That's your rule from the P109 amendment: the principle beats the check derived from it.

How some existing rules come out under this test:
- **Delegation rule:** binding. It's a rule about the route, but you own it, and the ledger shows why it has to bind: a lane broke it knowingly.
- **Never push to main:** binding, because merging is your decision.
- **The `spec:` gate:** a default. You never marked it binding. A lane added it.
- **The ledger case where a lane turned your question into a rule on a ticket:** that couldn't happen under this test. A question isn't a ruling, and the lane didn't own the decision.

The options:
- (a) Binding only when the owner marks it so, with the reason (the proposal above).
- (b) Binding by what the rule is about, as in round one: authority and facts bind, the route doesn't.
- (c) Everything in AGENTS.md and the playbooks binds; only text in a brief is a default.

➡️ (a). It makes binding rules rare and visible, and each one arrives with its reason.

---

❓ **Q2 - Leaving things out versus forbidding a look.** The test case: later review rounds are kept blind to earlier findings. That's your rule. Not putting the earlier verdicts in the brief is the writer holding back, and the forensic evidence supports it. But the earlier findings sit as comments on the PR, and a reviewer might go and read them on its own. Forbidding that limits what the reader may seek.

My proposal has three parts:
- The writer leaves out its own conclusions, its hopes about the result, and other reviewers' verdicts.
- The writer never leaves out facts the task needs.
- A limit on what the reader may look at is allowed only when looking would destroy the thing the reader is there to provide, such as the independence of a blind review. Even then, its owner must mark it binding and give the reason.

The options:
- (a) The proposal above.
- (b) Never limit what the reader may seek; independence comes only from what the writer leaves out.
- (c) Writer and reader rules aren't separated, and each case is argued on its own.

➡️ (a). It adds a second exception to your 2026-09-24 rule ("never tell a subagent what it can't look at"); the first was side effects. So it needs your explicit yes or no.

---

❓ **Q3 - What the writer knows about the route.** I propose splitting it in two:
- **Facts about the territory.** Project quirks, traps, where things live, and what was tried before and what happened. Give these near the start of the brief, written as facts with the evidence behind them. A reader without background gains the most from them.
- **Method.** How to search, in what order, with which tool, and when to stop. Leave this out. If the writer thinks a method matters, it goes in as a fact about what happened, never as an order. For example: "on 2026-09-22, three of five lanes ran the trail review and all three found errors."

The wording is plain and informational, without emphasis, because current models over-apply emphatic wording. Even a fact can anchor the reader, which is why it carries its evidence rather than reading as advice. On simple tasks, method given as information costs nothing, because the reader can simply follow it. So simple tasks don't need a separate rule.

The options:
- (a) The split above.
- (b) Round one's "knowledge with its reason, the reader may depart", without the split.
- (c) Leave route knowledge out entirely.

➡️ (a).

---

❓ **Q4 - Does every rule carry its reason?** The evidence:
- People follow a rule better, and more flexibly, when it comes with its reason.
- Anthropic's guidance says its models generalize from the reason.
- The reason is also what lets a reader see when a rule doesn't fit the situation in front of it. The sociology section's point is that no instruction written in advance can contain the situation it will meet.

The background search found reasons uneven across the factory. "Never an arena", the 30-second limit on the whole test suite, and the 150-line read cap carry none, and nobody can say where 150 came from. A bare prohibition also leaves a model sitting on some other fixed default. The git guard avoids that by naming what to do instead: "use --force-with-lease, or ask."

My proposal:
- Every rule, binding or default, carries its reason.
- A binding rule also names what to do instead.
- When the rework reaches a rule nobody can give a reason for, the rule is up for deletion rather than kept by default.

The options:
- (a) Every rule, as above.
- (b) Binding rules only.
- (c) Reasons are encouraged but optional.

➡️ (a).

---

❓ **Q5 - When a rule fights the goal, and how departures come to light.** The factory currently has five mechanisms for this, and they contradict each other. The research suggests a permission line won't fix that:
- Permission that is merely offered goes unused.
- A line repeated in every brief gets read past as boilerplate.
- Pushing too hard backfires. Dissent that is assigned is weaker than real dissent, and find-and-fix prompts raised false positives in model reviewers.

The one large test of a fixed handoff template that improved outcomes was I-PASS in hospitals, which cut medical errors by 23%. It built the reader's report back into the structure itself.

My proposal is one mechanism in place of the five, carried by the shape of the report rather than by a permission line:
- **A default fights the goal:** the reader goes its own way, and its report says where and why.
- **A binding rule fights the goal:**
  - A subagent stops that part, reports the conflict to the rule's owner, and finishes the rest.
  - In the root session, with you present, it says so and gets your sign-off, as AGENTS.md says today.
- **The brief is silent:** the reader decides and records the decision as Provisional, as now.

Every report has a place for departures. When there are none, it says so, and nothing tells the reader what count to expect; that's the lesson from "zero items is the expected result". The template's "follow the file, then tell me why your instinct differed" goes, because it treats every rule as binding.

The options:
- (a) The proposal above.
- (b) (a), plus the reader restating the goal in its report, as in I-PASS.
- (c) Keep a permission line in every brief.

➡️ (a). The restated goal from (b) belongs in the ticket "Prototype brief templates for the recurring lane jobs", where its cost can be tested.

---

❓ **Q6 - Does scope limit what the reader reports?** What a reader is told to look at decides what it sees:
- In the gorilla study, 46% of observers counting passes missed the gorilla. In a lung scan, 20 of 24 radiologists missed one.
- In the 2026 model study, a separate critic given an open brief recovered every critical finding the narrowly briefed models had left out.

The factory narrows scope on purpose: one concern per PR, with the ticket drawing the scope.

My proposal: scope limits what the reader *changes*, never what it *reports*. Every report has a place for things noticed outside the task, and the writer turns each one into a ticket. That's what AGENTS.md already does with review findings outside a PR's scope. Whether reviews also get a separate open-ended critic is a question for the templates ticket.

➡️ Yes, as proposed.

---

❓ **Q7 - Bars and caps on the report.** The evidence:
- Radiologists kept searching but raised their bar for reporting what they found.
- Anthropic's guide for Opus 4.8 says prompts like "only report high-severity", "be conservative" and "don't nitpick" make the model find bugs and then leave them out. The guide recommends asking for every finding with a confidence and severity, and filtering in a separate step.
- Tight limits on output length cut reasoning sharply.
- A number in a brief anchors the reader.

The `spec:` gate is a bar of this kind. P18's definition of "hard" already works the recommended way: the reviewer reports, and a defined rule decides what blocks.

My proposal:
- No brief sets a bar on what the reader reports, or a cap on how long the report is.
- The reader reports everything, with its own severity and confidence.
- Filtering, ranking and condensing are a separate step, owned by the writer or a script.
- If you set a token or time budget, the brief states it as a fact the reader plans around, never as a cap on the report. The map "Optimize token use and wall-clock time without losing reliability" owns budgets beyond that.

➡️ Yes, as proposed.

---

Once this round settles, I'll rewrite my memory note that still uses the old split between protecting the world and shaping the search, and I'll record the settled terms (goal, binding rule, default) where the ticket "Decide what the writing standard is and what carries it" can find them.