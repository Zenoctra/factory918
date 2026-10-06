I tried to post your answers word for word as a comment on the ticket, and that was blocked. They're saved locally in my scratchpad for now. I won't try again unless you say to. Otherwise they go into the resolution comment when the ticket closes.

Here's where your answers leave things, and then round two.

**Settled**
- **Q1 (c):** a rule binds only if it's about the task itself and someone with the authority to set it said it binds. Q1 below shows what that looks like with real factory rules, since my first version was too abstract.
- **Q2 (b):** what the writer knows about how to do the job goes in as information with its reason, never as an order. I'm keeping your note on rule count and on terms that carry many rules at once, like your micro-genre example. It's a good hypothesis, and so far nobody has tested it. It belongs with the ticket "Decide how we'll know the writing works", as an experiment: how many rules get followed, and whether one well-chosen term does the work of several rules.
- **Q5:** the budget answer depends on the mode.
  - In `safe` (the first mode, which you called Safety Mode), a budget never shapes the process. It's only used afterward, to measure.
  - In `eco` and Let It Rip, a token budget, and also wall-clock time in Let It Rip, reaches a brief only after you've been asked how binding it is.
  - When in doubt, leave it out. If it seems important and there's no chance to ask, it goes in as information. Anything written as binding is something you approved.
  - Your story fits this: a prediction became the bar for closing the ticket. It's the same failure as the "at most" list on #109.

**Your Q3 worry is fair, and I overstated the evidence.** The research shows that a bar on what to report hides findings the reviewer already made. It doesn't show that a reviewer sees every kind of bug. The gorilla studies point the other way: what a reader is told to look for decides what it sees. So I can't promise "both get found."

That's also why your "slight push toward the bugs we care about" would cause the headache you expected. Covering different kinds of bugs is a job for more independent passes, and in Shin's study a second reviewer with an open brief recovered every finding the narrow one hid. That's the review-system work you described. It appears as Q3 below.

One thing I found while checking: your own priority on kinds of bugs is already in the review brief, in your words ([review-brief.sh:488-489](template/.agents/skills/spec-review/scripts/review-brief.sh:488)): "Primary focus must be the happy path, then unhappy paths that error in a way the user can correct," and "An edge case outside the intended path being unsupported is not a flag." Q2 asks where that belongs now.

---

❓ **Q1 - Do these verdicts match what you meant by (c)?** Here's (c) applied to six real factory rules. For each one, ask two things: is it about the task (what's wanted, what done means, what isn't the reader's to decide), or about how to do it? And did someone with the authority to set it say it binds?

| Rule | About the task or the route? | Who set it | Verdict |
|---|---|---|---|
| Never push to `main` (git guard hook) | The task: merging is your decision | You | **Binds** |
| The orchestrator never writes the code; a lane does (delegation hook) | The route | You, with evidence it was being broken | **Binds**, because you set it |
| The trail review is mandatory | The route | You, after it caught the owner's mistakes 3 of 3 times | **Binds**, because you set it |
| Subagents never start their own dev servers ([template/AGENTS.md:68](template/AGENTS.md:68)) | Mixed: ports and processes are shared with other lanes, which isn't the reader's to decide; the rest is route | Adopted from Theo, reason dropped | **The shared-machine part binds**, with its reason restored. The rest becomes information |
| `knowledge`: "never read more than 150 lines in one call" ([knowledge/SKILL.md:20](template/.agents/skills/knowledge/SKILL.md:20)) | The route | No recorded owner or reason | **Doesn't bind.** It becomes information with a reason, or gets deleted |
| A review finding without a `spec:` line is sent back ([review-brief.sh:494](template/.agents/skills/spec-review/scripts/review-brief.sh:494)) | A bar on finishing | Built into the script | **Moves to the filter step (your Q3 answer).** The reviewer reports every bug, and the citation is added or checked afterward |

There's an open case these rows don't settle: rules in vendored skills, such as poteto-mode's "copy the playbook's steps in verbatim." My memory says upstream constraints stay and only factory-written text is suspect. Under (c), you'd be the owner who adopted them, so they bind until you say otherwise.

➡️ The table as written, and vendored rules bind until you rule on them one by one. If any verdict surprises you, that's where my reading of (c) differs from yours, and I'd rather find that now.

