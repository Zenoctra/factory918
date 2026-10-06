I tried to post your answers word for word as a comment on the ticket, since the map asks for your notes to be kept. The post was declined, so they're saved locally for now (`152-answers-round1.md` in my scratchpad). Do you want me to post them on the ticket?

Here's where each answer leaves things, then round two.

**Q1, explained with real rules.** In plain words, the test is two questions about any rule:
1. Is it about **what** we want, or about **how** to do the work?
2. Who said it's a must?

Only the person who owns a decision can make a rule a must. You own the project, so a rule you set binds whether it's about what or how. An orchestrator owns very little: mainly coordinating its own subagents. Anything else it writes is advice. The what/how half sets the default: a rule about what we want is expected to bind, and a rule about how is advice unless you said otherwise.

Here is that test applied to rules the factory has actually had:

| Rule | About | Who made it a must | Under (c) |
|---|---|---|---|
| Never push to `main` | What: merging is your call | You | Binds |
| The orchestrator never writes the code itself | How | You, after it was broken knowingly ([ledger.md:16](docs/agents/ledger.md:16)) | Binds |
| Run the trail review on every ticket | How | You, after it caught the owner's errors 3 times out of 3 | Binds |
| "Don't edit `auth.ts`, another subagent is in it right now" | Who owns the file at the moment | The orchestrator, which owns that coordination | Binds |
| "Read nothing beyond this brief" (old reviewer brief) | How | Nobody: a lane added it to save tokens | Becomes "the diff is here, the ticket is here", and the reviewer reads whatever it wants |
| "Never read more than 150 lines in one call" (`knowledge` skill) | How | Nobody, and no reason was recorded | Becomes information ("the files are long; the index is here"), or is deleted |
| "Cite a `spec:` line or it isn't a hard bug" | Looks like what done means; really a bar on reporting | A lane | Q3 covers it: report everything, and a later step sorts findings by spec |

**Q2 is settled as (b).** Your point that every added rule costs the reader something applies to everything after this ticket. Your micro-genre idea is a way to reduce that cost: one well-chosen term can carry many rules. When this ticket closes, I'll add it to two other tickets:
- **"Decide how we'll know the writing works"**, as an experiment: how many rules a model follows, and whether a single term carries several of them.
- **"Decide what the writing standard is and what carries it"**, as a technique.

**Q3: part of what I told you was wrong.** The evidence that a reviewer still *finds* everything only applies to a reporting bar. A bar changes what gets reported, not what gets found. Telling a reviewer what to look for is a different effect, and it does change what gets found:
- Observers told to count basketball passes missed the gorilla about half the time.
- In the 2026 preprint, a narrow instruction suppressed findings the model reported without it. A separate reviewer with an open-ended brief recovered them.

So your worry is real, and the "slight push" is the risky part. Q8 below takes it up.

**Q5 is settled.** Your first mode is called `safe`. Q5b below restates your ruling for you to check.

---

❓ **Q4 (again, with the five listed)** - **What happens when a reader departs from advice, or a binding rule fights the goal?** These are the factory's current mechanisms:

1. **Say so loudly and get a sign-off before breaking it.** [AGENTS.md:26](AGENTS.md:26) and [template/AGENTS.md:20](template/AGENTS.md:20), taken from Theo. A subagent has nobody to sign off. It also conflicts with "never block on the human for anything reversible" ([template/AGENTS.md:18](template/AGENTS.md:18)).
2. **Follow the file, then say why your instinct differed.** [template/AGENTS.md:16](template/AGENTS.md:16). Obey first and explain afterward, which is the opposite default to 1.
3. **Where the spec says nothing, decide and record it as Provisional for you to overrule.** PHILOSOPHY, DECISIONS, [ticket.md:30](template/.agents/skills/poteto-mode/playbooks/ticket.md:30).
4. **Skip a step visibly**, leaving it in the list as `skip: <reason>`. This comes from upstream poteto-mode. Delegation is the exception, where [feature.md:12](template/.agents/skills/poteto-mode/playbooks/feature.md:12) forbids skipping.
5. **Send it back up.**
   - A writer that can't implement a test-table cell as written stops and reports it.
   - Every writer flag must end `fixed` or `accepted: <reason>`.
   - A hole in the design amends the ticket with a dated line.

