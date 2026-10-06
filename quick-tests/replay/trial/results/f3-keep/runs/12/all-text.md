Yes, it changes them, and not only in tone. Three of my round-one positions don't hold up against the research, and three questions are new. The round below replaces round one, so answer this one instead.

**What the research changed**

- **My test for "binding" in round one was based on topic, and that test fails.** I said rules about the goal and about what done means were binding, and rules about the route weren't. Some of the most damaging rules in the evidence are about what done means:
  - A bar on what to report makes readers hold back findings they already made. Radiologists did it (Berbaum 2015), and Anthropic's prompting guide for Opus 4.8 reports the same in Claude.
  - Our `spec:` gate is one of these. A reviewer obeyed it and filed nothing on a PR that had four real bugs.
  - The task instruction decides what gets seen. In the gorilla study, people counting passes missed a gorilla walking through, and Shin 2026 found the same in models.
- **I missed a distinction the research draws: what the writer volunteers versus what the reader may go looking for.** Keeping my own guess about the answer out of a reviewer's brief doesn't limit the reviewer's route. It's restraint on my side, and forensic science supports it. Several examples on the map mix the two.
- **My Q3 assumed the reader notices when a rule fights the goal.** The evidence says readers who misread rarely know it and rarely ask. Models also use hints without mentioning them. A mechanism that relies on the reader's own report will miss most cases.
- **My Q1 handed you a closed list** of three things that count as binding. That is the multiple-choice pattern you warned about.

**How strong the evidence is.** Most of it is about people. The model studies mostly used models from 2022 to 2025. None tested Opus 5.5, and none tested a model under a limit on strategy, such as which files to read, what order to work in, or which list to cite. Section 13 of the note lists these gaps, and I flag single studies where I rely on one. My recommendations below are anchors too: in the research, even sentencing demands that judges knew were random moved their sentences. So push on them.

