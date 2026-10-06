Q2 and Q5 are settled. Your budget rule is saved as a standing memory so it applies beyond this map. I've kept all your answers word for word, ready for this ticket's resolution comment. Before the next questions, here's Q1 again in plainer terms, since round two builds on it.

## Q1 in practice

Think of a contractor building a deck:
- The client says "it has to hold ten people." That's what done means, and it binds.
- The client says "don't touch the neighbour's fence." The fence isn't the client's or the contractor's to decide about, so that binds.
- The HOA requires a permit. The HOA owns that call, so it binds.
- The client says "use the circular saw, the miter saw's blade is chipped." That's useful information with a reason. If the contractor has a better saw, they use it.

So for any rule, ask: **did it come from whoever owns that call?** You own the whole factory, so a process you've required binds. You said so in your Q5 answer: your goals include "setting specific processes that are required." A ticket's author owns its scope. An orchestrator owns only what it is coordinating right now, such as which files another subagent is editing. Anything else the writer thinks would help goes in as information, with its reason.

In the factory:

| Rule | Binds? | Why |
|---|---|---|
| Never push to main | Yes | Merging is yours |
| The orchestrator never writes the code | Yes | It's about method, but you required it |
| Read only the diff (written by an orchestrator) | No | The orchestrator's guess about method. At most: "the diff is here, the ticket is here" |
| Run `architect` first (an orchestrator's idea) | No | Information, with its reason, if it's worth saying at all |

## Your Q2 note: one well-chosen term instead of many rules

I've pinned it. The research supports the problem but has nothing on your fix. It found that the more rules a reader gets, the fewer it follows, and that text repeated in every brief gets skimmed. Nobody has tested whether one well-chosen term can carry a set of rules the way your micro-genre carries 90% of a song. That makes it an experiment, and it belongs to "Decide how we'll know the writing works". The experiment would measure how many rules get followed, whether a single term carries several of them, and which rules still need stating. I'll add it to that ticket's notes when I record this one.

---

❓ **Q4 (asked again) - What does a reader do when a rule fights the task?** These are the five mechanisms the factory has today:

1. **Ask first.** [AGENTS.md:26](AGENTS.md:26): "say so loudly and get a sign-off before breaking it." A subagent has nobody to ask. It also clashes with "never block on the human."
2. **Obey, then explain.** [template/AGENTS.md:16](template/AGENTS.md:16): "follow the file and tell me why your instinct differed." This is the opposite default to 1.
3. **Decide and record.** Where the spec says nothing, the agent picks and writes a Provisional row in `DECISIONS.md` that you can overrule.
4. **Skip with a reason.** poteto-mode keeps a skipped step in its list with `skip: <reason>`. The delegation step is the exception: it can't be skipped.
5. **Send it back up.** A writer that can't build a test cell as written stops and reports the cell. Reviewer flags must end `fixed` or `accepted: <reason>`. A design hole gets written back into the ticket.

Only 1, 2 and 4 cover a rule fighting the task. 3 and 5 cover gaps and mismatches in the spec, and they can stay as they are.

My proposal replaces 1, 2 and 4 with one rule:

| Situation | What the reader does | Replaces |
|---|---|---|
| A rule that binds fights the goal, and the owner is in the conversation (the session you type into) | Asks first | 1, unchanged for the session you type into |
| A rule that binds fights the goal, and nobody is there to ask (a subagent) | Stops that part, reports the conflict to whoever owns the rule, and carries on with the rest | 1 and 2 |
| The reader takes a different route from the one the writer described | Uses its own judgment. Its report always says where it departed and why, or says it didn't | 4, extended to every brief |
| Any case | Never quietly shrinks the goal to fit a rule | — |

➡️ Adopt the table.

---

❓ **Q6 - A focus without a fence.** You asked whether the evidence says both kinds of bug still get found. Partly. The evidence separates two things:
- **A bar on what to report** ("only high-severity"). The reader still finds the bugs and just doesn't write some down. Your (a) fixes this: report everything, rate it separately.
- **A focus on what to look for** ("we're especially wary of X"). This is your worry, and it's real. What the reader is told to look at decides what it sees, as in the gorilla study and the 2026 model preprint. A reader left alone also picks its own focus, often the same one every time, such as edge-case inputs. So the "slight push" you described would hide whatever it didn't name, and a separate verifier can't rate bugs that were never found.

What fixed this in the research was structure, not wording. A second reviewer with an open brief recovered everything the focused one missed.

➡️ When a kind of bug matters especially, say so in the goal, as what's wanted, never as the edge of what to look for. Whenever a focus is stated, an open pass with no focus runs too. How many passes there are and how they're split is review-system design (Q7).

---

❓ **Q7 - Where does the review system get designed?** No open ticket covers designing our own review system. The closest are "Choose each tier's review round count from the clean measurement" and "Eval the judge and trail-review models the way #103 evals reviewers". These are your notes for it:
- spec-review looks mainly for bugs, and interrogate looks wider.
- interrogate itself leads the witness.
- Studies celebrate zero false positives while missing half the planted bugs.
- Several passes are needed.

The options:
- (a) Its own wayfinder map, since the number of passes, the verifiers and recall measured against planted bugs are process questions, beyond this map's destination. This map keeps the review *briefs*, through the templates prototype, and points to the new map from "Out of scope".
- (b) Fog on this map.

➡️ (a). I'd open it as a map carrying your full words from this answer, in a session of its own.

---

❓ **Q8 - How is a binding rule written?** The research gives three findings:
- Plain wording with the reason works better than CAPS or MUST. Current Claude models over-apply emphatic rules.
- A bare "don't" names the forbidden thing and doesn't say what to do instead.
- A hook's refusal arrives at the moment of the act. The git guard already does this well: it blocks, gives the reason, and offers "Use --force-with-lease on your own branch, or ask."

Restating every binding rule in every brief adds to the rule count you flagged in Q2, and repeated text gets skimmed.

The options:
- (a) Each binding rule is written once, plainly, with its reason and what to do instead. Where a hook enforces it, the hook's message carries the reason and the way forward, and briefs don't repeat it. Where no hook reaches, as with the delegation hook, which covers only the session you type into, the rule goes in the brief, written the same way.
- (b) Restate binding rules in every brief, to be safe.

➡️ (a).

---

Once Q4 and Q8 are settled, the last round tests the whole answer against real cases: the `spec:` citation gate, the delegation rule, and the 150-line reading cap in `knowledge`.

Do you want your round answers posted to this ticket now, word for word, the way the charting rounds were posted on the map? Otherwise they go in the resolution comment.