My proposal sorts these into four cases:
- **Advice the reader didn't follow:** it does what it judges best and reports where it went another way and why, or says it didn't. This generalizes 4.
- **A binding rule that fights the goal:** the reader stops that part, reports to the rule's owner, and carries on with the rest. This generalizes 5. In your own session, where you are the owner and you're present, "report to the owner" means "say so loudly and ask", so 1 survives as that case.
- **Nothing was said at all:** 3 stays as it is, because it's a different situation.
- **2 goes.** Obeying a rule you think is wrong and explaining afterward is the goal-shrinking failure this ticket is about.

That corrects what I told you earlier: the proposal doesn't replace all five. It removes 2, merges 1, 4 and 5 into one rule, and keeps 3.

➡️ Adopt that.

---

❓ **Q5b - Does this restate your budget ruling correctly?**
- In `safe`, no budget ever shapes how work is done. Tokens and time are only measured afterward, to look for savings.
- In `eco` and Let It Rip, a budget reaches a brief only after the user has been asked how much it weighs against their other goals. In Let It Rip, that covers wall clock as well as tokens.
- When in doubt, leave the budget out. If it seems important and you can't ask, it goes in as information, never as a limit. A budget written as a must carries the user's approval.
- A predicted saving never becomes a ticket's closing criterion unless you made it one. This last line is mine, drawn from your token-halving story.

➡️ Yes, if the last line matches what you meant.

---

❓ **Q6 - Are the verdicts in the Q1 table right?** That table is the test applied to real cases. If any verdict feels wrong to you, that's where the test is wrong.

➡️ I think they're right. I'm least sure about the `spec:` row. You set the original goal that a review tie its findings to the ticket. A lane turned that goal into a gate.

---

❓ **Q7 - How is a rule that binds written?** The evidence:
- Current Claude models over-apply emphatic wording.
- A bare "don't" keeps the forbidden idea active and doesn't say what to do instead.
- A rule given with its reason generalizes to cases the writer didn't foresee.
- Every repeated rule costs attention (your Q2 pin).

The options:
- (a) State it once, plainly, with its reason and what to do instead, in normal words with no capital-letter MUST. Where a hook or script can hold it, the hook holds it, and its refusal message carries the reason and the way forward. The prose points to the hook instead of repeating the rule.
- (b) Restate it in every brief to be safe.
- (c) Decide case by case.

➡️ (a). Where each rule lives is the ticket "Decide where each piece lives and when it reaches the writer". This question is only how a binding rule is worded.

---

❓ **Q8 - How do we steer review toward a kind of bug we especially care about?**
- (a) Don't steer. One open brief, and a later step sorts findings by kind.
- (b) Add a slight push in the same brief: "we're especially wary of X."
- (c) Keep the open reviewer fully open, and when a kind of bug matters especially, add a separate pass that looks only for that kind, running alongside it.

➡️ (c), with (a) as the default when no kind is special. A push in the same brief is the instruction that, in the gorilla study, decides what gets seen. A separate pass gets the focus without narrowing the open reviewer. It is also the "multiple passes" you described.

---

❓ **Q9 - Where does designing the review system as a whole go?** That means the number of passes, verifiers, measuring recall against planted bugs, and `interrogate`'s leading wording. This map's destination is how agents write. Reviewer *briefs* are inside it: the templates and the rework of existing files. How many passes a review runs, and how it's measured, is process beyond the writing. Two open tickets already touch that process: "Eval the judge and trail-review models the way #103 evals reviewers" and "Choose each tier's review round count from the clean measurement".

The options:
- (a) Its own map, opened when you choose, with this map's decisions as input.
- (b) Kept as an unspecified item on this map.
- (c) Folded into the existing templates and rework tickets.

➡️ (a). Review is big enough, and important enough to you, to get its own destination. Until then I'd record it, in your words, under this map's Out of scope, with a pointer to where it goes next.