Research note: [wording-and-reader-context.md](https://github.com/Zenoctra/factory918/blob/research/wording-and-reader-context/docs/research/wording-and-reader-context.md)

---

❓ **Q1 - What makes a rule binding?** "Binding" means the reader may not overrule it by itself. Everything else is the reader's to depart from, as long as it says so.

The test I'd propose: **a rule is binding only when its reason lies outside what the reader can see or judge from where it stands, and the rule states that reason.** Inside its own view, the reader's judgment beats the writer's prediction, because the reader is in the situation and the writer wrote before the situation existed. Garfinkel and Suchman (section 4) argue that no instruction written in advance contains the situation it will meet, and that plans are resources for action, not specifications of it. That's the research's version of your "leave it open for something you CAN'T predict."

What lies outside a reader's view:
- **Someone else's authority.** For example, you merge PRs.
- **Work it can't see.** For example, files another subagent holds right now.
- **Its own blind spots.** A reader can't judge how a conclusion it was shown bent its own judgment. Fingerprint experts reversed their own past matches after being given context. Claude 3.7 Sonnet mentioned a hint it had used only 25% of the time.

Some cases run through the test:
- **"Never push to main":** the reason is your review, which the reader can't see. Binding.
- **"Don't read the earlier review rounds' findings":** the reason is the reviewer's own anchoring, which it can't see in itself. Binding. So the test still keeps some rules about the route.
- **"The writer doesn't grade its own tests"** ([feature.md:12](template/.agents/skills/poteto-mode/playbooks/feature.md:12)): binding, for the same reason.
- **"Read only the diff":** the reviewer can judge what's relevant itself. Not binding; at most it becomes a note.
- **"File only hard findings," and the `spec:` gate:** the reviewer can judge severity, and a filter after it can serve the bar's purpose (Q4). Not binding.
- **The 150-line cap in `knowledge`:** no reason is recorded anywhere, so it can't be binding.
- **pstack copying playbook steps verbatim "so the agent follows a script rather than improvising"** ([PHILOSOPHY.md:23](docs/knowledge/core/PHILOSOPHY.md:23)): binding, because you chose it deliberately. The research on capable readers still predicts a cost.

The test's weak spot is that any writer can claim "this is outside your view." So a rule also needs an owner to be binding. Only whoever owns the reason can make the rule binding: you, the ticket, or an orchestrator for things only it controls. This absorbs my old Q4.

- (a) The test above, plus the owner requirement.
- (b) Ownership alone: binding if its owner says so, with the reason optional.
- (c) No general test; each binding rule is argued case by case.

➡️ (a). A stated reason lets the reader, a reviewer and you check the claim. The research gives a second reason: people follow a rule better and apply it more sensibly when they know why it exists, and Anthropic says Claude generalizes from the reason. I built this test from the evidence and I picked the cases, so test it against cases of your own.

---

❓ **Q2 - How does a writer pass on what it knows about the route?** Round one's "knowledge, not orders" was right in spirit. The research draws a sharper line and adds a warning.

**The line is between facts about the situation and method.**
- A fresh subagent is capable but knows little about this project.
- Readers new to a subject gain from explicit context (McNamara 1996).
- Step-by-step method hurts capable readers. In a meta-analysis of 60 studies, high guidance helped novices (d = +0.51) and hurt experts (d = −0.43).
- So "the guard hook refuses `git` inside `$(...)`" is a fact that helps. "Run these two commands in this order" is method. They carry the same knowledge, but with the fact the reader picks its own way around the problem.

**The warning is that wording decides whether a fact reads as an order.**
- Children painting under the same limits were less creative when the limits were worded as control than when they were worded as information (Koestner 1984).
- Anthropic says current Claude models read instructions literally and over-apply emphatic ones. A model is the reader most likely to turn an aside into a rule.
- A disclaimer repeated in every brief stops being read: wording attached to every question becomes boilerplate (Igou 2002).

So the fix has to be in how each note is worded, not in a standing "these are only suggestions" line. Your rule from charting Q9, that lists in quoted text are examples and not boundaries, still stands. It covers a different risk.

- (a) Leave route knowledge out entirely.
- (b) Pass it on as facts about the situation, saying what each rests on, and word it as information, never as steps.
- (c) Pass it on as defaults the reader may override ("do X unless…").

➡️ (b). Option (c) is still method, only softened. The open edge: no study has tested this with a model writing to another model. The case rests on human evidence and vendor guidance.

---

❓ **Q3 (new) - Is keeping the writer's own conclusions out of a brief a rule about the route?** There are two different things here:
- **Limiting what the reader may look at,** such as "don't open that file."
- **The writer holding back what it volunteers,** such as leaving "I think the bug is in the hook" out of a reviewer's brief.

**The evidence for holding back is strong.**
- In one 2026 study, Opus 4.5 caught 96% of vulnerabilities under neutral framing and 89% when told the code was bug-free. A small model fell from 97% to 4%. This is a single study.
- Forensic examiners told of a previous decision were biased in 4 of 4 studies.

**Leaving out relevant information has a cost too.** In 16 studies of readers interpreting medical tests, clinical information improved accuracy and none found a loss. The line forensic science draws is between information relevant to the task and someone's conclusion.

**This collides with your Q9 preference.** You want the full, unsummarized quotes of where the task was defined, including orchestrator conversations. Those quotes sometimes carry a conclusion, like "the hook is probably the culprit." Labelling it as a guess doesn't cancel it: telling GPT-4 to ignore a hint didn't remove anchoring (Lou & Sun 2024).

- (a) The same rule for every subagent: quotes go in whole, conclusions included.
- (b) Split by job:
  - For subagents whose job is to judge (review, verify, research, audit), the writer's conclusions about the answer stay out, even from inside quotes, and each cut is visible: "[the orchestrator's guess at the cause, left out of a review brief]."
  - For subagents whose job is to build, guesses go in, each with what it rests on.
- (c) Strip conclusions everywhere.

➡️ (b). A reviewer's value is its independence, and a builder's is using everything already known. A cut inside a quote is the summarizing you dislike, so it has to show.

---

