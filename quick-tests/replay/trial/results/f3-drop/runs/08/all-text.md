Yes. After reading the research, I'd ask a different set of questions, and two of my earlier recommendations don't hold up. This round replaces the first one, so please answer this one instead. The evidence comes from [the research note](https://github.com/Zenoctra/factory918/blob/research/wording-and-reader-context/docs/research/wording-and-reader-context.md) (§ numbers below), and the repo cases come from the search I ran earlier.

**What changed:**

1. **My first question tried to sort rules ahead of time, by what they're about.** The research gives a reason why that can't work. No instruction written in advance contains every situation it will meet (Garfinkel and Suchman, §4). When military officers wrote statements of intent, the statements carried the intent only 34% of the time, and they were full of method (§4). My sorting test was itself a rule written in advance. So the weight moves:
   - from "which rules bind"
   - to "what every rule carries, so the reader can tell when it no longer fits": its reason and its owner.
2. **I had put two things on the safe side that aren't safe:**
   - "What done means." A measure tends to replace the goal it stands for.
   - Offering a method "as knowledge, not an order." An offered method anchors the reader even when it's optional.
3. **The research raised three questions I hadn't asked:**
   - holding back the writer's own conclusions, which protects the reader and doesn't bound it;
   - moving any necessary narrowing into a separate step;
   - required steps in the playbooks.

These questions are where I see decisions now. They aren't the edge of the question.

---

❓ **Q1 - What may bind a reader at all?** Things the evidence points at:
- Instructions are always incomplete (§4).
- Current Claude models read instructions literally and don't infer what the prompt didn't ask for (§11).
- Emphatic wording ("you MUST") gets over-applied (§4).
- A rule that comes with its reason is applied more flexibly, because the model generalizes from the reason (§9).
- In this repo, the rules about method that worked were ones you set, with evidence behind them: the required trail review and the delegation hook.

Options:
- (a) Sort by content (my old test).
- (b) Sort by authority. A rule binds only where someone with authority over that decision said it must. A writer passes such rules down and never invents them.
- (c) No binding rules in prose at all. Anything that must hold goes into a hook or script, and prose only informs.

➡️ (b), moving toward (c). Every binding rule names its owner and its reason. Where a hook or script can hold it, it lives there, and the prose says the hook holds it instead of restating it as an order. An orchestrator binds only what it owns, such as which files another lane is writing right now. (This folds in my old Q4.)

---

❓ **Q2 - Is "what done means" safe to bind?** Two lines of evidence:
- **People** (§4). When a measure stands in for the goal, people pursue the measure. Police under pressure to cut crime rates stopped recording crimes. Managers acted as if the measure were the strategy, without noticing, and simply knowing they were measured was enough.
- **This repo.** The Standards brief required every hard finding to cite the ticket, and the brief never showed the ticket. An honest reviewer obeyed and filed nothing on a PR that had four real bugs. Your ruling on the "at most N lanes" criterion called it "a prediction, not a constraint."

Options:
- (a) Done-criteria bind as written.
- (b) Only the goal binds. Criteria are stated as evidence that the goal was met. When the two disagree, the goal wins and the reader says so.
- (c) Leave criteria out of briefs.

➡️ (b). This is already your ruling for tickets. The change is to extend it to every brief, and to every check a reader is held to.

---

❓ **Q3 - How does a writer pass on what it knows about the route?** My old answer, "write it as knowledge, with the reason," doesn't survive the evidence:
- Chess masters shown a familiar mate missed a shorter one. They said they had looked for it, but their eyes stayed on the familiar squares (§2).
- Designers copied the flaws of an example even when told about the flaws (§2).
- Guidance helps beginners (d = 0.51) and hurts experts (d = −0.43) (§4).
- When people could add their own ideas to a list, 8 of the 10 best ideas came from outside the list the organizers seeded (§2).
- Stating a rule as information rather than control does help (§4), but an offered method still anchors.

That suggests a different line. **Facts about the terrain** are things the reader would otherwise pay to rediscover: this command fails inside a worktree, this file is generated, the suite takes 30 seconds. **A method** proposes the route: read X first, check Y, use approach Z.

Options:
- (a) Leave out all route knowledge.
- (b) Give terrain facts with their reasons. Leave methods out, except on simple, routine tasks, where the evidence says method helps.
- (c) Give methods as optional suggestions.

➡️ (b). One caveat: terrain versus method is another two-way split, the same shape as the one you rejected. I'd offer it to writers as a question to ask themselves ("would the reader pay to find this out, or am I proposing how to do the job?"), not as the test.

---

❓ **Q4 - Is holding something back from the reader a way of bounding it?** The evidence:
- Fingerprint experts reversed their own earlier matches after being given context suggesting otherwise (§3).
- Telling a model the code was bug-free cut vulnerability detection from 97% to 4% in a small model, and from 96% to 89% in Opus 4.5 (§3).
- Models use hints they never mention in their reasoning, so reading a lane's reasoning won't catch it (§3).
- Relevant facts help: across 16 studies, clinical information made medical tests read more accurately, with no loss (§3).

The line the field draws is between **what the writer volunteers** and **what the reader may seek**.

Options:
- (a) From a reader who judges or searches, hold back the writer's own conclusions and expectations: what it expects to find, how many, whether it thinks the code is fine, what earlier rounds found. Never limit what the reader may look at, and give relevant facts freely.
- (b) Share everything and trust capable models.
- (c) Decide case by case.

➡️ (a). Your rule that later review rounds stay blind to earlier findings is already this. The standard should name the difference, for two reasons:
- so "give the reader everything" doesn't turn into leading;
- so "keep the reader independent" doesn't turn into "don't read X".

---

❓ **Q5 - When the work genuinely has to be narrowed (cost, time, a filter), where does the narrowing go?** The evidence:
- Anthropic's guide for Opus 4.8: when told "only report high-severity issues," the model still found the bugs, then left them out of its report. The guide's fix is to ask for every finding with a confidence and severity, and filter in a separate step (§4).
- Radiologists who had already found one problem kept searching but became reluctant to report a second (§4).
- In one preprint, a narrow task instruction stopped models reporting critical findings they reported otherwise. A separate reader with an open-ended brief recovered all of them (§4).
- Tight output budgets cut a reasoning model from 72% to 53% (§4).

Options:
- (a) A budget is stated as a fact, and the reader plans within it (my old answer).
- (b) The narrowing never sits inside the reader doing the work. The reader works openly, and a separate step filters, ranks or trims. When a reader must be narrow, an open-ended pass runs alongside it.
- (c) Caps are allowed when you set them.

➡️ (b), with (a) for limits that are real facts of the situation, such as a deadline or a context size. The numbers belong to the map "Optimize token use and wall-clock time without losing reliability".

---

❓ **Q6 - What does the reader do when a rule pulls away from the goal?** The factory has five answers today, and they conflict:
- say so and get a sign-off first;
- follow the file, then explain;
- make the call and record it for you to overrule;
- skip visibly with a reason, except for delegation, where that's forbidden;
- end every writer flag with "fixed" or "accepted".

The evidence bears on how one replacement should work:
- **Readers who misunderstand rarely notice, and rarely ask.** On unusual cases, scripted interviews got 28% right and interviews that allowed clarification got 87%. Respondents told they could ask did so 4% of the time (§8).
- **The wording of a permission decides whether it gets used.** Readers told definitions were "essential" checked them 81% of the time; told they were "available," 23% (§8).
- **A literal reader won't assume a permission it wasn't given.**
- **Assigned dissent was weaker than genuine dissent** (§3). So departing from the brief shouldn't become a role the reader plays.

Options:
- (a) One mechanism. For anything not authority-bound, the reader serves the goal over the brief and reports each departure and its reason as a normal part of the report. For a binding rule, it stops that part, reports to the rule's owner, and carries on with the rest. It never narrows the goal to fit a rule.
- (b) Sign-off for everything. This doesn't work for a lane running unattended.
- (c) Break and report for everything.

➡️ (a), replacing all five. The reason attached to each rule (Q1) is how the reader notices a conflict. The departure report also does a second job. The research found that the thing that reliably improved writers was signal from real readers:
- Writers who studied transcripts of readers struggling got better, and the gain carried over to new kinds of text (§10).
- A hospital handoff that ends with the receiver restating the plan was followed by 23% fewer medical errors (§10).

So departures become data for the ticket "Decide how we'll know the writing works".

---

❓ **Q7 - Do required playbook steps bound the method?** The evidence points both ways:
- **For required steps:**
  - The required trail review caught owner errors three times out of three.
  - Skipping architect let a hook bug survive four review rounds.
  - The open-ended second reader in Q5 recovered every missed finding.
- **Against:**
  - The expertise reversal from Q3.
  - The philosophy says playbooks make the agent "follow a script rather than improvising."
  - Of 77 delegates in run 1, 9 changed an outcome.

A tempting split: rules that add a look help, and rules that cap one hurt. Most of the harm in the audits came from caps, and most of the good from added looks. But a script that dictates how each step goes is an added look that still decides the method, so I don't trust that split as the test.

Options:
- (a) A required step states what must have happened and why, for example "someone who didn't write the code reviewed the diff." How it happens is the reader's choice. Whether the step is required is yours to own.
- (b) Playbooks stay scripts, and this ticket covers briefs only.
- (c) Defer to the rework ticket.

➡️ (a) for the factory's own steps. Upstream pstack stays as vendored, per your earlier rule, and any change to it goes through "Decide the scope and order of reworking existing files".

---

**Passed to sibling tickets, no decision needed now:**
- **To "Decide what the writing standard is and what carries it":** whatever we decide here won't hold as a stated principle. Telling people to imagine the other person's view made them slightly *less* accurate. A generic system prompt barely helped models. A reminder about the specific reader, at the moment of use, closed most of the gap (§10). This decision needs a carrier at the moment a brief is written.
- **To "Decide how we'll know the writing works":** no study tests limits on method in models. The vendor's notes cover Opus 4.8, not 5.5. The illustrative-list experiment has never been run. Everything above is inference from people plus nearby model evidence, so it's worth testing here.
- My memory still holds the old test. I'll rewrite it once this round settles.