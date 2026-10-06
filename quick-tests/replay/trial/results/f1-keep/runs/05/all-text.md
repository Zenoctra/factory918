Two of your answers need more from me before you can settle them. Q1 needs a concrete version, and on Q4 you're right: I never listed the five mechanisms. Both are below, followed by two new questions.

---

❓ **Q1 - What (c) looks like in practice**: Each rule gets two questions:

1. Is it about **what** gets made, or what isn't the reader's to decide? Or is it about **how** the reader works?
2. Did someone who **owns that decision** set it?

If the answer to both is yes, the rule binds. Otherwise it's advice with a reason the reader can weigh, or it gets cut. Here it is on real rules:

| Rule | What or how? | Set by its owner? | Result |
|---|---|---|---|
| "Never push to main" | What: merging is your decision | You | Binds |
| "The orchestrator never writes the code" | How | You, with evidence; a hook holds it | Binds |
| An orchestrator tells a reviewer "read only the diff" | How | No. The orchestrator doesn't own how a review is done | Doesn't bind. At most: "the diff touches X; its callers are in Y" |
| "Another subagent is editing file C" | What: C isn't this reader's to change | The orchestrator assigned the work, so yes | Binds for editing C. Reading C is fine |
| "Nothing wider is redesigned" ([ticket.md:45](template/.agents/skills/poteto-mode/playbooks/ticket.md:45)) | What: the ticket's scope | The ticket, which you approved | Binds for what changes. Problems found beyond the scope get reported or ticketed, not ignored |
| "Never read more than 150 lines in one call" (`knowledge`) | How | Nobody recorded why | Doesn't bind. It goes |

The second column is what stops an orchestrator from turning its guess about the route into a rule. The third column is what keeps your own rules about the route, like delegation and the trail review, binding.

➡️ If this table matches what you meant by (c), Q1 is settled. If any row looks wrong to you, that row is the conversation to have.

---

❓ **Q4 - The five mechanisms, and what the proposal does to each**: Here is what exists today:

1. **Speak up and wait for a sign-off.** [AGENTS.md:26](AGENTS.md:26) and [template/AGENTS.md:20](template/AGENTS.md:20) say: "If a rule fights the task, say so loudly and get a sign-off before breaking it." It came from Theo. A subagent has nobody to sign off, and the rule pulls against "never block on the human".
2. **Follow the file first, then explain.** [template/AGENTS.md:16](template/AGENTS.md:16): "follow the file and tell me why your instinct differed." This is the opposite default to 1: obey, then report.
3. **Decide, and record it as Provisional.** Where the spec is silent, the agent makes the call and logs a Provisional row in `DECISIONS.md` for you to overrule.
4. **Skip a step visibly.** poteto-mode, from upstream: a skipped step stays in the list as `skip: <reason>`. [feature.md:12](template/.agents/skills/poteto-mode/playbooks/feature.md:12) forbids this for delegation.
5. **Send it back to the artifact or to you.** This takes several forms:
   - Each writer flag must end `fixed:` or `accepted: <reason>` before review.
   - A writer that can't build a test cell stops and reports it.
   - A design hole amends the ticket.
   - The falsifiability pass returns bad criteria to you.

What the proposal does to each:

| Today | Under the proposal |
|---|---|
| 1. Sign-off first | **Replaced for rules about how.** The reader uses its judgment, and its report always says where it took another route and why. **Changed for binding rules:** the reader stops that part and reports the conflict to the rule's owner instead of waiting. An unattended subagent can do that. |
| 2. Follow first, explain later | **Replaced** for rules about how, which become advice. For binding rules it already holds. |
| 3. Decide and record Provisional | **Kept.** It isn't a departure from a rule. It fills a gap no rule covered, the gap Garfinkel says always exists. |
| 4. `skip: <reason>` | **Absorbed** into the report line. The delegation exception stays, because delegation binds (Q1). |
| 5. Send it back | **Kept.** These are already cases of "stop that part and report to the owner". |

Two lines are new everywhere. The reader never shrinks the goal to fit a rule. And the report says "I took no other route" when that's true, so silence never stands for that.

➡️ Adopt it.

---

**Q5, restated so you can check I have it right:**

- In `safe` (the name of the first mode), budget never shapes process. It is only measured afterward, to look for savings.
- In `eco` and Let It Rip, a token budget (and in Let It Rip, also wall-clock time) reaches a reader only after you've been asked how binding it is.
- When in doubt, the budget isn't mentioned at all.
- If it seems important and there's no way to ask you, it goes in as information, not a limit.
- It binds only with your approval.
- A predicted saving never becomes a condition for closing a ticket.

**Q2 and Q3 are settled.** Your note on Q2 is that one well-chosen term can carry a whole cluster of rules, the way a micro-genre does for a song, and that this needs testing. That goes to the tickets "Decide how we'll know the writing works" and "Decide what the writing standard is and what carries it", with your words quoted in full. At the end of this ticket I'll post all your answers to it word for word.

---

❓ **Q6 - How a binding rule is worded**: The research points one way:

- Emphatic wording ("CRITICAL", "MUST") makes current Claude over-apply a rule.
- A bare "don't" keeps the forbidden thing in mind and doesn't say what to do instead.
- A line repeated in every brief gets read past as boilerplate.
- A rule with its reason is followed more flexibly.

➡️ A binding rule is written once, in plain words, with its reason and what to do instead. Where possible, something refuses the action, like a hook or a script. Its refusal message gives the reason and a way forward, because that's the moment the reader needs them. Whether the rule also appears in each brief is the placement question, and that belongs to the ticket "Decide where each piece lives and when it reaches the writer".

---

❓ **Q7 - Where the review-system work goes**: You described a whole review system of the factory's own: several passes, briefs that don't lead, judged on what they miss and not just on false positives, and `interrogate`'s wider coverage without its own leading. Your Q3 worry also lands there. A reviewer that hunts edge cases might read past the bug that matters. The evidence says the bar on what gets reported doesn't change what gets found, but what a reader is told to focus on does change what it sees. The research's answer to that wasn't a "be especially wary of X" line. It was a second reviewer with an open brief.

The options:
- (a) Fog on this map.
- (b) A ticket on this map now.
- (c) A map of its own, like the five, taking this map's decisions as input.

➡️ (c). Redesigning review is a process change bigger than this map's destination, which is the writing. How review briefs are worded stays here. I'd file the new map with your Q3 words quoted in full, once you say so.