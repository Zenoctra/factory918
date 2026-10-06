I tried to save your answers word for word as a comment on this ticket, and the post was declined. They're held in this session for now and will go into the ticket's resolution comment, which I'll show you before posting.

**Settled from round one:**
- **Q2:** (b), route knowledge goes in as a resource with its reason.
- **Q3:** (a), the reader reports everything with its own severity, and any bar is applied in a later step.
- **Q5, budgets:**
  - In `safe` (the factory's name for the first mode), a budget never shapes the work. It's only measured afterward.
  - In `eco` and Let It Rip, a token or wall-clock budget is never written into a brief as binding until you've been asked how much it matters.
  - When in doubt, leave the budget out.
  - If it seems important and there's no chance to ask, it goes in as information, never as a limit.

  Your story about the token-cut prediction that became a closing requirement goes beyond budgets. A writer's prediction must never become what "done" means, which is the same lesson as the "at most" list on P109. I'll write it into the answer that way.
- **Your point on terms that pull a whole cluster of rules** (the micro-genre idea) is noted for "Decide how we'll know the writing works" and "Decide what the writing standard is and what carries it". It's a testable claim, and the research found nothing on it.

## Q1 again, in plain terms

Think of hiring a roofer.
- The homeowner says: fix the leak over the kitchen (what's wanted). It's done when the hose test shows no drip (what done means). Don't touch the solar panels, because the leasing company owns them (not the roofer's call). These **bind**: each is about the job, and the person who owns it said so.
- The homeowner also says: the last roofer got in through the attic hatch. That's **advice**. It helps, it comes with a reason, and the roofer can go over the roof instead and say so.
- **Not allowed:** the homeowner's nephew, who owns nothing, telling the roofer to use only the north ladder to save time. In the factory, the nephew is the orchestrator inventing route rules in a brief.

Applied to real rules in the factory today:

| Rule | About the job, or the route? | Who owns it | Verdict |
|---|---|---|---|
| Never push to `main` | The job: merging is your call | You | Binds |
| The orchestrator never writes code; it delegates ([AGENTS.md:26](AGENTS.md:26), plus the hook) | Route | You, with evidence: it was broken even when stated, so a hook holds it now | Binds, because you made it bind |
| "Read no brief and no diff while the review state exists" ([ticket.md:13](template/.agents/skills/poteto-mode/playbooks/ticket.md:13), `eco` owner) | Route | Written in P109; no reason is given, and I can't find that you asked for it | Advice with its reason, unless you claim it |
| "Never read more than 150 lines in one call" ([knowledge/SKILL.md:20](template/.agents/skills/knowledge/SKILL.md:20)) | Route | Written by an agent, no reason recorded | Advice, or cut |
| "Execute only the task and path scope the parent assigns" (pstack wrapper) | Both, in one sentence | Upstream | Split it. "Don't write outside your files" binds, because another lane owns them. "Don't look outside" is route, so it goes. |
| An item without a `spec:` line "is sent back" ([review-brief.sh:494](template/.agents/skills/spec-review/scripts/review-brief.sh:494)) | Finishing rule | Agent-written | Goes, under your Q3 |
| "Primary focus must be the happy path…" and "An edge case outside the intended path being unsupported is not a flag" ([review-brief.sh:488](template/.agents/skills/spec-review/scripts/review-brief.sh:488)) | The job: your priority | You | This is where Q1 and Q3 meet; see Q6 |

## Round two

❓ **Q6 - Your happy-path priority, and the "slight push"**: You asked whether the evidence says both kinds of bug get found. Partly. It points to two different costs:
- **A bar** in the brief ("an unsupported edge case is not a flag") costs **reporting**. The reviewer still finds the problem and doesn't write it down. Radiologists did this, and Anthropic reports the same of its models. Moving the bar to a later step fixes it, which is your Q3 answer.
- **A focus** in the brief ("we're especially wary of X") costs **seeing**. Observers counting passes missed the gorilla. In the one model study of this, a focused instruction hid critical findings, and a second reviewer with an open-ended brief recovered them. No study tests a gentle push with no bar, but the evidence on focus suggests even a gentle one narrows what gets seen. Moving it to a later step doesn't fix this; only another pass does.

So your two rules in `review-brief.sh` are a priority you own, and today they sit in the reviewer's brief as a bar. The options:
- (a) Leave them where they are.
- (b) Take them out of the reviewer's brief. The reviewer reports everything, and the step that rates findings ranks each one against your priority.
- (c) Same as (b), plus the brief tells the reviewer, as information, what you care about most and why, with "report everything you find" next to it.

➡️ (b). Getting coverage of the kinds of bug you care about most becomes a question of how many passes there are and what each one is for (Q9), not of how to word one brief.

---

❓ **Q7 - One way to depart from a rule, replacing five**: Here are the five the factory has now:
1. **Ask first.** "If one fights the task in front of you, say so loudly and get a sign-off before breaking it" ([AGENTS.md:26](AGENTS.md:26), [template/AGENTS.md:20](template/AGENTS.md:20)). A subagent has no way to ask, and no record shows this being used.
2. **Obey, then explain.** "When this file and a vendored skill disagree with your instinct, follow the file and tell me why your instinct differed" ([template/AGENTS.md:16](template/AGENTS.md:16)). That's your voice in your note.
3. **Decide and record.** Where the spec says nothing, the agent decides and writes a Provisional row in `DECISIONS.md` that you can overrule.
4. **Skip visibly** (upstream poteto-mode). A step you don't do stays in the list with `skip: <reason>`. Delegation is the exception: it can't be skipped.
5. **Stop and send it back.** A writer that can't build a table cell stops and reports it. A writer flag must end `accepted: <reason>`. A design hole amends the ticket.

They contradict each other: the first says ask first, the second says obey first, the third and fourth say act and record, and the fifth says stop. A reader can't tell which applies.

➡️ My proposal:
- **Departing from advice** (Q2): the reader uses its judgment. Every report carries one line, "Where I took a different route than the brief suggested, and why", or "None". This replaces 4.
- **A binding rule that fights the goal:** the reader stops that part, reports to the rule's owner, and carries on with the rest. This generalizes 5. When you're live in the main session, that report reaches you directly, so it also covers 1.
- **A gap in the spec** is not a departure, so 3 stays as it is.
- **Mechanism 2 is your call.** It says your copied patterns outweigh an agent's instinct, which pulls against your correction that an agent may see a better way than the rule predicted. I'd keep the preference and its reason ("a copied professional pattern beats a first-principles idea from someone who hasn't seen it") as weighty advice, with departures reported on the line above. Your note's rules would then be advice unless you mark one as binding.

---

❓ **Q8 - How binding rules are worded**: The few rules that do bind still have to be written. The research gives three findings:
- Current Claude models over-apply emphatic wording like CAPS and "MUST".
- A bare "don't" keeps the forbidden idea active and doesn't say what to do instead, so the model lands on some other default.
- A rule with its reason is followed better and generalized more sensibly.

The options:
- (a) Every binding rule is in plain words, with its reason and with what to do instead.
- (b) Emphasis is allowed for the few that matter most.

Where each rule lives, and whether a hook's refusal message carries it at the moment it bites, belongs to "Decide where each piece lives and when it reaches the writer".

➡️ (a).

---

❓ **Q9 - Where does "our own review system" go?** You described a review system of our own: more than one pass, better briefs, measured against planted bugs instead of praised for having no false positives. That's process design (passes, verifiers, measurement), and it's bigger than this map's destination, which is the writing. The options:
- (a) Fog on this map.
- (b) A map of its own, which takes this map's decisions as input. The review briefs themselves stay in scope here, in "Prototype brief templates for the recurring lane jobs".
- (c) One ticket on this map.

➡️ (b). I'd record it under this map's Out of scope with a pointer, and open the new map when you say so. "Choose each tier's review round count from the clean measurement" and "Eval the judge and trail-review models the way #103 evals reviewers" would likely move under it.