❓ **Q4 (new; it absorbs round one's budget question) - Where does a bar on what gets reported go?** By a bar I mean things like "report only high severity," "under 400 words," "at most N findings," and the `spec:` citation requirement. The research says the reader still does the work, and the bar decides how much of it reaches the page:
- Radiologists kept searching but raised their bar for reporting what they found.
- Anthropic reports the same of Claude, and recommends asking for every finding with its confidence and severity, then filtering in a separate step.
- Tight output budgets cut reasoning accuracy. One reasoning model fell from 72% to 54% at a 1,024-token cap.
- Telling a reader how many problems to expect moves its bar. Mammographers missed 30% of cancers when cancers were rare and 12% of the same cancers when half the cases had one.
- A measure tends to become the goal without anyone noticing ("surrogation," section 4).

The options:
- (a) No subagent applies a bar to its own report.
  - It reports everything it found, each finding with its confidence and severity.
  - Any bar lives in a separate step after it, a script or another subagent, controlled by whoever owns the bar.
  - A time or token budget reaches a brief only when you set it. It is stated as a fact with its reason, and the subagent plans its own route within it.
- (b) Bars stay in the brief, with their reason stated.
- (c) Case by case.

➡️ (a). The cost moves to the filter: there is more noise to sort, and detailed find-and-fix prompts raise false positives (Jin & Chen 2026). That's the trade. A filter can drop a false positive later, but nothing recovers a finding that never got written down. For the `spec:` gate, this means the requirement moves out of the reviewer's brief into a step after the review. Doing that is work for the rework ticket.

---

❓ **Q5 - What does the reader do when it departs from a rule, or when a binding rule fights the goal?**

**The factory has five ways to depart from a rule, and they disagree:**
- say so and get a sign-off first ([AGENTS.md:26](AGENTS.md:26), [template/AGENTS.md:20](template/AGENTS.md:20));
- follow the file, then explain ([template/AGENTS.md:16](template/AGENTS.md:16));
- `skip: <reason>` (poteto-mode, except for delegation);
- record a Provisional decision;
- `accepted: <reason>` on writer flags.

None of them says how a subagent gets a sign-off.

**The research adds that the reader's own report misses a lot.**
- People who misread are confident in their reading.
- Chess masters said they were looking for a shorter mate while their eyes stayed on the familiar one (Bilalić 2008).
- Models used planted hints and seldom mentioned them.

**Proposal: one way, replacing all five.**
- **For a non-binding rule or note,** the reader departs when its judgment says to, and its report says where and why. This applies in the root session with you present too: no sign-off, because the departure is reversible and you see it.
- **For a binding rule that fights the goal,** the reader stops that part, reports the conflict to the rule's owner, and finishes the rest. With you present, it asks you.
- **The reader never narrows the goal to fit a rule.**
- **Every report states the route taken and where it differed from any notes,** as an expected part of the report, not an optional one. The wording matters. Survey respondents told that definitions were "essential" looked them up on 81% of questions; told they were "available," 23%. The report doesn't ask "where did a rule get in your way?", because that invites invented conflicts: assigned devil's advocates mostly strengthened the original view (Nemeth 2001).
- **Where a binding rule narrows what a subagent does, a later open pass covers what the subagent couldn't.** In Shin 2026, a separate critic with an open brief recovered every finding that a narrowly instructed model had dropped. That's a single-author preprint.

The options:
- (a) The proposal above.
- (b) Keep the sign-off rule for the root session and use the proposal for subagents.
- (c) Keep all five and add a path for subagents.

➡️ (a). The last bullet, the open pass, overlaps with "Decide where each piece lives and when it reaches the writer." If you'd rather decide it there, I'll carry it to that ticket as a note.

---

❓ **Q6 (new) - Which rules get a rung that blocks with no way past?** Belief 3 in [PHILOSOPHY.md](docs/knowledge/core/PHILOSOPHY.md) says a rule lives on the strongest rung that can hold it, so a hook or CI check beats a line of prose. A blocking hook has no override. Your principle says to leave a way for the agent to overrule rules that aren't absolutely necessary. The two collide wherever a non-binding rule has been pushed down to a blocking rung. Under this decision, every hook and gate that refuses would have to pass Q1's test.

The factory already has softer rungs:
- the git guard's refusal names a way forward ("Use --force-with-lease on your own branch, or ask");
- `skip: <reason>` and `accepted: <reason>` let a step be departed from visibly;
- a check can demand a reason instead of refusing.

The options:
- (a) Only binding rules get a blocking rung, and every refusal names a way forward, ending with asking the rule's owner. A non-binding rule that keeps coming up gets a rung that asks for a reason and then lets the action through. Belief 3 gains that qualifier.
- (b) Belief 3 stays as it is. Departures apply only to rules still written as prose.
- (c) Leave this to "Decide where each piece lives and when it reaches the writer."

➡️ (a). Garfinkel's point applies to hooks too. A block written in advance will meet a case its writer didn't foresee, and a refusal that names no way forward turns that case into a silent workaround or a stall. How the rungs work belongs to the other ticket. Whether belief 3 changes is a decision about how rules bound the route, so it belongs to this one.

---

When I record the resolution, I'll do two more things. First, I'll leave a note on "Decide how we'll know the writing works" and "Decide where each piece lives and when it reaches the writer": writers don't spot method in their own text, which makes this a checking problem and not something prose can fix. Shattuck found that commanders' written intent statements, meant to leave the method open, were full of method. Second, I'll rewrite my memory that still uses the old "protect the world" test.