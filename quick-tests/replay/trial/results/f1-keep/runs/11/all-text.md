His Q5 is saved as a memory. I'm writing round two now, with Q1 explained again through concrete cases.

**Saved so far.** I tried to post your round-one answers on the ticket, word for word, so they aren't lost. That post was declined, so for now they exist only in this conversation and a local note. Say if you want them posted now; otherwise they go up with the resolution.

**Q5, recorded as you said it.**
- In `safe` (the tier you called Safety Mode), no budget ever shapes how work is done. Tokens and time are only measured afterward, to look for ways to optimize.
- In `eco` and Let It Rip, a budget reaches a reader only after you've been asked how much it matters.
- When in doubt, the budget stays out. If it can't be asked about, it goes in as information, never as a limit. It binds only with your approval.

It's also saved as a standing rule for future sessions.

**Your Q2 note on dense terms.** When this ticket closes, it goes on two tickets:
- "Decide how we'll know the writing works", as an experiment: how many rules get followed, and whether one term carries several rules.
- "Decide what the writing standard is and what carries it", as a technique.

One thought of my own on it: a dense term is a list in disguise, because it pulls toward its genre's norms. That's what you want for a rule, where the norm is the point. It's the same pull as an example list when the goal is open. So I'd expect it to work better for rules than for open goals.

---

### Q1 again, in plain terms

Every rule in a brief decides something. The test is: **whose call is that?**

- **If it's the reader's own call, the writer can only advise.** That covers how the reader does its job: what to read, what to try, in what order, and when it has looked enough. The advice comes with its reason, per Q2.
- **If it's someone else's call, the rule binds, but only if that someone actually made it.** That covers your calls (merging, how the factory runs), another lane's (files it's working in), and the ticket's (what's in scope). An orchestrator can pass your call along. It can't make one for you.

| Rule | Whose call | Did they make it? | Result |
|---|---|---|---|
| Never push to main | Yours: you merge | Yes | Binds |
| The orchestrator never writes the code | Yours: how the factory runs | Yes, after an agent broke it knowingly | Binds |
| Don't edit files another lane is working in | That lane's | The orchestrator assigned them, so it knows | Binds |
| Read only the diff | The reviewer's: how it reviews | Not the writer's to make | Advice at most |
| Token burn must halve before this closes (your story) | Yours: how much budget matters | No, a model turned a prediction into a requirement | Doesn't bind, and under Q5 isn't even mentioned |

If that doesn't match what you chose with (c), say so and I'll re-ask.

### Your Q3 worry

I need to correct something: the evidence is narrower than "both kinds of bug get found." It shows that a bar on *reporting* doesn't stop *finding*: the reviewer finds the bug, then holds it back. Your worry is about where attention goes. That's a different finding, and it's real too. In the gorilla study, what people were counting decided what they saw. A reviewer fixed on edge cases from unsupported input can read straight past a logic bug, and (a) alone doesn't prevent that.

What the evidence offers for it is a second reviewer. In Shin's preprint, a reviewer with an open brief recovered everything the focused one missed. That's your "multiple passes", and it's what Q7 builds on.

---

❓ **Q4 - What happens when the reader departs from the route, or when a binding rule fights the goal?** These are the five mechanisms the factory has today:

| # | Where | What it says | The catch |
|---|---|---|---|
| 1 | [AGENTS.md:26](AGENTS.md:26), [template/AGENTS.md:20](template/AGENTS.md:20) (from Theo) | If a rule fights the task, say so loudly and get a sign-off before breaking it | A subagent has nobody to sign off. It also pulls against "never block on the human" |
| 2 | [template/AGENTS.md:16](template/AGENTS.md:16) | Follow the file, then tell Manuel why your instinct differed | The opposite default to #1: obey first, explain after |
| 3 | PHILOSOPHY, DECISIONS, the Ticket playbook | Where the spec is silent, decide and record a Provisional decision you can overrule | Covers gaps, not conflicts |
| 4 | poteto-mode (pstack, vendored) | A step you skip stays listed as `skip: <reason>`. Delegation can't be skipped | Covers skipped steps only |
| 5 | spec-review, the feature and ticket playbooks | A writer's flag ends as `fixed:` or `accepted: <reason>`. A writer that can't implement a test cell as written stops and reports it. A design hole is added to the ticket with a dated line | Already the stop-and-report shape, but scattered |

