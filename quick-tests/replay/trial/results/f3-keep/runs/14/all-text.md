Yes, the research changes the round. Round one asked which rules to allow. The research says that is only half of it. The other half is whether anyone can see when a rule bent the work, and what the writer slips in without calling it a rule. Three of my five recommendations change, and the research brings cases the old framing would have missed.

**What changed, in short:**

1. **The "you may overrule this" door is rarely used.** In one survey experiment, a list of four problems with an explicit invitation to name another drew 60% of answers. Asked openly, the same four drew 2%. A rule the reader may overrule works much like the "other" slot, and current Claude models read instructions literally on top of that.
2. **Reading limits are not the only route limits.** A threshold on what to report, a stance word, or a goal stated narrowly can bound the route just as hard. Radiologists who had found one problem became reluctant to report a second. Anthropic's own evals of Claude show the same thing: the model finds the bug, then leaves it out under "only report high-severity". In one 2026 preprint, a narrow task instruction stopped models reporting critical findings they reported otherwise.
3. **Readers who misread rarely notice, and rarely ask.** Survey respondents told they could ask for help did so 4% of the time. Current models almost never ask on underspecified coding tasks. Models also follow hints without mentioning them. A rule that says "report it if a rule fights the goal" depends on the step that fails most.
4. **Holding back what the writer volunteers is a different thing from limiting what the reader may look at.** Forensic science supports the first: don't hand the examiner someone else's conclusion. Medical evidence warns against confusing it with the second: across 16 studies, giving readers task-relevant context made them more accurate.
5. **Facts about the ground help; suggested paths anchor.** Naming a trap reduced fixation in design studies. Showing an example made people copy it, flaws included. A familiar solution kept chess masters' eyes on it even while they said they were looking for a better one.

**One caveat.** No model study tests a limit on method as such. The most direct model evidence is the factory's own:
- Four of 13 labelled bugs sat in files the brief told the reviewer not to open.
- The `spec:` citation gate left a PR's four real bugs unfiled.

Most of the rest is human evidence, single studies, or vendor observations with no published numbers. The "Decide how we'll know the writing works" ticket can run the experiment nobody has run.

The terms from round one still hold: **the goal** is what's wanted, **the route** is how the reader gets there, and **a binding rule** is one the reader may not overrule by itself.

---

❓ **Q1 - What makes a rule binding?** The revised test: a rule binds only when it states something that belongs to someone other than the reader.
- What the owner wants, stated as wide as it really is.
- What the result is and where it goes: a PR, a decision, a report back to the orchestrator.
- Actions that are someone else's call: merging, files another subagent is working in, anything outside the repo.

Everything else is the reader's. Only the owner of a thing can bind it. An owner may also bind a route rule, as you did with delegation, but then the rule carries its reason and its evidence. The trail review earns its place by catching the owner's errors three times out of three.

Four cases to test it against:
- **A bar on what gets reported**: "report only hard bugs", the `spec:` citation gate, "don't nitpick". These look like part of "done", but they filter what the reader reports, and the evidence says that's where findings vanish. Under the test they are not binding. The result is every finding, each with a confidence and a severity. Filtering is a separate step, done by whoever uses the report. Anthropic recommends the same.
- **Stance words**: "be adversarial", "be conservative". They read like a role, but they steer the route and what gets reported. Across 162 personas, a persona added no accuracy. Assigned dissent produced fewer good ideas than real dissent. "Be conservative" is one of the phrases in Anthropic's withholding observation. Under the test they are not binding, and not worth writing. The role says the reader's position instead: what it is judging, for whom, and where the result goes.
- **Keeping a judgment independent**: [ticket.md:13](template/.agents/skills/poteto-mode/playbooks/ticket.md:13) tells the orchestrator to read no brief and no diff while a review runs, and a later review round is kept from the earlier round's findings. These do limit what the reader may look at, but independence is part of what you asked for. Under the test they are binding when the owner wants an independent judgment, and only as narrow as the specific thing that would contaminate it, with the reason. "Don't read round one's findings" passes. "Read only the diff" fails: it fences off everything without naming anything it protects against.
- **A narrow goal**: in the preprint above, a focused instruction hid what the model would otherwise report, and a second reader with an open brief recovered every omitted finding. A goal stated narrower than the owner means is a route limit in disguise.

➡️ This test. It covers the old symptom, limits on reading, and the ones the old framing missed: bars, stances, and narrow goals.

---

