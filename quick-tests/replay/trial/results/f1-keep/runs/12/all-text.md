Your answers are saved in a draft comment for the ticket, but posting it to GitHub was blocked by the permission prompt. The draft is `152-round1.md` in my scratchpad. Say the word and I'll post it, so your Q2, Q3 and Q5 notes are kept on the ticket word for word.

**How I read Q5, so you can correct me:**
- In `safe` (the first mode), no budget ever reaches a brief. Tokens are only measured afterward.
- In `eco` and Let It Rip, a token or wall-clock budget reaches a reader only after you've been asked how much it matters, and it binds only if you approved it as binding.
- When in doubt, it's left out. If it seems important and nobody can ask you, it goes in as information, not as a limit.
- A predicted saving never becomes a requirement for closing a ticket.

---

**Q1 in practice.** (c) mostly comes down to one question for each rule: **whose call is this?**
- **If it's the reader's call, it can't bind.** That covers how it searches, what it reads, in what order, and how it finishes. Anything the writer knows about those goes in as information with its reason, which is your Q2 answer.
- **If it's someone else's call, it binds, but only if that person actually made it.** You merge. Another subagent owns that file. The ticket says what's wanted. You decided the process has a review step.
- **An orchestrator can pass your calls down, but it can't invent new ones about the reader's route.**

Here are some current rules sorted by that question:

| Rule | Whose call | Result |
|---|---|---|
| Never push to main | Yours: merging | Binds |
| The orchestrator never writes the code itself | Yours: you designed the process | Binds |
| Don't edit files another subagent is writing | That subagent's | Binds |
| Reviewer: "Read nothing beyond this brief" | The reviewer's. An orchestrator added it to save cost | Doesn't bind. At most: "the diff is at X" |
| Reviewer: cite a `spec:` line or it isn't a bug | How the reviewer finishes. A subagent added it | Doesn't bind. Under your Q3 answer, the bar moves to a later filter |
| `knowledge`: never read more than 150 lines in one call | The reader's. No reason was ever recorded | Doesn't bind |
| Subagents never launch their own dev servers | Yours, by adopting it from Theo. His reason was dropped | Binds, but should carry its reason again (Q7) |

---

❓ **Q6 - Does that sorting match yours?** The row to check is the second one: the orchestrator never writing the code. It's about the route, but it binds because you made that call about the process.

➡️ Yes. Process steps you decided bind. Route choices nobody owns stay with the reader.

---

❓ **Q4 (again) - Departures and conflicts.** Here are the five mechanisms the factory has today:

1. **Say so loudly and get a sign-off before breaking it** ([AGENTS.md:26](AGENTS.md:26), [template/AGENTS.md:20](template/AGENTS.md:20)). Problems:
   - A subagent has no way to get a sign-off.
   - It pulls against "never block on the human."
   - It has never been seen in use.
2. **Follow the file, then say why your instinct differed** ([template/AGENTS.md:16](template/AGENTS.md:16)). This is the opposite default: comply first, explain after.
3. **Where the spec is silent, decide and record a Provisional row you can overrule** ([DECISIONS.md:67](docs/knowledge/core/DECISIONS.md:67)). Also, re-read PHILOSOPHY "when a rule fights you" ([MANUAL.md:168](docs/knowledge/core/MANUAL.md:168)).
4. **Skip a step with a visible `skip: <reason>`.** This comes from upstream pstack (`poteto-mode/SKILL.md:113`). It is forbidden for delegation ([feature.md:12](template/.agents/skills/poteto-mode/playbooks/feature.md:12)).
5. **Hand it back.** Several places do this already:
   - The review script refuses until every writer flag ends `fixed:` or `accepted: <reason>`.
   - A writer that can't build a test cell as written stops and reports it.
   - A design hole amends the ticket.
   - The falsifiability pass sends bad criteria back to you.

My proposal, mapped against those:
- **A different route from the one the writer suggested:** the reader uses its judgment, and its report always says where it departed and why, or says it didn't. This replaces 2 and 4. Changing 4 needs a patch, since it's vendored.
- **A binding rule that fights the goal:** the reader stops that part, reports the conflict up to whoever owns the rule, and carries on with the rest. This is 1 made workable for subagents, and 5 is already this in practice.
- **3 stays.** A silent spec is a gap, not a conflict.
- **Never shrink the goal to fit a rule.**

➡️ Adopt the proposal.

---

❓ **Q7 - What about the kind of bug you're especially worried about?** Your worry is real, and I overstated the evidence before. It shows that a *reporting bar* leaves the finding intact and only stops the report. A *focus* is different: what you're told to look for decides what you see (the gorilla studies, and Shin's model study).

That means even a slight push in the open brief costs some of what lies outside it. In Shin's study, the fix was a second reviewer whose brief was left open.

The options:
- (a) The open pass stays open. Any class you're especially worried about gets its own focused pass alongside it, and never a line in the open brief.
- (b) Add one line in the open brief, written as information.
- (c) Run the open pass only.

➡️ (a). That's your "multiple passes." Which classes get a pass, and how many, is review-system design, so Q9 decides where that design happens.

---

❓ **Q8 - How are binding rules worded?** The research points one way:
- State the rule once, plainly, with its reason and what to do instead.
- No capitals or "MUST", because current Claude over-applies emphasis.
- No bare "don't", because it keeps the forbidden idea active.
- Where a hook holds the rule, its refusal message carries the reason and the way forward. The git guard already does this: "Use --force-with-lease on your own branch, or ask."

Where the rules live is a separate ticket, "Decide where each piece lives and when it reaches the writer".

➡️ Adopt that wording standard.

---

❓ **Q9 - Where do your side notes go?**
- **The idea of terms that carry many rules at once.** It's an experiment, so it goes to "Decide how we'll know the writing works", with a pointer from "Decide what the writing standard is and what carries it". It sits alongside the experiment the research flagged on illustrative lists.
- **A review system of our own.** No open ticket covers it. The closest are #141 (round counts) and #112 (judge evals). It's process design: passes, verifiers, which reviewers run. It isn't writing, so it sits past this map's destination. I'd file it as a sixth map, with this map's decisions as inputs, and note it under this map's Out of scope.
- **Wall clock in Let It Rip.** Your Q5 words go as a comment on the map "Design Let It Rip as the third mode".

➡️ All three as described, each quoting you word for word.