My proposal handles each case with one rule:
- **The reader departs from the writer's route.** It uses its judgment, and its report always says where it departed and why, or "none". This generalizes #4 and the `accepted:` half of #5, and replaces #2.
- **A binding rule fights the goal.** The reader stops that part, reports the conflict to the rule's owner, and carries on with the rest. This generalizes the stop-and-report half of #5. It replaces #1 for subagents. In your own session, where the owner is present, it amounts to #1.
- **The reader never shrinks the goal to fit a rule.**
- **#3 stays as it is.** It's about silence, and Garfinkel's point is that some silence always remains.

#4 is pstack's, so changing its wording would need a patch. The rework ticket can decide that.

➡️ The proposal above.

---

❓ **Q6 - What counts as "you made the call"?** Agents wrote many of the factory's rules, and you approved them in bulk through a PR or a ticket. You approved #109 with its "at most" list, then later ruled the list was a prediction, not a constraint. So approving a document didn't make every rule in it binding. The options:

- (a) Anything in a file you approved binds.
- (b) A rule binds only where you made it binding on its own: in your own words, a DECISIONS row quoting you, a hook you asked for, or a direct ruling.
- (c) Same as (b). Existing rules that don't meet that bar are read as advice until the rework ticket sorts them.

➡️ (c). It fails open, like your budget answer. The rules that matter most are already held by hooks or DECISIONS rows, so they keep their force. The cost is that some sensible rules drop to advice for a while. Advice with its reason still gets followed when it's right.

---

❓ **Q7 - May a brief tell a reviewer what the writer is especially wary of?** This is your "slight push". The evidence cuts both ways:
- Naming something pulls answers toward it. In one survey, four problems went from 2% of answers to 60% once they were listed.
- Naming something also reminds people of what they'd have counted but didn't think of. "Invention of the computer" went from 1–2% to about 30% once listed.

In short, you get more of what you named and less of what you didn't. The options:

- (a) Never. Multiple passes cover it.
- (b) Only in a separate pass. One reviewer always gets the open brief, with nothing emphasized. Another reviewer may be told "we're especially wary of X", with the reason.
- (c) In the same brief, written as information.

➡️ (b). The open pass protects what nobody predicted, and the focused pass gets the benefit of the reminder. This is the shape of Shin's result. How many passes and which focuses belong to the review system (Q9).

---

❓ **Q8 - How is a binding rule worded?** Three findings from the research apply:
- Current Claude models over-apply emphatic wording.
- A bare prohibition keeps the forbidden idea active and doesn't say what to do instead.
- A rule given with its reason is followed more willingly and more sensibly.

So instead of "NEVER push to main", a brief would say: "Merging is Manuel's call, so push only to your branch. If the task seems to need main, report that to him."

➡️ Every binding rule is written plainly, says what to do, gives its reason, and names whom to report to. Where binding rules sit (repeated in every brief, or in a hook's refusal at the moment it's needed) is for the ticket "Decide where each piece lives and when it reaches the writer".

---

❓ **Q9 - Where does the review system go?** What you described is bigger than writing: the passes, what each one looks for, the verifier, and measuring how many planted bugs are missed, not only false positives. This map covers how agents write. Its brief-template prototype will touch review briefs, but not the review process. The options:

- (a) Fog on this map.
- (b) Its own map, a sixth, opened with your Q3 words, taking this map's decisions as inputs, and absorbing open tickets like "Choose each tier's review round count from the clean measurement" and "Eval the judge and trail-review models the way #103 evals reviewers".
- (c) Wait until this map is done.

➡️ (b), filed now as a stub holding your words, and charted in its own session.