Yes, the research changes the questions. The biggest change is to "what done means": in round one I counted it as part of the task and so safe to bind. The research says that's where limits hide most easily, and your Q1 correction already pointed there ("pursued **or completed**").

The research is [docs/research/wording-and-reader-context.md](https://github.com/Zenoctra/factory918/blob/research/wording-and-reader-context/docs/research/wording-and-reader-context.md) on its own branch; section numbers below point into it. One limit applies to everything here. No study has tested a limit on method in a model directly. My recommendations rest on human evidence plus nearby model results, mostly from older models than Opus 5.5. The ticket "Decide how we'll know the writing works" is where that gets tested.

**What changed since round one:**
- The ownership test now carries the whole of Q1. I tried a rule based on content and it failed against your delegation rule.
- "What done means" moves from binding to evidence about the goal (new Q2).
- Route knowledge splits into two kinds: facts about the project, which help a reader starting cold, and advice on method, which can hold back a capable one.
- New Q4: the run-2 fix for reviewers being led ("read only the brief") mixed up two things. Holding back the writer's own conclusions protects independence. Limiting what the reader may look at does not.
- The conflict question gets harder. Readers rarely notice a conflict and rarely raise one, so permission to report it isn't enough.
- New Q6: rules about how the work is finished (reporting bars, output formats, budgets).
- New Q7: how a binding rule is worded.

Terms, the same as before:
- **The goal** is what's wanted.
- **The route** is how the reader gets there.
- **A binding rule** is one the reader may not overrule by itself.

The questions below follow what the research found. Neither they nor their options cover every way this can go wrong.

---

❓ **Q1 - What makes a rule binding?** Garfinkel and Suchman argue that no instruction written in advance can contain the situation it will meet: a plan helps the person acting, but doesn't dictate the action (§4). So any rule about the route has to justify itself.

I tested a test the factory's history suggests: rules that add a check help, and rules that take something away hurt. The trail review adds a check, and it caught the owner's errors three times out of three. "Read only the brief" and "stop after N" take something away, and they did harm. The test fails on the delegation rule, which takes something away from the orchestrator and did good. Who owns the rule sorts every case I found:
- Delegation is your rule.
- "Read only the brief" was added by subagents to save cost, and no ticket asked for it (the run-2 constraints audit).

The options:
- (a) A rule binds only when its owner made it binding. You own your rules; the ticket's author owns its scope; an orchestrator owns which files its other subagents are working in right now.
- (b) A rule binds based on what it's about (the task, or limits of authority), as in round one.
- (c) No test; each rule is argued case by case.

➡️ (a). An orchestrator passes your rules down unchanged, binds only what it owns itself, and offers everything else as knowledge (Q3). This merges round one's Q1 and Q4.

---

❓ **Q2 - Does a definition of done bind?** Measures quietly take the goal's place:
- Managers paid on one measure of a strategy acted as if the measure were the strategy. They didn't notice, and knowing they were measured was enough, with no pay attached (surrogation, §4).
- A reporting bar makes the reader find a problem and then leave it out of the report. That was seen in radiologists (Berbaum 2015) and in Anthropic's own evals of Claude reviewers (§4).
- The factory has its own case. The `spec:` citation gate was classed as "report format", and a reviewer that obeyed it filed nothing on a PR with four real bugs.
- Your P109 ruling already called an "at most" list "a prediction, not a constraint".

The options:
- (a) The goal binds, in the owner's words and with its reason. Any criterion for done is evidence about the goal. When the two disagree, the goal wins and the reader says so.
- (b) Criteria bind as written. That makes results predictable and checkable.
- (c) Briefs carry no done criteria.

➡️ (a). One caution from the research: when Army commanders wrote statements of intent, those carried the intent only about a third of the time, and the statements were full of method (Shattuck 2000, §4). Stating the goal is necessary but not sufficient. How the goal travels to the reader is a question for the ticket "Decide what the writing standard is and what carries it".

---

❓ **Q3 - How should the writing carry what the writer knows about the route?** The research separates two kinds of knowledge that behave differently.

**Facts about the project** are things a reader starting cold can't see. Examples: the worktree guard refuses `git` inside `$(...)`, and paths here contain spaces.
- However capable it is, a subagent starting cold is a low-knowledge reader for this project, and explicit connections help such readers (McNamara 1996, §9).
- Holding back relevant context isn't neutral. Across 16 studies, clinical information made people reading medical tests more accurate, and no study found it made them significantly worse (§3).

**Advice on method** covers what order to work in, what to read first, and when to stop.
- Detailed guidance helps novices and hurts experts (60 studies, §4).
- On complex, new tasks, specific goals push people into narrow step-by-step strategies (§4).
- A known method blocks a better one even while the solver believes it's looking for others (the chess study, §2).
- Current Claude reads literally, so advice written as information can still be taken as a rule (§11).
- The same limit stated as information rather than as control did not lower creativity (Koestner 1984). The vendor says the model generalizes from the reason given.

The options:
- (a) Leave route knowledge out.
- (b) Give facts about the project freely, each with its reason. Give method only as "what I tried and what happened", never as a recommendation.
- (c) Allow method, labelled as a default.

➡️ (b). Facts help the cold reader; advice on method is what anchors it. One case is neither: where a method is itself what's wanted, it's part of the goal, owned by whoever needs it, and binds under Q1. An example is recording a commit with a particular script because other tools read that script's output. Your Q-round remark that lists are fine on "a closed ended task where the options truly ARE listable" is the same idea.

---

❓ **Q4 - How is a reader's independence protected?** The run-2 fix for leading a reviewer was "read nothing beyond this brief". The research separates two things that fix mixed up: what the writer volunteers, and what the reader may look for (§4).
- Forensic science protects independence by holding back the requester's conclusions and information irrelevant to the task, and by blind re-checks. It never does it by stopping the examiner from looking (§3).
- Interrogators told to expect guilt asked guilt-presuming questions, which changed the answers and how third parties heard them (Kassin 2003).
- Telling a model reviewer the code was bug-free cut detection from about 96% to 89% for Claude Opus 4.5, and to 4% for a small model (§3).
- Models also use hints without mentioning them, so reading a reviewer's reasoning won't show that it was led (§3).

The options:
- (a) Independence is protected only by what the writer holds back: its hopes, its conclusions, an expected result, earlier rounds' findings. It is never protected by limiting what the reader may look for.
- (b) Use both.
- (c) Neither; trust capable models.

➡️ (a).

---

❓ **Q5 - What does the reader do when a binding rule fights the goal?** The factory gives five answers today, and they disagree:
- say so and get a sign-off;
- follow the rule, then explain;
- write a visible `skip: <reason>`;
- make the call and record a Provisional decision;
- end a flag with `accepted: <reason>`.

No text says how a subagent gets a sign-off.

The research changes how much the answer can lean on the reader:
- Readers who misunderstand rarely know it. Survey respondents told they could ask, asked 4% of the time. Models almost never ask on underspecified coding tasks (§8).
- Wording matters. Readers told that checking definitions was **essential** checked 81% of the time, against 23% when told it was **available**.
- Readers don't always see their own conflict, so something outside the reader has to look too. In the one model study of this, a separate critic with an open brief recovered every finding that a narrowly briefed model left out (Shin 2026, preprint, §4). A hospital handoff program that cut medical errors by 23% has the receiver restate the plan (I-PASS, §10).

The options:
- (a) One mechanism replaces all five. The reader stops that part, reports the conflict to the rule's owner, and carries on with the rest. Every report has a required section for conflicts and departures.
- (b) Break the rule and report it.
- (c) Narrow the goal to fit the rule.

➡️ (a). Never (c). I'd hand the outside check (a restatement step or an open critic) to the standard and template tickets rather than decide it here.

---

❓ **Q6 - Reporting bars, output formats and budgets.** You said "pursued **or completed**". The run-2 audit classed rules about how work is finished as safe, but the research says they can cost the most:
- **Reporting bars.** The vendor recommends asking for every finding with a confidence and severity, then filtering in a separate step (§4).
- **Output formats.** In one study, forcing JSON output hurt reasoning, and answering freely first and converting afterwards removed most of the loss. That result is contested (§4).
- **Budgets.** Tight output budgets cut reasoning models' scores sharply (Sun 2025, §4). A budget is also a measure, so it can quietly become the goal.

The options:
- (a) The reader does the whole job its own way. Filtering, ranking and formatting happen afterwards, in a separate step or by a script. A budget is stated as a fact the reader plans within, and only you can make one a hard cap.
- (b) Bars, formats and budgets stay in the brief as rules.
- (c) Decide each kind separately.

➡️ (a). The map "Optimize token use and wall-clock time without losing reliability" can revisit budgets once it has measurements.

---

❓ **Q7 - How is a binding rule worded?** Some rules will bind: your git rules, delegation. What the research says about wording them:
- Emphatic wording ("NEVER", "CRITICAL") makes current Claude over-apply an instruction (vendor, §4). A shouted rule spreads into parts of the route its owner never meant to bind.
- A bare prohibition keeps the forbidden thing active in the reader's mind and doesn't say what to do instead, so the reader settles on some other fixed default (§5).
- Rules given with their reason are followed better and more flexibly (§4, §9).

The git guard already works this way: its block message names another way forward.

The options:
- (a) Plain wording, with the reason, the owner named, and what to do instead.
- (b) Emphasis for the few rules that matter most.
- (c) Leave wording to the writing-standard ticket.

➡️ (a).

---

One more decision is waiting on Q1. In round one, I wanted to bring you the `spec:` gate as a test case after Q1. It's now inside Q2, so round two is whatever your answers open up. The housekeeping from round one still stands: once this round settles, I'll rewrite my memory note that still uses the old test, and post your answers on the ticket word for word, as we've done on the map.