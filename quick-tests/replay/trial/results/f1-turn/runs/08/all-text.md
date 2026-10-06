Your answers are below. I tried to post them word for word on the ticket so they're saved, and the post was declined. For now they're in this conversation, and they'll go into the ticket's resolution comment unless you want them posted sooner.

## Q1, in practice

Ask two things of any rule in a brief: **whose call is this, and did that person say it must hold?** The reader's own call is how it does its job. Nobody upstream can make that binding except you.

| Rule | Whose call | Did they say it must hold? | Result |
|---|---|---|---|
| Never push to main | Yours (merging) | Yes: AGENTS.md, plus a hook | Binds |
| The orchestrator never writes the code | Yours (how the factory runs) | Yes, decision P11, with evidence | Binds |
| Don't edit the files lane B is working in | The orchestrator's (it handed out the files) | Yes | Binds |
| Read only the diff | The reviewer's (how it reviews) | No: an orchestrator wrote it to save tokens | Doesn't bind; at most "the diff is attached" |
| Under 400 words | The reviewer's (how it reports) | No | Removed (Q3) |
| Cut token use in half | Yours | Never asked; it was a prediction | Doesn't bind (your Q5 story) |

## Q2, your note on terms that carry many rules

I'm keeping it as a standing note for the whole map. The research has one relevant number: with 500 instructions, the best model followed 68%. Nothing in it tests a single term that carries a cluster of rules, the way a micro-genre carries a style. That fits in two tickets:
- "Decide how we'll know the writing works" can run the experiment: how many rules get followed, and whether one term does the work of several.
- "Decide what the writing standard is and what carries it" can apply what the experiment finds.

## Q3, a correction to "both get found"

The evidence doesn't say that. It describes two different failures:
- **A bar on what to report.** The reviewer still finds the bug but doesn't report it. Reporting everything fixes this.
- **A narrow focus.** The reviewer never looks at the other kind of bug at all. This is your worry, and it does happen: the gorilla study, and Shin's preprint on models. Reporting everything doesn't fix it.

In Shin's study, what fixed the second failure was a second reviewer with an open brief, not a nudge in the first reviewer's brief. Your sense that "especially wary of X" brings headaches matches the evidence: naming a few kinds of bug pulls answers toward them and suppresses recall of the others. Coverage comes from several passes, each starting from a different angle, with a verifier sorting the findings afterward. So (a) stands for this ticket, and the coverage question goes to wherever review gets designed (Q6).

## Q5, as I understood it

- **`safe`:** budget never shapes the process. It's measured only after the fact.
- **`eco` and Let It Rip:** a token budget, plus a wall-clock budget in Let It Rip, enters a brief only after you've been asked how binding it is.
  - When in doubt, leave it out.
  - If it seems important and nobody can ask you, it goes in as information, not as a limit.
  - It binds only when you've approved it as binding.
- **Predictions never become criteria.**

This is Q1's test applied to budgets: the budget is your call, so only you can make it bind. If I've misread any of it, say so.

---

## Round two

❓ **Q4 - What happens when the reader departs from the route, or when a binding rule fights the goal?** Here are the five mechanisms the factory has now:

1. **Ask first.** "If a rule fights the task, say so loudly and get a sign-off before breaking it." ([AGENTS.md:26](AGENTS.md:26), [template/AGENTS.md:20](template/AGENTS.md:20).) Nothing says how a subagent gets a sign-off when nobody is there to give it.
2. **Comply first.** "When this file disagrees with your instinct, follow the file and tell me why your instinct differed." ([template/AGENTS.md:16](template/AGENTS.md:16).) This is the opposite default to 1.
3. **Decide and record.** Where the spec is silent, the agent makes the call and logs a Provisional decision you can overrule. (PHILOSOPHY, DECISIONS, [ticket.md:30](template/.agents/skills/poteto-mode/playbooks/ticket.md:30).) This one also pulls against 1: decide yourself, versus ask first.
4. **Skip visibly.** Upstream pstack lets a step be skipped with a written `skip: <reason>`. Our [feature.md:12](template/.agents/skills/poteto-mode/playbooks/feature.md:12) forbids that for delegation.
5. **Stop and send it back.** A writer that can't build a cell as specified stops and reports it. Each writer flag must end `fixed` or `accepted: <reason>`. A design hole amends the ticket. Bad acceptance criteria go back to you.

**My proposal: one mechanism in place of the five.**
- **Departing from route knowledge:** the reader uses its judgment, and its report always says where it took a different route and why, or that it took none. Nobody has to ask permission. This keeps the shape of 3 and 4.
- **A binding rule that fights the goal:** the reader stops that part, tells the rule's owner, and carries on with the rest. This is 5 made general. In your main window the owner is you, so this is 1's sign-off, still working where a person is present.
- **The reader never shrinks the goal to fit a rule.**

This retires 2 and narrows 1 to sessions where you're present. 3 stays as it is, because it covers a spec that says nothing, not a rule that fights the goal.

➡️ The proposal above.

---

❓ **Q6 - Where does the review system get designed?** Your note on review is bigger than this map. It covers several passes, each starting from a different angle; verifiers that sort findings by kind; measuring how many known bugs get missed rather than celebrating zero false positives; and `interrogate` leading the witness too. This map decides how the writing treats rules, and the ticket "Prototype brief templates for the recurring lane jobs" writes the review briefs. Neither decides how many passes there are or what each one looks for.
- (a) Open a sixth map for the factory's own review system. This map's decisions feed into it.
- (b) Add it to this map as fog that becomes tickets later.
- (c) Fold it into the brief-templates ticket.

➡️ (a). It's process design with its own measurements, and it would stretch this map's destination well past writing. On this map, it goes under Out of scope with a pointer to the new map. Charting that map would be its own session, when you choose.

---

❓ **Q7 - How should a binding rule be worded and held?** The research points one way: plain wording rather than emphatic, the reason given, and what to do instead rather than a bare "don't". A hook's refusal message reaches the reader at the moment it matters, which is the only placement the research found works for models. The open choice is whether a brief also restates a rule that a hook already holds.
- (a) A brief restates only the binding rules this reader is likely to walk into on this job, one line each with the reason. The hook holds the rest, and its refusal message carries the reason and a way forward.
- (b) Every brief restates every binding rule.
- (c) A brief restates none of them, and the hooks do all the work.

➡️ (a). With (b), each extra rule weakens the others, which is your Q2 point. With (c), lanes lose turns walking into the guard, which the ledger records happening more than once.