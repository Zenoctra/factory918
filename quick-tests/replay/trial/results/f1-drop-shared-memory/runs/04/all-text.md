I tried to post your answers on the ticket word for word and the comment was denied, so nothing is posted. They're safe in this conversation, and I'll quote them in full in the ticket's closing comment unless you'd like them posted somewhere sooner.

## Q1, in practice

Here's (c) again without the abstraction. Every rule a writer puts in a brief came from one of two places:

- **You decided it.** It's in AGENTS.md, a ticket, or a decision you made. It binds.
- **The writer made it up.** It binds only if it's about something the writer itself is in charge of. Everything else the writer knows goes in as information with its reason, and the reader is free to find a better way.

Applied to real rules from the factory:

| Rule | Where it came from | Under (c) |
|---|---|---|
| Never push to main | You | Binds |
| The orchestrator delegates code to a lane, never writes it | You, with evidence | Binds |
| Don't edit `auth.ts`, another lane is editing it right now | The orchestrator, which owns who edits what | Binds, with the reason |
| Read nothing beyond this brief | A lane, to save tokens (#33) | Doesn't bind. At most it becomes "the change is in these files" |
| Under 400 words | A lane | Gone; Q3 moves bars to a later filter step |
| Never read more than 150 lines at once (`knowledge` skill) | No recorded reason, no owner | Becomes information, or is cut |

I need to correct something from last round. I said the delegation rule binds "because you own it, not because of what it says", while also recommending that a rule needs both conditions. Those two statements contradict each other. The simpler version in the table is what I actually mean: **you can bind anything, and a writer can bind only what it's in charge of.**

This also creates work for the rework ticket, "Decide the scope and order of reworking existing files". The run-2 audit found that several rules that look like yours were added by lanes without being asked, among them the review-brief reading limits from #33, #93 and #107. Before anything is reworked, each rule has to be traced to who actually decided it.

If the table matches what you meant by (c), I'll treat Q1 as settled.

## Q2

Settled as (b). I'll pin your point about one well-chosen term carrying many rules on two tickets: "Decide what the writing standard is and what carries it" and "Decide how we'll know the writing works". The experiment is in your own words: how many rules a model actually follows, whether one term can carry several of them, and which rules still need stating separately.

## Q5

Your answer went beyond my options, so here it is as I'd record it. Correct me where it's off.

- **The first mode is called `safe`.** In `safe`, no budget ever shapes how work is done. Tokens and time are only measured afterward, to look for savings.
- **In `eco` and Let It Rip**, a budget exists only once you set one. Before it goes into any brief as binding, you're asked how much it should weigh against your other goals. Let It Rip adds wall clock as a second budget under the same rule. Setting an overall goal never means a reader has to be told about it, and it never overrides processes you've required.
- **When in doubt, the budget stays out of the brief.** If a writer thinks a budget matters but can't stop to ask, it goes in as information, not a limit. A binding budget always carries your approval. Your anecdote is the test case: a guessed "halves the token use" became a condition for closing the ticket without anyone asking you.

This also touches the map "Design Let It Rip as the third mode", so I'll leave a pointer there when this ticket closes.

---

❓ **Q4 (asked again, with the five listed) - What does a reader do when it wants a different route, or when a binding rule fights the goal?** Here is what the factory says today:

1. **Ask first.** "If one fights the task in front of you, say so loudly and get a sign-off before breaking it" ([AGENTS.md:26](AGENTS.md:26), [template/AGENTS.md:20](template/AGENTS.md:20)).
   - A subagent has nobody to sign off for it.
   - It conflicts with "never block on the human" two lines above it in the template.
   - There's no record of it ever being used.
2. **Obey first, explain after.** "When this file and a vendored skill disagree with your instinct, follow the file and tell me why your instinct differed" ([template/AGENTS.md:16](template/AGENTS.md:16)).
   - This sits in **"A note from Manuel"**, so it's in your voice. Changing it changes your note.
3. **Decide and record.** Where the spec says nothing, the agent makes the call and logs it as a Provisional decision you can overrule.
4. **Skip visibly.** poteto-mode lets an agent skip a step if it leaves a `skip: <reason>` line in the list. Skipping is forbidden only for delegation.
5. **Send it back.** Some gates turn a disagreement into a visible stop:
   - The review script refuses to run until every writer flag ends `fixed:` or `accepted: <reason>`.
   - A writer that can't implement a test cell as written stops and reports, and never fills it in.
   - A hole in a design amends the ticket with a dated line.

My proposal, and what it does to each:

- **The reader wants a different route.** It takes it. Its report always says where it departed and why, or says it didn't. Mechanisms 3 and 4 merge into this single report line.
- **A binding rule fights the goal.** The reader stops that part, reports the conflict to whoever owns the rule, and carries on with the rest.
  - This replaces 1, because there's no waiting on a sign-off.
  - It also replaces 2. Following a rule that makes the work worse, and explaining afterward, produces a weaker result that looks complete. That is the quiet narrowing this ticket exists to stop.
  - Mechanism 5 stays as it is, since those gates are already stop-and-report.
- **The reader never shrinks the goal to fit a rule.**

➡️ Adopt the proposal. Because mechanism 2 is in your note, I'd ask you to reword that sentence yourself rather than have a lane rewrite your voice. The ticket would only record that it needs changing.

---

❓ **Q6 - The "slight push" toward bugs we care about.** You're right to worry about this, and the research separates it into two effects:

- **A bar**, like "only report severe bugs", makes the reader find a bug and then withhold it. Moving the bar to a later filter step (your Q3 answer) fixes this.
- **A focus**, like "look especially for X", can stop the reader from seeing Y at all. That's the gorilla effect. A slight push is still a focus, so it carries the same risk on a smaller scale. In the one model study of this, the fix wasn't better wording. A second reviewer with an open-ended brief recovered everything the focused one missed.

The options:
- (a) No push in any reader's brief.
- (b) A light push in the brief.
- (c) No push in the open reviewer's brief. When a kind of bug matters especially, it gets its own reviewer, focused on it, alongside the open one and never instead of it.

➡️ (c). Each brief stays honest about what its reader is for, and it lines up with the multiple passes you described.

---

❓ **Q7 - Where does the review system you described live?** By "the review system" I mean several passes with better briefs, a verifier that sorts findings, and measuring how many planted bugs get caught, not just how few false alarms there are. Related work already exists:

- the reviewer eval in #103, which found that 4 of 13 labelled bugs sat in files the brief told the reviewer not to open;
- #112, which evaluates judges;
- #141, which sets round counts.

The review *briefs* are in this map's scope: the template ticket, and the rework ticket, which the research says should start with adversarial briefs. The review *process* is bigger than writing.

The options:
- (a) A map of its own, opened when you choose, with a line in this map's Out of scope pointing to it.
- (b) Fold it into the template ticket.
- (c) A ticket on the map "Optimize token use and wall-clock time without losing reliability".

➡️ (a). Folding it into (b) would make one ticket carry a whole system. Under (c), the effort would be judged by cost, when what you described is judged by how many bugs it catches.