❓ **Q2 - What may a writer say about the route?** The research splits what a writer knows about the route into three kinds that behave differently:
- **Facts about the ground.** A hazard, a tool quirk, a cost someone already paid: "the worktree guard refuses `git` inside `$(...)`." These help, especially a reader new to the project, and naming a trap doesn't anchor the reader the way an example does.
- **Suggested paths.** "Start with X, then Y." These anchor. In one study, Codex copied lines from a related example function into 32–61% of its solutions. Across 60 studies, step-by-step guidance helped novices and hurt experts.
- **Defaults the reader may overrule.** This is your door: "leaving the door open for a model to overrule certain rules that aren't absolutely necessary." The evidence says such a door works much like the "other" slot: most readers never use it.

The options:
- (a) Facts only. Anything that must be followed is bound by its owner under Q1, and anything else is left out.
- (b) Facts, plus defaults written so the door actually opens. Each default carries its reason, and is worded as something to weigh, not obey. The reason is what lets a reader see the case the writer didn't predict.
- (c) All three kinds, each with its reason.

➡️ (a) for what one agent writes to another. (b) where you, as owner, want a default. Suggested paths stay out. The counterweight is simple, mechanical jobs, where step-by-step method does help. The factory's answer there is a script offered as a tool, as a fact about the ground, not prose steps.

---

❓ **Q3 - When a binding rule fights the goal, what does the reader do, and how does anyone find out?** The options from round one stand:
- (a) Stop that part, report it, carry on with the rest.
- (b) Break the rule and report it.
- (c) Narrow the goal to fit the rule.

The research says the hard part is noticing at all. Two remedies have evidence behind them:
- **Make the report routine, not exceptional.** A hospital handoff program cut medical errors by 23%. Its last step is the receiver restating the plan. Applied here, every report opens with what the reader took the goal to be, and which rules changed what it did or reported. That gives the writer the signal without waiting for the reader to decide there was a conflict. Signal from real readers is the one thing the research found that improves writers. Telling writers to imagine their reader didn't help.
- **Say it's essential.** Survey respondents told that checking definitions was "essential" checked on 81% of questions. Those told it was "available" checked on 23%.

This also settles the factory's five departure mechanisms, which disagree today:
- Your note at [template/AGENTS.md:16](template/AGENTS.md:16): "follow the file and tell me why your instinct differed."
- The line at [:20](template/AGENTS.md:20): "These are good defaults, not hard rules… get a sign-off before breaking it."
- The other three: `skip: <reason>`, a Provisional decision, and `accepted: <reason>`.

Under (a) with the routine report, your two lines become one: follow the rule, and say in the report where the rule and your judgment parted. That keeps your note's purpose ("that is how the rules here get better"). It also drops a sign-off that a subagent has no way to get.

➡️ (a), with the routine report in every report, and (c) named in the writing as the failure to avoid. The root session, with you present, still asks you first.

---

❓ **Q4 - Who may write a binding rule into a brief?** Same recommendation as round one: the orchestrator passes down rules their owners set, binds only what it owns, and never makes its own guess about the route binding. The research adds two things:
- **What the writer believes leaks into the work.** Interrogators who expected guilt asked guilt-presuming questions. Fingerprint experts reversed their own past decisions once given case context. Telling a model the code was bug-free cut a small model's vulnerability detection from 97% to 4%, and Claude Opus 4.5's from 96% to 89%. So the orchestrator's restraint has to cover its conclusions, not only its rules. It gives the reader task-relevant context and keeps back its own verdict.
- **A literal reader treats every line as an instruction.** A brief has to make plain which few lines bind, or everything else gets read as rule too. How that's marked belongs to the brief-templates ticket.

➡️ Pass down, bind only what it owns, and keep its own conclusions out.

---

❓ **Q5 - Can cost or time limit the route?** The evidence:
- Tight output budgets cut reasoning models' accuracy: one fell from 72% to 54% at 1,024 tokens.
- People who merely knew a measure existed began treating it as the goal. That is your example of the reviewer capped on findings that then says there are no more bugs.

➡️ Sharper than round one. State a budget only when it's real and you own it, such as money or wall-clock time. It's a limit on spend, never on output. What happens at the limit is fixed: hand back what's done and say plainly what's left. "Nothing more to find" is never the answer at the limit. A cap derived from something else is never written.

---

Next round, once Q1 and Q2 settle: which of these rules may be held by a blocking hook, the "highest rung" in the map's destination. I'll also rewrite my memory note that still carries the old test.