---

❓ **Q2 - Where does your priority on kinds of bugs go?** Your two lines in the review brief do two different things:
- "Primary focus must be the happy path, then unhappy paths…" says what matters to you. That's context about the goal.
- "…is not a flag" is a bar on reporting. Under your Q3 answer, it moves to the filter step.

The options:
- (a) The reviewer sees what matters to you as context, worded as your priority, without "don't report X". It reports everything. The filter ranks findings by your priority.
- (b) Only the filter sees it. The reviewer gets no hint of what you care about.
- (c) Both, unchanged.

➡️ (a). Telling the reviewer what's at stake is the task-relevant context the forensic evidence says helps. Telling it where to look or what not to report is what hurts. Your words stay as you wrote them, and only the "is not a flag" half moves.

---

❓ **Q3 - Where does the review system go?** You said review may be the most important step, that it needs more passes and better briefs, and that even vendored `interrogate` leads the witness. This map's destination covers how review briefs are written: the ticket "Prototype brief templates for the recurring lane jobs" includes the reviewer templates. It doesn't cover how many passes there are, who runs them, or how findings get filtered and verified.

The options:
- (a) A new wayfinder map, "Design the factory's own review system," fed by this map's decisions.
- (b) Fog on this map, under Not yet specified.
- (c) A note on the map "Optimize token use and wall-clock time without losing reliability."

➡️ (a). It's as large as any of the five maps. Your point that a system can claim no false positives while missing half the planted bugs is the right starting question for it. This map would hand it the writing rules. I'd record it here as a pointer, not chart it now.

---

❓ **Q4 - What replaces the five ways an agent departs from a rule?** Here they are, as the factory has them today:

1. **Say so loudly and get a sign-off.** "If a rule fights the task in front of you, say so loudly and get a sign-off before breaking it" ([AGENTS.md:26](AGENTS.md:26), [template/AGENTS.md:20](template/AGENTS.md:20)). It came from Theo. Nothing says how a subagent with nobody to ask gets a sign-off, and it pulls against "Proceed on anything reversible" two lines earlier.
2. **Follow the file, then explain.** "When this file and a vendored skill disagree with your instinct, follow the file and tell me why your instinct differed" ([template/AGENTS.md:16](template/AGENTS.md:16)). It's the opposite default to 1: comply first, report after.
3. **Decide and record a Provisional row.** Where the spec is silent, the agent makes the call and adds a line to `DECISIONS.md` "so the next agent does not re-derive it and Manuel can overrule it" ([PHILOSOPHY.md:55](docs/knowledge/core/PHILOSOPHY.md:55)).
4. **Skip a step visibly** (upstream pstack). "A step you choose not to do stays in the list with a one-line `skip: <reason>`; skipping silently is not allowed" ([poteto-mode/SKILL.md:113](template/.agents/skills/poteto-mode/SKILL.md:113)). Delegation is excluded: "no skip-with-reason escape."
5. **Settle it on the artifact.** A writer's flag must end `fixed: <sha>` or `accepted: <reason>`, or the review script refuses to run. A writer that can't implement a cell of the scenario table stops and reports it. A design hole amends the ticket with a dated line.

These handle different situations, which is part of why they conflict:
- 1 and 2 are for a rule that fights the task.
- 3 is for a gap the rules don't cover.
- 4 is for a route step the agent thinks isn't needed.
- 5 is for a mismatch between the work and its spec.

Only 1 and 2 overlap, and they give opposite answers.

The proposal:
- **Route knowledge:** the reader uses its judgment. Its report always says where it took a different route and why, or that it took none. This covers 4, and the report line replaces the `skip:` line.
- **A binding rule that fights the goal:** the reader stops that part, reports the conflict to whoever owns the rule, and carries on with the rest. It never shrinks the goal to fit the rule. This replaces 1 and 2. A subagent's owner is whoever briefed it, which settles the sign-off question.
- **A gap or a spec mismatch:** 3 and 5 stay as they are. They're already the "decide, record, let the owner overrule" shape.

➡️ The proposal. The real change is 1 and 2 merging into one rule that works for a subagent too. "Follow the file and tell me why your instinct differed" survives only for binding rules. For everything else, the instinct gets used and reported.