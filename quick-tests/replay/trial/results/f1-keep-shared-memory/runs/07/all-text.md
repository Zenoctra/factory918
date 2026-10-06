I tried to post your answers word for word as a comment on the ticket, and the post was denied. They're saved verbatim in my scratchpad for now. I'll put them on the ticket with the resolution, or sooner if you tell me to. Your budget rule from Q5 is also saved to memory: in `safe` a budget never shapes the process; in `eco` and Let It Rip I ask you how binding it is first; when in doubt I leave it out; and a budget only binds if you approved it.

Before round two, here is Q1 again in plainer terms, since the rest builds on it.

## Q1 in plain terms

**The route belongs to the reader, unless the person who owns the work has deliberately made part of the route part of the job.**

Whoever writes the brief (the orchestrator, a subagent owner, me) can't make a rule bind just because they think it's a good idea. They can pass on your rules, and they can state facts they own, such as "another subagent is editing these files right now." Everything else they know about the route goes in as information with its reason. Your budget answer is this same rule applied to budgets.

Here's how that sorts some real rules in the factory. Each verdict is a question for you in Q6 below.

| Rule as it stands today | Who set it | Verdict |
|---|---|---|
| Never push to main | You (merging is yours) | Binds. A hook holds it. |
| The orchestrator never writes the code itself | You, with evidence | Binds. It's route, but you made it part of the job. |
| The trail review is mandatory | You (it caught the owner's errors 3 times out of 3) | Binds, for the same reason. |
| "Read nothing beyond this brief" in review briefs | A subagent, to save cost (#33). Nobody asked for it. | Doesn't bind. Delete it. |
| `knowledge`'s "never read more than 150 lines in one call" | Nobody. No reason is recorded. | Doesn't bind. Delete it, or keep it as information if a reason turns up. |
| "Execute only the task and path scope the parent assigns" (pstack lane wrapper) | Half fact, half guess | Split it. "These files belong to another subagent right now" is a fact it owns, so it binds. "Only the task" is a guess about the route, so it doesn't. |
| A ticket that made "halve token use" a closing requirement | A subagent turned your prediction into a requirement | Doesn't bind. Your Q5 answer. |
| `spec:` citation required, or it isn't a hard bug | Us, as a report format | It's a bar on finishing, so Q3 moves it to the filter step. |

## Round two

❓ **Q6 - Do those verdicts match what you mean?** If any row reads wrong to you, that row is where the test is wrong, and I'd rather find it now.

➡️ All eight as shown.

---

❓ **Q4, asked again with the five mechanisms laid out.** These are the ways the factory currently tells a reader what to do when a rule gets in the way:

1. **Ask first.** [AGENTS.md:26](AGENTS.md:26) and [template/AGENTS.md:20](template/AGENTS.md:20): "If one fights the task in front of you, say so loudly and get a sign-off before breaking it." Problem: a subagent running unattended has nobody to sign off. Nothing says how it would get one, and nothing records it ever being used.
2. **Obey first, explain after.** [template/AGENTS.md:16](template/AGENTS.md:16): "when this file and a vendored skill disagree with your instinct, follow the file and tell me why your instinct differed." This is the opposite default to #1.
3. **Decide and write it down.** [PHILOSOPHY.md:55](docs/knowledge/core/PHILOSOPHY.md:55): where the spec is silent, the agent chooses and records a Provisional row in `DECISIONS.md` so you can overrule it.
4. **Skip it, with a reason.** [poteto-mode/SKILL.md:113](template/.agents/skills/poteto-mode/SKILL.md:113): a playbook step you don't do stays in the list as `skip: <reason>`. [feature.md:12](template/.agents/skills/poteto-mode/playbooks/feature.md:12) then shuts that escape off for delegation.
5. **Stop and send it back.** A writer that can't build a table cell as written stops and reports it. Risks and writer flags must end `fixed: <sha>` or `accepted: <reason>`, or the review script refuses to run. Bad acceptance criteria go back to you.

They don't agree on the basic question: when the reader thinks a rule is wrong, does it obey, ask, decide, skip, or stop?

My proposal sorts it by the Q1 test:
- **Route knowledge** (doesn't bind): the reader uses its judgment, and its report always says where it took a different route and why, or says it took none. This replaces #2 and #4 for anything that doesn't bind, and keeps #3 for silences in the spec.
- **A binding rule that fights the goal**: the reader stops that part, reports the conflict to the rule's owner, and carries on with the rest. That is #5, made general, and it replaces #1, because "stop and report" works unattended and "ask first" doesn't.
- **Never**: shrinking the goal to fit a rule.

➡️ That proposal. #3 and #5 survive; #1, #2 and #4 are replaced.

---

❓ **Q7 - How is a binding rule worded and held?** The research says to drop emphasis (current Claude over-applies "CRITICAL / MUST"), give the reason, and say what to do instead of only what not to do. It also says every added rule costs the reader attention, which is your Q2 point. Your idea of a single term that pulls in many related rules, like a micro-genre, could cut that cost too.

The options:
- (a) The brief states each binding rule the reader's work is likely to run into, once, plainly, with its reason, and a hook holds it where one can. The hook's refusal message carries the reason and the way forward, since that arrives at the exact moment of use.
- (b) The brief leaves hook-held rules out and lets the hook teach them on contact.
- (c) Every brief restates every binding rule.

➡️ (a). (b) wastes turns: the ledger shows lanes losing turns to the worktree guard they didn't know about. (c) is the rule-count cost.

---

❓ **Q8 - Your worry under Q3, answered honestly.** Q3 fixes bars on reporting: a reviewer that finds a bug and stays quiet because of a bar. It doesn't fix your worry, and the research says your worry is real. What a reviewer is told to look for changes what it sees. That's the gorilla study, and Shin's preprint shows it in models. And "we're especially wary of X" is an example list, which pulls the reader toward X and away from everything else. The research's own fix is the same thing you reached for: more passes. In Shin's study, a separate reviewer with an open brief recovered every finding the focused one dropped.

The options:
- (a) When a kind of bug matters especially, it gets its own pass aimed at it, and the open reviewer's brief stays untouched.
- (b) Add a gentle mention to the open brief.
- (c) Neither.

➡️ (a).

---

❓ **Q9 - Where does the review system you described go?** You described a review system of the factory's own: multiple passes, better briefs, measured on recall and not just false positives. Spec-review looks mostly for bugs. `interrogate` looks wider but leads the witness too. No existing ticket covers this; "Choose each tier's review round count from the clean measurement" and "Eval the judge and trail-review models the way #103 evals reviewers" only touch parts of it.

The options:
- (a) Its own map, opened later, with your Q3 words quoted. This map keeps the wording of review briefs, through the ticket "Prototype brief templates for the recurring lane jobs", and gets a line under Out of scope pointing to the new map.
- (b) Fog on this map.
- (c) A single ticket here.

➡️ (a). It's process design, which is bigger than the writing, and your Q8 answer is already part of it.

---

Your note on rule count and terms that pull in many rules at once doesn't need a decision from you. I'll put it on the map as a hypothesis for two tickets: "Decide how we'll know the writing works", which would test how many rules get followed and whether a single term carries several of them, and "Decide what the writing standard is and what carries it". It goes there word for word.