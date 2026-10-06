Here's where this round landed. I'll post your answers word for word on the ticket when it closes, as with the earlier rounds.

**Q2 (b), plus your point about terms that pull related ideas with them.** You compared it to naming the right micro-genre for a song instead of listing BPM and guitar style: one term can carry most of what a list of rules would say, for fewer tokens. Then you write out only what that term wouldn't already bring. It fits the research: the more rules a reader gets, the fewer it follows. I'll add it to the map's "Not yet specified" section as something to test: how many rules a reader actually follows, which terms bring rules along with them, and which rules still need stating on their own even when a term covers them. That test belongs with the tickets "Decide what the writing standard is and what carries it" and "Decide how we'll know the writing works".

**Q3 (a).** I need to correct one thing. The evidence doesn't say a reviewer left to itself finds every kind of bug. It says a bar on what to report doesn't stop the finding; it only stops the reporting. Your worry, a reviewer drifting into unusual-input edge cases and reading past the bugs you care about, is a different problem. Q7 below takes it up.

**Q5: settled as you put it.**
- In the default mode, no budget ever shapes the process. Budgets are only measured afterward, to look for savings.
- In eco and Let It Rip, a budget reaches a brief only after you set it. Before it does, I ask you how much it should weigh against your other goals.
- If in doubt, leave the budget out of the brief.
- If it seems important and I can't ask you, it goes in as information, not as a rule.
- A budget written as a rule must have your approval.

Your story fits one of the research findings: an agent turned a guess ("this might halve the token use") into a requirement and then cut required steps to meet it. People paid on one measure start treating the measure as the goal, without noticing.

---

## Q1 in practice, with a fix to how I framed it

I made a mistake last round. I said a rule binds only if it is "about the task" and also "owned", but then I used the trail review as an example of a binding rule. The trail review is about how the work is done, so under my own test it couldn't bind. Here is the version that holds together:

**You decide what the task is, and that can include steps you require.** When you say "every ticket gets a trail review", the review becomes part of the job. Someone writing a brief can't do the same thing with their own guesses.

So the question for any rule in a brief is **"who said this must happen, and do they have the right to say it?"**

| Rule in a brief | Who said it must | Result |
|---|---|---|
| "Never push to main" | You: merging is your decision | Binding |
| "Run the trail review before handing off" | You, with evidence it catches errors | Binding |
| "Don't edit `foo.ts`, another lane is in it" | The writer, which owns how the work is split up | Binding |
| "Read only the diff" | The writer's guess about where the bugs are | Not binding. It goes in as advice with its reason, or not at all |
| "Halve the token use" | A guess, never approved | Not binding, per Q5 |

Anything that isn't binding becomes **what the writer knows**: "I found the bug was in X last time, because Y." The reader can use that or ignore it.

---

❓ **Q4 - One way to depart from a rule, in place of the five we have now.** Here are the five, and where they conflict:

1. **Ask first.** [AGENTS.md:26](AGENTS.md:26): "say so loudly and get a sign-off before breaking it." A subagent has nobody to ask, and I found no record of this ever being used.
2. **Obey, then explain.** [template/AGENTS.md:16](template/AGENTS.md:16): "follow the file and tell me why your instinct differed." The rule wins even when it fights the goal.
3. **Decide and log it.** Where the spec is silent, the agent decides and writes a Provisional row in DECISIONS for you to overrule.
4. **Skip with a note.** poteto-mode lets a step be skipped with `skip: <reason>`. Delegation is marked as the one step that can't be skipped.
5. **Push the conflict back to its source.**
   - Writer flags must end `fixed` or `accepted: <reason>`.
   - A writer that can't implement a test cell as written stops and reports it.
   - A hole in the design gets a dated line added to the ticket.

Numbers 1 and 2 contradict each other: one says ask before acting, the other says obey and explain later. Numbers 3 and 4 say act, then record.

➡️ Replace them with one rule that has three parts:
- **Advice:** the reader uses its own judgment, and its report always says where it took a different route and why, or says it didn't.
- **A binding rule that fights the goal:** the reader stops that part, reports the conflict to whoever owns the rule, and finishes the rest. This is number 5, made general.
- **Never:** quietly shrinking the goal to fit a rule.

Numbers 3 and 4 become the report line. Number 1 stays only in the main session, where you're there to sign off. Number 2 goes.

---

❓ **Q6 - How binding rules are worded and enforced.** From the research:
- Readers over-apply emphatic wording ("CRITICAL", "MUST").
- A bare "don't" keeps the forbidden idea active and doesn't say what to do instead.
- Every rule you add dilutes the rest, as you said under Q2.

The options:
- (a) Write each binding rule once, plainly, with its reason and what to do instead. Where a hook enforces it, the brief doesn't repeat it. The hook's refusal message carries the reason and a way forward, at the moment it matters.
- (b) Repeat binding rules in every brief, to be safe.

➡️ (a). The hooks already show the pattern: the git guard says "use --force-with-lease on your own branch, or ask."

---

❓ **Q7 - Your worry under Q3: when you're especially wary of one kind of bug.** You suggested a slight push in the brief ("we're especially wary of X"), and you already suspected it would cause trouble. The research says it would. Telling an observer what to look for is what made people miss the gorilla. In Shin's study, though, a separate reviewer with an open brief recovered what the focused one missed.

The options:
- (a) Add the push to the one reviewer's brief.
- (b) Keep the main reviewer's brief open. Concern about a particular kind of bug becomes its own lane with its own focused brief. The two run side by side, and the step after them combines and sorts the findings.
- (c) Nothing about bug types in any brief.

➡️ (b). Focus is useful as an extra pass. It's harmful as a filter on the only pass.

---

❓ **Q8 - Where your review-system idea goes.** You noted three things:
- spec-review looks mostly for bugs;
- interrogate covers more ground, including security, but its vendored script also leads the witness;
- review studies report no false positives while missing half the bugs planted for them.

Designing the review system means deciding passes, lanes and how findings get combined. That's process design, which is bigger than this map's subject, writing.

The options:
- (a) A sixth map of its own, which uses this map's decisions as input.
- (b) A ticket on this map.
- (c) A note in this map's "Not yet specified" section.

➡️ (a). Meanwhile, the review brief templates stay in this map's "Prototype brief templates for the recurring lane jobs", and Q3 and Q7 here become that new map's starting point.